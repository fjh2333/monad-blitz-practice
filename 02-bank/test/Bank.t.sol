// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.36;

import {Test} from "forge-std/Test.sol"; //导入 Test 这个测试合约。Foundry 的标准测试库 forge-std 里提供的一个测试基类合约。
import {Bank} from "../src/Bank.sol"; //导入要部署的合约，让脚本能 new Bank（）

contract BankTest is Test {
    Bank public bank0;

    function setUp() public {
        // 部署一个新的 Bank
        bank0 = new Bank();
        /*forge test 是在自己电脑上模拟一条链，不连任何真实网络。
        每个测试函数跑完后假链会重置，互不影响。
        所以这里需要在本地电脑的模拟假链上部署一个全新的Bank。
        执行流程：
        setUp()           → 部署 Bank
        test_Deposit()    → 测存钱      → 假链重置
        setUp()           → 再部署一个全新的 Bank
        test_Withdraw()   → 测取钱      → 假链重置
        setUp()           → 再部署一个全新的 Bank
        test_Withdraw_NotEnough() → 测余额不足  → 假链重置
        */
    }

    function test_Deposit() public {
        // 调用 deposit，带上一些 MON// 用 assertEq 检查余额

        vm.deal(address(this), 1 ether); //作弊码，直接给BankTest这个合约账户转钱
        bank0.deposit{value: 0.5 ether}(); //BankTest这个测试合约调用Bank合约中写的存钱函数向里面存钱。
        assertEq(bank0.getBalance(), 0.5 ether);//foundry的断言函数，两值不等就报错
    }

    function test_Withdraw() public {
        // 先存钱 // 再取钱 // 检查余额变了
        vm.deal(address(this),2 ether);

        bank0.deposit{value:1.5 ether}();
        /*
        {value: 0.5 ether} 是 Solidity 语法，表示「调用这个函数的同时转 0.5 ether 过去」。
        只有 payable 函数才能这样带钱
        msg.value 自动等于你 {value: ...} 里写的金额，不需要手动传参
        */
       bank0.withdraw(0.5 ether);
       /* 之前的 Bank 合约的 withdraw 里用的 transfer。
       transfer 有个 2300 gas 限制，给测试合约转钱时 gas 不够就 revert 了。导致transfer转账失败
       改为call
       
       */
       assertEq(bank0.getBalance(), 1 ether);
    }

    function test_Withdraw_NotEnough() public {
        // 余额不够，应该 revert
        vm.expectRevert("no enough balance");//告诉 Foundry：下一行应该报这个错。。注意这里字符串必须跟Bank合约里的报错信息完全一致，Foundry 才能匹配上。
        //vm.expectRevert 的意思是：下一行调用必须回滚，否则测试失败。
        //作弊码，期下一行代码会 revert。如果真的 revert 了，测试通过；如果没 revert，测试失败。
        
        bank0.withdraw(1 ether);
    }

    //当前的测试合约接受转账需要底层函数
    /*
    transfer 失败是因为 gas 限制，call 失败是因为测试合约没有 receive 函数，收不了钱。
    当 Bank 用 call 给测试合约转钱时，测试合约需要有 receive() 或 fallback() 函数才能接收。
    BankTest 里没写，所以转账被拒。
    */
   receive() external payable {}

}

/*
1. Test 是 Foundry 提供的类吗？
    是的。forge-std/Test.sol 里定义了一个 Test 合约，
    里面包含 assertEq、assertTrue 等断言函数，以及 vm 对象（所有作弊码的入口）。
    你的 BankTest 继承它之后就能用这些工具。
    同理，forge-std/Script.sol 里定义了 Script 合约，提供 vm.startBroadcast 等部署工具。

2.forge-std 在哪个文件夹？
    就在工程里的 lib/ 目录下


3.既然 Test 也是合约，为什么不需要像 Bank 一样手动部署？
    它其实也会被部署，
    只不过是由 Foundry 的测试运行器自动部署到一个临时的本地 EVM 里，你不用自己写部署脚本。
    BankTest 和 Test 也会被编译成合约，并由 Forge 自动部署到临时 EVM；
    Bank 则通常在 setUp() 中由测试合约执行 new Bank() 部署。
    然后 Forge 调用 test...() 函数，让真实的 EVM bytecode 在可控的测试环境中执行。
*/