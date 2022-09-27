import { ResourceRegistryClient } from "../../clients/ResourceRegistryClient";
import { RESOURCE_REGISTRY_PROTOCOL_NAME } from "../../Consts";
import { findProtocolHostId } from "../../findProtocolHostId";
import { LocationMonitor } from "../../LocationMonitor";
import Logger from "../../Logger";
import { ResourceRecord } from "../../stores/ResourceStore";
import { positionsEqual, serializePosition, TurtlePosition } from "../Consts";
import { PathfinderBehaviour } from "./PathfinderBehaviour";
import { TurtleBehaviour, TurtleBehaviourBase } from "./TurtleBehaviour";

//
export class ResupplyBehaviour extends TurtleBehaviourBase implements TurtleBehaviour {
  readonly name: string;

  constructor(
    private resourceTags: string[],
    private count?: number,
    readonly priority: number = 1,
  ) {
    super();
    this.name = `resupply:${resourceTags.join('|')}`;
  }

  private resource: ResourceRecord | void = undefined;
  private pathfinderBehaviour: PathfinderBehaviour | void = undefined;

  step(): boolean | void {
    if (!LocationMonitor.position) {
      Logger.info("Waiting for position");
      return;
    }
    if (!this.resource) {
      // TODO: Cache protocol host ids?
      const resourceRegistryHostId = findProtocolHostId(RESOURCE_REGISTRY_PROTOCOL_NAME);
      if (!resourceRegistryHostId) throw new Error('Failed to find resource registry host id');
      const resourceClient = new ResourceRegistryClient(resourceRegistryHostId);
      const { resource } = resourceClient.find(this.resourceTags, LocationMonitor.position);
      if (!resource) throw new Error(`Failed to find resource with tags ${this.resourceTags.join(',')}`);
      this.resource = resource;
      Logger.info('Located resource', this.resource);
    }

    if (positionsEqual(LocationMonitor.position, this.resource.position)) {
      // Logger.info("reached supply target");
      const [success, reason] = turtle.suckDown(this.count);
      if (success) {
        // Logger.info("Got some items", reason);
        return true;
      } else {
        Logger.info("Failed to get items", reason);
      }
    } else {
      if (!this.pathfinderBehaviour) {
        Logger.info("Travelling to supply target", serializePosition(this.resource.position));
        this.pathfinderBehaviour = new PathfinderBehaviour(this.resource.position);
      }
      this.pathfinderBehaviour.step();
    }
  }
}
