import { ClearBehaviour } from "../behaviours/ClearBehaviour";
import { cartesianDistance } from "../Consts";
import JobImpl from "./JobImpl";

const ClearJob = <JobImpl>{
  BehaviourConstructor: ClearBehaviour,
  turtleFitness(turtleRecord) {
    // todo: filter for only mining turtles
    if (!turtleRecord.location) return 0;

    const [startPosition] = this.record.args as ConstructorParameters<typeof ClearBehaviour>;
    return 1 / cartesianDistance(startPosition, turtleRecord.location); // nearest will have higher fitness
  },
}

export default ClearJob;
