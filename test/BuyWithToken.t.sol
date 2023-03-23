// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/BuyWithToken.sol";

contract BuyWithTokenTest is Test {
    BuyWithToken buy;

    function setUp() public {
        uint256 mainnet = vm.createFork("https://eth-mainnet.g.alchemy.com/v2/Bpgb9sxlII8NJjFOZCcMlnqzsK5dKk0L", 15_171_037);
        vm.selectFork(mainnet);

        buy = new BuyWithToken();
        // buy.addTokenDetails("BTC",8, 0xA39434A63A52E749F02807ae27335515BA4b07F7,address(0));
        // // buy.addTokenDetails("CZK",0xAE45DCb3eB59E27f05C170752B218C6174394Df8);
        // // buy.addTokenDetails("DAI",0x0d79df66BE487753B02D015Fb622DED7f0E9798d);
        // buy.addTokenDetails("ETH",18,0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e, address(0));
        // buy.addTokenDetails("EUR",0x44390589104C9164407A0E0562a9DBe6C24A0E05);
        // buy.addTokenDetails("FORTH",0x7A65Cf6C2ACE993f09231EC1Ea7363fb29C13f2F);
        // buy.addTokenDetails("GBP",0x73D9c953DaaB1c829D01E1FC0bd92e28ECfB66DB);
        // buy.addTokenDetails("JPY",0x982B232303af1EFfB49939b81AD6866B2E4eeD0B);
        // buy.addTokenDetails("LINK",0x48731cF7e84dc94C5f84577882c14Be11a5B7456);
        // buy.addTokenDetails("USDC",0xAb5c49580294Aff77670F839ea425f5b78ab3Ae7);
        // buy.addTokenDetails("XAU",0x7b219F57a8e9C7303204Af681e9fA69d17ef626f);
    }

    function testExchange() public view {
        buy.getSwapTokenPrice("ETH","USDT",2);
        // buy.getSwapTokenPrice("DAI","GBP",8,500);
        // buy.getSwapTokenPrice("FORTH","LINK",8,200);
        // buy.getSwapTokenPrice("CZK","BTC",8,1000);
        // buy.getSwapTokenPrice("JPY","EUR",8,75);
        // buy.getSwapTokenPrice("ETH","USDC",8,3.2 ether);
    }

}
