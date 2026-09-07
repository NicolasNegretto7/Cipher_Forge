<?php
// QUÉ: Controlador para la carga colaborativa de invitados y generación/impresión de códigos QR.
// POR QUÉ: Permite a invitados subir fotos/videos a eventos mediante escaneo de QR (HU4, HU7, HU11)
//          sin requerir cuentas complejas ni darles acceso a visualizar el material existente (RF14).
// CÓMO: Valida tokens en 'qr_tokens' con expiración de 24 horas y persiste en 'multimedia' con 'es_invitado=1'.

declare(strict_types=1);

namespace App\controllers;

use App\Core\AuthMiddleware;
use App\Core\Config;
use App\Core\Database;
use App\Core\Request;
use App\Core\Response;
use App\helpers\QrGenerator;
use App\repository\ColeccionRepository;
use App\services\MultimediaService;
use App\validators\MultimediaValidator;

class ColaborativoController
{
    private ColeccionRepository $coleccionRepository;
    private MultimediaService   $multimediaService;
    private MultimediaValidator $multimediaValidator;

    private const EXTENSION_POR_MIME = [
        'image/jpeg'      => 'jpg',
        'image/png'       => 'png',
        'video/mp4'       => 'mp4',
        'video/quicktime' => 'mov',
        'video/webm'      => 'webm',
        'video/x-msvideo' => 'avi',
    ];

    public function __construct()
    {
        $database = new Database();
        $pdo      = $database->getConnection();

        $this->coleccionRepository = new ColeccionRepository($pdo);
        $this->multimediaService   = new MultimediaService();
        $this->multimediaValidator = new MultimediaValidator();
    }

    /**
     * POST /colecciones/{id}/qr-colaborativo
     * Genera un código QR colaborativo con expiración de 24 horas para un evento (HU4 / RF13).
     */
    public function generar(string $id): void
    {
        $coleccionId = (int) $id;
        $coleccion = $this->coleccionRepository->findById($coleccionId);

        if ($coleccion === null) {
            Response::error('La colección no existe.', 404);
        }

        $usuario = AuthMiddleware::user();
        if ($usuario === null || (int) $coleccion['fotografo_id'] !== (int) $usuario['id']) {
            Response::error('Solo el fotógrafo dueño puede generar el código colaborativo.', 403);
        }

        // Expiración a 24 horas desde su creación (RF13)
        $expiracion = date('Y-m-d H:i:s', time() + (24 * 3600));
        $tokenData = $this->coleccionRepository->crearTokenColaborativo($coleccionId, $expiracion);

        $urlAcceso = $this->armarUrlFront("/colaborativo/{$tokenData['token']}");
        $urlImprimir = $this->armarUrlFront("/colecciones/{$coleccionId}/qr-colaborativo/imprimir");

        Response::success([
            'token'        => $tokenData['token'],
            'coleccion_id' => $coleccionId,
            'evento'       => $coleccion['titulo'],
            'expiracion'   => $expiracion,
            'url_acceso'   => $urlAcceso,
            'url_imprimir' => $urlImprimir,
            'svg_qr'       => QrGenerator::svg($urlAcceso),
        ], 'Código QR colaborativo de evento generado (vigencia: 24 horas).', 201);
    }

    /**
     * GET /colecciones/{id}/qr-colaborativo/imprimir
     * Genera la hoja HTML con estilos CSS @media print para imprimir el QR físicamente en el evento (HU7).
     */
    public function imprimir(string $id): void
    {
        $coleccionId = (int) $id;
        $coleccion = $this->coleccionRepository->findById($coleccionId);

        if ($coleccion === null) {
            Response::error('La colección no existe.', 404);
        }

        // Buscar el token colaborativo vigente más reciente
        $stmt = (new Database())->getConnection()->prepare(
            'SELECT token, expiracion FROM qr_tokens WHERE coleccion_id = :id AND tipo = "colaborativo" AND expiracion > NOW() ORDER BY id_token DESC LIMIT 1'
        );
        $stmt->execute(['id' => $coleccionId]);
        $tokenData = $stmt->fetch();

        if (!$tokenData) {
            // Si no hay vigente, generar uno nuevo automáticamente
            $expiracion = date('Y-m-d H:i:s', time() + (24 * 3600));
            $tokenData = $this->coleccionRepository->crearTokenColaborativo($coleccionId, $expiracion);
        }

        $urlAcceso = $this->armarUrlFront("/colaborativo/{$tokenData['token']}");
        $svg = QrGenerator::svg($urlAcceso, 280);

        header('Content-Type: text/html; charset=utf-8');
        echo QrGenerator::renderPrintableHtml(
            $coleccion['titulo'] ?? 'Evento Especial',
            $urlAcceso,
            $svg,
            $tokenData['expiracion']
        );
        exit;
    }

