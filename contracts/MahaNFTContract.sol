// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev This contract uses OpenZeppeling standard libraries along with
 * ERC721URIStorage is child of ERC721 with URI Storage support
*/
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract MahaNFTContract is ERC721URIStorage {
     /**
     * @dev Constracts the contract by setting a NFT `name` and a `symbol` to the token collection.
     */
         constructor () ERC721("MahaGaginticNFT", "MGTN"){   
    }
}