//SPDX-License-Identifier: GPL-3.0 
pragma solidity ^0.8.0;


interface IERC20 {
    function decimals() external pure returns(uint);
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns(uint);
    function transfer(address _to, uint _amount) external;
    function allowance(address owner, address spender) external view returns(uint);
    function approve(address spender, uint amount) external;
    function transferFrom(address sender, address recipient, uint amount) external;
    event Transfer(address indexed from, address indexed to, uint amount);
    event Approval (address indexed owner, address indexed to, uint amount);
}