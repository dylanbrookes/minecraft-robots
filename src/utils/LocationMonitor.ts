import { EventLoop } from "./EventLoop";
import Logger from "./Logger";
import { TurtleEvent, TurtlePosition } from "./turtle/Consts";

export enum LocationMonitorStatus {
  UNKNOWN = 'UNKNOWN',
  POS_ONLY = 'POS_ONLY', // when heading is missing
  ACQUIRED = 'ACQUIRED',
  ERROR = 'ERROR',
}

export enum Heading {
  UNKNOWN,
  SYNCING,
  NORTH,
  SOUTH,
  EAST,
  WEST,
}

// clockwise
export const HEADING_ORDER = [
  Heading.NORTH,
  Heading.EAST,
  Heading.SOUTH,
  Heading.WEST,
];

export const HEADING_TO_XZ_VEC = {
  [Heading.UNKNOWN]: [0, 0],
  [Heading.SYNCING]: [0, 0],
  [Heading.NORTH]: [0, -1],
  [Heading.SOUTH]: [0, 1],
  [Heading.EAST]: [1, 0],
  [Heading.WEST]: [-1, 0],
}

const RELEVANT_EVENTS: TurtleEvent[] = [
  TurtleEvent.moved_forward,
  TurtleEvent.moved_back,
  TurtleEvent.moved_up,
  TurtleEvent.moved_down,
  TurtleEvent.turned_left,
  TurtleEvent.turned_right,
];

class __LocationMonitor__ {
  private _status: LocationMonitorStatus = LocationMonitorStatus.UNKNOWN;
  private _heading: Heading = Heading.UNKNOWN;
  private pos: TurtlePosition = [0, 0, 0];
  private registered: boolean = false;

  get status(): LocationMonitorStatus {
    return this._status;
  }

  get position(): TurtlePosition | null {
    if (!this.hasPosition) {
      return null;
    }
    return [...this.pos]; // clone because we mutate internally
  }

  get heading(): Heading {
    return this._heading;
  }

  get hasPosition(): boolean {
    return [LocationMonitorStatus.ACQUIRED, LocationMonitorStatus.POS_ONLY].includes(this._status);
  }

  register() {
    if (this.registered) throw new Error("LocationMonitor is already registered");
    this.registered = true;

    Logger.info("Registering Location Monitor");
    for (const event of RELEVANT_EVENTS) {
      EventLoop.on(event, () => this.onMove(event));
    }

    EventLoop.on('check_position', () => this.checkPosition(), { async: true });
    EventLoop.emitRepeat('check_position', 10);
    EventLoop.setTimeout(() => EventLoop.emit('check_position'));
  }

  /**
   * Compare local position to gps position.
   * Must be performed inside of an async event handler because
   * the gps.locate call needs an exclusive event loop.
   */
  private checkPosition() {
    if (this._status === LocationMonitorStatus.UNKNOWN) {
      Logger.info("Retrieving location...");
      const pos = gps.locate(3);
      if (!pos || pos[0] === null) {
        Logger.warn("Failed to retrieve location");
        this._status = LocationMonitorStatus.ERROR;
      } else {
        Logger.info("Retrieved location:", ...pos);
        this.pos = pos;
        this._status = LocationMonitorStatus.POS_ONLY; // heading is still required
      }
      return;
    } else if (!([LocationMonitorStatus.POS_ONLY, LocationMonitorStatus.ACQUIRED].includes(this._status))) {
      Logger.debug("Skipping gps check, status is", this._status);
      return;
    }

    Logger.debug("Checking gps position...");
    const pos = gps.locate(3);
    if (!pos || pos[0] === null) {
      Logger.error("Could not retrieve gps position for check");
      return;
    }

    if (this._heading === Heading.SYNCING) {
      const oldPos = this.pos;
      // now figure out the heading
      const dx = pos[0] - oldPos[0];
      const dy = pos[1] - oldPos[1];
      const dz = pos[2] - oldPos[2];

      const diff = Math.abs(dx) + Math.abs(dy) + Math.abs(dz);
      if (diff === 1) {
        if (dy !== 0) throw new Error("how tf this happed");
        else if (dx !== 0) this._heading = dx === 1 ? Heading.EAST : Heading.WEST;
        else if (dz !== 0) this._heading = dz === 1 ? Heading.SOUTH : Heading.NORTH;
        else throw new Error("okay wtf 3979827590");

        this.pos = pos;
        this._status = LocationMonitorStatus.ACQUIRED;
        Logger.debug("acquired location and heading");
        Logger.debug("location:", ...this.pos);
        Logger.debug("heading:", this._heading);
      } else {
        Logger.warn("Could not determine heading, pos diff is not 1 (maybe we moved backwards? I didn't implement heading calculation for that 🙂):");
        Logger.debug("oldPos:", ...oldPos);
        Logger.debug("pos:", ...pos);
        this._heading = Heading.UNKNOWN;
        this.pos = pos;
      }
    }

    if (pos[0] !== this.pos[0]
      || pos[1] !== this.pos[1]
      || pos[2] !== this.pos[2]) {
      Logger.warn("GPS POSITION MISMATCH, will update");
      Logger.warn("Our position:", ...this.pos);
      Logger.warn("GPS pos:", ...pos);
      this.pos = pos;
    }
  }

  private onMoveForwardOrBack(forward: boolean) {
    const delta = forward ? 1 : -1;
    switch (this._heading) {
      case Heading.NORTH:
        this.pos[2] -= delta; // -z
        break;
      case Heading.SOUTH:
        this.pos[2] += delta; // +z
        break;
      case Heading.EAST:
        this.pos[0] += delta; // +x
        break;
      case Heading.WEST:
        this.pos[0] -= delta; // -x
        break;
    }
    // console.log(`position updated (forward? ${forward}):`, ...this.pos); 
  }

  onMove(eventName: TurtleEvent) {
    if (this._status === LocationMonitorStatus.UNKNOWN) {
      return; // Can't do nothin
    }

    switch (eventName) {
      case TurtleEvent.moved_forward:
        if (this._status === LocationMonitorStatus.POS_ONLY
          && this._heading === Heading.UNKNOWN) {
          // now that we've moved, we can figure out the heading
          this._heading = Heading.SYNCING;
          EventLoop.emit('check_position');
        } else {
          this.onMoveForwardOrBack(true);
        }
        break;
      case TurtleEvent.moved_back:
        if (this._status !== LocationMonitorStatus.ACQUIRED) break;
        this.onMoveForwardOrBack(false);
        break;
      case TurtleEvent.moved_up:
        this.pos[1] += 1;
        break;
      case TurtleEvent.moved_down:
        this.pos[1] -= 1;
        break;
      case TurtleEvent.turned_left:
        if (this._heading === Heading.UNKNOWN) break;
        // counterclockwise
        this._heading = HEADING_ORDER[(HEADING_ORDER.indexOf(this._heading) + HEADING_ORDER.length - 1) % HEADING_ORDER.length];
        break;
      case TurtleEvent.turned_right:
        if (this._heading === Heading.UNKNOWN) break;
        // clockwise
        this._heading = HEADING_ORDER[(HEADING_ORDER.indexOf(this._heading) + 1) % HEADING_ORDER.length];
        break;
      default:
        // we can ignore
    }
  }
}

export const LocationMonitor = new __LocationMonitor__();
