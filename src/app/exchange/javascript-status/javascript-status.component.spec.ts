import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { JavascriptStatusComponent } from './javascript-status.component';

describe('JavascriptStatusComponent', () => {
  let component: JavascriptStatusComponent;
  let fixture: ComponentFixture<JavascriptStatusComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ JavascriptStatusComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(JavascriptStatusComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
