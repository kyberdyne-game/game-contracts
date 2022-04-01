// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library KBDManagerType {

    struct ForgeKCardRecord{
        uint256 amountLeft;
        bytes32 seed;
        uint256 indexToMint;
    }
}
