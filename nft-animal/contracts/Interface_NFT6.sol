// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
//###为备用方法
interface INFT {

    function setBaseuri(string memory _baseURI) external;//设置基础URI

    function setBaseExtension(string memory _baseExtension) external;//设置拓展名，一般为.json

    function setNoRevealedURI(string memory _setNoRevealedURI) external;//设置盲盒URI

    function revealedNFTURI() external;//揭开盲盒URI

    function revokeToCapital(uint _tokenId) external;//###取消tokenid的船长身份

    function granToCapital(uint _tokenId) external;//升级为船长

    function safeMint(address to) external;//管理员为白名单mint一个

    function safeMintForMember(address to) external;//###管理员mint一个普通nft

    function safeMintWithWhiteList(address to) external;//白名单用户mint3个

    function setWhiteList(address user) external;//设置白名单



}
