import '/require_stub';
import { ResourceRegistryCommand, RESOURCE_REGISTRY_PROTOCOL_NAME } from '../utils/Consts';
import { findProtocolHostId } from '../utils/findProtocolHostId';
import Logger from '../utils/Logger';
import { TurtlePosition } from '../utils/turtle/Consts';
import { ResourceRegistryClient } from '../utils/clients/ResourceRegistryClient';

const hostId = findProtocolHostId(RESOURCE_REGISTRY_PROTOCOL_NAME);
if (!hostId) {
  throw new Error('Could not find any job registry protocol hosts');
}

Logger.info(`Found host ID: ${hostId}`);
const resourceRegistryClient = new ResourceRegistryClient(hostId);

const [cmd, ...params] = [...$vararg];

switch(cmd.toUpperCase()) {
  case ResourceRegistryCommand.LIST:
    Logger.info(textutils.serialize(resourceRegistryClient.list()));
    break;
  case ResourceRegistryCommand.DELETE: {
    const id = parseInt(params[0]);
    Logger.info(resourceRegistryClient.deleteById(id));
  } break;
  case ResourceRegistryCommand.GET: {
    const id = parseInt(params[0]);
    Logger.info(resourceRegistryClient.getById(id));
  } break;
  case ResourceRegistryCommand.UPDATE: {
    throw new Error("Not implemented");
  } break;
  case ResourceRegistryCommand.ADD: {
    Logger.info("Locating...");
    const pos = gps.locate(3);
    if (!pos || !pos[0]) throw new Error("Failed to geolocate");
    const feetPos: TurtlePosition = [Math.floor(pos[0]), Math.floor(pos[1]) - 1, Math.floor(pos[2])];
    Logger.info(resourceRegistryClient.add({
      tags: params,
      position: feetPos,
    }));
  } break;
  case ResourceRegistryCommand.FIND: {
    Logger.info("Locating...");
    const pos = gps.locate(3);
    if (!pos || !pos[0]) throw new Error("Failed to geolocate");
    const feetPos: TurtlePosition = [Math.floor(pos[0]), Math.floor(pos[1]) - 1, Math.floor(pos[2])];
    Logger.info(resourceRegistryClient.find(params, feetPos));
  } break;
  default:
    throw new Error("Unknown command: " + cmd);
}
