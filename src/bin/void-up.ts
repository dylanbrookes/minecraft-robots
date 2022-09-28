import '/require_stub';
import { JobRegistryClient } from "../utils/clients/JobRegistryClient";
import { JOB_REGISTRY_PROTOCOL_NAME } from "../utils/Consts";
import { findProtocolHostId } from "../utils/findProtocolHostId";
import { Heading } from "../utils/LocationMonitor";
import Logger from "../utils/Logger";
import { JobType, TurtlePosition } from "../utils/turtle/Consts";

const hostId = findProtocolHostId(JOB_REGISTRY_PROTOCOL_NAME);
if (!hostId) {
  throw new Error('Could not find any job registry protocol hosts');
}

Logger.info(`Found host ID: ${hostId}`);
const jobRegistryClient = new JobRegistryClient(hostId);

const CHUNK_SIZE = 3;

const values = [...$vararg];
const [x0p, z0p, x1p, z1p, y, h] = values.map(v => parseInt(v));
const [x0, z0, x1, z1] = [Math.min(x0p, x1p), Math.min(z0p, z1p), Math.max(x0p, x1p), Math.max(z0p, z1p)];
const regions: [TurtlePosition, TurtlePosition /* dimensions */][] = [];
for (let x = x0; x <= x1; x += CHUNK_SIZE) {
  for (let z = z0; z <= z1; z += CHUNK_SIZE) {
    regions.push([[x, y, z], [Math.min(z1 - z + 1, CHUNK_SIZE), Math.min(x1 - x + 1, CHUNK_SIZE), h]]);
  }
}

Logger.info(`Submitting ${regions.length} jobs...`);
for (const [position, dimensions] of regions) {
  jobRegistryClient.add(JobType.clear, [
    position,
    Heading.EAST,
    dimensions,
  ]);
}
Logger.info("Done.");
