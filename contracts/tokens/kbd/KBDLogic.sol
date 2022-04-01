// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./KBDLayout.sol";
import "../../depends/erc20improved/HERC20IMLogic.sol";
import "./KBDInterface.sol";

import "./KBDType.sol";

contract KBDLogic is Delegate, KBDLayout, HERC20IMLogic, KBDInterface {
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
