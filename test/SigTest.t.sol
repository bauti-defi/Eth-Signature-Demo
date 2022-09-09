// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "forge-std/StdJson.sol";
import "@src/SignatureChecker.sol";

contract SigTest is Test {
    using stdJson for string;
    using SignatureChecker for address;

    struct Sig {
        bytes message;
        bytes32 messageHash;
        bytes privateKey;
        bytes signature;
        address signer;
    }


    function testSignatureValidation() public {
        string memory root = vm.projectRoot();
        string memory path = string.concat(root, "/test/signature.json");
        string memory json = vm.readFile(path);
        bytes memory parsedJson = vm.parseJson(json);

        Sig memory sig = abi.decode(parsedJson, (Sig));

        console2.logAddress(sig.signer);
        console2.logBytes32(sig.messageHash);
        console2.logBytes(sig.message);
        console2.logBytes(sig.signature);

        assertTrue(sig.signer.isValidSignature(sig.messageHash, sig.signature));
    }

}
