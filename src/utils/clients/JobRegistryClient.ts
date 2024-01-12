import { JobRegistryCommand, JOB_REGISTRY_PROTOCOL_NAME } from "../Consts";
import Logger from "../Logger";
import { JobRecord } from "../stores/JobStore";
import { JobType } from "../turtle/Consts";

export class JobRegistryClient {
  constructor(private hostId: number) {}

  private call<T>(cmd: JobRegistryCommand, args: object = {}): T {
    rednet.send(this.hostId, {
      cmd,
      ...args,
    }, JOB_REGISTRY_PROTOCOL_NAME);
  
    Logger.debug('Sent cmd, waiting for resp...');
    const [pid, message] = rednet.receive(JOB_REGISTRY_PROTOCOL_NAME, 3);
    if (!pid) throw new Error("No response to command " + cmd);
    return message;
  }

  list(): JobRecord[] {
    const resp = this.call<string>(JobRegistryCommand.LIST);
    return textutils.unserialize(resp);
  }

  getById(id: number): JobRecord | undefined {
    return this.call<JobRecord>(JobRegistryCommand.GET, { id });
  }

  updateById(id: number, changes: Partial<JobRecord>): JobRecord {
    return this.call<JobRecord>(JobRegistryCommand.UPDATE, { id, changes });
  }

  deleteById(id: number): boolean {
    return this.call<boolean>(JobRegistryCommand.DELETE, { id });
  }

  add(type: JobType, args: unknown[]): JobRecord {
    return this.call<JobRecord>(JobRegistryCommand.ADD, { type, args });
  }

  cancel(id: number): boolean {
    return this.call<{ ok: boolean }>(JobRegistryCommand.CANCEL, { id }).ok;
  }

  retry(id: number): boolean {
    return this.call<{ ok: boolean }>(JobRegistryCommand.RETRY, { id }).ok;
  }

  jobDone(id: number) {
    return this.call(JobRegistryCommand.JOB_DONE, { id });
  }

  jobFailed(id: number, error: unknown) {
    return this.call(JobRegistryCommand.JOB_FAILED, { id, error });
  }

  deleteDone() {
    return this.call(JobRegistryCommand.DELETE_DONE);
  }

  deleteAll() {
    return this.call(JobRegistryCommand.DELETE_ALL);
  }
}
