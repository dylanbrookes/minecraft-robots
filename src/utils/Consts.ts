export const HOSTNAME = `job-server-${os.computerID()}`;

export const TSH_PROTOCOL_NAME = 'tsh';
export const TURTLE_PROTOCOL_NAME = 'tsh:turtle';
export const TURTLE_CONTROL_PROTOCOL_NAME = 'tsh:turtle-control';
export const JOB_REGISTRY_PROTOCOL_NAME = 'tsh:job-registry';
export const RESOURCE_REGISTRY_PROTOCOL_NAME = 'tsh:resource-registry';

export enum JobRegistryCommand {
  LIST = 'LIST',
  DELETE = 'DELETE',
  DELETE_DONE = 'DELETE_DONE',
  GET = 'GET',
  UPDATE = 'UPDATE',
  ADD = 'ADD',
  CANCEL = 'CANCEL',
  RETRY = 'RETRY',
  JOB_DONE = 'JOB_DONE',
  JOB_FAILED = 'JOB_FAILED',
}

export enum JobRegistryEvent {
  JOB_DONE = 'JobRegistry:job_done',
  JOB_FAILED = 'JobRegistry:job_failed',
  JOB_CANCELLED = 'JobRegistry:job_cancelled',
}

export enum TurtleControlEvent {
  TURTLE_IDLE = 'TurtleControl:turtle_idle',
  TURTLE_OFFLINE = 'TurtleControl:turtle_offline',
}

export enum ResourceRegistryCommand {
  LIST = 'LIST',
  GET = 'GET',
  FIND = 'FIND',
  ADD = 'ADD',
  DELETE = 'DELETE',
  UPDATE = 'UPDATE',
}