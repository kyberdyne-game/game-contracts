// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../preclude/Preclude.sol";

import "../accessControl/AccessControlInterface.sol";
import "./NameServiceEvent.sol";

interface NameServiceInterface is AccessControlInterface, NameServiceEvent {

    function isMulti(bytes32 keyName, address which) view external returns (bool);

    function getSingle(bytes32 keyName) view external returns (address);

    function getSingleSafe(bytes32 keyName) view external returns (address);

    //==========

    function setMulti(bytes32 keyName, address which, bool flag) external;

    function setSingle(bytes32 keyName, address which) external;
}
