// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IRentalController {

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
        uint256 nonce;
        uint256 tokenId;
        address nftAddress;
        address lenderAddress;
    }

    event Lend(address indexed lender, uint256 tokenId, address nftAddress, uint256 nonce);
    event Rent(address indexed renter, uint256 nonce);

    function rent(address renter, Listing memory listing) external;

}
