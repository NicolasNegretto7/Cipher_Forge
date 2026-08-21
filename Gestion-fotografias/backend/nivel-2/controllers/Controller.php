<?php

/**
 * CLASE CONTROLLER (controlador)  -  clase PADRE
 * ==================================================================
 * El CONTROLLER es el que habla con el mundo de afuera (HTTP):
 *
 *   1. agarra los datos que llegaron en el pedido
 *   2. le pide al VALIDATOR que revise la entrada
 *   3. crea un DTO con los datos válidos, cuando corresponde
 *   4. le pide el trabajo al SERVICE
 *   5. contesta
 *
 * Lo que el controller NO hace: reglas del negocio (eso es del
 * service), buscar datos (eso es del repository), NI decidir quién
 * puede entrar (eso ya lo resolvió el AuthMiddleware, antes de que
 * el controller siquiera se instancie — mirá Router::dispatch()).
 *
 * Los controllers necesitan lo mismo, así que lo escribimos una sola
 * vez acá y lo heredan. Eso es HERENCIA: escribir una vez, usar en
 * todos lados.
 *
 * Esta clase no se usa sola: no tiene sentido hacer new Controller().
 * ==================================================================
 */
class Controller
{
    /**
     * Lee el JSON que mandó el cliente y lo convierte en arreglo.
     *
     * Los datos de un POST o un PUT en formato JSON no llegan en
     * $_POST: hay que leerlos del "cuerpo" del pedido con php://input.
     */
    protected function requestData()
    {
        $json = file_get_contents('php://input');

        $data = json_decode($json, true);

        // Si no mandaron nada, o mandaron algo que no es JSON,
        // devolvemos un arreglo vacío para no romper el programa.
        if (!is_array($data)) {
            return [];
        }

        return $data;
    }

    /**
     * El usuario logueado (id, nombre, rol), para el controller que lo
     * necesite — por ejemplo AuthController::profile().
     *
     * Si la ruta no pedía login (middleware null), esto devuelve null.
     * Si lo pedía ('auth' o 'admin'), el AuthMiddleware ya lo validó
     * ANTES de llegar acá y lo dejó guardado.
     */
    protected function user(): ?array
    {
        return AuthMiddleware::user();
    }
}
