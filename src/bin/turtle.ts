import '/require_stub';
import { EventLoop } from '../utils/EventLoop';
import { TurtleService } from '../utils/services/TurtleService';
import { LocationMonitor } from '../utils/LocationMonitor';
import { BehaviourStack } from '../utils/turtle/BehaviourStack';
import { TurtleEvent } from '../utils/turtle/Consts';
import Logger from '../utils/Logger';
import { RefuelBehaviour } from '../utils/turtle/behaviours/RefuelBehaviour';
import FuelMonitor from '../utils/turtle/FuelMonitor';
import { TurtleControlClient } from '../utils/clients/TurtleControlClient';
import { findProtocolHostId } from '../utils/findProtocolHostId';
import { TURTLE_CONTROL_PROTOCOL_NAME } from '../utils/Consts';

const modem = peripheral.find('modem');
if (!modem) throw new Error('Could not find modem');

const modemName = peripheral.getName(modem);
rednet.open(modemName);

const turtleControlHostId = findProtocolHostId(TURTLE_CONTROL_PROTOCOL_NAME);

FuelMonitor.register();
TurtleService.register();
LocationMonitor.register();

if (!turtleControlHostId) {
  Logger.warn('Did not find a turtle control host');
} else {
  // it sets up events in the constructor
  const turtleControlClient = new TurtleControlClient(turtleControlHostId);
  turtleControlClient.register();
}

EventLoop.on(TurtleEvent.low_fuel, () => {
  BehaviourStack.push(new RefuelBehaviour());
});

EventLoop.on(TurtleEvent.out_of_fuel, () => {
  Logger.error("OH NO WE ARE OUT OF FUEL. THIS IS FROM AN EVENT.");
  return false;
});

Logger.info("Done startup");
EventLoop.run(() => {
  BehaviourStack.step();
});
