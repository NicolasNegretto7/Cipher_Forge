<?php
// QUÉ: Controlador para tareas de mantenimiento del sistema, respaldos y tareas de limpieza.
// POR QUÉ: Permite automatizar operaciones de infraestructura requeridas por el backlog (HU13, HU12)
//          mediante endpoints REST y ejecutables programados (cron / CI).
// CÓMO: Invoca BackupService y MultimediaService para ejecutar respaldos y depuraciones.

declare(strict_types=1);

namespace App\controllers;

use App\Core\Config;
use App\Core\Response;
use App\services\BackupService;
use App\services\MultimediaService;

class SistemaController
{
    private BackupService     $backupService;
    private MultimediaService $multimediaService;

    public function __construct()
    {
        $this->backupService     = new BackupService();
        $this->multimediaService = new MultimediaService();
        $this->restringirALocal();
    }

    /**
     * Restringe los endpoints de /sistema/* a la red local (H02, Riesgo Medio).
     * Sin lista explícita solo admite tráfico no público (loopback, rangos RFC1918 y
     * redes de reserva, incluido el NAT del bridge de Docker); opcionalmente la variable
     * de entorno SISTEMA_ALLOWED_IPS exige coincidencia con CIDRs concretos.
     * El respaldo automático no se ve afectado: cron-backup.php invoca BackupService y
     * MultimediaService por CLI (sin HTTP), por lo que HU13/HU12 siguen funcionando.
     */
    private function restringirALocal(): void
    {
        $ip = $_SERVER['REMOTE_ADDR'] ?? '';

        if ($ip === '' || filter_var($ip, FILTER_VALIDATE_IP) === false) {
            Response::error('Acceso restringido a la máquina local.', 403);
        }

        $permitidas = Config::ipsPermitidasSistema();
        if ($permitidas !== []) {
            foreach ($permitidas as $permitida) {
                if ($this->ipEnSubred($ip, $permitida)) {
                    return;
                }
            }

            Response::error('Acceso restringido a la máquina local.', 403);
        }

        $esPublica = filter_var($ip, FILTER_VALIDATE_IP, FILTER_FLAG_NO_PRIV_RANGE | FILTER_FLAG_NO_RES_RANGE) !== false;
        if ($esPublica) {
            Response::error('Acceso restringido a la máquina local.', 403);
        }
    }

    /**
     * Verifica si una IP coincide con una subred en notación CIDR o con una IP exacta.
     */
    private function ipEnSubred(string $ip, string $subred): bool
    {
        $subred = trim($subred);
        if ($subred === '') {
            return false;
        }

        if (strpos($subred, '/') === false) {
            return $ip === $subred;
        }

        [$red, $mascara] = explode('/', $subred, 2);
        $mascara = (int) $mascara;
        $ipBytes = inet_pton($ip);
        $redBytes = inet_pton(trim($red));

        if ($ipBytes === false || $redBytes === false || strlen($ipBytes) !== strlen($redBytes)) {
            return false;
        }

        $bits = strlen($ipBytes) * 8;
        if ($mascara < 0 || $mascara > $bits) {
            return false;
        }

        $ipBin = '';
        $redBin = '';
        for ($i = 0; $i < $bits; $i++) {
            $ipBin .= (ord($ipBytes[(int) ($i / 8)]) >> (7 - ($i % 8))) & 1;
            $redBin .= (ord($redBytes[(int) ($i / 8)]) >> (7 - ($i % 8))) & 1;
        }

        return substr($ipBin, 0, $mascara) === substr($redBin, 0, $mascara);
    }

    /**
     * POST /sistema/backup
     * Dispara un respaldo manual o programado con rotación automática a 3 copias (HU13 / RNF5, RNF6, RNF7).
     */
    public function backup(): void
    {
        $resultado = $this->backupService->generarBackup();
        Response::success($resultado, 'Respaldo de base de datos generado y rotado correctamente.', 201);
    }

    /**
     * GET /sistema/backups
     * Consulta el historial de respaldos registrados en la base de datos (RNF7).
     */
    public function listarBackups(): void
    {
        $backups = $this->backupService->listarBackups();
        Response::success($backups, 'Historial de respaldos de base de datos.');
    }

    /**
     * POST /sistema/limpiar-colaborativos
     * Purga archivos multimedia subidos por invitados no aprobados tras 24 horas (HU12 / RF15).
     */
    public function limpiarColaborativos(): void
    {
        $eliminados = $this->multimediaService->purgarExpirados();
        Response::success([
            'archivos_eliminados' => $eliminados,
            'ejecutado_en'        => date('Y-m-d H:i:s'),
        ], "Mantenimiento completado: {$eliminados} archivos colaborativos no aprobados purgados.");
    }
}
