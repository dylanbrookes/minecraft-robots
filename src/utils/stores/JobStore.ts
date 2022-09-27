import Logger from "../Logger";
import { JobType } from "../turtle/Consts";

export enum JobStatus {
  PENDING = 'PENDING',
  IN_PROGRESS = 'IN_PROGRESS',
  PAUSED = 'PAUSED',
  HALTED = 'HALTED',
  DONE = 'DONE',
  CANCELLED = 'CANCELLED',
  FAILED = 'FAILED',
}

export type JobRecord = {
  id: number,
  type: JobType,
  turtle_id?: number,
  args: any,
  resume_state?: string,
  resume_counter: number,
  error?: any,
  status: JobStatus,
  issuer_id: number, // host id which created the job
}

export class JobStore implements Iterable<JobRecord> {
  static DEFAULT_STORE_FILE = '/.jobstore';

  private maxId: number = -1;
  private jobs: Map<number, JobRecord>;

  constructor(private storeFile: string = JobStore.DEFAULT_STORE_FILE) {
    [this.jobs, this.maxId] = JobStore.LoadStoreFile(this.storeFile);
    Logger.info("N jobs:", this.jobs.size);
    Logger.info("Max ID:", this.maxId);
  }

  [Symbol.iterator](): IterableIterator<JobRecord> {
    return this.jobs.values();
  }
  select(filter: (v: JobRecord) => boolean = () => true): JobRecord[] {
    return [...this.jobs.values()].filter(filter);
  }

  // Returns jobs and the max job id
  private static LoadStoreFile(storeFile: string): [Map<number, JobRecord>, number] {
    const jobs = new Map<number, JobRecord>();
    let maxId = 0;

    if (!fs.exists(storeFile)) {
      Logger.debug("Starting without store file");
      return [jobs, maxId];
    }

    const [handle, err] = fs.open(storeFile, 'r');
    if (!handle) {
      throw new Error("Failed to open storeFile " + storeFile + " error: " + err);
    }

    let line: string | undefined;
    while (line = handle.readLine()) {
      const job = textutils.unserialize(line) as JobRecord;
      if (typeof job.id !== 'number') throw new Error("Invalid job parsed from: " + line);

      jobs.set(job.id, job);
      if (job.id > maxId) maxId = job.id;
    }

    return [jobs, maxId];
  }

  getById(id: number): JobRecord | undefined {
    return this.jobs.get(id);
  }

  removeById(id: number): boolean {
    return this.jobs.delete(id);
  }

  updateById(id: number, changes: Omit<Partial<JobRecord>, 'id'>): JobRecord | undefined {
    const job = this.jobs.get(id);
    if (!job) return undefined;

    Object.assign(job, changes);

    return job;
  }

  list() {
    Logger.info("Jobs:")
    for (const job of this.jobs.values()) {
      Logger.info(textutils.serializeJSON(job, true));
    }
  }

  add(jobRecord: Pick<JobRecord, 'type' | 'args'>) {
    const job: JobRecord = {
      id: ++this.maxId,
      resume_counter: 0,
      status: JobStatus.PENDING,
      error: undefined,
      resume_state: undefined,
      turtle_id: undefined,
      issuer_id: os.computerID(),
      ...jobRecord,
    };
    this.jobs.set(job.id, job);

    return job;
  }

  save() {
    if (fs.exists(this.storeFile)) {
      Logger.debug("Overwriting store file", this.storeFile);
    }

    const [handle, err] = fs.open(this.storeFile, 'w');
    if (!handle) {
      throw new Error("Failed to open storeFile " + this.storeFile + " for writing, error: " + err);
    }

    for (const job of this.jobs.values()) {
      handle.writeLine(textutils.serialize(job, { compact: true }));
    }
    handle.flush();
    handle.close();
    Logger.debug("Saved to storefile", this.storeFile);
  }

  toString(): string {
    const jobs = [];
    for (const job of this.jobs.values()) jobs.push(job);
    return textutils.serialize(jobs, { compact: true });
  }
}
