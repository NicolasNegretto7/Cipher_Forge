<?php

declare(strict_types=1);

namespace Config;

use PDO;
use PDOException;

/**
 * Gestor de conexión a base de datos mediante PDO.
 * 
 * Configura una conexión persistente y segura hacia MySQL
 * con soporte para variables de entorno (Docker/Local).
 */
class Database
{
    private string $host;
    private string $port;
    private string $dbName;
    private string $username;
    private string $password;
    private string $charset;
    private ?PDO $connection = null;

    public function __construct(
        string $host = '127.0.0.1',
        string $port = '3306',
        string $dbName = 'cipher_forge',
        string $username = 'root',
        string $password = '',
        string $charset = 'utf8mb4'
    ) {
        // Permite sobrescribir mediante variables de entorno (ej. en Docker host='db')
        $this->host = getenv('DB_HOST') ?: $host;
        $this->port = getenv('DB_PORT') ?: $port;
        $this->dbName = getenv('DB_NAME') ?: $dbName;
        $this->username = getenv('DB_USER') ?: $username;
        $this->password = getenv('DB_PASS') !== false ? (string) getenv('DB_PASS') : $password;
        $this->charset = getenv('DB_CHARSET') ?: $charset;
    }

    /**
     * Obtiene la instancia activa de PDO.
     * 
     * @return PDO Instancia de conexión lista para ejecutar consultas.
     * @throws PDOException Si falla la conexión con el servidor MySQL.
     */
    public function getConnection(): PDO
    {
        if ($this->connection !== null) {
            return $this->connection;
        }

        $dsn = "mysql:host={$this->host};port={$this->port};dbname={$this->dbName};charset={$this->charset}";

        $options = [
            PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION, // Lanza excepciones en fallos SQL
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,       // Retorna arrays asociativos
            PDO::ATTR_EMULATE_PREPARES   => false,                  // Fuerza sentencias preparadas nativas
        ];

        $this->connection = new PDO($dsn, $this->username, $this->password, $options);

        return $this->connection;
    }
}
