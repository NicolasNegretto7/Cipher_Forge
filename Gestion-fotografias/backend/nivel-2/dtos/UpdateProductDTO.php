<?php

/**
 * DTO PARA ACTUALIZAR UN PRODUCTO (Data Transfer Object)
 * ==================================================================
 * Un DTO recibe datos que el validator ya aprobó, les da una FORMA
 * conocida, los NORMALIZA, los TIPA y los transporta hasta el service.
 * Así ProductService no necesita trabajar con el arreglo crudo que llegó
 * desde HTTP.
 *
 * En PUT /productos/{id} el cliente manda solamente lo que quiere
 * cambiar. Por eso este DTO no tiene cinco propiedades obligatorias:
 * selecciona y guarda en $fields únicamente los campos permitidos que
 * llegaron. Los textos se normalizan, el precio se convierte a float y
 * el stock a int.
 *
 * Primero ProductValidator::validateUpdate() valida y después el
 * controller crea este DTO. El DTO NO valida, no busca el producto, no
 * decide si se puede modificar y no responde HTTP.
 * ==================================================================
 */
class UpdateProductDTO
{
    // "private array" tipa el contenedor: esta propiedad siempre es un arreglo.
    // Cada valor también se convierte al tipo que necesita antes de guardarlo.
    // = [] le asigna un arreglo vacío como valor inicial.
    private array $fields = [];

    public function __construct(array $data)
    {
        // array_key_exists() pregunta si la clave vino en el JSON.
        // No usamos ?? porque necesitamos recordar exactamente qué campos llegaron.
        if (array_key_exists('nombre', $data)) {
            $this->fields['nombre'] = trim($data['nombre']);
        }

        if (array_key_exists('descripcion', $data)) {
            $this->fields['descripcion'] = trim($data['descripcion']);
        }

        if (array_key_exists('precio', $data)) {
            // El cast (float) convierte el valor validado a número decimal.
            $this->fields['precio'] = (float) $data['precio'];
        }

        if (array_key_exists('stock', $data)) {
            // El cast (int) convierte el valor validado a número entero.
            $this->fields['stock'] = (int) $data['stock'];
        }

        if (array_key_exists('categoria', $data)) {
            $this->fields['categoria'] = trim($data['categoria']);
        }
    }

    /**
     * has() responde si el cliente envió un campo.
     * "string $field" exige texto y ": bool" devuelve true o false.
     */
    public function has(string $field): bool
    {
        return array_key_exists($field, $this->fields);
    }

    /**
     * get() entrega el valor guardado.
     * ?? null evita un error si se consulta una clave que no existe.
     */
    public function get(string $field)
    {
        return $this->fields[$field] ?? null;
    }
}
