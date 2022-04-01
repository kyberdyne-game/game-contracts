// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./HERC1155IMLayout.sol";
import "../ownable/OwnableLogic.sol";
import "../accessControlRef/AccessControlRefLogic.sol";
import "../reentrancy/ReentrancyLogic.sol";
import "../erc1155/HERC1155Logic.sol";
import "./HERC1155IMInterface.sol";

import "../accessControl/AccessControlInterface.sol";

abstract contract HERC1155IMLogic is HERC1155IMLayout, OwnableLogic, AccessControlRefLogic, ReentrancyLogic, HERC1155Logic, HERC1155IMInterface {

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
    function _mintNormal(uint256 id, uint256 amount) internal onlyOnce {
        _mint(msg.sender, id, amount, "");
    }

    //for non-sudo mint, the "to" must be the msg.sender
    function _mintNormal(uint256 id, uint256 amount, bytes memory data) internal onlyOnce {
        _mint(msg.sender, id, amount, data);
    }

    function _mintSudo(address to, uint256 id, uint256 amount) internal enableSudoMint onlyOnce {
        _mint(to, id, amount, "");
    }

    function _mintSudo(address to, uint256 id, uint256 amount, bytes memory data) internal enableSudoMint onlyOnce {
        _mint(to, id, amount, data);
    }

    //==

    //for non-sudo burn, the "from" must be the msg.sender
    function _burnNormal(uint256 id, uint256 amount) internal onlyOnce {
        _burn(msg.sender, id, amount);
    }

    function _burnSudo(address from, uint256 id, uint256 amount) internal enableSudoBurn onlyOnce {
        _burn(from, id, amount);
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

    function support() override view external returns (bool supportTransfer, bool supportMint, bool supportBurn){
        return (_supportTransfer, _supportMint, _supportBurn);
    }

    function transferTxs() override view external returns (uint256) {
        return _transferTxs;
    }

    function transferAmounts() override view external returns (uint256) {
        return _transferAmounts;
    }

    function interactAmounts() override view external returns (uint256){
        return _interactAmounts;
    }

    function isInteracted(address who) override view external returns (bool){
        return _interactAccount[who];
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
    override(HERC1155Logic)
    virtual
    internal
    {

        if (from == address(0) && to != address(0)) {
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

        for (uint256 i = 0; i < amounts.length; i++) {
            _transferAmounts = _transferAmounts.add(amounts[i]);
        }

        if (!_interactAccount[from]) {
            _interactAccount[from] = true;
            _interactAmounts = _interactAmounts.add(1);
        }

        HERC1155Logic._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

}
