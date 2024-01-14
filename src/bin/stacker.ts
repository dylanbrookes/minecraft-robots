import '/require_stub';

import { EventLoop } from '../utils/EventLoop';
import Logger from '../utils/Logger';

const monitor = peripheral.find<peripheral.Monitor>("monitor");
if (!monitor) {
  throw new Error('Failed to find a monitor');
}

monitor.setTextScale(0.5);
const [w, h] = monitor.getSize();
const maxWidth = Math.min(4, Math.ceil(w / 4));
let level = 0;
const posHistory: [number, number][] = [];
let pos = 0;
let dir = true;
let paused = false;
let width = 0; // set in main event loop

const oldTerm = term.redirect(monitor); // Now all term calls will go to the monitor instead
Logger.setTermRedirect(oldTerm);

monitor.setBackgroundColor(colors.black);
monitor.clear();

EventLoop.on('monitor_touch', () => {
  if (paused) {
    return;
  }
  // Logger.info("touch", x, y);
  paused = true;
  // flash the current row
  paintutils.drawLine(1, h - level, w, h - level, colors.white);
  paintutils.drawLine(pos + 1, h - level, pos + width, h - level, colors.red);
  sleep(0.3);
  paintutils.drawLine(1, h - level, w, h - level, colors.black);
  paintutils.drawLine(pos + 1, h - level, pos + width, h - level, colors.red);
  const leftOverflow = level === 0 ? 0 : Math.max(posHistory[level - 1][0] - pos, 0);
  const rightOverflow = level === 0 ? 0 : Math.max(pos + width - 1 - posHistory[level - 1][1], 0);
  if (leftOverflow + rightOverflow > 0) {
    // array of [pos, placed, level]
    const placements: [number, boolean, number][] = [];
    for (let i = 0; i < Math.min(leftOverflow, width); i++) {
      placements.push([posHistory[level - 1][0] - leftOverflow + i, false, -1]);
    }
    for (let i = 0; i < Math.min(rightOverflow, width); i++) {
      placements.push([posHistory[level - 1][1] + rightOverflow - i, false, -1]);
    }
    // animate falling blocks
    for (let l = level - 1; l >= 0; l--) {
      const remainingPlacements = placements.filter(([, placed]) => !placed);
      if (remainingPlacements.length === 0) break;
      for (const placement of remainingPlacements) {
        if (placement[1] === true) continue;
        paintutils.drawPixel(placement[0] + 1, h - l - 1, colors.black);
        paintutils.drawPixel(placement[0] + 1, h - l, colors.red);
        if (l === 0 || (posHistory[l - 1][0] <= placement[0] && posHistory[l - 1][1] >= placement[0])) {
          placement[1] = true;
          placement[2] = l;
          posHistory[l][0] = Math.min(posHistory[l][0], placement[0]);
          posHistory[l][1] = Math.max(posHistory[l][1], placement[0]);
        }
      }
      sleep(0.3);
    }
    for (const placement of placements) {
      paintutils.drawPixel(placement[0] + 1, h - placement[2], colors.white);
    }
    sleep(0.2);
    for (const placement of placements) {
      paintutils.drawPixel(placement[0] + 1, h - placement[2], colors.red);
    }
    sleep(0.2);
  }
  let restart = false;
  if (leftOverflow + rightOverflow >= width) {
    // lose
    for (let hh = h - level + 1; hh <= h; hh++) {
      paintutils.drawLine(1, hh, w, hh, colors.white);
      sleep(0.1);
    }
    sleep(1);
    restart = true;
  } else {
    posHistory[level] = [pos + leftOverflow, pos + width - 1 - rightOverflow];
    level++;
  }

  if (level === h) {
    // win!
    restart = true;
    for (let l = level - 1; l >= 0; l--) {
      paintutils.drawLine(1, 1, w, 1, colors.black);
      for (let i = 1; i < h - l; i++) {
        paintutils.drawLine(1, h - l + 1 - i, w, h - l + 1 - i, colors.black);
        paintutils.drawLine(posHistory[l][0] + 1, h - l - i, posHistory[l][1] + 1, h - l - i, colors.red);
        sleep(0.1);
      }
    }
    for (const color of [colors.red, colors.orange, colors.yellow, colors.green, colors.blue, colors.purple, colors.pink]) {
      monitor.setBackgroundColor(color);
      monitor.setTextColor(color);
      monitor.clear();
      sleep(0.1);
    }
  }

  if (restart) {
    monitor.setBackgroundColor(colors.black);
    monitor.setTextColor(colors.black);
    monitor.clear();
    level = 0;
  }

  pos = 1;
  dir = false;
  paused = false;
}, { async: true });

Logger.info('Started', w, h);
EventLoop.tickTimeout = 0.5;
EventLoop.run(() => {
  // Logger.info("step", paused, pos);
  if (paused) {
    return;
  }
  width = Math.ceil(Math.pow(Math.cos((level / h) * Math.PI / 2), 1.7) * maxWidth);
  EventLoop.tickTimeout = 0.5 - 0.45 * Math.sqrt(Math.pow(level / h, 0.2)); // speed up the game on later levels
  // Logger.info("step", pos + 1 + (dir? 0 : width - 1));
  if ((dir && (pos + width) >= w) || (!dir && pos <= 0)) {
    dir = !dir;
  }
  paintutils.drawPixel(pos + 1 + (dir? 0 : width - 1), h - level, colors.black);
  pos += dir ? 1 : -1;
  paintutils.drawLine(pos + 1, h - level, pos + width, h - level, colors.red);
});
