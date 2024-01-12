import { TURTLE_CONTROL_PROTOCOL_NAME } from "../Consts";
import { EventLoop } from "../EventLoop";
import { TurtleControlCommand } from "../services/TurtleControlService";
import { TurtleRecord } from "../stores/TurtleStore";
import Logger from "../Logger";
import getStatusUpdate from "../turtle/getStatusUpdate";

export class TurtleControlClient {
  private static REGISTER_EVENT = 'TurtleRegistryClient:registerSelf';
  private static REGISTER_RETRY_INTERVAL = 5;
  private static PING_EVENT = 'TurtleRegistryClient:sendPing';
  private static PING_INTERVAL = 5;
  private terminated = false;
  constructor(private hostId: number) {}

  // don't call this on non-turtle hosts
  register() {
    EventLoop.on(TurtleControlClient.REGISTER_EVENT, () => this.registerSelf(), { async: true });
    EventLoop.on(TurtleControlClient.PING_EVENT, () => this.sendPing(), { async: true });
    // register upon startup
    EventLoop.setTimeout(() => EventLoop.emit(TurtleControlClient.REGISTER_EVENT), 1);

    EventLoop.on('terminate', () => {
      Logger.info("Notifying control server that we're terminating");
      this.terminated = true;
      this.call(TurtleControlCommand.TURTLE_TERMINATE, {}, false);
    }, { async: true });
  }

  private call<T>(cmd: TurtleControlCommand, args: object = {}, getResponse: boolean = true, assertResponse = true): T | undefined {
    rednet.send(this.hostId,{
      cmd,
      ...args,
    }, TURTLE_CONTROL_PROTOCOL_NAME);
    // Logger.info("Send cmd", cmd);

    if (getResponse) {
      const [pid, message] = rednet.receive(TURTLE_CONTROL_PROTOCOL_NAME, 3);
      if (!pid && assertResponse) throw new Error("No response to command " + cmd);
      return message as T;
    }
    return undefined;
  }

  list(): TurtleRecord[] {
    return this.call(TurtleControlCommand.LIST)!;
  }

  private registerSelf(): void {
    if (this.terminated) return;
    if (typeof turtle === 'undefined') {
      throw new Error('Can only register on a turtle');
    }

    // if (!LocationMonitor.hasPosition) {
    //   Logger.warn("Missing location, will retry registration");
    //   EventLoop.setTimeout(() => EventLoop.emit(TurtleControlClient.REGISTER_EVENT), 1);
    //   return;
    // }

    Logger.info("Connecting to turtle control server...");

    const resp = this.call<{ ok: boolean, label: string }>(TurtleControlCommand.TURTLE_CONNECT, getStatusUpdate(), true);
    if (!resp?.ok) {
      // this could happen if the server crashes
      Logger.warn("Turtle register failed, will retry:", textutils.serialize(resp));
      EventLoop.setTimeout(() => EventLoop.emit(TurtleControlClient.REGISTER_EVENT), TurtleControlClient.REGISTER_RETRY_INTERVAL);
      return;
    }

    if (typeof resp.label === 'string') {
      os.setComputerLabel(`${resp.label} [${os.computerID()}]`);
    } else {
      // console.log("Did not receive label from registry");
    }

    Logger.info("Done registration");
    EventLoop.emitRepeat(TurtleControlClient.PING_EVENT, TurtleControlClient.PING_INTERVAL);
  }

  private sendPing(): void {
    if (this.terminated) return;
    // Logger.info("sent ping");
    this.call(TurtleControlCommand.TURTLE_PING, getStatusUpdate(), false);
  }
}
