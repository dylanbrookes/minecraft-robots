import '/require_stub';
import { EventLoop } from '../utils/EventLoop';
import GifUI from '../utils/ui/GifUI';

const [path] = [...$vararg];

const monitor = peripheral.find<peripheral.Monitor>("monitor");
if (!monitor) {
  console.log("Failed to find a monitor");
} else {
  const ui = new GifUI(monitor, path);
  ui.register();
}

EventLoop.run();
