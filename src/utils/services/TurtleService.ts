import { HOSTNAME, TURTLE_PROTOCOL_NAME } from "../Consts";
import { EventLoop } from "../EventLoop";
import Logger from "../Logger";
import { PathfinderBehaviour } from "../turtle/behaviours/PathfinderBehaviour";
import { BehaviourStack } from "../turtle/BehaviourStack";
import getStatusUpdate from "../turtle/getStatusUpdate";
import JobProcessor from "../turtle/JobProcessor";
import { TurtleController } from "../turtle/TurtleController";

export enum TurtleCommands {
  forward = 'forward',
  back = 'back',
  turnLeft = 'turnLeft',
  turnRight = 'turnRight',
  up = 'up',
  down = 'down',
  moveTo = 'moveTo',
  exec = 'exec',
  dig = 'dig',
  digUp = 'digUp',
  digDown = 'digDown',
  addJob = 'addJob',
  cancelJob = 'cancelJob',
  status = 'status',
  inspect = 'inspect',
  reboot = 'reboot',
}

type Message = { cmd: string, params: unknown[] };

class __TurtleService__ {
  private registered = false;

  // expects rednet to already be open
  register() {
    if (this.registered) throw new Error("TurtleService is already registered");
    this.registered = true;

    Logger.info("Registering Turtle Service");
    rednet.host(TURTLE_PROTOCOL_NAME, HOSTNAME);
    EventLoop.on('rednet_message', (sender: number, message: Message, protocol: string | null) => {
      if (protocol === TURTLE_PROTOCOL_NAME) {
        this.onMessage(message, sender);
      }
      return false;
    });
  }

  onMessage(message: Message, sender: number) {
    Logger.debug("GOT MESSAGE from sender", sender, message);
    if (typeof message !== 'object' || message === null || !('cmd' in message)) {
      Logger.error("idk what to do with this", textutils.serialize(message));
      return;
    }

    switch (message.cmd) {
      case TurtleCommands.forward:
      case TurtleCommands.back:
      case TurtleCommands.turnLeft:
      case TurtleCommands.turnRight:
      case TurtleCommands.up:
      case TurtleCommands.down:
      case TurtleCommands.dig:
      case TurtleCommands.digUp:
      case TurtleCommands.digDown:
        if (message.cmd in TurtleController
          // @ts-expect-error message is untyped
          && typeof TurtleController[message.cmd] === 'function') TurtleController[message.cmd](...(message.params || []));
        else throw new Error(`Method ${message.cmd} does not exist on TurtleController`);
        break;
      case TurtleCommands.inspect:
        rednet.send(sender, { result: turtle.inspect() }, TURTLE_PROTOCOL_NAME);
        break;
      case TurtleCommands.moveTo:
        
        BehaviourStack.push(new PathfinderBehaviour(
          // @ts-expect-error untyped
          message.params,
          100, // use higher priority so that it trumps jobs
        ));
        break;
      case TurtleCommands.exec:
        if (!('params' in message)) throw new Error(`Missing params`);
        Logger.info("Running command:", ...message.params);
        // @ts-expect-error untyped
        shell.run(...message.params);
        break;
      case TurtleCommands.addJob: {
        const job = message.params;
        Logger.info("Adding job with params:", job);
        // @ts-expect-error untyped
        JobProcessor.add(job);
        rednet.send(sender, { ok: true }, TURTLE_PROTOCOL_NAME);
      } break;
      case TurtleCommands.cancelJob: {
        // @ts-expect-error untyped
        const { id } = message.params;
        Logger.info("Cancelling job", id);
        JobProcessor.cancel(id);
        rednet.send(sender, { ok: true }, TURTLE_PROTOCOL_NAME);
      } break;
      case TurtleCommands.status: {
        const status = getStatusUpdate();
        Logger.info("Received status request, sending:", status);
        rednet.send(sender, { ok: true, status }, TURTLE_PROTOCOL_NAME);
      } break;
      case TurtleCommands.reboot: {
        os.queueEvent('terminate', 'reboot');
      } break;
      default:
        Logger.error("invalid command", message.cmd);
    }
  }
}

export const TurtleService = new __TurtleService__();
