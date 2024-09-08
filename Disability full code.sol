// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/AccessControl.sol";

contract MyNFT is ERC721, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    mapping(uint256 => string ) public tokenURIs;
    mapping(uint256 => mapping(address => uint256)) private _tokenViewers;
    mapping(uint256 => uint256) public tokenAccessPeriod;

    uint256 public lastMintDuration ;

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(MINTER_ROLE, msg.sender);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
// function encryptString(string memory metadata) public pure returns(bytes32) {
    // bytes32 EncryptedMetadata = keccak256(abi.encodePacked(metadata));
   // return EncryptedMetadata;
   // }

    function bytes32ToString(bytes32 _bytes32) private pure returns (string memory) {
        bytes memory bytesArray = new bytes(64);
        for (uint256 i = 0; i < 32; i++) {
        bytesArray[i * 2] = bytes1(uint8(uint256(_bytes32) >> (i * 8)));
        bytesArray[i * 2 + 1] = bytes1(uint8(uint256(_bytes32) >> (i * 8 + 4)));
    }
    return string(bytesArray);
}
function hash(string memory anystring) public pure returns(bytes32) {
     return keccak256(abi.encodePacked(anystring));
}

function mint(address to, uint256 tokenId, string memory metadata) public onlyRole(MINTER_ROLE) {
    uint256 startMintTime = block.timestamp;
       // bytes32 encryptedMetadataHash = keccak256(abi.encodePacked(EncryptedMetadata));
        //bytes32 hashed = keccak256(abi.encodePacked(HashedMetaData));
       //bytes32 hashed = keccak256(bytes(HashedMetaData));
       // string memory encryptedMetadataString = bytes32ToString(encryptedMetadataHash);
       //string memory HashedMetaDataString = bytes32ToString(hashed);
       // bytes32 HashedMetaDataString = hash(metadata);
         _mint(to, tokenId);
         //tokenURIs[tokenId] = HashedMetaDataString;
         tokenURIs[tokenId] = metadata;
         uint256 endMintTime = block.timestamp;
     lastMintDuration = endMintTime - startMintTime;
    }
     function getLastMintDuration() public view returns (uint256) {

        return lastMintDuration;
    }
    
//function getURIS(uint256 id) public view returns (string memory) {
    
  //   return tokenURIs[id]; // Retrieve the IPFS hash based on the provided ID }
//}
function getURIS(uint256 id) public view returns (string memory) {
    require(canView(id)==true);
    return tokenURIs[id]; // Retrieve the IPFS hash based on the provided ID }
}

    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(hasRole(ADMIN_ROLE, msg.sender), "MyNFT: must have admin role to set approval for all");
        super.setApprovalForAll(operator, approved);
    }

    function grantRole(bytes32 role, address account) public virtual override onlyRole(DEFAULT_ADMIN_ROLE) {
        super.grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual override onlyRole(DEFAULT_ADMIN_ROLE) {
        super.revokeRole(role, account);
    }

    function addViewer(uint256 tokenId, address viewer, uint256 accessPeriodInHours) public onlyRole(DEFAULT_ADMIN_ROLE) {
        uint256 startMintTime = block.timestamp;
        //require(tokenURIs[tokenId]!="","Token not existed");
        require(bytes(tokenURIs[tokenId]).length != 0, "Token does not exist");
        uint256 accessPeriodInSeconds = accessPeriodInHours * 1 hours; // convert hours to seconds
        _tokenViewers[tokenId][viewer] = block.timestamp + accessPeriodInSeconds;
        uint256 endMintTime = block.timestamp;
        lastMintDuration = endMintTime - startMintTime;
    }

    function removeViewer(uint256 tokenId, address viewer) public onlyRole(DEFAULT_ADMIN_ROLE) {
       uint256 startMintTime = block.timestamp;
       // require(tokenURIs[tokenId]!=0,"Token not existed");
       require(bytes(tokenURIs[tokenId]).length != 0, "Token does not exist");
        _tokenViewers[tokenId][viewer] = 0;
        uint256 endMintTime = block.timestamp;
        lastMintDuration = endMintTime - startMintTime;
    }

    function canView(uint256 tokenId) public view returns (bool) {
        if (ownerOf(tokenId) == msg.sender) {
            return true;
        }
        uint256 viewerAccessPeriod = _tokenViewers[tokenId][msg.sender];
        if (viewerAccessPeriod > block.timestamp && viewerAccessPeriod <= tokenAccessPeriod[tokenId]) {
            return true;
        }
        return false;
    }
    
    function checkDefaultAdminRole() public view returns (bool) {
        return hasRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }
}
