<?php

/**
 * CLASE RESPONSE (respuesta)
 * ------------------------------------------------------------------
 * Se encarga de una sola cosa: contestarle al cliente en formato JSON.
 *
 * Sus métodos son ESTÁTICOS. Eso quiere decir que se usan directamente
 * con :: y no hace falta crear un objeto:
 *
 *     Response::success($product);          <-- así
 *     $r = new Response(); $r->success();   <-- NO hace falta
 *
 * ¿Cuándo conviene un método estático? Cuando la clase no necesita
 * "recordar" nada. Response no guarda datos, solo hace un trabajo.
 */
class Response
{
    /**
     * Todo salió bien.
     *
     * @param mixed  $data    Lo que le devolvemos al cliente.
     * @param string $message Texto opcional.
     * @param int    $status  200 = OK, 201 = se creó algo nuevo.
     */
    public static function success($data = null, $message = '', $status = 200)
    {
        self::send([
            'ok'      => true,
            'mensaje' => $message,
            'datos'   => $data,
        ], $status);
    }

    /**
     * Algo salió mal.
     *
     * @param string $message Qué pasó.
     * @param int    $status  400, 401, 403, 404...
     * @param array  $errors  Lista de errores de validación (opcional).
     */
    public static function error($message, $status = 400, $errors = [])
    {
        self::send([
            'ok'      => false,
            'mensaje' => $message,
            'errores' => $errors,
        ], $status);
    }

    /**
     * Manda el JSON y TERMINA el programa.
     *
     * Es privado porque solo lo usan success() y error(), que están acá
     * adentro. Desde afuera nadie puede llamarlo (encapsulamiento).
     */
    private static function send($body, $status)
    {
        // El código de estado HTTP: le dice al cliente cómo salió todo.
        http_response_code($status);

        // Avisamos que lo que mandamos es JSON.
        header('Content-Type: application/json; charset=utf-8');

        echo json_encode($body, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);

        // exit corta la ejecución acá mismo: después de responder,
        // no hay nada más que hacer.
        exit;
    }
}
