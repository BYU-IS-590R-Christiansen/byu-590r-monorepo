<?php


namespace App\Http\Controllers\Api;

use App\Models\Drink;
use Illuminate\Http\Request;

class DrinkController extends BaseController
{
    /**
     * Display a listing of the resource. /drinks GET
     */ 
        public function index()
    {


        $drinks = Drink::orderBy('name')->get();

        foreach( $drinks as $drink) {
            $drink->image = $this->getS3Url($drink->image);
        }
        

        return $this->sendResponse($drinks, 'Drinks');
    }

    /**
     * Show the form for creating a new resource.
     */
    public function create()
    {
        //
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        //
    }

    /**
     * Display the specified resource.
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
     * Update the specified resource in storage.
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
