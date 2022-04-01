// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AirDropMerkleProofEvent {

    event Claim(address indexed claimer, address indexed erc20Token, uint256 amount, bytes32 merkleRoot);

}
