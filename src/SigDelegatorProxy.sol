// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./SignatureChecker.sol";
import "./IRentalController.sol";

contract SigDelegatorProxy is Ownable {

    address public target;

    function delegateCall(address signer, bytes memory signature, bytes memory call) public initiated {
        require(SignatureChecker.isValidSignature(signer, SignatureChecker.getEthSignedMessageHash(keccak256(call)), signature), "SigDelegatorProxy: invalid signature");
        
        IRentalController.Listing memory listing = abi.decode(call, (IRentalController.Listing));
        require(listing.lenderAddress == signer, "SigDelegatorProxy: Cannot lend on behalf of another");

        IRentalController(target).rent(msg.sender, listing);
    }

    function setTarget(address _target) public onlyOwner {
        target = _target;
    }

    modifier initiated() {
        require(target != address(0), "SigDelegatorProxy: target not set");
        _;
    }
   
}
