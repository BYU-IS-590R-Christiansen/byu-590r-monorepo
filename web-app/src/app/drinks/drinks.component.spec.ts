import { ComponentFixture, TestBed } from '@angular/core/testing';
import { TestbedHarnessEnvironment } from '@angular/cdk/testing/testbed';
import { MatSelectHarness } from '@angular/material/select/testing';
import { of } from 'rxjs';
import type { Drink } from '../core/services/drinks.service';
import { DrinksService } from '../core/services/drinks.service';
import { DrinksStore } from '../core/stores/drinks.store';

import { DrinksComponent } from './drinks.component';

describe('DrinksComponent', () => {
  let component: DrinksComponent;
  let fixture: ComponentFixture<DrinksComponent>;
  type DrinksStoreInstance = {
    drinks: () => Drink[];
    setDrinks: (drinks: Drink[] | unknown) => void;
  };
  let drinksStore!: DrinksStoreInstance;
  let drinksServiceSpy: jasmine.SpyObj<DrinksService>;

  const dummyDrinks: Drink[] = [
    {
      id: 1,
      name: 'Cola',
      is_diet: false,
      size: '12oz',
      image: 'cola.png',
    },
    {
      id: 2,
      name: 'Diet Cola',
      is_diet: true,
      size: '12oz',
      image: 'diet-cola.png',
    },
  ];

  beforeEach(async () => {
    drinksServiceSpy = jasmine.createSpyObj<DrinksService>('DrinksService', ['getDrinks']);
    drinksServiceSpy.getDrinks.and.returnValue(
      of({
        success: true,
        results: dummyDrinks,
        message: 'ok',
      })
    );

    await TestBed.configureTestingModule({
      imports: [DrinksComponent],
      providers: [{ provide: DrinksService, useValue: drinksServiceSpy }],
    })
    .compileComponents();

    fixture = TestBed.createComponent(DrinksComponent);
    component = fixture.componentInstance;
    drinksStore = TestBed.inject(DrinksStore);
    drinksStore.setDrinks([]);
  });

  it('should create', () => {
    fixture.detectChanges();
    expect(component).toBeTruthy();
  });

  it('should fetch drinks and render them in the mat-select', async () => {
    fixture.detectChanges();
    await fixture.whenStable();

    const loader = TestbedHarnessEnvironment.loader(fixture);
    const select = await loader.getHarness(MatSelectHarness);

    await select.open();
    const options = await select.getOptions();
    const optionTexts = await Promise.all(options.map((o) => o.getText()));

    expect(optionTexts).toEqual(jasmine.arrayContaining(dummyDrinks.map((d) => d.name)));
    expect(drinksServiceSpy.getDrinks).toHaveBeenCalled();
  });

  it('should populate the store with successful API results', () => {
    fixture.detectChanges();
    expect(drinksStore.drinks().length).toBe(dummyDrinks.length);
    expect(drinksStore.drinks()[0]?.id).toBe(dummyDrinks[0]!.id);
  });

  it('should keep the store empty when API reports success=false', () => {
    drinksServiceSpy.getDrinks.and.returnValue(
      of({
        success: false,
        results: dummyDrinks,
        message: 'bad request',
      })
    );

    fixture.detectChanges();
    expect(drinksStore.drinks().length).toBe(0);
  });

  it('should clear store state on destroy', () => {
    fixture.detectChanges();
    expect(drinksStore.drinks().length).toBeGreaterThan(0);

    fixture.destroy();
    expect(drinksStore.drinks().length).toBe(0);
  });
});
