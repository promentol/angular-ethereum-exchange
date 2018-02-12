import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { UtilModule } from '../util/util.module';
import { RouterModule, Routes} from '@angular/router';
import { MainComponent } from './main/main.component';
import { ManageTokenComponent } from './manage-token/manage-token.component';
import { TradingComponent } from './trading/trading.component';
import { DepositTokenComponent } from './deposit-token/deposit-token.component';
import { DepositEthComponent } from './deposit-eth/deposit-eth.component';
import { WithdrawEthComponent } from './withdraw-eth/withdraw-eth.component';
import { WithdrawTokenComponent } from './withdraw-token/withdraw-token.component';
import { AssetsComponent } from './assets/assets.component';
import { EventsComponent } from './events/events.component';

const appRoutes: Routes = [
  { path: '', component: MainComponent },
  { path: 'managetoken', component: ManageTokenComponent },
  { path: 'trading', component: TradingComponent }
];

import { FormsModule } from '@angular/forms';

@NgModule({
  imports: [
    CommonModule,
    RouterModule.forChild(appRoutes),
    UtilModule,
    FormsModule
  ],
  declarations: [
    MainComponent,
    ManageTokenComponent,
    TradingComponent,
    DepositTokenComponent,
    DepositEthComponent,
    WithdrawEthComponent,
    WithdrawTokenComponent,
    AssetsComponent,
    EventsComponent
  ],
  exports: [
    MainComponent,
    ManageTokenComponent,
    TradingComponent,
    DepositTokenComponent,
    DepositEthComponent,
    WithdrawEthComponent,
    WithdrawTokenComponent,
    AssetsComponent,
    EventsComponent
  ]
})
export class ExchangeModule {
}
