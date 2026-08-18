<?php


namespace App\public;
use App\config\Database;
use PDOException;
use PDO;
$method = $_SERVER['REQUEST_METHOD'];
$uri = parse_url($_SERVER['REQUEST_URI'],PHP_URL_PATH);

$uri = trim($uri, '/');

    function jsonResponse($data, $status =200){
    http_response_code($status);
    header('Content-Type: application/json');
    echo json_encode($data, JSON_PRETTY_PRINT);
    exit;
}

    

if($method === 'POST' && $uri === 'auth/login'){
    $input = json_decode(file_get_contents('php://input'), true);
    

    if(empty($input['email']) || empty($input['hash_password'])){
        jsonResponse(['error' => 'Faltan email o contraseña'], 400);
    }

    try{
        $pdo = (new Database())->connect();
        $stmt = $pdo->prepare("SELECT * FROM usuario WHERE email = :email");
        $stmt->execute([''])
$login = $stmt->fetchAll(PDO::FETCH_ASSOC);
jsonResponse($login);
    }

    catch(PDOException $e){
jsonResponse(['error' => 'Error al loguearte'], 500);
    }
}









if($method === 'POST' && $uri === 'auth/login'){
    $input = json_decode(file_get_contents('php://input'), true);
    

    if(empty($input['email']) || empty($input['hash_password'])){
        jsonResponse(['error' => 'Faltan email o contraseña'], 400);
    }

    try{
        $pdo = (new Database())->connect();
        $stmt = $pdo->prepare("INSERT INTO FROM usuario('nombre_completo','email','password_hash','rol') VALUES(:nombre_completo,:email,:password_hash,:rol)");
$login = $stmt->fetchAll(PDO::FETCH_ASSOC);
jsonResponse($login);
    }

    catch(PDOException $e){
jsonResponse(['error' => 'Error al loguearte'], 500);
    }
}