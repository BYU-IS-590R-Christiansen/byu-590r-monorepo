import { Component, inject } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { MatFormFieldModule } from '@angular/material/form-field';
import { Drink, DrinksService } from '../core/services/drinks.service';
import { DrinksStore } from '../core/stores/drinks.store';

@Component({
  selector: 'app-drinks',
  imports: [MatFormFieldModule, MatSelectModule, MatInputModule, FormsModule],
  templateUrl: './drinks.component.html',
  styleUrl: './drinks.component.scss',
})
export class DrinksComponent {
  private drinksService = inject(DrinksService);
  private drinksStore = inject(DrinksStore);

  drinks = this.drinksStore.drinks;

  ngOnInit(): void {
    this.getDrinks();

    console.log(this.drinks());
  }

  ngOnDestroy(): void {
    this.drinksStore.setDrinks([]);
    this.drinksService.getDrinks().subscribe().unsubscribe();
  }

  public getDrinks(): void {
    this.drinksService.getDrinks().subscribe({
      next: (response: {
        success: boolean;
        results: Drink[];
        message: string;
      }) => {
        if (response.success) {
          this.drinksStore.setDrinks(response.results);
        } else {
          console.error(response.message);
        }
      },
      error: (error) => {
        console.error('Error fetching drinks:', error);
      },
    });
  }
}
