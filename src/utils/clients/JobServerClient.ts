import { JobServerCommand, JOBS_PROTOCOL_NAME } from "../Consts";
import { JobRecord } from "../stores/JobStore";

export class JobServerClient {
  constructor(private hostId: number) {}

  private call(cmd: JobServerCommand, args: object = {}): any {
    rednet.send(this.hostId, textutils.serialize({
      cmd,
      ...args,
    }, { compact: true }), JOBS_PROTOCOL_NAME);
  
    console.log('Sent cmd, waiting for resp...');
    const [pid, message] = rednet.receive(JOBS_PROTOCOL_NAME, 3);
    if (!pid) throw new Error("No response to command " + cmd);
    return message;
  }

  list(): JobRecord[] {
    const resp = this.call(JobServerCommand.LIST);
    return textutils.unserialize(resp);
  }

  getById(id: number): JobRecord | undefined {
    return this.call(JobServerCommand.GET, { id });
  }

  updateById(id: number, changes: Partial<JobRecord>): JobRecord {
    return this.call(JobServerCommand.UPDATE, { id, changes });
  }

  deleteById(id: number): boolean {
    return this.call(JobServerCommand.DELETE, { id });
  }

  add(): JobRecord {
    return this.call(JobServerCommand.ADD);
  }
}
