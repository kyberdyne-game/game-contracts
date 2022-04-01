// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library NameServiceType {

    //copy the following declaration into new contract cause the compiler is not so smart for constant reference
    bytes32 constant SINGLE_REGISTRY_UNKNOWN = "";
    bytes32 constant S_Miner = "Miner";
    bytes32 constant S_Manager = "Manager";
    bytes32 constant S_DeputyCenter = "DeputyCenter";
    bytes32 constant S_VRFCenter = "VRFCenter";
    bytes32 constant S_AssetVault = "AssetVault";

    bytes32 constant MULTIPLE_REGISTRY_UNKNOWN = "";
    bytes32 constant M_Server = "Server";

}
