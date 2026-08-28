<?php

declare(strict_types=1);

namespace App\Validators;

/**
 * VALIDADOR DE AUTENTICACIÓN
 * ==============================================================================
 * WHAT: Valida la estructura, tipos y formatos de los datos de entrada para los
 *       endpoints de autenticación (`POST /registro` y `POST /login`).
 * WHY:  El validador se encarga exclusivamente de la sintaxis y formato (números,
 *       emails válidos, longitudes mínimas). NO consulta la base de datos ni
 *       aplica reglas del negocio (eso corresponde a AuthService).
 * ==============================================================================
 */
class AuthValidator
{
    /**
     * Valida la carga útil para el registro de usuarios.
     *
     * @param array<string, mixed> $data Datos crudos de la petición HTTP.
     * @return array<int, string> Lista de mensajes de error encontrados.
     */
    public static function validateRegister(array $data): array
    {
        $errors = [];

        $name     = $data['nombre'] ?? '';
        $email    = $data['email'] ?? '';
        $password = $data['clave'] ?? '';

        if (!is_string($name) || strlen(trim($name)) < 3) {
            $errors[] = 'El nombre tiene que tener al menos 3 letras.';
        }

        if (!is_string($email) || !filter_var(trim($email), FILTER_VALIDATE_EMAIL)) {
            $errors[] = 'El email no tiene un formato válido.';
        }

        if (!is_string($password) || strlen($password) < 6) {
            $errors[] = 'La contraseña tiene que tener al menos 6 caracteres.';
        }

        return $errors;
    }

    /**
     * Valida la carga útil para el inicio de sesión.
     *
     * @param array<string, mixed> $data Datos crudos de la petición HTTP.
     * @return array<int, string> Lista de mensajes de error encontrados.
     */
    public static function validateLogin(array $data): array
    {
        $errors = [];

        if (!isset($data['email']) || !is_string($data['email']) || trim($data['email']) === '') {
            $errors[] = 'Falta el email.';
        }

        if (!isset($data['clave']) || !is_string($data['clave']) || $data['clave'] === '') {
            $errors[] = 'Falta la contraseña.';
        }

        return $errors;
    }
}
