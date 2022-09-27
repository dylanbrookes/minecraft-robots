import { Heading, HEADING_ORDER, HEADING_TO_XZ_VEC, LocationMonitor } from "../../LocationMonitor";
import Logger from "../../Logger";
import { serializePosition, TurtlePosition } from "../Consts";
import { TurtleController } from "../TurtleController";
import { PathfinderBehaviour } from "./PathfinderBehaviour";
import { TurtleBehaviour, TurtleBehaviourBase, TurtleBehaviourStatus } from "./TurtleBehaviour";

function clearCol(breakForward: boolean, height: number, up: boolean = true) {
  for (let i = 0; i < height - 1; i++) {
    if (breakForward) TurtleController.dig(false);
    TurtleController[up ? 'digUp' : 'digDown'](false);
    TurtleController[up ? 'up' : 'down']();
  }
}

function breakAndMove() {
  TurtleController.dig(false);
  while (!TurtleController.forward(1, false)) {
    console.log("Could not move, waiting 5 seconds...");
    sleep(5);
  }
}

export class ClearBehaviour extends TurtleBehaviourBase implements TurtleBehaviour {
  readonly priority = 1;
  readonly name = 'clearing';
  private startPathfinder: PathfinderBehaviour;
  private pausedPosition: TurtlePosition | null = null;

  constructor(
    private startPosition: TurtlePosition,
    private startHeading: Heading,
    private dimensions: [w: number, d: number, h: number],
  ) {
    super();
    const [w, d, h] = dimensions;
    Logger.info(`Moving to ${serializePosition(startPosition)} and clearing w=${w} d=${d} h=${h}`);
    this.startPathfinder = new PathfinderBehaviour(startPosition);
  }

  onResume() {
    // recreate the pathfinder but start where it was paused
    this.startPathfinder = new PathfinderBehaviour(this.pausedPosition || this.startPosition);
  }

  onPause() {
    if (this.startPathfinder.status === TurtleBehaviourStatus.DONE) {
      // preserve position and heading
      this.pausedPosition = LocationMonitor.position;
      this.startHeading = LocationMonitor.heading;
    }
  }

  get w() { return this.dimensions[0]; }
  get d() { return this.dimensions[1]; }
  get h() { return this.dimensions[2]; }

  private x: number = 0;
  private y: number = 0;
  step(): boolean | void {
    if (this.startPathfinder.status !== TurtleBehaviourStatus.DONE) {
      if (this.startPathfinder.status === TurtleBehaviourStatus.INIT) this.startPathfinder.status = TurtleBehaviourStatus.RUNNING;
      const done = this.startPathfinder.step();
      if (done) {
        this.startPathfinder.status = TurtleBehaviourStatus.DONE;
        TurtleController.rotate(this.startHeading);
      }
      return;
    }

    if (this.x < this.w) {
      const lastRow = this.x + 1 === this.w; 
      Logger.info(`Clearing column ${this.x}, ${this.y}`);
      const lastCol = this.y + 1 === this.d;
      if (lastCol) {
        if (this.x % 2 === 0) {
          TurtleController.turnRight();
        } else {
          TurtleController.turnLeft();
        }
      }

      if ((this.x * this.d + this.y) % 2 === 0) {
        clearCol(!(lastCol && lastRow), this.h, ((this.x * this.d + this.y) >> 1) % 2 === 0);
      }

      if (!(lastCol && lastRow)) {
        breakAndMove();
      }
      this.y++;

      if (this.y === this.d) {
        if (!lastRow) {
          if (this.x % 2 === 0) {
            TurtleController.turnRight();
          } else {
            TurtleController.turnLeft();
          }
        }
        this.x++;
        this.y = 0;
      }
      return;
    }

    Logger.info("Done clearing")
    return true;
  }
}
