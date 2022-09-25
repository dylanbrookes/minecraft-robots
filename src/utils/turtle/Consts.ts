export enum TurtleReason {
  OUT_OF_FUEL = 'Out of fuel',
}

export enum TurtleEvent {
  moved = 'moved',
  moved_up = 'moved:up',
  moved_down = 'moved:down',
  moved_back = 'moved:back',
  moved_forward = 'moved:forward',
  turned = 'turned',
  turned_left = 'turned:left',
  turned_right = 'turned:right',
  out_of_fuel = 'out_of_fuel',
  check_fuel = 'check_fuel',
  dig = 'dig',
  dig_forward = 'dig:forward',
  dig_up = 'dig:up',
  dig_down = 'dig:down',
}

export type TurtlePosition = [x: number, y: number, z: number];
