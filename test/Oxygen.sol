// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../contracts/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../contracts/@openzeppelin/contracts/utils/Counters.sol";
import "../contracts/@openzeppelin/contracts/access/Ownable.sol";
import "../contracts/@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract Oxygen is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor() ERC721("Oxygen", "O") {}
    
     function claim(uint256 tokenId) public returns (uint256) {
      // require(tokenId > 0 && tokenId < 25535, "hydrogen atom is limited");
      _safeMint(_msgSender(), tokenId);
      return tokenId;
    }

}