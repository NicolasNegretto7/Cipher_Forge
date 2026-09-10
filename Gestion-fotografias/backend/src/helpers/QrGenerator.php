<?php
// QUÉ: Generador nativo de códigos QR estándar (ISO/IEC 18004, modo byte, ECC L, versiones 1-7) en SVG.
// POR QUÉ: Los QR de evento y de acceso permanente deben poder escanearse con cámaras reales (RF13/RF14,
//          RF16 / HU4, HU7, HU11, HU17); un encoder propio no estándar no es legible por lectores convencionales.
// CÓMO: Codifica en modo byte, aplica códigos Reed-Solomon sobre GF(256), escribe información de formato
//       (BCH 15,5 con máscara 0x5412), información de versión (BCH 18,6) para versión >= 7 y elige la
//       máscara con menor penalidad del estándar (reglas N1-N4). Emite SVG vectorial y plantillas imprimibles.

declare(strict_types=1);

namespace App\helpers;

class QrGenerator
{
    // ---------------------------------------------------------------
    // Constantes del estándar. Nivel de corrección de errores: L.
    // NIVEL_L[v] = [total de palabras de datos, ECC por bloque, número de bloques]
    // ---------------------------------------------------------------
    private const NIVEL_L = [
        1 => [19, 7, 1],
        2 => [34, 10, 1],
        3 => [55, 15, 1],
        4 => [80, 20, 1],
        5 => [108, 26, 1],
        6 => [136, 36, 1],
        7 => [156, 20, 2],
    ];

    /** Posiciones (fila/columna) de los patrones de alineación por versión. */
    private const ALINEACION = [
        1 => [],
        2 => [6, 18],
        3 => [6, 22],
        4 => [6, 26],
        5 => [6, 30],
        6 => [6, 34],
        7 => [6, 22, 38],
    ];

    /** Polinomio generador BCH(15,5) y máscara del bloque de información de formato. */
    private const G15_FORMATO = 0x537;
    private const MASCARA_FORMATO = 0x5412;

    /** Polinomio generador BCH(18,6) de la información de versión. */
    private const G18_VERSION = 0x1F25;

    /** Tablas de exponentes/logaritmos de GF(256) con polinomio primitivo 0x11D. */
    private static array $exp = [];
    private static array $log = [];
    private static bool $gfInicializado = false;

    /**
     * Genera un código QR en formato SVG vectorial a partir de una URL o texto.
     * Retorna el string XML/SVG listo para incrustar o servir como imagen.
     */
    public static function svg(string $text, int $size = 300): string
    {
        $matrix = self::generarMatriz($text);
        $modulos = count($matrix);
        $quietZone = 4;
        $totalModulos = $modulos + ($quietZone * 2);
        $moduloSize = $size / $totalModulos;

        $rects = '';
        for ($y = 0; $y < $modulos; $y++) {
            for ($x = 0; $x < $modulos; $x++) {
                if ($matrix[$y][$x] === 1) {
                    $posX = number_format(($x + $quietZone) * $moduloSize, 2, '.', '');
                    $posY = number_format(($y + $quietZone) * $moduloSize, 2, '.', '');
                    $width = number_format($moduloSize + 0.05, 2, '.', '');
                    $height = number_format($moduloSize + 0.05, 2, '.', '');
                    $rects .= "<rect x=\"{$posX}\" y=\"{$posY}\" width=\"{$width}\" height=\"{$height}\" fill=\"#1a1a1a\" />\n";
                }
            }
        }

        return <<<SVG
<svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="{$size}" height="{$size}" viewBox="0 0 {$size} {$size}">
    <rect width="100%" height="100%" fill="#ffffff" />
    {$rects}
</svg>
SVG;
    }

