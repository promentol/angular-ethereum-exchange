import { Component, OnInit, HostBinding } from '@angular/core';

@Component({
  selector: 'app-trading',
  templateUrl: './trading.component.html',
  styleUrls: ['./trading.component.css']
})
export class TradingComponent implements OnInit {

  constructor() { }

  @HostBinding('class.col-lg-8') someField = true;

  ngOnInit() {
  }

}
