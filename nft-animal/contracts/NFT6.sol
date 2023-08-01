// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable@4.7.3/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable@4.7.3/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable@4.7.3/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable@4.7.3/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable@4.7.3/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable@4.7.3/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable@4.7.3/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable@4.7.3/utils/CountersUpgradeable.sol";

contract NFT is Initializable, ERC721Upgradeable, ERC721URIStorageUpgradeable, PausableUpgradeable, AccessControlUpgradeable, ERC721BurnableUpgradeable, UUPSUpgradeable {
    using CountersUpgradeable for CountersUpgradeable.Counter;
    using Strings for uint256;

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    CountersUpgradeable.Counter private _tokenIdCounter;
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant WHITE_LIST_ROLE = keccak256("WHITE_LIST_ROLE");

    string public noRevealedURI;
    string public baseURI;
    string public baseExtension;
    mapping(address => bool) WhiteList;
    uint TotalSupply;
    bool isRevealed;

    

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() initializer public {
        __ERC721_init("NFT", "NFT");
        __ERC721URIStorage_init();
        __Pausable_init();
        __AccessControl_init();
        __ERC721Burnable_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function revealedNFTURI() public onlyRole(UPGRADER_ROLE) {
        require(!isRevealed,"revealed alreay");
        isRevealed = true;
    }

    function setBaseuri(string memory _baseURI) external onlyRole(UPGRADER_ROLE) {
        baseURI = _baseURI;
    }

    function setBaseExtension(string memory _baseExtension) external onlyRole(UPGRADER_ROLE) {
        baseExtension = _baseExtension;
    }

    function setNoRevealedURI(string memory _setNoRevealedURI) external onlyRole(UPGRADER_ROLE) {
        noRevealedURI = _setNoRevealedURI;
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function safeMint(address to) public onlyRole(MINTER_ROLE) {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        TotalSupply++;
    }

    function safeMintForMember(address to) public onlyRole(MINTER_ROLE) {
        uint256 tokenId = _tokenIdCounter.current() + 100000;
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        TotalSupply++;
    }

    function setWhiteList(address user) public onlyRole(MINTER_ROLE){
        require(!WhiteList[user],"whitelist now");
        require(user != address(0),"address is 0");
        WhiteList[user] = true;
    }

    function safeMintWithWhiteList(address to) public  {

        require(WhiteList[to],"not whitelist");
        WhiteList[to] = false;
        for(uint i =0 ;i <= 2 ;i ++){
            uint256 tokenId = _tokenIdCounter.current();
            _tokenIdCounter.increment();
            _safeMint(to, tokenId + 100000);
            TotalSupply++;
        }
       
    }
    //graning the  nft to the capital
    function granToCapital(uint _tokenId) public onlyRole(UPGRADER_ROLE) {
        require(_exists(_tokenId));
        require(_tokenId >= 100000,"alredy capital");
        address owner = ownerOf(_tokenId);
        uint tokenId = _tokenId - 100000;
        _burn(_tokenId);
        _safeMint(owner,tokenId);
        TotalSupply++;
    }
    //revoking the nft capital role 
    function revokeToCapital(uint _tokenId) public onlyRole(UPGRADER_ROLE) {
        require(_exists(_tokenId));
        require(_tokenId <= 100000,"no capital");
        address owner = ownerOf(_tokenId);
        uint tokenId = _tokenId + 100000;
        _burn(_tokenId);
        _safeMint(owner,tokenId);
        TotalSupply++;
    }

    
    

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyRole(UPGRADER_ROLE)
        override
    {}

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId)
        internal
        override(ERC721Upgradeable, ERC721URIStorageUpgradeable)
    {
        super._burn(tokenId);
        TotalSupply--;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721Upgradeable, ERC721URIStorageUpgradeable)
        returns (string memory)
    {
        if(isRevealed){
            require(
                _exists(tokenId),
                "ERC721Metadata: URI query for nonexistent token"
            );
            return  string(abi.encodePacked(baseURI,tokenId.toString(),baseExtension));
        }else {
            return noRevealedURI;
        }

    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721Upgradeable, AccessControlUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function totalSupply() external view  returns(uint256){
        return TotalSupply;
    }
}
