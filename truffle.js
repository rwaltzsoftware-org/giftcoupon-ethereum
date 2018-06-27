var HDWalletProvider = require("truffle-hdwallet-provider");
module.exports = 
{
    networks: 
    {
	    development: 
		{
	   		host: "localhost",
	   		port: 8545,
	   		network_id: "*" // Match any network id
		},
    	rinkeby: {
		    provider: function() {
		      var mnemonic = 'snap call clerk .... '; //put ETH wallet 12 mnemonic code	
		      return new HDWalletProvider(mnemonic, "https://rinkeby.infura.io/<API_KEY_HERE>"); // update your infura rinkeby network API Key
		    },
		    network_id: '4',
		}  
    }
};