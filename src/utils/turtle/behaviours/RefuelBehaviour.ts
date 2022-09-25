import { TurtlePosition } from "../Consts";
import { NaivePathfinderBehaviour } from "./NaivePathfinderBehaviour";
import { TurtleBehaviour } from "./TurtleBehaviour";

export class RefuelBehaviour implements TurtleBehaviour {
  readonly name = 'refueling';
  readonly priority: number = 10000;

  step(): boolean | void {
    // locate the nearest resource station w fuel
    //  - broadcast a lookup for fuel resources?
    const targetPos: TurtlePosition = [0,0,0];
    // pathfind to it
    const arrived = (new NaivePathfinderBehaviour(targetPos)).step();
    if (arrived) {
      // take fuel
      // refuel
      return true;
    }
  }
}
