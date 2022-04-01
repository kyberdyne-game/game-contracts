// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./KCARDEvent.sol";
import "../../depends/erc721improved/HERC721IMInterface.sol";
import "../../kbdNameServiceRef/KBDNameServiceRefInterface.sol";

interface KCARDInterface is HERC721IMInterface, KBDNameServiceRefInterface, KCARDEvent {

}
