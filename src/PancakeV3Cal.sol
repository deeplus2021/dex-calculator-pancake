// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import './interface/IPancakeV3Pool.sol';
import './interface/IERC20.sol';

import { Ownable } from './Ownable.sol';
// import './utils/Common.sol';

/**
 * @notice contract for calculate the token price in pancakeswap pool
 *
 * @dev ownable contract
 */
contract PancakeV3Cal is Ownable {
    constructor() Ownable(msg.sender) {}

    function getPoolInfo(
        address pool
    ) public view returns (
        uint160 sqrtPriceX96,
        address token0,
        address token1
    ) {
        // check the pair pool exist or not
        require(pool != address(0), "Requested pool doesn't exist in the pancakeswap");
        
        (sqrtPriceX96,,,,,,) = IPancakeV3Pool(pool).slot0();
        token0 = IPancakeV3Pool(pool).token0();
        token1 = IPancakeV3Pool(pool).token1();
    }
}
