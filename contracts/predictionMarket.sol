pragma solidity ^0.4.23;
import "./safeMath.sol";

contract predictionMarket {
    string theQuestion;
    mapping (address => Vote) Voters;
    Pool_Var pool;

    struct Vote {
        bool Vote_Status; //0 or 1 based on what they vote
        uint256 Amount; //amount of bet
    }

    struct Pool_Var {
        uint256 sumYes; //sum of all "yes" vote values
        uint256 sumNo; //sum of all "no" vote values
        uint256 sum_submit_yes; //num voters who voted yes;
        uint256 sum_submit_no; //num voters who voted no;
    }


  constructor(string  _theQuestion) {
    theQuestion = _theQuestion;
   
  }

  //allows a voter to vote either "yes":1 or "no":0 and pay a share. Also adds share to the pool.
  function vote(bool yesOrNo) public payable{
      address submitter = msg.sender;
      Voters[submitter].Vote_Status = yesOrNo; //sets vote_status
      Voters[submitter].Amount = msg.value; //sets vote amount
      if (yesOrNo){
        pool.sumYes += msg.value;
        pool.sum_submit_yes += 1;
      }
      else {
        pool.sumNo += msg.value;
        pool.sum_submit_no += 1;
      }
  }

  //returns _theQuestion driving the prediction market
  function readQuestion() constant public returns(string) {
    return theQuestion;
  }

  //returns a tuple of what a voter's vote and amount paid
  function check() constant public returns (bool, uint256) {
      address submitter = msg.sender;
      return (Voters[submitter].Vote_Status, Voters[submitter].Amount);
  }

  //returns the winner of the pool, either "yes":1, "no":0
  //TODO: this must eventually be time bound
  function getWinner() returns (bool) {
    if (pool.sumYes > pool.sumNo) {
        return true;
    } else {
        return false;
    }
  }

  //returns the amount a voter wins after the pool is decided
  //TODO: this must eventually be time bound
  function calculateWinnings(address addy) returns (uint256) {
      address submitter = addy;
      bool submitter_vote = Voters[submitter].Vote_Status;
      uint256 submitter_val = Voters[submitter].Amount;
      uint256 sum_winnings = 0;
      bool winner_vote = getWinner();


      if (submitter_vote == winner_vote) {
            //first add the submitter's initial contribution
            sum_winnings += submitter_val;

            if (winner_vote == true) {
                //time to split up the no pool
                sum_winnings += pool.sumNo/pool.sum_submit_yes;
            } else {
                //time to split up the yes pool
                sum_winnings += pool.sumYes/pool.sum_submit_no;
            }
        }
    return sum_winnings;
  }


  //withdraw amount from smart contract
  function withdraw(uint256 amount) {
    msg.sender.transfer(amount);
  }

  //submitter calls this function to claim their winnings after the prediction market is over
  function claimWinnings() {
    address submitter = msg.sender;
    withdraw(calculateWinnings(submitter));

  }

    //submitter calls this function to claim their winnings after the prediction market is over
    function getWinnings() returns (uint256) {
        address submitter = msg.sender;
        return calculateWinnings(submitter);
    }

  function() public payable {
    revert();

  }

}
