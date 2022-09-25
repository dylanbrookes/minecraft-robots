import Logger from "../../Logger";

export function refuel(): boolean {
  Logger.info("Refueling");
  const startSlot = turtle.getSelectedSlot() as turtle.TurtleSlot;
  let tries = 16;
  let refuelled = false;
  do {
    refuelled = turtle.refuel();
    if (!refuelled) {
      // change slots
      turtle.select(((turtle.getSelectedSlot() % 16) + 1) as turtle.TurtleSlot);

      tries -= 1;
    }
  } while (!refuelled && tries > 0);

  turtle.select(startSlot);
  return refuelled;
}
