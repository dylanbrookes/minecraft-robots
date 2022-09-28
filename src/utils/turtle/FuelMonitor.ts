import { EventLoop } from "../EventLoop";
import Logger from "../Logger";
import { TurtleEvent } from "./Consts";

export enum FuelStatus {
  UNKNOWN = 'UNKNOWN',
  OK = 'OK',
  LOW = 'LOW',
  EMPTY = 'EMPTY',
  UNLIMITED = 'UNLIMITED',
}

class __FuelMonitor__ {
  private static CHECK_FUEL_INTERVAL = 10; // seconds
  private static MIN_FUEL_RATIO = 0.2;

  private registered = false;
  private _fuelStatus: FuelStatus = FuelStatus.UNKNOWN;

  get fuelStatus(): FuelStatus {
    return this._fuelStatus;
  }

  register() {
    if (this.registered) throw new Error("FuelMonitor is already registered");
    this.registered = true;

    EventLoop.emitRepeat(TurtleEvent.check_fuel, __FuelMonitor__.CHECK_FUEL_INTERVAL);
    EventLoop.on(TurtleEvent.check_fuel, () => {
      this.checkFuel();
      return false;
    }, { async: true });

    // check after startup
    EventLoop.setTimeout(() => EventLoop.emit(TurtleEvent.check_fuel));
  }

  checkFuel(): FuelStatus {
    Logger.debug("Check fuel called");
    const fuelLevel = turtle.getFuelLevel();
    const fuelLimit = turtle.getFuelLimit();
    if (fuelLevel === 'unlimited' || fuelLimit === 'unlimited') {
      this._fuelStatus = FuelStatus.UNLIMITED;
    } else if (fuelLevel / fuelLimit < __FuelMonitor__.MIN_FUEL_RATIO) {
      if ([FuelStatus.UNKNOWN, FuelStatus.OK].includes(this._fuelStatus)) {
        EventLoop.emit(TurtleEvent.low_fuel);
      }
      const nextFuelStatus = fuelLevel === 0? FuelStatus.EMPTY : FuelStatus.LOW;
      if (nextFuelStatus === FuelStatus.EMPTY && this._fuelStatus !== FuelStatus.EMPTY) {
        EventLoop.emit(TurtleEvent.out_of_fuel);
      }
      this._fuelStatus = nextFuelStatus;
    } else {
      Logger.debug("Fuel OK, level:", fuelLevel, "limit:", fuelLimit, "ratio:", (fuelLevel / fuelLimit * 100), "%", "target:", __FuelMonitor__.MIN_FUEL_RATIO);
      this._fuelStatus = FuelStatus.OK;
    }

    return this.fuelStatus;
  }
}

const FuelMonitor = new __FuelMonitor__();
export default FuelMonitor;
