export const HOSTNAME = `job-server-${os.computerID()}`;

export const TSH_PROTOCOL_NAME = 'tsh';
export const JOBS_PROTOCOL_NAME = 'tsh:jobs';
export const TURTLE_PROTOCOL_NAME = 'tsh:turtle';
export const TURTLE_REGISTRY_PROTOCOL_NAME = 'tsh:turtle-registry';

export enum JobServerCommand {
  LIST = 'LIST',
  DELETE = 'DELETE',
  GET = 'GET',
  UPDATE = 'UPDATE',
  ADD = 'ADD',
}
