<?php

declare(strict_types=1);

namespace App\Core;
use PDO;
use RuntimeException;


class Database{

        private string $host;
        private string $user;
        private string $password;
        private string $port;
        private string $name;
        private string $charset;
        private ?PDO $connection = null;



public function __construct(
    ?string $host = null,
    ?string $user = null,
    ?string $password = null,
    ?string $port = null,
    ?string $name = null,
    ?string $charset = null,

)

{
    // Valores NO secretos: pueden tener un default razonable (red interna de Docker).
    $this->host = self::env('DB_HOST', $host, 'db');
    $this->user = self::env('DB_USER', $user, 'cipher_user');
    $this->port = self::env('DB_PORT', $port, '3306');
    $this->name = self::env('DB_NAME', $name, 'cipher_forge');
    $this->charset = self::env('DB_CHARSET', $charset, 'utf8mb4');

    // C-03: la contraseña NUNCA tiene un valor por defecto. Debe venir por entorno
    // (DB_PASS) o por parámetro explícito; así se elimina el fallback inseguro
    // 'cipher_password' que permitía conectar con credenciales conocidas.
    $clave = getenv('DB_PASS');
    if (is_string($clave) && $clave !== '') {
        $this->password = $clave;
    } elseif (is_string($password) && $password !== '') {
        $this->password = $password;
    } else {
        throw new RuntimeException('Falta la variable de entorno DB_PASS (contraseña de la base de datos).');
    }
}

/** Devuelve la variable de entorno si está definida; si no, el valor recibido o el default. */
private static function env(string $var, ?string $valor, string $default): string
{
    $env = getenv($var);
    if (is_string($env) && $env !== '') {
        return $env;
    }
    return $valor !== null && $valor !== '' ? $valor : $default;
}

public function getConnection(): PDO
    {
        if($this->connection !==null){
            
            return $this->connection;
        }
    $dsn = "mysql:host={$this->host};dbname={$this->name};port={$this->port};charset={$this->charset}";

    $options = [
    PDO::ATTR_ERRMODE=> PDO::ERRMODE_EXCEPTION,
    
    PDO::ATTR_DEFAULT_FETCH_MODE=> PDO::FETCH_ASSOC,
    
    PDO::ATTR_EMULATE_PREPARES=> false,
    ];
$this->connection = new PDO($dsn, $this->user, $this->password, $options);
    return $this->connection;
    }


}
