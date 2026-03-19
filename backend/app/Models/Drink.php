<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Drink extends Model
{
    protected $table = 'drinks';
    use HasFactory;

    
    protected $fillable = [
        'name',
        'is_diet',
        'size'
    ];
}
