<?php
// QUÉ: Script CLI para ejecución programada (cron) de respaldos y limpieza automática.
// POR QUÉ: Permite automatizar HU13 (respaldo diario) y HU12 (depuración de archivos tras 24h)
//          mediante el cron del sistema operativo o el contenedor sin intervención humana.

declare(strict_types=1);

spl_autoload_register(function (string $class): void {
    $prefix = 'App\\';
    $baseDir = __DIR__ . '/src/';

    $len = strlen($prefix);
    if (strncmp($prefix, $class, $len) !== 0) {
        return;
    }

    $relativeClass = substr($class, $len);
    // Convierte App\Core\Router en src/Core/Router.php
    $file = $baseDir . str_replace('\\', '/', $relativeClass) . '.php';

    if (file_exists($file)) {
        require_once $file;
    }
});

use App\services\BackupService;
use App\services\MultimediaService;

echo "[" . date('Y-m-d H:i:s') . "] Iniciando tareas programadas de mantenimiento...\n";

$modoLoop = in_array('--loop', $argv, true);

do {
    try {
        // 1. Respaldo de base de datos con rotación (HU13)
        $backupService = new BackupService();
        $backup = $backupService->generarBackup();
        echo "[" . date('Y-m-d H:i:s') . "] [OK] Respaldo generado: {$backup['nombre_backup']} ({$backup['tamanio_kb']} KB)\n";

        // 2. Limpieza de archivos colaborativos no aprobados > 24h (HU12)
        $multimediaService = new MultimediaService();
        $purgados = $multimediaService->purgarExpirados();
        echo "[" . date('Y-m-d H:i:s') . "] [OK] Archivos colaborativos expirados purgados: {$purgados}\n";

        if (!$modoLoop) {
            break;
        }

        sleep(60);
    } catch (Throwable $e) {
        echo "[" . date('Y-m-d H:i:s') . "] [ERROR] Fallo en tareas programadas: " . $e->getMessage() . "\n";

        if (!$modoLoop) {
            exit(1);
        }

        sleep(60);
    }
} while ($modoLoop);

if (!$modoLoop) {
    echo "[" . date('Y-m-d H:i:s') . "] Tareas finalizadas exitosamente.\n";
    exit(0);
}
