import { TurtlePosition } from "../LocationMonitor";

export enum TurtleStatus {
  OFFLINE = 'OFFLINE',
  IDLE = 'IDLE',
  BUSY = 'BUSY',
}

export type TurtleRecord = {
  id: number, // the actual computer ID
  label: string,
  status: TurtleStatus,
  currentBehaviour?: string,
  location?: TurtlePosition,
  registeredAt: number, // epoch
  lastSeen: number,
}

// Keeps track of turtle statuses
// TODO: Not very DRY a lot of logic copied from JobStore
export default class TurtleStore {
  static DEFAULT_STORE_FILE = '/.turtlestore';

  private turtles: Map<number, TurtleRecord>;

  constructor(private storeFile: string = TurtleStore.DEFAULT_STORE_FILE) {
    this.turtles = TurtleStore.LoadStoreFile(storeFile);
    console.log("TurtleStore loaded with", this.turtles.size, "turtles");
  }

  private static LoadStoreFile(storeFile: string): Map<number, TurtleRecord> {
    const turtles = new Map<number, TurtleRecord>();

    if (!fs.exists(storeFile)) {
      console.log("Starting without turtle store file");
      return turtles;
    }

    const [handle, err] = fs.open(storeFile, 'r');
    if (!handle) {
      throw new Error("Failed to open storeFile " + storeFile + " error: " + err);
    }

    let line: string | undefined;
    while (line = handle.readLine()) {
      const turtle = textutils.unserialize(line) as TurtleRecord;
      if (typeof turtle.id !== 'number') throw new Error("Invalid turtle parsed from: " + line);
      turtle.status = TurtleStatus.OFFLINE;

      turtles.set(turtle.id, turtle);
    }

    return turtles;
  }

  save() {
    if (fs.exists(this.storeFile)) {
      console.log("Overwriting store file", this.storeFile);
    }

    const [handle, err] = fs.open(this.storeFile, 'w');
    if (!handle) {
      throw new Error("Failed to open storeFile " + this.storeFile + " for writing, error: " + err);
    }

    for (const job of this.turtles.values()) {
      handle.writeLine(textutils.serialize(job, { compact: true }));
    }
    handle.flush();
    handle.close();
    console.log("Saved to storefile", this.storeFile);
  }

  toString(): string {
    const jobs = [];
    for (const job of this.turtles.values()) jobs.push(job);
    return textutils.serialize(jobs, { compact: true });
  }

  exists(id: number): boolean {
    return this.turtles.has(id);
  }

  get(id: number): TurtleRecord | undefined {
    return this.turtles.get(id);
  }

  getAll(): TurtleRecord[] {
    return [...this.turtles.values()];
  }

  count(): number {
    return this.turtles.size;
  }

  add(record: TurtleRecord): void {
    if (this.exists(record.id)) {
      throw new Error(`TurtleRecord already exists for id ${record.id}`);
    }

    this.turtles.set(record.id, record);
  }

  update(id: number, record: Partial<TurtleRecord>): TurtleRecord {
    const og = this.turtles.get(id);
    if (!og) {
      throw new Error(`Can't update: TurtleRecord doesn't exist for id ${id}`);
    }

    const newRecord = {
      ...og,
      ...record,
    };
    this.turtles.set(id, newRecord);
    return newRecord;
  }
}
