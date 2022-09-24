import '/require_stub';
import FloorMonitorUI from '../utils/ui/FloorMonitorUI';
import { EventLoop } from '../utils/EventLoop';

const monitor = peripheral.find<peripheral.Monitor>("monitor");
if (!monitor) {
  console.log("Failed to find a monitor");
} else {
  const ui = new FloorMonitorUI(monitor);
  ui.register();
}

EventLoop.run();
