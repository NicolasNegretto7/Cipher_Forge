<?php

/**
 * Estas dos líneas traen las clases de la librería firebase/php-jwt.
 *
 * ¿Por qué hacen falta? Porque las librerías guardan sus clases dentro
 * de un NAMESPACE (una especie de apellido) para que no choquen con las
 * nuestras. La clase completa se llama "Firebase\JWT\JWT".
 *
 * Con "use" le decimos a PHP: "cuando escriba JWT, me refiero a esa".
 * Es como agendar un contacto para no tener que marcar el número entero.
 */

use Firebase\JWT\JWT;
use Firebase\JWT\Key;

/**
 * CLASE TOKEN (JWT - JSON Web Token)
 * ==================================================================
 * EL PROBLEMA QUE RESUELVE
 *
 * HTTP no tiene memoria: cada pedido es independiente y el servidor no
 * se acuerda de quién sos. Entonces, después del login, ¿cómo sabemos
 * en el pedido siguiente que ya te habías logueado?
 *
 * LA SOLUCIÓN
 *
 * Cuando el login sale bien, el servidor crea un TOKEN firmado y lo
 * guarda en una cookie HttpOnly. El navegador conserva esa cookie y la
 * manda automáticamente en los pedidos siguientes. JavaScript no puede
 * leerla ni modificarla.
 *
 * ------------------------------------------------------------------
 * ¿CÓMO ES UN TOKEN POR DENTRO?
 *
 * Tres partes separadas por puntos:
 *
 *     encabezado . datos . firma
 *
 * ¡OJO! Las dos primeras partes NO están encriptadas, solo están en
 * Base64. Cualquiera las puede leer (probá pegando un token en jwt.io).
 *
 *   => NUNCA se guarda la contraseña adentro del token.
 *
 * Entonces, ¿para qué sirve? Para que nadie lo pueda MODIFICAR. Si un
 * usuario cambia "rol":"usuario" por "rol":"admin", la firma ya no
 * coincide, porque para recalcularla necesita la clave secreta que solo
 * tiene el servidor. El token queda inválido.
 *
 * ==================================================================
 * ¿QUIÉN HACE EL TRABAJO ACÁ?
 *
 * La librería **firebase/php-jwt**, que es la que usa todo el mundo en
 * PHP para esto. La instalamos con Composer y quedó en vendor/.
 * Ella arma las tres partes, calcula la firma y controla el vencimiento.
 *
 * ¿Y por qué no lo escribimos nosotros, si son 30 líneas?
 * Porque en seguridad, "casi bien" es igual a "mal". Un detalle chico
 * (comparar la firma con == en vez de en tiempo constante, aceptar el
 * algoritmo "none", olvidarse de mirar el vencimiento) deja la puerta
 * abierta. Esa librería la revisaron y la atacaron miles de personas
 * durante años. Nuestro código, no.
 *
 * REGLA GENERAL: la seguridad no se improvisa. Contraseñas, tokens y
 * encriptación se hacen con herramientas ya probadas.
 *
 * ------------------------------------------------------------------
 * ESTA CLASE SIGUE EXISTIENDO IGUAL, Y ES A PROPÓSITO.
 *
 * Podríamos llamar a JWT::encode() directamente desde el service, pero
 * entonces la librería quedaría desparramada por todo el proyecto. Así,
 * si algún día cambiamos de librería, se toca SOLO este archivo.
 *
 * A esto se le llama "envolver" una librería (wrapper): nuestro código
 * le habla a Token, y Token es el único que le habla a la librería.
 * ==================================================================
 */
class Token
{
    /** Algoritmo de firma. HS256 = HMAC con SHA-256 y una clave secreta. */
    private const ALGORITHM = 'HS256';

    // const declara un valor que no cambia. private lo oculta fuera de Token.
    // Este nombre identifica la cookie tanto al guardarla como al leerla.
    private const COOKIE_NAME = 'access_token';

    /**
     * Crea un token para un usuario que acaba de loguearse.
     */
    public static function create(User $user): string
    {
        // Los datos que van adentro del token. Solo lo necesario,
        // y NADA sensible (acordate de que se pueden leer).
        $payload = [
            'id'     => $user->getId(),
            'nombre' => $user->getName(),
            'rol'    => $user->getRole(),
            'iat'    => time(),                    // cuándo se emitió
            'exp'    => time() + TOKEN_LIFETIME,   // cuándo vence
        ];

        // Una sola línea: arma las tres partes y las firma.
        return JWT::encode($payload, SECRET_KEY, self::ALGORITHM);
    }

