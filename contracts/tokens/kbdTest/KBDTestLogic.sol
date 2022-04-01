// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./KBDTestLayout.sol";
import "../../depends/erc20improved/HERC20IMLogic.sol";
import "./KBDTestInterface.sol";

import "./KBDTestType.sol";

contract KBDTestLogic is Delegate, KBDTestLayout, HERC20IMLogic, KBDTestInterface {
    using SafeMath for uint256;

    function mintNormal(uint256) override pure external {
        revert("unsupported?");
    }

    function mintSudo(address to, uint256 amount) override external onlyAuth {
        _mintSudo(to, amount);
    }

    function burnNormal(uint256) override pure external {
        revert("unsupported?");
    }

    function burnSudo(address from, uint256 amount) override external onlyAuth {
        _burnSudo(from, amount);
    }
}
