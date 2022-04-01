// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./KBDTestLayout.sol";
import "../../depends/erc20improved/HERC20IMStorage.sol";

import "./KBDTestType.sol";

contract KBDTestStorage is Proxy, KBDTestLayout, HERC20IMStorage {

    constructor(
        address accessControl_,
        address owner_
    )
    Proxy(msg.sender)
    AccessControlRefStorage(accessControl_)
    HERC20IMStorage(
        KBDTestType._name_,
        KBDTestType._symbol_,
        KBDTestType._cap_,
        owner_
    ){

    }
}
