// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/BuyWithToken.sol";

contract BuyWithTokenTest is Test {
    BuyWithToken market;

    function setUp() public {
        uint256 mainnet = vm.createFork("https://eth-mainnet.g.alchemy.com/v2/Bpgb9sxlII8NJjFOZCcMlnqzsK5dKk0L", 16_889_761);
        vm.selectFork(mainnet);
        market = new BuyWithToken();
    }

    function testExchange() public view {
        market.getSwapTokenPrice("ETH","USDT",1);
        // console.log(us);
        // buy.getSwapTokenPrice("DAI","GBP",8,500);
        // buy.getSwapTokenPrice("FORTH","LINK",8,200);
        // buy.getSwapTokenPrice("CZK","BTC",8,1000);
        // buy.getSwapTokenPrice("JPY","EUR",8,75);
        // buy.getSwapTokenPrice("ETH","USDC",8,3.2 ether);

        // 614_880_141_589_000_000_000_000_000_000
        // 1756.80_040_454
        // 1756.80_040_454
    }

}
