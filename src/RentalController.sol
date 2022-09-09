// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "./IRentalController.sol";

contract RentalController is IRentalController{

    mapping(bytes32 => LendingRenting) public lendingsRentings;
    mapping(bytes32 => uint256) public nftNonce;
    address immutable owner;
    uint256 public lendingId;

    constructor(address _owner) {
        owner = _owner;
    }


    function postListing(Listing memory listing) private returns(bytes32 lrKey){
        require(listing.lenderAddress != address(0), "RentalController: lender address is zero");

        bytes32 nonceKey = keccak256(abi.encodePacked(listing.nftAddress, listing.tokenId));
        lrKey = _lrKey(listing.nftAddress, listing.tokenId, lendingId);

        LendingRenting storage lr = lendingsRentings[lrKey];

        require(nftNonce[nonceKey] == listing.nonce, "RentalController: Invalid nonce");
        require(lr.lending.lenderAddress == address(0) , "RentalController: Lending already exists");

        lr.lending = Lending({
            nonce: nftNonce[nonceKey]++,
            tokenId: listing.tokenId,
            nftAddress: listing.nftAddress,
            lenderAddress: listing.lenderAddress
        });

        lendingId++;

        emit Lend(listing.lenderAddress, listing.tokenId, listing.nftAddress, listing.nonce);
    }

    function _rent(address renter, bytes32 lrKey) private {
        LendingRenting storage lr = lendingsRentings[lrKey];

        require(lr.lending.lenderAddress != address(0), "RentalController: Lending does not exist");
        require(lr.renting.renterAddress == address(0), "RentalController: Already rented out");
        require(renter != address(0), "RentalController: Invalid renter address");

        lendingsRentings[lrKey].renting = Renting({
            renterAddress: renter
        });

        // perform all transfers (nfts and tokens) here
    }

    function rent(address renter, Listing memory listing) external onlyOwner {
        bytes32 lrKey = postListing(listing);
        _rent(renter, lrKey);
    }

    function stopRent() public {
        // TODO: implement
    }

    function _lrKey(address nftAddress, uint256 tokenId, uint256 _lendingId) internal pure returns(bytes32) {
        return keccak256(abi.encodePacked(nftAddress, tokenId, _lendingId));
    }


    modifier onlyOwner() {
        require(msg.sender == owner, "RentalController: caller is not the owner");
        _;
    }
   
}
