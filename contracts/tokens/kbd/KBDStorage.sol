// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./KBDLayout.sol";
import "../../depends/erc20improved/HERC20IMStorage.sol";

import "./KBDType.sol";

contract KBDStorage is Proxy, KBDLayout, HERC20IMStorage {

    constructor(
        address accessControl_,
        address owner_
    )
    Proxy(msg.sender)
    AccessControlRefStorage(accessControl_)
    HERC20IMStorage(
        KBDType._name_,
        KBDType._symbol_,
        KBDType._cap_,
        owner_
    ){

    }
}
