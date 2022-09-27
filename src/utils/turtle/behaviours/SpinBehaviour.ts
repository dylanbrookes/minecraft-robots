import Logger from "../../Logger";
import { TurtleController } from "../TurtleController";
import { TurtleBehaviour, TurtleBehaviourBase } from "./TurtleBehaviour";

export class SpinBehaviour extends TurtleBehaviourBase implements TurtleBehaviour {
  readonly priority = 1;
  readonly name = 'spinning';

  constructor(
    private duration = 5,
  ) {
    super();
    Logger.info(`Spinning for ${this.duration} seconds`);
  }
  
  private endTime: number = 0;
  onStart() {
    this.endTime = os.epoch('utc') + this.duration * 1000;
    // Logger.info("End time:", this.endTime, os.epoch('utc'));
  }

  step(): boolean | void {
    if (os.epoch('utc') > this.endTime) return true;
    // Logger.info('Spinning...', this.endTime - os.epoch('utc'));
    TurtleController.turnLeft();
  }
}
