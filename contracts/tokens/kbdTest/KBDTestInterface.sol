// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../depends/erc20improved/HERC20IMInterface.sol";
import "./KBDTestEvent.sol";

interface KBDTestInterface is HERC20IMInterface, KBDTestEvent {

}
