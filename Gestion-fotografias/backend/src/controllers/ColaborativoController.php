<?php
// QUÉ: Controlador para la carga colaborativa de invitados y generación/impresión de códigos QR.
// POR QUÉ: Permite a invitados subir fotos/videos a eventos mediante escaneo de QR (HU4, HU7, HU11)
//          sin requerir cuentas complejas ni darles acceso a visualizar el material existente (RF14).
// CÓMO: Valida tokens en 'qr_tokens' con expiración de 24 horas y persiste en 'multimedia' con 'es_invitado=1'.

declare(strict_types=1);

namespace App\controllers;

use App\middlewares\AuthMiddleware;
use App\Core\Config;
use App\Core\Database;
use App\Core\Request;
use App\Core\Response;
use App\helpers\QrGenerator;
use App\repository\ColeccionRepository;
use App\repository\MultimediaRepository;
use App\services\MultimediaService;
use App\validators\MultimediaValidator;

class ColaborativoController
{
    private ColeccionRepository    $coleccionRepository;
    private MultimediaRepository   $multimediaRepository;
    private MultimediaService      $multimediaService;
    private MultimediaValidator    $multimediaValidator;

    private const EXTENSION_POR_MIME = [
        'image/jpeg' => 'jpg',
        'video/mp4'  => 'mp4',
    ];

