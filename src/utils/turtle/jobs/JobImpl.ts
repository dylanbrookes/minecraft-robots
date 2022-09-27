import { TurtleRecord } from "../../stores/TurtleStore";
import { TurtleBehaviourConstructor } from "../behaviours/TurtleBehaviour";
import Job from "./Job";

export default interface JobImpl {
  readonly BehaviourConstructor: TurtleBehaviourConstructor;
  turtleFitness?(this: Job, turtleRecord: TurtleRecord): number | false;
}
