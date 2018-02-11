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
        string symbolName;

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

    mapping(uint8 => Token) tokens;
    uint8 tokensLength;

    //Balances
    mapping (address => mapping (uint8 => uint)) tokenBalanceForAddress;

    mapping (address => uint) balanceEthForAddress;

    //Token Management

    function addToken(string symbolName, address erc20tokenAddress) public onlyOwner {
        //check if a token with that symbol has been already added
        require(!hasToken(symbolName));
        tokensLength++;
        tokens[tokensLength].symbolName = symbolName;
        tokens[tokensLength].tokenContract = erc20tokenAddress;
    }

    function hasToken(string symbolName) public view returns (bool) {
        if (getSymbolIndex(symbolName) == 0) {
            return false;
        }
        return true;
    }

    function getSymbolIndex(string symbolName) internal view returns (uint8) {
        for (uint8 i = 1; i <= tokensLength; ++i) {
            if (stringsEqual(tokens[i].symbolName, symbolName)) {
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
    }

    function withdrawEther(uint amountInWei) public {
        require(balanceEthForAddress[msg.sender] - amountInWei >= 0);
        require(balanceEthForAddress[msg.sender] - amountInWei < balanceEthForAddress[msg.sender]);
        balanceEthForAddress[msg.sender] -= amountInWei;
        msg.sender.transfer(amountInWei);
    }

    function getEthBalanceInWei() view public returns (uint) {
        return balanceEthForAddress[msg.sender];
    }


    // Tokens

    function depositToken(string symbolName, uint amount) public {
        uint8 tokenNumber = getSymbolIndex(symbolName);
        require(tokenNumber > 0);

        ERC20Interface token = ERC20Interface(tokens[tokenNumber].tokenContract);

        require(token.transferFrom(msg.sender, address(this), amount) == true);
        
        require(tokenBalanceForAddress[msg.sender][tokenNumber] + amount > tokenBalanceForAddress[msg.sender][tokenNumber]);
        tokenBalanceForAddress[msg.sender][tokenNumber] += amount;
    }

    function withdrawToken(string symbolName, uint amount) public {
        uint8 tokenNumber = getSymbolIndex(symbolName);
        require(tokenNumber > 0);

        require(tokenBalanceForAddress[msg.sender][tokenNumber] - amount >= 0);
        require(tokenBalanceForAddress[msg.sender][tokenNumber] - amount < tokenBalanceForAddress[msg.sender][tokenNumber]);

        ERC20Interface token = ERC20Interface(tokens[tokenNumber].tokenContract);
        
        tokenBalanceForAddress[msg.sender][tokenNumber] -= amount;
        require(token.transfer(msg.sender, amount) == true);

    }

    function getBalance(string symbolName) view public returns (uint) {
        uint8 tokenNumber = getSymbolIndex(symbolName);
        require(tokenNumber > 0);
        return tokenBalanceForAddress[msg.sender][tokenNumber];
    }
}