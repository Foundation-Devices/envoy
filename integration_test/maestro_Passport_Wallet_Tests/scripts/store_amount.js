// copyTextFrom returns "label + rendered text", e.g. "5678 5,678"
// The label (raw sats) is the first token
output.amountSats = maestro.copiedText.trim().split(/\s+/)[0];
