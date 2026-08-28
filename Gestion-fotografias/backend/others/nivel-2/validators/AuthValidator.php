<?php

/**
 * VALIDADOR DE AUTENTICACIÓN
 * ==================================================================
 * Un VALIDADOR revisa la forma de los datos que llegan desde HTTP.
 * No busca usuarios, no consulta la base y no crea respuestas: solo
 * devuelve una lista de errores para que el controller decida qué hacer.
 *
 * PALABRAS CLAVE QUE APARECEN EN ESTA CLASE:
 *
 *   public   -> el método se puede llamar desde otra clase.
 *   static   -> se llama con AuthValidator::metodo(), sin usar "new".
 *   function -> declara un método.
 *   array    -> exige o devuelve un arreglo de PHP.
 *   return   -> termina el método y entrega un resultado.
 * ==================================================================
 */
class AuthValidator
{
    /**
     * Valida exclusivamente POST /registro.
     *
     * "array $data" exige que $data sea un arreglo.
     * ": array" promete que el resultado también será un arreglo.
     */
    public static function validateRegister(array $data): array
    {
        // [] crea un arreglo vacío. Acá acumularemos todos los errores.
        $errors = [];

        /**
         * ?? es el operador "fusión de null". Lee el valor de la
         * izquierda si existe; si no existe, usa el de la derecha.
         * Así evitamos el aviso "Undefined array key".
         */
        $name = $data['nombre'] ?? '';
        $email = $data['email'] ?? '';
        $password = $data['clave'] ?? '';

        // El operador ! niega una condición. || significa "O".
        // is_string() controla que el dato sea texto.
        // trim() quita espacios de los extremos y strlen() cuenta caracteres.
        if (!is_string($name) || strlen(trim($name)) < 3) {
            // [] después de una variable agrega un elemento al final del arreglo.
            $errors[] = 'El nombre tiene que tener al menos 3 letras.';
        }

        // filter_var() con FILTER_VALIDATE_EMAIL aplica el validador de email de PHP.
        if (!is_string($email) || !filter_var(trim($email), FILTER_VALIDATE_EMAIL)) {
            $errors[] = 'El email no es válido.';
        }

        // La contraseña no se recorta: los espacios podrían formar parte de ella.
        if (!is_string($password) || strlen($password) < 6) {
            $errors[] = 'La contraseña tiene que tener al menos 6 caracteres.';
        }

        // Si todo estaba bien devuelve []; si no, devuelve todos los mensajes.
        return $errors;
    }

    /** Valida exclusivamente POST /login. */
    public static function validateLogin(array $data): array
    {
        $errors = [];

        // isset() pregunta si la posición existe y su valor no es null.
        // === compara valor Y tipo; por eso '' significa texto realmente vacío.
        if (!isset($data['email']) || !is_string($data['email']) || trim($data['email']) === '') {
            $errors[] = 'Falta el email.';
        }

        if (!isset($data['clave']) || !is_string($data['clave']) || $data['clave'] === '') {
            $errors[] = 'Falta la contraseña.';
        }

        return $errors;
    }
}
