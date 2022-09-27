import '/require_stub';
import { JobRegistryCommand, JOB_REGISTRY_PROTOCOL_NAME } from '../utils/Consts';
import { findProtocolHostId } from '../utils/findProtocolHostId';
import { JobRegistryClient } from '../utils/clients/JobRegistryClient';
import Logger from '../utils/Logger';
import { JobType } from '../utils/turtle/Consts';
import { Heading } from '../utils/LocationMonitor';

const hostId = findProtocolHostId(JOB_REGISTRY_PROTOCOL_NAME);
if (!hostId) {
  throw new Error('Could not find any job registry protocol hosts');
}

Logger.info(`Found host ID: ${hostId}`);
const jobRegistryClient = new JobRegistryClient(hostId);

const [cmd, ...params] = [...$vararg];

switch(cmd.toUpperCase()) {
  case JobRegistryCommand.LIST:
    Logger.info(textutils.serialize(jobRegistryClient.list()));
    break;
  case JobRegistryCommand.DELETE: {
    const id = parseInt(params[0]);
    Logger.info(jobRegistryClient.deleteById(id));
  } break;
  case JobRegistryCommand.DELETE_DONE: {
    Logger.info(jobRegistryClient.deleteDone());
  } break;
  case JobRegistryCommand.GET: {
    const id = parseInt(params[0]);
    Logger.info(jobRegistryClient.getById(id));
  } break;
  case JobRegistryCommand.UPDATE: {
    throw new Error("Not implemented");
  } break;
  case JobRegistryCommand.ADD: {
    const [type, ...args] = params;
    Logger.info(jobRegistryClient.add(type as JobType, args));
  } break;
  case 'CLEAR': {
    const [headingParam, ...dimensions] = params;
    let heading = Heading.UNKNOWN;
    switch (headingParam.toLowerCase()) {
      case 'n':
      case 'north':
        heading = Heading.NORTH;
        break;
      case 's':
      case 'south':
        heading = Heading.SOUTH;
        break;
      case 'w':
      case 'west':
        heading = Heading.WEST;
        break;
      case 'e':
      case 'east':
        heading = Heading.EAST;
        break;
    }
  
    Logger.info("Locating...");
    const pos = gps.locate(3);
    if (!pos || !pos[0]) throw new Error("Failed to geolocate");
    const feetPos = [Math.floor(pos[0]), Math.floor(pos[1]) - 1, Math.floor(pos[2])];
  
    Logger.info("Clearing...", textutils.serialize(feetPos), heading, dimensions);
    Logger.info(jobRegistryClient.add(JobType.clear, [
      feetPos,
      heading,
      [parseInt(dimensions[0]), parseInt(dimensions[1]), parseInt(dimensions[2])],
    ]));
  } break;
  default:
    throw new Error("Unknown command: " + cmd);
}
