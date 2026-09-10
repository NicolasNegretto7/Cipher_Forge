<?php
// QUÉ: Script CLI para ejecución programada (cron) de respaldos y limpieza automática.
// POR QUÉ: Permite automatizar HU13 (respaldo diario) y HU12 (depuración de archivos tras 24h)
//          mediante el cron del sistema operativo o el contenedor sin intervención humana.
// CÓMO: En modo one-shot (sin --loop) ejecuta ambas tareas y sale (uso manual o cron del host).
//       En modo --loop se queda residente como worker (CF-12: servicio `worker` de docker-compose)
//       respetando intervalos configurables por entorno (BACKUP_INTERVAL_SEG y PURGE_INTERVAL_SEG).

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

$modoLoop = in_array('--loop', $argv, true);

// Intervalos (segundos) entre ejecuciones en modo --loop; sobrescribibles por entorno.
$intervaloBackupSeg = max(1, (int) (getenv('BACKUP_INTERVAL_SEG') ?: 86400)); // diario por defecto
$intervaloPurgaSeg  = max(1, (int) (getenv('PURGE_INTERVAL_SEG')  ?: 3600));  // horario por defecto

$ultimoBackup = 0;
$ultimaPurga  = 0;

echo "[" . date('Y-m-d H:i:s') . "] Iniciando tareas programadas de mantenimiento..."
    . ($modoLoop ? " (modo --loop: respaldo cada {$intervaloBackupSeg}s, purga cada {$intervaloPurgaSeg}s)" : '')
    . "\n";

do {
    $ahora = time();
    $correrBackup = ($ahora - $ultimoBackup) >= $intervaloBackupSeg;
    $correrPurga  = ($ahora - $ultimaPurga)  >= $intervaloPurgaSeg;

    try {
        // 1. Limpieza de archivos colaborativos no aprobados > 24h (HU12 / RF15)
        if ($correrPurga) {
            $multimediaService = new MultimediaService();
            $purgados = $multimediaService->purgarExpirados();
            echo "[" . date('Y-m-d H:i:s') . "] [OK] Archivos colaborativos expirados purgados: {$purgados}\n";
            $ultimaPurga = $ahora;
        }

        // 2. Respaldo de base de datos con rotación (HU13 / RNF5, RNF6, RNF7)
        if ($correrBackup) {
            $backupService = new BackupService();
            $backup = $backupService->generarBackup();
            echo "[" . date('Y-m-d H:i:s') . "] [OK] Respaldo generado: {$backup['nombre_backup']} ({$backup['tamanio_kb']} KB)\n";
            $ultimoBackup = $ahora;
        }

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
