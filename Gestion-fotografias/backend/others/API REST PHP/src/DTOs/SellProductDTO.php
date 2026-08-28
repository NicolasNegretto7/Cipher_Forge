<?php

declare(strict_types=1);

namespace App\DTOs;

/**
 * DTO DE VENTA DE PRODUCTO (DATA TRANSFER OBJECT)
 * ==============================================================================
 * WHAT: Transporta y valida el tipo numérico entero de la cantidad a vender.
 * WHY:  Asegura que el servicio reciba un entero positivo antes de evaluar el stock.
 * ==============================================================================
 */
class SellProductDTO
{
    private int $quantity;

    public function __construct(array $data)
    {
        $this->quantity = (int) ($data['cantidad'] ?? 1);
    }

    public function getQuantity(): int
    {
        return $this->quantity;
    }
}
