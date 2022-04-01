// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./KGOLDLayout.sol";
import "../../depends/erc20improved/HERC20IMLogic.sol";
import "../../kbdNameServiceRef/KBDNameServiceRefLogic.sol";
import "./KGOLDInterface.sol";

contract KGOLDLogic is Delegate, KGOLDLayout, HERC20IMLogic, KBDNameServiceRefLogic, KGOLDInterface {
    using SafeMath for uint256;

    modifier onlyAuthManager() {
        require(
            owner() == msg.sender ||
            _associatedOperators[msg.sender] ||
            manager() == msg.sender,
            "onlyAuthManager");
        _;
    }

    function mintNormal(uint256) override pure external {
        revert("unsupported?");
    }

    function mintSudo(address to, uint256 amount) override external onlyAuthManager {
        _mintSudo(to, amount);
    }

    function burnNormal(uint256) override pure external {
        revert("unsupported?");
    }

    function burnSudo(address from, uint256 amount) override external onlyAuthManager {
        _burnSudo(from, amount);
    }
}
