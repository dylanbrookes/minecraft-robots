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
  low_fuel = 'low_fuel',
  check_fuel = 'check_fuel',
  dig = 'dig',
  dig_forward = 'dig:forward',
  dig_up = 'dig:up',
  dig_down = 'dig:down',
}

export type TurtlePosition = [x: number, y: number, z: number];

export const positionsEqual = (a: TurtlePosition, b: TurtlePosition) => a[0] === b[0] && a[1] === b[1] && a[2] === b[2];
export const serializePosition = (p: TurtlePosition) => p.join('-');
export const cartesianDistance = (a: TurtlePosition, b: TurtlePosition): number => Math.abs(a[0] - b[0]) + Math.abs(a[1] - b[1]) + Math.abs(a[2] - b[2]);
export const distance = (a: TurtlePosition, b: TurtlePosition): number => Math.sqrt((a[0] - b[0]) ** 2 + (a[1] - b[1]) ** 2 + (a[2] - b[2]) ** 2);

export const JobEvent = {
  start: (id: number) => `job:start:${id}`,
  end: (id: number) => `job:end:${id}`,
  pause: (id: number) => `job:pause:${id}`,
  resume: (id: number) => `job:resume:${id}`,
  error: (id: number) => `job:error:${id}`,
}

export enum JobType {
  spin = 'spin',
  clear = 'clear',
}
