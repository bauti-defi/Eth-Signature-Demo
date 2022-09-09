// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "forge-std/StdJson.sol";
import "@src/SigDelegatorProxy.sol";
import "@src/RentalController.sol";
import "@src/IRentalController.sol";
import "@src/SignatureChecker.sol";
// import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";

contract SigTest is Test {
    using stdJson for string;
    using SignatureChecker for address;

    struct MockRental {
        string privateKey;
        address signer;
    }

    address deployer;
    SigDelegatorProxy proxy;
    RentalController controller;

    function setUp() public {
        deployer = vm.addr(1);
        vm.label(deployer, "deployer");

        vm.startPrank(deployer, deployer);
        proxy = new SigDelegatorProxy();
        vm.label(address(proxy), "Proxy");

        controller = new RentalController(address(proxy));
        vm.label(address(controller), "Controller");

        proxy.setTarget(address(controller));
        vm.stopPrank();
    }

    function toHexString(bytes memory buffer, bool preffix) public pure returns (string memory) {

        // Fixed buffer size for hexadecimal convertion
        bytes memory converted = new bytes(buffer.length * 2);

        bytes memory _base = "0123456789abcdef";

        for (uint256 i = 0; i < buffer.length; i++) {
            converted[i * 2] = _base[uint8(buffer[i]) / _base.length];
            converted[i * 2 + 1] = _base[uint8(buffer[i]) % _base.length];
        }

        return preffix ? string(abi.encodePacked("0x", converted)) : string(converted);
    }

    function testRent(address nftAddress) public {
        vm.assume(nftAddress != address(0));

        vm.label(nftAddress, "MockNFT");

        string memory root = vm.projectRoot();
        string memory path = string.concat(root, "/test/rental.json");
        string memory json = vm.readFile(path);
        bytes memory parsedJson = vm.parseJson(json);

        MockRental memory rental = abi.decode(parsedJson, (MockRental));

        vm.label(rental.signer, "renter");

        IRentalController.Listing memory listing = IRentalController.Listing({
            nonce: 0,
            tokenId: 1,
            nftAddress: nftAddress,
            lenderAddress: rental.signer
        });

        string[] memory inputs = new string[](6);

        inputs[0] = "cast";
        inputs[1] = "wallet";
        inputs[2] = "sign";
        inputs[3] = "--private-key";
        inputs[4] = rental.privateKey;
        inputs[5] = toHexString(abi.encode(listing), true);

        console2.logString(inputs[4]);

        bytes memory res = vm.ffi(inputs);

        console2.logString(string(res)[10]);
        console2.logBytes(res);
    }

    // function testSignature() public {
    //     address signer = vm.envAddress("SIGNER_PUBLIC_KEY");
    //     vm.label(signer, "Signer");

    //     // cast wallet sign --private-key $SIGNER_PRIVATE_KEY $MESSAGE
    //     bytes memory signature = vm.envBytes("SIGNATURE");
    //     string memory message = vm.envString("MESSAGE");

    //     bytes32 messageHash = keccak256(abi.encodePacked(message));

    //     console2.logBytes32(messageHash);

    //     assertTrue(signer.isValidSignatureNow(messageHash, signature));
    // }

}
