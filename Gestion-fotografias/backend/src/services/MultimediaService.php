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
     * Sube un archivo multimedia a una colección (HU5 / HU11).
     * Soporta subida de fotógrafo (con control de propiedad) o de invitado (es_invitado = 1, aprobado = 0).
     */
    public function upload(MultimediaDto $dto, array $archivo, string $extension, string $mime, bool $aprobado = true): array
    {
        // 1. Verificar que la colección existe.
        $coleccion = $this->coleccionRepository->findById($dto->coleccionId);
        if ($coleccion === null) {
            Response::error('La colección especificada no existe.', 404);
        }

        // 2. Si no es invitado, verificar que el usuario autenticado sea el fotógrafo dueño.
        if (!$dto->esInvitado) {
            $usuario = $this->usuarioAutenticado();
            if ((int) $coleccion['fotografo_id'] !== (int) $usuario['id']) {
                Response::error('No tienes permiso para subir archivos a esta colección.', 403);
            }
        }

        // 3. Guardar el archivo original en uploads/originals.
        $rutaOriginal = MediaProcessor::guardarOriginal($archivo['tmp_name'], $extension);
        if ($rutaOriginal === '') {
            Response::error('No se pudo almacenar el archivo original.', 500);
        }

        $rutaAbsoluta = MediaProcessor::aRutaAbsoluta($rutaOriginal);

        // 4. Generar la vista previa: marca de agua (imagen) o recorte 15 s (video).
        // 4b. Para videos se genera además un poster (fotograma JPG) usado como portada
        //     de colección cuando esta no tiene imágenes (CC-35).
        if ($dto->tipo === 'imagen') {
            $vistaPrevia = MediaProcessor::generarPreviewImagen($rutaAbsoluta);
            $poster = null;
        } else {
            $vistaPrevia = MediaProcessor::generarPreviewVideo($rutaAbsoluta);
            $poster = MediaProcessor::generarPosterVideo($rutaAbsoluta);
        }

        if ($vistaPrevia === '') {
            Response::error('No se pudo generar la vista previa del archivo.', 500);
        }

        // 5. Registrar el archivo en la base de datos con estado de aprobación.
        $tamanio = (int) $archivo['size'];
        $idMultimedia = $this->multimediaRepository->create($dto, $rutaOriginal, $vistaPrevia, $tamanio, $aprobado, $poster);

        return [
            'id_multimedia' => $idMultimedia,
            'coleccion_id'  => $dto->coleccionId,
            'tipo'          => $dto->tipo,
            'titulo'        => $dto->titulo,
            'descripcion'   => $dto->descripcion,
            'vista_previa'  => $vistaPrevia,
            'poster'        => $poster,
            'tamanio'       => $tamanio,
            'es_invitado'   => $dto->esInvitado,
            'aprobado'      => $aprobado,
        ];
    }

    /**
     * Sube múltiples archivos controlando la cuota de 3 GB del fotógrafo y reportando excedentes (HU16).
     */
    public function uploadMultiple(int $coleccionId, array $archivos, array $data, array $extensionesPorMime): array
    {
        $coleccion = $this->coleccionRepository->findById($coleccionId);
        if ($coleccion === null) {
            Response::error('La colección especificada no existe.', 404);
        }

        $usuario = $this->usuarioAutenticado();
        if ((int) $coleccion['fotografo_id'] !== (int) $usuario['id']) {
            Response::error('No tienes permiso para subir archivos a esta colección.', 403);
        }

        // Consultar almacenamiento actual usado por el fotógrafo (HU16)
        $espacioUsado = $this->multimediaRepository->espacioUsadoPorFotografo((int) $usuario['id']);
        $maxCuota = Config::maxStorageBytes();

        $subidos = [];
        $excedentes = [];
        $validator = new \App\validators\MultimediaValidator();

        foreach ($archivos as $archivo) {
            $tamano = (int) $archivo['size'];
            $nombreOriginal = $archivo['name'] ?? 'archivo';

            // Comprobar si este archivo excede la cuota restante (RF17)
            if (($espacioUsado + $tamano) > $maxCuota) {
                $excedentes[] = [
                    'archivo'   => $nombreOriginal,
                    'tamanio'   => $tamano,
                    'motivo'    => 'Excede la cuota máxima permitida de 3 GB.',
                ];
                continue; // Permite que archivos más pequeños que sí entren sean subidos
            }

            $dto = $validator->validateUpload($archivo, $data, $coleccionId, false);
            $mime = mime_content_type($archivo['tmp_name']);
            $extension = $extensionesPorMime[$mime] ?? 'bin';

            $resultado = $this->upload($dto, $archivo, $extension, $mime, true);
            $subidos[] = $resultado;
            $espacioUsado += $tamano;
        }

        if (empty($subidos) && !empty($excedentes)) {
            Response::error('No se pudo subir ningún archivo porque se excede la cuota de 3 GB.', 400, $excedentes);
        }

        return [
            'subidos'    => $subidos,
            'excedentes' => $excedentes,
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
     * Descarga directa individual en dos niveles de calidad: 'buena' o 'alta' (HU10 / RF10).
     * Las descargas NUNCA llevan marca de agua (RF136).
     */
    public function obtenerDescarga(int $idMultimedia, string $calidad = 'alta'): string
    {
        $multimedia = $this->multimediaRepository->findById($idMultimedia);
        if ($multimedia === null) {
            Response::error('El archivo multimedia no existe.', 404);
        }

        // 1. Control de acceso
        $coleccion = [
            'id'               => $multimedia['coleccion_id'],
            'fotografo_id'     => $multimedia['fotografo_id'],
            'tipo_visibilidad' => $multimedia['tipo_visibilidad'],
            'titulo'           => $multimedia['titulo'],
        ];
        $this->verificarAccesoALaColeccion($coleccion);

        $rutaOriginalAbsoluta = MediaProcessor::aRutaAbsoluta($multimedia['ruta_original']);
        if (!file_exists($rutaOriginalAbsoluta)) {
            Response::error('El archivo original no está disponible en disco.', 404);
        }

        // Se solicita Alta Calidad: se entrega el archivo original completo.
        if (strtolower($calidad) === 'alta') {
            return $rutaOriginalAbsoluta;
        }

        // Se solicita Buena Calidad (CC-24/H05): copia re-codificada con calidad baja.
        // Imagen: JPEG 30 con tope Full HD 1920 px. Video: FFmpeg H.264 CRF 28, tope
        // Full HD 1920 px y audio AAC 128 kbps (CC-30). Si no se puede generar, se
        // entrega el original como fallback.
        if ($multimedia['tipo'] === 'video') {
            $rutaBuenaCalidad = MediaProcessor::generarBuenaCalidadVideo($rutaOriginalAbsoluta);
        } else {
            $rutaBuenaCalidad = MediaProcessor::generarBuenaCalidadImagen($rutaOriginalAbsoluta);
        }
        $rutaBuenaAbsoluta = MediaProcessor::aRutaAbsoluta($rutaBuenaCalidad);

        if (file_exists($rutaBuenaAbsoluta)) {
            return $rutaBuenaAbsoluta;
        }

        return $rutaOriginalAbsoluta;
    }

    /**
     * Devuelve la ruta absoluta del poster (fotograma JPG) de un video tras validar acceso (CC-35).
     * Si el video se subió antes de CC-35 (sin poster en disco), lo genera una única vez
     * desde el original y persiste la ruta. Para imágenes sirve la vista previa con marca de agua.
     */
    public function obtenerPoster(int $idMultimedia): string
    {
        $multimedia = $this->multimediaRepository->findById($idMultimedia);
        if ($multimedia === null) {
            Response::error('El archivo multimedia no existe.', 404);
        }

        $coleccion = [
            'id'               => $multimedia['coleccion_id'],
            'fotografo_id'     => $multimedia['fotografo_id'],
            'tipo_visibilidad' => $multimedia['tipo_visibilidad'],
            'titulo'           => $multimedia['titulo'],
        ];
        $this->verificarAccesoALaColeccion($coleccion);

        if ($multimedia['tipo'] === 'imagen') {
            return MediaProcessor::aRutaAbsoluta($multimedia['vista_previa']);
        }

        $rutaPoster = $multimedia['poster'] ?? null;
        if ($rutaPoster === null || $rutaPoster === '' || !file_exists(MediaProcessor::aRutaAbsoluta($rutaPoster))) {
            $rutaOriginalAbsoluta = MediaProcessor::aRutaAbsoluta($multimedia['ruta_original']);
            if (!file_exists($rutaOriginalAbsoluta)) {
                Response::error('El archivo no está disponible.', 404);
            }
            $rutaPoster = MediaProcessor::generarPosterVideo($rutaOriginalAbsoluta);
            if ($rutaPoster === '') {
                Response::error('No se pudo generar el poster del video.', 500);
            }
            $this->multimediaRepository->actualizarPoster((int) $multimedia['id_multimedia'], $rutaPoster);
        }

        return MediaProcessor::aRutaAbsoluta($rutaPoster);
    }

    /**
     * Elimina una imagen o recorte de video por su ID (HU6 / RF20).
     */
    public function eliminar(int $idMultimedia): void
    {
        $multimedia = $this->multimediaRepository->findById($idMultimedia);
        if ($multimedia === null) {
            Response::error('El archivo multimedia no existe.', 404);
        }

        $usuario = $this->usuarioAutenticado();
        if ((int) $multimedia['fotografo_id'] !== (int) $usuario['id']) {
            Response::error('Solo el fotógrafo dueño puede eliminar este archivo.', 403);
        }

        // Eliminar archivos físicos en disco
        MediaProcessor::eliminarArchivoFisico($multimedia['ruta_original']);
        MediaProcessor::eliminarArchivoFisico($multimedia['vista_previa']);
        MediaProcessor::eliminarArchivoFisico($multimedia['poster']);

        $this->multimediaRepository->delete($idMultimedia);
    }

    /**
     * Edita metadatos básicos o reasigna de colección un archivo multimedia (HU22 / RF20).
     */
    public function actualizarMetadatos(int $idMultimedia, array $data): array
    {
        $multimedia = $this->multimediaRepository->findById($idMultimedia);
        if ($multimedia === null) {
            Response::error('El archivo multimedia no existe.', 404);
        }

        $usuario = $this->usuarioAutenticado();
        if ((int) $multimedia['fotografo_id'] !== (int) $usuario['id']) {
            Response::error('Solo el fotógrafo dueño puede editar este archivo.', 403);
        }

        $titulo = isset($data['titulo']) ? trim((string) $data['titulo']) : $multimedia['titulo'];
        $descripcion = isset($data['descripcion']) ? trim((string) $data['descripcion']) : $multimedia['descripcion'];
        $nuevaColeccionId = isset($data['coleccion_id']) ? (int) $data['coleccion_id'] : null;

        // Si se reasigna de colección, validar que la colección de destino pertenezca al fotógrafo
        if ($nuevaColeccionId !== null && $nuevaColeccionId !== (int) $multimedia['coleccion_id']) {
            $nuevaCol = $this->coleccionRepository->findById($nuevaColeccionId);
            if ($nuevaCol === null) {
                Response::error('La colección destino no existe.', 404);
            }
            if ((int) $nuevaCol['fotografo_id'] !== (int) $usuario['id']) {
                Response::error('No tienes permisos sobre la colección destino.', 403);
            }
        }

        $this->multimediaRepository->actualizarMetadatos($idMultimedia, $titulo, $descripcion, $nuevaColeccionId);

        return $this->multimediaRepository->findById($idMultimedia);
    }

    /**
     * Lista archivos colaborativos pendientes de moderación (HU12 / RF15).
     */
    public function listarPendientes(int $coleccionId): array
    {
        $coleccion = $this->coleccionRepository->findById($coleccionId);
        if ($coleccion === null) {
            Response::error('La colección especificada no existe.', 404);
        }

        $usuario = $this->usuarioAutenticado();
        if ((int) $coleccion['fotografo_id'] !== (int) $usuario['id']) {
            Response::error('Solo el fotógrafo dueño puede moderar esta colección.', 403);
        }

        return $this->multimediaRepository->listarPendientes($coleccionId);
    }

    /**
     * Aprueba archivos colaborativos seleccionados (HU12 / RF15).
     */
    public function aprobarColaborativo(int $coleccionId, array $ids): int
    {
        $coleccion = $this->coleccionRepository->findById($coleccionId);
        if ($coleccion === null) {
            Response::error('La colección especificada no existe.', 404);
        }

        $usuario = $this->usuarioAutenticado();
        if ((int) $coleccion['fotografo_id'] !== (int) $usuario['id']) {
            Response::error('Solo el fotógrafo dueño puede aprobar archivos.', 403);
        }

        return $this->multimediaRepository->aprobarMultiples($ids, $coleccionId);
    }

    /**
     * Rechaza y elimina archivos colaborativos no aprobados (HU12 / RF15).
     */
    public function rechazarColaborativo(int $coleccionId, array $ids): int
    {
        $coleccion = $this->coleccionRepository->findById($coleccionId);
        if ($coleccion === null) {
            Response::error('La colección especificada no existe.', 404);
        }

        $usuario = $this->usuarioAutenticado();
        if ((int) $coleccion['fotografo_id'] !== (int) $usuario['id']) {
            Response::error('Solo el fotógrafo dueño puede rechazar archivos.', 403);
        }

        // Obtener rutas para borrar los archivos del disco
        $rutas = $this->multimediaRepository->obtenerRutasPorIds($ids, $coleccionId);
        foreach ($rutas as $item) {
            MediaProcessor::eliminarArchivoFisico($item['ruta_original']);
            MediaProcessor::eliminarArchivoFisico($item['vista_previa']);
            MediaProcessor::eliminarArchivoFisico($item['poster']);
            $this->multimediaRepository->delete((int) $item['id_multimedia']);
        }

        return count($rutas);
    }

    /**
     * Tarea periódica: Elimina automáticamente archivos no aprobados tras 24 horas (RF15 / HU12).
     */
    public function purgarExpirados(): int
    {
        $purgados = $this->multimediaRepository->purgarNoAprobadosExpirados();
        foreach ($purgados as $item) {
            MediaProcessor::eliminarArchivoFisico($item['ruta_original']);
            MediaProcessor::eliminarArchivoFisico($item['vista_previa']);
            MediaProcessor::eliminarArchivoFisico($item['poster']);
        }
        return count($purgados);
    }

    /**
     * Lista los archivos multimedia aprobados de una colección respetando la visibilidad y el acceso.
     */
    public function listarColeccion(int $coleccionId): array
    {
        $coleccion = $this->coleccionRepository->findById($coleccionId);
        if ($coleccion === null) {
            Response::error('La colección especificada no existe.', 404);
        }

        $this->verificarAccesoALaColeccion($coleccion);

        return $this->multimediaRepository->findByColeccionId($coleccionId, true);
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
        $usuario = \App\middlewares\AuthMiddleware::user();
        if ($usuario === null) {
            Response::error('Debes iniciar sesión.', 401);
        }
        return $usuario;
    }

    private function usuarioOpcional(): ?array
    {
        return \App\middlewares\AuthMiddleware::user();
    }
}
