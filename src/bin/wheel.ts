import '/require_stub';

import { EventLoop } from '../utils/EventLoop';
import Logger from '../utils/Logger';
import { ItemTags } from '../utils/ItemTags';

const SPIN_END_EVENT = 'spin_end';
const WIN_EVENT = 'win';
const PLAY_SOUND_SEQUENCE_EVENT = 'play_sound_sequence';
const MIN_SPIN_DURATION = 5;
const MAX_SPIN_DURATION = 8;
const SPIN_SPEED = 4; // wheel sections / s
const WHEEL_TICK_HEIGHT = 3; // height of each section in the wheel
const WHEEL_SPIN_SOUND = 'entity.experience_orb.pickup';

const SOUND_SEQUENCES = {
  winBig() {
    speaker?.playSound('ui.toast.challenge_complete');
  },
  win() {
    speaker?.playSound('entity.player.levelup');
  },
  lose() {
    speaker?.playSound('entity.witch.celebrate');
    sleep(0.5);
  },
  loseBig() {
    speaker?.playSound('item.flintandsteel.use');
    sleep(0.25);
    speaker?.playSound('entity.tnt.primed');
    sleep(1.5);
    speaker?.playSound('entity.villager.no');
  },
}

type WheelTick = {
  item: ItemTags,
  count: number,
  label: string,
  color: colors.Color,
  textColor?: colors.Color,
  soundSequence?: keyof typeof SOUND_SEQUENCES,
} | { empty: true };
const WHEEL: WheelTick[] = [
  {
    item: ItemTags.diamond,
    count: 1,
    label: 'Diamond',
    color: colors.lightBlue,
    soundSequence: 'winBig',
  },
  {
    item: ItemTags.coal,
    count: 4,
    label: 'Coal',
    color: colors.black,
    textColor: colors.white,
    soundSequence: 'lose',
  },
  {
    item: ItemTags.gold_ingot,
    count: 1,
    label: 'Gold',
    color: colors.yellow,
  },
  {
    item: ItemTags.stick,
    count: 2,
    label: 'Sticks',
    color: colors.brown,
    textColor: colors.white,
  },
  {
    item: ItemTags.emerald,
    count: 1,
    label: 'Emerald',
    color: colors.green,
  },
  {
    item: ItemTags.cobblestone,
    count: 8,
    label: 'Cobblestone',
    color: colors.lightGray,
    textColor: colors.white,
    soundSequence: 'lose',
  },
  {
    item: ItemTags.diamond_block,
    count: 1,
    label: 'JACKPOT',
    soundSequence: 'winBig',
    color: colors.blue,
    textColor: colors.white,
  },
  {
    item: ItemTags.cobblestone,
    count: 8,
    label: 'Cobblestone',
    color: colors.lightGray,
    textColor: colors.white,
    soundSequence: 'lose',
  },
  {
    item: ItemTags.gold_ingot,
    count: 1,
    label: 'Gold',
    color: colors.yellow,
  },
  {
    item: ItemTags.stick,
    count: 2,
    label: 'Sticks',
    color: colors.brown,
    textColor: colors.white,
  },
  {
    item: ItemTags.emerald,
    count: 1,
    label: 'Emerald',
    color: colors.green,
  },
  {
    item: ItemTags.coal,
    count: 4,
    label: 'Coal',
    color: colors.black,
    textColor: colors.white,
    soundSequence: 'lose',
  },
  {
    item: ItemTags.tnt,
    count: 1,
    label: '???',
    color: colors.red,
    textColor: colors.white,
    soundSequence: 'loseBig',
  },
  {
    item: ItemTags.coal,
    count: 4,
    label: 'Coal',
    color: colors.black,
    textColor: colors.white,
    soundSequence: 'lose',
  },
  {
    item: ItemTags.emerald,
    count: 4,
    label: 'Emerald x4',
    color: colors.green,
  },
  {
    item: ItemTags.gold_ingot,
    count: 1,
    label: 'Gold',
    color: colors.yellow,
  },
];

const monitor = peripheral.find<peripheral.Monitor>("monitor");
if (!monitor) {
  throw new Error('Failed to find a monitor');
}

const speaker = peripheral.find<peripheral.Speaker>("speaker");
if (!speaker) {
  Logger.warn("Failed to find a speaker");
}

const dropper = peripheral.find<peripheral.Inventory>("minecraft:dropper");
if (!dropper) {
  Logger.warn("Failed to find a dropper");
} else {
  const maybeSide = peripheral.getName(dropper);
  if (!['back', 'front', 'top', 'bottom', 'left', 'right'].includes(maybeSide)) {
    throw new Error(`Dropper must be connected directly on a side, connected on ${maybeSide}`);
  }
}

const storage = peripheral.find<peripheral.Inventory>("minecraft:barrel");
if (!storage) {
  Logger.warn("Failed to find a storage barrel");
}

math.randomseed(os.epoch('utc'));
monitor.setTextScale(0.5);
const [w, h] = monitor.getSize();
let inputPaused = false;
let wheelRenderPaused = false;
let spinning = false;
let spinStart = 0;
let spinDuration = 0;
// indicates the pos at the center of the screen
// each int increment eqs one wheel section, only updates at start/end of spin
let wheelPos = 0;

const oldTerm = term.redirect(monitor); // Now all term calls will go to the monitor instead
Logger.setTermRedirect(oldTerm);

monitor.setBackgroundColor(colors.black);
monitor.clear();

