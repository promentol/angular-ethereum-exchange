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

        mapping(uint => Offer) offers;
        uint offersKey;
        uint offersLength;
    }

    struct Token {
        address tokenContract;
        string tokenName;

        mapping(uint => OrderBook) buyBook;

        uint currentBuyPrice;
        uint lowestBuyPrice;
        uint amountBuyPrices;

        mapping(uint => OrderBook) sellBook;

        uint currentSellPrice;
        uint highestSellPrice;
        uint amountSellPrices;
    }

    //Events

    event TokenAddedToSystem(uint tokenNumber, string _token, uint _timestamp);

    event DepositForTokenReceived(address indexed _from, uint indexed _tokenNumber, uint _amount, uint _timestamp);
    event WithdrawalToken(address indexed _to, uint indexed _tokenNumber, uint _amount, uint _timestamp);
    event DepositForEthReceived(address indexed _from, uint _amount, uint _timestamp);
    event WithdrawalEth(address indexed _to, uint _amount, uint _timestamp);

    event LimitSellOrderCreated(uint indexed _tokenNumber, address indexed _who, uint _amountTokens, uint _priceInWei, uint _orderKey);
    event SellOrderFulfilled(uint indexed _tokenNumber, uint _amount, uint _priceInWei, uint _orderKey);
    event SellOrderCanceled(uint indexed _tokenNumber, uint _priceInWei, uint _orderKey);
    event LimitBuyOrderCreated(uint indexed _tokenNumber, address indexed _who, uint _amountTokens, uint _priceInWei, uint _orderKey);
    event BuyOrderFulfilled(uint indexed _tokenNumber, uint _amount, uint _priceInWei, uint _orderKey);
    event BuyOrderCanceled(uint indexed _tokenNumber, uint _priceInWei, uint _orderKey);

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

    function getSymbolIndexOrThrow(string tokenName) internal view returns (uint8) {
        uint8 tokenNumber = getSymbolIndex(tokenName);
        require(tokenNumber>0);
        return tokenNumber;
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

    /* 
    THIS WAS COPYPASTED FROM THE TUTORIAL
    */
    
    function getBuyOrderBook(string symbolName) public constant returns (uint[], uint[]) {
        uint8 tokenNameIndex = getSymbolIndexOrThrow(symbolName);
        uint[] memory arrPricesBuy = new uint[](tokens[tokenNameIndex].amountBuyPrices);
        uint[] memory arrVolumesBuy = new uint[](tokens[tokenNameIndex].amountBuyPrices);

        uint whilePrice = tokens[tokenNameIndex].lowestBuyPrice;
        uint counter = 0;
        if (tokens[tokenNameIndex].currentBuyPrice > 0) {
            while (whilePrice <= tokens[tokenNameIndex].currentBuyPrice) {
                arrPricesBuy[counter] = whilePrice;
                uint volumeAtPrice = 0;
                uint offersKey = 0;

                offersKey = tokens[tokenNameIndex].buyBook[whilePrice].offersKey;
                while (offersKey <= tokens[tokenNameIndex].buyBook[whilePrice].offersLength) {
                    volumeAtPrice += tokens[tokenNameIndex].buyBook[whilePrice].offers[offersKey].amount;
                    offersKey++;
                }

                arrVolumesBuy[counter] = volumeAtPrice;

                //next whilePrice
                if (whilePrice == tokens[tokenNameIndex].buyBook[whilePrice].higherPrice) {
                    break;
                } else {
                    whilePrice = tokens[tokenNameIndex].buyBook[whilePrice].higherPrice;
                }
                counter++;

            }
        }

        return (arrPricesBuy, arrVolumesBuy);

    }

    function getSellOrderBook(string symbolName) public constant returns (uint[], uint[]) {
        uint8 tokenNameIndex = getSymbolIndexOrThrow(symbolName);
        uint[] memory arrPricesSell = new uint[](tokens[tokenNameIndex].amountSellPrices);
        uint[] memory arrVolumesSell = new uint[](tokens[tokenNameIndex].amountSellPrices);
        uint sellWhilePrice = tokens[tokenNameIndex].currentSellPrice;
        uint sellCounter = 0;
        if (tokens[tokenNameIndex].currentSellPrice > 0) {
            while (sellWhilePrice <= tokens[tokenNameIndex].highestSellPrice) {
                arrPricesSell[sellCounter] = sellWhilePrice;
                uint sellVolumeAtPrice = 0;
                uint sell_offersKey = 0;

                sell_offersKey = tokens[tokenNameIndex].sellBook[sellWhilePrice].offersKey;
                while (sell_offersKey <= tokens[tokenNameIndex].sellBook[sellWhilePrice].offersLength) {
                    sellVolumeAtPrice += tokens[tokenNameIndex].sellBook[sellWhilePrice].offers[sell_offersKey].amount;
                    sell_offersKey++;
                }

                arrVolumesSell[sellCounter] = sellVolumeAtPrice;

                //next whilePrice
                if (tokens[tokenNameIndex].sellBook[sellWhilePrice].higherPrice == 0) {
                    break;
                } else {
                    sellWhilePrice = tokens[tokenNameIndex].sellBook[sellWhilePrice].higherPrice;
                }
                sellCounter++;

            }
        }

        //sell part
        return (arrPricesSell, arrVolumesSell);
    }

    function buyToken(string symbolName, uint priceInWei, uint amount) public {
        uint8 tokenNameIndex = getSymbolIndexOrThrow(symbolName);
        uint total_amount_ether_necessary = 0;

        if (tokens[tokenNameIndex].amountSellPrices == 0 || tokens[tokenNameIndex].currentSellPrice > priceInWei) {
            //if we have enough ether, we can buy that:
            total_amount_ether_necessary = amount * priceInWei;

            //overflow check
            require(total_amount_ether_necessary >= amount);
            require(total_amount_ether_necessary >= priceInWei);
            require(balanceEthForAddress[msg.sender] >= total_amount_ether_necessary);
            require(balanceEthForAddress[msg.sender] - total_amount_ether_necessary >= 0);
            require(balanceEthForAddress[msg.sender] - total_amount_ether_necessary <= balanceEthForAddress[msg.sender]);

            //first deduct the amount of ether from our balance
            balanceEthForAddress[msg.sender] -= total_amount_ether_necessary;

            //limit order: we don't have enough offers to fulfill the amount

            //add the order to the orderBook
            addBuyOffer(tokenNameIndex, priceInWei, amount, msg.sender);
            //and emit the event.
            LimitBuyOrderCreated(tokenNameIndex, msg.sender, amount, priceInWei, tokens[tokenNameIndex].buyBook[priceInWei].offersLength);
        } else {
            //market order: current sell price is smaller or equal to buy price!

            //1st: find the "cheapest sell price" that is lower than the buy amount  [buy: 60@5000] [sell: 50@4500] [sell: 5@5000]
            //2: buy up the volume for 4500
            //3: buy up the volume for 5000
            //if still something remaining -> buyToken

            //2: buy up the volume
            //2.1 add ether to seller, add symbolName to buyer until offersKey <= offersLength

            uint total_amount_ether_available = 0;
            uint whilePrice = tokens[tokenNameIndex].currentSellPrice;
            uint amountNecessary = amount;
            uint offersKey;
            while (whilePrice <= priceInWei && amountNecessary > 0) {//we start with the smallest sell price.
                offersKey = tokens[tokenNameIndex].sellBook[whilePrice].offersKey;
                while (offersKey <= tokens[tokenNameIndex].sellBook[whilePrice].offersLength && amountNecessary > 0) {//and the first order (FIFO)
                    uint volumeAtPriceFromAddress = tokens[tokenNameIndex].sellBook[whilePrice].offers[offersKey].amount;

                    //Two choices from here:
                    //1) one person offers not enough volume to fulfill the market order - we use it up completely and move on to the next person who offers the symbolName
                    //2) else: we make use of parts of what a person is offering - lower his amount, fulfill out order.
                    if (volumeAtPriceFromAddress <= amountNecessary) {
                        total_amount_ether_available = volumeAtPriceFromAddress * whilePrice;

                        require(balanceEthForAddress[msg.sender] >= total_amount_ether_available);
                        require(balanceEthForAddress[msg.sender] - total_amount_ether_available <= balanceEthForAddress[msg.sender]);
                        //first deduct the amount of ether from our balance
                        balanceEthForAddress[msg.sender] -= total_amount_ether_available;

                        require(tokenBalanceForAddress[msg.sender][tokenNameIndex] + volumeAtPriceFromAddress >= tokenBalanceForAddress[msg.sender][tokenNameIndex]);
                        require(balanceEthForAddress[tokens[tokenNameIndex].sellBook[whilePrice].offers[offersKey].who] + total_amount_ether_available >= balanceEthForAddress[tokens[tokenNameIndex].sellBook[whilePrice].offers[offersKey].who]);
                        //overflow check
                        //this guy offers less or equal the volume that we ask for, so we use it up completely.
                        tokenBalanceForAddress[msg.sender][tokenNameIndex] += volumeAtPriceFromAddress;
                        tokens[tokenNameIndex].sellBook[whilePrice].offers[offersKey].amount = 0;
                        balanceEthForAddress[tokens[tokenNameIndex].sellBook[whilePrice].offers[offersKey].who] += total_amount_ether_available;
                        tokens[tokenNameIndex].sellBook[whilePrice].offersKey++;

                        SellOrderFulfilled(tokenNameIndex, volumeAtPriceFromAddress, whilePrice, offersKey);

                        amountNecessary -= volumeAtPriceFromAddress;
                    } else {
                        require(tokens[tokenNameIndex].sellBook[whilePrice].offers[offersKey].amount > amountNecessary);//sanity

                        total_amount_ether_necessary = amountNecessary * whilePrice;
                        require(balanceEthForAddress[msg.sender] - total_amount_ether_necessary <= balanceEthForAddress[msg.sender]);

                        //first deduct the amount of ether from our balance
                        balanceEthForAddress[msg.sender] -= total_amount_ether_necessary;

                        require(balanceEthForAddress[tokens[tokenNameIndex].sellBook[whilePrice].offers[offersKey].who] + total_amount_ether_necessary >= balanceEthForAddress[tokens[tokenNameIndex].sellBook[whilePrice].offers[offersKey].who]);
                        //overflow check
                        //this guy offers more than we ask for. We reduce his stack, add the tokens to us and the ether to him.
                        tokens[tokenNameIndex].sellBook[whilePrice].offers[offersKey].amount -= amountNecessary;
                        balanceEthForAddress[tokens[tokenNameIndex].sellBook[whilePrice].offers[offersKey].who] += total_amount_ether_necessary;
                        tokenBalanceForAddress[msg.sender][tokenNameIndex] += amountNecessary;

                        amountNecessary = 0;
                        //we have fulfilled our order
                        SellOrderFulfilled(tokenNameIndex, amountNecessary, whilePrice, offersKey);
                    }

                    //if it was the last offer for that price, we have to set the currentBuyPrice now lower. Additionally we have one offer less...
                    if (
                    offersKey == tokens[tokenNameIndex].sellBook[whilePrice].offersLength &&
                    tokens[tokenNameIndex].sellBook[whilePrice].offers[offersKey].amount == 0
                    ) {

                        tokens[tokenNameIndex].amountSellPrices--;
                        //we have one price offer less here...
                        //next whilePrice
                        if (whilePrice == tokens[tokenNameIndex].sellBook[whilePrice].higherPrice || tokens[tokenNameIndex].buyBook[whilePrice].higherPrice == 0) {
                            tokens[tokenNameIndex].currentSellPrice = 0;
                            //we have reached the last price
                        } else {
                            tokens[tokenNameIndex].currentSellPrice = tokens[tokenNameIndex].sellBook[whilePrice].higherPrice;
                            tokens[tokenNameIndex].sellBook[tokens[tokenNameIndex].buyBook[whilePrice].higherPrice].lowerPrice = 0;
                        }
                    }
                    offersKey++;
                }

                //we set the currentSellPrice again, since when the volume is used up for a lowest price the currentSellPrice is set there...
                whilePrice = tokens[tokenNameIndex].currentSellPrice;
            }

            if (amountNecessary > 0) {
                buyToken(symbolName, priceInWei, amountNecessary);
                //add a limit order!
            }
        }
    }

    function addBuyOffer(uint8 tokenIndex, uint priceInWei, uint amount, address who) internal {
        tokens[tokenIndex].buyBook[priceInWei].offersLength++;
        tokens[tokenIndex].buyBook[priceInWei].offers[tokens[tokenIndex].buyBook[priceInWei].offersLength] = Offer(amount, who);


        if (tokens[tokenIndex].buyBook[priceInWei].offersLength == 1) {
            tokens[tokenIndex].buyBook[priceInWei].offersKey = 1;
            //we have a new buy order - increase the counter, so we can set the getOrderBook array later
            tokens[tokenIndex].amountBuyPrices++;


            //lowerPrice and higherPrice have to be set
            uint currentBuyPrice = tokens[tokenIndex].currentBuyPrice;

            uint lowestBuyPrice = tokens[tokenIndex].lowestBuyPrice;
            if (lowestBuyPrice == 0 || lowestBuyPrice > priceInWei) {
                if (currentBuyPrice == 0) {
                    //there is no buy order yet, we insert the first one...
                    tokens[tokenIndex].currentBuyPrice = priceInWei;
                    tokens[tokenIndex].buyBook[priceInWei].higherPrice = priceInWei;
                    tokens[tokenIndex].buyBook[priceInWei].lowerPrice = 0;
                } else {
                    //or the lowest one
                    tokens[tokenIndex].buyBook[lowestBuyPrice].lowerPrice = priceInWei;
                    tokens[tokenIndex].buyBook[priceInWei].higherPrice = lowestBuyPrice;
                    tokens[tokenIndex].buyBook[priceInWei].lowerPrice = 0;
                }
                tokens[tokenIndex].lowestBuyPrice = priceInWei;
            } else if (currentBuyPrice < priceInWei) {
                //the offer to buy is the highest one, we don't need to find the right spot
                tokens[tokenIndex].buyBook[currentBuyPrice].higherPrice = priceInWei;
                tokens[tokenIndex].buyBook[priceInWei].higherPrice = priceInWei;
                tokens[tokenIndex].buyBook[priceInWei].lowerPrice = currentBuyPrice;
                tokens[tokenIndex].currentBuyPrice = priceInWei;

            } else {
                //we are somewhere in the middle, we need to find the right spot first...

                uint buyPrice = tokens[tokenIndex].currentBuyPrice;
                bool weFoundIt = false;
                while (buyPrice > 0 && !weFoundIt) {
                    if (
                    buyPrice < priceInWei &&
                    tokens[tokenIndex].buyBook[buyPrice].higherPrice > priceInWei
                    ) {
                        //set the new order-book entry higher/lowerPrice first right
                        tokens[tokenIndex].buyBook[priceInWei].lowerPrice = buyPrice;
                        tokens[tokenIndex].buyBook[priceInWei].higherPrice = tokens[tokenIndex].buyBook[buyPrice].higherPrice;

                        //set the higherPrice'd order-book entries lowerPrice to the current Price
                        tokens[tokenIndex].buyBook[tokens[tokenIndex].buyBook[buyPrice].higherPrice].lowerPrice = priceInWei;
                        //set the lowerPrice'd order-book entries higherPrice to the current Price
                        tokens[tokenIndex].buyBook[buyPrice].higherPrice = priceInWei;

                        //set we found it.
                        weFoundIt = true;
                    }
                    buyPrice = tokens[tokenIndex].buyBook[buyPrice].lowerPrice;
                }
            }
        }
    }

    function sellToken(string symbolName, uint priceInWei, uint amount) public {
        uint8 tokenNameIndex = getSymbolIndexOrThrow(symbolName);
        uint total_amount_ether_necessary = 0;
        uint total_amount_ether_available = 0;


        if (tokens[tokenNameIndex].amountBuyPrices == 0 || tokens[tokenNameIndex].currentBuyPrice < priceInWei) {

            //if we have enough ether, we can buy that:
            total_amount_ether_necessary = amount * priceInWei;

            //overflow check
            require(total_amount_ether_necessary >= amount);
            require(total_amount_ether_necessary >= priceInWei);
            require(tokenBalanceForAddress[msg.sender][tokenNameIndex] >= amount);
            require(tokenBalanceForAddress[msg.sender][tokenNameIndex] - amount >= 0);
            require(balanceEthForAddress[msg.sender] + total_amount_ether_necessary >= balanceEthForAddress[msg.sender]);

            //actually subtract the amount of tokens to change it then
            tokenBalanceForAddress[msg.sender][tokenNameIndex] -= amount;

            //limit order: we don't have enough offers to fulfill the amount

            //add the order to the orderBook
            addSellOffer(tokenNameIndex, priceInWei, amount, msg.sender);
            //and emit the event.
            LimitSellOrderCreated(tokenNameIndex, msg.sender, amount, priceInWei, tokens[tokenNameIndex].sellBook[priceInWei].offersLength);

        } else {
            //market order: current buy price is bigger or equal to sell price!

            //1st: find the "highest buy price" that is higher than the sell amount  [buy: 60@5000] [buy: 50@4500] [sell: 500@4000]
            //2: sell up the volume for 5000
            //3: sell up the volume for 4500
            //if still something remaining -> sellToken limit order

            //2: sell up the volume
            //2.1 add ether to seller, add symbolName to buyer until offersKey <= offersLength


            uint whilePrice = tokens[tokenNameIndex].currentBuyPrice;
            uint amountNecessary = amount;
            uint offersKey;
            while (whilePrice >= priceInWei && amountNecessary > 0) {//we start with the highest buy price.
                offersKey = tokens[tokenNameIndex].buyBook[whilePrice].offersKey;
                while (offersKey <= tokens[tokenNameIndex].buyBook[whilePrice].offersLength && amountNecessary > 0) {//and the first order (FIFO)
                    uint volumeAtPriceFromAddress = tokens[tokenNameIndex].buyBook[whilePrice].offers[offersKey].amount;


                    //Two choices from here:
                    //1) one person offers not enough volume to fulfill the market order - we use it up completely and move on to the next person who offers the symbolName
                    //2) else: we make use of parts of what a person is offering - lower his amount, fulfill out order.
                    if (volumeAtPriceFromAddress <= amountNecessary) {
                        total_amount_ether_available = volumeAtPriceFromAddress * whilePrice;


                        //overflow check
                        require(tokenBalanceForAddress[msg.sender][tokenNameIndex] >= volumeAtPriceFromAddress);
                        //actually subtract the amount of tokens to change it then
                        tokenBalanceForAddress[msg.sender][tokenNameIndex] -= volumeAtPriceFromAddress;

                        //overflow check
                        require(tokenBalanceForAddress[msg.sender][tokenNameIndex] - volumeAtPriceFromAddress >= 0);
                        require(tokenBalanceForAddress[tokens[tokenNameIndex].buyBook[whilePrice].offers[offersKey].who][tokenNameIndex] + volumeAtPriceFromAddress >= tokenBalanceForAddress[tokens[tokenNameIndex].buyBook[whilePrice].offers[offersKey].who][tokenNameIndex]);
                        require(balanceEthForAddress[msg.sender] + total_amount_ether_available >= balanceEthForAddress[msg.sender]);

                        //this guy offers less or equal the volume that we ask for, so we use it up completely.
                        tokenBalanceForAddress[tokens[tokenNameIndex].buyBook[whilePrice].offers[offersKey].who][tokenNameIndex] += volumeAtPriceFromAddress;
                        tokens[tokenNameIndex].buyBook[whilePrice].offers[offersKey].amount = 0;
                        balanceEthForAddress[msg.sender] += total_amount_ether_available;
                        tokens[tokenNameIndex].buyBook[whilePrice].offersKey++;
                        SellOrderFulfilled(tokenNameIndex, volumeAtPriceFromAddress, whilePrice, offersKey);


                        amountNecessary -= volumeAtPriceFromAddress;
                    } else {
                        require(volumeAtPriceFromAddress - amountNecessary > 0);
                        //just for sanity
                        total_amount_ether_necessary = amountNecessary * whilePrice;
                        //we take the rest of the outstanding amount

                        //overflow check
                        require(tokenBalanceForAddress[msg.sender][tokenNameIndex] >= amountNecessary);
                        //actually subtract the amount of tokens to change it then
                        tokenBalanceForAddress[msg.sender][tokenNameIndex] -= amountNecessary;

                        //overflow check
                        require(tokenBalanceForAddress[msg.sender][tokenNameIndex] >= amountNecessary);
                        require(balanceEthForAddress[msg.sender] + total_amount_ether_necessary >= balanceEthForAddress[msg.sender]);
                        require(tokenBalanceForAddress[tokens[tokenNameIndex].buyBook[whilePrice].offers[offersKey].who][tokenNameIndex] + amountNecessary >= tokenBalanceForAddress[tokens[tokenNameIndex].buyBook[whilePrice].offers[offersKey].who][tokenNameIndex]);

                        //this guy offers more than we ask for. We reduce his stack, add the eth to us and the symbolName to him.
                        tokens[tokenNameIndex].buyBook[whilePrice].offers[offersKey].amount -= amountNecessary;
                        balanceEthForAddress[msg.sender] += total_amount_ether_necessary;
                        tokenBalanceForAddress[tokens[tokenNameIndex].buyBook[whilePrice].offers[offersKey].who][tokenNameIndex] += amountNecessary;

                        SellOrderFulfilled(tokenNameIndex, amountNecessary, whilePrice, offersKey);

                        amountNecessary = 0;
                        //we have fulfilled our order
                    }

                    //if it was the last offer for that price, we have to set the currentBuyPrice now lower. Additionally we have one offer less...
                    if (
                    offersKey == tokens[tokenNameIndex].buyBook[whilePrice].offersLength &&
                    tokens[tokenNameIndex].buyBook[whilePrice].offers[offersKey].amount == 0
                    ) {

                        tokens[tokenNameIndex].amountBuyPrices--;
                        //we have one price offer less here...
                        //next whilePrice
                        if (whilePrice == tokens[tokenNameIndex].buyBook[whilePrice].lowerPrice || tokens[tokenNameIndex].buyBook[whilePrice].lowerPrice == 0) {
                            tokens[tokenNameIndex].currentBuyPrice = 0;
                            //we have reached the last price
                        } else {
                            tokens[tokenNameIndex].currentBuyPrice = tokens[tokenNameIndex].buyBook[whilePrice].lowerPrice;
                            tokens[tokenNameIndex].buyBook[tokens[tokenNameIndex].buyBook[whilePrice].lowerPrice].higherPrice = tokens[tokenNameIndex].currentBuyPrice;
                        }
                    }
                    offersKey++;
                }

                //we set the currentSellPrice again, since when the volume is used up for a lowest price the currentSellPrice is set there...
                whilePrice = tokens[tokenNameIndex].currentBuyPrice;
            }

            if (amountNecessary > 0) {
                sellToken(symbolName, priceInWei, amountNecessary);
                //add a limit order, we couldn't fulfill all the orders!
            }

        }
    }

    function addSellOffer(uint8 tokenIndex, uint priceInWei, uint amount, address who) internal {
        tokens[tokenIndex].sellBook[priceInWei].offersLength++;
        tokens[tokenIndex].sellBook[priceInWei].offers[tokens[tokenIndex].sellBook[priceInWei].offersLength] = Offer(amount, who);


        if (tokens[tokenIndex].sellBook[priceInWei].offersLength == 1) {
            tokens[tokenIndex].sellBook[priceInWei].offersKey = 1;
            //we have a new sell order - increase the counter, so we can set the getOrderBook array later
            tokens[tokenIndex].amountSellPrices++;

            //lowerPrice and higherPrice have to be set
            uint currentSellPrice = tokens[tokenIndex].currentSellPrice;

            uint highestSellPrice = tokens[tokenIndex].highestSellPrice;
            if (highestSellPrice == 0 || highestSellPrice < priceInWei) {
                if (currentSellPrice == 0) {
                    //there is no sell order yet, we insert the first one...
                    tokens[tokenIndex].currentSellPrice = priceInWei;
                    tokens[tokenIndex].sellBook[priceInWei].higherPrice = 0;
                    tokens[tokenIndex].sellBook[priceInWei].lowerPrice = 0;
                } else {

                    //this is the highest sell order
                    tokens[tokenIndex].sellBook[highestSellPrice].higherPrice = priceInWei;
                    tokens[tokenIndex].sellBook[priceInWei].lowerPrice = highestSellPrice;
                    tokens[tokenIndex].sellBook[priceInWei].higherPrice = 0;
                }

                tokens[tokenIndex].highestSellPrice = priceInWei;

            } else if (currentSellPrice > priceInWei) {
                //the offer to sell is the lowest one, we don't need to find the right spot
                tokens[tokenIndex].sellBook[currentSellPrice].lowerPrice = priceInWei;
                tokens[tokenIndex].sellBook[priceInWei].higherPrice = currentSellPrice;
                tokens[tokenIndex].sellBook[priceInWei].lowerPrice = 0;
                tokens[tokenIndex].currentSellPrice = priceInWei;

            } else {
                //we are somewhere in the middle, we need to find the right spot first...

                uint sellPrice = tokens[tokenIndex].currentSellPrice;
                bool weFoundIt = false;
                while (sellPrice > 0 && !weFoundIt) {
                    if (
                    sellPrice < priceInWei &&
                    tokens[tokenIndex].sellBook[sellPrice].higherPrice > priceInWei
                    ) {
                        //set the new order-book entry higher/lowerPrice first right
                        tokens[tokenIndex].sellBook[priceInWei].lowerPrice = sellPrice;
                        tokens[tokenIndex].sellBook[priceInWei].higherPrice = tokens[tokenIndex].sellBook[sellPrice].higherPrice;

                        //set the higherPrice'd order-book entries lowerPrice to the current Price
                        tokens[tokenIndex].sellBook[tokens[tokenIndex].sellBook[sellPrice].higherPrice].lowerPrice = priceInWei;
                        //set the lowerPrice'd order-book entries higherPrice to the current Price
                        tokens[tokenIndex].sellBook[sellPrice].higherPrice = priceInWei;

                        //set we found it.
                        weFoundIt = true;
                    }
                    sellPrice = tokens[tokenIndex].sellBook[sellPrice].higherPrice;
                }
            }
        }
    }


    function cancelOrder(string symbolName, bool isSellOrder, uint priceInWei, uint offerKey) public {
        uint8 symbolNameIndex = getSymbolIndexOrThrow(symbolName);
        if (isSellOrder) {
            require(tokens[symbolNameIndex].sellBook[priceInWei].offers[offerKey].who == msg.sender);

            uint tokensAmount = tokens[symbolNameIndex].sellBook[priceInWei].offers[offerKey].amount;
            require(tokenBalanceForAddress[msg.sender][symbolNameIndex] + tokensAmount >= tokenBalanceForAddress[msg.sender][symbolNameIndex]);


            tokenBalanceForAddress[msg.sender][symbolNameIndex] += tokensAmount;
            tokens[symbolNameIndex].sellBook[priceInWei].offers[offerKey].amount = 0;
            SellOrderCanceled(symbolNameIndex, priceInWei, offerKey);

        } else {
            require(tokens[symbolNameIndex].buyBook[priceInWei].offers[offerKey].who == msg.sender);
            uint etherToRefund = tokens[symbolNameIndex].buyBook[priceInWei].offers[offerKey].amount * priceInWei;
            require(balanceEthForAddress[msg.sender] + etherToRefund >= balanceEthForAddress[msg.sender]);

            balanceEthForAddress[msg.sender] += etherToRefund;
            tokens[symbolNameIndex].buyBook[priceInWei].offers[offerKey].amount = 0;
            BuyOrderCanceled(symbolNameIndex, priceInWei, offerKey);
        }
    }
}