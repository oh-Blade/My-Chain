const Block = require('./Block');

class Blockchain {
    constructor() {
        this.chain = [new Block('No') /* TODO: Create the genesis block here */ ];
    }

    addBlock(block) {
        const previousHash = this.chain[this.chain.length-1].toHash();
        block.previousHash = previousHash;
        this.chain.push(block);
    }

    isValid(){
        if(this.chain.length == 1){
            return true;
        }
        for(let i = 1;i < this.chain.length;i++){
            if(this.chain[i-1].toHash() !== this.chain[i].previousHash){
                return false;
            }
        }
        return true;
    }

}

module.exports = Blockchain;