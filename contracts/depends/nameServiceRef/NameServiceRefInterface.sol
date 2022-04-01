// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../preclude/Preclude.sol";

import "../accessControlRef/AccessControlRefInterface.sol";
import "./NameServiceRefEvent.sol";

interface NameServiceRefInterface is AccessControlRefInterface, NameServiceRefEvent {

}
