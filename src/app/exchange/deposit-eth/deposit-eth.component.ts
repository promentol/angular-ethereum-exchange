import { Component, OnInit } from '@angular/core';
import { ExchangeService } from '../../util/exchange.service';

@Component({
  selector: 'app-deposit-eth',
  templateUrl: './deposit-eth.component.html',
  styleUrls: ['./deposit-eth.component.css']
})
export class DepositEthComponent implements OnInit {

  public amount: number;

  constructor(public exchangeService: ExchangeService) { }

  ngOnInit() {
  }

  depositEth() {
    this.exchangeService.depositEth(this.amount);
  }

}
