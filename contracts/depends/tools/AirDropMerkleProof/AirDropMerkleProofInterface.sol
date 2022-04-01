// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../preclude/Preclude.sol";

import "../../ownable/OwnableInterface.sol";
import "./AirDropMerkleProofEvent.sol";

interface AirDropMerkleProofInterface is OwnableInterface, AirDropMerkleProofEvent {
    function claimable(bytes32 merkleRoot, address who, uint256 startTime, uint256 endTime)
    view
    external
    returns (
        bool claimAble,
        uint256 claimedAmount
    );

    function claim(uint256 amount, uint256 startTime, uint256 endTime, bytes32[] memory proof) external;

    function setRegistry(bytes32 merkleRoot, address erc20Token, address tokenMiner) external;

    function claimRecords(bytes32 merkleRoot, address who) view external returns (uint256 claimed);

    function registry(bytes32 merkleRoot) view external returns (address erc20Token);

    function erc20TokenMiner(address erc20Token) view external returns (address tokenMiner);
}
