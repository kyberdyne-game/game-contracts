// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AssetVaultEvent {

    event MintErc20(address tokenAddress, address owner, uint256 amount);
    event DepositErc20(address /*indexed*/ tokenAddress, address from, address owner, uint256 amount);
    event WithdrawErc20(address /*indexed*/ tokenAddress, address owner, uint256 amount);

    event MintErc1155(address tokenAddress, address owner, uint256 tokenId, uint256 amount);
    event DepositErc1155(address /*indexed*/ tokenAddress, address from, address owner, uint256 tokenId, uint256 amount);
    event WithdrawErc1155(address /*indexed*/ tokenAddress, address owner, uint256 tokenId, uint256 amount);

    event MintErc721(address tokenAddress, address owner, uint256 tokenId);
    event MapErc721(address tokenAddress, uint256 tokenId, uint256 offlineId);
    event BindErc721(address tokenAddress, uint256 tokenId, uint256 offlineId);
    event DepositErc721(address /*indexed*/ tokenAddress, address from, address owner, uint256 tokenId);
    event WithdrawErc721(address /*indexed*/ tokenAddress, address owner, uint256 tokenId);

}
