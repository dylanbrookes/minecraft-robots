import Logger from "../Logger";
import { TurtlePosition } from "../turtle/Consts";

export type ResourceRecord = {
  id: number,
  tags: string[],
  position: TurtlePosition,
}

export class ResourceStore implements Iterable<ResourceRecord> {
  static DEFAULT_STORE_FILE = '/.resourcestore';

  private maxId: number = -1;
  private resources: Map<number, ResourceRecord>;

  constructor(private storeFile: string = ResourceStore.DEFAULT_STORE_FILE) {
    [this.resources, this.maxId] = ResourceStore.LoadStoreFile(this.storeFile);
    Logger.info("N resources:", this.resources.size);
    Logger.info("Max ID:", this.maxId);
  }

  [Symbol.iterator](): IterableIterator<ResourceRecord> {
    return this.resources.values();
  }
  select(filter: (v: ResourceRecord) => boolean = () => true): ResourceRecord[] {
    return [...this.resources.values()].filter(filter);
  }

  private static LoadStoreFile(storeFile: string): [Map<number, ResourceRecord>, number] {
    const resources = new Map<number, ResourceRecord>();
    let maxId = 0;

    if (!fs.exists(storeFile)) {
      Logger.debug("Starting without store file");
      return [resources, maxId];
    }

    const [handle, err] = fs.open(storeFile, 'r');
    if (!handle) {
      throw new Error("Failed to open storeFile " + storeFile + " error: " + err);
    }

    let line: string | undefined;
    while (line = handle.readLine()) {
      const resource = textutils.unserialize(line) as ResourceRecord;
      if (typeof resource.id !== 'number') throw new Error("Invalid resource parsed from: " + line);

      resources.set(resource.id, resource);
      if (resource.id > maxId) maxId = resource.id;
    }

    return [resources, maxId];
  }

  getById(id: number): ResourceRecord | undefined {
    return this.resources.get(id);
  }

  removeById(id: number): boolean {
    return this.resources.delete(id);
  }

  updateById(id: number, changes: Omit<Partial<ResourceRecord>, 'id'>): ResourceRecord | undefined {
    const resource = this.resources.get(id);
    if (!resource) return undefined;

    Object.assign(resource, changes);

    return resource;
  }

  list() {
    Logger.info("Resources:")
    for (const resource of this.resources.values()) {
      Logger.info(textutils.serializeJSON(resource, true));
    }
  }

  add(resourceRecord: Pick<ResourceRecord, 'tags' | 'position'>) {
    const resource: ResourceRecord = {
      id: ++this.maxId,
      ...resourceRecord,
    };
    this.resources.set(resource.id, resource);

    return resource;
  }

  save() {
    if (fs.exists(this.storeFile)) {
      Logger.debug("Overwriting store file", this.storeFile);
    }

    const [handle, err] = fs.open(this.storeFile, 'w');
    if (!handle) {
      throw new Error("Failed to open storeFile " + this.storeFile + " for writing, error: " + err);
    }

    for (const resource of this.resources.values()) {
      handle.writeLine(textutils.serialize(resource, { compact: true }));
    }
    handle.flush();
    handle.close();
    Logger.debug("Saved to storefile", this.storeFile);
  }

  toString(): string {
    const resources = [];
    for (const resource of this.resources.values()) resources.push(resource);
    return textutils.serialize(resources, { compact: true });
  }
}
