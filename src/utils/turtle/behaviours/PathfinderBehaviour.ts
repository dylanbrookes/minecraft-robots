import { inspectHasTags, ItemTags } from "../../ItemTags";
import { Heading, HEADING_ORDER, HEADING_TO_XZ_VEC, LocationMonitor, LocationMonitorStatus } from "../../LocationMonitor";
import Logger from "../../Logger";
import PriorityQueue from "../../PriorityQueue";
import { cartesianDistance, positionsEqual, serializePosition, TurtlePosition } from "../Consts";
import { TurtleController } from "../TurtleController";
import { TurtleBehaviour, TurtleBehaviourBase } from "./TurtleBehaviour";

const neighbors = (p: TurtlePosition): TurtlePosition[] => [
  ...HEADING_ORDER.map<TurtlePosition>((h) => [
    p[0] + HEADING_TO_XZ_VEC[h][0],
    p[1],
    p[2] + HEADING_TO_XZ_VEC[h][1],
  ]),
  [p[0], p[1] + 1, p[2]],
  [p[0], p[1] - 1, p[2]],
];

const buildPathFromNode = (p: TurtlePosition, cameFrom: LuaMap<string, TurtlePosition>): TurtlePosition[] => {
  const path: TurtlePosition[] = [p];
  // eslint-disable-next-line no-constant-condition
  while (true) {
    const lastPos = path[path.length - 1];
    const pp = cameFrom.get(serializePosition(lastPos));
    // Logger.debug('next:', pp && serializePosition(pp), 'current:', lastPos);
    if (!pp || positionsEqual(lastPos, pp)) break; // will be equal for starting pos
    path.push(pp);
  }
  return path;
}
// sorta brute force but it works
const getTargetHeading = (a: TurtlePosition, b: TurtlePosition): Heading => {
  for (const heading of HEADING_ORDER) {
    const appliedPos: TurtlePosition = [
      a[0] + HEADING_TO_XZ_VEC[heading][0],
      a[1],
      a[2] + HEADING_TO_XZ_VEC[heading][1],
    ];
    if (positionsEqual(appliedPos, b)) return heading;
  }
  throw new Error(`Failed to get target heading from ${serializePosition(a)} to ${serializePosition(b)}`);
}

export class PathfinderBehaviour extends TurtleBehaviourBase implements TurtleBehaviour {
  private static EPSILON = 5; // cost heuristic multiplier, incentivizes nearest points first to prevent backtracking

  readonly name = 'pathfinding';
  private nodeQueue: PriorityQueue<TurtlePosition>;
  private cameFrom = new LuaMap<string, TurtlePosition>();
  private gScore = new LuaMap<string, number>();
  private heuristicOffsets = new LuaMap<string, number>(); // used to adjust cost heuristic
  private initialized = false;

  constructor(
    private targetPos: TurtlePosition,
    readonly priority = 1,
  ) {
    super();
    this.nodeQueue = new PriorityQueue((a, b) => this.costHeuristic(b) > this.costHeuristic(a));
  }

  private costHeuristic(pos: TurtlePosition) {
    return cartesianDistance(pos, this.targetPos) + (this.heuristicOffsets.get(serializePosition(pos)) || 0);
  }

  onStart() {
    Logger.info("pathfinder onStart")
  }

  onResume() {
    Logger.info("Restarting pathfinder");
    this.initialized = false;
    this.nodeQueue.clear();
    this.cameFrom = new LuaMap<string, TurtlePosition>();
    this.gScore = new LuaMap<string, number>();
  }

