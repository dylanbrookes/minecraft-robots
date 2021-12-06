enum Direction {
  left = "left",
  right = "right",
}

type Coordinates = {
  x: number;
  y: number;
  z: number;
};

class Miner {
  coordinates: Coordinates;

  constructor() {
    this.coordinates = {
      x: 0,
      y: 0,
      z: 0,
    };
  }

  digLine(distance: number) {
    for (let i = 0; i < distance - 1; i++) {
      turtle.refuel();
      if (turtle.detect()) {
        turtle.dig();
      } else {
        turtle.forward();
        break;
      }
    }
  }

  turn(direction: Direction) {
    if (direction == Direction.left) {
      turtle.turnLeft();
      turtle.dig();
      turtle.forward();
      turtle.turnLeft();
    } else if (direction == Direction.right) {
      turtle.turnRight();
      turtle.dig();
      turtle.forward();
      turtle.turnRight();
    }
  }
}
