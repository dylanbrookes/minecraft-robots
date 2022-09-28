import { Heading } from "./LocationMonitor";

export default function parseHeadingParam(headingParam: string): Heading {
  switch (headingParam.toLowerCase()) {
    case 'n':
    case 'north':
      return Heading.NORTH;
      break;
    case 's':
    case 'south':
      return Heading.SOUTH;
      break;
    case 'w':
    case 'west':
      return Heading.WEST;
      break;
    case 'e':
    case 'east':
      return Heading.EAST;
      break;
    default:
      return Heading.UNKNOWN;
  }
}