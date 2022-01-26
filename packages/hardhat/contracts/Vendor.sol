pragma solidity 0.8.4;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {

  event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);

  event SellTokens(address seller, uint256 amountOfETH, uint256 amountOfTokens);

  YourToken public yourToken;

  uint256 public constant tokensPerEth = 100;

  constructor(address tokenAddress) {
    yourToken = YourToken(tokenAddress);
  }

  // ToDo: create a payable buyTokens() function:
  function buyTokens() external payable {
    uint256 amountOfTokens = msg.value * tokensPerEth;
    yourToken.transfer(msg.sender, amountOfTokens);

    emit BuyTokens(msg.sender, msg.value, amountOfTokens);
  }

  // ToDo: create a withdraw() function that lets the owner withdraw ETH
  function withdraw() external onlyOwner {
    (bool sent, ) = msg.sender.call{value: address(this).balance}("");
    require(sent, "withdraw failure");
  }

  // ToDo: create a sellTokens() function:
  function sellTokens(uint256 amount) external {
    uint256 allowance = yourToken.allowance(msg.sender, address(this));
    require(allowance >= amount, "not enough allowance");

    bool tokenSuccess = yourToken.transferFrom(msg.sender, address(this), amount);
    require(tokenSuccess, "token transfer failed");

    uint256 backEth = amount / tokensPerEth;
    (bool ethSuccess, ) = msg.sender.call{value: backEth}("");
    require(ethSuccess, "transfer eth back failed");

    emit SellTokens(msg.sender, backEth, amount);
  }
}
