// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;
import {PriceConverter} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

error NotDefined();                      // another way to make gas efficiency in revert statements

contract FundMe {
    using PriceConverter for uint256;
    AggregatorV3Interface chainAddress;
    uint256 public constant MIN_USD=50;      //constant is used if the value of variable will not change to make it gas efficient and use the naming convention of capital and underscore
    address[] public s_senderlist;
    mapping(address sender => uint256 paisa) private s_kitnaPaisaDiya;
    function Fund() public payable{
          require(msg.value.getprice(chainAddress)> MIN_USD,"Garib saale");
          s_senderlist.push(msg.sender);
          s_kitnaPaisaDiya[msg.sender]+= msg.value;
    }
    
    
    address private immutable i_owner;
    constructor(address chaintoDeploy){
        //to ensure that only the owner receives the money on calling withdraw

        i_owner= msg.sender;
        chainAddress = AggregatorV3Interface(chaintoDeploy);
    }
    function getdecimal() public view returns(uint256){
        //AggregatorV3Interface naya = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306) ;
        return chainAddress.decimals();
    }
    function CheaperWithdraw() public OnlyOwner{
        uint256 senderlength= s_senderlist.length;
       
        for(uint256 index=0; index<senderlength;index++){
            address sender= s_senderlist[index];
            s_kitnaPaisaDiya[sender]=0;
        }
    s_senderlist = new address[](0); 
    (bool CallSuccess, /*bytes dataReturned*/)= payable(msg.sender).call{value: address(this).balance }("");
    require(CallSuccess,"Call Failed");



    }
    function withdraw() public OnlyOwner{
        //require(msg.sender==owner,"Chor Saale");clear
        for(uint256 index=0; index<s_senderlist.length;index++){
            address sender= s_senderlist[index];
            s_kitnaPaisaDiya[sender]=0;
        }
    s_senderlist = new address[](0); //resetting an array to 0

    //there are three ways to withdraw tranfer,send,call
    //payable(msg.sender).transfer(address(this).balance);

    //bool SendSuccess= payable(msg.sender).send(address(this).balance);
    //require(SendSuccess,"Failed");

    (bool CallSuccess, /*bytes dataReturned*/)= payable(msg.sender).call{value: address(this).balance }("");
    require(CallSuccess,"Call Failed");


    }

    modifier OnlyOwner{                                                 // to stop writing this for every function and specify it in the function descriptio itself
        if(msg.sender != i_owner) {revert NotDefined();}               //to be more gas efficient than require which stores the revert string                 
        //require(msg.sender==i_owner,"Chor Saale");
        _;                                              // it means the function body will be executed only after verifying the owner
    }

    receive() external payable {                         //if someone pays without deploying the contract. to keep track of them. used only when some amount of ether is sent without any calldata
        Fund();
    }
    fallback() external payable{                        //when ether is sent alongwith calldata is sent and nothing is found it comes back to fallback
        Fund();
    }

    function getKitnaPaisaDiya(address sender) public view returns(uint256){
        return s_kitnaPaisaDiya[sender];
    }
    function getFunder(uint256 index) public view returns(address){
        return s_senderlist[index];
    }
    function getOwner() external view returns(address){
        return i_owner;
    }
   
}