export enum JobStatus {
  PENDING = 'PENDING',
  IN_PROGRESS = 'IN_PROGRESS',
  PAUSED = 'PAUSED',
  HALTED = 'HALTED',
  DONE = 'DONE',
  CANCELLED = 'CANCELLED',
}

export type JobRecord = {
  id: number,
  type: string,
  turtle_id?: Number,
  params: string,
  resume_state?: string,
  resume_counter: number,
  error?: string,
  status: JobStatus,
}

export class JobStore {
  static DEFAULT_STORE_FILE = '/.jobstore';

  private maxId: number = -1;
  private jobs: Map<number, JobRecord>;

  constructor(private storeFile: string = JobStore.DEFAULT_STORE_FILE) {
    [this.jobs, this.maxId] = JobStore.LoadStoreFile(this.storeFile);
    console.log("N jobs:", this.jobs.size);
    console.log("Max ID:", this.maxId);
  }

  // Returns jobs and the max job id
  private static LoadStoreFile(storeFile: string): [Map<number, JobRecord>, number] {
    const jobs = new Map<number, JobRecord>();
    let maxId = 0;

    if (!fs.exists(storeFile)) {
      console.log("Starting without store file");
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

  updateById(id: number, changes: Partial<JobRecord>): JobRecord | undefined {
    const job = this.jobs.get(id);
    if (!job) return undefined;

    const newJob = {
      ...job,
      ...changes,
    };
    this.jobs.set(id, newJob);

    return newJob;
  }

  list() {
    console.log("Jobs:")
    for (const job of this.jobs.values()) {
      console.log(textutils.serializeJSON(job, true));
    }
  }

  add() {
    const job: JobRecord = {
      id: ++this.maxId,
      params: '',
      resume_counter: 0,
      status: JobStatus.PENDING,
      type: 'job_type',
      error: undefined,
      resume_state: undefined,
      turtle_id: undefined,
    };
    this.jobs.set(job.id, job);

    return job;
  }

  save() {
    if (fs.exists(this.storeFile)) {
      console.log("Overwriting store file", this.storeFile);
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
    console.log("Saved to storefile", this.storeFile);
  }

  toString(): string {
    const jobs = [];
    for (const job of this.jobs.values()) jobs.push(job);
    return textutils.serialize(jobs, { compact: true });
  }
}
