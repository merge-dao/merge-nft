// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


import "./@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./@openzeppelin/contracts/utils/Counters.sol";
import "./@openzeppelin/contracts/access/Ownable.sol";
import "./@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "./@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "./@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";

import "./@openzeppelin/contracts/token/ERC721/IERC721.sol";


contract Merge is ERC721Pausable, ERC721URIStorage, ERC721Burnable, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _matterIds;

    struct MatterMeta {
        uint256 id;
        uint tokenId;
    }

    mapping(address => MatterMeta[]) private _tokenOwners;

    bool private _isStopTransfer = true;

    // 当前这个人有几个matter，每个metter都有一个matterId和一个tokenId
    // 当前改地址对应的是一个数组

    string[] private vibes = [
        "Optimist",
        "Cosmic",
        "Chill",
        "Hyper",
        "Kind",
        "Hater",
        "Phobia",
        "Generous",
        "JonGold"
    ];

    constructor() public ERC721("MatterMerge", "MATM") {
      // 构造函数中禁止token转移，转移token会出现异常
        //   _pause();
    }

    function _beforeMatterTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal {
        require(!_isStopTransfer, "matter token transfer while paused");
    }

    // erc721合约地址
    function addMatter(address recipient)
        public onlyOwner
        returns (uint256) 
      {
        _matterIds.increment();
        uint256 matterId = _matterIds.current();
        _mint(recipient, matterId);
        return matterId;
    }

    // 保存指定matter的信息
    function _saveMatter(uint256 matterId, uint256 tokenId) private {
        address sender = _msgSender();
        // 如果当前地址没有初始化则进行初始化
        if (_tokenOwners[sender] == 0) {
            _tokenOwners[sender] = [];
        }
        // 把当前存入到合约中的nft放入对应的账户中
        _tokenOwners[sender].push(MatterMeta(matterId, tokenId));
    }

    // 保存指定matter的信息
    function _saveMatter(address owner, uint256 matterId, uint256 tokenId) private {
        // 如果当前地址没有初始化则进行初始化
        if (_tokenOwners[owner] == 0) {
            _tokenOwners[owner] = [];
        }
        // 把当前存入到合约中的nft放入对应的账户中
        _tokenOwners[owner].push(MatterMeta(matterId, tokenId));
    }

    // 移除指定的matter
    function _saveMatter(address owner, uint256 matterId, uint256 tokenId) private {
        // 如果当前地址没有初始化则进行初始化
        if (_tokenOwners[owner] == 0) {
            _tokenOwners[owner] = [];
        }
        // 把当前存入到合约中的nft放入对应的账户中
        _tokenOwners[owner].push(MatterMeta(matterId, tokenId));
    }

    // 存入指定的nft到合约中
    function deposit(uint256 matterId, uint256 tokenId)
        public onlyOwner
        returns (uint256) 
      {
        // 获取erc721指定的合约地址 
        address tokenContract = ownerOf(matterId);
        address sender = _msgSender();
        IERC721 token = IERC721(tokenContract);
        // 将tokenId存入合约中
        token.safeTransferFrom(sender, this, tokenId);
        // 保存指定的nft的信息
        _saveMatter(sender, matterId, tokenId);
        return tokenId;
    }

    // 获取指定用户可用的matter
    function approveMatter(address owner) public view returns (MatterMeta[]) {
        requrie(owner != address(0), 'owner is not valid');
        return _tokenOwners[owner];
    }

    // 把指定的nft转移到自己的账户
    function withdraw()
        public onlyOwner
        returns (uint256) 
    {

    }

    function compose(uint256 yinId, uint256 yinTid, uint256 yangId, uint256 yangTid) public returns (MatterMeta) {
        // 判断当前发送者是否有足够的matter
        address sender = _msgSender();
        require(_tokenOwners[sender] != 0, "no matter to compose");
        
        MatterMeta[] ownerMatters = _tokenOwners[sender];
        MatterMeta[2] inputs = [MatterMeta(yinId, yinTid), MatterMeta(yangId, yangTid)];]; 

        uint256 counter = 0;
        // 检查是否有不合法的matter
        for (uint256 i = 0; i < inputs.length; i++) {
            for (uint256 j = 0; j < ownerMatters.length; j++) {
                if (inputs[i].id == ownerMatters[j].id && inputs[i].tokenId == ownerMatters[j].tokenId) {
                    counter += 1;
                }
            }
        }

        // 确保所有的matter都是合法的
        requrie(counter != 2, "invalid matter");

        // 创建合成的matter，并存入到合约中
        IERC721 matter = IERC721(""); // matter合约

        // 自增id, 开始铸造
        uint256 matterId = matter.mint(this, yin, yang);

        uint256 ownerCount = _tokenOwners[sender].length;
        
        // 移除被合成的matter
        for (uint256 i = 0; i < inputs.length; i++) {
            for (uint256 j = 0; j < ownerMatters.length; j++) {
                if (inputs[i].id == ownerMatters[j].id && inputs[i].tokenId == ownerMatters[j].tokenId) {
                    ownerMatters.remove(j);
                    break;
                }
            }
        }

        require(ownerMatters.length != ownerCount - 2, "make sure remove yin yang");

        // 完成所有操作后返回合成的matter的id
        return matterId;
    }

    // 用指定的matter进行合并
    function compose(MatterMeta[] matters)
      public onlyOwner
      returns (uint256) 
    {
        // 判断当前发送者是否有足够的matter
        address sender = _msgSender();
        require(_tokenOwners[sender] != 0, "no matter to compose");
        
        MatterMeta[] ownerMatters = _tokenOwners[sender];
        uint256 counter = 0;
        // 检查是否有不合法的matter
        for (uint256 i = 0; i < matters.length; i++) {
            for (uint256 j = 0; j < ownerMatters.length; j++) {
                if (matters[i].id == ownerMatters[j].id && matters[i].tokenId == ownerMatters[j].tokenId) {
                    counter += 1;
                }
            }
        }
        // 确保所有的matter都是合法的
        requrie(counter == matters.length, "invalid matter");
        
        // 创建合成的matter，并存入到合约中
        IERC721 matter = IERC721(""); // matter合约

        // 自增id, 开始铸造
        uint256 matterId = matter.mint(this, matters);

        // 移除被合成的matter
        for (uint256 i = 0; i < matters.length; i++) {
            for (uint256 j = 0; j < ownerMatters.length; j++) {
                if (matters[i].id == ownerMatters[j].id && matters[i].tokenId == ownerMatters[j].tokenId) {
                    ownerMatters.remove(j);
                    break;
                }
            }
        }

        // 完成所有操作后返回合成的matter的id
        return matterId;
    }


    function deCompose(uint256[] matters)
      public onlyOwner
      returns (uint256) 
    {
        
    }

    // 重写合约方法，生成的token防止被转移走
    function transferFrom(address from, address to, uint256 tokenId) public onlyOwner {
        _beforeMatterTransfer(from, to, tokenId);
        return super.transferFrom(from, to, tokenId);
    }

    // 重写合约方法，生成的token防止被转移走
    function safeTransferFrom(address from, address to, uint256 tokenId) public onlyOwner {
        _beforeMatterTransfer(from, to, tokenId);
        return super.safeTransferFrom(from, to, tokenId);
    }

    function tokenURI(uint256 tokenId) override public view returns (string memory) {
        string[19] memory parts;
        parts[0] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { fill: black; font-family: serif; font-size: 14px; }</style><rect width="100%" height="100%" fill="white" /><text x="10" y="20" class="base">';

        parts[1] = getOS(tokenId);

        parts[2] = '</text><text x="10" y="40" class="base">';

        parts[3] = getTextEditor(tokenId);

        parts[4] = '</text><text x="10" y="60" class="base">';

        parts[5] = getClothing(tokenId);

        parts[6] = '</text><text x="10" y="80" class="base">';

        parts[7] = getLanguage(tokenId);

        parts[8] = '</text><text x="10" y="100" class="base">';

        parts[9] = getIndustry(tokenId);

        parts[10] = '</text><text x="10" y="120" class="base">';

        parts[11] = getLocation(tokenId);

        parts[14] = '</text><text x="10" y="140" class="base">';

        parts[15] = getMind(tokenId);

        parts[16] = '</text><text x="10" y="160" class="base">';

        parts[17] = getVibe(tokenId);

        parts[18] = '</text></svg>';

        string memory output = string(abi.encodePacked(parts[0], parts[1], parts[2], parts[3], parts[4], parts[5], parts[6], parts[7], parts[8]));
        output = string(abi.encodePacked(output, parts[9], parts[10], parts[11], parts[12], parts[13], parts[14], parts[15], parts[16], parts[17], parts[18]));
        
        string memory json = Base64.encode(bytes(string(abi.encodePacked('{"name": "Dev #', toString(tokenId), '", "description": "Developers around the world are tired of working and contributing their time and effort to enrich the top 1%. Join the movement that is community owned, building the future from the bottom up.", "image": "data:image/svg+xml;base64,', Base64.encode(bytes(output)), '"}'))));
        output = string(abi.encodePacked('data:application/json;base64,', json));

        return output;
    }

    function claim(uint256 tokenId) public nonReentrant {
        require(tokenId > 0 && tokenId < 7778, "Token ID invalid");
        _safeMint(_msgSender(), tokenId);
    }
    
    function ownerClaim(uint256 tokenId) public nonReentrant onlyOwner {
        require(tokenId > 7777 && tokenId < 8001, "Token ID invalid");
        _safeMint(owner(), tokenId);
    }
    
    function toString(uint256 value) internal pure returns (string memory) {
    // Inspired by OraclizeAPI's implementation - MIT license
    // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
    
    constructor() ERC721("Devs for Revolution", "DEVS") Ownable() {}
}
