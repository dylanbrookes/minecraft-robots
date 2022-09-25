enum LogLevel {
  DEBUG = 'DEBUG',
  INFO = 'INFO',
  WARN = 'WARN',
  ERROR = 'ERROR',
}

const LOG_LEVEL_SHORTCODES = {
  [LogLevel.DEBUG]: '[D]',
  [LogLevel.INFO]: '[I]',
  [LogLevel.WARN]: '[W]',
  [LogLevel.ERROR]: '[E]',
}

const formatArgs = (args: unknown[]): string => args.map(a => typeof a === 'string' ? a : textutils.serialize(a, { compact: true })).join(' ');
const levelColor = (level: LogLevel) => {
  switch (level) {
    case LogLevel.WARN:
      return colors.yellow;
    case LogLevel.ERROR:
      return colors.red;
    default:
      return colors.white;
  }
}
const printLog = (line: string, level: LogLevel) => {
  let oColor = term.getTextColor();
  let log = line;
  if (term.isColor()) {
    term.setTextColor(levelColor(level));
  } else {
    if ([LogLevel.WARN, LogLevel.ERROR].includes(level)) {
      log = `[${level}] ${line}`;
    }
  }

  print(log);
  term.setTextColor(oColor);
}

class __Logger__ {
  private readonly id = os.epoch();
  private readonly file: WriteHandle;
  constructor(logDir: string, fileName?: string) {
    const filePath = `${logDir}/${fileName || `${this.id}.log`}`;
    const [file, err] = fs.open(filePath, "a");
    if (!file) throw new Error(`Failed to open ${filePath}: ${err}`);
    this.file = file;
    this.debug(`Logger ${this.id} created`);
  }

  private writeLine(line: string, level: LogLevel) {
    if (level !== LogLevel.DEBUG /* TODO: some flag to enable debug logging */) {
      printLog(line, level);
    }
    const log = `${LOG_LEVEL_SHORTCODES[level]} ${line}`;
    this.file.writeLine(log);
    this.file.flush();
  }

  debug(...args: unknown[]) {
    this.writeLine(formatArgs(args), LogLevel.DEBUG);
  }

  info(...args: unknown[]) {
    this.writeLine(formatArgs(args), LogLevel.INFO);
  }

  warn(...args: unknown[]) {
    this.writeLine(formatArgs(args), LogLevel.WARN);
  }

  error(...args: unknown[]) {
    this.writeLine(formatArgs(args), LogLevel.ERROR);
  }
}

const Logger = new __Logger__('/log', 'default.log'); // omit file name for random log file naming
export default Logger;