    /**
     * Genera una página HTML responsive y con estilos de impresión para exponer físicamente el QR (HU7).
     */
    public static function renderPrintableHtml(string $tituloEvento, string $urlAcceso, string $svgQr, ?string $expiracion = null): string
    {
        $expiracionHtml = $expiracion
            ? "<p class=\"expira\">⚡ Código válido hasta: <strong>{$expiracion}</strong> (caduca en 24 horas)</p>"
            : "<p class=\"permanente\">🔒 Enlace de acceso exclusivo</p>";

        return <<<HTML
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>QR del Evento - {$tituloEvento}</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; }
        body { background: #f4f6f8; display: flex; justify-content: center; align-items: center; min-height: 100vh; padding: 20px; }
        .card { background: #ffffff; max-width: 480px; width: 100%; border-radius: 16px; box-shadow: 0 8px 30px rgba(0,0,0,0.12); padding: 40px; text-align: center; border: 1px solid #e2e8f0; }
        .logo { font-size: 14px; text-transform: uppercase; letter-spacing: 2px; color: #64748b; font-weight: 700; margin-bottom: 12px; }
        h1 { font-size: 26px; color: #0f172a; margin-bottom: 10px; line-height: 1.2; }
        p.desc { font-size: 15px; color: #475569; margin-bottom: 24px; line-height: 1.5; }
        .qr-box { display: inline-block; padding: 16px; background: #ffffff; border: 2px solid #0f172a; border-radius: 12px; margin-bottom: 24px; box-shadow: 0 4px 12px rgba(0,0,0,0.05); }
        .qr-box svg { display: block; max-width: 100%; height: auto; }
        .instructions { background: #fafafa; border-radius: 8px; padding: 14px; margin-bottom: 20px; font-size: 14px; color: #334155; text-align: left; }
        .instructions ol { padding-left: 20px; margin-top: 6px; }
        .instructions li { margin-bottom: 4px; }
        .expira { font-size: 13px; color: #dc2626; font-weight: 500; }
        .permanente { font-size: 13px; color: #059669; font-weight: 500; }
        .url-box { font-size: 12px; color: #94a3b8; word-break: break-all; margin-top: 16px; }
        .btn-print { margin-top: 20px; background: #0f172a; color: #ffffff; border: none; padding: 12px 24px; border-radius: 8px; font-size: 15px; font-weight: 600; cursor: pointer; transition: background 0.2s; }
        .btn-print:hover { background: #334155; }
        @media print {
            body { background: #ffffff; padding: 0; }
            .card { box-shadow: none; border: none; padding: 10px; max-width: 100%; }
            .btn-print { display: none; }
        }
    </style>
</head>
<body>
    <div class="card">
        <div class="logo">Cipher Forge • Galería Colaborativa</div>
        <h1>{$tituloEvento}</h1>
        <p class="desc">¡Comparte tus fotos y videos de esta celebración con nosotros!</p>

        <div class="qr-box">
            {$svgQr}
        </div>

        <div class="instructions">
            <strong>Cómo participar:</strong>
            <ol>
                <li>Abre la cámara de tu celular.</li>
                <li>Apunta hacia este código QR.</li>
                <li>Selecciona y sube tus mejores fotos y videos directo a la galería.</li>
            </ol>
        </div>

        {$expiracionHtml}

        <div class="url-box">{$urlAcceso}</div>

        <button class="btn-print" onclick="window.print()"> Imprimir Cartel del Evento</button>
    </div>
</body>
</html>
HTML;
    }

    /**
     * Devuelve la matriz binaria del código QR estándar para el texto indicado.
     */
    private static function generarMatriz(string $texto): array
    {
        $version = self::elegirVersion($texto);
        $totalDatos = self::NIVEL_L[$version][0];
        $bytesDatos = self::construirBytesDatos($texto, $totalDatos);
        $codewords = self::intercalarCodewords($bytesDatos, $version);

        $mejorPenalidad = PHP_INT_MAX;
        $mejorMatriz = [];

        for ($mascara = 0; $mascara < 8; $mascara++) {
            $matriz = self::construirMatrizConMascara($codewords, $mascara, $version);
            $penalidad = self::penalidad($matriz);
            if ($penalidad < $mejorPenalidad) {
                $mejorPenalidad = $penalidad;
                $mejorMatriz = $matriz;
            }
        }

        return $mejorMatriz;
    }

    /**
     * Devuelve la menor versión (1-7) cuya capacidad en modo byte cubre el texto.
     */
    private static function elegirVersion(string $texto): int
    {
        $len = strlen($texto);
        for ($v = 1; $v <= 7; $v++) {
            // Capacidad en bytes = palabras de datos - 2 (indicador de modo + longitud).
            if ($len <= self::NIVEL_L[$v][0] - 2) {
                return $v;
            }
        }
        throw new \RuntimeException('El contenido excede la capacidad máxima del código QR (versión 7, nivel L).');
    }

    /**
     * Construye la secuencia de bytes de datos: indicador de modo byte, longitud,
     * datos, terminador, alineación a byte y palabras de relleno 0xEC/0x11.
     */
    private static function construirBytesDatos(string $texto, int $capacidadCodewords): array
    {
        $bits = '0100'; // Modo byte (ISO/IEC 18004, tabla de indicadores).
        $bits .= str_pad(decbin(strlen($texto)), 8, '0', STR_PAD_LEFT);
        for ($i = 0; $i < strlen($texto); $i++) {
            $bits .= str_pad(decbin(ord($texto[$i])), 8, '0', STR_PAD_LEFT);
        }

        $capBits = $capacidadCodewords * 8;
        if (strlen($bits) > $capBits) {
            throw new \RuntimeException('El contenido excede la capacidad del código QR.');
        }

        // Terminador (hasta 4 bits de "0") y relleno hasta el límite del byte.
        $bits .= str_repeat('0', min(4, $capBits - strlen($bits)));
        while (strlen($bits) % 8 !== 0) {
            $bits .= '0';
        }

        $bytes = [];
        while (strlen($bits) >= 8) {
            $bytes[] = (int) bindec(substr($bits, 0, 8));
            $bits = substr($bits, 8);
        }

        $rellenoAlterno = true;
        while (count($bytes) < $capacidadCodewords) {
            $bytes[] = $rellenoAlterno ? 0xEC : 0x11;
            $rellenoAlterno = !$rellenoAlterno;
        }

        return $bytes;
    }

    /**
     * Divide los datos en bloques, calcula los códigos Reed-Solomon de cada bloque
     * y entrelaza palabras de datos y de corrección según el estándar.
     */
    private static function intercalarCodewords(array $bytesDatos, int $version): array
    {
        [$totalDatos, $eccBloque, $nBloques] = self::NIVEL_L[$version];
        $cadaBloque = intdiv($totalDatos, $nBloques);

        $bloquesDatos = [];
        $bloquesEcc = [];
        for ($b = 0; $b < $nBloques; $b++) {
            $bloque = array_slice($bytesDatos, $b * $cadaBloque, $cadaBloque);
            $bloquesDatos[] = $bloque;
            $bloquesEcc[] = self::codigoReedSolomon($bloque, $eccBloque);
        }

        $resultado = [];
        for ($i = 0; $i < $cadaBloque; $i++) {
            foreach ($bloquesDatos as $bloque) {
                $resultado[] = $bloque[$i];
            }
        }
        for ($i = 0; $i < $eccBloque; $i++) {
            foreach ($bloquesEcc as $ecc) {
                $resultado[] = $ecc[$i];
            }
        }

        return $resultado;
    }

    /**
     * Calcula las palabras de corrección Reed-Solomon de un bloque de datos.
     */
    private static function codigoReedSolomon(array $datos, int $grado): array
    {
        self::inicializarGalois();

        // Polinomio generador g(x) = ∏ (x - α^i), i = 0..grado-1, con α = 2.
        $gen = [1];
        for ($i = 0; $i < $grado; $i++) {
            $gen = self::multiplicarPolinomios($gen, [1, self::$exp[$i]]);
        }

        // División sintética estándar sobre GF(256).
        $residuo = array_merge($datos, array_fill(0, $grado, 0));
        $nDatos = count($datos);
        $nGen = count($gen);
        for ($i = 0; $i < $nDatos; $i++) {
            $coeficiente = $residuo[$i];
            if ($coeficiente === 0) {
                continue;
            }
            for ($j = 0; $j < $nGen; $j++) {
                $residuo[$i + $j] ^= self::multiplicar($gen[$j], $coeficiente);
            }
        }

        return array_slice($residuo, $nDatos);
    }

    /**
     * Construye la matriz completa de un símbolo QR con la máscara indicada.
     */
    private static function construirMatrizConMascara(array $codewords, int $mascara, int $version): array
    {
        $tamano = 17 + 4 * $version;
        $m = array_fill(0, $tamano, array_fill(0, $tamano, null));

        // Patrones de búsqueda en las tres esquinas.
        self::colocarBuscador($m, 0, 0);
        self::colocarBuscador($m, $tamano - 7, 0);
        self::colocarBuscador($m, 0, $tamano - 7);
        self::colocarSeparadores($m, $tamano);

        // Patrones de alineación (menos las esquinas ocupadas por los buscadores).
        foreach (self::ALINEACION[$version] as $cy) {
            foreach (self::ALINEACION[$version] as $cx) {
                $esEsquina = ($cy === 6 && $cx === 6)
                    || ($cy === 6 && $cx === $tamano - 7)
                    || ($cy === $tamano - 7 && $cx === 6);
                if (!$esEsquina) {
                    self::colocarAlineacion($m, $cy, $cx);
                }
            }
        }

        // Patrones de sincronización (fila 6 y columna 6).
        for ($i = 8; $i < $tamano - 8; $i++) {
            $bit = ($i % 2 === 0) ? 1 : 0;
            $m[6][$i] = $bit;
            $m[$i][6] = $bit;
        }

        // Módulo oscuro fijo en (fila tamaño-8, columna 8).
        $m[$tamano - 8][8] = 1;

        // Reservar zonas de formato y, para versión >= 7, de información de versión.
        self::reservarFormato($m, $tamano);
        if ($version >= 7) {
            self::reservarVersion($m, $tamano);
        }

        // Colocar los datos con el recorrido en zig-zag y la máscara aplicada.
        self::colocarDatos($m, $codewords, $mascara, $tamano);

        // Escribir la información de formato y de versión reales.
        self::escribirFormato($m, $mascara, $tamano);
        if ($version >= 7) {
            self::escribirVersion($m, $version, $tamano);
        }

        // Las celdas que quedan sin asignar se pintan de blanco.
        for ($y = 0; $y < $tamano; $y++) {
            for ($x = 0; $x < $tamano; $x++) {
                if ($m[$y][$x] === null) {
                    $m[$y][$x] = 0;
                }
            }
        }

        return $m;
    }

    private static function colocarBuscador(array &$m, int $filaTop, int $colIzq): void
    {
        for ($r = 0; $r < 7; $r++) {
            for ($c = 0; $c < 7; $c++) {
                $borde = ($r === 0 || $r === 6 || $c === 0 || $c === 6);
                $centro = ($r >= 2 && $r <= 4 && $c >= 2 && $c <= 4);
                $m[$filaTop + $r][$colIzq + $c] = ($borde || $centro) ? 1 : 0;
            }
        }
    }

    private static function colocarSeparadores(array &$m, int $tamano): void
    {
        for ($i = 0; $i < 8; $i++) {
            $m[7][$i] = 0;
            $m[$i][7] = 0;
            $m[$tamano - 8][$i] = 0;
            $m[$i][$tamano - 8] = 0;
            $m[7][$tamano - 8 + $i] = 0;
            $m[$tamano - 8 + $i][7] = 0;
        }
    }

    private static function colocarAlineacion(array &$m, int $centroY, int $centroX): void
    {
        for ($r = -2; $r <= 2; $r++) {
            for ($c = -2; $c <= 2; $c++) {
                $distancia = max(abs($r), abs($c));
                $m[$centroY + $r][$centroX + $c] = ($distancia === 1) ? 0 : 1;
            }
        }
    }

    /**
     * Reserva (pone en 0) las celdas de los dos bloques de información de formato.
     */
    private static function reservarFormato(array &$m, int $tamano): void
    {
        for ($i = 0; $i < 15; $i++) {
            if ($i < 6) {
                $m[$i][8] = 0;
            } elseif ($i < 8) {
                $m[$i + 1][8] = 0;
            } else {
                $m[$tamano - 15 + $i][8] = 0;
            }
        }
        for ($i = 0; $i < 15; $i++) {
            if ($i < 8) {
                $m[8][$tamano - 1 - $i] = 0;
            } elseif ($i < 9) {
                $m[8][15 - $i - 1 + 1] = 0;
            } else {
                $m[8][15 - $i - 1] = 0;
            }
        }
    }

    /**
     * Reserva (pone en 0) las celdas de la información de versión.
     */
    private static function reservarVersion(array &$m, int $tamano): void
    {
        for ($i = 0; $i < 18; $i++) {
            $m[intdiv($i, 3)][($i % 3) + $tamano - 11] = 0;
            $m[($i % 3) + $tamano - 11][intdiv($i, 3)] = 0;
        }
    }

    /**
     * Recorre la matriz en zig-zag (de derecha a izquierda, saltando la columna 6)
     * colocando los bits de los codewords y aplicando la máscara indicada.
     */
    private static function colocarDatos(array &$m, array $codewords, int $mascara, int $tamano): void
    {
        $inc = -1;
        $fila = $tamano - 1;
        $bitIndex = 7;
        $byteIndex = 0;

        for ($col = $tamano - 1; $col > 0; $col -= 2) {
            if ($col === 6) {
                $col--;
            }
            while (true) {
                for ($c = 0; $c < 2; $c++) {
                    $x = $col - $c;
                    if ($m[$fila][$x] === null) {
                        $oscuro = false;
                        if ($byteIndex < count($codewords)) {
                            $oscuro = (($codewords[$byteIndex] >> $bitIndex) & 1) === 1;
                        }
                        if (self::funcionMascara($mascara, $fila, $x)) {
                            $oscuro = !$oscuro;
                        }
                        $m[$fila][$x] = $oscuro ? 1 : 0;
                        $bitIndex--;
                        if ($bitIndex === -1) {
                            $byteIndex++;
                            $bitIndex = 7;
                        }
                    }
                }
                $fila += $inc;
                if ($fila < 0 || $fila >= $tamano) {
                    $fila -= $inc;
                    $inc = -$inc;
                    break;
                }
            }
        }
    }

    private static function funcionMascara(int $mascara, int $fila, int $col): bool
    {
        switch ($mascara) {
            case 0:
                return (($fila + $col) % 2) === 0;
            case 1:
                return ($fila % 2) === 0;
            case 2:
                return ($col % 3) === 0;
            case 3:
                return (($fila + $col) % 3) === 0;
            case 4:
                return (intdiv($fila, 2) + intdiv($col, 3)) % 2 === 0;
            case 5:
                return (($fila * $col) % 2) + (($fila * $col) % 3) === 0;
            case 6:
                return ((($fila * $col) % 2) + (($fila * $col) % 3)) % 2 === 0;
            default:
                return ((($fila + $col) % 2) + (($fila * $col) % 3)) % 2 === 0;
        }
    }

    /**
     * Escribe la información de formato (nivel L + máscara seleccionada).
     */
    private static function escribirFormato(array &$m, int $mascara, int $tamano): void
    {
        // Bits de nivel de corrección para L = "01" (desplazados 3 posiciones).
        $datos = (1 << 3) | $mascara;
        $info = self::bchFormato($datos);

        for ($i = 0; $i < 15; $i++) {
            $bit = (($info >> $i) & 1) === 1 ? 1 : 0;
            if ($i < 6) {
                $m[$i][8] = $bit;
            } elseif ($i < 8) {
                $m[$i + 1][8] = $bit;
            } else {
                $m[$tamano - 15 + $i][8] = $bit;
            }
        }
        for ($i = 0; $i < 15; $i++) {
            $bit = (($info >> $i) & 1) === 1 ? 1 : 0;
            if ($i < 8) {
                $m[8][$tamano - 1 - $i] = $bit;
            } elseif ($i < 9) {
                $m[8][15 - $i - 1 + 1] = $bit;
            } else {
                $m[8][15 - $i - 1] = $bit;
            }
        }

        // Módulo oscuro fijo (no se ve afectado por la máscara).
        $m[$tamano - 8][8] = 1;
    }

    private static function bchFormato(int $datos): int
    {
        $bch = $datos << 10;
        while (self::digitosBinarios($bch) - self::digitosBinarios(self::G15_FORMATO) >= 0) {
            $bch ^= self::G15_FORMATO << (self::digitosBinarios($bch) - self::digitosBinarios(self::G15_FORMATO));
        }
        return (($datos << 10) | $bch) ^ self::MASCARA_FORMATO;
    }

    private static function digitosBinarios(int $n): int
    {
        $conteo = 0;
        while ($n > 0) {
            $conteo++;
            $n >>= 1;
        }
        return $conteo;
    }

    /**
     * Escribe la información de versión (solo para versión >= 7).
     */
    private static function escribirVersion(array &$m, int $version, int $tamano): void
    {
        $info = self::bchVersion($version);
        for ($i = 0; $i < 18; $i++) {
            $bit = (($info >> $i) & 1) === 1 ? 1 : 0;
            $m[intdiv($i, 3)][($i % 3) + $tamano - 11] = $bit;
            $m[($i % 3) + $tamano - 11][intdiv($i, 3)] = $bit;
        }
    }

    private static function bchVersion(int $version): int
    {
        $bch = $version << 12;
        while (self::digitosBinarios($bch) - self::digitosBinarios(self::G18_VERSION) >= 0) {
            $bch ^= self::G18_VERSION << (self::digitosBinarios($bch) - self::digitosBinarios(self::G18_VERSION));
        }
        return ($version << 12) | $bch;
    }

    /**
     * Penalidad de la matriz según las reglas N1-N4 del estándar: cuanto menor, mejor la máscara.
     */
    private static function penalidad(array $m): int
    {
        $tamano = count($m);
        $total = 0;

        // Regla 1: corridas de 5 o más módulos del mismo color.
        for ($y = 0; $y < $tamano; $y++) {
            $runColor = null;
            $runLen = 0;
            for ($x = 0; $x < $tamano; $x++) {
                if ($m[$y][$x] === $runColor) {
                    $runLen++;
                } else {
                    if ($runLen >= 5) {
                        $total += 3 + ($runLen - 5);
                    }
                    $runColor = $m[$y][$x];
                    $runLen = 1;
                }
            }
            if ($runLen >= 5) {
                $total += 3 + ($runLen - 5);
            }
        }
        for ($x = 0; $x < $tamano; $x++) {
            $runColor = null;
            $runLen = 0;
            for ($y = 0; $y < $tamano; $y++) {
                if ($m[$y][$x] === $runColor) {
                    $runLen++;
                } else {
                    if ($runLen >= 5) {
                        $total += 3 + ($runLen - 5);
                    }
                    $runColor = $m[$y][$x];
                    $runLen = 1;
                }
            }
            if ($runLen >= 5) {
                $total += 3 + ($runLen - 5);
            }
        }

        // Regla 2: bloques de 2x2 del mismo color.
        for ($y = 0; $y < $tamano - 1; $y++) {
            for ($x = 0; $x < $tamano - 1; $x++) {
                if ($m[$y][$x] === $m[$y][$x + 1]
                    && $m[$y][$x] === $m[$y + 1][$x]
                    && $m[$y][$x] === $m[$y + 1][$x + 1]) {
                    $total += 3;
                }
            }
        }

        // Regla 3: patrón 1,0,1,1,1,0,1 con 4 módulos claros consecutivos a un lado.
        $patron = [1, 0, 1, 1, 1, 0, 1];
        for ($y = 0; $y < $tamano; $y++) {
            for ($x = 0; $x <= $tamano - 7; $x++) {
                $coincide = true;
                for ($k = 0; $k < 7; $k++) {
                    if ($m[$y][$x + $k] !== $patron[$k]) {
                        $coincide = false;
                        break;
                    }
                }
                if ($coincide && (self::cuatroClarosAntes($m, $y, $x, $tamano) || self::cuatroClarosDespues($m, $y, $x + 7, $tamano))) {
                    $total += 40;
                }
            }
        }
        for ($x = 0; $x < $tamano; $x++) {
            for ($y = 0; $y <= $tamano - 7; $y++) {
                $coincide = true;
                for ($k = 0; $k < 7; $k++) {
                    if ($m[$y + $k][$x] !== $patron[$k]) {
                        $coincide = false;
                        break;
                    }
                }
                if ($coincide && (self::cuatroClarosArriba($m, $y, $x, $tamano) || self::cuatroClarosAbajo($m, $y + 7, $x, $tamano))) {
                    $total += 40;
                }
            }
        }

        // Regla 4: proporción de módulos oscuros.
        $oscuros = 0;
        foreach ($m as $fila) {
            $oscuros += array_sum($fila);
        }
        $proporcion = abs(($oscuros * 100) / ($tamano * $tamano) - 50);
        $total += intdiv((int) $proporcion, 5) * 10;

        return $total;
    }

    private static function cuatroClarosAntes(array $m, int $fila, int $col, int $tamano): bool
    {
        if ($col < 4 || $col > $tamano) {
            return false;
        }
        return $m[$fila][$col - 1] === 0 && $m[$fila][$col - 2] === 0 && $m[$fila][$col - 3] === 0 && $m[$fila][$col - 4] === 0;
    }

    private static function cuatroClarosDespues(array $m, int $fila, int $colInicio, int $tamano): bool
    {
        if ($colInicio + 4 > $tamano) {
            return false;
        }
        return $m[$fila][$colInicio] === 0 && $m[$fila][$colInicio + 1] === 0 && $m[$fila][$colInicio + 2] === 0 && $m[$fila][$colInicio + 3] === 0;
    }

    private static function cuatroClarosArriba(array $m, int $fila, int $col, int $tamano): bool
    {
        if ($fila < 4 || $fila > $tamano) {
            return false;
        }
        return $m[$fila - 1][$col] === 0 && $m[$fila - 2][$col] === 0 && $m[$fila - 3][$col] === 0 && $m[$fila - 4][$col] === 0;
    }

    private static function cuatroClarosAbajo(array $m, int $fila, int $col, int $tamano): bool
    {
        if ($fila + 4 > $tamano) {
            return false;
        }
        return $m[$fila][$col] === 0 && $m[$fila + 1][$col] === 0 && $m[$fila + 2][$col] === 0 && $m[$fila + 3][$col] === 0;
    }

    // ---------------------------------------------------------------
    // Aritmética sobre GF(256) con polinomio primitivo x^8+x^4+x^3+x^2+1 (0x11D).
    // ---------------------------------------------------------------
    private static function inicializarGalois(): void
    {
        if (self::$gfInicializado) {
            return;
        }
        self::$exp = array_fill(0, 512, 0);
        self::$log = array_fill(0, 256, 0);

        $x = 1;
        for ($i = 0; $i < 255; $i++) {
            self::$exp[$i] = $x;
            self::$log[$x] = $i;
            $x <<= 1;
            if ($x & 0x100) {
                $x ^= 0x11D;
            }
        }
        for ($i = 255; $i < 512; $i++) {
            self::$exp[$i] = self::$exp[$i - 255];
        }
        self::$gfInicializado = true;
    }

    private static function multiplicar(int $a, int $b): int
    {
        if ($a === 0 || $b === 0) {
            return 0;
        }
        return self::$exp[self::$log[$a] + self::$log[$b]];
    }

    private static function multiplicarPolinomios(array $a, array $b): array
    {
        $resultado = array_fill(0, count($a) + count($b) - 1, 0);
        foreach ($a as $i => $ai) {
            foreach ($b as $j => $bj) {
                $resultado[$i + $j] ^= self::multiplicar($ai, $bj);
            }
        }
        return $resultado;
    }
}