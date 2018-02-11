import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { WithdrawEthComponent } from './withdraw-eth.component';

describe('WithdrawEthComponent', () => {
  let component: WithdrawEthComponent;
  let fixture: ComponentFixture<WithdrawEthComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ WithdrawEthComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(WithdrawEthComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
