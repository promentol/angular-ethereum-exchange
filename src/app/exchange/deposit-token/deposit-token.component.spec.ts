import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { DepositTokenComponent } from './deposit-token.component';

describe('DepositTokenComponent', () => {
  let component: DepositTokenComponent;
  let fixture: ComponentFixture<DepositTokenComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ DepositTokenComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(DepositTokenComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
