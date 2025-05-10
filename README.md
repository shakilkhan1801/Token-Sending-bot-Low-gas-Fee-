# Token Sending Bot with Low Gas Fee

A Node.js bot for minting and sending ERC20 tokens with optimized gas fees on the Ethereum network.

## Features

- Mint new ERC20 tokens to multiple addresses
- Send existing tokens to multiple addresses
- Optimized gas fee calculations
- Transaction tracking and retry mechanism
- Environment-based configuration
- Support for custom RPC endpoints
- Automatic tracking of sent tokens to prevent duplicate transactions

## Installation

```bash
npm install token-sending-bot
```

## Configuration

Create a `.env` file in your project root:

```env
# Ethereum Configuration
ETH_NODE_RPC_URL=https://rpc.katla.taiko.xyz
SENDER_ADDRESS=your_wallet_address_here
PRIVATE_KEY=your_private_key_here
CONTRACT_ADDRESS=your_token_contract_address_here
```

## Usage

1. Create a `wallets.js` file with recipient addresses:

```javascript
const wallets = [
    '0x742d35Cc6634C0532925a3b844Bc454e4438f44e',
    '0x123f681646d4A755815f9CB19e1aCc8565a0c2AC'
];

module.exports = wallets;
```

2. Run the bot:

```bash
npm start
```

## How It Works

The bot performs the following operations:

1. **Token Minting**:
   - Mints random amounts of tokens (1-1000) to each address in the wallets list
   - Automatically handles token decimals
   - Tracks minted addresses to prevent duplicate minting

2. **Transaction Management**:
   - Calculates optimal gas fees
   - Handles transaction retries if needed
   - Maintains a record of successful transactions

3. **Progress Tracking**:
   - Creates a `received_addresses.json` file to track successful transactions
   - Skips addresses that have already received tokens
   - Provides console output for monitoring progress

## Important Notes

- The sender address must have minting permissions on the token contract
- The sender address must have enough ETH for gas fees
- The bot will automatically retry failed transactions
- Each address will receive a random amount of tokens between 1 and 1000

## Security

- Never commit your `.env` file
- Keep your private keys secure
- Use environment variables for sensitive data
- The bot automatically tracks sent tokens to prevent duplicate transactions

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

Shakil Khan

## Support

If you find this project helpful, please give it a ⭐️ on GitHub! 