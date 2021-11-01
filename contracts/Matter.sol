// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./@openzeppelin/contracts/utils/Counters.sol";
import "./@openzeppelin/contracts/access/Ownable.sol";
import "./@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "./@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";

contract Matter is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor() public ERC721("Matter", "MATTER") {}

    // 构建物质，物质是有两个或者多个其他物质构成的，任何ERC721都是物质
    function mint(address recipient, uint256 yinId, uint256 yinTid, uint256 yangId)
        public onlyOwner
        returns (uint256) 
      {
        _tokenIds.increment();

        uint256 matterId = _tokenIds.current();
        _mint(recipient, matterId);
        // _setTokenURI(matterId, tokenURI);

        return matterId;
    }
}