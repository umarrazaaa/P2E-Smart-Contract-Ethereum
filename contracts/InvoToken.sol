// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@chainlink/contracts/src/v0.8/VRFV2WrapperConsumerBase.sol";

contract FlipCoin is VRFV2WrapperConsumerBase{
    
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    event FlipCoinRequest(uint256 requestId);
    event FlipCoinResult(uint256 requestId , bool isWin);


    constructor()   VRFV2WrapperConsumerBase(chainlinkaddress,vrfWraypperAddress)
    {
        flipCoinOwner = 0xB414c6a6dF9D16372D732161551CAA837ce26039;
    }

    uint256 private contractbalance;

    function checkContractBalance() private view  returns (uint256 _balance) {
        return address(this).balance;
    }

    address public flipCoinOwner;
    uint256 public FeeRequireToPlay = 0.1 ether;
    enum BetOptions{ HEADS , TAILS }

    address constant chainlinkaddress   = 0x326C977E6efc84E512bB9C30f76E30c160eD06FB ;
    address constant vrfWraypperAddress = 0x99aFAf084eBA697E584501b8Ed2c0B37Dd136693;

    uint32 constant callBackGasLimit     = 1_000_000;
    uint32 constant numWords = 1;
    uint16 constant requestConfirmations = 6;

    struct ETHPool
    {
        bool isAdded;
        uint256 ETHBalance;
        uint256 AddedAt;
    }
    mapping(address=>ETHPool) private EthereumPool;

    struct flipCoinDetails
    {
        uint256 BettingFee;
        uint256 randomWords;
        address player;
        bool isWin;
        bool fullFilled;
        BetOptions input;
    }

    mapping(uint256 => flipCoinDetails) public bettingDetails;


    function changeBettingFee(uint256 _FeeRequireToPlay) public returns(string memory _response)
    {
        require(msg.sender==flipCoinOwner , "You are not auhteroized to change the Betting fee");
        FeeRequireToPlay = _FeeRequireToPlay;
        return "Fee changed scucessfully";
    }

    function AddBalanceToTheContract() public payable returns(bool)
    {
        require(msg.sender == flipCoinOwner , "You ae not autheroized to send the ETH to contract");
        require(msg.value>0, "0 value can't be added");

        EthereumPool[msg.sender] = ETHPool({
            isAdded: true,
            ETHBalance: msg.value,
            AddedAt: block.timestamp
        });

        return true;
    }


    function flipTheCoin(BetOptions selection) external payable returns(uint256)
    {
        require(msg.value == FeeRequireToPlay , "Kindly pay the exact fee for betting");
        
        uint256 requestId = requestRandomness(callBackGasLimit,requestConfirmations,numWords);

        bettingDetails[requestId] = flipCoinDetails({
            BettingFee: VRF_V2_WRAPPER.calculateRequestPrice(callBackGasLimit),
            randomWords:0,
            player:msg.sender,
            isWin:false,
            fullFilled:false,
            input: selection
        });
        emit FlipCoinRequest(requestId);
        return requestId;
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomwords) internal override
    {
        require(bettingDetails[requestId].BettingFee > 0 , "Request Not Found");

        bettingDetails[requestId].fullFilled = true;
        bettingDetails[requestId].randomWords = randomwords[0];

        BetOptions result = BetOptions.HEADS;

            if(randomwords[0]%2==0)
            {
                result = BetOptions.TAILS;
            }

            if(bettingDetails[requestId].input==result)
            {
                bettingDetails[requestId].isWin=true;
                payable(bettingDetails[requestId].player).transfer(FeeRequireToPlay * 2);
            }
            emit FlipCoinResult(requestId,bettingDetails[requestId].isWin);
    }

    function getStatus(uint256 requestId) public view returns(flipCoinDetails memory)
    {
        return bettingDetails[requestId];
    }

    function withdrawAllFunds() public 
    {
        require(msg.sender == flipCoinOwner , "You are not the admin");
        payable(flipCoinOwner).transfer(address(this).balance);

    }
}