<?php

/**
 * DTO DE REGISTRO (Data Transfer Object)
 * ==================================================================
 * DTO significa "Data Transfer Object": objeto para transferir datos.
 * Su trabajo es tomar la entrada que ya aprobó el validator, darle una
 * FORMA conocida, NORMALIZARLA, TIPARLA y transportarla al service.
 * Así el service recibe un objeto con un contrato claro, en vez del
 * arreglo crudo que llegó desde HTTP.
 *
 * Este DTO conserva únicamente nombre, email y contraseña. Quita los
 * espacios del nombre, normaliza el email a minúsculas y guarda los tres
 * valores en propiedades de tipo string.
 *
 * El orden importa: primero AuthValidator valida; después el controller
 * crea el DTO. El DTO NO decide si los datos son válidos, no consulta la
 * base, no aplica reglas del negocio y no responde HTTP.
 * ==================================================================
 */
class RegisterDTO
{
    // private impide modificar estas propiedades directamente desde afuera.
    // string obliga a que cada una contenga texto.
    private string $name;
    private string $email;
    private string $password;

    /**
     * __construct es el método que se ejecuta al hacer:
     *     new RegisterDTO($data)
     */
    public function __construct(array $data)
    {
        // $this representa al objeto que se está construyendo.
        // -> permite acceder a una propiedad o método de ese objeto.
        $this->name = trim($data['nombre']);

        // strtolower() normaliza el email a minúsculas.
        $this->email = strtolower(trim($data['email']));

        // La contraseña se transporta sin trim para no cambiarla.
        $this->password = $data['clave'];
    }

    // Los getters permiten leer propiedades privadas sin poder cambiarlas.
    // : string declara que cada getter siempre devuelve texto.
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
