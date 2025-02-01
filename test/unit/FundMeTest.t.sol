//SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    uint256 paisa = 1 ether;
    address USER = makeAddr("USER");
    uint256 Starting_Balance = 10 ether;
    uint256 GAS_PRICE = 1;

    function setUp() external {
        vm.deal(USER, Starting_Balance);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
    }

    function testMinimumUsd() public view {
        assertEq(fundMe.MIN_USD(), 50);
    }

    function testOwner() public view {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testgetDecimal() public view {
        assertEq(fundMe.getdecimal(), 8);
    }

    function testFundfailsWithoutEnoughETH() public {
        vm.expectRevert();
        fundMe.Fund();
    }

    function testKitnaPaisaDiya() public {
        vm.prank(USER);
        fundMe.Fund{value: paisa}();
        uint256 senderAmount = fundMe.getKitnaPaisaDiya(USER);
        assertEq(senderAmount, paisa);
    }

    function testFundUpdatesSenderList() public {
        vm.prank(USER);
        fundMe.Fund{value: paisa}();
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    modifier transaction() {
        vm.prank(USER);
        fundMe.Fund{value: paisa}();
        assert(address(fundMe).balance > 0);
        _;
    }

    function testWithdrawforOnlyOwner() public transaction {
        //vm.prank(USER);
        //fundMe.Fund{value: paisa}();

        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawforSingleTransaction() public transaction {
        uint256 OwnerBalanceBefore = fundMe.getOwner().balance;
        uint256 ContractbalanceBefore = address(fundMe).balance;

        vm.txGasPrice(GAS_PRICE);
        uint256 gasStart = gasleft();

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log("Withdraw consumed %d gas", gasUsed);

        uint256 OwnerBalanceAfter = fundMe.getOwner().balance;
        uint256 ContractbalanceAfter = address(fundMe).balance;
        assertEq(OwnerBalanceBefore + ContractbalanceBefore, OwnerBalanceAfter);
        assertEq(0, ContractbalanceAfter);
    }

    function testCheaperWithdraw() public transaction {
        uint160 NumberofFunders = 10;
        uint160 StartingIndex = 1;
        for (uint160 index = StartingIndex; index < NumberofFunders; index++) {
            hoax(address(index), Starting_Balance);
            fundMe.Fund{value: paisa}();
        }

        uint256 OwnerBalanceBefore = fundMe.getOwner().balance;
        uint256 ContractbalanceBefore = address(fundMe).balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.CheaperWithdraw();
        vm.stopPrank();

        uint256 OwnerBalanceAfter = fundMe.getOwner().balance;
        uint256 ContractbalanceAfter = address(fundMe).balance;
        assertEq(OwnerBalanceBefore + ContractbalanceBefore, OwnerBalanceAfter);
        assertEq(0, ContractbalanceAfter);
    }

    function testWithdrawforMultipleTransaction() public transaction {
        uint160 NumberofFunders = 10;
        uint160 StartingIndex = 1;
        for (uint160 index = StartingIndex; index < NumberofFunders; index++) {
            hoax(address(index), Starting_Balance);
            fundMe.Fund{value: paisa}();
        }

        uint256 OwnerBalanceBefore = fundMe.getOwner().balance;
        uint256 ContractbalanceBefore = address(fundMe).balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        uint256 OwnerBalanceAfter = fundMe.getOwner().balance;
        uint256 ContractbalanceAfter = address(fundMe).balance;
        assertEq(OwnerBalanceBefore + ContractbalanceBefore, OwnerBalanceAfter);
        assertEq(0, ContractbalanceAfter);
    }

    function testPrintStorageData() public view {
        for (uint256 index = 0; index < 10; index++) {
            bytes32 value = vm.load(address(fundMe), bytes32(index));
            console.log("value at location", index, ":");
            console.logBytes32(value);
        }
    }
}
