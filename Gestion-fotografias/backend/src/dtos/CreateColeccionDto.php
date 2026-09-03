<?php
// QUÉ: DTO inmutable que transporta los datos validados para la creación de una colección.
// POR QUÉ: Evita el paso de arrays asociativos sin tipar entre el validador, servicio y repositorio.

declare(strict_types=1);

namespace App\dtos;

class CreateColeccionDto
{
    public function __construct(
        public readonly int     $fotografoId,
        public readonly string  $titulo,
        public readonly string  $tipoVisibilidad,
        public readonly ?string $descripcion = null,
    ) {}
}
