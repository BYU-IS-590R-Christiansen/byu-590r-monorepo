<?php

namespace Database\Seeders;

use App\Models\Drink;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DrinkSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        Drink::create([
            'name' => 'Water',
            'is_diet' => true,
            'size' => '12oz',
            'image' => 'images/drinks/water.jpg',
        ]);
        Drink::create([
            'name' => 'Soda',
            'is_diet' => false,
            'size' => '12oz',
            'image' => 'images/drinks/soda.jpg',
        ]);
        Drink::create([
            'name' => 'Coffee',
            'is_diet' => false,
            'size' => '12oz',
            'image' => 'images/drinks/coffee.jpg',
        ]);
        Drink::create([
            'name' => 'Tea',
            'is_diet' => true,
            'size' => '12oz',
            'image' => 'images/drinks/tea.jpg',
        ]);
        Drink::create([
            'name' => 'Milk',
            'is_diet' => false,
            'size' => '12oz',
            'image' => 'images/drinks/milk.jpg',
        ]);
        Drink::create([
            'name' => 'Juice',
            'is_diet' => false,
            'size' => '12oz',
            'image' => 'images/drinks/juice.jpg',
        ]);
        Drink::create([
            'name' => 'Water',
            'is_diet' => true,
            'size' => '12oz',
            'image' => 'images/drinks/water.jpg',
        ]);
    }
}
