<?php

declare(strict_types=1);

namespace App\Core;

use PDO;
use PDOException;

/**
 * GESTOR DE CONEXIÓN A BASE DE DATOS (PDO SINGLETON)
 * ==============================================================================
 * WHAT: Administra y provee una única instancia de conexión PDO compartida
 *       durante el ciclo de vida de la petición HTTP.
 * WHY:  El patrón Singleton evita la sobrecarga de abrir múltiples sockets TCP
 *       contra el motor MySQL en una misma solicitud. Configura además modo
 *       estricto de errores (`ERRMODE_EXCEPTION`) y desactiva prepares emulados
 *       para prevenir inyecciones SQL en el protocolo binario.
 * ==============================================================================
 */
class Database
{
    private static ?PDO $connection = null;

    /**
     * Retorna la conexión activa a MySQL o crea una nueva si aún no existe.
     *
     * @return PDO Conexión PDO lista para ejecutar Prepared Statements.
     * @throws PDOException Si las credenciales o el host son incorrectos.
     */
    public static function connection(): PDO
    {
        if (self::$connection === null) {
            $dsn = 'mysql:host=' . DB_HOST . ';port=' . DB_PORT . ';dbname=' . DB_NAME . ';charset=utf8mb4';

            self::$connection = new PDO($dsn, DB_USER, DB_PASSWORD, [
                // Fuerza a PDO a lanzar excepciones PDOException ante cualquier fallo en una query
                PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,

                // Devuelve únicamente arrays asociativos ['columna' => valor]
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,

                // Desactiva la emulación en PHP y fuerza sentencias preparadas nativas en MySQL
                PDO::ATTR_EMULATE_PREPARES   => false,
            ]);
        }

        return self::$connection;
    }
}
