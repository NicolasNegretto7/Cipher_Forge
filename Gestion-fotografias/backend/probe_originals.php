<?php
error_reporting(E_ALL);
$dir = '/var/www/html/uploads/originals/';
foreach (glob($dir . '*') as $f) {
    if (is_file($f)) {
        $i = @getimagesize($f);
        echo basename($f) . ' => ' . ($i ? ($i[0] . 'x' . $i[1] . ' mime=' . $i['mime']) : 'NO-IMAGE') . ' (' . filesize($f) . ' bytes)' . PHP_EOL;
    }
}
echo 'SPECIAL: ';
foreach (glob('/var/www/html/uploads/*.*') as $f) {
    if (is_file($f)) { echo basename($f) . ' '; }
}
echo PHP_EOL;