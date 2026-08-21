<?php

declare(strict_types=1);

/**
 * CONFIGURACIÓN CENTRALIZADA Y CARGADOR DE ENTORNO
 * ==============================================================================
 * WHAT: Carga las variables de entorno desde un archivo .env y define constantes
 *       globales inmutables para el funcionamiento de la aplicación.
 * WHY:  Separa las credenciales sensibles y configuraciones de infraestructura
 *       del código fuente (12-Factor App methodology). Previene fugas de seguridad
 *       en repositorios públicos de Git.
 * ==============================================================================
 */

/**
 * Lee un archivo de variables de entorno .env y las registra en el runtime de PHP.
 *
 * @param string $path Ruta absoluta hacia el archivo .env
 */
function loadEnv(string $path): void
{
    if (!file_exists($path)) {
        return;
    }

    foreach (file($path, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) as $line) {
        $line = trim($line);

        // Ignora comentarios y renglones vacíos
        if ($line === '' || str_starts_with($line, '#')) {
            continue;
        }

        // Divide solo por el primer signo '=' para permitir valores que contengan '='
        [$key, $value] = array_pad(explode('=', $line, 2), 2, '');

        $key   = trim($key);
        $value = trim($value);

        putenv("{$key}={$value}");
        $_ENV[$key] = $value;
    }
}

// Carga las variables del .env si existe en la raíz del módulo
loadEnv(__DIR__ . '/.env');

/**
 * Obtiene el valor de una variable de entorno o devuelve un valor por defecto.
 *
 * @param string $key Clave de la variable.
 * @param mixed $default Valor de fallback si la variable no está definida.
 * @return mixed
 */
function env(string $key, mixed $default = null): mixed
{
    $value = getenv($key);

    return ($value === false || $value === '') ? $default : $value;
}

// Entorno de ejecución: 'development' muestra detalles educativos; 'production' es estricto
$appEnv = strtolower((string) env('APP_ENV', 'development'));
if (!in_array($appEnv, ['development', 'production'], true)) {
    die('APP_ENV debe ser development o production.');
}
define('APP_ENV', $appEnv);

// Clave secreta criptográfica para firmar JWT
define('SECRET_KEY', (string) env('SECRET_KEY', 'clave-secreta-de-desarrollo-min-32-caracteres-jwt'));

// Duración del token JWT en segundos (por defecto 3600 = 1 hora)
define('TOKEN_LIFETIME', (int) env('TOKEN_LIFETIME', 3600));

// Origen frontend permitido para CORS con credenciales (cookies HttpOnly)
define('FRONTEND_ORIGIN', rtrim((string) env('FRONTEND_ORIGIN', 'http://localhost:5173'), '/'));

// Configuración de conexión a Base de Datos MySQL
define('DB_HOST', (string) env('DB_HOST', '127.0.0.1'));
define('DB_PORT', (string) env('DB_PORT', '3306'));
define('DB_NAME', (string) env('DB_NAME', 'utu_demo'));
define('DB_USER', (string) env('DB_USER', 'root'));
define('DB_PASSWORD', (string) env('DB_PASSWORD', ''));