    public function __construct()
    {
        $database = new Database();
        $pdo      = $database->getConnection();

        $this->coleccionRepository  = new ColeccionRepository($pdo);
        $this->multimediaRepository = new MultimediaRepository($pdo);
        $this->multimediaService    = new MultimediaService();
        $this->multimediaValidator  = new MultimediaValidator();
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

        $urlAcceso = $this->armarUrlColaborativo($tokenData['token']);
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
     * POST /colecciones/{id}/qr-acceso
     * Genera o reutiliza un enlace/QR de acceso permanente (sin caducidad) a una colección
     * privada (CF-01 / RF16 / HU17). Quien posea el enlace puede canjearlo y acceder a la
     * colección como cliente invitado. Solo el fotógrafo dueño puede generarlo.
     */
    public function generarAcceso(string $id): void
    {
        $coleccionId = (int) $id;
        $coleccion = $this->coleccionRepository->findById($coleccionId);

        if ($coleccion === null) {
            Response::error('La colección no existe.', 404);
        }

        $usuario = AuthMiddleware::user();
        if ($usuario === null || (int) $coleccion['fotografo_id'] !== (int) $usuario['id']) {
            Response::error('Solo el fotógrafo dueño puede generar el enlace de acceso.', 403);
        }

        // Reutilizar el token de acceso vigente si ya existe (enlace permanente estable);
        // de lo contrario crear uno nuevo sin expiración.
        $existente = $this->coleccionRepository->buscarTokenAccesoVigente($coleccionId);
        $tokenData = $existente ?? $this->coleccionRepository->crearTokenAcceso($coleccionId);

        $urlAcceso = $this->armarUrlInvitacion($tokenData['token']);

        Response::success([
            'token'        => $tokenData['token'],
            'coleccion_id' => $coleccionId,
            'titulo'       => $coleccion['titulo'],
            'tipo'         => 'acceso',
            'expiracion'   => null,
            'url_acceso'   => $urlAcceso,
            'svg_qr'       => QrGenerator::svg($urlAcceso),
        ], 'Enlace de acceso permanente a la colección generado.', 201);
    }

    /**
     * GET /colecciones/{id}/qr-colaborativo/imprimir
     * Genera la hoja HTML con estilos CSS @media print para imprimir el QR físicamente en el evento (HU7).
     * CF-06 (RESUELTO): la hoja imprimible es pública (sin login) y el QR codifica la landing anónima
     * del invitado (frontend-cliente/pages/colaborativo.html), conforme al frontend (qrcolaborativo.js).
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

        $urlAcceso = $this->armarUrlColaborativo($tokenData['token']);
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

        $url = $this->armarUrlColaborativo($token);
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
     * Aplica el límite documentado de 800 MB por video y respeta la cuota de 3 GB del
     * fotógrafo (CF-07 / RF17); los archivos que excedan la cuota se rechazan y se informan.
     */
    public function subir(string $token): void
    {
        $infoToken = $this->validarTokenActivo($token);
        $coleccionId = (int) $infoToken['coleccion_id'];
        $fotografoId = (int) $infoToken['fotografo_id'];

        if (!isset($_FILES['archivos'])) {
            Response::error('Debes enviar al menos un archivo en el campo "archivos".', 400);
        }

        $request = new Request();
        $data = array_merge($request->getBody(), $_POST);
        $nombreInvitado = isset($data['nombre_invitado']) ? trim((string) $data['nombre_invitado']) : 'Invitado';

        $archivos = $this->normalizarArchivos($_FILES['archivos']);
        $subidos = [];
        $excedentes = [];

        // Consultar cuota usada por el fotógrafo dueño de la colección (CF-07 / RF17)
        $espacioUsado = $this->multimediaRepository->espacioUsadoPorFotografo($fotografoId);
        $maxCuota = Config::maxStorageBytes();

        foreach ($archivos as $archivo) {
            $tamano = (int) $archivo['size'];
            $nombreOriginal = $archivo['name'] ?? 'archivo';

            // Comprobar cuota restante antes de validar el archivo (RF17)
            if (($espacioUsado + $tamano) > $maxCuota) {
                $excedentes[] = [
                    'archivo' => $nombreOriginal,
                    'tamanio' => $tamano,
                    'motivo'  => 'Excede la cuota máxima de almacenamiento del fotógrafo (3 GB).',
                ];
                continue;
            }

            // Validar con las restricciones de invitado (JPG/MP4 y máx 800 MB por archivo, CF-04)
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
            $espacioUsado += $tamano;
        }

        if (empty($subidos) && !empty($excedentes)) {
            Response::error('No se pudo subir ningún archivo porque se excede la cuota de 3 GB del fotógrafo.', 400, $excedentes);
        }

        $mensaje = !empty($excedentes)
            ? 'Carga colaborativa recibida parcialmente: algunos archivos excedieron la cuota de 3 GB.'
            : 'Carga colaborativa recibida exitosamente.';

        $aviso = 'Tus archivos han sido subidos y serán revisados por el fotógrafo. Los no aprobados se eliminarán en 24 horas.';

        Response::success([
            'subidos'  => count($subidos),
            'excedentes' => $excedentes,
            'aviso'    => $aviso,
        ], $mensaje, 201);
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

    /**
     * Construye la URL que codifica el QR colaborativo: debe abrir el formulario
     * de subida del invitado (frontend-cliente/pages/colaborativo.html?token=...),
     * nunca una respuesta JSON del API.
     * CÓMO: En producción se usa la variable de entorno FRONTEND_URL (raíz del servidor
     * estático que contiene las carpetas frontend-cliente y frontend-fotografo). En
     * desarrollo se deduce la raíz a partir del Referer que envía la página estática.
     * Si no se puede deducir, se conserva la URL del API (comportamiento histórico).
     */
    private function armarUrlColaborativo(string $token): string
    {
        $base = getenv('FRONTEND_URL');
        if (is_string($base) && trim($base) !== '') {
            return rtrim(trim($base), '/') . '/frontend-cliente/pages/colaborativo.html?token=' . rawurlencode($token);
        }

        $referer = $_SERVER['HTTP_REFERER'] ?? '';
        if (is_string($referer) && $referer !== '') {
            $partes = parse_url($referer);
            if (isset($partes['scheme'], $partes['host'], $partes['path']) && $partes['host'] !== '') {
                $rutaDerivada = preg_replace('#/frontend-(fotografo|cliente)(/.*)?$#', '', $partes['path']);

                // Solo se puede deducir la raíz si el Referer proviene de una página
                // real de las apps (frontend-fotografo o frontend-cliente), nunca de
                // la raíz del servidor estático o de listados de carpetas.
                $esOrigenFrontend = is_string($rutaDerivada)
                    && $rutaDerivada !== $partes['path']
                    && $partes['path'] !== '/';
                if ($esOrigenFrontend) {
                    $origen = $partes['scheme'] . '://' . $partes['host'];
                    if (isset($partes['port'])) {
                        $origen .= ':' . $partes['port'];
                    }
                    $rutaDerivada = rtrim($rutaDerivada, '/');
                    return $origen . $rutaDerivada . '/frontend-cliente/pages/colaborativo.html?token=' . rawurlencode($token);
                }
            }
        }

        return $this->armarUrlFront('/colaborativo/' . $token);
    }

    /**
     * Construye la URL que codifica el QR/enlace de acceso permanente: debe abrir la
     * página del cliente que canjea invitaciones (frontend-cliente/pages/tuscoleccionescliente.html?invitacion=...),
     * nunca una respuesta JSON del API. Misma lógica de origen que armarUrlColaborativo().
     */
    private function armarUrlInvitacion(string $token): string
    {
        $base = getenv('FRONTEND_URL');
        if (is_string($base) && trim($base) !== '') {
            return rtrim(trim($base), '/') . '/frontend-cliente/pages/tuscoleccionescliente.html?invitacion=' . rawurlencode($token);
        }

        $referer = $_SERVER['HTTP_REFERER'] ?? '';
        if (is_string($referer) && $referer !== '') {
            $partes = parse_url($referer);
            if (isset($partes['scheme'], $partes['host'], $partes['path']) && $partes['host'] !== '') {
                $rutaDerivada = preg_replace('#/frontend-(fotografo|cliente)(/.*)?$#', '', $partes['path']);

                $esOrigenFrontend = is_string($rutaDerivada)
                    && $rutaDerivada !== $partes['path']
                    && $partes['path'] !== '/';
                if ($esOrigenFrontend) {
                    $origen = $partes['scheme'] . '://' . $partes['host'];
                    if (isset($partes['port'])) {
                        $origen .= ':' . $partes['port'];
                    }
                    $rutaDerivada = rtrim($rutaDerivada, '/');
                    return $origen . $rutaDerivada . '/frontend-cliente/pages/tuscoleccionescliente.html?invitacion=' . rawurlencode($token);
                }
            }
        }

        return $this->armarUrlFront('/invitaciones/' . $token);
    }
}
