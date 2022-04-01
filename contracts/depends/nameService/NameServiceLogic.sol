// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./NameServiceLayout.sol";
import "../accessControl/AccessControlLogic.sol";
import "./NameServiceInterface.sol";

contract NameServiceLogic is NameServiceLayout, AccessControlLogic, NameServiceInterface {

    function isMulti(bytes32 keyName, address which) override view external returns (bool){
        return _multiRegistry[keyName][which];
    }

    function getSingle(bytes32 keyName) override view external returns (address){
        return _singleRegistry[keyName];
    }

    function getSingleSafe(bytes32 keyName) override view external returns (address){
        address ret = _singleRegistry[keyName];
        require(ret != address(0), string(abi.encodePacked("getSingleSafe, keyName not set: ", keyName)));
        return ret;
    }

    //==========

    function setMulti(bytes32 keyName, address which, bool flag) override external onlyOwner {
        _multiRegistry[keyName][which] = flag;
    }

    function setSingle(bytes32 keyName, address which) override external onlyOwner {
        _singleRegistry[keyName] = which;
    }

}
