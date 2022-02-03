### This is the description of the token ping-pong contract which is bridged between Kovan and Alfajores

[Kovan deployment](https://kovan.etherscan.io/address/0x9e310c1cff6598a09fE82A12718bC08C98525E6D#code)
[Alfajores deployment](https://alfajores-blockscout.celo-testnet.org/address/0x534E01478423E3c802f3D8b1DFe8198e9E0BDcC0/transactions)

Those are deployments on both networks. To interact with a bridge you can go to the Kovan ERC20 contract [on Etherscan](https://kovan.etherscan.io/address/0x6C374F3e6Cf99D32E49b05EE6635685Cc560bc35#writeContract), and mint some ERC20 tokens to yourself.
Then you can open Kovan deployment, and call dispatchTypeMint funtion. This call will bridge tokens on alfajores. Alfajores ERC20 token is deployed [here](https://alfajores-blockscout.celo-testnet.org/address/0x6B58c875175ef0b698cdB6426a89C55b0d269dc9/transactions).
