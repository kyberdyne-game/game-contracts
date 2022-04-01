// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../preclude/Preclude.sol";

import "../../ownable/OwnableLayout.sol";

abstract contract AirDropMerkleProofLayout is OwnableLayout {

    //merkle root => erc20 token
    mapping(bytes32 => address) internal _registry;
    //erc20 token => miner address
    mapping(address => address) internal _erc20TokenMiner;
    //merkle root => claimer => claimed amount
    mapping(bytes32 => mapping(address => uint256)) internal _claimRecords;


}
