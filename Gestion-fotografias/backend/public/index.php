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
    

    if(empty($input['email']) || empty($input['password_hash'])){
        jsonResponse(['error' => 'Faltan email o contraseña'], 400);
    }

    try{
        $pdo = (new Database())->connect();
        $stmt = $pdo->prepare("SELECT * FROM usuario WHERE email = :email");
        $stmt->execute([':email' => $input['email']]);
            $login = $stmt->fetch(PDO::FETCH_ASSOC);


            if(!$login){
                jsonResponse(['error' =>'Credenciales incorrectas', 401]);
            }


            if(!password_verify($input['password_hash'], $login['password_hash'])){
                jsonResponse(['error' => 'Credenciales incorrectas', 401]);
            }
                        jsonResponse($login);

    }
    

    catch(PDOException $e){
        jsonResponse(['error' => 'Error al loguearte'], 500);
    }
}










if($method === 'POST' && $uri === 'auth/register'){
    $input = json_decode(file_get_contents('php://input'), true);
    

    if(empty($input['email']) || empty($input['password_hash'])){
        jsonResponse(['error' => 'Faltan email o contraseña'], 400);
    }

    try{
        $pdo = (new Database())->connect();
        $stmt = $pdo->prepare("INSERT INTO usuario (nombre_completo, email, telefono, password_hash, email_verificado, rol) VALUES(:nombre_completo, :email, :telefono, :password_hash, :email_verificado, :rol) ");
        $stmt->execute([':nombre_completo' => $input['nombre_completo'], ':email' => $input['email'], ':telefono' => $input['telefono'], ':password_hash' => $input['password_hash'], ':email_verificado' => $input['email_verificado'], ':rol' => $input['rol']]);
            $register = $stmt->fetch(PDO::FETCH_ASSOC);
            jsonResponse($register);


            if(!$register){
                jsonResponse(['error' =>'Error al registrarte', 401]);
            }


            if(password_verify($input['password_hash'], $register['password_hash'])){
                jsonResponse(['success' => true, 'message' => 'Usuario registrado exitosamente']);
            }
    }

    catch(PDOException $e){
        jsonResponse(['error' => 'Error al loguearte'], 500);
    }
}