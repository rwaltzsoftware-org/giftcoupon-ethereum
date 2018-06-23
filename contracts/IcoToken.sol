pragma solidity ^0.4.23;

import "./StandardToken.sol";
import "./SafeMath.sol";
import "./Pausable.sol";

contract IcoToken is StandardToken, Pausable{
    /*define SafeMath library for uint256*/
    using SafeMath for uint256;
    
    string public name;
    string public symbol;
    string public version;
    uint public decimals;
    address public icoSaleDeposit;
    address public icoContract;
    
    constructor(string _name, string _symbol, uint256 _decimals, string _version) public {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        version = _version;
    }
    
    function transfer(address _to, uint _value) public whenNotPaused returns (bool success) {
        return super.transfer(_to,_value);
    }
    
    function approve(address _spender, uint _value) public whenNotPaused returns (bool success) {
        return super.approve(_spender,_value);
    }
    
    function balanceOf(address _owner) public view returns (uint balance){
        return super.balanceOf(_owner);
    }
    
    function setIcoContract(address _icoContract) public onlyOwner {
        if(_icoContract != address(0)){
            icoContract = _icoContract;           
        }
    }
    
    function sell(address _recipient, uint256 _value) public whenNotPaused returns (bool success){
        assert(_value > 0);
        require(msg.sender == icoContract);
        
        accountBalances[_recipient] = accountBalances[_recipient].add(_value);
        totalSupply = totalSupply.add(_value);
        
        emit Transfer(0x0,owner,_value);
        emit Transfer(owner,_recipient,_value);
        return true;
    }
    
}    