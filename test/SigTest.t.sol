// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "@src/SignatureChecker.sol";

contract SigTest is Test {
    using SignatureChecker for address;

    function testSignatureValidationE2E() public {
        uint256 privateKey = 123;
        address signer = vm.addr(privateKey);

        bytes memory message = bytes("hello world");

        bytes32 messageHash = SignatureChecker.getEthSignedMessageHash(keccak256(message));

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, messageHash);

        bytes memory signature = abi.encodePacked(r, s, v);

        assert(signer.isValidSignature(messageHash, signature));
    }

}
