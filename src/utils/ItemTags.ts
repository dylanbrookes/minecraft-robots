export enum ItemTags {
  turtle = 'computercraft:turtle',
  stella_arcanum = 'forge:ores/stella_arcanum',
}

export const inspectHasTags = (info: string | turtle.InspectItemData | null, tagsParam: string | string[]): boolean => {
  if (!info || typeof info !== 'object') return false;
  const tags = Array.isArray(tagsParam) ? tagsParam : [tagsParam];
  return tags.findIndex(tag => tag in (info as any).tags) !== -1;
}
