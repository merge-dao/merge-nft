// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./@openzeppelin/contracts/utils/Counters.sol";
import "./@openzeppelin/contracts/access/Ownable.sol";
import "./@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract Matter is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct BaseInfo {
        uint256 yinId;
        uint256 yinTid;
        uint256 yangId;
        uint256 yangTid;
    }

    // tokenId 和 BaseInfo 的映射
    mapping(uint256 => BaseInfo) private _matterInfo;

    address private _delegator;

    constructor() ERC721("Matter", "MATTER") {}

    function setDelegator(address delegator)
        public
        onlyOwner
        returns (address)
    {
        _delegator = delegator;
        return delegator;
    }

    function getDelegator() public view returns (address) {
        return _delegator;
    }

    // 构建物质，物质是有两个或者多个其他物质构成的，任何ERC721都是物质
    function mint(
        address recipient,
        uint256 yinId,
        uint256 yinTid,
        uint256 yangId,
        uint256 yangTid
    ) public returns (uint256) {
        // need to check sender is the owner
        address sender = _msgSender();
        require(_delegator == sender, "Only the delegator can mint new tokens");

        _tokenIds.increment();

        uint256 matterId = _tokenIds.current();
        _mint(recipient, matterId);

        // 保存数据
        saveInfo(matterId, yinId, yinTid, yangId, yangTid);

        return matterId;
    }

    function burn(uint256 tokenId) public {
        // need to check sender is the owner
        address sender = _msgSender();
        require(_delegator == sender, "Only the delegator can burn tokens");
        _burn(tokenId);
        // 删除meta数据
        removeInfo(tokenId);
    }

    /**
     * @dev Store matter in variable
     * @param matterId current matter id
     * @param yinId yin id
     */
    function saveInfo(
        uint256 matterId,
        uint256 yinId,
        uint256 yinTid,
        uint256 yangId,
        uint256 yangTid
    ) private {
        _matterInfo[matterId] = BaseInfo(yinId, yinTid, yangId, yangTid);
    }

    /**
     * @dev remove matter
     * @param matterId current matter id to remove
     *
     */
    function removeInfo(uint256 matterId) private {
        delete _matterInfo[matterId];
    }

    /**
     * @dev Return yinId by matterId
     * @return value of yinId
     */
    function getYinId(uint256 matterId) public view returns (uint256) {
        require(matterId > 0, "Matter not found");
        return _matterInfo[matterId].yinId;
    }

    /**
     * @dev Return yinTid by matterId
     * @return value of yinTid
     */
    function getYinTid(uint256 matterId) public view returns (uint256) {
        require(matterId > 0, "Matter not found");
        return _matterInfo[matterId].yinTid;
    }

    /**
     * @dev Return yinId by matterId
     * @return value of yinId
     */
    function getYangId(uint256 matterId) public view returns (uint256) {
        require(matterId > 0, "Matter not found");
        return _matterInfo[matterId].yangId;
    }

    /**
     * @dev Return yinTid by matterId
     * @return value of yinTid
     */
    function getYangTid(uint256 matterId) public view returns (uint256) {
        require(matterId > 0, "Matter not found");
        return _matterInfo[matterId].yangTid;
    }
}
