<?php

declare(strict_types=1);

namespace App\Controllers;

use App\Core\Request;
use App\Core\Response;
use App\Helpers\TokenHelper;
use App\Repositories\CollectionRepository;
use App\Repositories\ImageRepository;
use Throwable;

/**
 * Controlador REST para Colecciones / Galerías fotográficas con UUIDs.
 */
class CollectionController
{
    private CollectionRepository $collectionRepo;
    private ImageRepository $imageRepo;

    public function __construct(
        ?CollectionRepository $collectionRepo = null,
        ?ImageRepository $imageRepo = null
    ) {
        $this->collectionRepo = $collectionRepo ?? new CollectionRepository();
        $this->imageRepo = $imageRepo ?? new ImageRepository();
    }

    /**
     * GET /api/collections
     * Lista colecciones autorizadas para el usuario según su rol y privacidad.
     */
    public function index(Request $request): void
    {
        try {
            $user = $request->getUser();
            $userId = $user ? (int) $user['id'] : null;
            $role = $user ? (string) $user['role'] : null;

            $collections = $this->collectionRepo->findAllAccessible($userId, $role);

            Response::success($collections, 'Colecciones obtenidas exitosamente.', 200);
        } catch (Throwable $e) {
            Response::error('Error al listar colecciones: ' . $e->getMessage(), 500);
        }
    }

    /**
     * GET /api/collections/{uuid}
     * Obtiene los datos de una colección por su UUID y sus imágenes asociadas.
     */
    public function show(Request $request, array $params): void
    {
        try {
            $uuid = (string) ($params['uuid'] ?? '');
            $collection = $this->collectionRepo->findByUuid($uuid);

            if ($collection === null) {
                Response::error('Colección no encontrada.', 404);
            }

            $user = $request->getUser();
            $isOwner = $user && (int) $user['id'] === (int) $collection['user_id'];
            $isFotografo = $user && $user['role'] === 'fotografo';

            // Si es privada y no es fotógrafo ni creador -> 403 Forbidden
            if ((int) $collection['is_private'] === 1 && !$isOwner && !$isFotografo) {
                Response::error('Acceso denegado a esta colección privada.', 403);
            }

            $images = $this->imageRepo->findByCollectionId((int) $collection['id']);
            $collection['images'] = $images;

            Response::success($collection, 'Detalle de colección obtenido.', 200);
        } catch (Throwable $e) {
            Response::error('Error al obtener la colección: ' . $e->getMessage(), 500);
        }
    }

    /**
     * POST /api/collections (Solo Fotógrafo)
     * Crea una nueva colección generando un UUID v4 no predecible.
     */
    public function store(Request $request): void
    {
        try {
            $user = $request->getUser();
            $body = $request->getBody();

            $title = trim((string) ($body['title'] ?? ''));
            $description = isset($body['description']) ? trim((string) $body['description']) : null;
            $isPrivate = (bool) ($body['is_private'] ?? true);

            if ($title === '') {
                Response::error('El título de la colección es obligatorio.', 422, ['title' => 'Campo requerido']);
            }

            $uuid = TokenHelper::generateUuid();
            $id = $this->collectionRepo->create($uuid, (int) $user['id'], $title, $description, $isPrivate);

            $created = $this->collectionRepo->findByUuid($uuid);

            Response::success($created, 'Colección creada exitosamente.', 201);
        } catch (Throwable $e) {
            Response::error('Error al crear colección: ' . $e->getMessage(), 500);
        }
    }

    /**
     * PUT /api/collections/{uuid} (Solo Fotógrafo creador)
     */
    public function update(Request $request, array $params): void
    {
        try {
            $uuid = (string) ($params['uuid'] ?? '');
            $collection = $this->collectionRepo->findByUuid($uuid);

            if ($collection === null) {
                Response::error('Colección no encontrada.', 404);
            }

            $user = $request->getUser();
            if ((int) $collection['user_id'] !== (int) $user['id']) {
                Response::error('No tienes permiso para modificar esta colección.', 403);
            }

            $body = $request->getBody();
            $title = isset($body['title']) ? trim((string) $body['title']) : (string) $collection['title'];
            $description = array_key_exists('description', $body) ? trim((string) $body['description']) : $collection['description'];
            $isPrivate = isset($body['is_private']) ? (bool) $body['is_private'] : (bool) $collection['is_private'];

            $this->collectionRepo->update((int) $collection['id'], $title, $description, $isPrivate);
            $updated = $this->collectionRepo->findByUuid($uuid);

            Response::success($updated, 'Colección actualizada correctamente.', 200);
        } catch (Throwable $e) {
            Response::error('Error al actualizar colección: ' . $e->getMessage(), 500);
        }
    }

    /**
     * DELETE /api/collections/{uuid} (Solo Fotógrafo creador)
     */
    public function destroy(Request $request, array $params): void
    {
        try {
            $uuid = (string) ($params['uuid'] ?? '');
            $collection = $this->collectionRepo->findByUuid($uuid);

            if ($collection === null) {
                Response::error('Colección no encontrada.', 404);
            }

            $user = $request->getUser();
            if ((int) $collection['user_id'] !== (int) $user['id']) {
                Response::error('No tienes permiso para eliminar esta colección.', 403);
            }

            $this->collectionRepo->delete((int) $collection['id']);

            Response::success(null, 'Colección eliminada exitosamente.', 200);
        } catch (Throwable $e) {
            Response::error('Error al eliminar colección: ' . $e->getMessage(), 500);
        }
    }
}
