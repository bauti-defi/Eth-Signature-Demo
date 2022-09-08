// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";

contract SigDelegatorProxy is Ownable {

    address public target;

    function delegateCall(bytes32 hash, bytes memory call) public initiated {
        require(keccak256(call) == hash, "SigDelegatorProxy: invalid hash");

        (bool postListingResult, bytes memory lrKey) = target.call(call);

        require(postListingResult, "SigDelegatorProxy: postListing call failed");
        require(lrKey.length == 32, "SigDelegatorProxy: Invalid lrKey");

        (bool rentResult, ) = target.call(abi.encodeWithSignature("rent(address,bytes32)", msg.sender, bytes32(lrKey)));

        require(rentResult, "SigDelegatorProxy: Rent call failed");
    }

    function setTarget(address _target) public onlyOwner {
        target = _target;
    }

    modifier initiated() {
        require(target != address(0), "SigDelegatorProxy: target not set");
        _;
    }
   
}
