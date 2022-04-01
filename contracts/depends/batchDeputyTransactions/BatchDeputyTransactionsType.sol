// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library BatchDeputyTransactionsType {

    struct BatchTransactions {
        address target;
        bytes callData;
        uint256 value;
    }
}
