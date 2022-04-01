// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../depends/context/ContextInterface.sol";
import "../../depends/reentrancy/ReentrancyInterface.sol";
import "../../depends/ownable/OwnableInterface.sol";
import "../../kbdNameServiceRef/KBDNameServiceRefInterface.sol";
import "../../depends/vrfRef/VRFRefInterface.sol";
import "../../depends/deputyRef/DeputyRefInterface.sol";
import "../../depends/assetVault/AssetVaultInterface.sol";

import "./KBDManagerType.sol";

interface KBDManagerEvent {
}
