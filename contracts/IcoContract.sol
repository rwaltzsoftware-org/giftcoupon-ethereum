pragma solidity ^0.4.23;

import "./SafeMath.sol";
import "./Pausable.sol";
import "./IcoToken.sol";

contract IcoContract is Pausable{
    /*define SafeMath library for uint256*/
    using SafeMath for uint256;
    IcoToken public ico ;
    uint256 public tokenCreationCap;
    uint256 public totalSupply;
    uint256 public fundingStartTime;
    uint256 public fundingEndTime;
    uint256 public minContribution;
    uint256 public tokenExchangeRate;
    
    address public ethFundDeposit;
    address public icoAddress;
    
    bool public isFinalized;
    
    event LogCreateICO(address from, address to, uint256 val);
    
    function CreateIco(address to, uint256 val) internal returns (bool success) {
        emit LogCreateICO(0x0,to,val);
        return ico.sell(to,val);/*call to IcoToken sell() method*/
    }
    
    constructor(address _ethFundDeposit,
                address _icoAddress,
                uint256 _tokenCreationCap,
                uint256 _tokenExchangeRate,
                uint256 _fundingStartTime,
                uint256 _fundingEndTime,
                uint256 _minContribution) public {
        ethFundDeposit = _ethFundDeposit;
        icoAddress = _icoAddress;
        tokenCreationCap = _tokenCreationCap;
        tokenExchangeRate = _tokenExchangeRate;
        fundingStartTime = _fundingStartTime;
        minContribution = _minContribution;
        fundingEndTime = _fundingEndTime;
        ico = IcoToken(icoAddress);
        isFinalized = false;
    }
    
    /*call fallback method*/
    function () public payable{
        createTokens(msg.sender,msg.value);
    }
    
    function createTokens(address _beneficiary,uint256 _value) internal whenNotPaused {
        require(tokenCreationCap > totalSupply);
        require(now >= fundingStartTime);
        require(now <= fundingEndTime);
        require(_value >= minContribution);
        require(!isFinalized);
        
        uint256 tokens = _value.mul(tokenExchangeRate);
        uint256 checkSupply = totalSupply.add(tokens);
        
        if(tokenCreationCap < checkSupply){
            uint256 tokenToAllocate = tokenCreationCap.sub(totalSupply);
            uint256 tokenToRefund = tokens.sub(tokenToAllocate);
            uint256 etherToRefund = tokenToRefund / tokenExchangeRate;
            totalSupply = tokenCreationCap;
            
            require(CreateIco(_beneficiary,tokenToAllocate));
            msg.sender.transfer(etherToRefund);
            ethFundDeposit.transfer(address(this).balance);
            return;
        }
        
        totalSupply = checkSupply;
        require(CreateIco(_beneficiary,tokens));
        ethFundDeposit.transfer(address(this).balance);
    }
    
    function finalize() external onlyOwner{
        require(!isFinalized);
        isFinalized = true;
        ethFundDeposit.transfer(address(this).balance);
    }
}