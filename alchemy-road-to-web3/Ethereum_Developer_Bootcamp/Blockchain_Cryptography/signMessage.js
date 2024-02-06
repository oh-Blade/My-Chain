const secp256k1 = require("ethereum-cryptography/secp256k1");
const hashMessage = require('./hashMessage');

const PRIVATE_KEY = "6b911fd37cdf5c81d4c0adb1ab7fa822ed253ab0ad9aa18d77257c88b29b718e";

async function signMessage(msg) {
  return await secp256k1.sign(hashMessage(msg), PRIVATE_KEY, { lowS:true});
  
}
// module.exports = signMessage;
async function describe(){
  const [sig, recoveryBit] = await signMessage('hello world');

  console.log("sig:" ,sig);
  console.log("recover:", recoveryBit);
}

describe();
