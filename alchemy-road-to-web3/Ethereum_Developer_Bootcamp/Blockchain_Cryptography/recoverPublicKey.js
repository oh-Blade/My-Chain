const secp = require("ethereum-cryptography/secp256k1");
const hashMessage = require("./hashMessage");

/**
 * 当签名及其所有组成部分（包括恢复位）一起传递时，可以恢复公钥。这意味着区块链节点将能够了解谁签署了发送给他们的交易。
 * 一笔交易可能表明用户想要将 1 个以太币发送到另一个地址并提供一定的交易费用。由于签名对包含此意图的哈希进行签名，因此足以完全验证此操作。
 */
async function recoverKey(message, signature, recoveryBit) {
    return secp.recoverPublicKey(hashMessage(message),signature,recoveryBit);
    
}

module.exports = recoverKey;