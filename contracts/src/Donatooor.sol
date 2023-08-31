// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@endaoment/Entity.sol";
import "@uniswap/v3-periphery/SwapRouter.sol";

contract Donatooor {
    enum Platform {
        Endaoment,
        Gitcoin,
        Drips
    }

    address uniswapRouterAddress = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
    address USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    function donate(Platform platform, address token_address, uint256 amount, uint256 to) public payable {
        token_address
        if (platform == Platform.Endaoment) {
            if (token_address != USDC){
                //swap
                SwapRouter router = SwapRouter(uniswapRouterAddress);

            }
        }
    }
}
