import { SpinBehaviour } from "../behaviours/SpinBehaviour";
import JobImpl from "./JobImpl";

const SpinJob = <JobImpl>{
  BehaviourConstructor: SpinBehaviour,
}

export default SpinJob;
