const ENV_FILE = '/.env';
const env: { [k: string]: string } = {};
if (fs.exists(ENV_FILE)) {
  const [handle, err] = fs.open(ENV_FILE, 'r');
  if (!handle) {
    throw new Error("Failed to open env file " + ENV_FILE + " error: " + err);
  }

  let line: string | undefined;
  while (line = handle.readLine()) {
    const [key, value] = line.split('=');
    if (!key || !value) {
      // can't use logger because circular dependency
      console.log("Skipping malformed env line:", line);
    } else {
      Object.assign(env, { [key.replace(' ', '')]: value.replace(' ', '') });
    }
  }
}

export default env;
