// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {PancakeBuyer} from "../src/PancakeBuyer.sol";
import {PancakeCal} from "../src/PancakeV2Cal.sol";
import "../src/interface/IERC20.sol";
import "../src/interface/ISmartRouter.sol";

contract MainTest is Test {
    uint256 public mainnetFork;

    PancakeBuyer public buyer;

    address constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address constant USDT = 0x55d398326f99059fF775485246999027B3197955;

    address public alice = makeAddr('Alice');

    function setUp() public {
        mainnetFork = vm.createSelectFork('mainnet');

        buyer = new PancakeBuyer();
    }

    function test_v3swap() public {
        deal(WBNB, alice, 5 ether);

        vm.startPrank(alice);
        IERC20(WBNB).approve(address(buyer), 5 ether);

        ISmartRouter.ExactOutputSingleParams memory param = ISmartRouter.ExactOutputSingleParams({
            tokenIn: WBNB,
            tokenOut: USDT,
            fee: 2500,
            recipient: alice,
            amountOut: 2000000000000000000,
            amountInMaximum: 3500000000000000,
            sqrtPriceLimitX96: 0
        });

        buyer.exactOutputSingle(param);
        vm.stopPrank();
        console.log(IERC20(WBNB).balanceOf(alice));
        console.log(IERC20(USDT).balanceOf(alice));
    }

    function test_v2swap() public {
        deal(WBNB, alice, 5 ether);

        vm.startPrank(alice);
        IERC20(WBNB).approve(address(buyer), 5 ether);
        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = USDT;

        buyer.swapTokensForExactTokens(
            2000000000000000000,
            3500000000000000,
            path,
            alice
        );
        vm.stopPrank();

        console.log(IERC20(WBNB).balanceOf(alice));
        console.log(IERC20(USDT).balanceOf(alice));
    }
}
