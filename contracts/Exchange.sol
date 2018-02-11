pragma solidity ^0.4.8;

import "./owned.sol";
import "./FixedSupplyToken.sol";
import "./ERC20Interface.sol";

contract Exchange is owned {
    //Structures used

    struct Offer {
        uint amount;
        address who;
    }

    struct OrderBook {
        uint higherPrice;
        uint lowerPrice;

        mapping(uint8 => Offer) offers;
        uint8 offersLength;
    }

    struct Token {
        address tokenContract;
        string tokenName;

        mapping(uint8 => Offer) buyBook;
        uint8 buyBookLength;

        uint currentBuyPrice;
        uint lowestBuyPrice;
        uint amountBuyPrices;

        mapping(uint8 => Offer) sellBook;
        uint8 sellBookLength;

        uint currentSellPrice;
        uint highestSellPrice;
        uint amountSellPrice;
    }

    //Events

    event TokenAddedToSystem(uint tokenNumber, string _token, uint _timestamp);

    event DepositForTokenReceived(address indexed _from, uint indexed _tokenNumber, uint _amount, uint _timestamp);
    event WithdrawalToken(address indexed _to, uint indexed _tokenNumber, uint _amount, uint _timestamp);
    event DepositForEthReceived(address indexed _from, uint _amount, uint _timestamp);
    event WithdrawalEth(address indexed _to, uint _amount, uint _timestamp);

    mapping(uint8 => Token) tokens;
    uint8 tokensLength;

    //Balances
    mapping (address => mapping (uint8 => uint)) tokenBalanceForAddress;

    mapping (address => uint) balanceEthForAddress;

    //Token Management

    function addToken(string tokenName, address erc20tokenAddress) public onlyOwner {
        //check if a token with that symbol has been already added
        require(!hasToken(tokenName));
        tokensLength++;
        tokens[tokensLength].tokenName = tokenName;
        tokens[tokensLength].tokenContract = erc20tokenAddress;

        TokenAddedToSystem(tokensLength, tokenName, block.timestamp);
    }

    function hasToken(string tokenName) public view returns (bool) {
        if (getSymbolIndex(tokenName) == 0) {
            return false;
        }
        return true;
    }

    function getSymbolIndex(string tokenName) internal view returns (uint8) {
        for (uint8 i = 1; i <= tokensLength; ++i) {
            if (stringsEqual(tokens[i].tokenName, tokenName)) {
                return i;
            }
        }
        return 0;
    }

    function stringsEqual(string a, string b) internal pure returns (bool) {
        return keccak256(a) == keccak256(b);
    }


    // deposits/withdraw ether

    function depositEther() public payable {
        require(balanceEthForAddress[msg.sender] + msg.value >= balanceEthForAddress[msg.sender]);
        balanceEthForAddress[msg.sender] += msg.value;
        DepositForEthReceived(msg.sender, uint(msg.value), block.timestamp);
    }

    function withdrawEther(uint amountInWei) public {
        require(balanceEthForAddress[msg.sender] - amountInWei >= 0);
        require(balanceEthForAddress[msg.sender] - amountInWei < balanceEthForAddress[msg.sender]);
        balanceEthForAddress[msg.sender] -= amountInWei;
        msg.sender.transfer(amountInWei);
        WithdrawalEth(msg.sender, amountInWei, block.timestamp);
    }

    function getEthBalanceInWei() view public returns (uint) {
        return balanceEthForAddress[msg.sender];
    }


    // Tokens

    function depositToken(string tokenName, uint amount) public {
        uint8 tokenNumber = getSymbolIndex(tokenName);
        require(tokenNumber > 0);

        ERC20Interface token = ERC20Interface(tokens[tokenNumber].tokenContract);

        require(token.transferFrom(msg.sender, address(this), amount) == true);
        
        require(tokenBalanceForAddress[msg.sender][tokenNumber] + amount > tokenBalanceForAddress[msg.sender][tokenNumber]);
        tokenBalanceForAddress[msg.sender][tokenNumber] += amount;

        DepositForTokenReceived(msg.sender, tokenNumber, amount, block.timestamp);
    }

    function withdrawToken(string tokenName, uint amount) public {
        uint8 tokenNumber = getSymbolIndex(tokenName);
        require(tokenNumber > 0);

        require(tokenBalanceForAddress[msg.sender][tokenNumber] - amount >= 0);
        require(tokenBalanceForAddress[msg.sender][tokenNumber] - amount < tokenBalanceForAddress[msg.sender][tokenNumber]);

        ERC20Interface token = ERC20Interface(tokens[tokenNumber].tokenContract);
        
        tokenBalanceForAddress[msg.sender][tokenNumber] -= amount;
        require(token.transfer(msg.sender, amount) == true);

        WithdrawalToken(msg.sender, tokenNumber, amount, block.timestamp);

    }

    function getBalance(string tokenName) view public returns (uint) {
        uint8 tokenNumber = getSymbolIndex(tokenName);
        require(tokenNumber > 0);
        return tokenBalanceForAddress[msg.sender][tokenNumber];
    }
}