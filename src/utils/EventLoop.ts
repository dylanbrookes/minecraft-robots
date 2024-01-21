import Logger from "./Logger";

// eslint-disable-next-line @typescript-eslint/no-explicit-any
type EventCallback = (...ev: any[]) => boolean | void; // return true to be removed

type EventOptions = {
  /**
   * Needs to be true if the callback will require exclusive use of the event loop
   */
  async?: boolean,
}

type EventRecord = EventOptions & {
  cb: EventCallback,
  name: string,
};

class Routine {
  private static ID_COUNTER: number = 0;
  private co: LuaThread | void;
  readonly id: number;

  constructor(fn: (this: void) => void) {
    this.id = Routine.ID_COUNTER++;
    this.co = coroutine.create(fn);
    // console.log("Created routine", this.id);
    this.resume(); // run it to initialize
  }

  isDead(): boolean {
    if (!this.co) {
      return true;
    }
    return coroutine.status(this.co) === 'dead';
  }

  terminate() {
    if (this.co) {
      this.resume('terminate');
    }
  }

  /**
   * @returns true if the routine finished 
   */
  resume(event?: string, ...params: unknown[]): boolean | undefined {
    if (!this.co) throw new Error('Cannot resume a dead routine ' + this.id);
    const result = coroutine.resume(this.co, event, ...params);
    if (result[0] === false) {
      if (result[1] === "Terminated") {
        Logger.error(`Routine ${this.id} terminated`);
      } else {
        throw new Error(`Error in routine ${this.id}: ${textutils.serialize(result[1])}`);
      }
    }

    if (coroutine.status(this.co) === 'dead') {
      this.co = undefined;
      return true;
    }
  }
}

class __EventLoop__ {
  public tickTimeout = 0.01;

  private running: boolean = false;
  private reboot: boolean = false;
  private events: {
    [name: string]: EventRecord[];
  } = {};
  private routines = new Map<number, Routine>();

  on(name: string, cb: EventCallback, options: EventOptions = {}): () => boolean {
    if (!(name in this.events)) {
      this.events[name] = [];
    }

    this.events[name].push({
      cb,
      name,
      ...options,
    });

    return this.off.bind(this, name, cb);
  }

  // idk if this works
  off(name: string, cb: EventCallback): boolean {
    // Logger.info("Removing cb for", name);
    if (!(name in this.events)) return false;
    const idx = this.events[name].findIndex((ev) => ev.cb === cb);
    if (idx === -1) return false;
    this.events[name][idx].cb = () => true; // will be reaped on the next event emission
    return true;
  }

  emit(name: string, ...params: unknown[]) {
    if (!this.running) throw new Error("Cannot emit events before starting event loop");
    if (!(name in this.events)) return;

    const cbsLeft: EventRecord[] = [];
    // console.log("calling", startLen, name, "event cbs");
    for (const ev of this.events[name]) {
      const { cb, async } = ev;
      let remove = false;
      if (async) {
        /** ... oh no
         * During calls to other APIs (rednet, gps, etc) their code will take
         * control of the event loop, which destroys events that were queued by us :(
         * 
         * We need to fully empty the event queue, and then fill it back up??
         * what if we have timers that go off during the cb
         * I think we will need to:
         *  ~~1. Wait for all of our timers to complete~~
         *  1. queue an event "flush-complete"
         *  2. flush the current event queue until the event is received
         *    - the event queue is now "uncontrolled"
         *  3. "detach" all of our timers by swapping out the timerIds
         *  4. run the callback
         *  5. no this isn't going to work 😡
         *    - we may be waiting on other events (from a modem, redstone, user input),
         *      they will be destroyed by the callback's event loop too
         * 
         * Can we run these operations in a separate process?? That would be nice
         */
        // parallel.waitForAny(cb);
        // what if...
        // const remove = exclusive? parallel.waitForAny(() => cb(...params)) : cb(...params);

        /**
         * Okay maybe native lua coroutines? But how does the computer decide which coroutine gets the events?
         * OHHH you provide the events to the coroutine by calling resume! SICK
         * So what we need to do is:
         *  1. wrap the cb in a "promise" (coroutine?) - routine
         *  2. Add that promise to an internal array
         *  3. On each event pulled invoke resume on the promise until it completes
         */
        // maybe label routines with event ids here
        const routine = new Routine(() => cb(...params));
        if (routine.isDead()) {
          // console.log("Routine for event cb", name, "exited immediately");
          // remove = true;
        } else {
          // console.log("Routine for event cb", name, "did not exit immediately");
          this.routines.set(routine.id, routine);
        }
      } else {
        remove = !!cb(...params);
      }

      if (!remove) cbsLeft.push(ev);
      else {
        // console.log("REMOVED EVENT LISTENER", name);
      }
    }
    // if (this.events[name].length > startLen) {
    //   const newCbs = this.events[name].slice(startLen);
    //   console.log("Added", newCbs.length, "events that would have been missed", name);
    //   cbsLeft.push(...newCbs);
    // }
    this.events[name] = cbsLeft;
  }

  emitRepeat(name: string, interval: number, ...ev: unknown[]) {
    let evTimer = os.startTimer(interval);
    this.on('timer', (id: number) => {
      if (id !== evTimer) return false;

      this.emit(name, ...ev);
      evTimer = os.startTimer(interval);
      return false; // reuse this cb
    });
  }

  setTimeout(cb: () => void, interval: number = 0) {
    const evTimer = os.startTimer(interval);
    this.on('timer', (id: number) => {
      if (id !== evTimer) return false;
      cb();
      return true;
    });
  }

  run(tick?: (delta: number) => void) {
    if (this.running) throw new Error("Already running");

    this.running = true;

    // this.emitRepeat('_tick', this.tickTimeout);
    // do it this way to wait for async ticks to finish before starting the next
    os.queueEvent('_tick', 0);
    let lastTickTime = os.epoch('utc');
    this.on('_tick', (n: number) => {
      const now = os.epoch('utc');
      const delta = now - lastTickTime;
      lastTickTime = now;
      try {
        tick?.(delta);
      } catch (e) {
        Logger.error('Error in EventLoop tick:', e);
        throw e;
      }
      // might want to sleep here
      sleep(this.tickTimeout);
      os.queueEvent('_tick', n + 1);
      // this.setTimeout(() => {
      //   os.queueEvent('tick', n + 1);
      // }, this.tickTimeout);
    }, { async: true });

    while (this.running) {
      const [event, ...params] = os.pullEventRaw();
      if (!event) throw new Error("wtf why isn't there an event");
      if (event === 'terminate') {
        if (params[0] === 'reboot') {
          this.reboot = true;
          Logger.info('Reboot event received, rebooting in 1 second...');
        } else {
          Logger.info('Terminate event received, shutting down in 1 second...');
        }
        this.setTimeout(() => this.running = false, 1);
      }
      this.emit(event, ...params);

      // pass the event to routines
      for (const routine of this.routines.values()) {
        const finished = routine.resume(event, ...params);
        if (finished) {
          this.routines.delete(routine.id);
          // console.log("Routine", routine.id, "finished.");
        }
      }
    }

    if (this.reboot) {
      os.reboot();
    }
  }
}

export const EventLoop = new __EventLoop__();
