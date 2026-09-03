<?php
// QUÉ: Lógica de negocio para la gestión de colecciones.
// POR QUÉ: Centraliza las reglas de negocio (ej. verificación estricta del rol 'fotografo') antes de persistir datos.

declare(strict_types=1);

namespace App\services;

use App\Core\Database;
use App\Core\Response;
use App\dtos\CreateColeccionDto;
use App\repository\ColeccionRepository;
use App\repository\UserRepository;

class ColeccionService
{
    private UserRepository     $userRepository;
    private ColeccionRepository $coleccionRepository;

    public function __construct()
    {
        $database = new Database();
        $pdo      = $database->getConnection();

        $this->userRepository      = new UserRepository($pdo);
        $this->coleccionRepository = new ColeccionRepository($pdo);
    }

    /**
     * Valida permisos y registra una nueva colección.
     * Restringe la creación estrictamente a usuarios con rol 'fotografo'.
     */
    public function create(CreateColeccionDto $dto): array
    {
        // 1. Verificar existencia del usuario fotógrafo
        $usuario = $this->userRepository->findById($dto->fotografoId);

        if ($usuario === null) {
            Response::error('El fotógrafo especificado no existe.', 404);
        }

        // 2. Verificar que el usuario tenga rol 'fotografo' (RF4 / HU2)
        if ($usuario['rol'] !== 'fotografo') {
            Response::error('Solo los usuarios con rol fotógrafo pueden crear colecciones.', 403);
        }

        // 3. Crear la colección en la base de datos
        $coleccionId = $this->coleccionRepository->create($dto);

        // 4. Obtener los datos completos de la colección creada
        $coleccion = $this->coleccionRepository->findById($coleccionId);

        if ($coleccion === null) {
            Response::error('No se pudo recuperar la colección creada.', 500);
        }

        return $coleccion;
    }
}
