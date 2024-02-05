const SHA256 = require('crypto-js/sha256');
const TARGET_DIFFICULTY = BigInt(0x0fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
const MAX_TRANSACTIONS = 10;

const mempool = [];
const blocks = [];

function addTransaction(transaction) {
    // TODO: add transaction to mempool
    mempool.push(transaction);
}

function mine() {
    // TODO: mine a block
    let nonce = 0;
    const transactions = mempool.splice(0,10);
    const block = { id: blocks.length, transactions: transactions,nonce: nonce};

    let hash ;
    
    do {
        block.nonce = nonce;
        const strBlock = JSON.stringify(block);
        hash = SHA256(strBlock).toString();
        nonce += 1;
    } while (BigInt(`0x${hash}`) > TARGET_DIFFICULTY)

    block.hash = hash;
    blocks.push(block);

}

module.exports = {
    TARGET_DIFFICULTY,
    MAX_TRANSACTIONS,
    addTransaction, 
    mine, 
    blocks,
    mempool
};