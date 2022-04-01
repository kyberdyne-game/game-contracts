// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./HERC4610IMLayout.sol";
import "../ownable/OwnableLogic.sol";
import "../accessControlRef/AccessControlRefLogic.sol";
import "../reentrancy/ReentrancyLogic.sol";
import "../erc4610/HERC4610Logic.sol";
import "./HERC4610IMInterface.sol";

import "../accessControl/AccessControlInterface.sol";


abstract contract HERC4610IMLogic is HERC4610IMLayout, OwnableLogic, AccessControlRefLogic, ReentrancyLogic, HERC4610Logic, HERC4610IMInterface {
    using Counters for Counters.Counter;

    using Strings for uint256;
    using SafeMath for uint256;
    using Address for address;

    //have to cooperator with onlyOnce() !!!!!!!!!!!
    modifier enableSudoMint(){
        _sudoMint = true;
        _;
        _sudoMint = false;
    }

    //have to cooperator with onlyOnce() !!!!!!!!!!!
    modifier enableSudoBurn(){
        _sudoBurn = true;
        _;
        _sudoBurn = false;
    }

    //for non-sudo mint, the "to" must be the msg.sender
    function _mintNormal(uint256 tokenId, uint256 offlineId) internal onlyOnce returns (uint256){

        if (tokenId == 0) {
            //starts from 1
            _tokenIdCounter.increment();
            tokenId = _tokenIdCounter.current();
        }

        _mint(msg.sender, tokenId);
        emit Mint(msg.sender, tokenId);

        if (offlineId != 0) {
            _bind(tokenId, offlineId);
        }

        return tokenId;
    }

    //=========================================

    function _mintSudo(address to, uint256 tokenId, uint256 offlineId) internal enableSudoMint onlyOnce returns (uint256){

        if (tokenId == 0) {
            //starts from 1
            _tokenIdCounter.increment();
            tokenId = _tokenIdCounter.current();
        }

        _mint(to, tokenId);
        emit Mint(to, tokenId);

        if (offlineId != 0) {
            _bind(tokenId, offlineId);
        }

        return tokenId;
    }

    //=========================================

    //for non-sudo burn, the "from" must be the msg.sender
    function _burnNormal(uint256 tokenId) internal onlyOnce {
        require(_exists(tokenId), "tokenId does not exist");
        require(ownerOf(tokenId) == msg.sender, "can only burn tokenId belongs to yourself");

        _unbind(tokenId);

        _burn(tokenId);

        emit Burn(msg.sender, tokenId);

    }

    //for non-sudo burn, the "from" must be the msg.sender
    function _burnSudo(uint256 tokenId) internal enableSudoBurn onlyOnce {
        require(_exists(tokenId), "tokenId does not exist");

        _unbind(tokenId);

        address owner = ownerOf(tokenId);
        _burn(tokenId);

        emit Burn(owner, tokenId);

    }

    function _bind(uint256 tokenId, uint256 offlineId) internal {
        require(_exists(tokenId), "bind tokenId does not exist");
        require(tokenId != 0 && offlineId != 0, "bind, param error");

        uint256 boundenTokenId = _offlineIdsToTokenIds[offlineId];
        uint256 boundenOfflineId = _tokenIdsToOfflineIds[tokenId];
        if (boundenTokenId == tokenId && boundenOfflineId == offlineId) {
            //keep the bind relationship
        } else if (boundenTokenId == 0 && boundenOfflineId == 0) {
            _offlineIdsToTokenIds[offlineId] = tokenId;
            _tokenIdsToOfflineIds[tokenId] = offlineId;
        } else {
            revert("bind offlineId to tokenId fails");
        }
    }

    function _unbind(uint256 tokenId) internal {
        require(_exists(tokenId), "unbind tokenId does not exist");

        uint256 boundenOfflineId = _tokenIdsToOfflineIds[tokenId];
        if (boundenOfflineId != 0) {
            _offlineIdsToTokenIds[boundenOfflineId] = 0;
            _tokenIdsToOfflineIds[tokenId] = 0;
        }
    }

    function _setLock(uint256 tokenId, address locker) internal {
        _tokenLocks[tokenId] = locker;
    }

    function _setUint256Attribute(bytes32 attributeName, uint256 tokenId, uint256 attributeValue) internal {
        _fixedAttribute[attributeName][tokenId] = bytes32(attributeValue);
    }

    function _setBytes32Attribute(bytes32 attributeName, uint256 tokenId, bytes32 attributeValue) internal {
        _fixedAttribute[attributeName][tokenId] = attributeValue;
    }

    function _setAddressAttribute(bytes32 attributeName, uint256 tokenId, address attributeValue) internal {
        _fixedAttribute[attributeName][tokenId] = bytes32(uint256(uint160(attributeValue)));
    }

    function _setBytesAttribute(bytes32 attributeName, uint256 tokenId, bytes memory attributeValue) internal {
        _dynamicAttribute[attributeName][tokenId] = attributeValue;
    }

    //==================================

    function freeze(uint256 tokenId, address unlocker) override virtual external {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "_lock caller is not owner nor approved");
        require(_tokenLocks[tokenId] == address(0), "has been locked");
        _setLock(tokenId, unlocker);

        emit Freeze(unlocker, tokenId);
    }

    function thaw(uint256 tokenId) override virtual external {
        require(_tokenLocks[tokenId] == _msgSender(), "you are not the unlocker, or the token is not locked");
        _setLock(tokenId, address(0));

        emit Thaw(_msgSender(), tokenId);
    }

    function setAccessControl(address accessControl_) override external onlyOwner {
        _setAccessControl(accessControl_);
    }

    function setSupport(bool supportTransfer_, bool supportMint_, bool supportBurn_) override external onlyOwner {
        _supportTransfer = supportTransfer_;
        _supportMint = supportMint_;
        _supportBurn = supportBurn_;
    }

    //==========

    function frozen(uint256 tokenId) override view external returns (address){
        return _tokenLocks[tokenId];
    }

    //zero for unbound or not existence
    function offlineIdToTokenId(uint256 offlineId) override view external returns (uint256){
        return _offlineIdsToTokenIds[offlineId];
    }

    //zero for unbound or not existence
    function tokenIdToOfflineId(uint256 tokenId) override view external returns (uint256){
        return _tokenIdsToOfflineIds[tokenId];
    }

    function exists(uint256 tokenId) override view external returns (bool) {
        return _exists(tokenId);
    }

    function getUint256Attribute(bytes32 attributeName, uint256 tokenId) override view external returns (uint256) {
        return uint256(_fixedAttribute[attributeName][tokenId]);
    }

    function getBytes32Attribute(bytes32 attributeName, uint256 tokenId) override view external returns (bytes32) {
        return _fixedAttribute[attributeName][tokenId];
    }

    function getAddressAttribute(bytes32 attributeName, uint256 tokenId) override view external returns (address)  {
        return address(uint160(uint256(_fixedAttribute[attributeName][tokenId])));
    }

    function getBytesAttribute(bytes32 attributeName, uint256 tokenId) override view external returns (bytes memory)  {
        return _dynamicAttribute[attributeName][tokenId];
    }

    function support() override view external returns (bool supportTransfer, bool supportMint, bool supportBurn){
        return (_supportTransfer, _supportMint, _supportBurn);
    }

    function transferTxs() override view external returns (uint256) {
        return _transferTxs;
    }

    function interactAmounts() override view external returns (uint256){
        return _interactAmounts;
    }

    function isInteracted(address who) override view external returns (bool){
        return _interactAccount[who];
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) virtual override(HERC721Logic) internal {

        require(_tokenLocks[tokenId] == address(0), "can not transfer locked token");

        if (from == address(0) && to != address(0)) {
            require(tokenId != uint256(0), "tokenId can not be zero");
            //mint mode
            //some how you call _mint :) , you must have done job of mint permission
            if (_supportMint) {

                if (_accessControl != address(0)) {

                    AccessControlInterface ac = ac();

                    if (_sudoMint) {
                        //pass

                    } else {
                        if (ac.isPrivileged(to)) {
                            //privilege overrides blockList
                        } else if (ac.isBlocked(to)) {
                            revert("does not support mint commonly to whom is blocked");
                        } else {
                            //normal, pass
                        }
                    }
                } else {
                    //ns not set, whoever pass
                }

            } else {
                //not support mint
                if (_accessControl != address(0)) {
                    AccessControlInterface ac = ac();

                    if (_sudoMint) {
                        //pass
                    } else {
                        if (ac.isPrivileged(to)) {
                            //privilege pass
                        } else {
                            revert("does not support mint commonly w/ ns");
                        }
                    }

                } else {
                    if (_sudoMint) {
                        //pass
                    } else {
                        revert("does not support mint w/o ns");
                    }
                }
            }
        } else if (from != address(0) && to == address(0)) {
            //burn mode

            if (_supportBurn) {

                if (_accessControl != address(0)) {

                    //burn invoked by normal msg.sender
                    AccessControlInterface ac = ac();

                    if (_sudoBurn) {
                        //pass
                    } else {
                        if (ac.isPrivileged(from)) {
                            //privilege overrides blockList
                        } else if (ac.isBlocked(from)) {
                            revert("does not support burn commonly from whom is blocked");
                        } else {
                            //normal, pass
                        }
                    }
                } else {
                    //ns not set, whoever pass
                }

            } else {

                if (_accessControl != address(0)) {
                    AccessControlInterface ac = ac();

                    if (_sudoBurn) {
                        //pass
                    } else {
                        if (ac.isPrivileged(from)) {
                            //privilege pass
                        } else {
                            revert("does not support burn commonly w/ ns");
                        }
                    }

                } else {
                    if (_sudoBurn) {
                        //pass
                    } else {
                        revert("does not support burn w/o ns");
                    }
                }
            }

        } else if (from != address(0) && to != address(0)) {
            //normal transfer
            if (_supportTransfer) {
                if (_accessControl != address(0)) {

                    AccessControlInterface ac = ac();

                    if (ac.isPrivileged(from) || ac.isPrivileged(to)) {
                        //privilege overrides blockList
                    } else if (ac.isBlocked(from) || ac.isBlocked(to)) {
                        revert("block");
                    } else {
                        //normal, pass
                    }

                } else {
                    //ns not set, pass
                }

            } else {
                //not support transfer
                if (_accessControl != address(0)) {
                    AccessControlInterface ac = ac();

                    if (ac.isPrivileged(from) || ac.isPrivileged(to)) {
                        //privilege pass
                    } else {
                        revert("does not support transfer w/ ns");
                    }
                } else {
                    //ns not set, revert
                    revert("does not support transfer w/o ns");
                }
            }
        } else {
            revert("transfer, 'from' and 'to' should never be 0 at one time");
        }


        //impossible to hit the 2^256 :)
        _transferTxs = _transferTxs.add(1);

        if (!_interactAccount[from]) {
            _interactAccount[from] = true;
            _interactAmounts = _interactAmounts.add(1);
        }

        HERC721Logic._beforeTokenTransfer(from, to, tokenId);
    }

}
