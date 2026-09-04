// SPDX-License-Identifier: UNLICENSED
//记录打卡
//2.0 增加NFT奖励功能
pragma solidity ^0.8.36; 

import {ERC721} from "lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

contract Hackcheck is ERC721 {

    constructor() ERC721("Hack", "HCT") {
    }//「父合约构造函数调用」，部署你的 Hackcheck 时，先执行 ERC721 的初始化
    //ERC721("HackCheck Badge", "HCB") — 把名字和符号传给父合约 ERC721 的构造函数。


    struct CheckIn {
        string note;
        uint256 checkInTime;
    }
    
    mapping(address => CheckIn[]) public checkIns;  
    //「CheckIn 类型的数组」如果写成 mapping(address => CheckIn) 就只能存一条打卡，不能多次打卡。
    //每个地址 → 对应一个 CheckIn 数组（可以打卡很多次）


    struct Check_threhold_Count{
        uint256 checkcount;
        bool istoken;
    }
    //记录每个地址的打卡次数和是否获得徽章
    mapping(address => Check_threhold_Count ) public Check_threhold_c;

    //记录已发行的徽章数量，用于生成唯一的token ID
    uint256 public nextTokenId; //徽章计数
    //标定徽章发行门槛
    uint256 public constant MINT_THRESHOLD = 3;

    //1.打卡 
    //note 是 string，复杂类型，必须标 memory
    function checkin(string memory note) public {
        // 添加打卡逻辑、记录时间戳
        checkIns[msg.sender].push(CheckIn(note, block.timestamp));
        //记录当前打卡者的次数
        Check_threhold_c[msg.sender].checkcount++;
        if(Check_threhold_c[msg.sender].istoken == false && Check_threhold_c[msg.sender].checkcount == MINT_THRESHOLD) {  //显式判断是否已经获得徽章 //恰好第 3 次时触发（第 4、5 次不满足） 
            //发行NFT
            _mint(msg.sender, nextTokenId);
            nextTokenId++;
            Check_threhold_c[msg.sender].istoken = true;
        }
    }

    //2.查询记录
    function getCheckIn(address user, uint256 index) public view returns(string memory note, uint256 time){
        //返回某人的 第index条打卡
        CheckIn memory c = checkIns[user][index];
        /*从 mapping 里取数据，两层查找：
        checkIns          → 整个 mapping
        checkIns[user]    → user 这个地址的 CheckIn 数组
        checkIns[user][index]  → 这个数组里第 index 条打卡
        */
        return (c.note, c.checkInTime);
    } 
}
