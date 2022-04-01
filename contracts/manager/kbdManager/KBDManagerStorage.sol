// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./KBDManagerLayout.sol";
import "../../depends/context/ContextStorage.sol";
import "../../depends/reentrancy/ReentrancyStorage.sol";
import "../../depends/ownable/OwnableStorage.sol";
import "../../kbdNameServiceRef/KBDNameServiceRefStorage.sol";
import "../../depends/vrfRef/VRFRefStorage.sol";
import "../../depends/deputyRef/DeputyRefStorage.sol";
import "../../depends/assetVault/AssetVaultStorage.sol";

contract KBDManagerStorage is Proxy, KBDManagerLayout, ContextStorage, ReentrancyStorage, OwnableStorage,
KBDNameServiceRefStorage, VRFRefStorage, DeputyRefStorage, AssetVaultStorage {

    constructor (
        address nameService_,
        address owner_
    )
    Proxy(msg.sender)
    ContextStorage()
    ReentrancyStorage()
    OwnableStorage(owner_)
    KBDNameServiceRefStorage(nameService_)
    VRFRefStorage()
    DeputyRefStorage(){

    }
}
