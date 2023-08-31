// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@endaoment/Entity.sol";

contract Donatooor {
    enum Platform {
        Endaoment,
        Gitcoin,
        Drips
    }

    address uniswapRouterAddress = 0xE592427A0AEce92De3Edee1F18E0157C05861564;

    function donate(Platform platform, address from, address token_address, uint256 amount, address payable to) public payable {
        ERC20(token_address).transferFrom(from, address(this), amount);
        if (platform == Platform.Endaoment) {
            ERC20 baseToken = Entity(to).baseToken();

            if (ERC20(token_address) != baseToken) {
                //swap to Eth
                uint256 amountOut = swap(token_address, amount, to);
                ERC20(baseToken).approve(to, amountOut);
                Entity(to).donate(amountOut);
            }
        }
    }

    function swap(address token, uint256 amount, address to) public returns (uint256){
        ERC20(token).approve(uniswapRouterAddress, amount);
        ISwapRouter router = ISwapRouter(uniswapRouterAddress);
        uint256 amountOut = router.exactInputSingle(
            ISwapRouter.ExactInputSingleParams(
                token,
                to,
                3000,
                address(this),
                block.timestamp,
                amount,
                0,
                0
            )
        );

        return amountOut;
    }
}



interface ISwapRouter {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Swaps `amountIn` of one token for as much as possible of another token
    /// @param params The parameters necessary for the swap, encoded as `ExactInputSingleParams` in calldata
    /// @return amountOut The amount of the received token
    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);

    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    /// @notice Swaps `amountIn` of one token for as much as possible of another along the specified path
    /// @param params The parameters necessary for the multi-hop swap, encoded as `ExactInputParams` in calldata
    /// @return amountOut The amount of the received token
    function exactInput(ExactInputParams calldata params) external payable returns (uint256 amountOut);

    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Swaps as little as possible of one token for `amountOut` of another token
    /// @param params The parameters necessary for the swap, encoded as `ExactOutputSingleParams` in calldata
    /// @return amountIn The amount of the input token
    function exactOutputSingle(ExactOutputSingleParams calldata params) external payable returns (uint256 amountIn);

    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
    }

    /// @notice Swaps as little as possible of one token for `amountOut` of another along the specified path (reversed)
    /// @param params The parameters necessary for the multi-hop swap, encoded as `ExactOutputParams` in calldata
    /// @return amountIn The amount of the input token
    function exactOutput(ExactOutputParams calldata params) external payable returns (uint256 amountIn);
}
