import { HOSTNAME, JobRegistryCommand, JobRegistryEvent, JOB_REGISTRY_PROTOCOL_NAME } from "../Consts";
import { EventLoop } from "../EventLoop";
import Logger from "../Logger";
import { JobStatus, JobStore } from "../stores/JobStore";

export default class JobRegistryService {
  private registered = false;

  constructor(private jobStore: JobStore) {}

  // expects rednet to already be open
  register() {
    if (this.registered) throw new Error("JobRegistryService is already registered");
    this.registered = true;

    Logger.info("Registering Job Registry Service");
    rednet.host(JOB_REGISTRY_PROTOCOL_NAME, HOSTNAME);
    EventLoop.on('rednet_message', (sender: number, message: any, protocol: string | null) => {
      if (protocol === JOB_REGISTRY_PROTOCOL_NAME) {
        this.onMessage(message, sender);
      }
      return false;
    });
  }

  private onMessage(message: any, sender: number) {
    Logger.info("Got JobRegistryService message from sender", sender, textutils.serialize(message));
    if (!('cmd' in message)) {
      Logger.error("idk what to do with this", message);
      return;
    }

    const { cmd, ...params } = message;

    switch (cmd) {
      case JobRegistryCommand.LIST: {
        rednet.send(sender, this.jobStore.toString(), JOB_REGISTRY_PROTOCOL_NAME);
      } break;
      case JobRegistryCommand.GET: {
        const { id } = params;
        rednet.send(sender, this.jobStore.getById(id), JOB_REGISTRY_PROTOCOL_NAME);
      } break;
      case JobRegistryCommand.DELETE: {
        const { id } = params;
        const result = this.jobStore.removeById(id);
        if (result) {
          this.jobStore.save();
        }
        rednet.send(sender, result, JOB_REGISTRY_PROTOCOL_NAME);
      } break;
      case JobRegistryCommand.DELETE_DONE: {
        let count = 0;
        for (const { id, status } of this.jobStore) {
          if (status === JobStatus.DONE) {
            this.jobStore.removeById(id);
            count++;
          }
        }
        if (count > 0) {
          this.jobStore.save();
        }
        Logger.info(`Removed ${count} done jobs`);
        rednet.send(sender, { ok: true, count }, JOB_REGISTRY_PROTOCOL_NAME);
      } break;
      case JobRegistryCommand.UPDATE: {
        const { id, ...changes } = params;
        const result = this.jobStore.updateById(id, changes);
        if (result) {
          this.jobStore.save();
        }
        rednet.send(sender, result, JOB_REGISTRY_PROTOCOL_NAME);
      } break;
      case JobRegistryCommand.ADD: {
        const { type, args } = params;
        const result = this.jobStore.add({ type, args });
        this.jobStore.save();
        rednet.send(sender, result, JOB_REGISTRY_PROTOCOL_NAME);
      } break;
      case JobRegistryCommand.JOB_DONE: {
        const { id } = params;
        this.jobStore.updateById(id, {
          status: JobStatus.DONE,
        });
        this.jobStore.save();
        EventLoop.emit(JobRegistryEvent.JOB_DONE, id);
        rednet.send(sender, { ok: true }, JOB_REGISTRY_PROTOCOL_NAME);
      } break;
      case JobRegistryCommand.JOB_FAILED: {
        const { id, error } = params;
        this.jobStore.updateById(id, {
          status: JobStatus.FAILED,
          error,
        });
        this.jobStore.save();
        Logger.error(`Job ${id} failed:`, error);
        EventLoop.emit(JobRegistryEvent.JOB_FAILED, id);
        rednet.send(sender, { ok: true }, JOB_REGISTRY_PROTOCOL_NAME);
      } break;
      case JobRegistryCommand.CANCEL: {
        const { id } = params;
        this.jobStore.updateById(id, { status: JobStatus.CANCELLED });
        this.jobStore.save();
        Logger.warn(`Cancelled job ${id}`);
        EventLoop.emit(JobRegistryEvent.JOB_CANCELLED, id);
        rednet.send(sender, { ok: true }, JOB_REGISTRY_PROTOCOL_NAME);
      } break;
      case JobRegistryCommand.RETRY: {
        const { id } = params;
        Logger.info(`Retrying job ${id}`);
        const job = this.jobStore.getById(id);
        if (!job || job.status !== JobStatus.FAILED) {
          rednet.send(sender, { ok: false }, JOB_REGISTRY_PROTOCOL_NAME);
          return;
        }
        this.jobStore.updateById(id, { status: JobStatus.PENDING });
        this.jobStore.save();
        rednet.send(sender, { ok: true }, JOB_REGISTRY_PROTOCOL_NAME);
      }
      default:
        Logger.error("invalid JobRegistryService command", message.cmd);
    }
  }
}
