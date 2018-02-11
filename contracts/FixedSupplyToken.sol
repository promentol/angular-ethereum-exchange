pragma solidity ^0.4.8;

import "./ERC20Interface.sol";
import "./owned.sol";

contract FixedSupplyToken is ERC20Interface, owned {
    string public constant symbol = "LAZY";
    string public constant name = "LAZY FIXED SUPPLY TOKEN";
    uint8 public constant decimals = 0;
    uint256 _totalSupply = 100000;
    
    //balances for each account
    mapping (address => uint256) balances;
    
    mapping (address => mapping (address => uint256)) allowed;

    function FixedSupplyToken() public {
        balances[owner] = _totalSupply;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }

    function transfer(address _to, uint256 _amount) public returns (bool) {
        if(balances[msg.sender] >= _amount && _amount > 0 && balances[_to] + _amount > balances[_to]) {
            balances[msg.sender] -= _amount;
            balances[_to] += _amount;
            Transfer(msg.sender, _to, _amount);
            return true;
        } else {
            return false;
        }
    }

    function transferFrom (address _from, address _to, uint256 _amount) public returns (bool) {
        if (balances[_from] >= _amount && allowed[_from][msg.sender] >= _amount) {
            if( _amount > 0 && balances[_to] + _amount > 0 && balances[_to] + _amount >= _amount) {
                balances[_from] -= _amount;
                allowed[_from][msg.sender] -= _amount;
                balances[_to] += _amount;
                Transfer(_from, _to, _amount);
                return true;
            } else {
                return false;
            }
        } else {
            return false;
        }
    }

    function approve(address _spender, uint256 _amount) public returns (bool) {
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }

}