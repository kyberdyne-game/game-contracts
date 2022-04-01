// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./KBDManagerEvent.sol";

interface KBDManagerInterface3 is
    //here select needed interface
ContextInterface,
ReentrancyInterface,
OwnableInterface,
KBDNameServiceRefInterface,
    //VRFRefInterface,
DeputyRefInterface,
    //AssetVaultInterface,
KBDManagerEvent {

    //reward KGold from offline server
    function rewardKGold(
        address owner,
        uint256 amount
    ) external;

    //user deposit KGold to offline
    function depositKGold(
        uint256 amount
    ) external;

    //server approve to withdraw KGold back to online user
    function withdrawKGold(
        uint256 amount
    ) external;

    //KCARD
    //======================================================

    //user spend certain fee token to PREPARE to mint KCard
    function forgeKCardPay(
        uint256 buyAmount,
        address paymentTokenAddress
    ) external;

    //user requested offline server to get some attributes about KCard minting
    function forgeKCardMint(
        address owner,
        bytes32[] memory checkSeeds,
        bytes[] memory bytesAttributes
    ) external;

    //for browser to get the seeds to further send to offline server to generator attributes about KCard minting
    function forgeKCardMintSeed(address who, uint256 amount) view external returns (bytes32[] memory seeds);

    //sync attributes
    function syncKCard(
        uint256 tokenId,
        uint256 offlineId,
        bytes32[] memory attributeNames,
        uint256[] memory uint256Data,
        bytes32[] memory bytes32Data,
        address[] memory addressData,
        bytes[] memory bytesData
    ) external;

    //offline server create online token which has been generated offline before
    function mapKCard(
        uint256 offlineId,
        bytes memory bytesAttribute
    ) external returns (uint256 tokenId);

    //bind tokenId and offlineId
    function bindKCard(
        uint256 tokenId,
        uint256 offlineId
    ) external;

    //user deposit online KCard
    function depositErc721(
        address owner,
        uint256 tokenId,
        uint256 offlineId
    ) external;

    //server approve user to withdraw offline KCard, the KCard should be [map/bind]+sync before
    function withdrawWithdrawKCard(
        address owner,
        uint256 tokenId,
        uint256 offlineId
    ) external;
}
