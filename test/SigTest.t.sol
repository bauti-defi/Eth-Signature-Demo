// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "@src/SigDelegatorProxy.sol";
import "@src/RentalController.sol";
import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";

contract SigTest is Test {

    using SignatureChecker for address;

    address lender;
    address deployer;
    SigDelegatorProxy proxy;
    RentalController controller;

    // 0xb98d9a21518fad8be723ff7683d5df01e65d2195472123767d32df598f09597e5534b12fb6b85769eacd647114908cb411ecd1abb1c68416bb9dac55f1cf537a1b
    // bytes constant signature = "0xb98d9a21518fad8be723ff7683d5df01e65d2195472123767d32df598f09597e5534b12fb6b85769eacd647114908cb411ecd1abb1c68416bb9dac55f1cf537a1b";

    function setUp() public {
        deployer = vm.addr(1);
        vm.label(deployer, "deployer");

        lender = vm.addr(2);
        vm.label(lender, "lender");

        vm.startPrank(deployer, deployer);
        proxy = new SigDelegatorProxy();
        vm.label(address(proxy), "Proxy");

        controller = new RentalController(address(proxy));
        vm.label(address(controller), "Controller");

        proxy.setTarget(address(controller));
        vm.stopPrank();
    }

    function testRent(address nftAddress) public {
        vm.label(nftAddress, "MockNFT");

        bytes memory functionCall = abi.encodeWithSignature("postListing(uint256,uint256,address,address)",0,0,nftAddress,lender);
        console2.logBytes(functionCall);
        console2.logBytes32(keccak256(functionCall));

        proxy.delegateCall(keccak256(functionCall), functionCall);
    }

    function testSignature() public {
        address signer = vm.envAddress("SIGNER_PUBLIC_KEY");
        vm.label(signer, "Signer");

        // cast wallet sign --private-key $SIGNER_PRIVATE_KEY $MESSAGE
        bytes memory signature = vm.envBytes("SIGNATURE");
        string memory message = vm.envString("MESSAGE");

        bytes32 messageHash = keccak256(abi.encode(message));

        signer.isValidSignatureNow(messageHash, signature);
    }

}
