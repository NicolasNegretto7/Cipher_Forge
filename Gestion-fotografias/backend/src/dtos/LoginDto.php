<?php
// QUÉ: DTO que transporta los datos validados de un login.
// POR QUÉ: Mismo patrón que RegisterDto — objeto tipado en vez de array crudo.

declare(strict_types=1);

namespace App\dtos;

class LoginDto
{
    public function __construct(
        public readonly string $email,
        public readonly string $password,
    ) {}
}