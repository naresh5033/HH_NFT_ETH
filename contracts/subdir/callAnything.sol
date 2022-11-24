// SPDX-License-Identifier: MIT

// So why do we care about all this encoding stuff?

// In order to call a function using only the data field of call, we need to encode:
// The function name
// The parameters we want to add
// Down to the binary level

// Now each contract assigns each function it has a function ID. This is known as the "function selector".
// The "function selector" is the first 4 bytes of the function signature.
// The "function signature" is a string that defines the function name & parameters.
// Let's look at this

pragma solidity ^0.8.7;

contract CallAnything {
    address public s_someAddress;
    uint256 public s_amount;

    function transfer(address someAddress, uint256 amount) public {
        // Some code
        s_someAddress = someAddress;
        s_amount = amount;
    }

    //lets see one amongst the few way to get the fn selector (ex --> fn selector - 0x9059cbb)
    // We can get a function selector as easy as this.
    // "transfer(address,uint256)" is our function signature
    // and our resulting function selector of "transfer(address,uint256)" is output from this function
    function getSelectorOne() public pure returns (bytes4 selector) {
        selector = bytes4(keccak256(bytes("transfer(address,uint256)"))); // we passed the fn signature a byte form
    } // the selector returns 0x9059cbb

    //we ve the fn selector now we also want the fn params(someAdddr and Amt) to be encoded
    function getDataToCallTransfer(address someAddress, uint256 amount)
        public
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(getSelectorOne(), someAddress, amount);
    } // this abi encodes the given args starting from the second and prpends the give 4 byte selector

    // So... How can we use the selector to call our transfer function(w/o calling directly) now then?
    function callTransferFunctionDirectly(address someAddress, uint256 amount)
        public
        returns (bytes4, bool)
    {
        (bool success, bytes memory returnData) = address(this).call(
            // getDataToCallTransfer(someAddress, amount); or
            abi.encodeWithSelector(getSelectorOne(), someAddress, amount)
        );
        return (bytes4(returnData), success);
    }

    // Using encodeWithSignature(instead of selector)
    function callTransferFunctionDirectlyTwo(
        address someAddress,
        uint256 amount
    ) public returns (bytes4, bool) {
        (bool success, bytes memory returnData) = address(this).call(
            abi.encodeWithSignature(
                "transfer(address,uint256)",
                someAddress,
                amount
            )
        );
        return (bytes4(returnData), success);
    }

    // There are whole bunch of diff was to get the selector
    // We can also get a function selector from data sent into the call
    function getSelectorTwo() public view returns (bytes4 selector) {
        bytes memory functionCallData = abi.encodeWithSignature(
            "transfer(address,uint256)",
            address(this),
            123
        );
        selector = bytes4(
            bytes.concat(
                functionCallData[0],
                functionCallData[1],
                functionCallData[2],
                functionCallData[3]
            )
        );
    }

    // Another way to get data (hard coded)
    function getCallData() public view returns (bytes memory) {
        return
            abi.encodeWithSignature(
                "transfer(address,uint256)",
                address(this),
                123
            );
    }

    // Pass this:
    // 0xa9059cbb000000000000000000000000d7acd2a9fd159e69bb102a1ca21c9a3e3a5f771b000000000000000000000000000000000000000000000000000000000000007b
    // This is output of `getCallData()`
    // This is another low level way to get function selector using assembly
    // You can actually write code that resembles the opcodes using the assembly keyword!
    // This in-line assembly is called "Yul"
    // It's a best practice to use it as little as possible - only when you need to do something very VERY specific
    function getSelectorThree(bytes calldata functionCallData)
        public
        pure
        returns (bytes4 selector)
    {
        // offset is a special attribute of calldata
        assembly {
            selector := calldataload(functionCallData.offset)
        }
    }

    // Another way to get your selector with the "this" keyword
    function getSelectorFour() public pure returns (bytes4 selector) {
        return this.transfer.selector;
    }

    // Just a function that gets the signature
    function getSignatureOne() public pure returns (string memory) {
        return "transfer(address,uint256)";
    }
}

contract CallFunctionWithoutContract {
    address public s_selectorsAndSignaturesAddress;

    constructor(address selectorsAndSignaturesAddress) {
        s_selectorsAndSignaturesAddress = selectorsAndSignaturesAddress;
    }

    // pass in 0xa9059cbb000000000000000000000000d7acd2a9fd159e69bb102a1ca21c9a3e3a5f771b000000000000000000000000000000000000000000000000000000000000007b
    // you could use this to change state
    //by calling this fn in this contract, we can directly call the transfer() from the 1st contract
    function callFunctionDirectly(bytes calldata callData)
        public
        returns (bytes4, bool)
    {
        (
            bool success,
            bytes memory returnData
        ) = s_selectorsAndSignaturesAddress.call(
                abi.encodeWithSignature("getSelectorThree(bytes)", callData)
            );
        return (bytes4(returnData), success);
    }

    // with a staticcall, we can have this be a view function!
    function staticCallFunctionDirectly() public view returns (bytes4, bool) {
        (
            bool success,
            bytes memory returnData
        ) = s_selectorsAndSignaturesAddress.staticcall(
                abi.encodeWithSignature("getSelectorOne()")
            );
        return (bytes4(returnData), success);
    }

    // by calling this fn in this contract, we can directly call the transfer() from the 1st contract
    function callTransferFunctionDirectlyThree(
        address someAddress,
        uint256 amount
    ) public returns (bytes4, bool) {
        (
            bool success,
            bytes memory returnData
        ) = s_selectorsAndSignaturesAddress.call(
                abi.encodeWithSignature(
                    "transfer(address,uint256)",
                    someAddress,
                    amount
                )
            );
        return (bytes4(returnData), success);
    }
}
