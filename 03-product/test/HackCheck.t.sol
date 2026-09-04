// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.36;

import {Test} from "forge-std/Test.sol";
import {Hackcheck} from "../src/Hackcheck.sol";

contract HackCheckTest is Test {
    Hackcheck public hackcheck;

    function setUp() public {
        // 部署
        hackcheck = new Hackcheck();
    }

    function test_CheckIn() public {
        // 打卡
        // 查回来，验证 note 和时间
        hackcheck.checkin("today study solidity");
        (string memory note, uint256 time) = hackcheck.getCheckIn(address(this), 0);
        assertEq(note, "today study solidity");
        assertEq(time, block.timestamp);
    }

    function test_MultipleCheckIns() public {
        // 打卡两次
        hackcheck.checkin("first checkin");
        hackcheck.checkin("second checkin");
        // 查第0条和第1条
        (string memory note0, )=hackcheck.getCheckIn(address(this),0);
        assertEq(note0,"first checkin");
        (string memory note1, )=hackcheck.getCheckIn(address(this),1);
        assertEq(note1,"second checkin");

    }   

    function test_GetCheckIn_Empty() public {
        // 没打过卡，查第 0 条应该 revert
        vm.expectRevert();
        hackcheck.getCheckIn(address(this), 0);
    }

    function test_MintNFT() public {
        // 打卡三次
        hackcheck.checkin("first checkin");
        hackcheck.checkin("second checkin");
        hackcheck.checkin("third checkin");
        // 查看是否获得 NFT
        assertEq(hackcheck.balanceOf(address(this)), 1);
    }

    function test_NoMintBeforeThreshold() public {
        //「打卡 1 次后 balanceOf 应该是 0」的用例，验证不会提前 mint
        hackcheck.checkin("first");
        assertEq(hackcheck.balanceOf(address(this)), 0);  // 1 次不该有徽章
    }



}