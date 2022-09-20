// print("Refuelling...")
// local startSlot = turtle.getSelectedSlot()
// local tries = 16
// repeat
//     local refuelled = turtle.refuel()
//     if refuelled == false then
//         -- change slots
//         turtle.select((turtle.getSelectedSlot() % 16) + 1)

//         tries = tries - 1
//         if tries == 0 then
//             print("ERROR: Ran out of fuel, will search again in 3 seconds")
//             sleep(3)
//             tries = 16
//         end
//     end
// until(refuelled == true)
// turtle.select(startSlot)
// print("Done refueling")

export function refuel(): boolean {
  console.log("Refueling");
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
  } while (!refuelled && tries > 16);

  turtle.select(startSlot);
  return refuelled;
}
