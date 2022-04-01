// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./KBDNameServiceLayout.sol";
import "../depends/nameService/NameServiceStorage.sol";

contract KBDNameServiceStorage is Proxy, KBDNameServiceLayout, NameServiceStorage {

    constructor (
        address owner_
    )
    Proxy(msg.sender)
    NameServiceStorage(owner_){

    }
}
