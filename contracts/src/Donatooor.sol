// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "solady/tokens/WETH.sol";

contract Donatooor {
    enum Platform {
        Endaoment,
        Gitcoin,
        Drips
    }

    address uniswapRouterAddress = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
    address payable weth = payable(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    IPool allo;

    function donate(Platform platform, address from, address token_address, uint256 amount, address payable to, uint256 poolId) public payable {
        ERC20(token_address).transferFrom(from, address(this), amount);
        if (platform == Platform.Endaoment) {
            address baseToken = address(IEntity(to).baseToken());

            if (token_address != baseToken) {
                //swap to Eth
                if (baseToken == address(0)) {
                    uint256 amountOut = swap(token_address, amount, weth);
                    WETH(weth).withdraw(amountOut);
                    IEntity(to).donate{value: amountOut}(amountOut);
                } else {
                    uint256 amountOut = swap(token_address, amount, to);
                    ERC20(baseToken).approve(to, amountOut);
                    IEntity(to).donate(amountOut);
                }
            } else {
                if (baseToken == address(0)) {
                    IEntity(to).donate{value: amount}(amount);
                } else {
                    ERC20(baseToken).approve(to, amount);
                    IEntity(to).donate(amount);
                }
            }

        } else if (platform == Platform.Gitcoin) {
            address baseToken = allo.getPool(poolId).token;

            if (token_address != baseToken) {
                if (baseToken == address(0)) {
                    uint256 amountOut = swap(token_address, amount, weth);
                    WETH(weth).withdraw(amountOut);
                    allo.fundPool{value: amountOut}(poolId, amountOut);
                } else {
                    uint256 amountOut = swap(token_address, amount, to);
                    ERC20(baseToken).approve(to, amountOut);
                    allo.fundPool(poolId, amountOut);
                }
            } else {
                if (baseToken == address(0)) {
                    allo.fundPool{value: amount}(poolId, amount);
                } else {
                    ERC20(baseToken).approve(to, amount);
                    allo.fundPool(poolId, amount);
                }
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


interface IPool {
    /// @notice the Pool struct that all strategy pools are based from
    struct Pool {
        bytes32 profileId;
        IStrategy strategy;
        address token;
        Metadata metadata;
        bytes32 managerRole;
        bytes32 adminRole;
    }


    struct Metadata {
    /// @notice Protocol ID corresponding to a specific protocol (currently using IPFS = 1)
    uint256 protocol;
    /// @notice Pointer (hash) to fetch metadata for the specified protocol
    string pointer;
}

    /// @notice Returns the 'Pool' struct for a given 'poolId'
    /// @param _poolId The ID of the pool to check
    /// @return pool The 'Pool' struct for the ID of the pool passed in
    function getPool(uint256 _poolId) external view returns (Pool memory);

    function fundPool(uint256 _poolId, uint256 _amount) external payable;
}

interface IStrategy {
    function deposit(uint256 _amount) external;
}

interface IEntity {
    function donate(uint256 _amount) external payable;
    function baseToken() external view returns (address);
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
}