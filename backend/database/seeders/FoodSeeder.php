<?php

namespace Database\Seeders;

use App\Models\Food;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class FoodSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        Food::create([
            'name' => 'Pizza',
            'is_purple' => true,
        ]);
        Food::create([
            'name' => 'Burger',
            'is_purple' => false,
        ]);
        Food::create([
            'name' => 'Salad',
            'is_purple' => true,
        ]);
        Food::create([
            'name' => 'Soda',
            'is_purple' => false,
        ]);
        Food::create([
            'name' => 'Ice Cream',
            'is_purple' => true,
        ]);
        Food::create([
            'name' => 'Cake',
            'is_purple' => false,
        ]);
        Food::create([
            'name' => 'Donut',
            'is_purple' => true,
        ]);
        Food::create([
            'name' => 'Vitamin water',
            'is_purple' => false,
        ]);
        Food::create([
            'name' => 'Lemonade',
            'is_purple' => true,
        ]);
        Food::create([
            'name' => 'Water',
            'is_purple' => false,
        ]);
    }
}
