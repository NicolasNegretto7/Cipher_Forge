<?php

/**
 * CLASE USER (usuario)
 * ==================================================================
 * Esta es la POO más clásica que hay, la del primer día:
 *
 *   - PROPIEDADES privadas  -> los datos del objeto
 *   - CONSTRUCTOR           -> se ejecuta al hacer "new User(...)"
 *   - GETTERS               -> métodos para leer esos datos desde afuera
 *   - MÉTODOS propios       -> lo que el objeto sabe hacer
 *
 * ¿Por qué las propiedades son PRIVADAS?
 * Porque así nadie de afuera puede escribir cualquier cosa adentro del
 * objeto. Si $passwordHash fuera pública, alguien podría hacer:
 *
 *     $user->passwordHash = '123';     // ¡desastre!
 *
 * Con private, la única forma de trabajar con la contraseña es a través
 * de los métodos que nosotros escribimos. A eso se le llama
 * ENCAPSULAMIENTO: el objeto protege sus propios datos.
 * ==================================================================
 */
class User
{
    // Las propiedades: qué datos tiene un usuario.
    private int $id;
    private string $name;
    private string $email;
    private string $passwordHash;   // la contraseña, pero encriptada
    private string $role;
    private bool $active;

    /**
     * CONSTRUCTOR
     * Se ejecuta solo cuando hacemos:  new User(1, 'Ana', ...)
     * $this se refiere al objeto que se está creando.
     */
    public function __construct($id, $name, $email, $passwordHash, $role, $active)
    {
        $this->id           = $id;
        $this->name         = $name;
        $this->email        = $email;
        $this->passwordHash = $passwordHash;
        $this->role         = $role;
        $this->active       = $active;
    }

    // ------------------------------------------------------------------
    // GETTERS: dejan LEER los datos, pero no modificarlos.
    // ------------------------------------------------------------------

    public function getId()
    {
        return $this->id;
    }

    public function getName()
    {
        return $this->name;
    }

    public function getEmail()
    {
        return $this->email;
    }

    public function getRole()
    {
        return $this->role;
    }

    public function isActive()
    {
        return $this->active;
    }

    /**
     * Fijate que NO hay un getPasswordHash().
     * La contraseña entra al objeto y no sale nunca más.
     */

    // ------------------------------------------------------------------
    // MÉTODOS: lo que el usuario sabe hacer.
    // ------------------------------------------------------------------

    /**
     * ¿Es correcta esta contraseña?
     *
     * password_verify() agarra lo que escribió la persona, lo encripta
     * igual que el original y compara. Nunca comparamos con == , y
     * NUNCA se puede desencriptar un hash: va en un solo sentido.
     */
    public function checkPassword($plainPassword)
    {
        return password_verify($plainPassword, $this->passwordHash);
    }

    /**
     * Convierte el objeto en un arreglo, para poder mandarlo como JSON.
     *
     * ¡IMPORTANTE! Acá NO va la contraseña. Una API nunca devuelve
     * contraseñas, ni siquiera encriptadas.
     *
     * (Los nombres de los campos van en español porque son el "contrato"
     * de nuestra API: es lo que ven los que la consumen.)
     */
    public function toArray()
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
