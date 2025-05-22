// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../src/FunWithStorage.sol";

contract FunWithStorageTest is Test {
    FunWithStorage fun;

    function setUp() public {
        fun = new FunWithStorage();
    }

    function testInitialFavoriteNumber() public view {
        // slot 0
        assertEq(vm.load(address(fun), bytes32(uint256(0))), bytes32(uint256(25)));
    }

    function testInitialSomeBool() public view {
        // slot 1 - true = 0x01 in bool
        assertEq(vm.load(address(fun), bytes32(uint256(1))), bytes32(uint256(1)));
    }

    function testArrayLengthAndValue() public view {
        // slot 2 = length of array
        assertEq(vm.load(address(fun), bytes32(uint256(2))), bytes32(uint256(3)));

        // value at keccak256(2) = first element of array
        bytes32 arraySlot = keccak256(abi.encode(uint256(2)));
        
        assertEq(vm.load(address(fun), arraySlot), bytes32(uint256(222)));
        assertEq(vm.load(address(fun), bytes32(uint256(arraySlot) + 1)), bytes32(uint256(333)));
        assertEq(vm.load(address(fun), bytes32(uint256(arraySlot) + 2)), bytes32(uint256(444)));
    }

    function testMapSlot0() public view {
        // myMap[0] is stored at keccak256(abi.encode(uint256(0), uint256(3)))
        bytes32 mapSlot = keccak256(abi.encode(uint256(0), uint256(3)));
        assertEq(uint256(vm.load(address(fun), mapSlot)), 1); // true
    }

    function testMapSlot1() public view {
        bytes32 mapSlot = keccak256(abi.encode(uint256(1), uint256(3)));
        assertEq(uint256(vm.load(address(fun), mapSlot)), 0); // false
    }

    function testConstantNotInStorage() public view {
        // Constants are inlined and not stored
        // We test by calling a helper if needed
        // But vm.load should return 0
        assertEq(vm.load(address(fun), bytes32(uint256(4))), bytes32(0));
    }

    function testImmutableNotInStorage() public view {
        // Immutables are not stored in traditional storage slots
        // We'll test it via public getter if it existed
        // Otherwise this proves it's not in a known storage slot
        assertEq(vm.load(address(fun), bytes32(uint256(5))), bytes32(0));
    }

    function testDoStuffDoesntChangeStorage() public {
        bytes32 slot0Before = vm.load(address(fun), bytes32(uint256(0)));
        bytes32 slot1Before = vm.load(address(fun), bytes32(uint256(1)));

        fun.doStuff();

        bytes32 slot0After = vm.load(address(fun), bytes32(uint256(0)));
        bytes32 slot1After = vm.load(address(fun), bytes32(uint256(1)));

        assertEq(slot0Before, slot0After);
        assertEq(slot1Before, slot1After);
    }
}