  step(): boolean | void {
    const currentPos = LocationMonitor.position;
    if (!currentPos) {
      Logger.info("Skipping pathfinding, current location status is", LocationMonitor.status);
      return;
    }
    if (LocationMonitor.status !== LocationMonitorStatus.ACQUIRED) {
      // Maybe this should be implemented as a heading finder behaviour
      // heading is required
      const success = TurtleController.forward(1, false);
      if (!success) TurtleController.turnLeft();
      return;
    }

    if (positionsEqual(currentPos, this.targetPos)) {
      Logger.info("Done pathfinding to", serializePosition(this.targetPos));
      return true;
    }

    const currentPosKey = serializePosition(currentPos);
    if (!this.initialized) {
      this.initialized = true;
      this.nodeQueue.push(currentPos);
      this.cameFrom.set(currentPosKey, currentPos);
      this.gScore.set(currentPosKey, 0);
    }

    // Logger.debug(`current pos: ${currentPosKey}`);
    let bestNode = this.nodeQueue.peek();
    if (bestNode && positionsEqual(bestNode, currentPos)) {
      this.nodeQueue.pop(); // remove it since we're here
      // explore neighbors
      // Logger.debug("exploring neighbors");
      const currentGScore = this.gScore.get(currentPosKey);
      if (typeof currentGScore !== 'number') throw new Error('missing gscore');

      for (const neighbor of neighbors(currentPos)) {
        const neighborKey = serializePosition(neighbor);
        const tentativeGScore = currentGScore + 1;
        const neighbourGScore = this.gScore.get(neighborKey);
        const known = typeof neighbourGScore === 'number';
        if (!known || tentativeGScore < neighbourGScore) {
          // replace cameFrom if we find a better route (lower gscore)
          this.cameFrom.set(neighborKey, currentPos);
          this.gScore.set(neighborKey, tentativeGScore);
          if (!known) {
            // Logger.debug(`${neighborKey} is new`)
            this.nodeQueue.push(neighbor);
          }
        }
      }
    }
    
    bestNode = this.nodeQueue.peek();
    if (bestNode !== undefined) {
      // Logger.debug(`Travelling to best node: ${serializePosition(bestNode)}`);
      // visit bestNode by following cameFrom tree
      // need to find a common ancestor in the cameFrom tree b/w the currentPos and bestNode
      const bestNodePath = buildPathFromNode(bestNode, this.cameFrom);
      // Logger.debug(`best node path: ${textutils.serialize(bestNodePath)}`);
      // for (const [k, v] of this.cameFrom) Logger.debug(k, v);
      const currentPosIdx = bestNodePath.findIndex(p => positionsEqual(p, currentPos));
      let nextPos: TurtlePosition;
      if (currentPosIdx !== -1) {
        // the current position is a point in the path to best node so travel forward along bestNodePath
        if (currentPosIdx === 0) throw new Error("oh no 675438967");
        nextPos = bestNodePath[currentPosIdx - 1];
      } else {
        // backtrack to the previous position
        const pos = this.cameFrom.get(currentPosKey);
        if (!pos) throw new Error(`Missing pos ${currentPosKey} in cameFrom`);
        nextPos = pos;
      }

      const nextPosIsBestNode = positionsEqual(nextPos, bestNode);
      const nextPosKey = serializePosition(nextPos);
      // Logger.debug(`moving to ${serializePosition(nextPos)} (${nextPosIsBestNode})`);
      // move to next pos
      if (cartesianDistance(currentPos, nextPos) !== 1) throw new Error(`Next pos ${nextPosKey} is not adjacent to current pos ${currentPosKey}`);
      let ranIntoTurtle = false;
      if (nextPos[1] > currentPos[1]) {
        const [occupied, info] = turtle.inspectUp();
        // just wait if occupied by another turtle
        if (nextPosIsBestNode && occupied) {
          // Logger.debug('space is occupied, removing best node');
          this.nodeQueue.pop();
          ranIntoTurtle = inspectHasTags(info, ItemTags.turtle);
        } else if (!TurtleController.up(1, false)) {
          Logger.warn("failed to move up, sleeping for 5 seconds");
          sleep(5);
        }
      } else if (nextPos[1] < currentPos[1]) {
        const [occupied, info] = turtle.inspectDown();
        if (nextPosIsBestNode && occupied) {
          // Logger.debug('space is occupied, removing best node');
          this.nodeQueue.pop();
          ranIntoTurtle = inspectHasTags(info, ItemTags.turtle);
        } else if (!TurtleController.down(1, false)) {
          Logger.warn("failed to move up, sleeping for 5 seconds");
          sleep(5);
        }
      } else {
        const targetHeading = getTargetHeading(currentPos, nextPos);
        Logger.debug(`moving ${targetHeading}`);
        TurtleController.rotate(targetHeading);
        const [occupied, info] = turtle.inspect();
        if (nextPosIsBestNode && occupied) {
          // Logger.debug('space is occupied, removing best node');
          this.nodeQueue.pop();
          ranIntoTurtle = inspectHasTags(info, ItemTags.turtle);
        } else if (!TurtleController.forward(1, false)) {
          Logger.warn("failed to move forward, sleeping for 5 seconds");
          sleep(5);
        }
      }

      if (ranIntoTurtle) {
        Logger.info("Ran into another turtle, will check again");
        this.heuristicOffsets.set(nextPosKey, (this.heuristicOffsets.get(nextPosKey) || 0) + 1); // deincentivize the node so that it will try a different route
        this.nodeQueue.push(nextPos);
      }
    } else {
      throw new Error(`Failed to find path to ${serializePosition(this.targetPos)}`);
    }
  }
}
