// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./Ownable.sol";

import "./interface/ISmartRouter.sol";
import "./interface/IERC20.sol";
import "./interface/IPool.sol";

contract PancakeBuyer is Ownable {
    address public SMART_ROUTER = 0x13f4EA83D0bd40E75C8222255bc855a974568Dd4;

    ISmartRouter internal router;

    constructor() Ownable(msg.sender) {
        router = ISmartRouter(SMART_ROUTER);
    }

    function approveForRouter(address token, uint256 amount) public {
        IERC20 tokenErc = IERC20(token);
        tokenErc.approve(SMART_ROUTER, amount);
    }

    function resetAllowance(address token) public {
        IERC20 tokenErc = IERC20(token);
        tokenErc.approve(SMART_ROUTER, 0);
    }

    function readPool(address poolAddress)
        public
        view
        returns (
            uint256 sqrtPriceX96,
            uint256 liquidity,
            int24 tickSpacing
        )
    {
        IPool pool = IPool(poolAddress);
        IPool.Slot0 memory slot0 = pool.slot0();

        sqrtPriceX96 = slot0.sqrtPriceX96;
        liquidity = pool.liquidity();
        tickSpacing = pool.tickSpacing();
    }

    function exactOutputSingle(
        ISmartRouter.ExactOutputSingleParams calldata params
    )
        public
        returns (
            uint256 amountIn
        )
    {
        IERC20(params.tokenIn).transferFrom(
            msg.sender,
            address(this),
            params.amountInMaximum
        );

        approveForRouter(params.tokenIn, params.amountInMaximum);
        amountIn = router.exactOutputSingle(params);

        if (amountIn < params.amountInMaximum) {
            IERC20(params.tokenIn).transfer(
                msg.sender,
                params.amountInMaximum - amountIn
            );
        }

        resetAllowance(params.tokenIn);
    }

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to
    ) external returns(
        uint256 amountIn
    ) {
        address tokenIn = path[0];

        IERC20(tokenIn).transferFrom(
            msg.sender,
            address(this),
            amountInMax
        );

        approveForRouter(tokenIn, amountInMax);
        amountIn = router.swapTokensForExactTokens(amountOut, amountInMax, path, to);

        if (amountIn < amountInMax) {
            IERC20(tokenIn).transfer(
                msg.sender,
                amountInMax - amountIn
            );
        }

        resetAllowance(tokenIn);
    }

    function setRouter(address _router) external onlyOwner {
        require(_router != address(0), "Invalid zero address");

        SMART_ROUTER = _router;
        router = ISmartRouter(SMART_ROUTER);
    }
}