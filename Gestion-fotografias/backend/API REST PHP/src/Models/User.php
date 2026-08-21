<?php

declare(strict_types=1);

namespace App\Models;

/**
 * ENTIDAD DE DOMINIO: USUARIO
 * ==============================================================================
 * WHAT: Modela un usuario del sistema encapsulando sus propiedades y protegiendo
 *       su información confidencial (como el hash de la contraseña).
 * WHY:  El principio de encapsulamiento impide la mutación no controlada de los
 *       datos. No se incluye un getter para `passwordHash`, obligando a usar
 *       `checkPassword()` para verificar credenciales de forma segura.
 * ==============================================================================
 */
class User
{
    private int $id;
    private string $name;
    private string $email;
    private string $passwordHash;
    private string $role;
    private bool $active;

    public function __construct(
        int $id,
        string $name,
        string $email,
        string $passwordHash,
        string $role = 'usuario',
        bool $active = true
    ) {
        $this->id           = $id;
        $this->name         = $name;
        $this->email        = $email;
        $this->passwordHash = $passwordHash;
        $this->role         = $role;
        $this->active       = $active;
    }

    public function getId(): int
    {
        return $this->id;
    }

    public function getName(): string
    {
        return $this->name;
    }

    public function getEmail(): string
    {
        return $this->email;
    }

    public function getRole(): string
    {
        return $this->role;
    }

    public function isActive(): bool
    {
        return $this->active;
    }

    /**
     * Comprueba si la contraseña enviada en texto plano coincide con el hash almacenado.
     *
     * @param string $plainPassword Contraseña a verificar.
     * @return bool True si la contraseña es correcta.
     */
    public function checkPassword(string $plainPassword): bool
    {
        return password_verify($plainPassword, $this->passwordHash);
    }

    /**
     * Exporta la entidad a array asociativo para serialización JSON pública.
     * NOTA: Jamás se incluye el hash de la contraseña en la salida pública.
     *
     * @return array<string, mixed>
     */
    public function toArray(): array
    {
        return [
            'id'     => $this->id,
            'nombre' => $this->name,
            'email'  => $this->email,
            'rol'    => $this->role,
            'activo' => $this->active,
        ];
    }
}
