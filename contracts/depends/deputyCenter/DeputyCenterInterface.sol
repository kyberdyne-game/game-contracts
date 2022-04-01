// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../preclude/Preclude.sol";

import "../ownable/OwnableInterface.sol";
import "../nameServiceRef/NameServiceRefInterface.sol";
import "./DeputyCenterEvent.sol";

interface DeputyCenterInterface is OwnableInterface, NameServiceRefInterface, DeputyCenterEvent {

}
