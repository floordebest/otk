
async function confirmOwnership() {
        const accountName = document.getElementById("accountName").value;
        const privKey = document.getElementById("privateKey").value;

        if (privKey) {
            // If private key is entered, go to private key login
            loginWithSecretKey(accountName, privKey);
        } else {
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
}
async function loginWithSecretKey(accountName, privKey) {
    // Try to get the public key from the private key
    try {
        const keyPair = Pact.crypto.restoreKeyPairFromSecretKey(privKey);
        const command = "(free.otk-test-module.check-ownership \"" + accountName + "\")"

        const sig = signWithPact(keyPair, command, 0);

        const tx = await fetch(host(0, "local"), {
            headers: {"Content-Type" : "application/json"},
            body: JSON.stringify(sig),
            method: "POST"
        })
        if (tx.ok) {
            const data = await tx.json();
            if (data.result.data) {
                console.log(data.result.data);
                getBalances(accountName)
            } else if (data.result.error.message.includes("row not found")){
                console.log("Error: Account does not exist on the Kadena Blockchain, make sure your account is active on chain 0")
            }
        }

    } catch (error) {
        console.log("Error: " + error)
    }
}
async function getBalances(accountName) {

    const tokenBalance = {}

    for (var token = 0; token < tokenList.length; token++) {

        tokenBalance[tokenList[token].coinName] = {}

        for (var chain = 0; chain < numberOfChains; chain++) {

                // Get contract location for testnet/mainnet
                const contractID = (testnet ? tokenList[token].contractIdTest : tokenList[token].contractIdMain);
                const chainNr = "chain" + chain;
                const command = getBalanceCommand(contractID, accountName, chain)

                try {
                    const tx = await fetch(host(chain, "local"), {
                        headers: {"Content-Type" : "application/json"},
                        body: JSON.stringify(command),
                        method: "POST"
                    })
                    if (tx.ok) {
                        const data = await tx.json();
                        if (data.result.status == "success") {
                            tokenBalance[tokenList[token].coinName][chainNr] = data.result.data;
                        } else if (data.result.error.message.includes("row not found")) {
                            tokenBalance[tokenList[token].coinName][chainNr] = 0.0;
                        }
                    }
                } catch (error) {
                    console.log(error)
                }
        }
    }
    // Returns balance for each chain on each token ({token : chain : balance})
    console.log(tokenBalance);
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

function getBalanceCommand(token, accountName, chain) {

    // Pact command to send to blockchain
    const code = "(" + token +".get-balance \"" + accountName + "\")";

    // Fetch command
    const fetchcommand = {
        pactCode: code,
        meta: Pact.lang.mkMeta("OTK", chain.toString(), 0.0001, 400, 0, 28800)
    };

    // Let Pact API sign the transaction
    const {keyPairs, nonce, pactCode, envData, meta, networkId} = fetchcommand
    const sigs = Pact.api.prepareExecCmd(keyPairs, nonce, pactCode, envData, meta, networkId)

    return sigs;
}

function signWithPact(keyPair, command, chain) {

    // Fetch command
    const fetchcommand = {
        pactCode: command,
        meta: Pact.lang.mkMeta("OTK", chain.toString(), 0.0001, 400, 0, 28800),
        keyPairs: (keyPair ? [keyPair] : [])
    };

    // Let Pact API sign the transaction
    const {keyPairs, nonce, pactCode, envData, meta, networkId} = fetchcommand
    const sigs = Pact.api.prepareExecCmd(keyPairs, nonce, pactCode, envData, meta, networkId)

    return sigs;
}

