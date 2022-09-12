// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IReNFT {

    struct Lending {
        uint256 nonce;
        uint256 tokenId;
        address nftAddress;
        address lenderAddress;
    }

    struct Renting {
        address renterAddress;
    }

    struct LendingRenting {
        Lending lending;
        Renting renting;
    }

    struct Listing {
        uint256 startBlockTimestamp;
        uint256 endBlockTimestamp;

        //Below here is same as listing
        uint256 nonce;
        uint256 tokenId;
        address nftAddress;
        address lenderAddress;
    }

    event Lend(address indexed lender, uint256 tokenId, address nftAddress, uint256 nonce);
    event Rent(address indexed renter, uint256 nonce);

    function rent(address signer, bytes memory signature, bytes memory call) external;

}
