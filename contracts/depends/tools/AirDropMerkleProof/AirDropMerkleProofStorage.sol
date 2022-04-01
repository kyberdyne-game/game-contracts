// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./AirDropMerkleProofLayout.sol";
import "../../ownable/OwnableStorage.sol";

contract AirDropMerkleProofStorage is Proxy, AirDropMerkleProofLayout, OwnableStorage {

    constructor (
        address owner_
    )
    Proxy(msg.sender)
    OwnableStorage(owner_){
    }
}
