import { JobRecord } from "../../stores/JobStore";
import { TurtleRecord } from "../../stores/TurtleStore";
import { TurtleBehaviour } from "../behaviours/TurtleBehaviour";
import { JobType } from "../Consts";
import ClearJob from "./ClearJob";
import JobImpl from "./JobImpl";
import SpinJob from "./SpinJob";

const JOB_IMPL_TYPE_MAP: {
  [k in JobType]: JobImpl
} = {
  [JobType.spin]: SpinJob,
  [JobType.clear]: ClearJob,
}

/**
 * Encapsulates a job record
 */
export default class Job {
  readonly id: number;
  readonly type: JobType;
  private impl: JobImpl;

  constructor(readonly record: JobRecord) {
    this.id = record.id;
    this.type = record.type;
    this.impl = JOB_IMPL_TYPE_MAP[this.type];
  }

  /**
   * Returns a fitness score (higher is more fit) or false if the turtle is ineligible
   */
  turtleFitness(turtleRecord: TurtleRecord): number | false {
    if (this.impl.turtleFitness) {
      return this.impl.turtleFitness.call(this, turtleRecord);
    }
    
    return 0;
  }

  buildBehaviour(): TurtleBehaviour {
    return new this.impl.BehaviourConstructor(...this.record.args);
  }
}