    /**
     * GET /qr/{token}/svg
     * Retorna la imagen vectorial SVG del código QR directamente (HU7).
     */
    public function svg(string $token): void
    {
        $infoToken = $this->coleccionRepository->buscarToken($token);
        if ($infoToken === null) {
            Response::error('Token no encontrado.', 404);
        }

        $url = $this->armarUrlFront("/colaborativo/{$token}");
        $svg = QrGenerator::svg($url, 300);

        header('Content-Type: image/svg+xml');
        echo $svg;
        exit;
    }

    /**
     * GET /colaborativo/{token}
     * Valida el token y entrega metadatos mínimos del evento al invitado (HU11 / RF14).
     * IMPORTANTE: No retorna multimedia ni galería para proteger la privacidad.
     */
    public function verificar(string $token): void
    {
        $infoToken = $this->validarTokenActivo($token);

        Response::success([
            'token'        => $token,
            'evento'       => $infoToken['coleccion_titulo'],
            'expira_en'    => $infoToken['expiracion'],
            'mensaje'      => 'Puedes subir fotos y videos para este evento.',
        ], 'Acceso colaborativo verificado.');
    }

    /**
     * POST /colaborativo/{token}/subir
     * Sube material de invitados a la colección sin requerir registro (HU11 / RF14 / RF25).
     * Aplica límite de 80 MB para clips y marca como pendiente de moderación (aprobado = 0).
     */
    public function subir(string $token): void
    {
        $infoToken = $this->validarTokenActivo($token);
        $coleccionId = (int) $infoToken['coleccion_id'];

        if (!isset($_FILES['archivos'])) {
            Response::error('Debes enviar al menos un archivo en el campo "archivos".', 400);
        }

        $request = new Request();
        $data = $request->getBody();
        $nombreInvitado = isset($data['nombre_invitado']) ? trim((string) $data['nombre_invitado']) : 'Invitado';

        $archivos = $this->normalizarArchivos($_FILES['archivos']);
        $subidos = [];

        foreach ($archivos as $archivo) {
            // Validar con restricción estricta de invitado (máx 80MB para clips según RF25)
            $dto = $this->multimediaValidator->validateUpload(
                $archivo,
                [
                    'titulo'      => $nombreInvitado,
                    'descripcion' => 'Aporte colaborativo de invitado',
                ],
                $coleccionId,
                esInvitado: true
            );

            $mime = mime_content_type($archivo['tmp_name']);
            $extension = self::EXTENSION_POR_MIME[$mime] ?? 'bin';

            // Subir con aprobado = false para requerir aprobación del fotógrafo (HU12)
            $subidos[] = $this->multimediaService->upload($dto, $archivo, $extension, $mime, aprobado: false);
        }

        Response::success([
            'subidos' => count($subidos),
            'aviso'   => 'Tus archivos han sido subidos y serán revisados por el fotógrafo. Los no aprobados se eliminarán en 24 horas.',
        ], 'Carga colaborativa recibida exitosamente.', 201);
    }

    private function validarTokenActivo(string $token): array
    {
        $infoToken = $this->coleccionRepository->buscarToken($token);

        if ($infoToken === null || $infoToken['tipo'] !== 'colaborativo') {
            Response::error('El código QR colaborativo no es válido.', 404);
        }

        if ($infoToken['expiracion'] !== null && strtotime($infoToken['expiracion']) < time()) {
            Response::error('Este código QR colaborativo ha caducado (duración máxima de 24 horas).', 410);
        }

        return $infoToken;
    }

    private function normalizarArchivos(array $archivos): array
    {
        if (!is_array($archivos['name'])) {
            return [$archivos];
        }

        $resultado = [];
        foreach ($archivos['name'] as $i => $nombre) {
            $resultado[] = [
                'name'     => $nombre,
                'type'     => $archivos['type'][$i],
                'tmp_name' => $archivos['tmp_name'][$i],
                'error'    => $archivos['error'][$i],
                'size'     => $archivos['size'][$i],
            ];
        }
        return $resultado;
    }

    private function armarUrlFront(string $path): string
    {
        $host = $_SERVER['HTTP_HOST'] ?? 'localhost:8080';
        $proto = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ? 'https' : 'http';
        return "{$proto}://{$host}{$path}";
    }
}
