import { TURTLE_PROTOCOL_NAME } from "../Consts";
import Logger from "../Logger";
import { TurtleCommands } from "../services/TurtleService";
import { JobRecord } from "../stores/JobStore";
import { TurtleStatusUpdate } from "../stores/TurtleStore";

export class TurtleClient {
  constructor(private hostId: number) {}

  private call<T>(cmd: TurtleCommands, params: object = {}, timeout = 3, assertResp: boolean = true, expectResponse = true): T | undefined {
    rednet.send(this.hostId, {
      cmd,
      params,
    }, TURTLE_PROTOCOL_NAME);
  
    if (expectResponse) {
      Logger.debug('Sent cmd, waiting for resp...');
      const [pid, message] = rednet.receive(TURTLE_PROTOCOL_NAME, timeout);
      if (!pid && assertResp) throw new Error("No response to command " + cmd);
      return message;
    }
    return undefined;
  }

  addJob(jobRecord: JobRecord) {
    const resp = this.call<{ ok: boolean }>(TurtleCommands.addJob, jobRecord);
    if (!resp?.ok) throw new Error(`Response didn't contain ok: ${textutils.serialize(resp)}`);
  }

  status(): TurtleStatusUpdate | undefined {
    const resp = this.call<{ ok: boolean, status: TurtleStatusUpdate }>(TurtleCommands.status, {}, 1, false);
    if (!resp?.ok) return undefined;
    return resp.status;
  }

  cancelJob(id: number) {
    this.call(TurtleCommands.cancelJob, { id }, 1, false, false);
  }
}
