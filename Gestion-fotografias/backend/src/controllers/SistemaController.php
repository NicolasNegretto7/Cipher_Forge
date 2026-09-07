<?php
// QUÉ: Controlador para tareas de mantenimiento del sistema, respaldos y tareas de limpieza.
// POR QUÉ: Permite automatizar operaciones de infraestructura requeridas por el backlog (HU13, HU12)
//          mediante endpoints REST y ejecutables programados (cron / CI).
// CÓMO: Invoca BackupService y MultimediaService para ejecutar respaldos y depuraciones.

declare(strict_types=1);

namespace App\controllers;

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
