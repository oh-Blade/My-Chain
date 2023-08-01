/**
*
* 动态体力 mapping(uint => uint) public dymHp;
*   在mint的时候initialattribute的 proxy dymHp[tokenId] = hp;
*
*/
pragma solidity ^0.8.4;
import "./IERC721MPT.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "./IERC721Attribute.sol";

contract NFT_data_proxy is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    /// @custom:oz-upgrades-unsafe-allow constructor
    //address [] public Slot;//父合约插槽 == 子合约地址
    IERC721MPT public  F_NFT;//父合约地址
    IERC721MPT [] public Slot;//子合约插槽
    IERC721Attribute attribute;//NFT属性
    IERC721Attribute attribute_Of_Son;//道具NFT属性
    ICalculateFactory CalculateFactory;//初始化的属性数据

    
    mapping(address => mapping(uint => bool)) public sonNFT_isEquip; //第一个是子合约地址，第二个是子合约的tokenid，第三个是是否装备
    //子NFT装备到对应的父NFT tokenID=>tokenID
    //所以子合约的tokenId不能从0开始
    mapping(uint => uint) public S_tokenId_mapping_F_tokenId;//子NFT合约对应的父NFT合约
    mapping(uint => uint) public slot_used_Num;//已插槽数量
    mapping(uint => uint) public mainNFT_slot;//主NFT的插槽数量
    mapping(uint => attributeUintData) private tokenId_For_Attribute_Uint_Value;//通过tokenId找到属性值
    mapping(uint => attributeUintData) private SontokenId_For_Attribute_Uint_Value;//通过子tokenId找到属性值
    uint256 private initialSlotNum;
    //结构体属性
    struct attributeUintData{
        uint256 hp;
        uint256 efficient;
        uint256 speed;
        uint256 dymhp;
        uint256 slotNum;
        uint256 slot_Used_Num;
    }
    //初始化

    constructor() {
        _disableInitializers();
    }

    function initialize() initializer public {
        __Ownable_init();
        __UUPSUpgradeable_init();
    }



    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}

    function initialNFTSlot(uint Num) external returns(uint) {
        initialSlotNum = Num ;
        return initialSlotNum;
    }

    //属性的初始化
    function initialAttrbute(uint tokenId) internal {
        //uint hp = getAttributeDataByUint(F_tokenId,"hp") + getSonAttributeDataByUint(S_tokenId, "hp");
        //uint efficient = getAttributeDataByUint(F_tokenId, "efficient") + getSonAttributeDataByUint(S_tokenId, "efficient");
        //uint speed = getAttributeDataByUint(F_tokenId, "speed") + getSonAttributeDataByUint(S_tokenId, "speed");

        uint hp = getAttributeDataByUint(tokenId,"hp");
        uint efficient = getAttributeDataByUint(tokenId, "efficient");
        uint speed = getAttributeDataByUint(tokenId, "speed");

        attributeUintData memory attributeData;
        attributeData.hp = hp;
        attributeData.dymhp = hp;
        attributeData.efficient = efficient;
        attributeData.speed = speed;
        attributeData.slotNum = initialSlotNum;
        tokenId_For_Attribute_Uint_Value[tokenId] = attributeData;
    }

    function initialSonAttribute(uint tokenId) internal {
        //uint hp = getAttributeDataByUint(F_tokenId,"hp") + getSonAttributeDataByUint(S_tokenId, "hp");
        //uint efficient = getAttributeDataByUint(F_tokenId, "efficient") + getSonAttributeDataByUint(S_tokenId, "efficient");
        //uint speed = getAttributeDataByUint(F_tokenId, "speed") + getSonAttributeDataByUint(S_tokenId, "speed");

        uint hp = getAttributeDataByUint(tokenId,"hp");
        uint efficient = getAttributeDataByUint(tokenId, "efficient");
        uint speed = getAttributeDataByUint(tokenId, "speed");

        attributeUintData memory attributeData;
        attributeData.hp = hp;
        attributeData.efficient = efficient;
        attributeData.speed = speed;
        SontokenId_For_Attribute_Uint_Value[tokenId] = attributeData;
    }
    /**
    *
    *   string转化为uint
    */
  function toUint(string memory _str) internal pure returns(uint256 res, bool err) {
      for (uint256 i = 0; i < bytes(_str).length; i++) {
          if ((uint8(bytes(_str)[i]) - 48) < 0 || (uint8(bytes(_str)[i]) - 48) > 9) {
              return (0, true);
          }
          res += (uint8(bytes(_str)[i]) - 48) * 10**(bytes(_str).length - i - 1);
      }
      return (res, false);
  }

    /**
    *   设置属性合约
    */

    function setAttributeContract(address _attribute) public {
        attribute = IERC721Attribute(_attribute);

    }

    function setSonAttributeContract(address _attribute) public {
        attribute_Of_Son = IERC721Attribute(_attribute);

    }

    //设置初始化属性地址
    function setCalculateFactory(address _CalculateFactory) public {
        CalculateFactory = ICalculateFactory(_CalculateFactory);
    }
    /**
    * 增加子NFT类型
    *
    */

    function addSolt(address slot) public {
        IERC721MPT _S_NFT = IERC721MPT(slot);
        Slot.push(_S_NFT);
    }

    /**
    *
    * 升级NFT插槽
    *
    **/
    //插槽升级内部函数
    function addTokenSlot(uint tokenId) internal {
        require((mainNFT_slot[tokenId] < 10) && (mainNFT_slot[tokenId] >= 4),"slot number error");
        require(F_NFT.ownerOf(tokenId) == tx.origin,"no owner");
        if(mainNFT_slot[tokenId] < 6) {
            mainNFT_slot[tokenId] ++;

        }if(mainNFT_slot[tokenId] >= 6) {
            mainNFT_slot[tokenId] + 2;
        }

    }

    function upGradeNFTSlot(uint tokenId) external {
        addTokenSlot(tokenId);
 

    }

    //读取NFT的属性数据
    function getTokenId_For_Attribute_Uint_Value (uint tokenId) external view returns(uint _hp,uint _efficient,uint _speed,uint _dymhp) {
        _hp = tokenId_For_Attribute_Uint_Value[tokenId].hp ;
        _efficient = tokenId_For_Attribute_Uint_Value[tokenId].efficient;
        _speed = tokenId_For_Attribute_Uint_Value[tokenId].speed;
        _dymhp = tokenId_For_Attribute_Uint_Value[tokenId].dymhp;

    }
    //读取道具合约属性
    function getSonTokenId_For_Attribute_Uint_Value (uint tokenId) external view returns(uint _hp,uint _efficient,uint _speed) {
        _hp = SontokenId_For_Attribute_Uint_Value[tokenId].hp ;
        _efficient = SontokenId_For_Attribute_Uint_Value[tokenId].efficient;
        _speed = SontokenId_For_Attribute_Uint_Value[tokenId].speed;

    }

    //体力的交互


    //获取体力
    function getHp(uint tokenId) public view returns(uint hp, uint dymhp) {
        hp = tokenId_For_Attribute_Uint_Value[tokenId].hp;
        dymhp = tokenId_For_Attribute_Uint_Value[tokenId].dymhp;
        return (hp, dymhp);
    }
    //0.8不会溢出

    //减少体力
    function subHp(uint tokenId, uint Num) public {
        tokenId_For_Attribute_Uint_Value[tokenId].dymhp -= Num;
        
    }
    //回复体力
    function recoverHpAll(uint tokenId) public {
        tokenId_For_Attribute_Uint_Value[tokenId].dymhp = tokenId_For_Attribute_Uint_Value[tokenId].hp ;

    }
    //体力清0
    function subHpAll(uint tokenId) public {
        tokenId_For_Attribute_Uint_Value[tokenId].dymhp = 0;

    }

    /**
    *
    *设置父合约
    *
    *
    */

    function set_F_NFT(address _F_NFT) external {
        F_NFT = IERC721MPT(_F_NFT);
    }

    /**
    * 装备
    * 父NFTtokenId 子NFT地址 子nft的tokenId
    */
    function uplodeEquip(uint256 F_tokenId, address sonAddress, uint S_tokenId) public {
        require(tokenId_For_Attribute_Uint_Value[F_tokenId].slot_Used_Num < tokenId_For_Attribute_Uint_Value[F_tokenId].slotNum,"solt is full");
        require(F_NFT.ownerOf(F_tokenId) == tx.origin,"no mainNFT owner");
        require(!sonNFT_isEquip[sonAddress][S_tokenId], "Equip is uploading now");
//父合约与子合约owner同一个才可以装备)
        bool isSonNFT;//判断是否为子合约
        uint key;
        for(uint i = 0; i < Slot.length; i ++) {
            if(address(Slot[i]) == sonAddress){
                isSonNFT = true;
                key = i;
            }
        }
        require(isSonNFT,"motherFuker");
        //子合约和父合约owner一致
        require(F_NFT.ownerOf(F_tokenId) == Slot[key].ownerOf(S_tokenId),"no one owner");
        //Slot[key].transferFrom(msg.sender, address(this), S_tokenId);//装备完成后发送到该合约中
        sonNFT_isEquip[sonAddress][S_tokenId] = true;
        S_tokenId_mapping_F_tokenId[S_tokenId] = F_tokenId;
        attributeAdd(F_tokenId, S_tokenId);
        tokenId_For_Attribute_Uint_Value[F_tokenId].slot_Used_Num --;

    }





    /**
    *@dev 卸下装备
    *
    ***/
    
    function unlodeEquip(uint256 F_tokenId, address NFT_address, uint S_tokenId) public {
        //require(F_NFT.ownerOf(F_tokenId) == tx.origin,"no mainNFT owner");
        require(sonNFT_isEquip[NFT_address][S_tokenId], "Equip is'n uploading now");
        require(msg.sender == F_NFT.ownerOf(S_tokenId_mapping_F_tokenId[S_tokenId]),"no mainNFT owner");
        bool isSonNFT;//判断是否为子合约
        uint key;//拿到相应子合约的key
        for(uint i = 0; i < Slot.length; i ++) {
            if(address(Slot[i]) == NFT_address){
                isSonNFT = true;
                key = i;
            }

        }
        require(F_NFT.ownerOf(F_tokenId) == tx.origin,"no owner");
        require(isSonNFT,"motherFuker");
        sonNFT_isEquip[NFT_address][S_tokenId] = false;
        //Slot[key].approve(msg.sender,S_tokenId);//直接发送方法
        Slot[key].unloadEquip(S_tokenId);//装备完成后发送到该合约中
        S_tokenId_mapping_F_tokenId[S_tokenId] = 0;
        attributeSub(F_tokenId, S_tokenId);
        tokenId_For_Attribute_Uint_Value[F_tokenId].slot_Used_Num -- ;

    }



    //得到uint类型的属性数据
    function getAttributeDataByUint(uint tokenId, string memory key) internal view returns(uint uintData){
        (string memory stringData) = attribute.getAttribute(tokenId,key).value;
        (uintData,) = toUint(stringData);
    }


    //得到uint类型的道具合约数据
    function getSonAttributeDataByUint(uint tokenId, string memory key) internal view returns(uint uintData){
        (string memory stringData) = attribute_Of_Son.getAttribute(tokenId,key).value;
        (uintData,) = toUint(stringData);
    }


    //装备后属性相加
    function _attributeAdd(uint F_tokenId, uint S_tokenId) public {
        //uint hp = getAttributeDataByUint(F_tokenId,"hp") + getSonAttributeDataByUint(S_tokenId, "hp");
        //uint efficient = getAttributeDataByUint(F_tokenId, "efficient") + getSonAttributeDataByUint(S_tokenId, "efficient");
        //uint speed = getAttributeDataByUint(F_tokenId, "speed") + getSonAttributeDataByUint(S_tokenId, "speed");

        uint hp = getAttributeDataByUint(F_tokenId,"hp") + 5;
        uint efficient = getAttributeDataByUint(F_tokenId, "efficient") + 6;
        uint speed = getAttributeDataByUint(F_tokenId, "speed") + 100;

        attributeUintData memory attributeData;
        attributeData.hp = hp;
        attributeData.efficient = efficient;
        attributeData.speed = speed;
        tokenId_For_Attribute_Uint_Value[F_tokenId] = attributeData;

    }

    //备用
    function attributeAdd(uint F_tokenId, uint S_tokenId) public {
        tokenId_For_Attribute_Uint_Value[F_tokenId].hp += SontokenId_For_Attribute_Uint_Value[S_tokenId].hp;
        tokenId_For_Attribute_Uint_Value[F_tokenId].efficient += tokenId_For_Attribute_Uint_Value[S_tokenId].efficient;
        tokenId_For_Attribute_Uint_Value[F_tokenId].speed += tokenId_For_Attribute_Uint_Value[S_tokenId].speed;
    }

    function attributeSub(uint F_tokenId, uint S_tokenId) public {
        tokenId_For_Attribute_Uint_Value[F_tokenId].hp -= SontokenId_For_Attribute_Uint_Value[S_tokenId].hp;
        tokenId_For_Attribute_Uint_Value[F_tokenId].efficient -= tokenId_For_Attribute_Uint_Value[S_tokenId].efficient;
        tokenId_For_Attribute_Uint_Value[F_tokenId].speed -= tokenId_For_Attribute_Uint_Value[S_tokenId].speed;
    }


    //卸下装备属性相减
    function _attributeSub(uint F_tokenId, uint S_tokenId) public {
        //uint hp = getAttributeDataByUint(F_tokenId,"hp") - getSonAttributeDataByUint(S_tokenId, "hp");
        //uint efficient = getAttributeDataByUint(F_tokenId, "efficient") - getSonAttributeDataByUint(S_tokenId, "efficient");
        //uint speed = getAttributeDataByUint(F_tokenId, "speed") - getSonAttributeDataByUint(S_tokenId, "speed");

        uint hp = getAttributeDataByUint(F_tokenId,"hp") - 5;
        uint efficient = getAttributeDataByUint(F_tokenId, "efficient") - 6;
        uint speed = getAttributeDataByUint(F_tokenId, "speed") - 100;

        attributeUintData memory attributeData;
        attributeData.hp = hp;
        attributeData.efficient = efficient;
        attributeData.speed = speed;
        tokenId_For_Attribute_Uint_Value[F_tokenId] = attributeData;

    }



}

interface ICalculateFactory {
    function generate(uint256 tokenId) external ;
}
