export enum ItemTags {
  turtle = 'computercraft:turtle',
  stella_arcanum = 'forge:ores/stella_arcanum',
}

export const inspectHasTag = (info: string | turtle.InspectItemData | null, tag: string): boolean => {
  if (!info || typeof info !== 'object') return false;
  return tag in (info as any).tags;
}
