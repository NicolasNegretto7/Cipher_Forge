<?php

/**
 * CONFIGURACIÓN
 * ==================================================================
 * Acá van los valores que pueden cambiar según la computadora donde
 * corra la API. Usamos constantes (define) porque se pueden leer desde
 * cualquier archivo, sin tener que pasarlas de una función a otra.
 *
 * Por convención, las constantes se escriben EN MAYÚSCULAS.
 *
 * ------------------------------------------------------------------
 * ¿QUÉ ES UN ".env" Y PARA QUÉ SIRVE?
 *
 * Es un archivo de texto con pares "CLAVE=valor", uno por línea, que
 * vive en la raíz del proyecto (mirá ".env" al lado de este archivo).
 * Ahí van los datos que:
 *
 *   a) son SECRETOS (la clave para firmar tokens, la contraseña de
 *      la base de datos), o
 *   b) CAMBIAN según la computadora (en tu máquina la base se llama
 *      distinto que en la del profesor, o en el servidor real).
 *
 * La regla es simple: el .env NUNCA se sube a git (mirá el
 * .gitignore). Lo que sí se sube es ".env.example", una copia sin
 * los valores reales, que le muestra a cualquiera que baje el
 * proyecto QUÉ variables necesita definir.
 *
 * ¿Por qué importa? Si la clave secreta estuviera escrita adentro
 * del código (como estaba antes acá mismo) y el código se sube a un
 * repositorio público, cualquiera que lo vea puede fabricar tokens
 * JWT válidos, incluso de administrador. Sacándola al .env, el
 * secreto vive solo en la computadora de cada uno.
 *
 * PHP no trae de fábrica un lector de .env (proyectos grandes usan
 * una librería, "vlucas/phpdotenv"), pero el formato es tan simple
 * que alcanza con leer el archivo línea por línea. Eso es lo que
 * hace loadEnv() acá abajo.
 * ==================================================================
 */

/**
 * loadEnv(): LEE UN ARCHIVO .env LÍNEA POR LÍNEA
 * ==================================================================
 * Esta función es genérica: no sabe nada de tokens ni de esta API en
 * particular, solo sabe leer archivos con formato "CLAVE=valor". Por
 * eso la pueden copiar y pegar tal cual al inicio de CUALQUIER otro
 * proyecto PHP que quieran armar, y ya van a tener soporte de .env.
 *
 * Lo que hace, paso a paso:
 *
 *   1. Si el archivo no existe, no hace nada (return) y listo. Así
 *      el proyecto no explota si alguien todavía no creó su .env;
 *      simplemente van a valer los defaults que pusimos más abajo.
 *
 *   2. file(...) lee el archivo y devuelve un arreglo con una línea
 *      por posición. Los dos flags le piden que no incluya el salto
 *      de línea de cada renglón y que se salte las líneas vacías.
 *
 *   3. Por cada línea:
 *        - si empieza con "#", es un comentario: la ignoramos.
 *        - si no, la partimos en dos por el PRIMER "=" que aparece
 *          (el límite 2 de explode() es justamente para eso: si el
 *          VALOR tuviera un "=" adentro, no se rompe el parseo).
 *
 *   4. putenv() y $_ENV son dos formas que tiene PHP de guardar una
 *      variable de entorno. Las llenamos las DOS por compatibilidad:
 *      según cómo esté configurado el servidor, getenv() puede leer
 *      de una o de la otra. Guardando en ambas, siempre funciona.
 *
 * Después de llamar a loadEnv() una sola vez (ver la línea de abajo),
 * cualquier archivo del proyecto puede leer esos valores con
 * getenv('SECRET_KEY'), o mejor, con el helper env() que definimos
 * a continuación.
 *
 * @param string $path ruta al archivo .env
 */
function loadEnv(string $path): void
{
    if (!file_exists($path)) {
        return;
    }

    foreach (file($path, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) as $line) {
        $line = trim($line);

        if ($line === '' || str_starts_with($line, '#')) {
            continue;
        }

        [$key, $value] = array_pad(explode('=', $line, 2), 2, '');

        $key   = trim($key);
        $value = trim($value);

        putenv("$key=$value");
        $_ENV[$key] = $value;
    }
}

// La llamamos UNA vez, apenas arranca la app, antes de leer ninguna
// variable. A partir de acá, getenv() ya "conoce" todo lo del .env.
loadEnv(__DIR__ . '/.env');

/**
 * env(): lee una variable del .env, y si no está, usa un valor por
 * defecto. Así ningún define() de abajo se rompe aunque falte el .env.
 */
function env(string $key, $default = null)
{
    $value = getenv($key);

    return $value === false || $value === '' ? $default : $value;
}

/**
 * APP_ENV indica en qué tipo de entorno está ejecutándose la API.
 *
 * development: entorno local para aprender y depurar. GET / puede mostrar
 *              la lista de endpoints y las cuentas de prueba.
 * production:  servidor público. GET / devuelve información mínima.
 *
 * Usamos production como valor por defecto seguro: si alguien se olvida de
 * configurar APP_ENV en un servidor, la API no publica la ayuda de desarrollo.
 */
$appEnv = strtolower((string) env('APP_ENV', 'production'));

// Solo aceptamos estos dos valores para detectar errores de escritura rápido.
if (!in_array($appEnv, ['development', 'production'], true)) {
    die('APP_ENV debe ser development o production.');
}

define('APP_ENV', $appEnv);

// Clave secreta para firmar los tokens. Sale del .env; jamás del código.
define('SECRET_KEY', env('SECRET_KEY'));

/**
 * FALLA RÁPIDO (fail fast) si falta la clave o quedó con el valor de
 * ejemplo. Preferimos que la API no arranque a que arranque insegura
 * sin que nadie se dé cuenta.
 */
if (!SECRET_KEY || SECRET_KEY === 'cambiame-por-una-clave-generada-al-azar') {
    die('Falta configurar SECRET_KEY en el archivo .env (mirá .env.example).');
}

// Cuánto dura el token, en segundos (3600 = 1 hora). No es una sesión
// de PHP: acá no hay session_start() ni $_SESSION en ningún lado.
define('TOKEN_LIFETIME', (int) env('TOKEN_LIFETIME', 3600));

/**
 * Origen autorizado para que el frontend use la cookie con CORS.
 * env() lee FRONTEND_ORIGIN del .env o usa localhost:5173 por defecto.
 * rtrim(..., '/') quita una barra final para comparar orígenes exactamente.
 * define() crea una constante accesible desde index.php.
 */
define('FRONTEND_ORIGIN', rtrim(env('FRONTEND_ORIGIN', 'http://localhost:5173'), '/'));

/**
 * Datos de conexión a MySQL. Los usa core/Database.php para armar
 * la conexión PDO. Mirá database.sql para crear la base y las
 * tablas con estos mismos datos.
 */
define('DB_HOST', env('DB_HOST', 'localhost'));
define('DB_NAME', env('DB_NAME', 'utu_demo'));
define('DB_USER', env('DB_USER', 'root'));
define('DB_PASSWORD', env('DB_PASSWORD', ''));
