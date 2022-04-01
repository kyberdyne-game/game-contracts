// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../depends/context/ContextLayout.sol";
import "../../depends/reentrancy/ReentrancyLayout.sol";
import "../../depends/ownable/OwnableLayout.sol";
import "../../kbdNameServiceRef/KBDNameServiceRefLayout.sol";
import "../../depends/vrfRef/VRFRefLayout.sol";
import "../../depends/deputyRef/DeputyRefLayout.sol";
import "../../depends/assetVault/AssetVaultLayout.sol";

import "./KBDManagerType.sol";

contract KBDManagerLayout is ContextLayout, ReentrancyLayout, OwnableLayout,
KBDNameServiceRefLayout, VRFRefLayout, DeputyRefLayout, AssetVaultLayout {

    uint256 internal _forgeKCardGlobalNonce;

    mapping(address => uint256) internal _forgeKCardPrice;

    mapping(address => KBDManagerType.ForgeKCardRecord) internal _forgeKCardPending;
}

