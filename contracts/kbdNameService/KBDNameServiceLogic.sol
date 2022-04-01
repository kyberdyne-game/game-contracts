// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./KBDNameServiceLayout.sol";
import "../depends/nameService/NameServiceLogic.sol";
import "./KBDNameServiceInterface.sol";

contract KBDNameServiceLogic is Delegate, KBDNameServiceLayout, NameServiceLogic, KBDNameServiceInterface {

}
