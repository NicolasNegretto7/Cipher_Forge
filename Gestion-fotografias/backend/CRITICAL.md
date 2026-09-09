# Notas técnicas del Backend — Cipher Forge

Documento de trazabilidad para incidentes o correcciones aplicadas sobre el backend
durante el desarrollo de los endpoints del frontend.

---

## critical

### Error encontrado

En los endpoints de subida multipart:

- `POST /colecciones/{id}/multimedia` (subida de fotos/videos por el fotógrafo).
- `POST /colaborativo/{token}/subir` (carga colaborativa por invitados).

Los metadatos enviados por el frontend en el mismo `multipart/form-data`
(`titulo`, `descripcion` en la subida multimedia y `nombre_invitado` en la carga
colaborativa) **no llegaban al backend**.

Causa: los controladores leían los metadatos con `Request::getBody()`, que parsea
`php://input`. Cuando el cuerpo de la petición es `multipart/form-data`, `php://input`
llega vacío en PHP, por lo que esos campos siempre se recibían como `null` o con el
valor por defecto (`'Invitado'`). Solo los archivos de `$_FILES['archivos']` eran
recibidos correctamente.

### Solución aplicada

En ambos controladores se combinan las fuentes de datos antes de leer los metadatos:

```php
$data = array_merge($request->getBody(), $_POST);
```

- Los archivos se siguen tomando de `$_FILES['archivos']` (sin cambios).
- Los metadatos envíados como campos de formulario multipart se leen de `$_POST`.
- Se conserva la compatibilidad con un body JSON (`php://input`) si en el futuro se
  utiliza: `array_merge` da prioridad a `$_POST` cuando ambas fuentes vienen, por lo
  que en peticiones multipart los campos de formulario son los que prevalecen.

Archivos modificados:

- `backend/src/controllers/MultimediaController.php` (método `upload`).
- `backend/src/controllers/ColaborativoController.php` (método `subir`).

### Frente

- `frontend-fotografo/js/api.js` ya envía `titulo` y `descripcion` como campos del
  `FormData` en `api.subirMultimedia(...)`, y `nombre_invitado` como campo del
  `FormData` en `api.subirMaterialColaborativo(...)`, alineado con esta corrección.

---

## Entorno (sin modificación de código)

En pruebas E2E se detectó que el directorio `uploads/` dentro del contenedor
`cipher_forge_app` quedaba creado como `root:root` (permisos `755`) al reconstruir la
imagen, dejando a Apache (`www-data`) sin permisos de escritura. Síntomas:

- `POST /colecciones/{id}/multimedia` fallaba con 500 «No se pudo almacenar el
  archivo original» (`move_uploaded_file` sin permiso).
- `GET /multimedia/{id}/descargar?calidad=buena` servía por defecto el original en
  lugar de la copia estándar, porque `uploads/standard/` no era escribible.

Diagnóstico verificado con `ls -ld /var/www/html/uploads/*` en el contenedor.

Solución aplicada en el contenedor (entorno local, no versioneada):

```sh
docker exec cipher_forge_app sh -c "chown -R www-data:www-data /var/www/html/uploads"
```

Tras esto `calidad=buena` devuelve la copia limpia de `uploads/standard/` y la subida
funciona normalmente. Si al reconstruir la imagen vuelve a fallar la subida y la
descarga en «Buena Calidad», reaplicar el `chown` (o ajustar el `Dockerfile`/entrypoint
para crear `uploads/*` con propietario `www-data`). Sin impacto en código fuente.