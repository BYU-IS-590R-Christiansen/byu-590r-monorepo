import { computed } from '@angular/core';
import {
  signalStore,
  withState,
  withComputed,
  withMethods,
  patchState,
} from '@ngrx/signals';
import { Drink } from '../services/drinks.service';

export interface DrinksState {
  drinksList: Drink[];
}

const initialState: DrinksState = {
  drinksList: [],
};

export const DrinksStore = signalStore(
  { providedIn: 'root' },
  withState<DrinksState>(initialState),
  withComputed(({ drinksList }) => ({
    drinks: computed(() => {
      return drinksList().map((drink) => ({
        ...drink,
      }));
    }),
  })),
  withMethods((store) => ({
    setDrinks(drinks: Drink[] | unknown): void {
      patchState(store, {
        drinksList: drinks as Drink[],
      });
    },
  })),
);
