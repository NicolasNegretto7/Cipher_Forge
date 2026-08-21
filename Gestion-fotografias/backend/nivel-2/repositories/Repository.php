<?php

/**
 * CLASE REPOSITORY (repositorio)  -  clase PADRE
 * ==================================================================
 * ¿QUÉ ES UN REPOSITORY?
 * Es el objeto encargado de buscar y guardar datos. Es la ÚNICA parte
 * del programa que sabe de dónde salen. El resto del código le pide
 * "dame los productos" y no se entera de cómo están guardados.
 *
 * Vas a ver el mismo nombre en Laravel y en Symfony (ProductRepository).
 * También vas a escuchar "DAO" (Data Access Object), que es el nombre
 * que le pone el mundo Java a la misma idea.
 *
 * ------------------------------------------------------------------
 * ACÁ APARECE LA HERENCIA.
 *
 * UserRepository y ProductRepository necesitan las dos lo mismo: una
 * conexión a la base para poder hacer sus consultas. En vez de que
 * cada una abra la suya, lo escribimos UNA sola vez acá, en la clase
 * padre, y las dos clases hijas lo heredan:
 *
 *     class UserRepository extends Repository { ... }
 *
 * "extends" = "hereda de". La clase hija recibe gratis $this->db, ya
 * conectado, sin tener que escribir un constructor propio.
 *
 * ------------------------------------------------------------------
 * OJO: esta clase NO se usa sola. Nunca vamos a escribir
 * "new Repository()", porque por sí sola no busca ninguna tabla en
 * particular. Solo existe para que las hijas la hereden.
 * ==================================================================
 */
class Repository
{
    /**
     * protected = la ven esta clase Y sus hijas, pero nadie de afuera.
     * (private sería solo esta clase; public sería todo el mundo).
     */
    protected PDO $db;

    public function __construct()
    {
        $this->db = Database::connection();
    }
}
