<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class UsuarioSeeder extends Seeder
{
    public function run()
    {
        DB::table('usuarios')->insert([
            'nombre' => 'Admin',
            'apellido' => 'Render',
            'usuario' => 'adminrender',
            'email' => 'admin@render.com',
            'password' => password_hash('admin123', PASSWORD_DEFAULT),
            'rol_id' => 1, // Ajusta según tu sistema
            'genero' => 'Otro',
        ]);
    }
}
