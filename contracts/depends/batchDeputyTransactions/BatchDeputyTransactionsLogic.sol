// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./BatchDeputyTransactionsLayout.sol";
import "./BatchDeputyTransactionsInterface.sol";

import "./BatchDeputyTransactionsType.sol";

contract BatchDeputyTransactionsLogic is BatchDeputyTransactionsLayout, BatchDeputyTransactionsInterface {

    function dispatchTransactions(BatchDeputyTransactionsType.BatchTransactions[] memory bTxs) external {
        for (uint256 i = 0; i < bTxs.length; i++) {
            (bool success, bytes memory ret) = bTxs[i].target.call{value : bTxs[i].value}(bTxs[i].callData);
            require(success, string(abi.encodePacked("dispatchTransactions [", i, "] fails: ", ret)));
        }
    }
}
