import { ResourceRegistryCommand, RESOURCE_REGISTRY_PROTOCOL_NAME } from "../Consts";
import Logger from "../Logger";
import { ResourceRecord } from "../stores/ResourceStore";
import { TurtlePosition } from "../turtle/Consts";

export class ResourceRegistryClient {
  constructor(private hostId: number) {}

  private call<T>(cmd: ResourceRegistryCommand, args: object = {}): T | undefined {
    rednet.send(this.hostId, {
      cmd,
      ...args,
    }, RESOURCE_REGISTRY_PROTOCOL_NAME);
  
    Logger.debug('Sent cmd, waiting for resp...');
    const [pid, message] = rednet.receive(RESOURCE_REGISTRY_PROTOCOL_NAME, 3);
    if (!pid) throw new Error("No response to command " + cmd);
    return message;
  }

  list(): ResourceRecord[] {
    const resp = this.call<string>(ResourceRegistryCommand.LIST);
    return textutils.unserialize(resp!);
  }

  getById(id: number): ResourceRecord | undefined {
    return this.call(ResourceRegistryCommand.GET, { id });
  }

  updateById(id: number, changes: Partial<ResourceRecord>): ResourceRecord {
    return this.call(ResourceRegistryCommand.UPDATE, { id, changes })!;
  }

  deleteById(id: number): boolean {
    return this.call(ResourceRegistryCommand.DELETE, { id })!;
  }

  add(resource: Pick<ResourceRecord, 'tags' | 'position'>): ResourceRecord {
    return this.call(ResourceRegistryCommand.ADD, resource)!;
  }

  find(tags: string[], position: TurtlePosition): { resource: ResourceRecord | null } {
    return this.call(ResourceRegistryCommand.FIND, { tags, position })!;
  }
}
