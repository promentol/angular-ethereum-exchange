import { Component, OnInit, HostBinding } from '@angular/core';
import { ExchangeService } from '../../util/exchange.service';

@Component({
  selector: 'app-manage-token',
  templateUrl: './manage-token.component.html',
  styleUrls: ['./manage-token.component.css']
})
export class ManageTokenComponent implements OnInit {

  public inputAmountSendToken;
  public inputBeneficiarySendToken;

  public inputAmountAllowanceToken;
  public inputBeneficiaryAllowanceToken;

  public inputAddressTokenAddExchange;
  public inputNameTokenAddExchange;

  constructor(public exchangeService: ExchangeService) { }

  @HostBinding('class.col-lg-8') someField = true;

  ngOnInit() {
  }

  public sendToken() {
   this.exchangeService.sendToken(this.inputAmountSendToken, this.inputBeneficiarySendToken);
  }

  public allowanceToken() {
    this.exchangeService.allowanceToken(this.inputAmountAllowanceToken, this.inputBeneficiaryAllowanceToken);
  }

  public addTokenToExchange() {
    this.exchangeService.addTokenToExchange(this.inputNameTokenAddExchange, this.inputAddressTokenAddExchange);
  }

}
