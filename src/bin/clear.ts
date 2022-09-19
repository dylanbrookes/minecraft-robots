// find fuel in inv and restore current slot after
// function checkFuel()
//     if turtle.getFuelLevel() < 100 then
//         print("Refuelling...")
//         local startSlot = turtle.getSelectedSlot()
//         local tries = 16
//         repeat
//             local refuelled = turtle.refuel()
//             if refuelled == false then
//                 // change slots
//                 turtle.select((turtle.getSelectedSlot() % 16) + 1)

//                 tries = tries - 1
//                 if tries == 0 then
//                     print("ERROR: Ran out of fuel, will search again in 3 seconds")
//                     sleep(3)
//                     tries = 16
//                 end
//             end
//         until(refuelled == true)
//         turtle.select(startSlot)
//         print("Done refueling")
//     end
// end
function checkFuel() {
  if (turtle.getFuelLevel() < 100) {
    console.log("Refuelling...");
    const startSlot = turtle.getSelectedSlot() as turtle.TurtleSlot;
    let refuelled = false;
    let tries = 16;
    while (!refuelled) {
      refuelled = turtle.refuel();
      if (!refuelled) {
        turtle.select((turtle.getSelectedSlot() + 1) % 16 as turtle.TurtleSlot);
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

// function locateItemInInv(itemId)
//     local currentSlot = turtle.getSelectedSlot()
//     local tries = 16
    
//     local currentItem = turtle.getItemDetail(currentSlot)
//     while currentItem == nil or currentItem.name ~= itemId do
//         if currentItem ~= nil then print(currentItem.name) end
//         // change slots
//         currentSlot = (turtle.getSelectedSlot() % 16) + 1
//         turtle.select(currentSlot)
//         currentItem = turtle.getItemDetail(currentSlot)

//         tries = tries - 1
//         if tries == 0 then
//             print("ERROR: Failed to find item ".. itemId ..", will search again in 3 seconds")
//             sleep(3)
//             tries = 16
//         end
//     end
// end

// // clears the col directly above
// // optional height, otherwise it will dig up until there's no block
// function clearCol(height)
//     local off = 0
//     while height == nil or off < height - 1 do
//         if height == nil and turtle.detectUp() == false then
//             break
//         end

//         turtle.digUp()
//         if height == nil or off < height - 2 then
//             // skip going up one last time if we're using height
//             turtle.up()
//         end
//         off = off + 1
//     end

//     print("done up "..off)
//     if height ~= nil then
//         // we skipped the last move up
//         off = off - 1
//     end

//     while off > 0 do
//         turtle.digDown() // in case a block was accidentally placed below
//         turtle.down()
//         off = off - 1
//     end
// end
/**
 * clears the col directly above
 * optional height, otherwise it will dig up until there's no block
 */
function clearCol(height?: number) {
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

  if (!height) {
    // we skipped the last move up
    off--;
  }

  while (off > 0) {
    turtle.digDown(); // in case a block was accidentally placed below
    turtle.down();
    off--;
  }
}

// // break directly in front and move forward
// function breakAndMove()
//     turtle.dig()
//     while turtle.forward() == false do
//         print("ERROR: Could not move, waiting 5 seconds...")
//         sleep(5)
//     end
// end
function breakAndMove() {
  turtle.dig()
  while (!turtle.forward()) {
    console.log("Could not move, waiting 5 seconds...");
    sleep(5);
  }
}

// function clear(x, y, z)
//     print("Clearing w="..x.." d="..y.." h="..textutils.serialize(z))
//     checkFuel()
//     breakAndMove()

//     local xx, yy = 0, 0
//     while xx < x do
//         yy = 0
//         while yy < y do
//             checkFuel()
//             print("clearing column "..xx..","..yy)

//             clearCol(z)
//             if y - yy > 1 then // skip on last col
//                 breakAndMove()
//             end
//             print("Done")

//             yy = yy + 1
//         end

//         if x - xx > 1 then // skip on last row
//             if xx % 2 == 0 then
//                 turtle.turnRight()
//                 breakAndMove()
//                 turtle.turnRight()
//             else
//                 turtle.turnLeft()
//                 breakAndMove()
//                 turtle.turnLeft()
//             end
//         end
//         xx = xx + 1
//     end
//     print("Done clearing")
// end

function clear(w: number, d: number, h?: number) {
  console.log(`Clearing w=${w} d=${d} h=${h}`);
  checkFuel();
  breakAndMove();

  for (let x = 0; x < w; x++) {
    for (let y = 0; y < d; y++) {
      checkFuel();
      console.log(`Clearing column ${x},${y}`);
      clearCol(h);

      if (d - y > 1) { // skip on last col
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


// args = {...}
// x = tonumber(args[1])
// y = tonumber(args[2])
// z = tonumber(args[3])
// if x == nil or y == nil then
//     print("missing x/y")
//     return
// end
// print(x, y, z)
// clear(x, y, z)

const args = [...$vararg];
assert(args.length >= 2, "usage: clear <w> <d> [h]");
console.log(textutils.serialize(args))
clear(parseInt(args[0]), parseInt(args[1]), parseInt(args[2]))
