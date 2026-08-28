<?php

/**
 * SERVICE DE AUTENTICACIÓN
 * ==================================================================
 * Las reglas de "quién puede entrar al sistema":
 *
 *   - el email no se puede repetir
 *   - la contraseña se guarda encriptada, nunca como la escribieron
 *   - el que se registra solo es siempre rol "usuario"
 *   - una cuenta deshabilitada no puede entrar
 * ==================================================================
 */
class AuthService
{
    private UserRepository $repository;

    public function __construct()
    {
        $this->repository = new UserRepository();
    }

    /**
     * Registrar una cuenta nueva.
     * "RegisterDTO $dto" es un TYPE HINT: PHP exige recibir ese tipo de objeto.
     */
    public function register(RegisterDTO $dto)
    {
        // Los getters leen los datos privados que transporta el DTO.
        // REGLA: el email es único.
        if ($this->repository->findByEmail($dto->getEmail()) !== null) {
            Response::error('Ya existe una cuenta con ese email.', 400);
        }

        /**
         * REGLA: la contraseña se guarda encriptada.
         * password_hash() la convierte en algo que NO se puede volver
         * atrás. Si mañana nos roban los datos, las contraseñas siguen
         * protegidas.
         *
         * Y ojo con esto: el rol lo ponemos nosotros ('usuario', dentro
         * del repository). Si lo aceptáramos del pedido, cualquiera se
         * registraría como admin.
         */
        $passwordHash = password_hash($dto->getPassword(), PASSWORD_DEFAULT);

        $user = $this->repository->create(
            $dto->getName(),
            $dto->getEmail(),
            $passwordHash
        );

        return $user->toArray();
    }

    /**
     * Iniciar sesión: verifica la contraseña y entrega el token al controller.
     * LoginDTO garantiza un contrato claro: email y contraseña ya validados.
     */
    public function login(LoginDTO $dto)
    {
        $user = $this->repository->findByEmail($dto->getEmail());

        /**
         * DETALLE DE SEGURIDAD:
         * el mensaje es el mismo si el email no existe o si la
         * contraseña está mal. Si dijéramos "ese email no existe", le
         * estaríamos regalando a un atacante la lista de qué emails
         * están registrados en el sistema.
         */
        if ($user === null || !$user->checkPassword($dto->getPassword())) {
            Response::error('Email o contraseña incorrectos.', 401);
        }

        // REGLA: una cuenta deshabilitada no entra.
        if (!$user->isActive()) {
            Response::error('Tu cuenta está deshabilitada.', 403);
        }

        // El token solo viaja hasta AuthController; allí se coloca en la cookie
        // y se elimina de este arreglo antes de crear la respuesta JSON.
        return [
            'token'   => Token::create($user),
            'usuario' => $user->toArray(),
        ];
    }

    /**
     * Los datos de un usuario.
     */
    public function getProfile($id)
    {
        $user = $this->repository->findById($id);

        if ($user === null) {
            Response::error('El usuario ya no existe.', 404);
        }

        return $user->toArray();
    }
}
