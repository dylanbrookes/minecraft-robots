import { TurtleClient } from "./clients/TurtleClient";
import { JobRegistryEvent, TurtleControlEvent } from "./Consts";
import { EventLoop } from "./EventLoop";
import Logger from "./Logger";
import { JobStatus, JobStore } from "./stores/JobStore";
import TurtleStore, { TurtleRecord, TurtleStatus } from "./stores/TurtleStore";
import Job from "./turtle/jobs/Job";

export default class JobScheduler {
  private static SCHEDULE_JOBS_EVENT = 'JobScheduler:schedule_jobs';
  private static SCHEDULE_JOBS_INTERVAL = 5;
  private registered = false;
  constructor(private jobStore: JobStore, private turtleStore: TurtleStore) {}

  register() {
    if (this.registered) throw new Error("JobScheduler is already registered");
    this.registered = true;

    Logger.info("Registering Job Scheduler");
    EventLoop.on(JobScheduler.SCHEDULE_JOBS_EVENT, () => this.scheduleJobs(), { async: true });
    EventLoop.emitRepeat(JobScheduler.SCHEDULE_JOBS_EVENT, JobScheduler.SCHEDULE_JOBS_INTERVAL);
    EventLoop.setTimeout(() => EventLoop.emit(JobScheduler.SCHEDULE_JOBS_EVENT));

    EventLoop.on(JobRegistryEvent.JOB_DONE, () => this.scheduleJobs(), { async: true });
    EventLoop.on(JobRegistryEvent.JOB_FAILED, () => this.scheduleJobs(), { async: true });
    EventLoop.on(JobRegistryEvent.JOB_CANCELLED, (id) => {
      this.onJobCancelled(id);
      this.scheduleJobs();
    }, { async: true });
    EventLoop.on(TurtleControlEvent.TURTLE_IDLE, () => this.scheduleJobs(), { async: true });
    EventLoop.on(TurtleControlEvent.TURTLE_OFFLINE, (id: number) => this.onTurtleOffline(id));
  }

  private onJobCancelled(jobId: number) {
    const jobRecord = this.jobStore.getById(jobId);
    if (!jobRecord) {
      Logger.error("Unknown job", jobId);
      return;
    }

    if (jobRecord.turtle_id) {
      // notify the turtle that they can stop
      const turtleClient = new TurtleClient(jobRecord.turtle_id);
      turtleClient.cancelJob(jobRecord.id);
    }
  }

  private onTurtleOffline(id: number) {
    const assignedJobs = this.jobStore.select(({ status, turtle_id }) => status === JobStatus.IN_PROGRESS && turtle_id === id);
    for (const job of assignedJobs) {
      Logger.info(`Releasing job ${job.id} to be retried`);
      this.jobStore.updateById(job.id, { status: JobStatus.HALTED });
    }
    if (assignedJobs.length > 0) {
      this.jobStore.save();
    }
  }

  private schedulingInProgress = false;
  private scheduleJobs() {
    if (this.schedulingInProgress) {
      Logger.debug("Skipping job scheduling, already in progress");
      return;
    }
    this.schedulingInProgress = true;

    const assignedTurtleIds = new Set(this.jobStore.select(({ status }) => status === JobStatus.IN_PROGRESS)
      .map(({ turtle_id }) => turtle_id)
      .filter((id): id is number => id !== undefined));
    let availableTurtles = this.turtleStore
      .select(({ id, status }) => status === TurtleStatus.IDLE && !assignedTurtleIds.has(id));
    if (availableTurtles.length === 0) {
      Logger.info("All idle turtles are assigned a job");
      this.schedulingInProgress = false;
      return;
    } 

    for (const job of this.jobStore
      .select(({ status }) => [JobStatus.PENDING, JobStatus.HALTED].includes(status))
      .map(jobRecord => new Job(jobRecord))) {
      
      let turtleFitnesses: [TurtleRecord, number][] | undefined = undefined;
      try {
        turtleFitnesses = availableTurtles
          .map<[TurtleRecord, number | false]>((turtleRecord) => [turtleRecord, job.turtleFitness(turtleRecord)])
          .filter((v): v is [TurtleRecord, number] => v[1] !== false)
          .sort((a, b) => b[1] - a[1]);
      } catch (error) {
        Logger.error(`Error while evaluating fitness for job ${job.id} (${job.type}):`, error);
        this.jobStore.updateById(job.id, {
          status: JobStatus.FAILED,
          error,
        });
        this.jobStore.save();
      }

      if (turtleFitnesses) {
        if (turtleFitnesses.length === 0) {
          Logger.warn(`No available turtles can perform job ${job.record.type} [${job.id}]`);
        } else {
          for (const [turtle] of turtleFitnesses) {
            const success = this.assignJobToTurtle(job, turtle);
            if (success) {
              assert(job.record.status === JobStatus.IN_PROGRESS); // sanity check that the object gets mutated when the store is updated
              availableTurtles = availableTurtles.filter(({ id }) => id !== turtle.id); // remove from available turtles
              break;
            }
          }
          if (availableTurtles.length === 0) break;
        }
      }
    }

    const pendingJobs =  this.jobStore
      .select(({ status }) => status === JobStatus.PENDING);
    if (pendingJobs.length > 0) {
      Logger.info(`Pending jobs: ${pendingJobs.length}`);
    }
    this.schedulingInProgress = false;
  }

  /**
   * @returns success
   */
  assignJobToTurtle(job: Job, turtleRecord: TurtleRecord): boolean {
    Logger.info(`Assigning job ${job.record.type} [${job.id}] to turtle ${turtleRecord.label} [${turtleRecord.id}]`);
    const turtleClient = new TurtleClient(turtleRecord.id);
    try {
      turtleClient.addJob(job.record);
    } catch (e) {
      Logger.error('Failed to assign job to turtle', e);
      return false;
    }

    this.jobStore.updateById(job.id, {
      turtle_id: turtleRecord.id,
      status: JobStatus.IN_PROGRESS,
    });
    this.jobStore.save();
    return true;
  }
}
