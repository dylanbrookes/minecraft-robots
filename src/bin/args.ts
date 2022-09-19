import '/require_stub'; // import first in entrypoint scripts
import test from '../utils/test';

const args = [...$vararg];
console.log(`These are your arguments: ${args}`);
test();
