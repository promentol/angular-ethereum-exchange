import { Component, OnInit, HostBinding } from '@angular/core';

@Component({
  selector: 'app-main',
  templateUrl: './main.component.html',
  styleUrls: ['./main.component.css']
})
export class MainComponent implements OnInit {

  constructor() { }

  @HostBinding('class.col-lg-8') someField = true;

  ngOnInit() {
  }

}
