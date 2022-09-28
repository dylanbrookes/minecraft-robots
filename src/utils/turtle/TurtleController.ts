import { EventLoop } from "../EventLoop";
import { inspectHasTag, ItemTags } from "../ItemTags";
import { Heading, HEADING_ORDER, LocationMonitor, LocationMonitorStatus } from "../LocationMonitor";
import Logger from "../Logger";
import { TurtleEvent, TurtleReason } from "./Consts";

class __TurtleController__ {
  private checkActionResult(assertSuccess: boolean, [success, reason]: [boolean, string | null]): boolean {
    if (!success) {
      if (reason === TurtleReason.OUT_OF_FUEL) {
        EventLoop.emit(TurtleEvent.out_of_fuel);
      }
      if (assertSuccess) throw new Error('Failed to move, reason: ' + reason);
    }
    return success;
  }

  move(direction: "forward" | "back" | "up" | "down", n: number, assertSuccess: boolean = true): boolean {
    let success: boolean = false;
    let i: number;
    for (i = 0; i < n; i++) {
      success = this.checkActionResult(assertSuccess, turtle[direction]());
      if (!success) break;
      else {
        EventLoop.emit(TurtleEvent.moved, direction);
        EventLoop.emit(`moved:${direction}`, direction);
      }
    }
    return success;
  }

  turn(direction: "left" | "right", assertSuccess: boolean = true): boolean {
    const success = this.checkActionResult(
      assertSuccess,
      turtle[direction === 'left' ? 'turnLeft' : 'turnRight'](),
    );
    if (success) {
      EventLoop.emit(TurtleEvent.turned, direction);
      EventLoop.emit(`turned:${direction}`, direction);
    }
    return success;
  }

  private _dig(direction: 'forward' | 'up' | 'down', assertSuccess: boolean = true): boolean {
    const [occupied, info] = turtle[direction === 'forward' ? 'inspect' : (direction === 'up' ? 'inspectUp' : 'inspectDown')]();
    if (occupied && inspectHasTag(info, ItemTags.stella_arcanum)) {
      Logger.error('Dig target is stellar arcanum');
      return false;
    }

    const success = this.checkActionResult(
      assertSuccess,
      turtle[direction === 'forward' ? 'dig' : (direction === 'up' ? 'digUp' : 'digDown')](),
    );
    if (success) {
      EventLoop.emit(TurtleEvent.dig, direction);
      EventLoop.emit(`dig:${direction}`, direction);
    }
    return success;
  }

  private _place(direction: 'forward' | 'up' | 'down', assertSuccess: boolean = true): boolean {
    const success = this.checkActionResult(
      assertSuccess,
      turtle[direction === 'forward' ? 'place' : (direction === 'up' ? 'placeUp' : 'placeDown')](),
    );
    if (success) {
      EventLoop.emit(TurtleEvent.dig, direction);
      EventLoop.emit(`dig:${direction}`, direction);
    }
    return success;
  }

  forward(n: number | string = 1, assertSuccess: boolean = true): boolean {
    if (typeof n === 'string') n = parseInt(n);
    return this.move("forward", n, assertSuccess);
  }
  back(n: number | string = 1, assertSuccess: boolean = true): boolean {
    if (typeof n === 'string') n = parseInt(n);
    return this.move("back", n, assertSuccess);
  }
  up(n: number| string = 1, assertSuccess: boolean = true): boolean {
    if (typeof n === 'string') n = parseInt(n);
    return this.move("up", n, assertSuccess);
  }
  down(n: number | string = 1, assertSuccess: boolean = true): boolean {
    if (typeof n === 'string') n = parseInt(n);
    return this.move("down", n, assertSuccess);
  }

  turnLeft(assertSuccess: boolean = true): boolean {
    return this.turn("left", assertSuccess);
  }
  turnRight(assertSuccess: boolean = true): boolean {
    return this.turn("right", assertSuccess);
  }
  dig(assertSuccess: boolean = true): boolean {
    return this._dig('forward', assertSuccess);
  }
  digUp(assertSuccess: boolean = true): boolean {
    return this._dig('up', assertSuccess);
  }
  digDown(assertSuccess: boolean = true): boolean {
    return this._dig('down', assertSuccess);
  }
  place(assertSuccess: boolean = true): boolean {
    return this._place('forward', assertSuccess);
  }
  placeUp(assertSuccess: boolean = true): boolean {
    return this._place('up', assertSuccess);
  }
  placeDown(assertSuccess: boolean = true): boolean {
    return this._place('down', assertSuccess);
  }

  rotate(heading: Heading, assertSuccess: boolean = true): boolean {
    if (LocationMonitor.status !== LocationMonitorStatus.ACQUIRED) {
      if (assertSuccess) throw new Error(`Unable to rotate towards heading ${heading}, LocationMonitorStatus is ${LocationMonitor.status}`);
      return false;
    }
    if (LocationMonitor.heading === heading) return true;

    const currentHeadingIdx = HEADING_ORDER.indexOf(LocationMonitor.heading);
    const targetHeadingIdx = HEADING_ORDER.indexOf(heading);
    if ((currentHeadingIdx - 1 + HEADING_ORDER.length) % HEADING_ORDER.length === targetHeadingIdx) {
      return this.turnLeft(assertSuccess);
    } else if ((currentHeadingIdx + 1) % HEADING_ORDER.length === targetHeadingIdx) {
      return this.turnRight(assertSuccess);
    } else {
      return this.turnRight(assertSuccess) && this.turnRight(assertSuccess);
    }
  }
}

export const TurtleController = new __TurtleController__();
