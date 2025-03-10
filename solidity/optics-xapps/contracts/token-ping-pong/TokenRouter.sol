// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity >=0.6.11;

// ============ External Imports ============
import {TypedMemView} from "@summa-tx/memview-sol/contracts/TypedMemView.sol";
// ============ Internal Imports ============
import {TokenMessage} from "./TokenMessage.sol";
import {Router} from "../Router.sol";
import {XAppConnectionClient} from "../XAppConnectionClient.sol";
import {ERC20} from "./ERC20.sol";

/*
============ Overview: Building a xApp ============
To implement a xApp, define the actions you would like to execute across chains.
For each type of action,
- in the xApp Router
    - implement a function like doTypeA to initiate the action from one domain to another (add your own parameters and logic)
    - implement a corresponding _handle function to receive, parse, and execute this type of message on the remote domain
    - add logic to the handle function to route incoming messages to the appropriate _handle function
- in the Message library,
    - implement functions to *format* the message to send to the other chain (encodes all necessary information for the action)
    - implement functions to *parse* the message once it is received on the other chain (decode all necessary information for the action)
*/
contract TokenRouter is Router {
    ERC20 public token;

    // ============ Libraries ============

    using TypedMemView for bytes;
    using TypedMemView for bytes29;
    //    using Message for bytes29;

    // ============ Events ============

    event MintReceived(uint256 amount, address to);
    event BurnReceived(uint256 amount, address to);

    // ============ Constructor ============

    constructor(address _xAppConnectionManager, address _token) {
        __XAppConnectionClient_initialize(_xAppConnectionManager);
        token = ERC20(_token);
    }

    // ============ Handle message functions ============

    /**
     * @notice Receive messages sent via Optics from other remote xApp Routers;
     * parse the contents of the message and enact the message's effects on the local chain
     * @dev Called by an Optics Replica contract while processing a message sent via Optics
     * @param _origin The domain the message is coming from
     * @param _sender The address the message is coming from
     * @param _message The message in the form of raw bytes
     */
    function handle(
        uint32 _origin,
        bytes32 _sender,
        bytes calldata _message
    ) external override onlyReplica onlyRemoteRouter(_origin, _sender)  {
        //        bytes29 _msg = _message.ref(0);
        // route message to appropriate _handle function
        // based on what type of message is encoded
        (uint8 tt, uint32 amount, address to) = abi.decode(_message, (uint8, uint32, address));
        if (tt == 1) {
            _handleTypeMint(_message);
        } else {
            if (tt == 2) {
                _handleTypeBurn(_message);
            }
            // if _message doesn't match any valid actions, revert
            require(false, "!valid action");
        }
    }

    /**
     * @notice Once the Router has parsed a message in the handle function and determined it is Type A,
     * call this internal function to parse specific information from the message,
     * and enact the message's action on this chain
     * @param _message The message in the form of raw bytes
     */
    function _handleTypeMint(bytes calldata _message) internal {
        (uint8 tt, uint32 _amount, address _to) = abi.decode(_message, (uint8, uint32, address));
        // parse the information from the message
        // implement the logic for executing the action
        // (in this example case, emit an event with the number that was sent)
        token.mint(_to, _amount);
        emit MintReceived(_amount, _to);
    }

    function _handleTypeBurn(bytes calldata _message) internal {
        // parse the information from the message
        (uint8 tt, uint32 _amount, address _to) = abi.decode(_message, (uint8, uint32, address));
        // implement the logic for executing the action
        // (in this example case, emit an event with the number that was sent)
        token.burn(_to, _amount);
        emit BurnReceived(_amount, _to);
    }

    // ============ Dispatch message functions ============

    /**
     * @notice Send a message of "Type A" to a remote xApp Router via Optics;
     * this message is called to take some action in the cross-chain context
     * Example message types:
     * Sending tokens from this chain to the destination chain;
     * params would be the address of the token, the amount of the token to send, and the address of the recipient
     * @param _destinationDomain The domain to send the message to
     * @param _amount Example parameter used in message TypeA - a number to send to another chain
     */
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

    function dispatchTypeBurn(
        uint32 _destinationDomain,
        uint32 _amount,
        address to
    ) external {
        // get the xApp Router at the destinationDomain
        bytes32 _remoteRouterAddress = _mustHaveRemote(_destinationDomain);
        // encode a message to send to the remote xApp Router
        bytes memory _outboundMessage = TokenMessage.formatTypeBurn(
            _amount,
            to
        );
        // send the message to the xApp Router
        token.mint(to, _amount);
            _home().dispatch(
            _destinationDomain,
            _remoteRouterAddress,
            _outboundMessage
        );
    }
}
