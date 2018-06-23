const IcoToken = artifacts.require('IcoToken');
const IcoContract = artifacts.require('IcoContract');
const GiftCoupon = artifacts.require('GiftCoupon');

module.exports = function(deployer){
	deployer.deploy(
			IcoToken,
			'OLA Token',
			'OLAT',
			'18',
			'1.0'
		).then(() => {
			return deployer.deploy(
					IcoContract,
					'0x9F386CcD8A8e7043314902ECE639DE8E2452d731', //Vikas Address-Rinkby(Account1)
					IcoToken.address,
					'100000000000000000000000000', // 100000000 Token
				    '1000', // 1 ETH = 1000 Token
				    '1514764800', // 01/01/2018
				    '1546214400', // 31/12/2018
				    '100000000000000000' // 0.1 ETH
				).then(() => {						
					return IcoToken.deployed(
							GiftCoupon,
							IcoToken.address,
							IcoContract.address
						).then(function(instance){
						return instance.setIcoContract(IcoContract.address);	
					});
				});
		});
};