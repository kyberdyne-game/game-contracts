// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library KBDNameServiceType {

    bytes32 constant SINGLE_REGISTRY_UNKNOWN = "";
    bytes32 constant S_Miner = "Miner";
    bytes32 constant S_Manager = "Manager";
    bytes32 constant S_DeputyCenter = "DeputyCenter";
    bytes32 constant S_VRFCenter = "VRFCenter";
    bytes32 constant S_AssetVault = "AssetVault";

    //**************************
    //erc20: kbd
    bytes32 constant S_KBD = "KBD";

    //erc20: kgold
    bytes32 constant S_KGOLD = "KGOLD";

    //erc721: KCARD
    bytes32 constant S_KCARD = "KCARD";

    //***************************************************************************************************

    bytes32 constant MULTIPLE_REGISTRY_UNKNOWN = "";
    bytes32 constant M_Server = "Server";

    //all pools should goes here additionally
    //which means it has ability to mint erc20 or erc721
    bytes32 constant M_NFT_Pool = "Nft-pool";
    //**************************


}
