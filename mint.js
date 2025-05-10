require('dotenv').config(); // Load environment variables
const fs = require('fs');
const Web3 = require('web3');
const wallets = require('./wallets');
const erc20Abi = require('./erc20Abi.json');

// Initialize Web3 with your Ethereum node provider
const web3 = new Web3(process.env.ETH_NODE_RPC_URL || 'https://rpc.katla.taiko.xyz');

// Set up your contract address and the account addresses
const contractAddress = process.env.CONTRACT_ADDRESS;
const abiFound = erc20Abi ? 'ABI found' : 'ABI not found';
console.log(abiFound); // Log if ABI is found or not
console.log('Contract Address:', contractAddress); // Log contract address
const tokenContract = new web3.eth.Contract(erc20Abi, contractAddress);

const fromAddress = process.env.SENDER_ADDRESS; // The address sending the tokens

// Load or create the file to store addresses that have received tokens
const receivedAddressesFile = './received_addresses.json';
let receivedAddresses = [];
try {
    if (fs.existsSync(receivedAddressesFile)) {
        receivedAddresses = JSON.parse(fs.readFileSync(receivedAddressesFile));
    } else {
        fs.writeFileSync(receivedAddressesFile, JSON.stringify(receivedAddresses, null, 2)); // Start with an empty array
    }
} catch (error) {
    console.error('Error loading or creating received addresses file:', error);
}

// Method to mint random amounts of tokens to multiple wallets
const mintTokensToWallets = async () => {
    try {
        for (const toAddress of wallets) {
            // Skip if the address has already received tokens
            if (receivedAddresses.includes(toAddress)) {
                console.log(`Skipping address ${toAddress} as it has already received tokens.`);
                continue;
            }

            // Generate a random amount between 1 and 1000 tokens
            const amountToMint = Math.floor(Math.random() * 1000) + 1;

            // Get the decimals of the token
            const decimals = await tokenContract.methods.decimals().call();

            // Convert the random amount you want to mint into the smallest unit based on the number of decimals
            const amountInWei = web3.utils.toBN(amountToMint).mul(web3.utils.toBN(10 ** decimals));

            // Get the current nonce
            const nonce = await web3.eth.getTransactionCount(fromAddress);

            // Estimate the gas needed for the transaction
            const estimateGas = await tokenContract.methods.mint(toAddress, amountInWei).estimateGas({ from: fromAddress });

            // Get the gas price
            const gasPrice = await web3.eth.getGasPrice();

            // Build the transaction
            const txObject = {
                nonce: web3.utils.toHex(nonce),
                gasLimit: web3.utils.toHex(estimateGas),
                gasPrice: web3.utils.toHex(gasPrice),
                to: contractAddress,
                data: tokenContract.methods.mint(toAddress, amountInWei).encodeABI()
            };

            // The private key of the sender address (make sure to keep this secure!)
            const privateKey = Buffer.from(process.env.PRIVATE_KEY, 'hex');

            // Sign the transaction
            const signedTx = await web3.eth.accounts.signTransaction(txObject, privateKey.toString('hex'));

            // Send the signed transaction
            const txReceipt = await web3.eth.sendSignedTransaction(signedTx.rawTransaction);

            console.log(`Tokens minted successfully to ${toAddress}: ${amountToMint} tokens`);
            //console.log('Transaction Hash:', txReceipt.transactionHash);

            // Add the address to the receivedAddresses array
            receivedAddresses.push(toAddress);
            // Write the updated receivedAddresses array to the file with new line for each address
            fs.writeFileSync(receivedAddressesFile, JSON.stringify(receivedAddresses, null, 2));
        }
        console.log('All token minting completed successfully!');
    } catch (error) {
        console.error('Error minting tokens:', error);
        if (error.message.includes('invalid nonce')) {
            console.log('Invalid nonce error encountered. Retrying in 10 seconds...');
            await new Promise(resolve => setTimeout(resolve, 10000)); // Wait for 10 seconds
            console.log('Retrying token minting...');
            await mintTokensToWallets(); // Retry the token minting
        } else {
            console.error('Unhandled error:', error);
        }
    }
};

// Call the mintTokensToWallets function to initiate the minting process
mintTokensToWallets();