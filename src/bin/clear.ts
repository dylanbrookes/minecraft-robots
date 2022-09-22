import "/require_stub";

// find fuel in inv and restore current slot after
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

/**
 * clears the col directly above
 * optional height, otherwise it will dig up until there's no block
 */
function clearCol(breakForward: boolean, height?: number) {
  let off = 0;
  while (!height || off < height - 1) {
    if (!height && !turtle.detectUp()) {
      break;
    }

    turtle.digUp();
    if (!height || off < height - 2) {
      // skip going up one last time if we're using height
      turtle.up();
    }
    off++;
  }

  if (height) {
    // we skipped the last move up
    off--;
  }

  while (off > 0) {
    turtle.digDown(); // in case a block was accidentally placed below
    turtle.down();
    off--;
  }
}

function breakAndMove() {
  turtle.dig()
  while (!turtle.forward()) {
    console.log("Could not move, waiting 5 seconds...");
    sleep(5);
  }
}

function clear(w: number, d: number, h?: number) {
  console.log(`Clearing w=${w} d=${d} h=${h}`);
  checkFuel();
  breakAndMove();

  for (let x = 0; x < w; x++) {
    for (let y = 0; y < d; y++) {
      checkFuel();
      console.log(`Clearing column ${x},${y}`);
      const lastCol = y + 1 === d;
      if (y % 2 === 0) {
        // clears above and forward, skip breaking forward on last col
        clearCol(!lastCol, h);
      }

      if (!lastCol) { // skip on last col
        breakAndMove()
      }
    }

    if (w - x > 1) { // skip on last row
      if (x % 2 == 0) {
          turtle.turnRight();
          breakAndMove();
          turtle.turnRight();
      } else {
          turtle.turnLeft();
          breakAndMove();
          turtle.turnLeft();
      }
    }
  }
  print("Done clearing")
}

const args = [...$vararg];
assert(args.length >= 2, "usage: clear <w> <d> [h]");
console.log(textutils.serialize(args))
clear(parseInt(args[0]), parseInt(args[1]), args[2] ? parseInt(args[2]) : undefined)
