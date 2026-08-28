<?php

declare(strict_types=1);

namespace App\Repositories;

use App\Core\Database;
use PDO;

/**
 * REPOSITORIO BASE (CLASE PADRE)
 * ==============================================================================
 * WHAT: Clase abstracta/base que inicializa e inyecta la conexión PDO compartida
 *       para todos los repositorios hijos.
 * WHY:  Aplica el principio DRY (Don't Repeat Yourself) y Herencia. Los repositorios
 *       hijos heredan `$this->db` automáticamente sin escribir constructores repetidos.
 * ==============================================================================
 */
class Repository
{
    protected PDO $db;

    public function __construct(?PDO $db = null)
    {
        $this->db = $db ?? Database::connection();
    }
}
