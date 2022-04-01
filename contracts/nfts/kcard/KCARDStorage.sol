// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./KCARDLayout.sol";
import "../../depends/erc721improved/HERC721IMStorage.sol";
import "../../kbdNameServiceRef/KBDNameServiceRefStorage.sol";

import "./KCARDType.sol";

contract KCARDStorage is Proxy, KCARDLayout, HERC721IMStorage, KBDNameServiceRefStorage {

    constructor (
        address accessControl_,
        address owner_
    )
    Proxy(msg.sender)
    KBDNameServiceRefStorage(accessControl_)
    HERC721IMStorage(
        KCARDType._name_,
        KCARDType._symbol_,
        KCARDType._uri_,
        owner_
    ){
    }
}
