// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./KBDManagerEvent.sol";

interface KBDManagerInterface2 is
    //here select needed interface
ContextInterface,
ReentrancyInterface,
OwnableInterface,
KBDNameServiceRefInterface,
    //VRFRefInterface,
DeputyRefInterface,
AssetVaultInterface,
KBDManagerEvent {

}
