// copyTextFrom returns "label + rendered text", e.g. "141 141"
// The label (raw sats) is the first token
output.feeSats = maestro.copiedText.trim().split(/\s+/)[0];
