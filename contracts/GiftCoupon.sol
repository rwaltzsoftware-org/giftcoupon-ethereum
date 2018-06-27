pragma solidity ^0.4.23;

import "./SafeMath.sol";
import "./IcoToken.sol";
import "./IcoContract.sol";

contract GiftCoupon {

	using SafeMath for uint256;
	IcoToken icoTokenObj ;
	IcoContract icoContractObj ;

	address owner;
	uint256 allowanceCost;
	uint256 decimalFactor;
	
	uint256 public RedeemableCost;

	struct Coupon
	{		
		uint256 rewardCost;		
		uint256 validity;					
		address creator;
		string couponTitle;
		address redeemedBy;
	}
	
	constructor(address _icoToken) public 
	{
	    icoTokenObj = IcoToken(_icoToken);
	    owner = msg.sender;
	    
	    /* decimal factor */
	    uint256 decimals = icoTokenObj.decimals();
	    decimalFactor = 10 ** decimals;
	}
	
	modifier onlyAdmin()
	{
	    require(owner == msg.sender) ;
	    _;
	}
	
	function setIcoTokenInstance(address _icoToken) private onlyAdmin 
	{
	    icoTokenObj = IcoToken(_icoToken);
	}

	mapping(uint32 => Coupon) CouponCode; 

    mapping( address => uint[]) UserCouponList;	
    uint[] codeList;

	event couponGift(uint256 _cost,  uint256 _validity, address _creator, string _title , uint256 _noOfCoupon);
    event couponRedeemed(address user, uint256 couponCode);
  
    // can createGiftCoupon only if have tokens creators account
    function createGiftCoupon(uint256 _cost,  uint256 _validity, string _title , uint256 _noOfCoupon) public 
    {
      
		/*  Get exchange rate from IcoContract and convert new token cost into decimal */
	
		uint256 newTokenCost = _cost.mul(_noOfCoupon);
		
		/* multiply new token cost with exchange rate to get decimal cost*/
        uint tokenCostInDecimal = decimalFactor.mul(newTokenCost);
        
		/* get allowance cost of constract*/
		allowanceCost = icoTokenObj.allowance(msg.sender,address(this));
        
		/*  Check if Total Coupon Token Value in decimalis Lesser than allowance cost of contract  */
        require(tokenCostInDecimal < allowanceCost); 
    
        
        Coupon memory couponObj;
        /*  Iterate _noOfCoupon times  */
        for(uint i = 0 ; i < _noOfCoupon ; i++)
        {
            	couponObj.creator = msg.sender;
        		couponObj.couponTitle = _title;
        		couponObj.rewardCost = _cost.mul(decimalFactor);
        		couponObj.validity = _validity;
        		couponObj.redeemedBy = address(0); // store address 0x000 initially before redeem 
        		/* Generate Random String Coupon code */
        		uint32 code = uint32(uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty,now,i)))%2000000000);
        		codeList.push(code);
        		CouponCode[code] = couponObj;  
        }
        
        /* Map codelist on creators address */
        UserCouponList[msg.sender] = codeList;
        
		/* Trigger Event  */
		emit couponGift(_cost, _validity, msg.sender, _title, _noOfCoupon);
	}
	
    function getGiftCouponDetails(uint32 _couponCode) public view returns( string title,uint256 cost,  uint256 validity, uint256 code, address creator, address redeemedBy)
    {
        Coupon storage getStructValue = CouponCode[_couponCode];
        
        title = getStructValue.couponTitle;
        cost = getStructValue.rewardCost;
        validity = getStructValue.validity;
        code = _couponCode;
        creator = getStructValue.creator;
        redeemedBy = getStructValue.redeemedBy;
        
        return (title, cost, validity, code, creator, redeemedBy);
    }
	
	function getGiftCouponCodes() public view returns ( uint[]){
	       return UserCouponList[msg.sender];
	}

	function redeemCoupon(uint32 _couponCode) public returns(bool)
	{
		Coupon storage reward = CouponCode[_couponCode];
		RedeemableCost = reward.rewardCost;
		/*  Check if rewardCost is not 0 */
        require(reward.rewardCost != 0);
        require(reward.redeemedBy == address(0));
        
        /* Transfer Reward Cost Token to msg.sender from Coupon Creator Account via TokenContract using transferFrom method */
        icoTokenObj.transferFrom(reward.creator, msg.sender, reward.rewardCost);
       
       	/* Update Coupon redeemedBy address */
		reward.redeemedBy = msg.sender;

		/* Trigger Event */
		emit couponRedeemed(msg.sender , _couponCode);
		
		return true;
	}
}