<?php

declare(strict_types=1);

namespace App\Core;

/**
 * Abstracción orientada a objetos de una petición HTTP.
 * 
 * Captura y procesa método, ruta, encabezados, token Bearer, cuerpo JSON,
 * parámetros de URL y archivos subidos ($_FILES).
 */
class Request
{
    private string $method;
    private string $uri;
    private array $queryParams;
    private array $body;
    private array $headers;
    private array $files;
    private array $routeParams = [];
    private ?array $user = null;

    public function __construct()
    {
        $this->method = strtoupper($_SERVER['REQUEST_METHOD'] ?? 'GET');
        $this->uri = $this->parseUri();
        $this->queryParams = $_GET;
        $this->headers = $this->parseHeaders();
        $this->files = $_FILES;
        $this->body = $this->parseBody();
    }

    private function parseUri(): string
    {
        $requestUri = $_SERVER['REQUEST_URI'] ?? '/';
        $parsedPath = parse_url($requestUri, PHP_URL_PATH) ?? '/';
        
        $trimmedPath = rtrim($parsedPath, '/');
        return $trimmedPath === '' ? '/' : $trimmedPath;
    }

    private function parseHeaders(): array
    {
        if (function_exists('getallheaders')) {
            $headers = getallheaders();
            if ($headers !== false) {
                return $headers;
            }
        }

        $headers = [];
        foreach ($_SERVER as $key => $value) {
            if (str_starts_with($key, 'HTTP_')) {
                $headerName = str_replace('_', '-', substr($key, 5));
                $headers[ucwords(strtolower($headerName), '-')] = (string) $value;
            } elseif ($key === 'CONTENT_TYPE') {
                $headers['Content-Type'] = (string) $value;
            } elseif ($key === 'CONTENT_LENGTH') {
                $headers['Content-Length'] = (string) $value;
            }
        }
        return $headers;
    }

    private function parseBody(): array
    {
        if ($this->method === 'GET' || $this->method === 'HEAD') {
            return [];
        }

        // Si es formulario multipart o urlencoded estándar
        $contentType = $this->getHeader('Content-Type') ?? '';
        if (str_contains($contentType, 'multipart/form-data') || str_contains($contentType, 'application/x-www-form-urlencoded')) {
            return $_POST;
        }

        // Stream crudo para JSON
        $rawInput = file_get_contents('php://input');
        if ($rawInput === false || trim($rawInput) === '') {
            return $_POST;
        }

        $decoded = json_decode($rawInput, true);
        return (json_last_error() === JSON_ERROR_NONE && is_array($decoded)) ? $decoded : $_POST;
    }

    /**
     * Extrae el token de autenticación Bearer de la cabecera Authorization.
     * 
     * @return string|null Token en texto plano si se proporcionó, null en caso contrario.
     */
    public function getBearerToken(): ?string
    {
        $authHeader = $this->getHeader('Authorization');
        if (!$authHeader && isset($_SERVER['HTTP_AUTHORIZATION'])) {
            $authHeader = $_SERVER['HTTP_AUTHORIZATION'];
        }

        if ($authHeader && preg_match('/Bearer\s+(\S+)/i', $authHeader, $matches)) {
            return $matches[1];
        }

        // Fallback para clientes que envíen el token por query param (ej. descargas directas)
        if (isset($this->queryParams['token']) && is_string($this->queryParams['token'])) {
            return $this->queryParams['token'];
        }

        return null;
    }

    public function getMethod(): string
    {
        return $this->method;
    }

    public function getUri(): string
    {
        return $this->uri;
    }

    public function getQueryParams(): array
    {
        return $this->queryParams;
    }

    public function getQueryParam(string $key, mixed $default = null): mixed
    {
        return $this->queryParams[$key] ?? $default;
    }

    public function getBody(): array
    {
        return $this->body;
    }

    public function getBodyParam(string $key, mixed $default = null): mixed
    {
        return $this->body[$key] ?? $default;
    }

    public function getHeaders(): array
    {
        return $this->headers;
    }

    public function getHeader(string $name, ?string $default = null): ?string
    {
        $normalizedName = strtolower($name);
        foreach ($this->headers as $key => $value) {
            if (strtolower($key) === $normalizedName) {
                return $value;
            }
        }
        return $default;
    }

    public function getFile(string $key): ?array
    {
        return $this->files[$key] ?? null;
    }

    public function setRouteParams(array $params): void
    {
        $this->routeParams = $params;
    }

    public function getRouteParams(): array
    {
        return $this->routeParams;
    }

    public function getRouteParam(string $key, mixed $default = null): mixed
    {
        return $this->routeParams[$key] ?? $default;
    }

    public function setUser(array $user): void
    {
        $this->user = $user;
    }

    public function getUser(): ?array
    {
        return $this->user;
    }
}
