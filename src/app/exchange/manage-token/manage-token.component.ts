import { Component, OnInit, HostBinding } from '@angular/core';

@Component({
  selector: 'app-manage-token',
  templateUrl: './manage-token.component.html',
  styleUrls: ['./manage-token.component.css']
})
export class ManageTokenComponent implements OnInit {

  constructor() { }

  @HostBinding('class.col-lg-8') someField = true;

  ngOnInit() {
  }

}
