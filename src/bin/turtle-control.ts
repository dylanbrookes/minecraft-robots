import '/require_stub';
import { EventLoop } from "../utils/EventLoop";
import Logger from "../utils/Logger";
import TurtleControlService from "../utils/services/TurtleControlService";
import TurtleStore from "../utils/stores/TurtleStore";
import TurtleControlUI from "../utils/ui/TurtleControlUI";
import { JobStore } from '../utils/stores/JobStore';
import JobRegistryService from '../utils/services/JobRegistryService';
import JobScheduler from '../utils/JobScheduler';
import ResourceRegistryService from '../utils/services/ResourceRegistryService';
import { ResourceStore } from '../utils/stores/ResourceStore';

const modem = peripheral.find('modem');
if (!modem) throw new Error('Could not find modem');

const modemName = peripheral.getName(modem);
rednet.open(modemName);

const turtleStore = new TurtleStore();
const turtleRegistry = new TurtleControlService(turtleStore);
turtleRegistry.register();

const jobStore = new JobStore();
const jobRegistry = new JobRegistryService(jobStore);
jobRegistry.register();

const jobScheduler = new JobScheduler(jobStore, turtleStore);
jobScheduler.register();

const resourceStore = new ResourceStore();
const resourceRegistry = new ResourceRegistryService(resourceStore);
resourceRegistry.register();

const monitor = peripheral.find<peripheral.Monitor>("monitor");
if (!monitor) {
  Logger.error("Failed to find a monitor");
} else {
  const ui = new TurtleControlUI(monitor, turtleStore, jobStore, resourceStore);
  ui.register();
}

EventLoop.run();
