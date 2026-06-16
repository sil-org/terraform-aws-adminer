const readline = require('node:readline');

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
  terminal: false
});

rl.on('line', (line) => {
  try {
    const input = JSON.parse(line);

    // Parse the immutable base64 string provided by Terraform back into binary bytes
    const bytes = Buffer.from(input.secret_base64, 'base64');

    // RFC 4648 Base32 implementation
    const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    let base32Str = '';
    let bits = 0;
    let value = 0;

    for (const element of bytes) {
      value = (value << 8) | element;
      bits += 8;
      while (bits >= 5) {
        bits -= 5;
        base32Str += alphabet[(value >>> bits) & 31];
      }
    }

    // Return both formats back to Terraform
    console.log(JSON.stringify({
      base32: base32Str
    }));

  } catch (err) {
    console.error(err);
    process.exit(1);
  }
});
