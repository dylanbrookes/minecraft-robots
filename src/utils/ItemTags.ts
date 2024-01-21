export enum ItemTags {
  turtle = 'computercraft:turtle',
  stella_arcanum = 'forge:ores/stella_arcanum',
  diamond = 'minecraft:diamond',
  diamond_block = 'minecraft:diamond_block',
  gold_ingot = 'minecraft:gold_ingot',
  gold_block = 'minecraft:gold_block',
  emerald = 'minecraft:emerald',
  emerald_block = 'minecraft:emerald_block',
  cobblestone = 'minecraft:cobblestone',
  coal = 'minecraft:coal',
  tnt = 'minecraft:tnt',
  stick = 'minecraft:stick',
}

export const inspectHasTags = (info: string | turtle.InspectItemData | null, tagsParam: string | string[]): boolean => {
  if (!info || typeof info !== 'object') return false;
  const tags = Array.isArray(tagsParam) ? tagsParam : [tagsParam];
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  return tags.findIndex(tag => tag in (info as any).tags) !== -1;
}
