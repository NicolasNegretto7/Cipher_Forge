<?php
require '/var/www/html/src/Core/Config.php';
require '/var/www/html/src/helpers/MediaProcessor.php';

set_time_limit(35);
$t = microtime(true);
$info = @getimagesize('/var/www/html/uploads/test_big.png');
echo 'size: ' . $info[0] . 'x' . $info[1] . ' mime=' . $info['mime'] . PHP_EOL;
try {
    $r = \App\helpers\MediaProcessor::generarPreviewImagen('/var/www/html/uploads/test_big.png');
    echo 'res: [' . $r . '] time=' . round(microtime(true) - $t, 2) . 's' . PHP_EOL;
} catch (\Throwable $e) {
    echo 'EX: ' . $e->getMessage() . PHP_EOL;
}
echo 'done' . PHP_EOL;