
async function loginChainweaver() {
        const accountName = document.getElementById("accountName").value;
        const testnet = false;
        
        if (!testnet) {
            // First sign 1 command with Chainweaver to check if user is the owner of the account

            // Create object to sign in chainweaver
            const signingCmd = {
                pactCode: "(coin.get-balance \"" + accountName + "\")",
                caps: Pact.lang.mkCap("GAS", "Capa to pay for gas", "coin.remediate"),
                chainId: "0",
                sender: "tester",
                signingPubKey: "floppie"
            }

            try {
                const signRequest = await Pact.wallet.sign(signingCmd); // Open chainweaver and await response (error or object to send to blockchain)
                console.log(signRequest.cmd);
                //const sendSigned = await Pact.wallet.sendSigned(signRequest, "https://api.testnet.chainweb.com/chainweb/testnet04/0.0/chain/0/pact");
                //console.log(sendSigned);
            } catch (error) {
                console.log(error)
            }
            
        }
}