import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { WithdrawTokenComponent } from './withdraw-token.component';

describe('WithdrawTokenComponent', () => {
  let component: WithdrawTokenComponent;
  let fixture: ComponentFixture<WithdrawTokenComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ WithdrawTokenComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(WithdrawTokenComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
