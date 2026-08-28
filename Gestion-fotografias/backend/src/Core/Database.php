<?php

declare(strict_types=1);

namespace App\Core;
use PDO;


class Database{

        private string $host;
        private string $user;
        private string $password;
        private string $port;
        private string $name;
        private string $charset;
        private ?PDO $connection = null;



public function __construct(
    string $host= 'db',
    string $user = 'cipher_user',
    string $password = 'cipher_password',
    string $port = '3306',
    string $name = 'cipher_forge',
    string $charset = 'utf8mb4',
    
    
)

{
    $this->host = getenv("DB_HOST") ?: $host;
    $this->user = getenv("DB_USER") ?: $user;
    $this->password = getenv("DB_PASS") ?: $password;
    $this->port = getenv('DB_PORT') ?: $port;   
    $this->name = getenv("DB_NAME") ?: $name;
    $this->charset = getenv("DB_CHARSET") ?: $charset;
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