    /**
     * Guarda el JWT en una cookie que JavaScript no puede leer.
     *
     * "string $token" exige texto. ": void" indica que el método no
     * devuelve un valor: su efecto es agregar Set-Cookie a la respuesta HTTP.
     */
    public static function sendCookie(string $token): void
    {
        /**
         * setcookie() NO modifica inmediatamente el navegador. PHP agrega
         * una cabecera HTTP "Set-Cookie" a la respuesta y el navegador la
         * procesa al recibirla. Debe llamarse antes de imprimir el JSON.
         *
         * Las opciones significan:
         *
         * expires  -> fecha de vencimiento expresada como timestamp Unix.
         * path     -> '/' permite enviarla a todos los endpoints de la API.
         * secure   -> con true solo viaja mediante HTTPS.
         * httponly -> impide leerla con JavaScript/document.cookie.
         * samesite -> Lax reduce el envío desde sitios externos y ayuda
         *             a proteger contra ataques CSRF.
         */
        setcookie(self::COOKIE_NAME, $token, [
            // time() devuelve el instante actual en segundos.
            'expires'  => time() + TOKEN_LIFETIME,
            'path'     => '/',
            // self::isHttps() llama a un método privado de esta misma clase.
            'secure'   => self::isHttps(),
            'httponly' => true,
            'samesite' => 'Lax',
        ]);
    }

    /**
     * Elimina la cookie al cerrar sesión.
     * También devuelve void porque su resultado es una cabecera HTTP.
     */
    public static function clearCookie(): void
    {
        // Para borrar una cookie se vuelve a enviar con el mismo nombre y
        // opciones, pero vacía y con una fecha ubicada en el pasado.
        setcookie(self::COOKIE_NAME, '', [
            'expires'  => time() - 3600,
            'path'     => '/',
            'secure'   => self::isHttps(),
            'httponly' => true,
            'samesite' => 'Lax',
        ]);

        /**
         * setcookie() le pide al NAVEGADOR que la borre en la respuesta.
         * unset() elimina además el valor del arreglo PHP de ESTA petición.
         * $_COOKIE es la variable superglobal donde PHP coloca las cookies
         * que llegaron desde el navegador.
         */
        unset($_COOKIE[self::COOKIE_NAME]);
    }

    /**
     * Lee el token que vino en el pedido y lo valida.
     *
     * Devuelve los datos del usuario si el token es válido,
     * o null si no hay token, está vencido o está adulterado.
     */
    public static function read(): ?array
    {
        // El tipo ?array significa que el método devuelve un arreglo o null.
        // El operador ?? usa null cuando la cookie no fue enviada.
        $token = $_COOKIE[self::COOKIE_NAME] ?? null;

        if ($token === null) {
            return null;
        }

        /**
         * ACÁ APARECE ALGO NUEVO: try / catch.
         *
         * Cuando la librería encuentra un problema, no devuelve false:
         * LANZA UNA EXCEPCIÓN, que es un error que corta la ejecución.
         *
         *   try   -> "intentá hacer esto"
         *   catch -> "y si explota, agarralo acá y seguí"
         *
         * Las que puede lanzar:
         *   SignatureInvalidException -> le tocaron la firma
         *   ExpiredException          -> se venció
         *   BeforeValidException      -> todavía no es válido
         *   UnexpectedValueException  -> está mal formado
         *
         * Como para nosotros todos esos casos significan lo mismo
         * ("este token no sirve"), los agarramos juntos y devolvemos null.
         *
         * Fijate también que le pasamos el algoritmo esperado (HS256).
         * Eso es importante: evita el ataque clásico de mandar un token
         * que dice "alg": "none" para que el servidor no verifique nada.
         */
        try {
            $payload = JWT::decode($token, new Key(SECRET_KEY, self::ALGORITHM));
        } catch (Exception $e) {
            return null;
        }

        // decode() devuelve un objeto (stdClass) y en el resto del
        // proyecto trabajamos con arreglos, así que lo convertimos.
        return (array) $payload;
    }

    /**
     * En HTTPS la cookie viaja marcada como Secure.
     * isset() comprueba si existe la información y !== compara valor y tipo.
     */
    private static function isHttps(): bool
    {
        return isset($_SERVER['HTTPS']) && strtolower($_SERVER['HTTPS']) !== 'off';
    }
}
