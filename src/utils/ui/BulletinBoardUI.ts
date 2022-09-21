import { EventLoop } from "../EventLoop";
import TaskStore, { TaskStatus } from "../stores/TaskStore";

const getColorForTaskStatus = (status: TaskStatus): number => {
  switch (status) {
    case TaskStatus.DONE:
      return colors.green;
    case TaskStatus.IN_PROGRESS:
      return colors.yellow;
    case TaskStatus.TODO:
    default:
      return colors.white;
  }
}

export default class BulletinBoardUI {
  private static ID_COUNTER: number = 0;
  private id: number = 0;
  private width: number;
  private height: number;
  private registered: boolean = false;

  constructor(private monitor: peripheral.Monitor, private taskStore: TaskStore, private fps: number = 1) {
    this.id = BulletinBoardUI.ID_COUNTER++;
    monitor.setTextScale(1);
    const size = monitor.getSize();
    this.width = size[0];
    this.height = size[1];

    console.log(`BulletinBoardUI ${this.id} created for monitor ${peripheral.getName(monitor).trim()}, w:${this.width} h:${this.height}`);
  }

  register() {
    if (this.registered) throw new Error("BulletinBoardUI is already registered");
    this.registered = true;

    const renderEvent = `render:BulletinBoardUI:${this.id}`;
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

    this.monitor.setCursorPos(2, 3);
    for (const task of this.taskStore.getAll()) {
      this.monitor.write(`${task.id}: `);
      this.monitor.setTextColor(getColorForTaskStatus(task.status));
      this.monitor.write(task.status);
      this.monitor.setTextColor(colors.white);
      this.monitor.write(` ${task.description}\n`);

      const [_, y] = this.monitor.getCursorPos();
      this.monitor.setCursorPos(2, y + 1);
    }
    // this.monitor.setCursorPos(1, 3);
    // this.monitor.write("Hello from monitor " + this.id);
    // this.monitor.setCursorPos(1, 4);
    // this.monitor.write("Frame number " + this.frameNum);

    term.redirect(oldterm);
  }
}
