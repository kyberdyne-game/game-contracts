// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./KBDManagerInterface3.sol";
import "./KBDManagerLogicCommon.sol";

import "../../depends/helperLibrary/ConstantLibrary.sol";

import "./KBDManagerInterface2.sol";
import "../../nfts/kcard/KCARDType.sol";

/*
KGOLD, mint
KCARD mint onlin, map, bind .....
*/
contract KBDManagerLogic3 is Delegate, KBDManagerLayout,
    //here select needed logic
ContextLogic,
ReentrancyLogic,
OwnableLogic,
KBDNameServiceRefLogic,
    //VRFRefLogic,
DeputyRefLogic,
    //AssetVaultLogic,
    //HERC721HolderLogic,
    //HERC1155HolderLogic,
KBDManagerLogicCommon,
KBDManagerInterface3 {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    //KGOLD
    //=====================================================

    function rewardKGold(
        address owner,
        uint256 amount
    ) override external onlyEnableDesignatedSenderAndSignerIsServer(owner) {
        KBDManagerInterface2(address(this)).mintErc20(KBDNameServiceType.S_KGOLD, owner, amount);
    }

    function depositKGold(
        uint256 amount
    ) override external {
        KBDManagerInterface2(address(this)).depositErc20(KBDNameServiceType.S_KGOLD, msg.sender, amount);
    }

    function withdrawKGold(
        uint256 amount
    ) override external onlyEnableDesignatedSenderAndSignerIsServer(msg.sender) {

        address erc20Token = ns().getSingleSafe(KBDNameServiceType.S_KGOLD);

        //if the erc20 token is not enough, mint enough immediately if supported
        uint256 have = IERC20(erc20Token).balanceOf(address(this));
        if (have < amount) {
            HERC20IMInterface(erc20Token).mintSudo(address(this), amount.sub(have));
        }

        KBDManagerInterface2(address(this)).withdrawErc20(KBDNameServiceType.S_KGOLD, msg.sender, amount);
    }

    //KCARD
    //======================================================

    function forgeKCardPay(
        uint256 buyAmount,
        address paymentTokenAddress
    ) override external {
        uint256 price = _forgeKCardPrice[paymentTokenAddress];
        require(price > 0, "forgeKCARD, unsupported payment");
        _gatherToken(msg.sender, paymentTokenAddress, price.mul(buyAmount));

        KBDManagerType.ForgeKCardRecord storage record = _forgeKCardPending[msg.sender];

        require(record.amountLeft == 0, "forge bought KCard at first, and then request another request");

        record.amountLeft = buyAmount;
        record.seed = keccak256(abi.encode(msg.sender, "forgeKCardPay", _forgeKCardGlobalNonce));
        _forgeKCardGlobalNonce = _forgeKCardGlobalNonce.add(1);
        record.indexToMint = 1;
    }

    function forgeKCardMint(
        address owner,
        bytes32[] memory checkSeeds,
        bytes[] memory bytesAttributes
    ) override external onlyEnableDesignatedSenderAndSignerIsServer(owner) {

        require(checkSeeds.length == bytesAttributes.length, "param length mismatch");

        KBDManagerType.ForgeKCardRecord storage record = _forgeKCardPending[owner];

        require(checkSeeds.length <= record.amountLeft, "insufficient bought KCard");
        record.amountLeft = record.amountLeft.sub(checkSeeds.length);

        for (uint256 i = 0; i < checkSeeds.length; i++) {
            bytes32 presumptiveSeed = keccak256(abi.encode(record.seed, record.indexToMint));
            require(presumptiveSeed == checkSeeds[i], "seed check fails");
            record.indexToMint = record.indexToMint.add(1);
            _mintKCard(owner, bytesAttributes[i]);
        }

        //if need clear
        if (record.amountLeft == 0) {
            record.seed = 0;
            record.indexToMint = 0;
        }
    }

    function forgeKCardMintSeed(address who, uint256 amount) override view external returns (bytes32[] memory seeds){
        KBDManagerType.ForgeKCardRecord storage record = _forgeKCardPending[who];
        if (record.seed == 0) {
            return new bytes32[](0);
        }

        seeds = new bytes32[](amount);

        uint256 indexToMint = record.indexToMint;
        for (uint256 i = 0; i < amount; i++) {
            bytes32 seed = keccak256(abi.encode(record.seed, record.indexToMint));
            indexToMint = indexToMint.add(1);
            seeds[i] = seed;
        }

        return seeds;
    }

    function _mintKCard(address owner, bytes memory bytesAttribute) internal {
        uint256 tokenId = KBDManagerInterface2(address(this)).mintErc721(KBDNameServiceType.S_KCARD, owner);

        address kcardToken = ns().getSingleSafe(KBDNameServiceType.S_KCARD);
        HERC721IMInterface(kcardToken).setBytesAttribute(KCARDType.attribute_json, tokenId, bytesAttribute);

    }

    function _gatherToken(address from, address tokenAddress, uint256 amount) internal {
        if (tokenAddress == address(0)) {
            require(msg.value >= amount, "insufficient payment");
        } else {
            IERC20(tokenAddress).safeTransferFrom(from, address(this), amount);
        }
    }

    function syncKCard(
        uint256 tokenId,
        uint256 offlineId,
        bytes32[] memory attributeNames,
        uint256[] memory uint256Data,
        bytes32[] memory bytes32Data,
        address[] memory addressData,
        bytes[] memory bytesData
    ) override external onlyEnableDeputyAndSignerIsServer {
        KBDManagerInterface2(address(this)).syncErc721(
            KBDNameServiceType.S_KCARD,
            tokenId,
            offlineId,
            attributeNames,
            uint256Data,
            bytes32Data,
            addressData,
            bytesData
        );
    }

    function mapKCard(
        uint256 offlineId,
        bytes memory bytesAttribute
    ) override external onlyEnableDeputyAndSignerIsServer returns (uint256 tokenId){
        tokenId = KBDManagerInterface2(address(this)).mapErc721(KBDNameServiceType.S_KCARD, offlineId);

        address kcardToken = ns().getSingleSafe(KBDNameServiceType.S_KCARD);
        HERC721IMInterface(kcardToken).setBytesAttribute(KCARDType.attribute_json, tokenId, bytesAttribute);
        return tokenId;
    }

    function bindKCard(
        uint256 tokenId,
        uint256 offlineId
    ) override external onlyEnableDeputyAndSignerIsServer {
        KBDManagerInterface2(address(this)).bindErc721(KBDNameServiceType.S_KCARD, tokenId, offlineId);
    }

    function depositErc721(
        address owner,
        uint256 tokenId,
        uint256 offlineId
    ) override external onlyOwnerSelfSpecified(owner) {
        KBDManagerInterface2(address(this)).depositErc721(KBDNameServiceType.S_KCARD, owner, tokenId, offlineId);
    }

    function withdrawWithdrawKCard(
        address owner,
        uint256 tokenId,
        uint256 offlineId
    ) override external onlyEnableDesignatedSenderAndSignerIsServer(owner) {
        KBDManagerInterface2(address(this)).withdrawErc721(KBDNameServiceType.S_KCARD, owner, tokenId, offlineId);

    }
}
