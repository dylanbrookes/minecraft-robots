import { EventLoop } from "../EventLoop";

const randomColor = () => 1 << Math.round(Math.random() * 0xe);

export default class FloorMonitorUI {
  private static ID_COUNTER: number = 0;
  private id: number = 0;
  private width: number;
  private height: number;
  private registered: boolean = false;

  constructor(private monitor: peripheral.Monitor, private fps: number = 0.1) {
    this.id = FloorMonitorUI.ID_COUNTER++;
    monitor.setTextScale(0.5);
    monitor.clear();
    const size = monitor.getSize();
    this.width = size[0];
    this.height = size[1];

    console.log(`FloorMonitorUI ${this.id} created for monitor ${peripheral.getName(monitor).trim()}, w:${this.width} h:${this.height}`);
  }

  register() {
    if (this.registered) throw new Error("FloorMonitorUI is already registered");
    this.registered = true;

    const renderEvent = `render:BulletinBoardUI:${this.id}`;
    EventLoop.on(renderEvent, () => this.render());
    EventLoop.emitRepeat(renderEvent, 1 / this.fps);
    EventLoop.on("monitor_touch", (side, x, y) => {
      const oldterm = term.redirect(this.monitor);
      paintutils.drawPixel(x, y, randomColor());
      term.redirect(oldterm);
    });
  }

  render() {
    const oldterm = term.redirect(this.monitor);
  
    const wu = this.width >> 2;
    const hu = this.height >> 2;
    for (let x = 0; x < this.width / wu; x++) {
      for (let y = 0; y < this.height / hu; y++) {
        paintutils.drawFilledBox(x * wu, y * hu, (x + 1) * wu, (y + 1) * hu, randomColor());
      }
    }

    term.redirect(oldterm);
  }
}
