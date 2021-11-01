/**
 *Submitted for verification at FtmScan.com on 2021-09-05
*/

pragma solidity ^0.8.7;

interface IRarity {
    function adventure(uint _summoner) external;
    function level_up(uint _summoner) external;
    function summon(uint _class) external;
}

/**
 * @title RarityEnhance
 * @dev 
 */
contract RarityEnhance {
    IRarity rarity = IRarity(0x0BC32C4cadb6A17c144784d74575bB00758B34D6);

    // 选择指定的应用进行冒险
    function adventureAll(uint256[] calldata _ids) external {
        uint len = _ids.length;
        for (uint i = 0; i < len; i++) {
            rarity.adventure(_ids[i]);
        }
        // that's literally it
    }

    // 召唤指定数量的英雄
    function summon(uint count) external {
      require(count > 0 && count <= 1000);
      // 从零遍历创建指定数量的英雄
      for (uint i = 0; i < count; i++) {
        rarity.summon((i % 10) + 1);
      }
    }

}