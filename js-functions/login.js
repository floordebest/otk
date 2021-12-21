
async function confirmOwnership() {
        const accountName = document.getElementById("accountName").value;
        
            // First sign 1 command with Chainweaver to check if user is the owner of the account

            // Create object to sign in chainweaver, this object runs the blockchain function 'check-ownership' from the 'otk-test-module' module
            const signingCmd = {
                code: "(free.otk-test-module.check-ownership \"" + accountName + "\")",
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
                chainId: "0",
                gasLimit: 1000,
                gasPrice: 400,
                nonce: "",
                ttl: 1400,
                signingPubKey: "",
                networkId: ""
            }

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
    console.log("Get balance for:" + accountName)
}