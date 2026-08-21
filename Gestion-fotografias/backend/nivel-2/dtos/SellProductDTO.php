<?php

/**
 * DTO PARA VENDER UN PRODUCTO (Data Transfer Object)
 * ==================================================================
 * Un DTO recibe datos que el validator ya aprobó, les da una FORMA
 * conocida, los NORMALIZA, los TIPA y los transporta hasta el service.
 * De esa manera, ProductService recibe un contrato claro y no trabaja
 * directamente con el arreglo crudo que llegó desde HTTP.
 *
 * Este endpoint solo necesita transportar una cantidad, por eso su DTO
 * tiene una única propiedad. Mantenerlo separado deja explícito qué dato
 * necesita la operación de venta y garantiza que llegue como int.
 *
 * Primero ProductValidator::validateSell() valida y después el controller
 * crea este DTO. El DTO NO valida el stock disponible, no consulta la base,
 * no realiza la venta y no responde HTTP.
 * ==================================================================
 */
class SellProductDTO
{
    // int obliga a que quantity sea un número entero.
    private int $quantity;

    public function __construct(array $data)
    {
        // El operador ?? usa 1 si no vino cantidad; (int) fija el tipo.
        $this->quantity = (int) ($data['cantidad'] ?? 1);
    }

    // El service usa este getter para leer la cantidad privada.
    public function getQuantity(): int
    {
        return $this->quantity;
    }
}
