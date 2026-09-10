<?php
// QUÉ: DTO que transporta los datos validados de un registro de usuario.
// POR QUÉ: Separa la validación del uso de datos — el controller y service
//           trabajan con un objeto tipado en vez de un array crudo.

declare(strict_types=1);

namespace App\dtos;

class RegisterDto
{
    public function __construct(
        public readonly string  $nombreCompleto,
        public readonly string  $email,
        public readonly string  $password,
        public readonly string  $rol,
        public readonly ?string $telefono = null,
    ) {}
}