<?php

declare(strict_types=1);

namespace App\DTOs;

/**
 * DTO DE INICIO DE SESIÓN (DATA TRANSFER OBJECT)
 * ==============================================================================
 * WHAT: Transporta y normaliza las credenciales verificadas para autenticación.
 * WHY:  Define un contrato explícito y tipado para la operación de login.
 * ==============================================================================
 */
class LoginDTO
{
    private string $email;
    private string $password;

    public function __construct(array $data)
    {
        $this->email    = strtolower(trim((string) ($data['email'] ?? '')));
        $this->password = (string) ($data['clave'] ?? '');
    }

    public function getEmail(): string
    {
        return $this->email;
    }

    public function getPassword(): string
    {
        return $this->password;
    }
}
