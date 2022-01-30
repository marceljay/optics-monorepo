// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity >=0.6.11;

import "@summa-tx/memview-sol/contracts/TypedMemView.sol";

library TokenMessage {
    using TypedMemView for bytes;
    using TypedMemView for bytes29;

    enum Types {
        Invalid, // 0
        Mint, // 1
        Burn // 1
    }

    // ============ Formatters ============

    /**
     * @notice Given the information needed for a message TypeA
     * (in this example case, the information is just a single number)
     * format a bytes message encoding the information
     * @param _amount The number to be included in the TypeA message
     * @return The encoded bytes message
     */
    function formatTypeMint(uint32 _amount, address to)
        internal
        pure
        returns (bytes memory)
    {
        return abi.encode(uint8(Types.Mint), _amount, to);
    }

    function formatTypeBurn(uint32 _amount, address to)
        internal
        pure
        returns (bytes memory)
    {
        return abi.encode(uint8(Types.Burn), _amount, to);
    }

    // ============ Identifiers ============

    /**
     * @notice Get the type that the TypedMemView is cast to
     * @param _view The message
     * @return _type The type of the message (one of the enum Types)
     */
    function messageType(bytes29 _view) internal pure returns (Types _type) {
        _type = Types(uint8(_view.typeOf()));
    }

    /**
     * @notice Determine whether the message is a message TypeA
     * @param _view The message
     * @return _isTypeMint True if the message is TypeA
     */
    function isTypeMint(bytes calldata _view)
        internal
        pure
        returns (bool _isTypeMint)
    {
        uint8 tt = uint8(_view[0]);
        _isTypeMint = Types(tt) == Types.Mint;
    }

    function isTypeBurn(bytes calldata _view)
        internal
        pure
        returns (bool _isTypeBurn)
    {
        uint8 tt = uint8(_view[0]);
        _isTypeBurn = Types(tt) == Types.Burn;
    }

    // ============ Getters ============

    /**
     * @notice Parse the amount sent within a Mint message
     * @param _view The message
     * @return _amount The number encoded in the message
     */
    function amount(bytes calldata _view)
        internal
        pure
        returns (uint256 _amount)
    {
        require(
            isTypeMint(_view) || isTypeBurn(_view),
            "MessageTemplate/number: view must be of type A"
        );
        _amount = abi.decode(_view[1:5], (uint32));
    }

    function to(bytes calldata _view) internal pure returns (address _to) {
        require(
            isTypeMint(_view) || isTypeBurn(_view),
            "MessageTemplate/number: view must be of type A"
        );
        _to = abi.decode(_view[6:26], (address));
    }

    //    function isPing(bytes29 _view) internal pure returns (bool) {
    //        return messageType(_view) == Types.Ping;
    //    }
    //
    ////    /**
    ////     * @notice Determine whether the message contains a Pong volley
    ////     * @param _view The message
    ////     * @return True if the volley is Pong
    ////     */
    ////    function matchId(bytes29 _view) internal pure returns (uint32) {
    ////        // At index 1, read 4 bytes as a uint, and cast to a uint32
    ////        return uint32(_view.indexUint(1, 4));
    ////    }
}
