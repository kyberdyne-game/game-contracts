// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../preclude/Preclude.sol";

import "../ownable/OwnableInterface.sol";
import "../accessControlRef/AccessControlRefInterface.sol";
import "../reentrancy/ReentrancyInterface.sol";
import "../erc721/HERC721Interface.sol";
import "./HERC721IMEvent.sol";

interface HERC721IMInterface is OwnableInterface, AccessControlRefInterface, ReentrancyInterface, HERC721Interface, HERC721IMEvent {

    function mintNormal(uint256 tokenId, uint256 offlineId) external returns (uint256);

    function mintSudo(address to, uint256 tokenId, uint256 offlineId) external returns (uint256);

    function burnNormal(uint256 tokenId) external;

    function burnSudo(uint256 tokenId) external;

    function bind(uint256 tokenId, uint256 offlineId) external;

    function unbind(uint256 tokenId) external;

    function freeze(uint256 tokenId, address unlocker) external;

    function thaw(uint256 tokenId) external;

    function setUint256Attribute(bytes32 attributeName, uint256 tokenId, uint256 data) external;

    function setBytes32Attribute(bytes32 attributeName, uint256 tokenId, bytes32 data) external;

    function setAddressAttribute(bytes32 attributeName, uint256 tokenId, address data) external;

    function setBytesAttribute(bytes32 attributeName, uint256 tokenId, bytes memory data) external;

    function setAccessControl(address accessControl_) external;

    function setSupport(bool supportTransfer_, bool supportMint_, bool supportBurn_) external;

    //==========

    function frozen(uint256 tokenId) view external returns (address);

    function offlineIdToTokenId(uint256 offlineId) view external returns (uint256);

    //zero for unbound or not existence
    function tokenIdToOfflineId(uint256 tokenId) view external returns (uint256);

    function exists(uint256 tokenId) view external returns (bool);

    function getUint256Attribute(bytes32 attributeName, uint256 tokenId) view external returns (uint256);

    function getBytes32Attribute(bytes32 attributeName, uint256 tokenId) view external returns (bytes32);

    function getAddressAttribute(bytes32 attributeName, uint256 tokenId) view external returns (address);

    function getBytesAttribute(bytes32 attributeName, uint256 tokenId) view external returns (bytes memory);

    function support() view external returns (bool supportTransfer, bool supportMint, bool supportBurn);

    function transferTxs() view external returns (uint256);

    function interactAmounts() view external returns (uint256);

    function isInteracted(address who) view external returns (bool);
}
