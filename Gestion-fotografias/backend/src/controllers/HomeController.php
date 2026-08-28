<?php
// QUÉ: Controlador básico para pruebas de conectividad y estado del servidor.
// POR QUÉ: Permite verificar que el enrutamiento y la respuesta JSON funcionan antes de conectar la base de datos.

declare(strict_types=1);

namespace App\controllers;

use App\Core\Response;

class HomeController
{
    public function ping(): void
    {
        Response::success([
            'servidor' => 'Cipher_Forge Backend API',
            'estado'   => 'activo',
            'hora'     => date('Y-m-d H:i:s')
        ], 'Conexión exitosa con el backend');
    }
}