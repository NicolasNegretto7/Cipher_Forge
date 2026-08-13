<?php
class Database{



    public function connect(): PDO{
    $host = getenv("DB_HOST");
    $user = getenv("DB_USER");
    $pass = getenv("DB_PASS");
    $port = '3306';
    $name = getenv("DB_NAME");
    $dsn = "mysql:host=$host;dbname=$name;port=$port;charset=utf8mb4";


    $options = [
        PDO::ATTR_ERRMODE=> PDO::ERRMODE_EXCEPTION,
    
    PDO::ATTR_DEFAULT_FETCH_MODE=> PDO::FETCH_ASSOC,
    
    PDO::ATTR_EMULATE_PREPARES=> false,
    ];

try{
$pdo = new PDO($dsn, $user, $pass, $options);

return $pdo;
}catch(PDOException $e){
    error_log("ErrorPDO: " . $e->getMessage());
    exit("Error de conexión con la base de datos.");
}
    }
}