import { HOSTNAME, TURTLE_PROTOCOL_NAME } from "../Consts";
import { EventLoop } from "../EventLoop";
import { PathfinderBehaviour } from "../turtle/behaviours/PathfinderBehaviour";
import { BehaviourStack } from "../turtle/BehaviourStack";
import { TurtleController } from "../turtle/TurtleController";

export enum TurtleServiceCommands {
  forward = 'forward',
  back = 'back',
  turnLeft = 'turnLeft',
  turnRight = 'turnRight',
  up = 'up',
  down = 'down',
  moveTo = 'moveTo',
  exec = 'exec',
}

class __TurtleService__ {
  private registered = false;

  // expects rednet to already be open
  register() {
    if (this.registered) throw new Error("TurtleService is already registered");
    this.registered = true;

    console.log("Registering Turtle Service");
    rednet.host(TURTLE_PROTOCOL_NAME, HOSTNAME);
    EventLoop.on('rednet_message', (sender: number, message: any, protocol: string | null) => {
      if (protocol === TURTLE_PROTOCOL_NAME) {
        this.onMessage(message, sender);
      }
      return false;
    });
  }

  onMessage(message: any, sender: number) {
    // console.log("GOT MESSAGE", "from sender", sender, textutils.serialize(message));
    if ('cmd' in message) {
      switch (message.cmd) {
        case TurtleServiceCommands.forward:
        case TurtleServiceCommands.back:
        case TurtleServiceCommands.turnLeft:
        case TurtleServiceCommands.turnRight:
        case TurtleServiceCommands.up:
        case TurtleServiceCommands.down:
          if (message.cmd in TurtleController
            // @ts-ignore
            && typeof TurtleController[message.cmd] === 'function') TurtleController[message.cmd](...(message.params || []));
          else throw new Error(`Method ${message.cmd} does not exist on TurtleController`);
          break;
        case TurtleServiceCommands.moveTo:
          console.log("Adding pathfinder to", ...message.params);
          BehaviourStack.push(new PathfinderBehaviour(message.params));
          break;
        case TurtleServiceCommands.exec:
          console.log("Running command:", ...message.params);
          shell.run(...message.params);
          break;
        default:
          console.log("invalid command", message.cmd);
      }
    } else {
      console.log("idk what to do with this", textutils.serialize(message));
    }
  }
}

export const TurtleService = new __TurtleService__();
