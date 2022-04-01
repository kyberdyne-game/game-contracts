// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../preclude/Preclude.sol";

import "../accessControl/AccessControlLayout.sol";

abstract contract NameServiceLayout is AccessControlLayout {

    mapping(bytes32 => address) _singleRegistry;
    mapping(bytes32 => mapping(address => bool)) _multiRegistry;

}
