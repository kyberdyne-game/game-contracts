// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./KBDManagerInterface2.sol";
import "./KBDManagerLogicCommon.sol";

import "../../depends/helperLibrary/ConstantLibrary.sol";


contract KBDManagerLogic2 is Delegate, KBDManagerLayout,
    //here select needed logic
ContextLogic,
ReentrancyLogic,
OwnableLogic,
KBDNameServiceRefLogic,
    //VRFRefLogic,
DeputyRefLogic,
AssetVaultLogic,
    //HERC721HolderLogic,
    //HERC1155HolderLogic,
KBDManagerLogicCommon,
KBDManagerInterface2 {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    /*
   make sure the the manager has "sudo" permit to mint token
   */
    function mintErc20(
        bytes32 erc20TokenName,
        address owner,
        uint256 amount
    ) override external onlyOwnerSelf {
        address erc20Token = ns().getSingleSafe(erc20TokenName);
        _mintErc20(erc20Token, owner, amount);
    }

    function depositErc20(
        bytes32 erc20TokenName,
        address owner,
        uint256 amount
    ) override external onlyOwnerSelf /*onlyOwnerSelfSpecified(owner)*/ {
        address erc20Token = ns().getSingleSafe(erc20TokenName);
        _depositErc20(erc20Token, owner, amount);
    }

    function withdrawErc20(
        bytes32 erc20TokenName,
        address owner,
        uint256 amount
    ) override external onlyOwnerSelf /*onlyEnableDesignatedSenderAndSignerIsServer(owner)*/  {
        address erc20Token = ns().getSingleSafe(erc20TokenName);

        //supply insufficient erc20 token

        _withdrawErc20(erc20Token, owner, amount);
    }

    //==========================================================================================

    function mintErc1155(
        bytes32 erc1155TokenName,
        address owner,
        uint256 tokenId,
        uint256 amount
    ) override external onlyOwnerSelf {
        address erc1155Token = ns().getSingleSafe(erc1155TokenName);
        _mintErc1155(erc1155Token, owner, tokenId, amount);
    }

    function depositErc1155(
        bytes32 erc1155TokenName,
        address owner,
        uint256 tokenId,
        uint256 amount
    ) override external onlyOwnerSelf /*onlyOwnerSelfSpecified(owner)*/ {
        address erc1155Token = ns().getSingleSafe(erc1155TokenName);
        _depositErc1155(erc1155Token, owner, tokenId, amount);
    }

    function withdrawErc1155(
        bytes32 erc1155TokenName,
        address owner,
        uint256 tokenId,
        uint256 amount
    ) override external onlyOwnerSelf /*onlyEnableDesignatedSenderAndSignerIsServer(owner)*/ {
        address erc1155Token = ns().getSingleSafe(erc1155TokenName);
        _withdrawErc1155(erc1155Token, owner, tokenId, amount);
    }

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
    ) override external onlyOwnerSelf /*onlyEnableDeputyAndSignerIsServer*/ {
        address erc721Token = ns().getSingleSafe(erc721TokenName);

        _syncErc721(erc721Token, tokenId, offlineId, attributeNames, uint256Data, bytes32Data, addressData, bytesData);
    }
    /*
    make sure the the manager has "sudo" permit to mint token
    */
    //mint 721 online to OWNER
    function mintErc721(
        bytes32 erc721TokenName,
        address owner
    ) override external onlyOwnerSelf returns (uint256 tokenId) {
        address erc721Token = ns().getSingleSafe(erc721TokenName);

        return _mintErc721(erc721Token, owner);
    }

    //mint offline 721 in VAULT, auto bind the generated tokenId with offlineId
    function mapErc721(
        bytes32 erc721TokenName,
        uint256 offlineId
    ) override external onlyOwnerSelf /*onlyEnableDeputyAndSignerIsServer*/ returns (uint256 tokenId){
        address erc721Token = ns().getSingleSafe(erc721TokenName);

        return _mapErc721(erc721Token, offlineId);
    }

    //bind the tokenId with offlineId
    function bindErc721(
        bytes32 erc721TokenName,
        uint256 tokenId,
        uint256 offlineId
    ) override external onlyOwnerSelf /*onlyEnableDeputyAndSignerIsServer*/ {
        address erc721Token = ns().getSingleSafe(erc721TokenName);

        _bindErc721(erc721Token, tokenId, offlineId);
    }

    function depositErc721(
        bytes32 erc721TokenName,
        address owner,
        uint256 tokenId,
        uint256 offlineId
    ) override external onlyOwnerSelfSpecified(owner) {
        address erc721Token = ns().getSingleSafe(erc721TokenName);

        _depositErc721(erc721Token, owner, tokenId, offlineId);

    }

    /*
    withdraw tokenId from vault
    */
    function withdrawErc721(
        bytes32 erc721TokenName,
        address owner,
        uint256 tokenId,
        uint256 offlineId
    ) override external onlyOwnerSelf /*onlyEnableDesignatedSenderAndSignerIsServer(owner)*/ {
        address erc721Token = ns().getSingleSafe(erc721TokenName);

        _withdrawErc721(erc721Token, owner, tokenId, offlineId);
    }
}
