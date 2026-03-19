import { CommonModule } from '@angular/common';
import { ChangeDetectionStrategy, Component, signal } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';

@Component({
  selector: 'app-foods',
  imports: [CommonModule, MatCardModule, MatButtonModule],
  templateUrl: './foods.component.html',
  styleUrl: './foods.component.scss',
})
export class FoodsComponent {
  foods = signal<{ name: string; isPurple: boolean }[]>([
    { name: 'Pizza', isPurple: true },
    { name: 'Burger', isPurple: false },
    { name: 'Salad', isPurple: true },
    { name: 'Soda', isPurple: false },
    { name: 'Ice Cream', isPurple: true },
    { name: 'Cake', isPurple: false },
    { name: 'Donut', isPurple: true },
    { name: 'Coffee', isPurple: false },
    { name: 'Tea', isPurple: true },
    { name: 'Water', isPurple: false },
  ]);
}
