import { Component, OnInit } from '@angular/core';
import { ExchangeService } from '../../util/exchange.service';

@Component({
  selector: 'app-withdraw-token',
  templateUrl: './withdraw-token.component.html',
  styleUrls: ['./withdraw-token.component.css']
})
export class WithdrawTokenComponent implements OnInit {

  public amount: number;
  public tokenName: string;

  constructor(public exchangeService: ExchangeService) { }

  ngOnInit() {
  }

  withdrawToken() {
    this.exchangeService.withdrawToken(this.tokenName, this.amount);
  }

}
