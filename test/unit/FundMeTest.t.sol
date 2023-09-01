//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant SEND_ETH = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() external {
        //fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumusd() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testowner() public {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersion() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testamountofETH() public {
        vm.expectRevert(); // i expect the next line to revert when i use vm.expectrevert();
        fundMe.fund();
    }

    function testcorrectamountofETH() public {
        vm.prank(USER); // the next transaction shall be send by user...
        fundMe.fund{value: SEND_ETH}();
        uint256 amountfunded = fundMe.getamountfunded(USER);
        assertEq(amountfunded, SEND_ETH);
    }

    function testarrayofFunders() public funded {
        address myaddress = fundMe.getfunder(0);
        assertEq(myaddress, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_ETH}();
        _;
    }

    function testwithdrawonlyOwner() public funded {
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    function testwithdraw() public funded {
        //Arrange
        uint256 startingbalance = fundMe.getOwner().balance;
        uint256 startingFUND = address(fundMe).balance;

        //Action
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        //Assert

        uint256 endingowner = fundMe.getOwner().balance;
        uint256 endingFUND = address(fundMe).balance;

        assertEq(endingFUND, 0);
        assertEq(startingbalance + startingFUND, endingowner);
    }

    function testmultipleWithdraw() public funded {
        // Arrange
        uint160 numberofFunders = 10;
        uint160 startindex = 1;

        for (uint160 i = startindex; i < numberofFunders; i++) {
            hoax(address(i), STARTING_BALANCE);
            fundMe.fund{value: SEND_ETH}();
        }

        uint256 startingbalance = fundMe.getOwner().balance;
        uint256 startingFUND = address(fundMe).balance;

        // Action
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // Assert
        assert(address(fundMe).balance == 0);
        assert(startingbalance + startingFUND == fundMe.getOwner().balance);
    }
}
