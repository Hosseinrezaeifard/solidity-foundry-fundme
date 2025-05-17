// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import { PriceConverter } from "./PriceConverter.sol";
import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

error FundMe__NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    uint256 public constant MIN_USD = 5e18;

    address[] public funders;

    mapping (address funder => uint256 amountFunded) public addressToAmountFunded;
    
    address public immutable i_owner;

    constructor() {
        i_owner = msg.sender;
    }

    function fund() public payable {
        require(msg.value.getConversionRate() > MIN_USD, "Didn't sent enough ETH");
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        for (uint256 i = 0; i < funders.length; i++) {
            address funder = funders[i];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
        (bool callSuccess, ) = payable (msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Send Failed!");
        revert();
    }

    function getVersion() public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        return priceFeed.version();
    }

    modifier onlyOwner() {
        if (msg.sender != i_owner) { revert FundMe__NotOwner(); }
        _;
    }

    receive() external payable { fund(); }

    fallback() external payable { fund(); }
    
}