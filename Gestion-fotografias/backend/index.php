<?php
header('Content-Type: application/json');


$metod = $_SERVER['REQUEST METHOD'];

$uri = parse_url($_SERVER['REQUEST_URI'],PHP_URL_PATH);

$uri = trim($uri, '/');

