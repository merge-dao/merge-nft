// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IMatter.sol";
import "./@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./@openzeppelin/contracts/utils/Counters.sol";
import "./@openzeppelin/contracts/access/Ownable.sol";
import "./@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";


contract Merge is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _matterIds;

    struct MatterMeta {
        uint256 id;
        uint256 tokenId;
    }

    mapping(address => uint256) private _metaMatterIds;

    mapping(address => MatterMeta[]) private _tokenOwners;

    bool private _isStopTransfer = true;

    address private _matterNFTContract;

    constructor() ERC721("MatterMerge", "MTMG") {}

    function burn(uint256 tokenId) internal {
        _burn(tokenId);
    }

    function _beforeMatterTransfer() internal view {
        require(!_isStopTransfer, "matter token transfer while paused");
    }

    function setMatterContract(address matterNFT)
        public
        onlyOwner
        returns (address)
    {
        _matterNFTContract = matterNFT;
        return matterNFT;
    }

    function matterContract() public view returns (address) {
        return _matterNFTContract;
    }

    // erc721合约地址，需要防止重放攻击
    function addMetaMatter(address metaMatter)
        public
        onlyOwner
        returns (uint256)
    {
        // 需要确保唯一性, 保证每一个原Matter只能被添加一次
        require(_metaMatterIds[metaMatter] == 0, "metaMatter already exists");
        _matterIds.increment();
        uint256 matterId = _matterIds.current();
        _mint(metaMatter, matterId);

        // 将原matter合约和id关联起来
        _metaMatterIds[metaMatter] = matterId;
        return matterId;
    }

    // 销毁已经添加的matter
    function burnMetaMatter(uint256 tokenId)
        public
        onlyOwner
        returns (uint256)
    {
        address metaMatterContract = ownerOf(tokenId);
        // 判断元物质是否被添加
        require(tokenId != 0, "meta matter not exist");

        delete _metaMatterIds[metaMatterContract];

        burn(tokenId);

        return tokenId;
    }

    // 获取当前原Matter的id
    function getMetaMatterId(address metaMatter) public view returns (uint256) {
        return _metaMatterIds[metaMatter];
    }

    // 保存指定matter的信息
    function _saveMatter(uint256 matterId, uint256 tokenId) private {
        address sender = _msgSender();
        // 如果当前地址没有初始化则进行初始化
        // if (_tokenOwners[sender].length == 0) {
        //     _tokenOwners[sender] = address[0];
        // }
        // 把当前存入到合约中的nft放入对应的账户中
        _tokenOwners[sender].push(MatterMeta(matterId, tokenId));
    }

    // 保存指定matter的信息
    function _saveMatter(
        address owner,
        uint256 matterId,
        uint256 tokenId
    ) private {
        // 如果当前地址没有初始化则进行初始化
        // if (_tokenOwners[owner] == 0) {
        //     _tokenOwners[owner] = address[];
        // }
        // 把当前存入到合约中的nft放入对应的账户中
        _tokenOwners[owner].push(MatterMeta(matterId, tokenId));
    }

    // 移除指定的matter
    function _deleteMatter(
        address owner,
        uint256 matterId,
        uint256 tokenId
    ) private {
        // 如果当前地址没有初始化则进行初始化
        // if (_tokenOwners[owner] == 0) {
        //     _tokenOwners[owner] = address[];
        // }
        bool isExist = false;
        uint256 resultIdx = 0;
        for (uint256 i = 0; i < _tokenOwners[owner].length; i++) {
            if (
                _tokenOwners[owner][i].id == matterId &&
                _tokenOwners[owner][i].tokenId == tokenId
            ) {
                resultIdx = i;
                isExist = true;
                break;
            }
        }
        require(isExist, "matter not exist");
        // 把当前存入到合约中的nft放入对应的账户中
        // delete  _tokenOwners[owner][resultIdx];
        // require(resultIdx < _tokenOwners[owner].length);
        _tokenOwners[owner][resultIdx] = _tokenOwners[owner][
            _tokenOwners[owner].length - 1
        ];
        _tokenOwners[owner].pop();
    }

    // 获取指定用户可用的matter
    function matterOf(address owner) public view returns (MatterMeta[] memory) {
        require(owner != address(0), "owner is not valid");
        MatterMeta[] memory owners = _tokenOwners[owner];
        return owners;
    }

    // 任何人都可以存入自己的nft到合约中
    function deposit(uint256 metaMatterId, uint256 tokenId)
        public
        returns (uint256)
    {
        // 获取erc721指定的合约地址
        address tokenContract = ownerOf(metaMatterId);
        address sender = _msgSender();

        IERC721 token = IERC721(tokenContract);

        // 将tokenId存入合约中
        token.safeTransferFrom(sender, address(this), tokenId);

        // 保存指定的nft的信息, 这里不保存Matter信息，因为不知到Matter是否转移成功
        // _saveMatter(sender, metaMatterId, tokenId);
        return tokenId;
    }

    // 把指定的nft转移给指定的用户
    function withdraw(
        address to,
        uint256 metaMatterId,
        uint256 tokenId
    ) public returns (uint256) {
        // 获取erc721指定的合约地址
        address tokenContract = ownerOf(metaMatterId);

        require(tokenContract != address(0), "metaMatter not exist");

        address sender = _msgSender();

        // 判断当前用户是否有权限转移
        MatterMeta[] memory ownMatters = matterOf(sender);

        bool isVerifyed = false;
        uint256 resultIdx = 0;

        for (uint256 i = 0; i < ownMatters.length; i++) {
            if (
                ownMatters[i].id == metaMatterId &&
                ownMatters[i].tokenId == tokenId
            ) {
                isVerifyed = true;
                resultIdx = i;
            }
        }

        require(isVerifyed, "you have no permission to withdraw");

        IERC721 token = IERC721(tokenContract);
        // 将tokenId存入合约中
        token.safeTransferFrom(address(this), to, tokenId);

        // 移除指定的nft
        _deleteMatter(sender, metaMatterId, tokenId);

        return tokenId;
    }

    // 提到自己的账户中
    function withdraw(uint256 metaMatterId, uint256 tokenId)
        public
        returns (uint256)
    {
        address sender = _msgSender();
        return withdraw(sender, metaMatterId, tokenId);
    }

    function onERC721Received(
        address,
        address from,
        uint256 tokenId,
        bytes calldata
    ) external returns (bytes4) {
        address tokenContract = _msgSender();
        uint256 metaMatterId = _metaMatterIds[tokenContract];
        // 保存指定的nft的信息，保证NFT转移成功后再存入当前的token
        _saveMatter(from, metaMatterId, tokenId);
        return 0x150b7a02;
    }

    function compose(
        uint256 yinId,
        uint256 yinTid,
        uint256 yangId,
        uint256 yangTid
    ) public returns (uint256) {
        // 判断当前发送者是否有足够的matter
        address sender = _msgSender();
        require(_tokenOwners[sender].length > 0, "no matter to compose");

        MatterMeta[] memory ownerMatters = _tokenOwners[sender];
        MatterMeta[2] memory inputs = [
            MatterMeta(yinId, yinTid),
            MatterMeta(yangId, yangTid)
        ];

        uint256 counter = 0;
        // 检查是否有不合法的matter
        for (uint256 i = 0; i < inputs.length; i++) {
            for (uint256 j = 0; j < ownerMatters.length; j++) {
                if (
                    inputs[i].id == ownerMatters[j].id &&
                    inputs[i].tokenId == ownerMatters[j].tokenId
                ) {
                    counter += 1;
                }
            }
        }

        // 确保所有的matter都是合法的
        require(counter == 2, "invalid matter");

        // 创建合成的matter，并存入到合约中
        IMatter matter = IMatter(_matterNFTContract); // matter合约

        // 自增id, 开始铸造
        uint256 matterId = matter.mint(
            address(this),
            yinId,
            yinTid,
            yangId,
            yangTid
        );

        uint256 removeCount = 0;

        // 移除被合成的matter
        for (uint256 i = 0; i < inputs.length; i++) {
            for (uint256 j = 0; j < ownerMatters.length; j++) {
                if (
                    inputs[i].id == ownerMatters[j].id &&
                    inputs[i].tokenId == ownerMatters[j].tokenId
                ) {
                    // 删除被合成的matter
                    _deleteMatter(sender, inputs[i].id, inputs[i].tokenId);
                    removeCount += 1;
                    // delete ownerMatters[j];
                    break;
                }
            }
        }

        require(removeCount == 2, "make sure remove yin yang");

        uint256 matterContractId = getMetaMatterId(_matterNFTContract);
        // 保存新的matter给铸造者
        _saveMatter(sender, matterContractId, matterId);

        // 完成所有操作后返回合成的matter的id
        return matterId;
    }

    function merge(address yin, uint256 yinTid, address yang, uint256 yangTid) public returns(uint256) {
        require(yin != address(0) && yang != address(0), "yin and yang not emputy!");
        
        uint256 yinId = getMetaMatterId(yin);
        // 把对应的nft质押到合约中
        deposit(yinId, yinTid);

        uint256 yangId = getMetaMatterId(yang);
        // 把对应的nft质押到合约中
        deposit(yangId, yangTid);

        uint256 newTokenId = compose(yinId, yinTid, yangId, yangTid);

        // 把新的token提取到自己的账户
        uint256 matterContractId = getMetaMatterId(_matterNFTContract);
        withdraw(matterContractId, newTokenId);
        return newTokenId;
    }

    // // 用指定的matter进行合并
    // function compose(uint256[] memory matters)
    //     public
    //     onlyOwner
    //     returns (uint256)
    // {
    //     //     // 判断当前发送者是否有足够的matter
    //     //     address sender = _msgSender();
    //     //     require(_tokenOwners[sender].length > 0, "no matter to compose");
    //     //     MatterMeta[] memory ownerMatters = _tokenOwners[sender];
    //     //     uint256 counter = 0;
    //     //     // 检查是否有不合法的matter
    //     //     for (uint256 i = 0; i < matters.length; i++) {
    //     //         for (uint256 j = 0; j < ownerMatters.length; j++) {
    //     //             if (matters[i].id == ownerMatters[j].id && matters[i].tokenId == ownerMatters[j].tokenId) {
    //     //                 counter += 1;
    //     //             }
    //     //         }
    //     //     }
    //     //     // 确保所有的matter都是合法的
    //     //     require(counter == matters.length, "invalid matter");
    //     //     // 创建合成的matter，并存入到合约中
    //     //     IERC721 matter = IERC721(address(0x0fC5025C764cE34df352757e82f7B5c4Df39A836)); // matter合约
    //     //     // 自增id, 开始铸造
    //     //     // uint256 matterId = matter.mint(address(this), yinId, yinTid, yangId, yangTid);
    //     //     // 移除被合成的matter
    //     //     for (uint256 i = 0; i < matters.length; i++) {
    //     //         for (uint256 j = 0; j < ownerMatters.length; j++) {
    //     //             if (matters[i].id == ownerMatters[j].id && matters[i].tokenId == ownerMatters[j].tokenId) {
    //     //                 ownerMatters.remove(j);
    //     //                 break;
    //     //             }
    //     //         }
    //     //     }
    //     //     // 完成所有操作后返回合成的matter的id
    //     //     return matterId;
    // }

    // 分解指定的物质
    function deCompose(uint256 tokenId) public returns (uint256, uint256, uint256, uint256) {
        // 判断当前发送者是否有足够的matter
        address sender = _msgSender();
        require(_tokenOwners[sender].length > 0, "no matter to decompose");

        uint256 matterId = getMetaMatterId(_matterNFTContract);

        uint256 counter = 0;
        // 检查是否有不合法的matter
        for (uint256 i = 0; i < _tokenOwners[sender].length; i++) {
            // 第一个原Matter是matter合约
            if (
                _tokenOwners[sender][i].tokenId == tokenId &&
                _tokenOwners[sender][i].id == matterId
            ) {
                counter += 1;
            }
        }

        require(counter == 1, "invalid matter");

        // 从自身的存储中移除
        _deleteMatter(sender, matterId, tokenId);

        // 获取合约地址
        IMatter matter = IMatter(_matterNFTContract); // matter合约

        uint256 yangId = matter.getYangId(tokenId);
        uint256 yangTid = matter.getYangTid(tokenId);
        uint256 yinId = matter.getYinId(tokenId);
        uint256 yinTid = matter.getYinTid(tokenId);

        // 合成的matter不能为0
        require(
            yangId != 0 && yangTid != 0 && yinId != 0 && yinTid != 0,
            "invalid matter"
        );

        // 销毁当前的matter
        matter.burn(tokenId);

        // 恢复对拆分后的matter的控制权
        _saveMatter(sender, yangId, yangTid);
        _saveMatter(sender, yinId, yinTid);

        // 把阴阳转移给发送者的存储中
        return (yinId, yinTid, yangId, yangTid);
    }

    // 分解指定的物质
    function demerge(uint256 tokenId) public returns (uint256) {
        require(tokenId > 0, "tokenId not null");
        uint256 matterContractId = getMetaMatterId(_matterNFTContract);
        deposit(matterContractId, tokenId);
        (uint256 yinId, uint256 yinTid, uint256 yangId, uint256 yangTid) = deCompose(tokenId);
        withdraw(yinId, yinTid);
        withdraw(yangId, yangTid);
        return tokenId;
    }

    // 重写合约方法，生成的token防止被转移走
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override onlyOwner {
        _beforeMatterTransfer();
        return super.transferFrom(from, to, tokenId);
    }

    // 重写合约方法，生成的token防止被转移走
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override onlyOwner {
        _beforeMatterTransfer();
        return super.safeTransferFrom(from, to, tokenId);
    }

    // 重写合约方法，生成的token防止被转移走
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata _data
    ) public override onlyOwner {
        _beforeMatterTransfer();
        return super.safeTransferFrom(from, to, tokenId, _data);
    }
}
