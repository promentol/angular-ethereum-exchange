import { Injectable } from '@angular/core';
import { Web3Service } from './web3.service';
import { default as contract } from 'truffle-contract';

import exchange_artifacts from '../../../build/contracts/Exchange.json';
import token_artifacts from '../../../build/contracts/FixedSupplyToken.json';
import { BehaviorSubject } from 'rxjs/BehaviorSubject';

@Injectable()
export class ExchangeService {

  ExchangeContract: any;
  TokenContract: any;

  balanceTokenInExchange: BehaviorSubject<number>;
  balanceEtherInExchange: BehaviorSubject<number>;

  constructor(public web3service: Web3Service) {
    this.ExchangeContract = contract(exchange_artifacts);
    this.TokenContract = contract(token_artifacts);

    this.balanceTokenInExchange = new BehaviorSubject(0);
    this.refreshBalanceTokenInExchange();

    this.balanceEtherInExchange = new BehaviorSubject(0);
    this.refreshBalanceEtherInExchange();
  }

  refreshBalanceTokenInExchange() {
    return this.ExchangeContract.deployed().then((instance) => {
      return instance.getBalance('FIXED');
    }).then((value) => {
      this.balanceTokenInExchange.next(value.toNumber());
    });
  }

  refreshBalanceEtherInExchange() {
    return this.ExchangeContract.deployed().then((instance) => {
      return instance.getEthBalanceInWei();
    }).then((value) => {
      return this.web3service.web3.fromWei(value, 'ether');
    }).then((value) => {
      this.balanceEtherInExchange.next(value);
    });
  }

  depositEth(amount) {
    return this.ExchangeContract.deployed().then((instance) => {
      return instance.depositEther({
        value: this.web3service.web3.toWei(amount, 'Ether'),
        from: this.web3service.mainAccount
      });
    });

  }

  withdrawEth(amount) {
    return this.ExchangeContract.deployed().then((instance) => {
      return instance.withdrawEther(this.web3service.web3.toWei(amount, 'Ether'), {
        from: this.web3service.mainAccount
      });
    });
  }

  depositToken(tokenName, amount) {
    return this.ExchangeContract.deployed().then((instance) => {
      return instance.depositEther(tokenName, amount, {
        from: this.web3service.mainAccount,
        ga: 4500000
      });
    });
  }

  withdrawToken(tokenName, amount) {
    return this.ExchangeContract.deployed().then((instance) => {
      return instance.withdrawToken(tokenName, amount, {
        from: this.web3service.mainAccount
      });
    });
  }
}
