<?php
// QUÉ: Servicio de respaldo automático y rotación de base de datos MySQL en PHP Vanilla.
// POR QUÉ: Garantiza respaldos consistentes y rotación de las últimas 3 copias (RNF5, RNF6, RNF7 / HU13)
//          sin requerir mysqldump en el host ni librerías externas de composer.
// CÓMO: Exporta DDL y DML mediante PDO, almacena en 'backups/' y mantiene máx 3 registros en la tabla 'backups'.

declare(strict_types=1);

namespace App\services;

use App\Core\Config;
use App\Core\Database;
use PDO;

class BackupService
{
    private PDO $pdo;

    public function __construct()
    {
        $database = new Database();
        $this->pdo = $database->getConnection();
    }

    /**
     * Genera un respaldo SQL completo de la base de datos y rota las copias antiguas (HU13).
     */
    public function generarBackup(): array
    {
        $dir = Config::backupsDir();
        if (!is_dir($dir)) {
            mkdir($dir, 0775, true);
        }

        $timestamp = date('Y-m-d_H-i-s');
        $nombreArchivo = "backup_cipher_forge_{$timestamp}.sql";
        $rutaCompleta = $dir . '/' . $nombreArchivo;

        // 1. Generar contenido SQL de tablas y datos
        $contenidoSql = $this->generarSqlDump();

        // 2. Escribir archivo de respaldo
        file_put_contents($rutaCompleta, $contenidoSql);
        $tamanioBytes = filesize($rutaCompleta);

        // 3. Rotación de respaldos: mantener exactamente las últimas 3 copias (RNF6)
        $this->rotarBackups();

        // 4. Registrar el nuevo respaldo en la base de datos (RNF7)
        $stmt = $this->pdo->prepare(
            'INSERT INTO backups (ruta_backup, nombre_backup, fecha_backup)
             VALUES (:ruta, :nombre, NOW())'
        );
        $stmt->execute([
            'ruta'   => 'backups/' . $nombreArchivo,
            'nombre' => $nombreArchivo,
        ]);
        $idBackup = (int) $this->pdo->lastInsertId();

        return [
            'id_backup'     => $idBackup,
            'nombre_backup' => $nombreArchivo,
            'ruta'          => 'backups/' . $nombreArchivo,
            'tamanio_kb'    => round($tamanioBytes / 1024, 2),
            'fecha'         => date('Y-m-d H:i:s'),
        ];
    }

    /**
     * Lista el historial de respaldos almacenados en el sistema (RNF7).
     */
    public function listarBackups(): array
    {
        $stmt = $this->pdo->prepare(
            'SELECT id_backup, ruta_backup, nombre_backup, fecha_backup
             FROM backups
             ORDER BY fecha_backup DESC'
        );
        $stmt->execute();
        return $stmt->fetchAll();
    }

    /**
     * Mantiene como máximo 3 respaldos; si hay 3 o más elimina el más antiguo (RNF6).
     */
    private function rotarBackups(): void
    {
        $stmt = $this->pdo->prepare('SELECT id_backup, ruta_backup, nombre_backup FROM backups ORDER BY fecha_backup ASC');
        $stmt->execute();
        $existentes = $stmt->fetchAll();

        // Si ya hay 3 copias (o más), eliminar los más antiguos hasta que queden 2 antes de insertar el nuevo
        if (count($existentes) >= 3) {
            $excedentes = array_slice($existentes, 0, count($existentes) - 2);

            foreach ($excedentes as $viejo) {
                $rutaFisica = Config::backupsDir() . '/' . basename($viejo['ruta_backup']);
                if (file_exists($rutaFisica)) {
                    @unlink($rutaFisica);
                }

                $delStmt = $this->pdo->prepare('DELETE FROM backups WHERE id_backup = :id');
                $delStmt->execute(['id' => $viejo['id_backup']]);
            }
        }
    }

    /**
     * Exporta DDL y DML de todas las tablas en formato SQL estándar.
     */
    private function generarSqlDump(): string
    {
        $sql = "-- ========================================================\n";
        $sql .= "-- Respaldo Automático de Base de Datos - Cipher Forge\n";
        $sql .= "-- Generado el: " . date('Y-m-d H:i:s') . "\n";
        $sql .= "-- ========================================================\n\n";
        $sql .= "SET FOREIGN_KEY_CHECKS = 0;\n\n";

        // Obtener tablas de la base de datos
        $tablesStmt = $this->pdo->query("SHOW FULL TABLES WHERE Table_type = 'BASE TABLE'");
        $tables = $tablesStmt->fetchAll(PDO::FETCH_COLUMN);

        foreach ($tables as $table) {
            // No respaldar la propia tabla backups para evitar inconsistencias circulares
            if ($table === 'backups') {
                continue;
            }

            $sql .= "-- --------------------------------------------------------\n";
            $sql .= "-- Estructura de tabla `{$table}`\n";
            $sql .= "-- --------------------------------------------------------\n";
            $sql .= "DROP TABLE IF EXISTS `{$table}`;\n";

            $createStmt = $this->pdo->query("SHOW CREATE TABLE `{$table}`");
            $createRow = $createStmt->fetch(PDO::FETCH_NUM);
            $sql .= $createRow[1] . ";\n\n";

            // Volcado de datos
            $rowsStmt = $this->pdo->query("SELECT * FROM `{$table}`");
            $rows = $rowsStmt->fetchAll(PDO::FETCH_ASSOC);

            if (!empty($rows)) {
                $sql .= "-- Volcado de datos para `{$table}`\n";
                foreach ($rows as $row) {
                    $columnas = array_keys($row);
                    $columnasStr = implode('`, `', $columnas);

                    $valores = array_map(function ($val) {
                        if ($val === null) return 'NULL';
                        return $this->pdo->quote((string) $val);
                    }, array_values($row));

                    $valoresStr = implode(', ', $valores);
                    $sql .= "INSERT INTO `{$table}` (`{$columnasStr}`) VALUES ({$valoresStr});\n";
                }
                $sql .= "\n";
            }
        }

        $sql .= "SET FOREIGN_KEY_CHECKS = 1;\n";
        $sql .= "-- Fin del Respaldo\n";

        return $sql;
    }
}
