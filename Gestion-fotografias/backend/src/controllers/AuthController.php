<?php

declare(strict_types=1);

namespace App\controllers;
use App\Core\Response;
use App\Core\Request;
use App\services\AuthService;
use App\validators\AuthValidator;
use App\dtos\RegisterDto;
use App\dtos\LoginDto;

class AuthController{

    private AuthService $authService;

    public function __construct(){
        $this->authService = new AuthService();
    }
    


    public static function register(Request $request): void{
    }

}