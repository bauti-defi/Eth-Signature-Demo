// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../src/SigPlayground.sol";

contract SigTest is Test {

    SigPlayground sigPlayground;

    function setUp() public {
        sigPlayground = new SigPlayground();
    }

    function testSetNounce(uint256 nonce) public {
        sigPlayground.setNounce(nonce);
        // assertEq(sigPlayground.userNounces(address(this)), 1);
    }

    function testStuff() public{
        for(uint256 i = 0; i < 10; i++){
            console2.logUint(i);
            bytes memory R  = abi.encodeWithSignature("tester(uint256,uin256,uint8)", i, i, i);

            console2.logBytes(R);
            // console2.logBytes(keccak256(string(R)));
        }
        
    }

    function testCallPrivate(uint256 index) public {
        assertTrue(sigPlayground.callPrivate(index));

    }
   
}
