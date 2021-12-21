// Constants for communication with Kadena Blockchain

var testnet = true // Set to false to move to production

var existingTestKeyPair = {
    publicKey: "dc991904cd0d2d40b3b67f40429826daebd4dd9fa68388a8e304b0cb46200cb9",
    secretKey: "6d370b3f65eb850a6001cecb6efcb2dbdafa90bff192b71862e875295692a6d1"
}

var nonExistingTestKeyPair = {
    publicKey: "24028c9060a09e77c1557ab0dd8923d1bd2f7d0e977874749e3bb732e5f6cc9d",
    secretKey: "3a07aff392ff8e2bf649fa34d5d9508a479da873a065ef7a76e937ea83d77783"
}

var numberOfChains = 20; // Number of active chains on the blockchain

var creationTime = () => Math.round(new Date().getTime() / 1000) - 15; // Creates a timestamp

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
        apiCommand = "";
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