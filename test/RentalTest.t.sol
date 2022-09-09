// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "forge-std/StdJson.sol";
import "@src/SigDelegatorProxy.sol";
import "@src/RentalController.sol";
import "@src/IRentalController.sol";
import "@src/SignatureChecker.sol";
import "@string-utils/strings.sol";
// import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";

contract SigTest is Test {
    using strings for *;
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

        vm.label(rental.signer, "Lender");

        IRentalController.Listing memory listing = IRentalController.Listing({
            nonce: 0,
            tokenId: 1,
            nftAddress: nftAddress,
            lenderAddress: rental.signer
        });

        // Lets generate a signature

        string[] memory inputs = new string[](6);

        inputs[0] = "cast";
        inputs[1] = "wallet";
        inputs[2] = "sign";
        inputs[3] = "--private-key";
        inputs[4] = rental.privateKey;
        inputs[5] = vm.toString(abi.encode(listing));

        bytes memory res = vm.ffi(inputs);
        // res: "Signature: 0x5bf72af31a009c39fb94c8d6da44d2a92d6cffaba2301a847132096759122a522ba88ee07a9ad20c72a1c44793cb853bed5524648f1e3d7957751053b28814ac1b"
        console2.logBytes(res);
        // console2.logBytes(abi.encodePacked("Signature: ")); // 0x5369676e61747572653a20

        // bytes memory header;
        // bytes memory signature;

        console2.logBytes(res[10:15]);


        // strings.slice memory output = string(res).toSlice();

        // strings.slice memory splitAt = "Signature: ".toSlice();
        // // Extract the signature from output
        // string memory signature = output.copy().find(splitAt).beyond(splitAt).toString();

        // console2.logString(signature);
        // console2.logBytes(abi.encodePacked(signature));

        // proxy.delegateCall(rental.signer, bytes(signature), abi.encode(listing));
    }

}
