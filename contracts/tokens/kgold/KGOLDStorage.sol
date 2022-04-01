// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./KGOLDLayout.sol";
import "../../depends/erc20improved/HERC20IMStorage.sol";
import "../../kbdNameServiceRef/KBDNameServiceRefStorage.sol";

import "./KGOLDType.sol";

contract KGOLDStorage is Proxy, KGOLDLayout, HERC20IMStorage, KBDNameServiceRefStorage {

    constructor(
        address accessControl_,
        address owner_
    )
    Proxy(msg.sender)
    KBDNameServiceRefStorage(accessControl_)
    HERC20IMStorage(
        KGOLDType._name_,
        KGOLDType._symbol_,
        KGOLDType._cap_,
        owner_
    ){

    }
}
