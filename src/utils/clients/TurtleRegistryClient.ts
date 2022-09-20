import { TURTLE_REGISTRY_PROTOCOL_NAME } from "../Consts";
import { EventLoop } from "../EventLoop";
import { LocationMonitor, TurtlePosition } from "../LocationMonitor";
import { TurtleRegistryCommand } from "../services/TurtleRegistryService";
import { BehaviourStack } from "../turtle/BehaviourStack";
import { TurtleRecord, TurtleStatus } from "../stores/TurtleStore";

export class TurtleRegistryClient {
  constructor(private hostId: number) {}

  // don't call this on non-turtle hosts
  startPeriodicRegistration() {
    const eventName = 'TurtleRegistryClient:registerSelf';
    EventLoop.on(eventName, () => this.registerSelf(), { async: true });
    EventLoop.emitRepeat(eventName, 5);
  }

  private call(cmd: TurtleRegistryCommand, args: object = {}, assertResponse: boolean = true): any {
    rednet.send(this.hostId,{
      cmd,
      ...args,
    }, TURTLE_REGISTRY_PROTOCOL_NAME);
  
    console.log('Sent cmd, waiting for resp...');
    const [pid, message] = rednet.receive(TURTLE_REGISTRY_PROTOCOL_NAME, 3);
    if (assertResponse && !pid) throw new Error("No response to command " + cmd);
    return message;
  }

  list(): TurtleRecord[] {
    return this.call(TurtleRegistryCommand.LIST);
  }

  registerSelf(): void {
    if (typeof turtle === 'undefined') {
      throw new Error('Can only register on a turtle');
    }

    if (!LocationMonitor.hasPosition) {
      console.log("Missing location, will retry registration");
      return;
    }

    console.log("Registering turtle...");

    const resp = this.call(TurtleRegistryCommand.REGISTER, {
      location: LocationMonitor.position,
      status: BehaviourStack.peek() ? TurtleStatus.BUSY : TurtleStatus.IDLE,
      currentBehaviour: BehaviourStack.peek()?.name || '',
    }, false);
    if (!resp?.ok) {
      // this could happen if the server crashes
      console.log("Turtle register failed, will retry:", textutils.serialize(resp));
      return;
    }

    if (resp.label) {
      os.setComputerLabel(resp.label);
    } else {
      // console.log("Did not receive label from registry");
    }

    console.log("Done registration");
  }
}
