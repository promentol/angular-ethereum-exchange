pragma solidity ^0.4.8;

import "./owned.sol";
import "./FixedSupplyToken.sol";

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
}