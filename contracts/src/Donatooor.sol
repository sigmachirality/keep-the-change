// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@endaoment/Entity.sol";

contract Donatooor {
    enum Platform {
        Endaoment,
        Gitcoin,
        Drips
    }

    address uniswapRouterAddress = 


    function donate(Platform platform, address token_address, uint256 amount) public payable {
        if (platform == Platform.Endaoment) {

        }
    }
}
