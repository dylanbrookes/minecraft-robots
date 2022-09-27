import { JobRegistryCommand, JOB_REGISTRY_PROTOCOL_NAME } from "../Consts";
import Logger from "../Logger";
import { JobRecord } from "../stores/JobStore";
import { JobType } from "../turtle/Consts";

export class JobRegistryClient {
  constructor(private hostId: number) {}

  private call(cmd: JobRegistryCommand, args: object = {}): any {
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
    const resp = this.call(JobRegistryCommand.LIST);
    return textutils.unserialize(resp);
  }

  getById(id: number): JobRecord | undefined {
    return this.call(JobRegistryCommand.GET, { id });
  }

  updateById(id: number, changes: Partial<JobRecord>): JobRecord {
    return this.call(JobRegistryCommand.UPDATE, { id, changes });
  }

  deleteById(id: number): boolean {
    return this.call(JobRegistryCommand.DELETE, { id });
  }

  add(type: JobType, args: any[]): JobRecord {
    return this.call(JobRegistryCommand.ADD, { type, args });
  }

  jobDone(id: number) {
    return this.call(JobRegistryCommand.JOB_DONE, { id });
  }

  deleteDone() {
    return this.call(JobRegistryCommand.DELETE_DONE);
  }
}
