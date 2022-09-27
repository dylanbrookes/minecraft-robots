import { EventLoop } from "../../EventLoop";
import Logger from "../../Logger";
import { JobEvent } from "../Consts";
import Job from "../jobs/Job";
import { TurtleBehaviour, TurtleBehaviourBase } from "./TurtleBehaviour";

export class JobBehaviour extends TurtleBehaviourBase implements TurtleBehaviour {
  readonly name: string;

  private behaviour: TurtleBehaviour;

  constructor(
    private job: Job,
    readonly priority = 1,
  ) {
    super();
    this.name = `job:${this.job.type} [${this.job.id}]`;
    this.behaviour = this.job.buildBehaviour();
    Logger.info(`Created job behaviour ${this.behaviour.name}`);
  }

  step(): boolean | void {
    // Logger.info(`Working on job ${this.job.id}...`);
    return this.behaviour.step();
  }
  onStart(): void {
    this.behaviour.onStart?.();
    EventLoop.emit(JobEvent.start(this.job.id));
  }
  onResume(): void {
    this.behaviour.onResume?.();
    EventLoop.emit(JobEvent.resume(this.job.id));
  }
  onPause() {
    this.behaviour.onPause?.();
    EventLoop.emit(JobEvent.pause(this.job.id));
  }
  onEnd(): void {
    this.behaviour.onEnd?.();
    EventLoop.emit(JobEvent.end(this.job.id));
  }
}
