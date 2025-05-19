// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import { PriceConverter } from "./PriceConverter.sol";
import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

error FundMe__NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    mapping (address funder => uint256 amountFunded) private s_addressToAmountFunded;
    address[] private s_funders;
    
    address private immutable i_owner;
    uint256 public constant MIN_USD = 5e18;
    AggregatorV3Interface private s_priceFeed;

    constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    function fund() public payable {
        require(msg.value.getConversionRate(s_priceFeed) > MIN_USD, "Didn't sent enough ETH");
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        for (uint256 i = 0; i < s_funders.length; i++) {
            address funder = s_funders[i];
            s_addressToAmountFunded[funder] = 0;
        }
        // reset the array
        s_funders = new address[](0);
        (bool callSuccess, ) = payable (msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Send Failed!");
    }

    function gasOptimizedWithdraw() public onlyOwner {
        uint256 fundersLength = s_funders.length;
         for (uint256 i = 0; i < fundersLength; i++) {
            address funder = s_funders[i];
            s_addressToAmountFunded[funder] = 0;
        }
        // reset the array
        s_funders = new address[](0);
        (bool callSuccess, ) = payable (msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Send Failed!");
    }


    modifier onlyOwner() {
        if (msg.sender != i_owner) { revert FundMe__NotOwner(); }
        _;
    }

    receive() external payable { fund(); }

    fallback() external payable { fund(); }

     /**
     * Getter Functions
     */

    /**
     * @notice Gets the amount that an address has funded
     *  @param fundingAddress the address of the funder
     *  @return the amount funded
     */
    function getAddressToAmountFunded(address fundingAddress) public view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    function getFunder(uint256 index) public view returns (address) {
        return s_funders[index];
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }
    
}