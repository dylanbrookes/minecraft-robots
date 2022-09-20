import { HOSTNAME, TURTLE_REGISTRY_PROTOCOL_NAME } from "../Consts";
import { EventLoop } from "../EventLoop";
import generateName from "../generateName";
import TurtleStore, { TurtleRecord } from "../stores/TurtleStore";

export enum TurtleRegistryCommand {
  REGISTER = 'REGISTER',
  LIST = 'LIST',
}

export default class TurtleRegistryService {
  private registered = false;

  constructor(private turtleStore: TurtleStore) {}

  // expects rednet to already be open
  register() {
    if (this.registered) throw new Error("TurtleRegistryService is already registered");
    this.registered = true;

    console.log("Registering Turtle Registry Service");
    rednet.host(TURTLE_REGISTRY_PROTOCOL_NAME, HOSTNAME);
    EventLoop.on('rednet_message', (sender: number, message: any, protocol: string | null) => {
      if (protocol === TURTLE_REGISTRY_PROTOCOL_NAME) {
        this.onMessage(message, sender);
      }
      return false;
    });
  }

  private onMessage(message: any, sender: number) {
    console.log("Got TurtleRegistryService message from sender", sender, textutils.serialize(message));
    if (!('cmd' in message)) {
      console.log("idk what to do with this", textutils.serialize(message));
      return;
    }

    switch (message.cmd) {
      case TurtleRegistryCommand.REGISTER:
        if (message && typeof message === 'object') {
          const updates = {
            lastSeen: os.epoch(),
            location: undefined,
            currentBehaviour: message.currentBehaviour,
            status: message.status,
          }

          if ('location' in message) {
            const location = message.location;
            if (Array.isArray(location) && location.length === 3) {
              updates.location = message.location;
            } else {
              console.log("Invalid location", textutils.serialize(message.location));
            }
          }
          
          if (this.turtleStore.exists(sender)) {
            console.log(`Turtle ${sender} registered again`);
            this.turtleStore.update(sender, updates);
            this.turtleStore.save();
            rednet.send(sender, { ok: true }, TURTLE_REGISTRY_PROTOCOL_NAME);
          } else {
            
            const record: TurtleRecord = {
              id: sender,
              label: generateName(),
              registeredAt: os.epoch(),
              ...updates
            };
            this.turtleStore.add(record);
            this.turtleStore.save();
            rednet.send(sender, {
              ok: true,
              label: record.label,
            }, TURTLE_REGISTRY_PROTOCOL_NAME);
          }
        } else {
          console.log("Invalid register params", textutils.serialize(message));
          // console.log(typeof message, 'location' in message, Array.isArray(message.location), (message.location as Array<number>)?.length);
        }
        break;
      case TurtleRegistryCommand.LIST:
        rednet.send(sender, this.turtleStore.toString(), TURTLE_REGISTRY_PROTOCOL_NAME);
        break;
      default:
        console.log("invalid TurtleRegistryService command", message.cmd);
    }
  }
}
