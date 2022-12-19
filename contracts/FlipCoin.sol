// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@chainlink/contracts/src/v0.8/VRFV2WrapperConsumerBase.sol";

contract FlipCoin is VRFV2WrapperConsumerBase{
    
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    enum BetOptions{ HEADS , TAILS }
    IERC20  public invoToken;
    address public flipCoinOwner;
    uint256 public FeeRequireToPlay = 10;
    address constant chainlinkaddress   = 0x326C977E6efc84E512bB9C30f76E30c160eD06FB ;
    address constant vrfWraypperAddress = 0x99aFAf084eBA697E584501b8Ed2c0B37Dd136693;
    uint32  constant callBackGasLimit = 1_000_000;
    uint16  constant requestConfirmations = 6;
    uint32  constant numWords = 1;
    


    event FlipCoinRequest(uint256 requestId);
    event FlipCoinResult(uint256 requestId , bool isWin);


    constructor(address _invoToken) VRFV2WrapperConsumerBase(chainlinkaddress,vrfWraypperAddress)
    {
        flipCoinOwner = msg.sender;
        invoToken = IERC20(_invoToken); 
    }

    function checkContractBalance() private view  returns (uint256 _balance) {
        return address(this).balance;
    }

    struct ETHPool
    {
        bool isAdded;
        uint256 AddedAt;
        uint256 ETHBalance;
    }

    struct flipCoinDetails
    {
        uint256 BettingFee;
        uint256 randomWords;
        address player;
        bool isWin;
        bool fullFilled;
        BetOptions input;
    }
    
    mapping(address=>ETHPool) private EthereumPool;
    mapping(uint256 => flipCoinDetails) public bettingDetails;


    function changeBettingFee(uint256 _FeeRequireToPlay) public returns(string memory _response)
    {
        require(msg.sender == flipCoinOwner , "You are not auhteroized to change the Betting fee");
        FeeRequireToPlay = _FeeRequireToPlay;
        return "Fee changed scucessfully";
    }

    function AddInvoTokensToTheContrct(uint256 _tokenAmount) public returns(bool)
    {
        require(msg.sender == flipCoinOwner , "You ae not autheroized to send the ETH to contract");
        require(_tokenAmount > 0, "0 value can't be added");

        EthereumPool[msg.sender] = 
        ETHPool({
            isAdded: true,
            ETHBalance: _tokenAmount,
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

    function getStatus(uint256 requestId) private view returns(flipCoinDetails memory)
    {
        return bettingDetails[requestId];
    }

    function withdrawAllFunds() public 
    {
        require(msg.sender == flipCoinOwner , "You are not the admin");

        if(address(this).balance <= 1 ether )
        {
            revert("Currently can not withdraw balance because contract balance is 1 Ether or Matic or BNB");
        }else
        {
            payable(flipCoinOwner).transfer(address(this).balance - 1 ether);

        }


    }
}