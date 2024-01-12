import Logger from "../../Logger";
import FuelMonitor, { FuelStatus } from "../FuelMonitor";
import { createInvSpace } from "../routines/createInvSpace";
import { refuel } from "../routines/refuel";
import { ResupplyBehaviour } from "./ResupplyBehaviour";
import { TurtleBehaviour, TurtleBehaviourBase } from "./TurtleBehaviour";

export class RefuelBehaviour extends TurtleBehaviourBase implements TurtleBehaviour {
  readonly name = 'refueling';
  readonly priority: number = 10000;
  private static RESCAN_STEP_INTERVAL = 20 * 10; // every 10s?

  private resupplyBehaviour = new ResupplyBehaviour(['fuel']);

  private stepn = 0;
  step(): boolean | void {
    if (FuelMonitor.fuelStatus === FuelStatus.OK) {
      // some other process refuelled?
      Logger.info("Cancelled refuel behaviour, fuel status is OK");
      return true;
    }

    // only try to resupply when the status is LOW not EMPTY, can't do anything when EMPTY
    if (this.stepn % RefuelBehaviour.RESCAN_STEP_INTERVAL === 0
      || (FuelMonitor.fuelStatus === FuelStatus.LOW && this.resupplyBehaviour.step())) {
      Logger.info("Trying to refuel");
      const refuelled = refuel();
      if (refuelled) {
        Logger.info("Refuel success");
        return FuelMonitor.checkFuel() === FuelStatus.OK;
      }
    }

    if (this.stepn === 0) {
      // create some inventory space to pick up fuel with
      createInvSpace(); // will drop something if full
    }

    this.stepn++;
  }
}
