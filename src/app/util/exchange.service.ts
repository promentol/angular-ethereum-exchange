import { Injectable } from '@angular/core';
import { Web3Service } from './web3.service';

import exchange_artifacts from '../../../build/contracts/Exchange.json';
import token_artifacts from '../../../build/contracts/FixedSupplyToken.json';

@Injectable()
export class ExchangeService {

  constructor(public web3service: Web3Service) {
    console.log('asd');
  }

  depositEth(amount) {
    console.log(amount);
  }

  withdrawEth(amount) {
    console.log(amount);
  }

  depositToken(tokenName, amount) {
    console.log(tokenName, amount);
  }

  withdrawToken(tokenName, amount) {
    console.log(tokenName, amount);
  }

}
