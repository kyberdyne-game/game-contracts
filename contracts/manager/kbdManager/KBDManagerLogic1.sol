// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./KBDManagerInterface1.sol";
import "../../depends/holders/HERC721HolderLogic.sol";
import "../../depends/holders/HERC1155HolderLogic.sol";
import "./KBDManagerLogicCommon.sol";

contract KBDManagerLogic1 is Delegate, KBDManagerLayout,
    //here select needed logic
ContextLogic,
ReentrancyLogic,
OwnableLogic,
KBDNameServiceRefLogic,
    //VRFRefLogic,
    //DeputyRefLogic,
    //AssetVaultLogic,
HERC721HolderLogic,
HERC1155HolderLogic,
KBDManagerLogicCommon,
KBDManagerInterface1 {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    function setForgeKCardPrice(address[] memory tokens, uint256[] memory prices) override external onlyAuth {
        for (uint256 i = 0; i < tokens.length; i++) {
            _forgeKCardPrice[tokens[i]] = prices[i];
        }

    }

    function forgeKCardPrice(address token) override view external returns (uint256 price){
        return _forgeKCardPrice[token];
    }

    function forgeKCardPending(address who) override view external returns (KBDManagerType.ForgeKCardRecord memory){
        return _forgeKCardPending[who];
    }
}
