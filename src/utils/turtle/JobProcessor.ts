import { JobRegistryClient } from "../clients/JobRegistryClient";
import { EventLoop } from "../EventLoop";
import Logger from "../Logger";
import { JobRecord } from "../stores/JobStore";
import { JobBehaviour } from "./behaviours/JobBehaviour";
import { BehaviourStack } from "./BehaviourStack";
import { JobEvent } from "./Consts";
import Job from "./jobs/Job";

class __JobProcessor__ {
  private jobs = new Map<number, Job>();
  private activeJobBehaviour: JobBehaviour | null = null;

  /**
   * Creates JobBehaviours for jobs to be added to the BehaviourStack.
   */
  private checkWork() {
    if (this.activeJobBehaviour) return; // a job is already being executed

    const job = this.jobs.values().next().value as Job | void;
    if (!job) return; // no jobs

    const offFns = [
      EventLoop.on(JobEvent.start(job.id), () => this.onJobStart(job.id)),
      EventLoop.on(JobEvent.pause(job.id), () => this.onJobPause(job.id)),
      EventLoop.on(JobEvent.resume(job.id), () => this.onJobResume(job.id)),
      EventLoop.on(JobEvent.end(job.id), () => {
        this.onJobEnd(job.id);
        offFns.forEach(off => {
          if (!off()) {
            throw new Error('Failed to remove job event callback');
          }
        });
      }, { async: true }),
    ];

    BehaviourStack.push(new JobBehaviour(job));
  }

  add(jobRecord: JobRecord) {
    if (this.jobs.has(jobRecord.id)) {
      throw new Error(`Job ${jobRecord.id} already exists`);
    }

    this.jobs.set(jobRecord.id, new Job(jobRecord));

    this.checkWork();
  }

  private onJobStart(id: number) {
    Logger.info('Job started', id);
  }

  private onJobEnd(id: number) {
    Logger.info('Job ended', id);
    const job = this.jobs.get(id);
    if (!job) throw new Error(`Missing job ${id}`);
    this.activeJobBehaviour = null;
    this.jobs.delete(id);
    this.checkWork();
    const jobRegistryClient = new JobRegistryClient(job.record.issuer_id);
    try {
      jobRegistryClient.jobDone(job.id);
    } catch (e) {
      Logger.error(`Failed to report job ${id} done`, e);
    }
  }

  private onJobPause(id: number) {
    Logger.info('Job paused', id);
  }

  private onJobResume(id: number) {
    Logger.info('Job resumed', id);
  }
}

const JobProcessor = new __JobProcessor__();
export default JobProcessor;
