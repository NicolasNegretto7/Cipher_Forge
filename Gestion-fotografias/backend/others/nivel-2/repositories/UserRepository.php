<?php

/**
 * REPOSITORIO DE USUARIOS  (clase HIJA de Repository)
 * ------------------------------------------------------------------
 * Es la única parte del programa que busca y guarda usuarios en la
 * tabla `usuarios`.
 *
 * (Las columnas de la base van en español, igual que los campos del
 * JSON que devuelve la API: son los datos, no el código.)
 */
class UserRepository extends Repository
{
    /**
     * Busca un usuario por email. Se usa en el LOGIN.
     * Devuelve un objeto User, o null si no lo encuentra.
     */
    public function findByEmail($email)
    {
        $sql = 'SELECT * FROM usuarios WHERE email = :email';

        $query = $this->db->prepare($sql);
        $query->execute([':email' => trim($email)]);
        $row = $query->fetch();

        return $row === false ? null : $this->buildUser($row);
    }

    /** Busca un usuario por su id. */
    public function findById($id)
    {
        $sql = 'SELECT * FROM usuarios WHERE id = :id';

        $query = $this->db->prepare($sql);
        $query->execute([':id' => $id]);
        $row = $query->fetch();

        return $row === false ? null : $this->buildUser($row);
    }

    /**
     * Crea un usuario nuevo (registro).
     * Recibe la contraseña YA encriptada.
     */
    public function create($name, $email, $passwordHash)
    {
        $sql = "INSERT INTO usuarios (nombre, email, clave_hash, rol, activo)
                VALUES (:nombre, :email, :clave_hash, 'usuario', 1)";

        $query = $this->db->prepare($sql);
        $query->execute([
            ':nombre'     => $name,
            ':email'      => $email,
            ':clave_hash' => $passwordHash,
        ]);

        // lastInsertId() devuelve el id que le puso la base.
        return $this->findById((int) $this->db->lastInsertId());
    }

    /**
     * Convierte una fila de la base (arreglo) en un OBJETO User.
     *
     * Este pasito es el que separa "los datos crudos de la tabla" de
     * "un objeto con el que se puede trabajar".
     */
    private function buildUser($row)
    {
        return new User(
            $row['id'],
            $row['nombre'],
            $row['email'],
            $row['clave_hash'],
            $row['rol'],
            (bool) $row['activo']
        );
    }
}
