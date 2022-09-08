// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract RentalController {

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

    event Lend(address indexed lender, uint256 tokenId, address nftAddress, uint256 nonce);
    event Rent(address indexed renter, uint256 nonce);

    mapping(bytes32 => LendingRenting) public lendingsRentings;
    mapping(bytes32 => uint256) public nftNonce;
    address immutable owner;
    uint256 public lendingId;

    constructor(address _owner) {
        owner = _owner;
    }

    function lend(
        uint256 nonce, 
        uint256 tokenId,
        address nftAddress,
        address lender
    ) external onlyOwner returns(bytes32 lrKey){
        bytes32 nonceKey = keccak256(abi.encodePacked(nftAddress, tokenId));
        lrKey = _lrKey(nftAddress, tokenId, lendingId);

        LendingRenting storage lr = lendingsRentings[lrKey];

        require(nftNonce[nonceKey] == nonce, "RentalController: Invalid nonce");
        require(lr.lending.lenderAddress == address(0) , "RentalController: Lending already exists");

        lr.lending = Lending({
            nonce: nftNonce[nonceKey]++,
            tokenId: tokenId,
            nftAddress: nftAddress,
            lenderAddress: lender
        });

        lendingId++;

        emit Lend(lender, tokenId, nftAddress, nonce);
    }

    function rent(address renter, bytes32 lrKey) external onlyOwner {
        LendingRenting storage lr = lendingsRentings[lrKey];

        require(lr.lending.lenderAddress != address(0), "RentalController: Lending does not exist");
        require(lr.renting.renterAddress == address(0), "RentalController: Already rented out");
        require(renter != address(0), "RentalController: Invalid renter address");

        lendingsRentings[lrKey].renting = Renting({
            renterAddress: renter
        });
    }

    function _lrKey(address nftAddress, uint256 tokenId, uint256 _lendingId) internal pure returns(bytes32) {
        return keccak256(abi.encodePacked(nftAddress, tokenId, _lendingId));
    }


    modifier onlyOwner() {
        require(msg.sender == owner, "RentalController: caller is not the owner");
        _;
    }
   
}
