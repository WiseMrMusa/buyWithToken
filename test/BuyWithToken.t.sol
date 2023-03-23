// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/BuyWithToken.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract BuyWithTokenTest is Test {
    BuyWithToken market;

    function setUp() public {
        uint256 mainnet = vm.createFork("https://eth-mainnet.g.alchemy.com/v2/Bpgb9sxlII8NJjFOZCcMlnqzsK5dKk0L", 16890919);
        vm.selectFork(mainnet);
        market = new BuyWithToken();
    }

    function testListAsset() public {
        vm.startPrank(0xC8E04d79c9b84ccE230b7495B57b25F8c59A27be);
        IERC721(0x6B5d28442aF2444F66F8f2883Df30089E3fb840E).approve(address(market),31);
        market.listAsset(0x6B5d28442aF2444F66F8f2883Df30089E3fb840E,31,20);
        assertEq(IERC721(0x6B5d28442aF2444F66F8f2883Df30089E3fb840E).ownerOf(31),address(market));
        vm.stopPrank();
        
    }

    // function testApprove() public {
    //     vm.prank(0x748dE14197922c4Ae258c7939C7739f3ff1db573);
    //     IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7).approve(address(market),2000000000);
    // }

    function testBuyAssetWithUSDT() public {
        testListAsset();
        vm.deal(0x748dE14197922c4Ae258c7939C7739f3ff1db573,10000000 ether);
        vm.startPrank(0x748dE14197922c4Ae258c7939C7739f3ff1db573);
        IERC20(0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984).approve(address(market), 100000000000000000000000000);
        market.buyAssetWithToken(1, "UNI");    
    }

    // function testExchange() public view {
    //     market.getSwapTokenPrice("ETH","USDT",1);
    //     // console.log(us);
    //     // buy.getSwapTokenPrice("DAI","GBP",8,500);
    //     // buy.getSwapTokenPrice("FORTH","LINK",8,200);
    //     // buy.getSwapTokenPrice("CZK","BTC",8,1000);
    //     // buy.getSwapTokenPrice("JPY","EUR",8,75);
    //     // buy.getSwapTokenPrice("ETH","USDC",8,3.2 ether);

    //     // 614_880_141_589_000_000_000_000_000_000
    //     // 1756.80_040_454
    //     // 1756.80_040_454
    // }

}