EventLoop.on('monitor_touch', () => {
  if (inputPaused) {
    return;
  }
  // Logger.info("touch", x, y);
  inputPaused = true;
  spinning = true;
  spinStart = os.epoch('utc');
  spinDuration = MIN_SPIN_DURATION + (math.random() * (MAX_SPIN_DURATION - MIN_SPIN_DURATION));
}, { async: true });

// distributes the rewards
EventLoop.on(WIN_EVENT, (item: ItemTags, count: number) => {
  if (dropper === null || storage === null) {
    Logger.error('Failed to distribute rewards, missing dropper/storage');
    return;
  }

  const items = storage.list();
  const filteredItems: [number, ItemDetails][] = [];
  for (const slot of Object.keys(items)) {
    const details = items[slot as unknown as number];
    if (details.name === item) {
      filteredItems.push([slot as unknown as number, details]);
    }
  }

  // move items into dropper
  let remaining = count;
  while (remaining > 0) {
    const entry = filteredItems.pop();
    if (!entry) {
      Logger.error(`Ran out of ${item}, remaining: ${remaining}`);
      break;
    }
    const [slot, details] = entry;
    const toMove = Math.min(remaining, details.count);
    storage.pushItems(peripheral.getName(dropper), slot, toMove);
    remaining -= toMove;
  }

  // drop items
  // Logger.info('Dropping items');
  const dropperSide = peripheral.getName(dropper);
  while (Object.keys(dropper.list()).length > 0) {
    redstone.setOutput(dropperSide, true);
    sleep(0.05);
    redstone.setOutput(dropperSide, false);
    sleep(0.05);
  }
}, { async: true });

EventLoop.on(PLAY_SOUND_SEQUENCE_EVENT, (sequenceName: keyof typeof SOUND_SEQUENCES) => {
  SOUND_SEQUENCES[sequenceName]();
}, { async: true });

EventLoop.on(SPIN_END_EVENT, () => {
  const wheelTick = WHEEL[Math.floor(wheelPos) % WHEEL.length];
  Logger.info("Spin ended", wheelPos, textutils.serialize(wheelTick));
  spinning = false;
  if (!('empty' in wheelTick)) {
    EventLoop.emit(WIN_EVENT, wheelTick.item, wheelTick.count);
    EventLoop.emit(PLAY_SOUND_SEQUENCE_EVENT, wheelTick.soundSequence ?? 'win');
  } else {
    EventLoop.emit(PLAY_SOUND_SEQUENCE_EVENT, 'lose');
  }
  inputPaused = false;
}, { async: true });

function drawWheelTick(wheelTick: WheelTick, yOff: number) {
  let color: colors.Color = colors.red;
  let textColor: colors.Color = colors.white;
  let label = null;
  if ('empty' in wheelTick) {
    color = colors.black;
  } else {
    label = wheelTick.label;
    color = wheelTick.color;
    textColor = wheelTick.textColor ?? colors.black;
  }
  paintutils.drawFilledBox(2, yOff, w - 1, yOff + WHEEL_TICK_HEIGHT, color);
  if (label !== null) {
    term.setCursorPos(3, yOff + Math.floor(WHEEL_TICK_HEIGHT / 2));
    term.setBackgroundColor(color);
    term.setTextColor(textColor);
    term.write(label);
  }
}

Logger.info('Started', w, h);
EventLoop.tickTimeout = 0.05; // min timeout
EventLoop.run((delta) => {
  if (spinning) {
    const duration = os.epoch('utc') - spinStart;
    // Logger.info(duration, spinDuration);
    if (duration >= spinDuration * 1000) {
      EventLoop.emit(SPIN_END_EVENT);
    } else {
      const spinSpeed = Math.max(0.2, Math.min(1, duration / 1000) * Math.min(1, (spinDuration - (duration / 1000)) / 3)) * SPIN_SPEED;
      const lastWheelPosPx = Math.floor(wheelPos * WHEEL_TICK_HEIGHT);
      wheelPos -= (delta / 1000) * spinSpeed;
      if (wheelPos < 0) wheelPos += WHEEL.length;
      if (lastWheelPosPx !== Math.floor(wheelPos * WHEEL_TICK_HEIGHT)) {
        speaker?.playSound(WHEEL_SPIN_SOUND, 0.7, 0.5 + (math.random() * 0.4));
      }
    }
  }

  if (!wheelRenderPaused) {
    // render the wheel
    paintutils.drawFilledBox(1, 1, w, h, colors.white);
    const wheelPosInt = Math.floor(wheelPos);
    const subsectionOffset = wheelPos - wheelPosInt;
    // Logger.info( Math.ceil(h / WHEEL_TICK_HEIGHT));
    for (let i = 0; i <= Math.ceil(h / WHEEL_TICK_HEIGHT); i++) {
      const wheelTick = WHEEL[(Math.floor(wheelPos - (h / 2 / WHEEL_TICK_HEIGHT)) + i) % WHEEL.length];
      drawWheelTick(wheelTick, Math.ceil((i - subsectionOffset) * WHEEL_TICK_HEIGHT));
    }
  }

  const marqueeOffset = Math.floor(os.epoch('utc') / 1000);
  for (let y = 2; y < h; y++) {
    const color = y === h / 2
      ? colors.white
      : (y + marqueeOffset) % 3 === 0 ? colors.blue : colors.black;
    paintutils.drawPixel(1, y, color);
    paintutils.drawPixel(w, y, color);
  }
  for (let x = 2; x < w; x++) {
    paintutils.drawPixel(x, 1, (x + marqueeOffset) % 3 === 0 ? colors.blue : colors.black);
    paintutils.drawPixel(x, h, (x + marqueeOffset) % 3 === 1 ? colors.blue : colors.black);
  }
});
