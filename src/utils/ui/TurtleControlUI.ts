import { EventLoop } from "../EventLoop";
import Logger from "../Logger";
import { JobStore } from "../stores/JobStore";
import { ResourceStore } from "../stores/ResourceStore";
import TurtleStore from "../stores/TurtleStore";
import { serializePosition } from "../turtle/Consts";

export default class TurtleControlUI {
  private static ID_COUNTER: number = 0;
  private id: number = 0;
  private width: number;
  private height: number;
  private registered: boolean = false;

  constructor(
    private monitor: peripheral.Monitor,
    private turtleStore: TurtleStore,
    private jobStore: JobStore,
    private resourceStore: ResourceStore,
    private fps: number = 1,
  ) {
    this.id = TurtleControlUI.ID_COUNTER++;
    monitor.setTextScale(0.5);
    const size = monitor.getSize();
    this.width = size[0];
    this.height = size[1];

    Logger.info(`TurtleControlUI ${this.id} created for monitor ${peripheral.getName(monitor).trim()}, w:${this.width} h:${this.height}`);
  }

  register() {
    if (this.registered) throw new Error("TurtleControlUI is already registered");
    this.registered = true;

    const renderEvent = `render:TurtleControlUI:${this.id}`;
    EventLoop.on(renderEvent, () => this.render());
    EventLoop.emitRepeat(renderEvent, 1 / this.fps);
    EventLoop.on("monitor_touch", (side, x, y) => {
      const oldterm = term.redirect(this.monitor);
      paintutils.drawPixel(x, y, 0x4);
      term.redirect(oldterm);
    });
  }

  private frameNum = 0;
  render() {
    this.frameNum++;
    // console.log("Drawing frame", this.frameNum);

    const oldterm = term.redirect(this.monitor);
  
    this.monitor.setBackgroundColor(0x8000);
    this.monitor.clear();
    paintutils.drawBox(1, 1, this.width, this.height, 0x8);
    this.monitor.setBackgroundColor(0x8000);
    this.monitor.setCursorPos(2, 2);
    this.monitor.write("Hey there!!!!! " + this.frameNum);

    const text: string[] = [];
    this.turtleStore.select().forEach(({ id, label, location, lastSeen, status, currentBehaviour }, i) => text.push(
      `[${id}] ${label}`,
      `    status: ${status}`
        + ((currentBehaviour && currentBehaviour !== '') ? ` (${currentBehaviour})` : ''),
      `    lastSeen: ${lastSeen}`,
      location
        ? `    x: ${location[0]} y: ${location[1]} z: ${location[2]}`
        : `    location unknown`,
    ));
    for (const [i, t] of text.entries()) {
      this.monitor.setCursorPos(2, 3 + i);
      this.monitor.write(t);
    }

    this.monitor.setCursorPos(2, this.monitor.getCursorPos()[1] + 1);
    this.monitor.write('Resources:');
    this.monitor.setCursorPos(2, this.monitor.getCursorPos()[1] + 1);
    for (const resource of this.resourceStore.select()) {
      this.monitor.write(`${resource.id}: ${resource.tags.join(',')}`);
      this.monitor.setCursorPos(2, this.monitor.getCursorPos()[1] + 1);
      this.monitor.write(`    Position: ${serializePosition(resource.position)}`);
      this.monitor.setCursorPos(2, this.monitor.getCursorPos()[1] + 1);
    }

    this.monitor.write('Jobs:');
    this.monitor.setCursorPos(2, this.monitor.getCursorPos()[1] + 1);
    for (const job of this.jobStore.select()) {
      this.monitor.write(`${job.id}: ${job.type} ${job.status}`);
      if (job.turtle_id) {
        this.monitor.setCursorPos(2, this.monitor.getCursorPos()[1] + 1);
        this.monitor.write(`    Turtle ID: ${job.turtle_id}`);
      }
      this.monitor.setCursorPos(2, this.monitor.getCursorPos()[1] + 1);
    }

    term.redirect(oldterm);
  }
}
