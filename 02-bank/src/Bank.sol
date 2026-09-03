// Bank
pragma solidity ^0.8.36; 

contract Bank {
    mapping(address => uint256) public balances;
    //1.存储函数
    function deposit() public payable{
        balances[msg.sender] += msg.value;
    }
    //2.取款函数
    function withdraw (uint256 amount) public {
        require(balances[msg.sender]>=amount,"no enough balance");
        /*require 失败时不是「返回一个错误字符串」，而是整个交易回滚——所有状态变化全部撤销，钱退回去，gas 白花。
        这不是普通的返回值，是异常。 */

        balances[msg.sender] -= amount;
        //方法1，但transfer有2300gas限制
        /* payable(msg.sender).transfer(amount);
        有两种地址类型：address 和 address payable
         address payable 可以转账，address 不可以。
         payable() 是类型转换，将 address 转换为 address payable。
         */
        //方法2，call无gas限制
        (bool ok , ) = payable(msg.sender).call{value:amount} ("");//call{value: amount}("")：给 msg.sender 转 amount额度，不带额外数据
        require(ok , "transfer failed");//是否ok，否则回滚并 返回”trans failed“
    } 
    //3.查账函数
    function getBalance() public view returns(uint256){
        return balances[msg.sender];
    } 
}
