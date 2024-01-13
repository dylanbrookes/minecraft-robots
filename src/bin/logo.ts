import '/require_stub';
const monitor = peripheral.find<peripheral.Monitor>("monitor");
if (!monitor) {
  console.log("Failed to find a monitor");
} else {
  monitor.setTextScale(0.5);
  const oldterm = term.redirect(monitor); // Now all term calls will go to the monitor instead
  const image = paintutils.loadImage("/res/logo.nfp");
  if (!image) {
    throw new Error('Missing image');
  }
  paintutils.drawImage(image, 1, 1);
  term.redirect(oldterm); // Now the term.* calls will draw on the terminal again
}
