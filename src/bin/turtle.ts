import '/require_stub';
// import { JOBS_PROTOCOL_NAME } from 'src/utils/Consts';
// import { JobServerClient } from 'src/utils/JobServerClient';
import { EventLoop } from '../utils/EventLoop';
import { TurtleController } from '../utils/turtle/TurtleController';
import { TurtleService } from '../utils/services/TurtleService';
// import { LocationMonitor } from '../utils/LocationMonitor';
import { BehaviourStack } from '../utils/turtle/BehaviourStack';
import { findProtocolHostId } from '../utils/findProtocolHostId';
import { TURTLE_REGISTRY_PROTOCOL_NAME } from '../utils/Consts';
import { TurtleRegistryClient } from '../utils/clients/TurtleRegistryClient';

const modem = peripheral.find('modem');
if (!modem) throw new Error('Could not find modem');

const modemName = peripheral.getName(modem);
rednet.open(modemName);

// const hostId = findProtocolHostId(TURTLE_REGISTRY_PROTOCOL_NAME);
// if (!hostId) throw new Error("Could not find turtle registry host");

// it sets up events in the constructor
// const turtleRegistryClient = new TurtleRegistryClient(hostId);
// turtleRegistryClient.startPeriodicRegistration();

// console.log(`Looking for protocol ${JOBS_PROTOCOL_NAME} host...`);
// const hostIds = rednet.lookup(JOBS_PROTOCOL_NAME);
// if (!hostIds || (Array.isArray(hostIds) && hostIds.length === 0)) {
//   throw new Error('Could not find any agent protocol hosts, lookup returned ' + hostIds);
// }
// console.log(`Found host IDs: ${hostIds}`);
// const hostId = Array.isArray(hostIds) ? hostIds[0] : hostIds;

// console.log("Sending to", hostId);
// const jobServerClient = new JobServerClient(hostId);
// const jobs = jobServerClient.list();
// console.log("These are the jobs:", textutils.serialize(jobs));




// EventLoop.on('my-timer', (...params) => {
//   console.log("My timer event fired");
//   // console.log("params:", ...params);
//   // return false;
// });

// EventLoop.emitRepeat('my-timer', 1, 'hello', 'there');

TurtleController.register();
TurtleService.register();
// LocationMonitor.register();

// EventLoop.setTimeout(() => {
//   console.log("Timeout called, pushing behaviour");
//   BehaviourStack.push(new PathfinderBehaviour([0,235,0]));
// }, 3);

EventLoop.run(() => {
  // check opcons
  // Do some work
  // the important part is that only one bit of code is trying to do something at once,
  // this is where sequenced async/movement work will go
  
  // BehaviourStack.step();
});
