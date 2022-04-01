// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./HERC20IMLayout.sol";
import "../ownable/OwnableLogic.sol";
import "../accessControlRef/AccessControlRefLogic.sol";
import "../reentrancy/ReentrancyLogic.sol";
import "../erc20/HERC20Logic.sol";
import "./HERC20IMInterface.sol";

import "../accessControl/AccessControlInterface.sol";

abstract contract HERC20IMLogic is HERC20IMLayout, OwnableLogic, AccessControlRefLogic, ReentrancyLogic, HERC20Logic, HERC20IMInterface {
    using SafeMath for uint256;

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
    function _mintNormal(uint256 amount) internal onlyOnce {
        _mint(msg.sender, amount);
    }

    function _mintSudo(address to, uint256 amount) internal enableSudoMint onlyOnce {
        _mint(to, amount);
    }

    //for non-sudo burn, the "from" must be the msg.sender
    function _burnNormal(uint256 amount) internal onlyOnce {
        _burn(msg.sender, amount);
    }

    function _burnSudo(address from, uint256 amount) internal enableSudoBurn onlyOnce {
        _burn(from, amount);
    }

    //=====

    function setAccessControl(address accessControl_) override external onlyOwner {
        _setAccessControl(accessControl_);
        emit SetAccessControl(accessControl_);
    }

    function setSupport(bool supportTransfer_, bool supportMint_, bool supportBurn_) override external onlyOwner {
        _supportTransfer = supportTransfer_;
        _supportMint = supportMint_;
        _supportBurn = supportBurn_;
        emit SetSupport(supportTransfer_, supportMint_, supportBurn_);
    }

    //==================================

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

    //privilege overrides block and supportTransfer
    function _beforeTokenTransfer(address from, address to, uint256 amount) virtual override(HERC20Logic) internal {

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

    unchecked{_transferTxs = _transferTxs + 1;}


        //unreasonable to hit the 2^256 :)
        bool flag;
        (flag, _transferAmounts) = _transferAmounts.tryAdd(amount);
        if (flag) {
            _transferAmounts = type(uint256).max;
        }

        if (!_interactAccount[from]) {
            _interactAccount[from] = true;
        unchecked{_interactAmounts = _interactAmounts.add(1);}
        }

        HERC20Logic._beforeTokenTransfer(from, to, amount);

    }
}
