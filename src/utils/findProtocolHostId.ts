export function findProtocolHostId(protocolId: string): number | null {
  const modem = peripheral.find('modem');
  if (!modem) throw new Error('Could not find modem');

  const modemName = peripheral.getName(modem);
  rednet.open(modemName);

  console.log(`Looking for protocol ${protocolId} host...`);
  const hostIds = rednet.lookup(protocolId);
  const hostId = Array.isArray(hostIds) ? hostIds[0] : hostIds;
  return hostId;
}