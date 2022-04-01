// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./KBDManagerEvent.sol";

interface KBDManagerInterface1 is
    //here select needed interface
ContextInterface,
ReentrancyInterface,
OwnableInterface,
KBDNameServiceRefInterface,
    //VRFRefInterface,
    //DeputyRefInterface,
    //AssetVaultInterface,
KBDManagerEvent {

    function setForgeKCardPrice(address[] memory tokens, uint256[] memory prices) external;

    function forgeKCardPrice(address token) view external returns (uint256 price);

    function forgeKCardPending(address who) view external returns (KBDManagerType.ForgeKCardRecord memory);
}
