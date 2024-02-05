const secp = require("ethereum-cryptography/secp256k1");
const { keccak256 } = require("ethereum-cryptography/keccak");
const { utf8ToBytes, toHex } = require("ethereum-cryptography/utils");

function getAddress(publicKey) {
  const keyBytes = utf8ToBytes(publicKey);
  const hash = keccak256(keyBytes.slice(1,keyBytes.length));
  return toHex(hash.slice(hash.length-20,hash.length));
    
}
console.log(getAddress('6b911fd37cdf5c81d4c0adb1ab7fa822ed253ab0ad9aa18d77257c88b29b718e'));
// module.exports = getAddress;