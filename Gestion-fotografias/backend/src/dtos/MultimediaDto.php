<?php
// QUÉ: DTO inmutable que transporta los metadatos validados de un archivo multimedia subido.
// POR QUÉ: Entrega datos tipados (tipo, título, descripción, colección) entre el validador,
//          el servicio y el repositorio, manteniendo la arquitectura en capas del proyecto.

declare(strict_types=1);

namespace App\dtos;

class MultimediaDto
{
    public function __construct(
        public readonly int     $coleccionId,
        public readonly string  $tipo,          // 'imagen' | 'video'
        public readonly ?string $titulo = null,
        public readonly ?string $descripcion = null,
        public readonly bool    $esInvitado = false,
    ) {}
}
