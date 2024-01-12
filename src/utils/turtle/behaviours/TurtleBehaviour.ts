
export enum TurtleBehaviourStatus {
  INIT = 'INIT',
  RUNNING = 'RUNNING',
  PAUSED = 'PAUSED',
  DONE = 'DONE',
  FAILED = 'FAILED',
}

export interface TurtleBehaviour {

  /**
   * Used to prioritize behaviours.
   * Can also be a getter
   */
  readonly priority: number;
  /**
   * Sent in registration info
   */
  readonly name: string;

  status: TurtleBehaviourStatus;

  /**
   * Called for each step of the behaviour, should perform a single operation.
   * @returns {true} if the behaviour has completed
   * @returns {true} if the behaviour was skipped
   */
  step(): boolean | void;

  /**
   * Called when the behaviour will start.
   */
  onStart?(): void;

  /**
   * Called when the behaviour is resumed. Will be provided with the
   * state that was returned from the onPause method.
   * The behaviour may be resumed on any turtle.
   */
  onResume?(data?: unknown): void;

  /**
   * Called when the behaviour is paused.
   * If required, the behaviour can return state that will be persisted
   * and passed to the turtle that is resuming the job.
   */
  onPause?(): unknown;

  /**
   * Called when the behaviour is completed (returns true from step)
   */
  onEnd?(): void;

  onError?(e: unknown): void;
}

export type TurtleBehaviourConstructor = {
  new (...args: unknown[]): TurtleBehaviour;
}

export class TurtleBehaviourBase {
  private _status: TurtleBehaviourStatus = TurtleBehaviourStatus.INIT;

  get status(): TurtleBehaviourStatus {
    return this._status;
  }

  set status(status: TurtleBehaviourStatus) {
    switch (status) {
      case TurtleBehaviourStatus.INIT:
        throw new Error('Cannot transition to TurtleBehaviourStatus.INIT');
      case TurtleBehaviourStatus.RUNNING:
        switch (this._status) {
          case TurtleBehaviourStatus.INIT:
          case TurtleBehaviourStatus.PAUSED:
            this._status = status;
            break;
          default:
            throw new Error(`Cannot transition from ${this._status} to ${status}`);
        } break;
      case TurtleBehaviourStatus.PAUSED:
      case TurtleBehaviourStatus.DONE:
        if (this._status !== TurtleBehaviourStatus.RUNNING) {
          throw new Error(`Cannot transition from ${this._status} to ${status}`);
        }
        this._status = status;
        break;
    }
  }
}
