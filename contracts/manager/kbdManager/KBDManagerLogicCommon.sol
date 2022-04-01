// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./KBDManagerLayout.sol";

import "../../depends/context/ContextLogic.sol";
import "../../depends/reentrancy/ReentrancyLogic.sol";
import "../../depends/ownable/OwnableLogic.sol";
import "../../kbdNameServiceRef/KBDNameServiceRefLogic.sol";
import "../../depends/vrfRef/VRFRefLogic.sol";
import "../../depends/deputyRef/DeputyRefLogic.sol";
import "../../depends/assetVault/AssetVaultLogic.sol";

contract KBDManagerLogicCommon is KBDManagerLayout,
OwnableLogic,
KBDNameServiceRefLogic
{
    using SafeMath for uint256;
    using SafeERC20 for IERC20;



    modifier onlyServer(){
        require(isServer(msg.sender), "onlyServer");
        _;
    }

    modifier onlyOwnerServer(){
        require(msg.sender == owner() || isServer(msg.sender), "onlyOwnerServer");
        _;
    }

    modifier onlyOwnerSelf(){
        require(msg.sender == owner() || msg.sender == address(this), "onlyOwnerSelf");
        _;
    }

    modifier onlyOwnerServerSelf(){
        require(msg.sender == owner() || isServer(msg.sender) || msg.sender == address(this), "onlyOwnerServerSelf");
        _;
    }

    modifier onlyOwnerServerSelfPool(){
        require(
            msg.sender == owner() ||
            isServer(msg.sender) ||
            msg.sender == address(this) ||
            ns().isMulti(KBDNameServiceType.M_NFT_Pool, msg.sender),
            "onlyOwnerServerSelfPool");
        _;
    }

    modifier onlyOwnerSelfPool(){
        require(
            msg.sender == owner() ||
            msg.sender == address(this) ||
            ns().isMulti(KBDNameServiceType.M_NFT_Pool, msg.sender),
            "onlyOwnerSelfPool");
        _;
    }

    modifier onlyOwnerSelfSpecified(address who){
        require(
            msg.sender == owner() ||
            msg.sender == address(this) ||
            msg.sender == who,
            "onlyOwnerSelfSpecified");
        _;
    }
}
