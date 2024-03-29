// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "@src/ReNFT.sol";
import "@src/IReNFT.sol";
import "@src/SignatureChecker.sol";
// import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";

contract SigTest is Test {
    using SignatureChecker for address;

    address deployer;
    ReNFT reNft;

    function setUp() public {
        deployer = vm.addr(1);
        vm.label(deployer, "deployer");

        vm.prank(deployer, deployer);
        reNft = new ReNFT();
        vm.label(address(reNft), "ReNFT");
    }


    function testRent(address renter, uint256 lenderPK, address nftAddress) public {
        vm.assume(nftAddress != address(0));
        vm.assume(lenderPK > 10000);
        // vm requirement
        vm.assume(lenderPK < 115792089237316195423570985008687907852837564279074904382605163141518161494337);
        vm.assume(renter != address(0));

        address lender = vm.addr(lenderPK);

        vm.assume(renter != lender);

        vm.label(lender, "Lender");
        vm.label(renter, "Renter");
        vm.label(nftAddress, "MockNFT");

        IReNFT.Listing memory listing = IReNFT.Listing({
            startBlockTimestamp: block.timestamp,
            endBlockTimestamp: block.timestamp + 1_000_000,
            nonce: 0,
            tokenId: 1,
            nftAddress: nftAddress,
            lenderAddress: lender
        });

        bytes memory message = abi.encode(listing);

        bytes32 messageHash = SignatureChecker.getEthSignedMessageHash(keccak256(message));

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(lenderPK, messageHash);

        bytes memory signature = abi.encodePacked(r, s, v);

        vm.prank(renter, renter);
        reNft.rent(lender, signature, message);
    }

    function testFailsRentIfLenderIsNotSigner(address renter, uint256 lenderPK, address nftAddress, address random) public {
        vm.assume(nftAddress != address(0));
        vm.assume(lenderPK > 10000);
        // vm requirement
        vm.assume(lenderPK < 115792089237316195423570985008687907852837564279074904382605163141518161494337);
        vm.assume(renter != address(0));
        vm.assume(random != address(0));

        address lender = vm.addr(lenderPK);

        vm.assume(renter != lender);
        vm.assume(random != lender);

        vm.label(lender, "Lender");
        vm.label(renter, "Renter");
        vm.label(nftAddress, "MockNFT");

        IReNFT.Listing memory listing = IReNFT.Listing({
            startBlockTimestamp: block.timestamp,
            endBlockTimestamp: block.timestamp + 1_000_000,
            nonce: 0,
            tokenId: 1,
            nftAddress: nftAddress,
            lenderAddress: random // make random the lender
        });

        bytes memory message = abi.encode(listing);

        bytes32 messageHash = SignatureChecker.getEthSignedMessageHash(keccak256(message));

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(lenderPK, messageHash);

        bytes memory signature = abi.encodePacked(r, s, v);

        vm.prank(renter, renter);
        reNft.rent(lender, signature, message);
    }

}
