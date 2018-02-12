import {NgModule} from '@angular/core';
import {CommonModule} from '@angular/common';
import {Web3Service} from './web3.service';
import { ExchangeService } from './exchange.service';

@NgModule({
  imports: [
    CommonModule
  ],
  providers: [
    Web3Service,
    ExchangeService
  ],
  declarations: []
})
export class UtilModule {
}
