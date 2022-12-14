pragma solidity ^0.5.0;

contract Adoption {
    // 保存领养者的地址
    address[16] public adopters;

    //领养宠物
    function adopt(uint256 petId) public returns (uint256) {
        require(petId >= 0 && petId <= 15);

        //保存调用地址
        adopters[petId] = msg.sender;

        return petId;
    }

    function getAdopters() public view returns (address[16] memory) {
        return adopters;
    }
}
