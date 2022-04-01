// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../depends/nameServiceRef/NameServiceRefInterface.sol";
import "./KBDNameServiceRefEvent.sol";

interface KBDNameServiceRefInterface is NameServiceRefInterface, KBDNameServiceRefEvent {

}
