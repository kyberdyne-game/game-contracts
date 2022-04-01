// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../depends/nameService/NameServiceInterface.sol";
import "./KBDNameServiceEvent.sol";

interface KBDNameServiceInterface is NameServiceInterface, KBDNameServiceEvent {

}
