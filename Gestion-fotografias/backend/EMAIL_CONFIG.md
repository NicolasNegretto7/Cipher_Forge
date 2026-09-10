# Envío de correos — Verificación por email (CF-02)

## Contexto

El hallazgo **CF-02** detectó que el requisito RF18 ("enviar un código de verificación al correo
del usuario") no se cumplía: el backend generaba el código pero **nunca enviaba ningún correo**;
el código solo se devolvía en la respuesta del API.

La resolución aprobada:
- Implementar **un mensaje personalizado** con el código de verificación y **enviarlo por correo**.
- Usar un **buzón SMTP local de desarrollo (Mailpit)** para poder verificar la entrega sin
  credenciales reales ni servicios de terceros.
- **Alcance excluido:** la integración con **Gmail** (OAuth2/App Password) o cualquier proveedor
  externo de correo queda **fuera de alcance**. Este documento describe únicamente el transporte
  local; la conexión con Gmail es una integración futura.

## Qué hace hoy el sistema

1. `POST /auth/register` crea el usuario, genera el código de 6 dígitos con 1 hora de validez y
   llama a `App\helpers\Mailer::enviarVerificacion(...)`, que compone un correo personalizado
   (texto plano + HTML) y lo entrega por SMTP.
2. `POST /auth/reenviar-codigo` hace lo mismo para regenerar el código.
3. El resultado del intento se expone como `email_enviado` en la respuesta.

> **Nota:** el campo `codigo_verificacion` se sigue devolviendo en la respuesta JSON **en
> desarrollo** para permitir el testing ágil y las pruebas E2E. Cuando el correo real sea el
> canal confiable (o se integre Gmail), ese campo debería quitarse de las respuestas.

## Cómo funciona en desarrollo

- Se agrega el contenedor **mailpit** (`axllent/mailpit`) al `docker-compose.yml`.
- La app envía el correo al SMTP de mailpit (puerto `1025`) usando la clase `Mailer`
  (cliente SMTP en PHP puro, sin Composer ni librerías externas).
- Mailpit guarda los correos y los muestra en: **http://localhost:8025**

Pasos:

1. Levantar el stack: `docker compose up -d --build`
2. Registrar un usuario (o reenviar el código).
3. Abrir `http://localhost:8025` y ver el correo entrante con el código.

## Nota sobre tildes (UTF-8) en Mailpit

El correo se compone y se envía siempre en **UTF-8 correcto** (asunto en encoded-word
RFC 2047 `=?UTF-8?B?...?=` y cuerpo con `charset=UTF-8`; verificado a nivel de bytes en el
SMTP). **Mailpit no interpreta `charset=UTF-8` al renderizar**, por lo que en su interfaz las
tildes pueden verse como `cÃ³digo` en lugar de `código`. No es un problema de los datos:
el código de verificación siempre se muestra correctamente y cualquier cliente SMTP real
que respete el estándar renderizará el mensaje bien (por eso Gmail quedó fuera de alcance
para integrarse más adelante sin cambios).

## Archivos involucrados

- `docker-compose.yml` — servicio `mailpit` + variables de entorno SMTP.
- `src/helpers/Mailer.php` — cliente SMTP mínimo y mensaje personalizado (nuevo).
- `src/services/AuthService.php` — envío del código al registrar y al reenviar.

## Variables de entorno

| Variable         | Default                   | Descripción                                  |
|------------------|---------------------------|----------------------------------------------|
| `SMTP_HOST`      | `mailpit`                 | Host del servidor SMTP                       |
| `SMTP_PORT`      | `1025`                    | Puerto SMTP (mailpit usa 1025)               |
| `SMTP_USER`      | *(vacío)*                 | Usuario SMTP si el servidor exige AUTH LOGIN |
| `SMTP_PASS`      | *(vacío)*                 | Contraseña SMTP                              |
| `MAIL_FROM`      | `no-reply@cipherforge.local` | Remitente del correo                      |
| `MAIL_FROM_NAME` | `Cipher Forge`            | Nombre visible del remitente                 |

## Alcance excluido

- **Gmail / proveedores externos (SMTP real):** fuera de alcance. La arquitectura del
  `Mailer` (host, puerto, usuario/clave vía variables de entorno) ya deja el punto de
  integración preparado para conectarse a un proveedor externo sin cambios de diseño.