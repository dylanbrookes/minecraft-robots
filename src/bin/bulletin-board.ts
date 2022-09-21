import '/require_stub';
import BulletinBoardUI from '../utils/ui/BulletinBoardUI';
import { EventLoop } from '../utils/EventLoop';
import TaskStore from '../utils/stores/TaskStore';

const taskStore = new TaskStore();

const monitor = peripheral.find<peripheral.Monitor>("monitor");
if (!monitor) {
  console.log("Failed to find a monitor");
} else {
  const ui = new BulletinBoardUI(monitor, taskStore);
  ui.register();
}

EventLoop.run();
