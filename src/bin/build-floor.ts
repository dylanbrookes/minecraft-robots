import "/require_stub";

function checkFuel() {
  if (turtle.getFuelLevel() < 100) {
    console.log("Refuelling...");
    const startSlot = turtle.getSelectedSlot() as turtle.TurtleSlot;
    let refuelled = false;
    let tries = 16;
    while (!refuelled) {
      refuelled = turtle.refuel();
      if (!refuelled) {
        turtle.select((turtle.getSelectedSlot() % 16) + 1 as turtle.TurtleSlot);
        tries--;
        if (tries === 0) {
          console.log("ERROR: Ran out of fuel, will search again in 3 seconds");
          sleep(3);
          tries = 16;
        }
      }
    }
    turtle.select(startSlot);
  }
}

function forceMoveForward() {
  while (!turtle.forward()[0]) {
    console.log("Could not move, waiting 5 seconds...");
    sleep(5);
  }
}

function locateItemInInv(itemId: string) {
  let currentSlot = turtle.getSelectedSlot() as turtle.TurtleSlot;
  let currentItem = turtle.getItemDetail(currentSlot);
  let tries = 16;
  while (!currentItem || currentItem.name != itemId) {
    currentSlot = (turtle.getSelectedSlot() % 16) + 1 as turtle.TurtleSlot;
    turtle.select(currentSlot);
    currentItem = turtle.getItemDetail(currentSlot);

    tries--;
    if (tries === 0) {
      console.log(`ERROR: Failed to find item ${itemId}, will search again in 3 seconds`);
      sleep(3);
      tries = 16;
    }
  }
}

function buildFloor(itemId: string, w?: number, d?: number) {
  console.log(`Building floor, dimensions: w=${w} d=${d}`);
  checkFuel();

  for (let x = 0; w ? x < w : true; x++) {
    for (let y = 0; d ? y < d : true; y++) {
      checkFuel();
      console.log(`${x},${y}`);
      locateItemInInv(itemId);
      turtle.placeDown();

      if (d) {
        if (d - y > 1) { // skip moving forward on the last col
          forceMoveForward()
        }
      } else {
        const [moved] = turtle.forward();
        if (!moved) {
          console.log("Reached end of row");
          break;
        }
      }
    }

    if (w) {
      if (w - x > 1) { // skip on last row
        if (x % 2 == 0) {
            turtle.turnRight();
            forceMoveForward();
            turtle.turnRight();
        } else {
            turtle.turnLeft();
            forceMoveForward();
            turtle.turnLeft();
        }
      }
    } else {
      let moved: boolean;
      if (x % 2 == 0) {
        turtle.turnRight();
        ([moved] = turtle.forward());
        turtle.turnRight();
      } else {
        turtle.turnLeft();
        ([moved] = turtle.forward());
        turtle.turnLeft();
      }

      if (!moved) {
        break;
      }
    }
  }
  print("Done clearing")
}

const args = [...$vararg];
assert(args.length === 1 || args.length === 3, );
console.log(textutils.serialize(args));

if (args.length === 1) {
  const [itemId] = args;
  buildFloor(itemId);
} else if (args.length === 3) {
  const [itemId, w, d] = args;
  buildFloor(itemId, parseInt(w), parseInt(d));
} else {
  console.log("usage: build-floor <itemId> [w] [d]");
}
