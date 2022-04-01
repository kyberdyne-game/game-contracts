// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./KBDNameServiceRefLayout.sol";
import "../depends/nameServiceRef/NameServiceRefLogic.sol";
import "./KBDNameServiceRefInterface.sol";

import "../kbdNameService/KBDNameServiceType.sol";

contract KBDNameServiceRefLogic is KBDNameServiceRefLayout, NameServiceRefLogic, KBDNameServiceRefInterface {

    function kbd() view internal returns (address){
        return ns().getSingleSafe(KBDNameServiceType.S_KBD);
    }

    function kgold() view internal returns (address){
        return ns().getSingleSafe(KBDNameServiceType.S_KGOLD);
    }

    function kcard() view internal returns (address){
        return ns().getSingleSafe(KBDNameServiceType.S_KCARD);
    }
}
