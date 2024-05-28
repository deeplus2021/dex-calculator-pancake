// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import './interface/IPancakePair.sol';
import './interface/IERC20.sol';

import { Ownable } from './Ownable.sol';
// import './utils/Common.sol';

/**
 * @notice contract for calculate the token price in pancakeswap pool
 *
 * @dev ownable contract
 */
contract PancakeCal is Ownable {
    constructor() Ownable(msg.sender) {}

    function getPoolInfo(
        address pool
    ) public view returns (
        uint256 reserve0,
        uint256 reserve1,
        uint256 decimals0,
        uint256 decimals1,
        string memory symbol0,
        string memory symbol1
    ) {
        // check the pair pool exist or not
        require(pool != address(0), "Requested pool doesn't exist in the pancakeswap");

        address token0 = IPancakePair(pool).token0();
        address token1 = IPancakePair(pool).token1();

        // get the decimals and symbols of pair tokens
        decimals0 = IERC20(token0).decimals();
        decimals1 = IERC20(token1).decimals();
        symbol0 = IERC20(token0).symbol();
        symbol1 = IERC20(token1).symbol();

        // current reserves of token 0, 1 in the pool
        (reserve0, reserve1, ) = IPancakePair(pool).getReserves();
    }
}
