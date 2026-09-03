// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.36;


import {Script} from "forge-std/Script.sol";
//导入 Foundry 提供的 Script 基类。就像测试文件里 import {Test} 一样，Script 给你提供部署专用的工具。
import {Bank} from "../src/Bank.sol";


contract DeployBankScript is Script { //声明的部署脚本合约继承自 Script ，能用foundry的部署功能
    Bank public bank;

    function run() public {  //run() 是 Foundry 约定的入口函数。forge script 执行时就是调这个函数。
        vm.startBroadcast(); //作弊码，从这里开始，下面的所有操作不再是模拟，而是真实发交易到链上。
        bank = new Bank();
        vm.stopBroadcast(); //作弊码，到此结束，下面的所有操作又回到模拟。
    }
}
/*
1.为什么要写部署脚本
    合约不会自己跑到链上。 写完 Bank.sol，它只是一个文件。要把它部署到链上，需要：
    编译成字节码 -> 构造一笔「创建合约」的交易 -> 用私钥签名 -> 通过 RPC 发给节点 。
    部署脚本就是告诉 Foundry 「部署时要做哪些事」。
    然后跑的 forge script ... --broadcast，就是在执行这个脚本部署到链上。
*/

/*
2.运行逻辑
 终端命令：
    forge script script/DeployBank.s.sol \
  --rpc-url https://testnet-rpc.monad.xyz \
  --private-key $PRIVATE_KEY \
  --broadcast

foundry执行：
    1. 编译 Bank.sol → 字节码
    2. 找到 DeployBankScript 合约
    3. 调用 run() 函数
    4. 遇到 vm.startBroadcast()
        → 开始记录要发到链上的交易
        → 用 --private-key 签名
        → 通过 --rpc-url 发给 Monad 节点
    5. 遇到 bank = new Bank()
        → 构造一笔「创建合约」交易
        → 签名 → 发到 Monad
        → 节点执行 → Bank 合约出现在链上
        → 返回合约地址
    6. 遇到 vm.stopBroadcast()
        → 停止记录
    7. 打印结果：合约地址、交易哈希、花了多少 gas


*/