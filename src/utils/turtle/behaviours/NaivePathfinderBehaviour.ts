import { Heading, HEADING_TO_XZ_VEC, LocationMonitor } from "../../LocationMonitor";
import { TurtlePosition } from "../Consts";
import { TurtleController } from "../TurtleController";
import { TurtleBehaviour, TurtleBehaviourBase } from "./TurtleBehaviour";

export class NaivePathfinderBehaviour extends TurtleBehaviourBase implements TurtleBehaviour {
  readonly name = 'pathfinding_naive';

  constructor(
    private targetPos: TurtlePosition,
    readonly priority = 1,
  ) {
    super();
  }
  

  step(): boolean | void {
    // lets just do a straight line up and over
    const currentPos = LocationMonitor.position;
    if (!currentPos) {
      console.log("Skipping pathfinding, current location status is", LocationMonitor.status);
      return;
    }

    const dx = this.targetPos[0] - currentPos[0];
    const dy = this.targetPos[1] - currentPos[1];
    const dz = this.targetPos[2] - currentPos[2];
    if (dy !== 0) {
      const n = Math.abs(dy);
      dy > 0
        ? TurtleController.up(n)
        : TurtleController.down(n)
    } else if (dx !== 0 || dz !== 0) {
      console.log("Gonna move forward");
      if (LocationMonitor.heading === Heading.UNKNOWN) {
        // Maybe this should be implemented as a heading finder behaviour
        // heading is required
        const success = TurtleController.forward(1, false);
        if (!success) TurtleController.turnLeft();
        return;
      }
      // prefer moving in same direction
      const [xx, zz] = HEADING_TO_XZ_VEC[LocationMonitor.heading];
      const xOk = xx * dx > 0;
      const zOk = zz * dz > 0;
      if (xOk) {
        // current heading is ok
        TurtleController.forward(Math.abs(dx));
      } else if (zOk) {
        TurtleController.forward(Math.abs(dz));
      } else {
        // rotate until the heading is ok
        // TODO: rotate smartly
        TurtleController.turnLeft();
      }
    } else {
      // we made it!
      return true;
    }
  }
}
