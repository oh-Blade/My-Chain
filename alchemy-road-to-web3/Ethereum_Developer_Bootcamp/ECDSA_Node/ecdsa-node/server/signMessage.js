const secp = require("ethereum-cryptography/secp256k1");
const hashMessage = require('./hashMessage');

async function signMessage(msg, key) {
  const si = await secp.sign(hashMessage(msg), key, { lowS: true });
  console.log(si);
  return si;
}
signMessage("hello world");
// module.exports = signMessage;