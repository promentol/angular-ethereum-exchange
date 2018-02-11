pragma solidity ^0.4.8;

contract ERC20Interface {

    function totalSupply() public view returns (uint256);

    function balanceOf(address _owner) public view returns (uint balance);

    function transfer(address _to, uint256 _value) public returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    function approve(address _spender, uint256 _value) public returns (bool success);

    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _to, uint256 _value);
}