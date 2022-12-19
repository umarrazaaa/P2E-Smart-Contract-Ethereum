// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@chainlink/contracts/src/v0.8/VRFV2WrapperConsumerBase.sol";

contract InvoFlip is VRFV2WrapperConsumerBase{
    
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    enum BetOptions{ HEADS , TAILS }

    IERC20 public invoToken;

    address public flipCoinOwner;
    address constant chainlinkaddress   = 0x326C977E6efc84E512bB9C30f76E30c160eD06FB ;
    address constant vrfWraypperAddress = 0x708701a1DfF4f478de54383E49a627eD4852C816;

    uint32 constant numWords = 1;
    uint256 public  FeeRequireToPlay = 2*10**18;
    uint16 constant requestConfirmations = 6;
    uint32 constant callBackGasLimit = 1_000_000;


    event FlipCoinRequest(uint256 requestId);
    event FlipCoinResult(uint256 requestId , bool isWin);


    constructor(address _invoToken) VRFV2WrapperConsumerBase(chainlinkaddress,vrfWraypperAddress)
    {
        flipCoinOwner = msg.sender;
        invoToken = IERC20(_invoToken); 
    }
    struct InvoTokensPool
    {
        bool isAdded;
        uint256 AddedAt;
        uint256 ETHBalance;
    }

    struct flipCoinDetails
    {
        uint256 BettingFee;
        uint256 randomWords;
        uint256 tokenAmount;
        address player;
        bool isWin;
        bool fullFilled;
        BetOptions input;
    }

    mapping(address => InvoTokensPool) private EthereumPool;
    mapping(uint256 => flipCoinDetails) public bettingDetails;

    // Admin Functions

    function changeBettingFee(uint256 _FeeRequireToPlay) public returns(string memory _response)
    {
        require(msg.sender == flipCoinOwner , "You are not auhteroized to change the Betting fee");
        FeeRequireToPlay = _FeeRequireToPlay;
        return "Fee changed scucessfully";
    }
    
    function checkContractBalance() private view  returns (uint256 _balance) {
        return address(this).balance;
    }

    function CurrentBalanceOfContract() public view returns(uint256 _currentTokens)
    {
        return invoToken.balanceOf(address(this));
    }

    function AddInvoTokensToTheContrct(uint256 _tokenAmount) public returns(bool)
    {
        require(msg.sender == flipCoinOwner , "You ae not autheroized to send the ETH to contract");
        require(_tokenAmount > 0, "0 value can't be added");

        EthereumPool[msg.sender] = 
        InvoTokensPool({
            isAdded: true,
            ETHBalance: _tokenAmount,
            AddedAt: block.timestamp
        });

        return true;
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
                payable(bettingDetails[requestId].player).transfer(FeeRequireToPlay.mul(2));
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



        if(invoToken.balanceOf(address(this)) <= 100 )
        {
            revert("Currently can not withdraw balance because contract balance is 100 InvoTokens");
        }else
        {
            payable(flipCoinOwner).transfer(invoToken.balanceOf(address(this)) - 100);

        }

    }

    // User Functions

    function flipTheCoin(BetOptions _selection , uint256 _feeRequiredToPlay) external  returns(uint256)
    {
        require(_feeRequiredToPlay == FeeRequireToPlay , "Kindly pay the exact fee for betting");
        
        uint256 requestId = requestRandomness(callBackGasLimit,requestConfirmations,numWords);

        bettingDetails[requestId] = flipCoinDetails({
            BettingFee: VRF_V2_WRAPPER.calculateRequestPrice(callBackGasLimit),
            randomWords:0,
            tokenAmount:_feeRequiredToPlay,
            player:msg.sender,
            isWin:false,
            fullFilled:false,
            input: _selection
        });
        emit FlipCoinRequest(requestId);
        return requestId;
    }
}