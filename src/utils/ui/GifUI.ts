import { EventLoop } from "../EventLoop";

export default class GifUI {
  private width: number;
  private height: number;
  private static registered: boolean = false;
  private frames: paintutils.ImageData[];
  private frameNum = 0;

  constructor(private monitor: peripheral.Monitor, private path: string, private fps: number = 8) {
    monitor.setTextScale(0.5);
    const size = monitor.getSize();
    this.width = size[0];
    this.height = size[1];

    // load frames
    if (!fs.exists(path)) throw new Error("Path doesn't exist");
    if (!fs.isDir(path)) throw new Error("Path is not a directory");
    const files = fs.list(path);
    this.frames = files
      .map((fn) => {
        const data = paintutils.loadImage(`${path}/${fn}`);
        if (!data) throw new Error("Failed to load frame " + fn);
        return data;
      });

    console.log(`GifUI created with ${this.frames.length} frames, w:${this.width} h:${this.height}`);
  }

  register() {
    if (GifUI.registered) throw new Error("GifUI is already registered");
    GifUI.registered = true;

    const renderEvent = `render:GifUI`;
    EventLoop.on(renderEvent, () => this.render());
    EventLoop.emitRepeat(renderEvent, 1 / this.fps);
  }

  render() {
    // console.log("Drawing frame", this.frameNum);

    // this.monitor.clear();
    // this.monitor.setCursorPos(1, 1);
    // this.monitor.write("Hey there!!!!!");
    // this.monitor.setCursorPos(1, 2);
    // this.monitor.write("Hello from monitor " + this.id);
    // this.monitor.setCursorPos(1, 3);
    // this.monitor.write("Frame number " + this.frameNum);
    const oldterm = term.redirect(this.monitor);

    paintutils.drawImage(this.frames[this.frameNum], 1, 1);

    term.redirect(oldterm);

    this.frameNum = (this.frameNum + 1) % this.frames.length;
  }
}
