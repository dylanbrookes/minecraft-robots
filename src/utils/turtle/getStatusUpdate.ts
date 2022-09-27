import { LocationMonitor } from "../LocationMonitor";
import { TurtleStatus, TurtleStatusUpdate } from "../stores/TurtleStore";
import { BehaviourStack } from "./BehaviourStack";

export default function getStatusUpdate(): TurtleStatusUpdate {
  return {
    location: LocationMonitor.position || undefined,
    status: BehaviourStack.peek() ? TurtleStatus.BUSY : TurtleStatus.IDLE,
    currentBehaviour: BehaviourStack.peek()?.name || '',
  }
}
