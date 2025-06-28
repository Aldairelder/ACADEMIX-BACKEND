<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Hash;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});

Route::post('/register', function (Request $request) {
    $validated = $request->validate([
        'nombre' => 'required|string|max:255',
        'apellido' => 'required|string|max:255',
        'usuario' => 'required|string|max:255|unique:usuarios,usuario',
        'email' => 'required|email|unique:usuarios,email',
        'password' => 'required|string|min:6',
        'rol_id' => 'required|integer',
        'genero' => 'required|string',
    ]);

    $id = \DB::table('usuarios')->insertGetId([
        'nombre' => $validated['nombre'],
        'apellido' => $validated['apellido'],
        'usuario' => $validated['usuario'],
        'email' => $validated['email'],
        'password' => Hash::make($validated['password']),
        'rol_id' => $validated['rol_id'],
        'genero' => $validated['genero'],
    ]);

    return response()->json([
        'success' => true,
        'usuario_id' => $id,
        'message' => 'Usuario registrado correctamente'
    ]);
});
