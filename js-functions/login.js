
async function confirmOwnership() {
        const accountName = document.getElementById("accountName").value;
        
            // First sign 1 command with Chainweaver to check if user is the owner of the account

            // Create object to sign in chainweaver, this object runs the blockchain function 'check-ownership' from the 'otk-test-module' module
            const signingCmd = createCommandCW("free.otk-test-module.check-ownership", accountName, 0)

            try {
                // Send a command to sign to chainweaver (wallet app)
                const sign = await fetch('http://localhost:9467/v1/sign', {
                    headers: {"Content-Type" : "application/json"},
                    body: JSON.stringify(signingCmd),
                    method: "POST"
                })
                if (sign.ok) {
                    // Send the signed command to blockchain
                    const sig = await sign.json();
                    const tx = await fetch(host(0, "local"), {
                        headers: {"Content-Type" : "application/json"},
                        body: JSON.stringify(sig.body),
                        method: "POST"
                    })
                    
                    if (tx.ok){
                        // When user is the owner (returns true) get balances for all tokens
                        const data = await tx.json()
                        if (data.result.data) {
                            getBalances(accountName)
                        }
                    }
                }
                
            } catch (error) {
                console.log("Error found: " + error)
            }
}

async function getBalances(accountName) {

    const tokenBalance = {}

    for (var token = 0; token < tokenList.length; token++) {

        tokenBalance[tokenList[token].coinName] = {}

        for (var chain = 0; chain < numberOfChains; chain++) {

                // Get contract location for testnet/mainnet
                const contractID = (testnet ? tokenList[token].contractIdTest : tokenList[token].contractIdMain);

                // Pact command to send to blockchain
                const code = "(" + contractID +".get-balance \"" + accountName + "\")";
            
                // Fetch command
                const fetchcommand = {
                    pactCode: code,
                    meta: Pact.lang.mkMeta("OTK", chain.toString(), 0.0001, 400, 0, 28800)
                };
                try {
                    // Using PACT api for simplicity
                    const tx = await Pact.fetch.local(fetchcommand, host(chain))
                    const chainNr = "chain" + chain;
                    if (tx['result'].status == "success") {
                        
                        tokenBalance[tokenList[token].coinName][chainNr] = tx['result'].data;
                        
                    } else {
                        tokenBalance[tokenList[token].coinName][chainNr] = 0.0;
                    }
                } catch (error) {
                    console.log("Error in fetching balance: " + error);
                }

        }
    }
    console.log(tokenBalance)
    return tokenBalance;
}

function createCommandCW(command, accountName, chain) {
                // Create object to sign in chainweaver, this object runs the blockchain function 'check-ownership' from the 'otk-test-module' module
                const signingCmd = {
                    code: "(" + command + " \"" + accountName + "\")",
                    caps: [{
                        "role": "GAS",
                        "description": "No need to pay for gas",
                        "cap": {
                          "args": [],
                          "name": "coin.GAS"
                        }
                      }],
                    data: {},
                    sender: accountName,
                    chainId: chain.toString(),
                    gasLimit: 1000,
                    gasPrice: 400,
                    nonce: "",
                    ttl: 1400,
                    signingPubKey: "",
                    networkId: ""
                }
                return signingCmd;
}

