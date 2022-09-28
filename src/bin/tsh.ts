import '/require_stub';
import { TURTLE_PROTOCOL_NAME } from '../utils/Consts';
import { EventLoop } from '../utils/EventLoop';
import { findProtocolHostId } from '../utils/findProtocolHostId';
import { TurtleCommands } from '../utils/services/TurtleService';
import { JobRecord, JobStatus } from '../utils/stores/JobStore';
import { JobType } from '../utils/turtle/Consts';
import { Heading } from '../utils/LocationMonitor';
import Logger from '../utils/Logger';

// const pos = gps.locate();
// if (!pos) {
//   throw new Error("Failed to find position");
// }

// console.log("Position is:", ...pos);

const modem = peripheral.find('modem');
if (!modem) throw new Error('Could not find modem');

const modemName = peripheral.getName(modem);
rednet.open(modemName);

// const hostId = findProtocolHostId(TURTLE_PROTOCOL_NAME);
// if (!hostId) {
//   throw new Error('Could not find any agent protocol hosts');
// }

const [hostIdArg, cmd, ...params] = [...$vararg];
if (!hostIdArg) {
  throw new Error("host id required");
}
const hostId = parseInt(hostIdArg);

const sendCmd = (cmd: TurtleCommands, ...params: any[]) => {
  rednet.send(hostId, {
    cmd, params,
  }, TURTLE_PROTOCOL_NAME);
}

if (cmd === null) {
  Logger.info("Entering interactive mode");
  EventLoop.on('char', (char: string) => {
    switch (char) {
      case 'w': {
        sendCmd(TurtleCommands.forward, 1, false);
      } break;
      case 's': {
        sendCmd(TurtleCommands.back, 1, false);
      } break;
      case 'a': {
        sendCmd(TurtleCommands.turnLeft, false);
      } break;
      case 'd': {
        sendCmd(TurtleCommands.turnRight, false);
      } break;
      case 'q': {
        sendCmd(TurtleCommands.up, 1, false);
      } break;
      case 'e': {
        sendCmd(TurtleCommands.down, 1, false);
      } break;
      case ' ': {
        sendCmd(TurtleCommands.dig, false);
      } break;
      case '?': {
        sendCmd(TurtleCommands.inspect, false);
        const [pid, message] = rednet.receive(TURTLE_PROTOCOL_NAME, 3);
        if (!pid) throw new Error("No response to command " + cmd);
        Logger.info(message);
      } break;
      default:
        Logger.warn("unknown char", char);
    }
    return false;
  });
  EventLoop.run();
} else if (cmd === '.') {
  // move the turtle to the player pos
  Logger.info("Locating...");
  const pos = gps.locate(3);
  if (!pos || !pos[0]) throw new Error("Failed to geolocate");
  sendCmd(
    TurtleCommands.moveTo,
    Math.floor(pos[0]),
    Math.floor(pos[1]) - 1, // player's feet
    Math.floor(pos[2]),
  );
} else if (cmd === 'spin') {
  Logger.info("Making it spin...");
  sendCmd(TurtleCommands.addJob, <JobRecord>{
    id: 1,
    type: JobType.spin,
    args: [12],
    resume_counter: 0,
    status: JobStatus.IN_PROGRESS,
    issuer_id: os.computerID(),
  });
} else if (cmd === 'clear') {
  const [headingParam, ...dimensions] = params;
  let heading = Heading.UNKNOWN;
  switch (headingParam.toLowerCase()) {
    case 'n':
    case 'north':
      heading = Heading.NORTH;
      break;
    case 's':
    case 'south':
      heading = Heading.SOUTH;
      break;
    case 'w':
    case 'west':
      heading = Heading.WEST;
      break;
    case 'e':
    case 'east':
      heading = Heading.EAST;
      break;
  }

  Logger.info("Locating...");
  const pos = gps.locate(3);
  if (!pos || !pos[0]) throw new Error("Failed to geolocate");
  const feetPos = [Math.floor(pos[0]), Math.floor(pos[1]) - 1, Math.floor(pos[2])];

  Logger.info("Clearing...", textutils.serialize(feetPos), heading, dimensions);
  sendCmd(TurtleCommands.addJob, <JobRecord>{
    id: 1,
    type: JobType.clear,
    args: [
      feetPos,
      heading,
      [parseInt(dimensions[0]), parseInt(dimensions[1]), parseInt(dimensions[2])],
    ],
    resume_counter: 0,
    status: JobStatus.IN_PROGRESS,
    issuer_id: os.computerID(),
  });
} else {
  Logger.info("Sending", cmd, "with params:", ...params);
  sendCmd(cmd as TurtleCommands, ...params);
}
