//SPDX-License-Identifier: GPL-3.0 
pragma solidity ^0.8.0;
import './_IERC20.sol';

contract ERC20 is IERC20 {
    address mainOwner;
    uint totalTokens;
    mapping(address=>uint) balances;
    mapping(address => mapping(address => uint)) allowances;
    string public name = "Chai";
    string public symbol = "CHA";

    constructor(uint initSupply) {
        mainOwner = msg.sender;
        mint(mainOwner,initSupply);
    }

    modifier enoughTokens(address _from, uint _amount){
        require(balanceOf(_from) >= _amount, "not enough tokens");
        _;
    }
      modifier onlyOwner(){
        require(msg.sender == mainOwner,"Only Owner!");
        _;
    }

    function decimals() override external pure returns(uint) {
        return 18;
    }
    function totalSupply() override public view returns (uint){
        return totalTokens;
    }
    function balanceOf(address account) override public view returns(uint){
        return balances[account];
    }
    function transfer(address _to, uint _amount) override external enoughTokens(msg.sender, _amount) {
        balances[msg.sender] -= _amount;
        balances[_to] += _amount;
        emit Transfer(msg.sender, _to, _amount);
    }
    function allowance(address owner, address spender) override external view returns(uint) {
        return allowances[owner][spender];
    }
    function approve(address spender, uint amount) override external {
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender,spender,amount);
    }
    function transferFrom(address sender, address recipient, uint amount) override public enoughTokens(sender,amount){
        allowances[sender][recipient] -= amount;
        balances[sender] -= amount;
        balances[recipient] += amount;
        emit Transfer(sender,recipient,amount);
    }
    function mint(address _to,uint amount) public {
        balances[_to] += amount;
        totalTokens += amount;
        emit Transfer(address(0),msg.sender,amount);
    }
    function burn(address _to,uint amount) public enoughTokens(msg.sender,amount)   {
        balances[_to] -= amount;
        totalTokens -= amount;
        emit Transfer(msg.sender,address(0),amount);
    }
    fallback() external payable {

    }
    receive() external virtual payable {

    }
}
contract SellToken {
    IERC20 public token;
    address owner;
    address thisAddress = address(this);

    event Bought(address indexed buyer, uint amount);
    event Sold(address indexed seller, uint amount);

    constructor(IERC20 _token){
        token = _token;
        owner = msg.sender;
    }
    modifier onlyOwner(){
        require(msg.sender == owner,"Only Owner!");
        _;
    }
    function balance() public view returns(uint){
        return thisAddress.balance;
    }
    function buy() public payable {
        require(msg.value >= _rate(), "Incorrect sum");
        uint tokensAvailable = token.balanceOf(thisAddress);
        uint tokensToBuy = msg.value / _rate();
        require(tokensToBuy <= tokensAvailable, "not enough tokens!");
        token.transfer(msg.sender,tokensToBuy);
        emit Bought(msg.sender,tokensToBuy);
    }
    function sell(uint amount) public {
        require(amount > 0, "must be greater than zero!");
        uint allowance = token.allowance(msg.sender, thisAddress);
        require(allowance >= amount,"Wrong allowance!");
        token.transferFrom(msg.sender,thisAddress,amount);
        payable(msg.sender).transfer(amount * _rate());
        emit Sold(msg.sender,amount);
    }
    function withdraw(uint amount) public onlyOwner {
        require(amount<=balance(), "not enough funds!");
        payable(msg.sender).transfer(amount);
    }

    function _rate() private pure returns(uint){
        return 1 ether;
    }
}

contract Weth is ERC20 {
    constructor() ERC20(0) {}
    event Deposit(address indexed initiator, uint amount);

    function deposit() public payable {
        mint(msg.sender, msg.value);
        emit Deposit(msg.sender,msg.value);
    }
    receive() override external payable{
        deposit();
    }
    function withdraw(uint _amount) public{
        burn(msg.sender,_amount);
        (bool success,) = msg.sender.call{value:_amount}("");
        require(success,"failed!");
    }
}
