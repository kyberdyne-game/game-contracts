// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../preclude/Preclude.sol";

import '@openzeppelin/contracts/security/ReentrancyGuard.sol';

contract AirDrop is ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address payable;

    function airDropBatch(address erc20Token, address[] calldata targets, uint256 amount) payable external nonReentrant {
        if (address(erc20Token) == address(0)) {
            for (uint256 i = 0; i < targets.length; i++) {
                payable(targets[i]).sendValue(amount);
            }

        } else {
            for (uint256 i = 0; i < targets.length; i++) {
                IERC20(erc20Token).safeTransferFrom(msg.sender, targets[i], amount);
            }
        }
    }

    function airDropIndividual(address erc20Token, address[] calldata targets, uint256[] calldata amounts) payable external nonReentrant {
        require(targets.length == amounts.length, "length not match");
        if (address(erc20Token) == address(0)) {
            for (uint256 i = 0; i < targets.length; i++) {
                payable(targets[i]).sendValue(amounts[i]);
            }

        } else {
            for (uint256 i = 0; i < targets.length; i++) {
                IERC20(erc20Token).safeTransferFrom(msg.sender, targets[i], amounts[i]);
            }
        }
    }
}
