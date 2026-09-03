<?php
// QUÉ: Lógica de negocio para la subida, vista previa y acceso a archivos multimedia.
// POR QUÉ: Centraliza las reglas de negocio (propiedad de la colección, control de acceso por
//          visibilidad y autorización de clientes) y delega el procesamiento binario a MediaProcessor.

declare(strict_types=1);

namespace App\services;

use App\Core\Config;
use App\Core\Database;
use App\Core\Response;
use App\dtos\MultimediaDto;
use App\helpers\MediaProcessor;
use App\repository\ColeccionRepository;
use App\repository\MultimediaRepository;
use App\repository\UserRepository;

class MultimediaService
{
    private MultimediaRepository $multimediaRepository;
    private ColeccionRepository  $coleccionRepository;
    private UserRepository       $userRepository;

    public function __construct()
    {
        $database = new Database();
        $pdo      = $database->getConnection();

        $this->multimediaRepository = new MultimediaRepository($pdo);
        $this->coleccionRepository  = new ColeccionRepository($pdo);
        $this->userRepository       = new UserRepository($pdo);
    }

    /**
     * Sube un archivo multimedia a una colección (HU5).
     * Solo el fotógrafo dueño de la colección puede subir contenido.
     */
    public function upload(MultimediaDto $dto, array $archivo, string $extension, string $mime): array
    {
        // 1. Verificar que el usuario autenticado existe.
        $usuario = $this->usuarioAutenticado();

        // 2. Verificar que la colección existe.
        $coleccion = $this->coleccionRepository->findById($dto->coleccionId);
        if ($coleccion === null) {
            Response::error('La colección especificada no existe.', 404);
        }

        // 3. Solo el fotógrafo dueño puede subir a su colección (control de propiedad).
        if ((int) $coleccion['fotografo_id'] !== (int) $usuario['id']) {
            Response::error('No tienes permiso para subir archivos a esta colección.', 403);
        }

        // 4. Guardar el archivo original en uploads/originals.
        $rutaOriginal = MediaProcessor::guardarOriginal($archivo['tmp_name'], $extension);
        if ($rutaOriginal === '') {
            Response::error('No se pudo almacenar el archivo original.', 500);
        }

        $rutaAbsoluta = MediaProcessor::aRutaAbsoluta($rutaOriginal);

        // 5. Generar la vista previa: marca de agua (imagen) o recorte 15 s (video).
        if ($dto->tipo === 'imagen') {
            $vistaPrevia = MediaProcessor::generarPreviewImagen($rutaAbsoluta);
        } else {
            $vistaPrevia = MediaProcessor::generarPreviewVideo($rutaAbsoluta);
        }

        if ($vistaPrevia === '') {
            Response::error('No se pudo generar la vista previa del archivo.', 500);
        }

        // 6. Registrar el archivo en la base de datos.
        $tamanio = (int) $archivo['size'];
        $idMultimedia = $this->multimediaRepository->create($dto, $rutaOriginal, $vistaPrevia, $tamanio);

        return [
            'id_multimedia' => $idMultimedia,
            'coleccion_id'  => $dto->coleccionId,
            'tipo'          => $dto->tipo,
            'titulo'        => $dto->titulo,
            'descripcion'   => $dto->descripcion,
            'vista_previa'  => $vistaPrevia,
            'tamanio'       => $tamanio,
        ];
    }

    /**
     * Devuelve la ruta absoluta de la vista previa si el solicitante tiene permiso
     * para ver el contenido de la colección. Si no, interrumpe con 403/404.
     */
    public function obtenerVistaPrevia(int $idMultimedia): string
    {
        return $this->rutaServible($idMultimedia, true);
    }

    /**
     * Devuelve la ruta absoluta del archivo original SOLO si el solicitante está autorizado.
     * El original (alta calidad) nunca se sirve a quien no tenga acceso (RF11 / HU20).
     */
    public function obtenerOriginal(int $idMultimedia): string
    {
        return $this->rutaServible($idMultimedia, thoughWatermark: false);
    }

    /**
     * Lista los archivos multimedia de una colección respetando la visibilidad y el acceso.
     */
    public function listarColeccion(int $coleccionId): array
    {
        $coleccion = $this->coleccionRepository->findById($coleccionId);
        if ($coleccion === null) {
            Response::error('La colección especificada no existe.', 404);
        }

        $this->verificarAccesoALaColeccion($coleccion);

        return $this->multimediaRepository->findByColeccionId($coleccionId);
    }

    // ------------------------------------------------------------------
    // Métodos internos de control de acceso
    // ------------------------------------------------------------------

    private function rutaServible(int $idMultimedia, bool $thoughWatermark): string
    {
        $multimedia = $this->multimediaRepository->findById($idMultimedia);

        if ($multimedia === null) {
            Response::error('El archivo multimedia no existe.', 404);
        }

        // 1. Control de acceso a nivel de colección (visibilidad + autorización).
        $coleccion = [
            'id'               => $multimedia['coleccion_id'],
            'fotografo_id'     => $multimedia['fotografo_id'],
            'tipo_visibilidad' => $multimedia['tipo_visibilidad'],
            'titulo'           => $multimedia['titulo'],
        ];
        $this->verificarAccesoALaColeccion($coleccion);

        // 2. Elegir entre vista previa (con marca de agua) u original.
        $rutaRelativa = $thoughWatermark ? $multimedia['vista_previa'] : $multimedia['ruta_original'];
        $rutaAbsoluta = MediaProcessor::aRutaAbsoluta($rutaRelativa);

        if (!file_exists($rutaAbsoluta)) {
            Response::error('El archivo no está disponible.', 404);
        }

        return $rutaAbsoluta;
    }

    /**
     * HU20: Bloquea el acceso directo por URL a colecciones privadas.
     * Colecciones públicas -> permitido. Privadas -> solo dueño o cliente con acceso_colecciones.
     */
    private function verificarAccesoALaColeccion(array $coleccion): void
    {
        if ($coleccion['tipo_visibilidad'] === 'publica') {
            return; // Las colecciones públicas son de libre visualización (RF11).
        }

        $usuario = $this->usuarioOpcional();

        if ($usuario === null) {
            Response::error('Debes iniciar sesión para acceder a esta colección privada.', 401);
        }

        $esDueno = (int) $coleccion['fotografo_id'] === (int) $usuario['id'];
        $tieneAcceso = $this->multimediaRepository->tieneAcceso((int) $usuario['id'], (int) $coleccion['id']);

        if (!$esDueno && !$tieneAcceso) {
            Response::error('No tienes permisos para acceder a esta colección privada.', 403);
        }
    }

    private function usuarioAutenticado(): array
    {
        $usuario = \App\Core\AuthMiddleware::user();
        if ($usuario === null) {
            Response::error('Debes iniciar sesión.', 401);
        }
        return $usuario;
    }

    private function usuarioOpcional(): ?array
    {
        return \App\Core\AuthMiddleware::user();
    }
}
