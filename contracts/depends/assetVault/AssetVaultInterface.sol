// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../preclude/Preclude.sol";

import "./AssetVaultEvent.sol";

interface AssetVaultInterface is AssetVaultEvent {

    function mintErc20(
        bytes32 erc20TokenName,
        address owner,
        uint256 amount
    ) external;

    function depositErc20(
        bytes32 erc20TokenName,
        address owner,
        uint256 amount
    ) external;

    function withdrawErc20(
        bytes32 erc20TokenName,
        address owner,
        uint256 amount
    ) external;

    //==========================================================================================

    function mintErc1155(
        bytes32 erc1155TokenName,
        address owner,
        uint256 tokenId,
        uint256 amount
    ) external;


    function depositErc1155(
        bytes32 erc1155TokenName,
        address owner,
        uint256 tokenId,
        uint256 amount
    ) external;

    function withdrawErc1155(
        bytes32 erc1155TokenName,
        address owner,
        uint256 tokenId,
        uint256 amount
    ) external;

    //==========================================================================================

    //theoretically, the server could only update info of deposited 721
    //could compress fixed data into one array, but we leave it separated here for contract invoke
    function syncErc721(
        bytes32 erc721TokenName,
        uint256 tokenId,
        uint256 offlineId,
        bytes32[] memory attributeNames,
        uint256[] memory uint256Data,
        bytes32[] memory bytes32Data,
        address[] memory addressData,
        bytes[] memory bytesData
    ) external;

    //mint 721 online to OWNER
    function mintErc721(
        bytes32 erc721TokenName,
        address owner
    ) external returns (uint256 tokenId);

    //mint offline 721 in VAULT, auto bind the generated tokenId with offlineId
    function mapErc721(
        bytes32 erc721TokenName,
        uint256 offlineId
    ) external returns (uint256 tokenId);

    //bind the tokenId with offlineId
    function bindErc721(
        bytes32 erc721TokenName,
        uint256 tokenId,
        uint256 offlineId
    ) external;

    function depositErc721(
        bytes32 erc721TokenName,
        address owner,
        uint256 tokenId,
        uint256 offlineId
    ) external;

    /*
    withdraw tokenId from vault
    */
    function withdrawErc721(
        bytes32 erc721TokenName,
        address owner,
        uint256 tokenId,
        uint256 offlineId
    ) external;

}
