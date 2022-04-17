// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC20/ERC20.sol";

contract MahaTokenContract is ERC20 {
    /**
     * @dev Constracts the contract by setting a ERC20 Token`name` and a `symbol`.
     */
    constructor() ERC20("Maha Gigantic Token", "MGT") {
        /** 
        * Mint 1000 tokens to msg.sender, where
        * 1 token = 1 * (10 ** decimals)
        */
        _mint(msg.sender, 1000 * 10**uint(decimals()));
    }
}