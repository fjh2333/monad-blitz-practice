// SPDX-License-Identifier: UNLICENSED
//记录打卡
pragma solidity ^0.8.36; 

contract Hackcheck {

    struct CheckIn {
        string note;
        uint256 checkInTime;
    }
    mapping(address => CheckIn[]) public checkIns;  
    //「CheckIn 类型的数组」如果写成 mapping(address => CheckIn) 就只能存一条打卡，不能多次打卡。
    //每个地址 → 对应一个 CheckIn 数组（可以打卡很多次）

    //1.打卡 
    //note 是 string，复杂类型，必须标 memory
    function checkin(string memory note) public {
        // 添加打卡逻辑、记录时间戳
        checkIns[msg.sender].push(CheckIn(note, block.timestamp));
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
