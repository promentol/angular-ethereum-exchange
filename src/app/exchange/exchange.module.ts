import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { UtilModule } from '../util/util.module';
import { RouterModule, Routes} from '@angular/router';
import { MainComponent } from './main/main.component';
import { ManageTokenComponent } from './manage-token/manage-token.component';
import { TradingComponent } from './trading/trading.component';

const appRoutes: Routes = [
  { path: '', component: MainComponent },
  { path: 'managetoken', component: ManageTokenComponent },
  { path: 'trading', component: TradingComponent }
];

@NgModule({
  imports: [
    CommonModule,
    RouterModule.forChild(appRoutes),
    UtilModule
  ],
  declarations: [MainComponent, ManageTokenComponent, TradingComponent]
})
export class ExchangeModule {
}
