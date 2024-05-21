// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import './interface/IPancakeFactory.sol';
import './interface/IPancakeRouter02.sol';
import './interface/IPancakePair.sol';
import './interface/IERC20.sol';

import { Ownable } from './Ownable.sol';
import './utils/Common.sol';

/**
 * @notice contract for calculate the token price in pancakeswap pool
 *
 * @dev ownable contract
 */
contract PancakeCal is Ownable {
    // value for handling fixed point
    uint256 public DENOMINATOR = 10 ** 8;

    // public contract for pancakeswap factory & router
    IPancakeFactory public pancakeFactory;
    IPancakeRouter02 public pancakeRouter;

    constructor(
        address factory,
        address router
    ) Ownable(msg.sender) {
        pancakeFactory = IPancakeFactory(factory);
        pancakeRouter = IPancakeRouter02(router);
    }

    function getPriceFromPoolTokens(
        address token0,
        address token1
    ) public view returns (
        uint256 price01,
        uint256 price10,
        string memory symbol0,
        string memory symbol1
    ) {
        // get the address of pair pool
        address pool = getPoolAddress(token0, token1);
        require(pool != address(0), "The pool of such tokens doesn't exist");

        // get the decimals of both tokens
        uint256 decimals0 = IERC20(token0).decimals();
        uint256 decimals1 = IERC20(token1).decimals();
        symbol0 = IERC20(token0).symbol();
        symbol1 = IERC20(token1).symbol();

        // get the amount of reserves for both of tokens
        (uint256 _reserve0, uint256 _reserve1, ) = IPancakePair(pool).getReserves();
        (uint256 reserve0, uint256 reserve1) = token0 < token1 ? (_reserve0, _reserve1) : (_reserve1, _reserve0);

        price01 = reserve1 * (10 ** decimals0) * DENOMINATOR / (reserve0 * (10 ** decimals1));
        price10 = reserve0 * (10 ** decimals1) * DENOMINATOR / (reserve1 * (10 ** decimals0));
    }

    function getSwapableTokenAmount(
        address token0,
        address token1,
        uint256 startPrice,
        uint256 endPrice
    ) public view returns (
        uint256 current,
        uint256 startReserve,
        uint256 endReserve,
        uint256 decimals0,
        string memory symbol0,
        string memory symbol1
    ) {
        // check the address of tokens' validity
        require(token0 != address(0), "The address of token cannot be zero address");
        require(token1 != address(0), "The address of token cannot be zero address");

        // get the address of pool
        address pool = getPoolAddress(token0, token1);
        // check the pair pool exist or not
        require(pool != address(0), "Requested pool doesn't exist in the pancakeswap");

        // check the validity of values for price range
        require(
            startPrice != 0 &&
            endPrice != 0 &&
            startPrice < endPrice, "Price range values are invalid");

        // get the decimals and symbols of pair tokens
        decimals0 = IERC20(token0).decimals();
        uint256 decimals1 = IERC20(token1).decimals();
        symbol0 = IERC20(token0).symbol();
        symbol1 = IERC20(token1).symbol();

        // current reserves of token 0, 1 in the pool
        (uint256 _reserve0, uint256 _reserve1, ) = IPancakePair(pool).getReserves();
        (current, ) = token0 < token1 ? (_reserve0, _reserve1) : (_reserve1, _reserve0);
        uint256 k = _reserve0 * _reserve1;

        startReserve = k * DENOMINATOR * (10 ** decimals0) / (startPrice * (10 ** decimals1));
        startReserve = sqrt(startReserve);

        endReserve = k * DENOMINATOR * (10 ** decimals0) / (endPrice * (10 ** decimals1));
        endReserve = sqrt(endReserve);
    }

    /*************************************************
                    utility functions
    *************************************************/
    function getPoolAddress(
        address token0,
        address token1
    ) public view returns (address pool) {
        // check if swap factory was set
        require(address(pancakeFactory) != address(0), "Invalid factory address");

        // get the address of pair pool and returns it
        pool = pancakeFactory.getPair(token0, token1);
    }

    function setFactory(address _factory) external onlyOwner {
        require(_factory != address(0), "Invalid factory address");

        pancakeFactory = IPancakeFactory(_factory);
    }

    function setRouter(address _router) external onlyOwner {
        require(_router != address(0), "Invalid router address");

        pancakeRouter = IPancakeRouter02(_router);
    }
}