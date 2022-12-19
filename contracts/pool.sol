// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.9;

// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
// import "@openzeppelin/contracts/utils/math/SafeMath.sol";
// import "@openzeppelin/contracts/utils/Counters.sol";

// contract StakingNFT
// {
//       using SafeMath for uint256;


//     IERC20   public rewardsToken;
//     IERC721 public NFtToken;

//     address public owner;
//     uint256 public _totalsupplies;
//     uint256 public amount;
//     uint256 public AllUserStakes;
//     uint256 public AllStakedNfts;
//     uint256 public AllRewardTokens;

//     uint256 public minStakeNFT  = 1;
//     uint256[3] public durations = [1 minutes , 2 minutes , 3 minutes];

//     mapping(address=>uint256) public rewards;
//     mapping(address=>uint256) public _balances;

//     constructor(address _rewardsToken , address _nft)
//     {
//         rewardsToken = IERC20(_rewardsToken);
//         NFtToken = IERC721(_nft);

//         owner = msg.sender;
//     }

//     struct NftStakeInfo
//     {     
//         bool isStaked;
//         bool withdrawn;
//         bool rewardGet;

//         uint256 nftId;
//         uint256 plan;
//         uint256 bonus;
//         uint256 stakeTime;
//         uint256 withdrawTime;
//         uint256 nftamount;
//         address nftStaker;        
//     }

//    NftStakeInfo[] public nftstakeinfo;
   
//    struct Staker
//    {
//        uint256 totalStakedNFTs;
//        uint256 remainingStakedNFTs;
//        uint256 stakeCount;
//        uint256 totalRewardTokens;
//        mapping(uint256 => NftStakeInfo) StakeRecord; 
//    }

//    mapping(address => Staker) public stakersInfo;
  


//     function stakeNFT(uint256 _tokenId , uint256 _amountofNftToStake ,  uint256 _plan) public
//     {   
//         uint256 amountnft = NFtToken.ownerOf(_tokenId);
//         require(amountnft=1, "Only owner can stake");
//         require(_amountofNftToStake > minStakeNFT , "Can not Stake , stake atleast 2 copies");
//         require(_plan >=0 && _plan < 2 , "Put Valid Plan details for staking");
//         require(owner != address(0), "Owner address can not be zero address");
//         require(msg.sender != address(0), "User Address can not be null");
//         require(_tokenId > 0 , "Token should be greater than zero");

//         Staker storage user = stakersInfo[msg.sender];

//         amount = stakersInfo[msg.sender].StakeRecord[user.stakeCount].nftamount;

//         AllUserStakes++;
//         NFtToken.safeTransferFrom(msg.sender,address(this),_tokenId, amount ,'0x00');

//         user.StakeRecord[user.stakeCount].plan = _plan;
//         user.StakeRecord[user.stakeCount].stakeTime = block.timestamp;
//         user.StakeRecord[user.stakeCount].withdrawTime = block.timestamp.add(durations[_plan]);
//         user.StakeRecord[user.stakeCount].bonus = rewardDistribution(_plan);

//         _totalsupplies = _totalsupplies.add(amount);
//         _balances[msg.sender] = _balances[msg.sender].add(amount);

//     }   

//     function withdraw(uint256 _count , uint256 _tokenId) public
//     {
//         Staker storage user = stakersInfo[msg.sender];
        
//         require(user.stakeCount >= _count , "Invalid Stake index");
//         require(!user.StakeRecord[_count].withdrawn," withdraw completed ");
//         require(msg.sender != address(0), "User address canot be zero.");
//         require(owner != address(0), "Owner address canot be zero.");

//         if(block.timestamp >= user.StakeRecord[_count].withdrawTime)
//         {
//             NFtToken.safeTransferFrom(address(this), msg.sender, _tokenId, amount, "0x00");
//             rewardsToken.transferFrom(address(this), msg.sender , user.StakeRecord[_count].bonus);
//         }
//         else
//         {
//             NFtToken.safeTransferFrom(address(this), msg.sender, _tokenId, amount, "0x00");

//         }
        
        
//     }

//     function rewardDistribution(uint256 plan)public view returns(uint256 _rewardAmount)
//     {
//         // Staker storage user = stakersInfo[msg.sender];
        
//         if(plan == 0)
//         {
//             return  calculateRewards(amount,375);
//         }
//         else if( plan == 1)
//         {
//             return  calculateRewards(amount, 575);
//         }       
//         else if(plan == 2)
//         {
//             return  calculateRewards(amount, 875);
//         }  


//     }

//     function calculateRewards(uint256 _copiesofNFT , uint256 _percentage) public pure returns(uint256)
//     {
//         return _copiesofNFT*_percentage/10000;
//     }
// }