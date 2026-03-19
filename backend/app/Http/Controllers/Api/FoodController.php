<?php

namespace App\Http\Controllers\Api;

use App\Models\Food;
use Illuminate\Http\Request;

class FoodController extends BaseController
{
    /**
     * Display a listing of the resource.
     */
    public function index() // GET /foods
    {

        $foods = Food::get()->sortBy('name');
        return $this->sendResponse($foods, 'Foods');
    }


    /**
     * Store a newly created resource in storage. POST /foods {name, price, description}
     */
    public function store(Request $request)// POST /foods {name, price, description}
    {
        $food = Food::create($request->all());
        return $this->sendResponse($food, 'Food created successfully');
    }

    /**
     * Display the specified resource. GET /foods/{id}
     */
    public function show(string $id)
    {
        //
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(string $id)
    {
        //
    }

    /**
     * Update the specified resource in storage. PUT
     */
    public function update(Request $request, string $id)
    {
        //
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        //
    }
}
