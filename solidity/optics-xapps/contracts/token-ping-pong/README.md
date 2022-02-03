### This is the description of the token ping-pong contract which is bridged between Kovan and Alfajores

[TokenRouter: Kovan deployment](https://kovan.etherscan.io/address/0x9e310c1cff6598a09fE82A12718bC08C98525E6D#code)
[Alfajores deployment](https://alfajores-blockscout.celo-testnet.org/address/0x534E01478423E3c802f3D8b1DFe8198e9E0BDcC0/transactions)

Those are deployments on both networks. 

To interact with a bridge you can go to the Mock-ERC20 contract deployed to Kovan [on Etherscan](https://kovan.etherscan.io/address/0x6C374F3e6Cf99D32E49b05EE6635685Cc560bc35#writeContract), and mint some ERC20 tokens to yourself.

Then you can open TokenRouter contract and call the `dispatchTypeMint` funtion. In order to send the tokens to Alfajores enter `1000` as `_destinationDomain`.

```
    function dispatchTypeMint(
        uint32 _destinationDomain,
        uint32 _amount,
        address to
    ) external {
        // get the xApp Router at the destinationDomain
        bytes32 _remoteRouterAddress = _mustHaveRemote(_destinationDomain);
        // encode a message to send to the remote xApp Router
        bytes memory _outboundMessage = TokenMessage.formatTypeMint(
            _amount,
            to
        );
        // send the message to the xApp Router
        token.burn(to, _amount);
        _home().dispatch(
        _destinationDomain,
        _remoteRouterAddress,
        _outboundMessage
        );
    }
```

This call will bridge tokens on Alfajores. (Please elaborate)
Alfajores ERC20 token is deployed [here](https://alfajores-blockscout.celo-testnet.org/address/0x6B58c875175ef0b698cdB6426a89C55b0d269dc9/transactions).

`dispatchTypeMint` will call ` _home().dispatch(...)` which gets received by the remote Replica, which then forards it to the remote `TokenRouter` contract on Alfajores. There `handle` is called which calls the internal `_handleTypeMint` function. This function calls `mint` on the remote ERC20 contract.
