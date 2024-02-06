const secp = require("ethereum-cryptography/secp256k1");
const {toHex} = require("ethereum-cryptography/utils");

function getPrivateKey () {
  const privateKey = secp.utils.randomPrivateKey();
  return toHex(privateKey);
};
const private_key = getPrivateKey();
console.log('private key: ',private_key);

function getPublicKey (privateKey) {
  const publicKey = secp.getPublicKey(privateKey);
  return toHex(publicKey);
};
console.log('public key: ',getPublicKey(private_key));