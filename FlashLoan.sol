// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@uniswap/v3-core/contracts/interfaces/callback/IUniswapV3FlashCallback.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title FlashLoan
 * @notice Implements a flash loan using Uniswap V3
 */
contract FlashLoan is IUniswapV3FlashCallback {
    
    struct FlashCallbackData {
        uint256 amount0;
        uint256 amount1;
        address payer;
    }

    /**
     * @notice Initiates a flash loan
     * @param pool The address of the Uniswap V3 pool to borrow from
     * @param amount0 Amount of token0 to borrow
     * @param amount1 Amount of token1 to borrow
     */
    function initiateFlashLoan(
        address pool,
        uint256 amount0,
        uint256 amount1
    ) external {
        IUniswapV3Pool(pool).flash(
            address(this),
            amount0,
            amount1,
            abi.encode(FlashCallbackData({
                amount0: amount0,
                amount1: amount1,
                payer: msg.sender
            }))
        );
    }

    /**
     * @notice Callback function called by the pool after receiving the flash assets
     */
    function uniswapV3FlashCallback(
        uint256 fee0,
        uint256 fee1,
        bytes calldata data
    ) external override {
        FlashCallbackData memory decoded = abi.decode(data, (FlashCallbackData));

        // 1. Logic goes here (e.g., Arbitrage across another DEX)
        // Perform swaps, liquidations, etc.

        // 2. Repay the loan + fee
        if (decoded.amount0 > 0) {
            IERC20(IUniswapV3Pool(msg.sender).token0()).transfer(
                msg.sender, 
                decoded.amount0 + fee0
            );
        }
        if (decoded.amount1 > 0) {
            IERC20(IUniswapV3Pool(msg.sender).token1()).transfer(
                msg.sender, 
                decoded.amount1 + fee1
            );
        }
    }
}
