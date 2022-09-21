import '/require_stub';
import { TURTLE_PROTOCOL_NAME } from '../utils/Consts';
import { EventLoop } from '../utils/EventLoop';
import { findProtocolHostId } from '../utils/findProtocolHostId';
import { TurtleRegistryCommand } from '../utils/services/TurtleRegistryService';
import { TurtleServiceCommands } from '../utils/services/TurtleService';

// const pos = gps.locate();
// if (!pos) {
//   throw new Error("Failed to find position");
// }

// console.log("Position is:", ...pos);

const modem = peripheral.find('modem');
if (!modem) throw new Error('Could not find modem');

const modemName = peripheral.getName(modem);
rednet.open(modemName);

const hostId = findProtocolHostId(TURTLE_PROTOCOL_NAME);
if (!hostId) {
  throw new Error('Could not find any agent protocol hosts');
}

const [cmd, ...params] = [...$vararg];

const sendCmd = (cmd: TurtleServiceCommands, ...params: any[]) => {
  rednet.send(hostId, {
    cmd, params,
  }, TURTLE_PROTOCOL_NAME);
}

if (cmd === null) {
  console.log("Entering interactive mode");
  EventLoop.on('char', (char: string) => {
    switch (char) {
      case 'w': {
        sendCmd(TurtleServiceCommands.forward, 1, false);
      } break;
      case 's': {
        sendCmd(TurtleServiceCommands.back, 1, false);
      } break;
      case 'a': {
        sendCmd(TurtleServiceCommands.turnLeft, false);
      } break;
      case 'd': {
        sendCmd(TurtleServiceCommands.turnRight, false);
      } break;
      case 'q': {
        sendCmd(TurtleServiceCommands.up, 1, false);
      } break;
      case 'e': {
        sendCmd(TurtleServiceCommands.down, 1, false);
      } break;
      case ' ': {
        sendCmd(TurtleServiceCommands.dig, false);
      } break;
      default:
        console.log("unknown char", char);
    }
    return false;
  });
  EventLoop.run();
} else if (cmd === '.') {
  // move the turtle to the player pos
  console.log("Locating...");
  const pos = gps.locate(3);
  if (!pos || !pos[0]) throw new Error("Failed to geolocate");
  sendCmd(
    TurtleServiceCommands.moveTo,
    Math.floor(pos[0]),
    Math.floor(pos[1]) - 1, // player's feet
    Math.floor(pos[2]),
  );
} else {
  console.log("Sending", cmd, "with params:", ...params);
  sendCmd(cmd, ...params);
}
