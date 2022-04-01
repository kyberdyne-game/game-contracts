// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./KCARDLayout.sol";
import "../../depends/erc721improved/HERC721IMLogic.sol";
import "../../kbdNameServiceRef/KBDNameServiceRefLogic.sol";
import "./KCARDInterface.sol";

//KCARD is all minted online
contract KCARDLogic is Delegate, KCARDLayout, HERC721IMLogic, KBDNameServiceRefLogic, KCARDInterface {
    using SafeMath for uint256;

    modifier onlyAuthOrManager{
        require(
            owner() == msg.sender ||
            _associatedOperators[msg.sender] ||
            manager() == msg.sender,
            "onlyAuthOrManager"
        );
        _;
    }

    function mintNormal(uint256, uint256) override pure external returns (uint256){
        revert("unsupported?");
    }

    function mintSudo(address to, uint256 tokenId, uint256 offlineId) override external onlyAuth returns (uint256) {
        return _mintSudo(to, tokenId, offlineId);
    }

    function bind(uint256 tokenId, uint256 offlineId) override external onlyAuth {
        _bind(tokenId, offlineId);
    }

    function unbind(uint256 tokenId) override external onlyAuth {
        _unbind(tokenId);
    }

    //==============================================

    function burnNormal(uint256) override pure external {
        revert("unsupported?");
    }

    function burnSudo(uint256 tokenId) override external onlyAuthOrManager {
        _burnSudo(tokenId);
    }

    function setUint256Attribute(bytes32 attributeName, uint256 tokenId, uint256 attributeValue) override external onlyAuthOrManager {
        _setUint256Attribute(attributeName, tokenId, attributeValue);
    }

    function setBytes32Attribute(bytes32 attributeName, uint256 tokenId, bytes32 attributeValue) override external onlyAuthOrManager {
        _setBytes32Attribute(attributeName, tokenId, attributeValue);
    }

    function setAddressAttribute(bytes32 attributeName, uint256 tokenId, address attributeValue) override external onlyAuthOrManager {
        _setAddressAttribute(attributeName, tokenId, attributeValue);
    }

    function setBytesAttribute(bytes32 attributeName, uint256 tokenId, bytes memory attributeValue) override external onlyAuthOrManager {
        _setBytesAttribute(attributeName, tokenId, attributeValue);
    }

}
