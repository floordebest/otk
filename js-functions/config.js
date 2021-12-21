// Constants for communication with Kadena Blockchain

var testnet = true // Set to false to move to production

var numberOfChains = 20; // Number of active chains on the blockchain

// List of all tokens on the blockchain and contract names
var tokenList = [
    {
      "coinName": "Kadena",
      "coinId": "KDA",
      "contractIdMain": "coin",
      "contractIdTest": "coin",
    },
    {
      "coinName": "Anedak",
      "coinId": "ADK",
      "contractIdMain": "free.anedak",
      "contractIdTest": "free.anedak-token",
    },
    {
      "coinName": "Zelcash",
      "coinId": "FLUX",
      "contractIdMain": "runonflux.flux",
      "contractIdTest": "free.flux",
    },
  ];

// Returns an URL of the blockchain for testnet or mainnet
function host(chainID, command) {
    var apiCommand = "";

    switch (command) {
      case "send": //write to Blockchain
        apiCommand = "/api/v1/send";
        break;
      case "local": //non-write data to/from Blockchain
        apiCommand = "/api/v1/local";
        break;
      case "poll": //check tx-id status
        apiCommand = "/api/v1/poll";
        break;
      case "listen": //wait for response/confirmation from blockchain
        apiCommand = "/api/v1/listen";
        break;
      case "spv": //cross-chain transaction
        apiCommand = "/spv";
        break;
      default:
        apiCommand = "/api/v1/local";
    }

    if (!testnet) {
        // Returns the mainnet URL
        return "https://api.chainweb.com/chainweb/0.0/mainnet01/chain/" + 
            chainID +
            "/pact" +
            apiCommand;
      }
    else {
        // Returns the testnet URL
      return "https://api.testnet.chainweb.com/chainweb/0.0/testnet04/chain/" +
          chainID +
          "/pact" +
          apiCommand;
    }
}