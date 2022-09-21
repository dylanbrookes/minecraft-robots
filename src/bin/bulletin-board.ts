import '/require_stub';
import BulletinBoardUI from '../utils/ui/BulletinBoardUI';
import { EventLoop } from '../utils/EventLoop';
import TaskStore, { TaskStatus } from '../utils/stores/TaskStore';

const taskStore = new TaskStore();

const monitor = peripheral.find<peripheral.Monitor>("monitor");
if (!monitor) {
  console.log("Failed to find a monitor");
} else {
  const ui = new BulletinBoardUI(monitor, taskStore);
  ui.register();
}

const VALID_STATUSES = [TaskStatus.DONE, TaskStatus.IN_PROGRESS, TaskStatus.TODO];
const printPrompt = () => term.write('> ');

function handleCommand(cmd: string, ...params: string[]) {
  switch (cmd) {
    case 'add':
      taskStore.add({
        description: params[0],
        status: TaskStatus.TODO,
      });
      console.log("Added new task");
      break;
    case 'remove':
      taskStore.remove(parseInt(params[0]));
      console.log("Removed task");
      break;
    case 'update':
      const status = params[1] as TaskStatus;
      if (!VALID_STATUSES.includes(status)) {
        console.log(`Invalid status ${status}, must be one of ${textutils.serialize(VALID_STATUSES)}`);
      }
      taskStore.update(parseInt(params[0]), { status });
      console.log("Updated task");
      break;
    default:
      console.log(`Unknown command "${cmd}"`);
      return;
  }
  taskStore.save();
}

term.clear();
term.setCursorPos(0, 0);
let line = '';
EventLoop.on('char', (char: string) => {
  term.write(char);
  line += char;
});

EventLoop.on('key', (key: string) => {
  // @ts-ignore
  if (key === keys.enter) {
    print(); // newline
    const [cmd, ...params] = line.split(' ');
    handleCommand(cmd, ...params);
    printPrompt();
    line = '';
    // @ts-ignore
  } else if (key === keys.backspace) {
    if (line.length === 0) return;
    const [x, y] = term.getCursorPos();
    term.setCursorPos(x - 1, y);
    term.write(' ');
    term.setCursorPos(x - 1, y);
    line = line.slice(0, line.length - 1);
  }
});

console.log([
  'Commands:',
  'add <description>',
  'remove <id>',
  'update <id> <status>'
].join('\n'));
printPrompt();

EventLoop.run();
