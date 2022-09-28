import Logger from "../Logger";
import PriorityQueue from "../PriorityQueue";
import { TurtleBehaviour, TurtleBehaviourStatus } from "./behaviours/TurtleBehaviour";

class __BehaviourStack__ {
  private priorityQueue = new PriorityQueue<TurtleBehaviour>(__BehaviourStack__.CompareBehaviourPriority);
  private lastBehaviour: TurtleBehaviour | undefined;

  static CompareBehaviourPriority(a: TurtleBehaviour, b: TurtleBehaviour): boolean {
    return a.priority > b.priority;
  }

  peek(): TurtleBehaviour | undefined {
    return this.priorityQueue.peek();
  }

  push(behaviour: TurtleBehaviour) {
    this.priorityQueue.push(behaviour);
  }

  step() {
    const currentBehaviour = this.priorityQueue.peek();
    if (!this.lastBehaviour && currentBehaviour) {
      Logger.info("Found something to do!");
    }

    if (currentBehaviour && currentBehaviour !== this.lastBehaviour) {
      if (currentBehaviour.status === TurtleBehaviourStatus.INIT) {
        currentBehaviour.onStart?.();
      } else {
        currentBehaviour.onResume?.();
      }
      currentBehaviour.status = TurtleBehaviourStatus.RUNNING;
    }
    
    if (this.lastBehaviour && currentBehaviour !== this.lastBehaviour) {
      // this happens when a new behaviour is added that takes priority
      // do the behaviour switching things ...
      this.lastBehaviour.onPause?.();
      this.lastBehaviour.status = TurtleBehaviourStatus.PAUSED;
    }

    this.lastBehaviour = currentBehaviour;
    if (!currentBehaviour) {
      // console.log("Nothing to do...");
      return;
    }
    let done: boolean | void;
    try {
      done = currentBehaviour.step();
    } catch (e) {
      Logger.error(e);
      Logger.error(`Behaviour ${currentBehaviour.name} threw an error`);
      currentBehaviour.status = TurtleBehaviourStatus.FAILED;
      currentBehaviour.onError?.(e);
      this.lastBehaviour = undefined;
      this.priorityQueue.pop();
    }

    if (done) {
      currentBehaviour.status = TurtleBehaviourStatus.DONE;
      currentBehaviour.onEnd?.();

      this.lastBehaviour = undefined;
      if (this.priorityQueue.peek() !== currentBehaviour) {
        throw new Error("Failed to finish behaviour, priority queue behaviour is not the current behaviour and idk how to remove any element :(");
      }
      this.priorityQueue.pop();

      if (this.priorityQueue.size() === 0) {
        Logger.info("Nothing to do...");
      }
    }
  }
}

export const BehaviourStack = new __BehaviourStack__();
