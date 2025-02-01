//SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/interactions.s.sol";

contract IntegrationTest is Test {
    FundMe fundMe;
    DeployFundMe deployFundMe;
    uint256 constant SEND_VALUE = 1 ether;
    uint256 public constant STARTING_BALANCE = 10 ether;

    address user = makeAddr("user");

    function setUp() external {
        deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(user, STARTING_BALANCE);
    }

    function testFundandWithdraw() public {
        uint256 initialuserBalance = address(user).balance;
        uint256 initialOwnerBalance = address(fundMe.getOwner()).balance;

        vm.prank(user);
        fundMe.Fund{value: SEND_VALUE}();
        //FundFundMe fundFundMe = new FundFundMe();
        //fundFundMe.fundFundMe(address(fundMe));

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        uint256 finalOwnerBalance = address(fundMe.getOwner()).balance;
        uint256 finaluserBalance = address(user).balance;

        assertEq(address(fundMe).balance, 0);
        assertEq(finalOwnerBalance, initialOwnerBalance + SEND_VALUE);
        assertEq(finaluserBalance, initialuserBalance - SEND_VALUE);
    }
}
