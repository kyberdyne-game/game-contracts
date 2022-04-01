// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./AssetVaultLayout.sol";
import "./AssetVaultInterface.sol";

import "../holders/HERC721HolderLogic.sol";
import "../holders/HERC1155HolderLogic.sol";
import "../erc20improved/HERC20IMInterface.sol";
import "../erc1155improved/HERC1155IMInterface.sol";
import "../erc721improved/HERC721IMInterface.sol";

abstract contract AssetVaultLogic is AssetVaultLayout, HERC721HolderLogic, HERC1155HolderLogic, AssetVaultInterface {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    /*
    make sure the the manager has "sudo" permit to mint token
    */
    function _mintErc20(
        address erc20Token,
        address owner,
        uint256 amount
    ) internal {
        HERC20IMInterface(erc20Token).mintSudo(owner, amount);
        emit MintErc20(erc20Token, owner, amount);
    }

    //no map here

    //no bind here

    function _depositErc20(
        address erc20Token,
        address owner,
        uint256 amount
    ) internal {
        uint256 temp = IERC20(erc20Token).balanceOf(address(this));
        IERC20(erc20Token).safeTransferFrom(owner, address(this), amount);
        amount = IERC20(erc20Token).balanceOf(address(this)).sub(temp);
        emit DepositErc20(erc20Token, owner, owner, amount);
    }

    function _withdrawErc20(
        address erc20Token,
        address owner,
        uint256 amount
    ) internal {

        //if the erc20 token is not enough, mint enough immediately if supported
        /*uint256 gap = IERC20(erc20Token).balanceOf(address(this));
        if (gap < amount) {
            gap = amount.sub(gap);
            //or transfer some from miner
            //to-do
            HERC20IMInterface(erc20Token).mintSudo(address(this), gap);
        }*/

        IERC20(erc20Token).safeTransfer(owner, amount);
        emit WithdrawErc20(erc20Token, owner, amount);
    }

    //==========================================================================================

    function _mintErc1155(
        address erc1155Token,
        address owner,
        uint256 tokenId,
        uint256 amount
    ) internal {
        HERC1155IMInterface(erc1155Token).mintSudo(owner, tokenId, amount);
        emit MintErc1155(erc1155Token, owner, tokenId, amount);
    }

    //no map here

    //no bind here

    function _depositErc1155(
        address erc1155Token,
        address owner,
        uint256 tokenId,
        uint256 amount
    ) internal {
        IERC1155(erc1155Token).safeTransferFrom(owner, address(this), tokenId, amount, "");
        emit DepositErc1155(erc1155Token, owner, owner, tokenId, amount);
    }

    function _withdrawErc1155(
        address erc1155Token,
        address owner,
        uint256 tokenId,
        uint256 amount
    ) internal {
        IERC1155(erc1155Token).safeTransferFrom(address(this), owner, tokenId, amount, "");
        emit WithdrawErc1155(erc1155Token, owner, tokenId, amount);
    }
    //==========================================================================================

    //theoretically, the server could only update info of deposited 721
    //could compress fixed data into one array, but we leave it separated here for contract invoke
    function _syncErc721(
        address erc721Token,
        uint256 tokenId,
        uint256 offlineId,
        bytes32[] memory attributeNames,
        uint256[] memory uint256Data,
        bytes32[] memory bytes32Data,
        address[] memory addressData,
        bytes[] memory bytesData
    ) internal {

        require(attributeNames.length == (uint256Data.length + bytes32Data.length + addressData.length + bytesData.length), "param length");

        require((tokenId != 0 && offlineId == 0) || (tokenId == 0 && offlineId != 0), "tokenId and offlineId should set and only set one");

        if (tokenId == 0) {
            tokenId = HERC721IMInterface(erc721Token).offlineIdToTokenId(offlineId);
        }

        require(tokenId != 0, "_syncErc721, tokenId is zero, please mint it or map it");

        uint256 attributeNameIndex = 0;
        for (uint256 i = 0; i < uint256Data.length; i++) {
            HERC721IMInterface(erc721Token).setUint256Attribute(attributeNames[attributeNameIndex], tokenId, uint256Data[i]);
            attributeNameIndex = attributeNameIndex.add(1);
        }

        for (uint256 i = 0; i < bytes32Data.length; i++) {
            HERC721IMInterface(erc721Token).setBytes32Attribute(attributeNames[attributeNameIndex], tokenId, bytes32Data[i]);
            attributeNameIndex = attributeNameIndex.add(1);
        }

        for (uint256 i = 0; i < addressData.length; i++) {
            HERC721IMInterface(erc721Token).setAddressAttribute(attributeNames[attributeNameIndex], tokenId, addressData[i]);
            attributeNameIndex = attributeNameIndex.add(1);
        }

        for (uint256 i = 0; i < bytesData.length; i++) {
            HERC721IMInterface(erc721Token).setBytesAttribute(attributeNames[attributeNameIndex], tokenId, bytesData[i]);
            attributeNameIndex = attributeNameIndex.add(1);
        }
    }
    /*
    make sure the the manager has "sudo" permit to mint token
    */
    //mint 721 online to OWNER
    function _mintErc721(
        address erc721Token,
        address owner
    ) internal returns (uint256 tokenId) {
        tokenId = HERC721IMInterface(erc721Token).mintSudo(owner, 0, 0);
        emit MintErc721(erc721Token, owner, tokenId);
    }

    //mint offline 721 in VAULT, auto bind the generated tokenId with offlineId
    function _mapErc721(
        address erc721Token,
        uint256 offlineId
    ) internal returns (uint256 tokenId){
        require(offlineId != 0, "_mapErc721, offlineId is zero");

        //set offlineId and auto-bind
        tokenId = HERC721IMInterface(erc721Token).mintSudo(address(this), 0, offlineId);
        emit MapErc721(erc721Token, tokenId, offlineId);

        return tokenId;
    }

    //bind the tokenId with offlineId
    function _bindErc721(
        address erc721Token,
        uint256 tokenId,
        uint256 offlineId
    ) internal {
        HERC721IMInterface(erc721Token).bind(tokenId, offlineId);
        emit BindErc721(erc721Token, tokenId, offlineId);
    }

    //normally use tokenId, not offlineId
    function _depositErc721(
        address erc721Token,
        address owner,
        uint256 tokenId,
        uint256 offlineId
    ) internal {

        require((tokenId != 0 && offlineId == 0) || (tokenId == 0 && offlineId != 0), "_depositErc721, tokenId and offlineId should set and only set one");

        if (tokenId == 0) {
            tokenId = HERC721IMInterface(erc721Token).offlineIdToTokenId(offlineId);
        }

        require(tokenId != 0, "_depositErc721, tokenId is zero");

        IERC721(erc721Token).safeTransferFrom(owner, address(this), tokenId);
        emit DepositErc721(erc721Token, owner, owner, tokenId);
    }

    /*
    withdraw tokenId from vault
    */
    function _withdrawErc721(
        address erc721Token,
        address owner,
        uint256 tokenId,
        uint256 offlineId
    ) internal {

        require((tokenId != 0 && offlineId == 0) || (tokenId == 0 && offlineId != 0), "_withdrawErc721, tokenId and offlineId should set and only set one");

        if (tokenId == 0) {
            tokenId = HERC721IMInterface(erc721Token).offlineIdToTokenId(offlineId);
        }

        require(tokenId != 0, "_withdrawErc721, tokenId is 0, maybe should map it before");

        IERC721(erc721Token).safeTransferFrom(address(this), owner, tokenId);
        emit WithdrawErc721(erc721Token, owner, tokenId);
    }


    //=================================low level function=========================================================

    function _depositErc20_(address erc20Token, address owner, uint256 amount) internal {
        uint256 temp = IERC20(erc20Token).balanceOf(address(this));
        IERC20(erc20Token).safeTransferFrom(owner, address(this), amount);
        amount = IERC20(erc20Token).balanceOf(address(this)).sub(temp);
        emit DepositErc20(erc20Token, owner, owner, amount);
    }

    //the caller deposit 'amount' erc20 tokens from 'from' on behalf of 'to'
    function _depositErc20From_(address erc20Token, address from, address owner, uint256 amount) internal {
        uint256 temp = IERC20(erc20Token).balanceOf(address(this));
        IERC20(erc20Token).safeTransferFrom(from, address(this), amount);
        amount = IERC20(erc20Token).balanceOf(address(this)).sub(temp);
        emit DepositErc20(erc20Token, from, owner, amount);
    }

    function _withdrawErc20_(address erc20Token, address owner, uint256 amount) internal {
        IERC20(erc20Token).safeTransfer(owner, amount);
        emit WithdrawErc20(erc20Token, owner, amount);
    }

    //***********************************************************

    function _depositErc1155_(address erc1155Token, address owner, uint256 tokenId, uint256 amount) internal {
        IERC1155(erc1155Token).safeTransferFrom(owner, address(this), tokenId, amount, "");
        emit DepositErc1155(erc1155Token, owner, owner, tokenId, amount);
    }

    function _depositErc1155From_(address erc1155Token, address from, address owner, uint256 tokenId, uint256 amount) internal {
        IERC1155(erc1155Token).safeTransferFrom(from, address(this), tokenId, amount, "");
        emit DepositErc1155(erc1155Token, from, owner, tokenId, amount);
    }

    function _withdrawErc1155_(address erc1155Token, address owner, uint256 tokenId, uint256 amount) internal {
        IERC1155(erc1155Token).safeTransferFrom(address(this), owner, tokenId, amount, "");
        emit WithdrawErc1155(erc1155Token, owner, tokenId, amount);
    }

    //***********************************************************

    function _depositErc721_(address erc721Token, address owner, uint256 tokenId) internal {
        IERC721(erc721Token).safeTransferFrom(owner, address(this), tokenId);
        emit DepositErc721(erc721Token, owner, owner, tokenId);
    }

    function _depositErc721From_(address erc721Token, address from, address owner, uint256 tokenId) internal {
        IERC721(erc721Token).safeTransferFrom(from, address(this), tokenId);
        emit DepositErc721(erc721Token, from, owner, tokenId);
    }

    function _withdrawErc721_(address erc721Token, address owner, uint256 tokenId) internal {
        IERC721(erc721Token).safeTransferFrom(address(this), owner, tokenId);
        emit WithdrawErc721(erc721Token, owner, tokenId);
    }
}
