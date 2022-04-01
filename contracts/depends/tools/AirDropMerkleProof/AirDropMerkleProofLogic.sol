// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./AirDropMerkleProofLayout.sol";
import "../../ownable/OwnableLogic.sol";
import "./AirDropMerkleProofInterface.sol";

import "../../helperLibrary/MerkleProofLibrary.sol";

contract AirDropMerkleProofLogic is Delegate, AirDropMerkleProofLayout, OwnableLogic, AirDropMerkleProofInterface {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    function claimable(bytes32 merkleRoot, address who, uint256 startTime, uint256 endTime)
    view
    external
    returns (
        bool claimAble,
        uint256 claimedAmount
    ){
        claimedAmount = _claimRecords[merkleRoot][who];
        if (claimedAmount != 0) {
            return (true, claimedAmount);
        }

        if (block.timestamp <= startTime || endTime <= block.timestamp) {
            return (false, 0);
        }

        if (_registry[merkleRoot] == address(0)) {
            return (false, 0);
        }

        return (true, 0);
    }

    function claim(uint256 amount, uint256 startTime, uint256 endTime, bytes32[] memory proof) external {
        require(amount > 0, "claim nothing?");
        require(proof.length >= 2, "should have at least one sibling and a root");

        bytes32 root = proof[proof.length - 1];

        address erc20Token = _registry[root];
        require(erc20Token != address(0), "merkle root not registered");

        require(startTime <= block.timestamp, "not started yet");
        require(block.timestamp <= endTime, "finished yet");

        address miner = _erc20TokenMiner[erc20Token];
        require(miner != address(0), "miner has not been set yet");

        require(_claimRecords[root][msg.sender] == 0, "you have claimed");

        bytes32 leaf = keccak256(abi.encode(msg.sender, amount, startTime, endTime));
        require(MerkleProofLibrary.verify(leaf, proof), "merkle proof check fails");

        _claimRecords[root][msg.sender] = amount;

        IERC20(erc20Token).safeTransferFrom(miner, msg.sender, amount);

        emit Claim(msg.sender, erc20Token, amount, root);

    }

    function setRegistry(bytes32 merkleRoot, address erc20Token, address tokenMiner) external onlyOwner {
        _registry[merkleRoot] = erc20Token;
        _erc20TokenMiner[erc20Token] = tokenMiner;
    }

    function claimRecords(bytes32 merkleRoot, address who) view external returns (uint256 claimed){
        return _claimRecords[merkleRoot][who];
    }

    function registry(bytes32 merkleRoot) view external returns (address erc20Token){
        return _registry[merkleRoot];
    }

    function erc20TokenMiner(address erc20Token) view external returns (address tokenMiner){
        return _erc20TokenMiner[erc20Token];
    }
}
