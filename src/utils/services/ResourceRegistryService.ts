import { HOSTNAME, ResourceRegistryCommand, RESOURCE_REGISTRY_PROTOCOL_NAME } from "../Consts";
import { EventLoop } from "../EventLoop";
import Logger from "../Logger";
import { ResourceRecord, ResourceStore } from "../stores/ResourceStore";
import { cartesianDistance } from "../turtle/Consts";

export default class ResourceRegistryService {
  private registered = false;

  constructor(private resourceStore: ResourceStore) {}

  // expects rednet to already be open
  register() {
    if (this.registered) throw new Error("ResourceRegistryService is already registered");
    this.registered = true;

    Logger.info("Registering Resource Registry Service");
    rednet.host(RESOURCE_REGISTRY_PROTOCOL_NAME, HOSTNAME);
    EventLoop.on('rednet_message', (sender: number, message: unknown, protocol: string | null) => {
      if (protocol === RESOURCE_REGISTRY_PROTOCOL_NAME) {
        this.onMessage(message, sender);
      }
      return false;
    });
  }

  private onMessage(message: unknown, sender: number) {
    Logger.info("Got ResourceRegistryService message from sender", sender, textutils.serialize(message));
    if (typeof message !== 'object' || message === null || !('cmd' in message)) {
      Logger.error("idk what to do with this", message);
      return;
    }

    const { cmd, ...params } = message;

    switch (cmd) {
      case ResourceRegistryCommand.LIST: {
        rednet.send(sender, this.resourceStore.toString(), RESOURCE_REGISTRY_PROTOCOL_NAME);
      } break;
      case ResourceRegistryCommand.GET: {
        const { id } = params as Pick<ResourceRecord, 'id'>;
        rednet.send(sender, this.resourceStore.getById(id), RESOURCE_REGISTRY_PROTOCOL_NAME);
      } break;
      case ResourceRegistryCommand.DELETE: {
        const { id } = params as Pick<ResourceRecord, 'id'>;
        const result = this.resourceStore.removeById(id);
        if (result) {
          this.resourceStore.save();
        }
        rednet.send(sender, result, RESOURCE_REGISTRY_PROTOCOL_NAME);
      } break;
      case ResourceRegistryCommand.UPDATE: {
        const { id, ...changes } = params as Pick<ResourceRecord, 'id'> & Partial<ResourceRecord>;
        const result = this.resourceStore.updateById(id, changes);
        if (result) {
          this.resourceStore.save();
        }
        rednet.send(sender, result, RESOURCE_REGISTRY_PROTOCOL_NAME);
      } break;
      case ResourceRegistryCommand.ADD: {
        const { tags, position } = params as Pick<ResourceRecord, 'tags' | 'position'>;
        const result = this.resourceStore.add({ tags, position });
        this.resourceStore.save();
        rednet.send(sender, result, RESOURCE_REGISTRY_PROTOCOL_NAME);
      } break;
      case ResourceRegistryCommand.FIND: {
        // finds closest resource to position matching tags
        const { tags, position } = params as Pick<ResourceRecord, 'tags' | 'position'>;
        const resources = this.resourceStore
          .select(({ tags: _tags }) => tags.every(t => _tags.includes(t)))
          .sort((a, b) => cartesianDistance(a.position, position) - cartesianDistance(b.position, position));
        Logger.info("Resources:", resources);
        if (!resources.length) {
          rednet.send(sender, { resource: null }, RESOURCE_REGISTRY_PROTOCOL_NAME);
        } else {
          rednet.send(sender, { resource: resources[0] }, RESOURCE_REGISTRY_PROTOCOL_NAME);
        }
      } break;
      default:
        Logger.error("invalid ResourceRegistryService command", message.cmd);
    }
  }
}
