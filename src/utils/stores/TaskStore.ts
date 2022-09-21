
export enum TaskStatus {
  TODO = 'TODO',
  IN_PROGRESS = 'IN_PROGRESS',
  DONE = 'DONE',
}

export type TaskRecord = {
  id: number,
  description: string,
  status: TaskStatus,
}

// Keeps track of turtle statuses
// TODO: Not very DRY a lot of logic copied from JobStore
export default class TaskStore {
  static DEFAULT_STORE_FILE = '/.tasks';

  private nextTaskId: number;
  private tasks: Map<number, TaskRecord>;

  constructor(private storeFile: string = TaskStore.DEFAULT_STORE_FILE) {
    const { nextTaskId, tasks } = TaskStore.LoadStoreFile(storeFile);
    this.nextTaskId = nextTaskId;
    this.tasks = tasks;
    console.log("TaskStore loaded with", this.tasks.size, "tasks");
  }

  private static LoadStoreFile(storeFile: string): {
    nextTaskId: number,
    tasks: Map<number, TaskRecord>,
  } {
    const tasks = new Map<number, TaskRecord>();

    if (!fs.exists(storeFile)) {
      console.log("Creating new task store file");
      return {
        nextTaskId: 1,
        tasks,
      };
    }

    const [handle, err] = fs.open(storeFile, 'r');
    if (!handle) {
      throw new Error("Failed to open storeFile " + storeFile + " error: " + err);
    }

    const firstLine = handle.readLine();
    const nextTaskId = firstLine && parseInt(firstLine);
    if (!nextTaskId) {
      throw new Error('Missing nextTaskId');
    }
    
    let line: string | undefined;
    while (line = handle.readLine()) {
      const task = textutils.unserialize(line) as TaskRecord;
      if (typeof task.id !== 'number') throw new Error("Invalid turtle parsed from: " + line);

      tasks.set(task.id, task);
    }

    return {
      nextTaskId,
      tasks,
    };
  }

  save() {
    if (fs.exists(this.storeFile)) {
      console.log("Overwriting store file", this.storeFile);
    }

    const [handle, err] = fs.open(this.storeFile, 'w');
    if (!handle) {
      throw new Error("Failed to open storeFile " + this.storeFile + " for writing, error: " + err);
    }

    handle.writeLine(textutils.serialize(this.nextTaskId));
    for (const task of this.tasks.values()) {
      handle.writeLine(textutils.serialize(task, { compact: true }));
    }
    handle.flush();
    handle.close();
    console.log("Saved to storefile", this.storeFile);
  }

  toString(): string {
    const tasks = [];
    for (const task of this.tasks.values()) tasks.push(task);
    return textutils.serialize(tasks, { compact: true });
  }

  exists(id: number): boolean {
    return this.tasks.has(id);
  }

  get(id: number): TaskRecord | undefined {
    return this.tasks.get(id);
  }

  getAll(): TaskRecord[] {
    return [...this.tasks.values()];
  }

  count(): number {
    return this.tasks.size;
  }

  add(record: Omit<TaskRecord, 'id'>): void {
    const id = this.nextTaskId++;
    this.tasks.set(id, Object.assign({ id }, record));
  }

  update(id: number, record: Partial<Omit<TaskRecord, 'id'>>): TaskRecord {
    const og = this.tasks.get(id);
    if (!og) {
      throw new Error(`Can't update: TaskRecord doesn't exist for id ${id}`);
    }

    const newRecord = {
      ...og,
      ...record,
    };
    this.tasks.set(id, newRecord);
    return newRecord;
  }
}
