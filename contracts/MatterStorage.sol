// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 存储生成的物质的附加信息
contract MatterStorage {
    struct MatterInfo {
        uint256 yinId;
        uint256 yinTid;
        uint256 yangId;
        uint256 yangTid;
    }
    // tokenId 和 matterInfo 的映射
    mapping(uint256 => MatterInfo) private _matterInfo;

    /**
     * @dev Store matter in variable
     * @param matterId current matter id
     * @param yinId yin id
     */
    function save(uint256 matterId, uint256 yinId, uint256 yinTid, uint256 yangId, uint256 yangTid) public {
      _matterInfo[matterId] = MatterInfo(yinId, yinTid, yangId, yangTid);
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