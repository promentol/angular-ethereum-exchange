import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { ManageTokenComponent } from './manage-token.component';

describe('ManageTokenComponent', () => {
  let component: ManageTokenComponent;
  let fixture: ComponentFixture<ManageTokenComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ ManageTokenComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(ManageTokenComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
