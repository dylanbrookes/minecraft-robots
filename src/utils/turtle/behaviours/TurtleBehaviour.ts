
export interface TurtleBehaviour {
  // might also want to add some way for the behaviour to
  // relay its state back to the control server (status string, behaviour name, progress, etc)

  /**
   * Used to prioritize behaviours.
   * Can also be a getter
   */
  readonly priority: number;
  /**
   * Sent in registration info
   */
  readonly name: string;

  /**
   * Called for each step of the behaviour, should perform a single operation.
   * @returns if the behaviour has completed
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
  onResume?(data?: any): void;

  /**
   * Called when the behaviour is paused.
   * If required, the behaviour can return state that will be persisted
   * and passed to the turtle that is resuming the job.
   */
  onPause?(): any;

}
