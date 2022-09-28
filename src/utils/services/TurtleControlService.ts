import { TurtleClient } from "../clients/TurtleClient";
import { HOSTNAME, TurtleControlEvent, TURTLE_CONTROL_PROTOCOL_NAME } from "../Consts";
import { EventLoop } from "../EventLoop";
import generateName from "../generateName";
import Logger from "../Logger";
import TurtleStore, { TurtleRecord, TurtleStatus, TurtleStatusUpdate } from "../stores/TurtleStore";

export enum TurtleControlCommand {
  TURTLE_CONNECT = 'TURTLE_CONNECT',
  TURTLE_PING = 'TURTLE_PING',
  TURTLE_SOS = 'TURTLE_SOS',
  TURTLE_TERMINATE = 'TURTLE_TERMINATE',
  LIST = 'LIST',
}

const buildUpdates = (status: TurtleStatusUpdate, turtleRecord?: TurtleRecord): Pick<TurtleRecord, keyof TurtleStatusUpdate | 'lastSeen' | 'lastKnownLocation'> => {
  const lastKnownLocation = status.location || turtleRecord?.location || turtleRecord?.lastKnownLocation;
  return {
    lastSeen: os.epoch('utc'),
    location: status.location,
    lastKnownLocation: lastKnownLocation && [...lastKnownLocation], // need to copy to prevent repeating location
    currentBehaviour: status.currentBehaviour,
    status: status.status,
  }
}

export default class TurtleControlService {
  private registered = false;
  private static CHECK_TURTLES_EVENT = 'TurtleControlService:check_turtles';
  private static STALE_TURTLE_TIMEOUT = 10; // seconds after we last saw a turtle we'll check on it

  constructor(private turtleStore: TurtleStore) {}

  // expects rednet to already be open
  register() {
    if (this.registered) throw new Error("TurtleControlService is already registered");
    this.registered = true;

    Logger.info("Registering Turtle Control Service");
    rednet.host(TURTLE_CONTROL_PROTOCOL_NAME, HOSTNAME);
    EventLoop.on('rednet_message', (sender: number, message: any, protocol: string | null) => {
      if (protocol === TURTLE_CONTROL_PROTOCOL_NAME) {
        this.onMessage(message, sender);
      }
      return false;
    });

    EventLoop.on(TurtleControlService.CHECK_TURTLES_EVENT, () => this.checkTurtles(), { async: true });
    EventLoop.emitRepeat(TurtleControlService.CHECK_TURTLES_EVENT, TurtleControlService.STALE_TURTLE_TIMEOUT);
    EventLoop.setTimeout(() => EventLoop.emit(TurtleControlService.CHECK_TURTLES_EVENT));
  }

  private checkingTurtles = false;
  /**
   * Periodically called to see if any turtles have gone missing.
   */
  private checkTurtles() {
    if (this.checkingTurtles) {
      Logger.debug('Skipping turtle check, already in progress');
      return;
    }
    this.checkingTurtles = true;
    // Logger.info('Checking for stale turtles...');
    for (const staleTurtle of this.turtleStore
      .select(({ lastSeen, status }) => status !== TurtleStatus.OFFLINE
        && os.epoch('utc') > lastSeen + TurtleControlService.STALE_TURTLE_TIMEOUT * 1000)) {
      const turtleClient = new TurtleClient(staleTurtle.id);
      Logger.info("Contacting", staleTurtle.label);
      const status = turtleClient.status();
      if (!status) {
        Logger.warn(`Failed to contact turtle ${staleTurtle.label} [${staleTurtle.id}], setting status OFFLINE`);
        this.turtleStore.update(staleTurtle.id, { status: TurtleStatus.OFFLINE });
        EventLoop.emit(TurtleControlEvent.TURTLE_OFFLINE, staleTurtle.id);
      } else {
        Logger.info("Got status from turtle", staleTurtle.label, status);
        this.turtleStore.update(staleTurtle.id, buildUpdates(status, staleTurtle));
      }
      this.turtleStore.save();
    }
    this.checkingTurtles = false;
  }

  private onMessage(message: any, sender: number) {
    Logger.debug("Got TurtleControlService message from sender", sender, textutils.serialize(message));
    if (!('cmd' in message)) {
      Logger.error("idk what to do with this", textutils.serialize(message));
      return;
    }

    switch (message.cmd) {
      case TurtleControlCommand.TURTLE_CONNECT:
        if (message && typeof message === 'object') {
          let turtleRecord = this.turtleStore.get(sender);
          const updates = buildUpdates(message, turtleRecord);
          
          if (turtleRecord) {
            if (turtleRecord.status !== TurtleStatus.OFFLINE) {
              // if we got a connect msg without it being offline first, the turtle was probably picked up and placed again quickly
              // trigger offline event to reap jobs
              EventLoop.emit(TurtleControlEvent.TURTLE_OFFLINE, turtleRecord.id);
            }
            turtleRecord = this.turtleStore.update(sender, updates);
            this.turtleStore.save();
            Logger.info(`Turtle ${turtleRecord.label} [${sender}] reconnected`);
            rednet.send(sender, {
              ok: true,
              label: turtleRecord.label,
            }, TURTLE_CONTROL_PROTOCOL_NAME);
          } else {
            // a new turtle :)
            turtleRecord = Object.assign({
              id: sender,
              label: generateName(),
              registeredAt: updates.lastSeen,
            }, updates);
            Logger.info(turtleRecord);
            this.turtleStore.add(turtleRecord);
            this.turtleStore.save();
            rednet.send(sender, {
              ok: true,
              label: turtleRecord.label,
            }, TURTLE_CONTROL_PROTOCOL_NAME);
          }

          if (turtleRecord.status === TurtleStatus.IDLE) {
            EventLoop.emit(TurtleControlEvent.TURTLE_IDLE, turtleRecord.id);
          }
        } else {
          Logger.error("Invalid connect params", textutils.serialize(message));
          // Logger.error(typeof message, 'location' in message, Array.isArray(message.location), (message.location as Array<number>)?.length);
        }
        break;
      case TurtleControlCommand.TURTLE_PING:
        const turtleRecord = this.turtleStore.get(sender);
        if (!turtleRecord) {
          Logger.error("received turtle ping from unknown sender " + sender);
          break;
        }

        if (message && typeof message === "object") {
          this.turtleStore.update(sender, buildUpdates(message, turtleRecord));
          this.turtleStore.save();
          Logger.debug(`Received ping from ${turtleRecord.label} [${sender}]`);
          // don't pong
        } else {
          Logger.error("Invalid ping params", message);
        }
        break;
      case TurtleControlCommand.TURTLE_TERMINATE:
        if (!this.turtleStore.exists(sender)) {
          Logger.error("received turtle terminate from unknown sender " + sender);
          break;
        }
        const turtle = this.turtleStore.update(sender, { status: TurtleStatus.OFFLINE });
        EventLoop.emit(TurtleControlEvent.TURTLE_OFFLINE, sender);
        Logger.info(`Turtle ${turtle.label} [${sender}] terminated`);
        break;
      case TurtleControlCommand.LIST:
        rednet.send(sender, this.turtleStore.toString(), TURTLE_CONTROL_PROTOCOL_NAME);
        break;
      default:
        Logger.error("invalid TurtleControlService command", message.cmd);
    }
  }
}
