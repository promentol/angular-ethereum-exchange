import { Component, OnInit } from '@angular/core';
import { ExchangeService } from '../../util/exchange.service';

@Component({
  selector: 'app-assets',
  templateUrl: './assets.component.html',
  styleUrls: ['./assets.component.css']
})
export class AssetsComponent implements OnInit {

  constructor(public exchangeService: ExchangeService) { }

  ngOnInit() {
  }

}
