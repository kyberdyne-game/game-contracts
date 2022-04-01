// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../depends/erc20improved/HERC20IMInterface.sol";
import "../../kbdNameServiceRef/KBDNameServiceRefInterface.sol";
import "./KGOLDEvent.sol";

interface KGOLDInterface is HERC20IMInterface, KBDNameServiceRefInterface, KGOLDEvent {

}
