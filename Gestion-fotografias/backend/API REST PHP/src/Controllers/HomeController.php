<?php

declare(strict_types=1);

namespace App\Controllers;

use App\Core\Response;

/**
 * CONTROLADOR DE INICIO Y ESPECIFICACIÓN
 * ==============================================================================
 * WHAT: Atiende la ruta raíz (`GET /`) y devuelve información de estado y el
 *       mapa interactivo de endpoints de la API.
 * ==============================================================================
 */
class HomeController extends Controller
{
    public function index(): void
    {
        if (APP_ENV === 'production') {
            Response::success([
                'api'     => 'API REST PHP — Arquitectura por Capas',
                'version' => '2.0.0',
                'estado'  => 'online',
            ], 'API funcionando.');
        }

        Response::success([
            'api'        => 'API REST PHP — Arquitectura por Capas + DTO + Validators + JWT',
            'entorno'    => APP_ENV,
            'seguridad'  => 'JWT en Cookie HttpOnly (SameSite=Lax)',
            'endpoints'  => [
                'POST   /registro'             => 'Crear cuenta de usuario',
                'POST   /login'                => 'Iniciar sesión y emitir Cookie HttpOnly',
                'POST   /logout'               => 'Cerrar sesión y limpiar Cookie',
                'GET    /perfil'               => 'Consultar datos del usuario autenticado (requiere sesión)',
                'GET    /productos'            => 'Listar catálogo (?categoria=audio)',
                'GET    /productos/{id}'        => 'Ver detalle de un producto',
                'POST   /productos'            => 'Crear producto nuevo (requiere sesión)',
                'PUT    /productos/{id}'        => 'Modificar producto existente (requiere sesión)',
                'DELETE /productos/{id}'        => 'Eliminar producto (solo admin)',
                'POST   /productos/{id}/vender' => 'Vender unidades y descontar stock (requiere sesión)',
            ],
            'usuarios_de_prueba' => [
                'admin@utu.edu.uy / admin123 (rol: admin)',
                'alumno@utu.edu.uy / alumno123 (rol: usuario)',
            ],
        ], 'API REST Educativa funcionando correctamente.');
    }
}
