<?php

declare(strict_types=1);

namespace App\DTOs;

/**
 * DTO DE REGISTRO DE USUARIO (DATA TRANSFER OBJECT)
 * ==============================================================================
 * WHAT: Transporta y normaliza los datos validados requeridos para registrar un usuario.
 * WHY:  Garantiza que la capa de servicio (AuthService) reciba un objeto tipado
 *       inmutable con propiedades limpias en lugar de un array asociativo crudo.
 * ==============================================================================
 */
class RegisterDTO
{
    private string $name;
    private string $email;
    private string $password;

    public function __construct(array $data)
    {
        $this->name     = trim((string) ($data['nombre'] ?? ''));
        $this->email    = strtolower(trim((string) ($data['email'] ?? '')));
        $this->password = (string) ($data['clave'] ?? '');
    }

    public function getName(): string
    {
        return $this->name;
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
