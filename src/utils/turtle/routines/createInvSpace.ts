import Logger from "../../Logger";

/**
 * Must be run async
 * @returns if an item was dropped
 */
export function createInvSpace(): boolean {
  for (let i = 1; i <= 16; i++) {
    const result = turtle.getItemDetail(i as turtle.TurtleSlot);
    if (!result) {
      return false;
    }
  }

  // need to empty a slot, just drop whatever is in the current slot
  const [dropped] = turtle.drop();
  Logger.warn("Dropped an item to clear space");
  return dropped;
}
