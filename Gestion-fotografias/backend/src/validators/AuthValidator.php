<?php
// QUÉ: Valida los datos crudos del body y retorna un DTO tipado.
// POR QUÉ: Centraliza la validación en un solo lugar — si falla,
//           corta con Response::error() y nunca llega al Service.

declare(strict_types=1);

namespace App\validators;

use App\Core\Response;
use App\dtos\RegisterDto;
use App\dtos\LoginDto;

class AuthValidator
{
    /**
     * Valida los datos de registro y retorna un RegisterDto.
     * Si algún campo falla, responde con 400 y detiene la ejecución.
     */
    public function validateRegister(array $data): RegisterDto
    {
        $errores = [];

        // --- Campos obligatorios ---
        if (empty($data['nombre_completo'])) {
            $errores[] = 'El nombre completo es obligatorio.';
        }

        if (empty($data['email'])) {
            $errores[] = 'El correo electrónico es obligatorio.';
        } elseif (!filter_var($data['email'], FILTER_VALIDATE_EMAIL)) {
            // filter_var con FILTER_VALIDATE_EMAIL valida formato RFC 822
            $errores[] = 'El formato del correo electrónico no es válido.';
        }

        if (empty($data['password'])) {
            $errores[] = 'La contraseña es obligatoria.';
        } elseif (strlen($data['password']) < 8) {
            $errores[] = 'La contraseña debe tener al menos 8 caracteres.';
        }

        if (empty($data['rol'])) {
            $errores[] = 'El rol es obligatorio.';
        } elseif (!in_array($data['rol'], ['fotografo', 'cliente'], true)) {
            // strict comparison para evitar type coercion
            $errores[] = 'El rol debe ser "fotografo" o "cliente".';
        }

        // --- Si hay errores, cortar aquí ---
        if (!empty($errores)) {
            Response::error('Error de validación.', 400, $errores);
        }

        return new RegisterDto(
            nombreCompleto: trim($data['nombre_completo']),
            email:          strtolower(trim($data['email'])),
            password:       $data['password'],
            rol:            $data['rol'],
            telefono:       !empty($data['telefono']) ? trim($data['telefono']) : null,
        );
    }

    /**
     * Valida los datos de login y retorna un LoginDto.
     * Si algún campo falta, responde con 400 y detiene la ejecución.
     */
    public function validateLogin(array $data): LoginDto
    {
        $errores = [];

        if (empty($data['email'])) {
            $errores[] = 'El correo electrónico es obligatorio.';
        }

        if (empty($data['password'])) {
            $errores[] = 'La contraseña es obligatoria.';
        }

        if (!empty($errores)) {
            Response::error('Error de validación.', 400, $errores);
        }

        return new LoginDto(
            email:    strtolower(trim($data['email'])),
            password: $data['password'],
        );
    }
}