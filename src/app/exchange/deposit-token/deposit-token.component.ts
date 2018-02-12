import { Component, OnInit } from '@angular/core';
import { ExchangeService } from '../../util/exchange.service';

@Component({
  selector: 'app-deposit-token',
  templateUrl: './deposit-token.component.html',
  styleUrls: ['./deposit-token.component.css']
})
export class DepositTokenComponent implements OnInit {

  constructor(public exchangeService: ExchangeService) { }

  public amount: number;
  public tokenName: string;

  depositToken() {
    this.exchangeService.depositToken(this.tokenName, this.amount);
  }

  ngOnInit() {
  }

}
