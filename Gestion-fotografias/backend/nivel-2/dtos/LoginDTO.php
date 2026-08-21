<?php

/**
 * DTO DE LOGIN (Data Transfer Object)
 * ==================================================================
 * Un DTO toma datos que el validator ya aprobó, les da una FORMA
 * conocida, los NORMALIZA, los TIPA y los transporta hasta el service.
 * De esta manera, AuthService recibe un contrato claro y no trabaja con
 * el arreglo crudo que llegó desde HTTP.
 *
 * Este DTO conserva solamente el email y la contraseña necesarios para
 * iniciar sesión. Normaliza el email y guarda ambos como string.
 *
 * Primero AuthValidator valida y después el controller crea este DTO.
 * El DTO NO valida, no consulta usuarios, no comprueba la contraseña,
 * no aplica reglas del negocio y no responde HTTP.
 * ==================================================================
 */
class LoginDTO
{
    // Son private para que el DTO no se pueda modificar libremente.
    private string $email;
    private string $password;

    // array $data indica que el constructor solo acepta un arreglo.
    public function __construct(array $data)
    {
        // $this->email es la propiedad del objeto; $data['email'] es la entrada.
        $this->email = strtolower(trim($data['email']));
        $this->password = $data['clave'];
    }

    // Los getters exponen los datos de manera controlada.
    public function getEmail(): string
    {
        return $this->email;
    }

    public function getPassword(): string
    {
        return $this->password;
    }
}
