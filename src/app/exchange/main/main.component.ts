import { Component, OnInit, HostBinding } from '@angular/core';
import { ExchangeService } from '../../util/exchange.service';

@Component({
  selector: 'app-main',
  templateUrl: './main.component.html',
  styleUrls: ['./main.component.css']
})
export class MainComponent implements OnInit {

  constructor(public exchangeService: ExchangeService) { }

  @HostBinding('class.col-lg-8') someField = true;

  ngOnInit() {
  }

}
