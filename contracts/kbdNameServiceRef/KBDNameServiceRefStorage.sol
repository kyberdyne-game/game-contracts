// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./KBDNameServiceRefLayout.sol";
import "../depends/nameServiceRef/NameServiceRefStorage.sol";

contract KBDNameServiceRefStorage is KBDNameServiceRefLayout, NameServiceRefStorage {

    constructor (
        address nameService_
    )
    NameServiceRefStorage(nameService_){

    }
}
