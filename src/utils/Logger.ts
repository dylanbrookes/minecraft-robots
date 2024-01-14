import env from "./env";

enum LogLevel {
  INTERNAL = 'INTERNAL',
  DEBUG = 'DEBUG',
  INFO = 'INFO',
  WARN = 'WARN',
  ERROR = 'ERROR',
}

const LOG_LEVEL_SHORTCODES = {
  [LogLevel.INTERNAL]: '[*]',
  [LogLevel.DEBUG]: '[D]',
  [LogLevel.INFO]: '[I]',
  [LogLevel.WARN]: '[W]',
  [LogLevel.ERROR]: '[E]',
}

const LOG_LEVEL_ORDER = [
  LogLevel.INTERNAL,
  LogLevel.DEBUG,
  LogLevel.INFO,
  LogLevel.WARN,
  LogLevel.ERROR,
];

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
const printLog = (line: string, level: LogLevel, termRedirect?: Redirect) => {
  const oTerm = termRedirect && term.redirect(termRedirect);
  const oColor = term.getTextColor();
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
  term.redirect(oTerm);
}

class __Logger__ {
  private readonly id = os.epoch();
  private readonly file: WriteHandle;
  private readonly logLevel: LogLevel; // level that goes to stdout
  private readonly fileLogLevel: LogLevel; // level that goes to file
  private termRedirect?: Redirect; // used to set a target term redirect for stdout
  constructor(logDir: string, fileName?: string) {
    const filePath = `${logDir}/${fileName || `${this.id}.log`}`;
    const [file, err] = fs.open(filePath, "a");
    if (!file) throw new Error(`Failed to open ${filePath}: ${err}`);
    this.file = file;
    
    if (`LOG_LEVEL` in env) {
      const idx = LOG_LEVEL_ORDER.indexOf(env.LOG_LEVEL as LogLevel);
      if (idx === -1) throw new Error(`Invalid log level ${env.LOG_LEVEL}`);
      this.logLevel = env.LOG_LEVEL as LogLevel;
    } else {
      this.logLevel = LogLevel.INFO;
    }

    if (`FILE_LOG_LEVEL` in env) {
      const idx = LOG_LEVEL_ORDER.indexOf(env.FILE_LOG_LEVEL as LogLevel);
      if (idx === -1) throw new Error(`Invalid log level ${env.FILE_LOG_LEVEL}`);
      this.fileLogLevel = env.FILE_LOG_LEVEL as LogLevel;
    } else {
      this.fileLogLevel = LogLevel.DEBUG;
    }

    this.writeLine(`Logger ${this.id} created with log level ${this.logLevel}/${this.fileLogLevel}`, LogLevel.INTERNAL);
  }

  private writeLine(line: string, level: LogLevel) {
    if (LOG_LEVEL_ORDER.indexOf(level) >= LOG_LEVEL_ORDER.indexOf(this.logLevel)) {
      printLog(line, level, this.termRedirect);
    }
    if ('FILE_LOGGING' in env && LOG_LEVEL_ORDER.indexOf(level) >= LOG_LEVEL_ORDER.indexOf(this.fileLogLevel)) { 
      const log = `${LOG_LEVEL_SHORTCODES[level]} ${line}`;
      this.file.writeLine(log);
      this.file.flush();
    }
  }

  setTermRedirect(termRedirect?: Redirect) {
    this.termRedirect = termRedirect;
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
