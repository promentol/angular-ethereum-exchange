import { Component, OnInit } from '@angular/core';
import { ExchangeService } from '../../util/exchange.service';

@Component({
  selector: 'app-withdraw-eth',
  templateUrl: './withdraw-eth.component.html',
  styleUrls: ['./withdraw-eth.component.css']
})
export class WithdrawEthComponent implements OnInit {

  public amount: number;

  constructor(public exchangeService: ExchangeService) { }

  ngOnInit() {
  }

  withdrawEth() {
    this.exchangeService.withdrawEth(this.amount);
  }

}
