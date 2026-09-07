# Auditoría y Ciclo de Vida de Endpoints — Backend API

Documento de registro técnico y auditoría para documentar el flujo de ejecución, capas involucradas y ciclo de vida de cada endpoint implementado o modificado en el sistema.

---

## 1. `POST /auth/register`

### Resumen Técnico
* **Propósito:** Registro de nuevos usuarios en la plataforma con asignación de rol (`fotografo` o `cliente`).
* **Autenticación requerida:** Ninguna (Ruta pública).
* **Códigos de respuesta:**
  * `201 Created`: Usuario creado exitosamente (retorna datos del usuario sin hash de contraseña).
  * `400 Bad Request`: Faltan campos obligatorios, formato de email inválido, contraseña menor a 8 caracteres o rol no permitido.
  * `409 Conflict`: El correo electrónico ya se encuentra registrado (RF2).
  * `500 Internal Server Error`: Error imprevisto o fallo en la transacción con la base de datos.

### Diagrama de Secuencia y Ciclo de Vida

```
1. Cliente (Insomnia / Frontend)
   │ Envía HTTP POST a http://localhost:8080/auth/register con payload JSON.
   ▼
2. .htaccess (Apache)
   │ Redirige toda solicitud que no sea archivo estático hacia public/index.php.
   ▼
3. public/index.php (Front Controller)
   │ - Registra el autoloader PSR-4 para el namespace App\...
   │ - Emite cabeceras CORS (Allow-Origin, Allow-Headers, Allow-Methods).
   │ - Captura método ('POST') y ruta normalizada ('/auth/register').
   │ - Invoca Router->dispatch($method, $path).
   ▼
4. routes.php
   │ Asocia 'POST /auth/register' con AuthController::class y método 'register'.
   ▼
5. src/Core/Router.php (Despachador)
   │ - Valida cantidad de partes de la ruta.
   │ - Ejecuta AuthMiddleware::handle(null) (pasa directo por ser pública).
   │ - Instancia $controller = new AuthController().
   │ - Llama a $controller->register().
   ▼
6. src/controllers/AuthController.php (Controlador)
   │ Coordina las capas:
   │ 1. Instancia Request para obtener el cuerpo deserializado.
   │ 2. Pasa los datos a AuthValidator->validateRegister($data).
   │ 3. Pasa el DTO a AuthService->register($dto).
   │ 4. Envía la respuesta mediante Response::success(..., 201).
   ▼
7. src/Core/Request.php
   │ Lee php://input y lo transforma mediante json_decode en un array asociativo.
   ▼
8. src/validators/AuthValidator.php (Validador)
   │ - Valida presencia de: nombre_completo, email, password, rol.
   │ - Valida formato de email mediante filter_var.
   │ - Valida longitud de contraseña (>= 8 caracteres).
   │ - Valida que rol sea estrictamente 'fotografo' o 'cliente'.
   │ - Si falla: corta con Response::error('Error de validación.', 400, $errores).
   │ - Si aprueba: retorna una instancia inmutable de RegisterDto.
   ▼
9. src/dtos/RegisterDto.php (DTO)
   │ Almacena los datos limpios con propiedades readonly tipadas.
   ▼
10. src/services/AuthService.php (Lógica de Negocio)
    │ - Invoca UserRepository->findByEmail($dto->email).
    │   Si existe usuario: corta con Response::error('El correo electrónico ya está registrado.', 409).
    │ - Aplica password_hash($dto->password, PASSWORD_DEFAULT) para cifrar con bcrypt.
    │ - Invoca UserRepository->create($dto, $hashedPassword).
    │ - Retorna array con datos de usuario (id, nombre_completo, email, telefono, rol).
    ▼
11. src/repository/UserRepository.php (Persistencia)
    │ - Inicia transacción PDO ($pdo->beginTransaction()).
    │ - INSERT en tabla 'usuarios' con sentencia preparada.
    │ - Obtiene el ID insertado ($pdo->lastInsertId()).
    │ - INSERT en tabla hija ('fotografos' o 'clientes') usando el ID padre.
    │ - Confirma la transacción ($pdo->commit()).
    ▼
12. src/Core/Database.php ──► MySQL (cipher_forge)
    │ Mantiene la conexión PDO configurada en UTF-8 y excepciones activas.
    ▼
13. src/Core/Response.php (Emisor de Respuesta)
    │ Configura cabecera 'Content-Type: application/json', código HTTP 201 y emite JSON.
    ▼
14. Cliente
    │ Recibe la respuesta HTTP 201 con los datos del usuario registrado.
```

---

## 2. `POST /auth/login`

### Resumen Técnico
* **Propósito:** Autenticación de usuarios existentes mediante correo y contraseña.
* **Autenticación requerida:** Ninguna (Ruta pública).
* **Códigos de respuesta:**
  * `200 OK`: Credenciales válidas (retorna identificador, nombre, correo, rol y estado de verificación).
  * `400 Bad Request`: Correo o contraseña ausentes en el cuerpo de la petición.
  * `401 Unauthorized`: Credenciales inválidas (correo no encontrado o contraseña errónea).
  * `500 Internal Server Error`: Error no controlado o desconexión con la base de datos.

### Diagrama de Secuencia y Ciclo de Vida

```
1. Cliente (Insomnia / Frontend)
   │ Envía HTTP POST a http://localhost:8080/auth/login con email y password.
   ▼
2. .htaccess (Apache)
   │ Redirige la petición a public/index.php.
   ▼
3. public/index.php (Front Controller)
   │ Carga autoloader, cabeceras CORS y despacha hacia routes.php.
   ▼
4. routes.php
   │ Asocia 'POST /auth/login' con AuthController::class y método 'login'.
   ▼
5. src/Core/Router.php (Despachador)
   │ Coincide la ruta y ejecuta $authController->login().
   ▼
6. src/controllers/AuthController.php (Controlador)
   │ 1. Obtiene body JSON con Request.
   │ 2. Valida presencia de datos con AuthValidator->validateLogin($data).
   │ 3. Autentica mediante AuthService->login($dto).
   │ 4. Responde con Response::success($userData, 'Inicio de sesión exitoso.').
   ▼
7. src/Core/Request.php
   │ Deserializa el JSON a array asociativo.
   ▼
8. src/validators/AuthValidator.php (Validador)
   │ - Verifica que 'email' y 'password' no estén vacíos.
   │ - Si falla: emite Response::error('Error de validación.', 400).
   │ - Si aprueba: retorna una instancia inmutable de LoginDto.
   ▼
9. src/dtos/LoginDto.php (DTO)
   │ Contenedor inmutable de credenciales (email y password).
   ▼
10. src/services/AuthService.php (Lógica de Negocio)
    │ - Llama a UserRepository->findByEmail($dto->email).
    │   Si es null: emite Response::error('Credenciales incorrectas.', 401).
    │ - Compara contraseñas usando password_verify($dto->password, $user['password_hash']).
    │   Si no coincide: emite Response::error('Credenciales incorrectas.', 401).
    │ - Retorna datos del perfil de usuario sanitizados.
    ▼
11. src/repository/UserRepository.php (Persistencia)
    │ Ejecuta SELECT preparado sobre 'usuarios' filtrando por email con LIMIT 1.
    ▼
12. src/Core/Database.php ──► MySQL (cipher_forge)
    │ Ejecuta la lectura en base de datos.
    ▼
13. src/Core/Response.php (Emisor de Respuesta)
    │ Establece código HTTP 200 y emite el JSON final.
    ▼
14. Cliente
    │ Recibe la respuesta HTTP 200 con el rol y datos del usuario autenticado.
```

---

## 3. `GET /api/ping`

### Resumen Técnico
* **Propósito:** Endpoint de diagnóstico para comprobar disponibilidad del servidor y latencia de conexión.
* **Autenticación requerida:** Ninguna.
* **Controlador:** `HomeController::ping`
* **Códigos de respuesta:** `200 OK`

---

## 4. `POST /colecciones`

### Resumen Técnico
* **Propósito:** Creación de una nueva colección y asignación de su visibilidad (`privada` o `publica`) por parte de un usuario con rol de fotógrafo (RF4 / HU2).
* **Autenticación / Autorización:** Requiere que el `fotografo_id` pertenezca a un usuario existente y con rol estrictamente `fotografo`. Los usuarios con rol `cliente` son rechazados con `403 Forbidden`.
* **Códigos de respuesta:**
  * `201 Created`: Colección creada correctamente (retorna `id`, `fotografo_id`, `titulo`, `tipo_visibilidad`, `descripcion` y `creado_en`).
  * `400 Bad Request`: Error de validación (faltan campos obligatorios, `tipo_visibilidad` inválido o longitud de campos excedida).
  * `403 Forbidden`: El usuario existe pero no posee el rol de fotógrafo.
  * `404 Not Found`: El `fotografo_id` proporcionado no corresponde a ningún usuario en la base de datos.
  * `500 Internal Server Error`: Fallo interno del servidor o error al interactuar con la base de datos.

### Diagrama de Secuencia y Ciclo de Vida

```
1. Cliente (Insomnia / Frontend)
   │ Envía HTTP POST a http://localhost:8080/colecciones con payload JSON:
   │ {
   │   "fotografo_id": 1,
   │   "titulo": "Boda Martín & Sofía",
   │   "tipo_visibilidad": "privada",
   │   "descripcion": "Colección privada de la ceremonia"
   │ }
   ▼
2. .htaccess (Apache)
   │ Redirige la petición hacia public/index.php.
   ▼
3. public/index.php (Front Controller)
   │ Carga autoloader, cabeceras CORS y despacha hacia routes.php.
   ▼
4. routes.php
   │ Mapea 'POST /colecciones' hacia ColeccionController::class y método 'create'.
   ▼
5. src/Core/Router.php (Despachador)
   │ Valida la ruta, resuelve middleware y ejecuta $coleccionController->create().
   ▼
6. src/controllers/ColeccionController.php (Controlador)
   │ 1. Obtiene body JSON deserializado con Request.
   │ 2. Delega la validación formal a ColeccionValidator->validateCreate($data).
   │ 3. Pasa el DTO a ColeccionService->create($dto).
   │ 4. Retorna respuesta exitosa con Response::success($coleccion, 'Colección creada exitosamente.', 201).
   ▼
7. src/Core/Request.php
   │ Deserializa el flujo php://input a array asociativo PHP.
   ▼
8. src/validators/ColeccionValidator.php (Validador)
   │ - Valida que 'fotografo_id' esté presente, sea numérico y entero positivo (> 0).
   │ - Valida que 'titulo' esté presente y no supere los 60 caracteres.
   │ - Valida que 'tipo_visibilidad' sea estrictamente 'privada' o 'publica'.
   │ - Valida que 'descripcion' (opcional) no supere los 90 caracteres.
   │ - Si falla: interrumpe con Response::error('Error de validación.', 400, $errores).
   │ - Si aprueba: retorna una instancia inmutable de CreateColeccionDto.
   ▼
9. src/dtos/CreateColeccionDto.php (DTO)
   │ Almacena los datos limpios de la colección en propiedades readonly tipadas.
   ▼
10. src/services/ColeccionService.php (Lógica de Negocio)
    │ 1. Consulta UserRepository->findById($dto->fotografoId).
    │    - Si el usuario es null: corta con Response::error('El fotógrafo especificado no existe.', 404).
    │    - Si usuario['rol'] !== 'fotografo': corta con Response::error('Solo los usuarios con rol fotógrafo pueden crear colecciones.', 403).
    │ 2. Si el rol es 'fotografo': delega la persistencia a ColeccionRepository->create($dto).
    │ 3. Recupera la entidad recién creada con ColeccionRepository->findById($coleccionId).
    │ 4. Retorna el array de la colección creada.
    ▼
11. src/repository/ColeccionRepository.php (Persistencia)
    │ Ejecuta INSERT preparado en la tabla 'colecciones' con fotografo_id, titulo, tipo_visibilidad y descripcion.
    │ Obtiene el id autogenerado con lastInsertId().
    ▼
12. src/Core/Database.php ──► MySQL (cipher_forge)
    │ Persiste el registro en la base de datos relacional.
    ▼
13. src/Core/Response.php (Emisor de Respuesta)
    │ Configura código HTTP 201 Created y emite el payload JSON al cliente.
    ▼
14. Cliente
    │ Recibe la respuesta HTTP 201 con los datos de la colección creada.
```

---

# Sprint 2 — Nuevas funcionalidades (JWT, subida multimedia, marca de agua y bloqueo de acceso)

> Nota de introducción: hasta aquí la API sólo devolvía JSON para autenticación y colecciones,
> sin identificar al usuario en cada petición (el `AuthMiddleware` era un stub). Para habilitar la
> subida a colecciones (HU5), la marca de agua (HU14), el **bloqueo de acceso directo por URL a
> colecciones privadas (HU20)** y documentar el **impedimento de registros duplicados (HU19)**, se
> incorporó una capa de autenticación basada en **tokens JWT** (HS256, PHP puro, sin librerías).

## 5. Capa de autenticación JWT (transversal a todos los endpoints protegidos)

### Resumen Técnico
* **Propósito:** Identificar de forma fiable al usuario que realiza cada petición protegida.
* **Emisión:** `POST /auth/login` ahora devuelve campo `token` (JWT firmado con HMAC-SHA256).
* **Transporte:** El frontend envía el token en la cabecera `Authorization: Bearer <token>`.
* **Validación:** `AuthMiddleware` lee la cabecera, verifica la firma con clave secreta y
  comprueba la expiración (`exp`) antes de permitir el acceso al controlador.

### Archivos nuevos / modificados
* `src/helpers/Jwt.php` *(nuevo)* — `encode()` y `decode()` de JWT HS256 con PHP puro.
* `src/Core/Config.php` *(nuevo)* — clave secreta JWT, cantidad de horas de validez y rutas de uploads.
* `src/Core/AuthMiddleware.php` *(modificado)* — autentica rutas protegidas y opcionales.
* `src/services/AuthService.php` *(modificado)* — `login()` emite el token JWT.
* `routes.php` *(modificado)* — pasa el requisito de seguridad como 5º argumento del Router.

### Ciclo de vida de una petición autenticada

```
1. Cliente
   │ Envía HTTP con cabecera: Authorization: Bearer <token>
   ▼
2. .htaccess (Apache)
   │ Conserva la cabecera Authorization (sino Apache la descarta) y redirige a public/index.php.
   ▼
3. public/index.php (Front Controller)
   │ Carga autoloader, CORS y despacha hacia routes.php.
   ▼
4. routes.php
   │ Asocia la ruta con su requisito: 'null' (pública), 'auth' (obligatoria) u 'optional'.
   ▼
5. src/Core/Router.php
   │ Llama AuthMiddleware::handle($requirement) antes de instanciar el controlador.
   ▼
6. src/Core/AuthMiddleware.php
   │ - 'auth'    : exige Bearer; si falta o es inválido -> 401.
   │ - 'optional': autentica si hay token; si no, continúa como anónimo (colecciones públicas).
   │ - valida el token con Jwt::decode($token, Config::jwtSecret()).
   │ - si es válido, carga el usuario vigente en AuthMiddleware::$user.
   ▼
7. src/helpers/Jwt.php
   │ - Desglosa header.payload.signature y re-firma con hash_hmac('sha256').
   │ - Compara firmas con hash_equals (tiempo constante).
   │ - Rechaza tokens vencidos (time() >= exp).
   ▼
8. src/repository/UserRepository.php
   │ Carga el usuario por el id del token (sub) para usar datos vigentes (no caché en el token).
   ▼
9. Controlador
   │ Puede leer AuthMiddleware::user() para saber quién hace la petición.
```

### Códigos de error de autenticación
* `401 Unauthorized`: falta la cabecera Bearer, token inválido, firma incorrecta o vencido.
* `500 Internal Server Error`: no se pudo cargar el usuario asociado al token.

---

## 6. `POST /auth/register` — verificación de duplicado (HU19)

### Resumen Técnico
* **Propósito:** Impedir el registro de usuarios duplicados con el mismo correo (RF2 / HU19).
* **Autenticación requerida:** Ninguna (ruta pública).
* **Códigos de respuesta:**
  * `201 Created`: Usuario creado exitosamente.
  * `409 Conflict`: El correo ya está registrado (se corta el flujo antes de insertar).
  * `400 Bad Request`: Validación fallida.

### Flujo de control de duplicado

```
1. src/services/AuthService.php -> register($dto)
   │
   ▼
2. UserRepository->findByEmail($dto->email)   // SELECT preparado por email, LIMIT 1
   │
   ├── Si existe usuario  -> Response::error('El correo electrónico ya está registrado.', 409)
   │                        (nunca llega a insertar; se impide el duplicado)
   │
   └── Si no existe       -> password_hash() + UserRepository->create() dentro de transacción
```

### Doble barrera de integridad
* **A nivel de aplicación:** `AuthService` verifica el correo antes de insertar (respuesta `409`).
* **A nivel de base de datos:** la columna `usuarios.email` tiene restricción `UNIQUE`, por lo que
  un duplicado concurrente sería rechazado igualmente por MySQL.

> **Verificado en pruebas:** registrar dos veces `foto@test.com` devuelve `201` la primera vez
> y `409` la segunda, sin crear una fila duplicada en `usuarios`.

---

## 7. `POST /colecciones/{id}/multimedia` — Subida de imágenes o videos (HU5)

### Resumen Técnico
* **Propósito:** Subir uno o más archivos (JPG/PNG o video) a una colección del fotógrafo (HU5/RF7).
* **Autenticación requerida:** Sí (`auth`). Solo el fotógrafo **dueño** de la colección puede subir.
* **Formato:** `multipart/form-data`, campo `archivos` (uno o un array). Opcionales: `titulo`, `descripcion`.
* **Códigos de respuesta:**
  * `201 Created`: Archivo(s) subido(s) y procesado(s). Devuelve id, tipo y ruta de vista previa.
  * `400 Bad Request`: No llegó el archivo, formato no permitido o tamaño excedido.
  * `401 Unauthorized`: Token faltante/vencido.
  * `403 Forbidden`: El usuario autenticado no es el dueño de la colección.
  * `404 Not Found`: La colección no existe.

### Diagrama de Secuencia y Ciclo de Vida

```
1. Fotógrafo (Frontend / Insomnia)
   │ POST /colecciones/{id}/multimedia (multipart) + Authorization: Bearer <token>
   ▼
2. .htaccess -> public/index.php -> routes.php (requisito 'auth')
   ▼
3. src/Core/AuthMiddleware.php
   │ Autentica el token y carga el usuario (ver sección 5).
   ▼
4. src/controllers/MultimediaController.php -> upload($coleccionId)
   │ 1. Lee $_FILES['archivos'] (acepta array o un único archivo).
   │ 2. Llama MultimediaValidator->validateUpload() por archivo.
   │ 3. Llama MultimediaService->upload() por archivo.
   │ 4. Response::success($subidos, 201).
   ▼
5. src/validators/MultimediaValidator.php
   │ - Verifica que $_FILES['archivos'] tenga error UPLOAD_ERR_OK.
   │ - Detecta el MIME real con mime_content_type() (imagen JPG/PNG | video MP4/MOV/WEBM/AVI).
   │ - Valida tamaño: imagen <= 20 MB, video <= 800 MB (RF7).
   │ - Valida título (<=60) y descripción (<=90).
   ▼
6. src/services/MultimediaService.php -> upload()
   │ 1. Verifica que la colección exista (404).
   │ 2. Verifica que el usuario autenticado sea el DUEÑO (fotografo_id == usuario.id) -> 403 si no.
   │ 3. MediaProcessor::guardarOriginal()  -> uploads/originals/<aleatorio>.<ext>
   │ 4. Genera la vista previa (ver sección 8).
   │ 5. MultimediaRepository->create()  -> fila en tabla 'multimedia'.
   ▼
7. src/helpers/MediaProcessor.php
   │ - guardarOriginal(): mueve el archivo temporal con move_uploaded_file() a uploads/originals.
   │ - genera nombre único con random_bytes() (no predecible, evita colisiones y enumeración).
   ▼
8. src/repository/MultimediaRepository.php
   │ INSERT preparado en multimedia (coleccion_id, ruta_original, vista_previa, tamanio, tipo).
   ▼
9. src/Core/Database.php -> MySQL
   ▼
10. Response::success(..., 201)
    │ Devuelve: [{ id_multimedia, coleccion_id, tipo, titulo, descripcion, vista_previa, tamanio }]
```

### Detalle de seguridad en la subida
* **MIME real** (no sólo la extensión) verificado con `mime_content_type()` para rechazar binarios
  disfrazados (mitiga subida de ejecutables).
* **`is_uploaded_file()`** comprueba que el archivo provenga de una carga HTTP legítima.
* **Nombre aleatorio** para los archivos: evita path traversal y enumeración de recursos.
* **Control de propiedad**: un cliente u otro fotógrafo no pueden subir a una colección ajena (403).

---

## 8. Marca de agua y vista previa (HU14 / RF8, RF9)

### Resumen Técnico
* **Propósito:** Al subir una imagen, el backend genera automáticamente una **vista previa optimizada
  con marca de agua**, separada del archivo original (RF8/RF9). Para videos genera un **recorte de
  15 s** con FFmpeg (RF26/32).
* **Archivo resultante:** se guarda en `uploads/previews/` y se referencia en `multimedia.vista_previa`.

### Diagrama de procesamiento

```
MultimediaService->upload()
   │
   ├── Si tipo == 'imagen'  -> MediaProcessor::generarPreviewImagen($rutaOriginal)
   │     1. getimagesize() valida que sea una imagen real.
   │     2. imagecreatefromjpeg() / imagecreatefrompng().
   │     3. Redimensiona a máx. 1280 px de ancho (vista previa ligera, RNF2).
   │     4. Superpone texto "Cipher Forge" semitransparente en diagonal repetido
   │        (imagecolorallocatealpha + imagestring) -> dificulta removerla (amenaza A5).
   │     5. imagejpeg($destino, 85) guarda la copia.
   │
   └── Si tipo == 'video'   -> MediaProcessor::generarPreviewVideo($rutaOriginal)
         1. Ejecuta FFmpeg: -t 15 (recorta los primeros 15 segundos).
         2. Guarda el clip en uploads/previews/<aleatorio>.mp4 (preserva audio/video).
         3. El video ORIGINAL completo queda en uploads/originals para la descarga directa.
```

> **Verificado en pruebas:** una imagen JPG de 2 KB original generó una preview de ~23 KB con marca
> de agua; un video de 30 s generó un clip de preview de exactamente **15.0 s** (ffprobe).

### Decisiones de diseño
* El archivo **original** (alta calidad) **nunca** es la vista previa: se mantienen rutas separadas
  (`ruta_original` vs `vista_previa`) tal como define el modelo de datos, protegiendo el objetivo de
  negocio (la vista previa va con marca de agua, el original va sin ella sólo tras autorización).

---

## 9. `GET /multimedia/{id}/vista-previa` y `GET /multimedia/{id}/original` — Bloqueo de acceso directo por URL (HU20 / RF6)

### Resumen Técnico
* **Propósito:** Servir la vista previa (con marca de agua) y el archivo original de una pieza
  multimedia, **validando el acceso a la colección en el backend** en cada solicitud. Esto bloquea
  el acceso directo por URL a contenido de colecciones privadas por usuarios no autorizados (HU20).
* **Autenticación requerida:** Opcional (`optional`). Si la colección es privada se exige usuario.
* **Códigos de respuesta:**
  * `200 OK`: Contenido servido (Content-Type correcto; original se sirve como `attachment`).
  * `401 Unauthorized`: Colección privada y no hay token de sesión.
  * `403 Forbidden`: Colección privada y el usuario autenticado no tiene permisos.
  * `404 Not Found`: La pieza multimedia no existe, o el archivo no está disponible.

### Diagrama de Secuencia y Ciclo de Vida (acceso de lectura)

```
1. Cliente
   │ GET /multimedia/{id}/vista-previa  (o /original) + opcional: Bearer <token>
   ▼
2. .htaccess -> public/index.php -> routes.php (requisito 'optional')
   ▼
3. AuthMiddleware (modo 'optional')
   │ Si hay token lo valida y carga al usuario; si no, continúa como anónimo.
   ▼
4. src/controllers/MultimediaController.php
   │ - vistaPrevia($id) -> MultimediaService->obtenerVistaPrevia($id)  (usa ruta $vista_previa)
   │ - original($id)    -> MultimediaService->obtenerOriginal($id)     (usa ruta $ruta_original)
   ▼
5. src/services/MultimediaService.php -> rutaServible()
   │ 1. MultimediaRepository->findById()  (JOIN con colecciones: trae visibilidad y dueño).
   │ 2. verificarAccesoALaColeccion() -> regla central de acceso (ver abajo).
   │ 3. Elige ruta (preview u original) y comprueba que el archivo exista en disco.
   ▼
6. MultimediaController->emitirArchivo()
   │ - Vista previa: Content-Disposition: inline (se muestra en el navegador).
   │ - Original:     Content-Disposition: attachment (descarga directa).
   │ - Cache-Control: no-store (evita reutilización de caché del original).
   │ - readfile() envía el binario y hace exit.
```

### Regla central de acceso (verificarAccesoALaColeccion)

```
if (coleccion.tipo_visibilidad == 'publica'):
    >>> PERMITIDO (libre visualización, RF11)
else:  # colección privada (RF5/RF6)
    si no hay usuario autenticado        -> 401 Debes iniciar sesión
    si es el dueño (fotografo_id == id)  -> PERMITIDO
    si está en tabla acceso_colecciones  -> PERMITIDO
    si no                                -> 403 No tienes permisos
```

### Bloqueo del archivo físico en disco
Además del control a nivel de endpoint, los archivos de `uploads/` **no se sirven por una ruta
estática**: el `.htaccess` raíz redirige toda petición a `public/index.php` y existe un
`uploads/.htaccess` con `Require all denied` (defensa en profundidad). Verificado: acceder
directamente a `http://localhost:8080/uploads/originals/<archivo>.jpg` devuelve **404**.

> **Verificado en pruebas:**
> * Colección privada sin token -> `401` (vista previa y original).
> * Colección privada con token de cliente **sin acceso** -> `403`.
> * Colección privada con token del **dueño** -> `200` (vista previa y original).
> * Colección **pública** sin token -> `200` (vista previa, original y listado).

---

## 10. `GET /colecciones/{id}/multimedia` — Listado de contenidos (galería)

### Resumen Técnico
* **Propósito:** Listar los archivos multimedia de una colección para la galería, respetando la
  visibilidad y el control de acceso (no expone `ruta_original` en la respuesta).
* **Autenticación requerida:** Opcional (`optional`).
* **Salida:** array de piezas con `id_multimedia`, `titulo`, `descripcion`, `vista_previa`,
  `tamanio`, `tipo` y `es_invitado`. **No** se incluye `ruta_original` (protección del original).

### Flujo
```
MultimediaController->listar() 
   -> MultimediaService->listarColeccion($coleccionId)
       1. Verifica que la colección exista (404).
       2. verificarAccesoALaColeccion()   (misma regla que la sección 9)
       3. MultimediaRepository->findByColeccionId()  -> SELECT ordenado por id DESC
   -> Response::success(...)
```

---

# Sprints 3, 4 y 5 — Finalización Integral del Backlog Priorizado (PHP Vanilla)

Este bloque completa y documenta todas las historias de usuario y requerimientos funcionales faltantes del backend según el backlog priorizado de `docs/01-requerimientos.md`.

---

## 11. Arquitectura del Backend en PHP Vanilla

El backend está diseñado bajo una **Arquitectura en Capas desacoplada**, utilizando exclusivamente **PHP 8.x nativo** sin librerías de Composer ni frameworks:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          1. Cliente HTTP                                │
│        (Frontend React / Vue / Vanilla JS, Postman, Insomnia)           │
└────────────────────────────────────┬────────────────────────────────────┘
                                     │ HTTP Request
                                     ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                2. Servidor Web Apache + .htaccess                       │
│    Reenvía todas las peticiones dinámicas a public/index.php            │
│    Bloquea acceso estático directo a uploads/ (.htaccess con Deny all)  │
└────────────────────────────────────┬────────────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                    3. Front Controller (public/index.php)               │
│    - Autoloader PSR-4 para App\...                                      │
│    - Emisión de cabeceras CORS permisivas para SPA                      │
│    - Normalización de método HTTP y URI (parse_url sin query strings)   │
│    - Despacho global con captura de excepciones Throwable (HTTP 500)    │
└────────────────────────────────────┬────────────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                 4. Enrutador Dinámico (src/Core/Router.php)             │
│    - Comparación por método y conteo de partes                          │
│    - Extracción de parámetros dinámicos genéricos: {id}, {token}, etc.  │
│    - Invocación previa de AuthMiddleware::handle($requirement)          │
│    - Desempaquetado seguro de argumentos: $controller->$action(...$arg) │
└───────────────────┬─────────────────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│            5. Middleware de Autenticación (src/Core/AuthMiddleware.php) │
│    - 'auth'    : Exige cabecera Authorization: Bearer <jwt> (401 si no) │
│    - 'optional': Autentica si existe token, tolera clientes anónimos   │
│    - Carga de usuario vigente en base de datos (evita caché en token)   │
└───────────────────┬─────────────────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                       6. Capa de Controladores                          │
│        (AuthController, ColeccionController, MultimediaController,      │
│         FotografoController, ColaborativoController, FavoritoController,│
│         SistemaController, HomeController)                              │
│    - Lee entrada HTTP mediante Request (JSON body, $_FILES, $_GET)      │
│    - Delega validación a Validators y lógica a Services                 │
│    - Emite respuestas uniformes mediante Response::success / error      │
└───────────────────┬─────────────────────────────────────────────────────┘
                    │
                    ▼
┌──────────────────────────────────────┬──────────────────────────────────┐
│      7. Validadores & DTOs           │      8. Capa de Servicios        │
│   - AuthValidator / LoginDto         │   - AuthService                  │
│   - ColeccionValidator / ColeccionDto│   - ColeccionService             │
│   - MultimediaValidator / MultiDto   │   - MultimediaService            │
│     Valida MIME real, límites 3GB /  │   - BackupService                │
│     800MB / 80MB clips, tipos        │     Reglas de negocio, cuotas,   │
│                                      │     canje de tokens, moderación  │
└──────────────────────────────────────┴──────────────────┬───────────────┘
                                                          │
                                                          ▼
┌─────────────────────────────────────────────────────────────────────────┐
│            9. Capa de Persistencia / Repositorios (PDO)                 │
│        (UserRepository, ColeccionRepository, MultimediaRepository)      │
│    - Consultas preparadas contra inyección SQL                          │
│    - Transacciones atómicas ($pdo->beginTransaction())                  │
│    - MySQL 8.x: base de datos relacional cipher_forge                   │
└────────────────────────────────────┬────────────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────────────┐
│          10. Capa de Procesamiento Binario & Helpers Nativos            │
│   - MediaProcessor: GD (vistas previas, marca de agua diagonal, buena   │
│     calidad 1920px limpia sin marca de agua) + FFmpeg (clip 15s)        │
│   - QrGenerator: generación nativa de códigos QR SVG y carteles HTML    │
│   - Jwt: codificación / decodificación HMAC-SHA256 en PHP puro          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 12. Nuevos Endpoints — Especificación y Auditoría

### 12.1 `POST /auth/verificar-email` (HU21 / RF18)
* **Propósito:** Validar el código de 6 dígitos enviado al registrarse o reenviado a la casilla del usuario.
* **Autenticación:** Ninguna (Ruta pública).
* **Entrada (JSON):**
  ```json
  {
    "email": "juan@example.com",
    "codigo": "481920"
  }
  ```
* **Códigos HTTP:**
  * `200 OK`: Correo verificado con éxito (`email_verificado = true`).
  * `400 Bad Request`: Código incorrecto, expirado (> 1 hora) o usuario ya verificado.
  * `404 Not Found`: No existe usuario registrado con ese correo.

### 12.2 `POST /auth/reenviar-codigo` (HU21 / RF18)
* **Propósito:** Generar y reenviar un nuevo código de verificación con vigencia de 1 hora.
* **Autenticación:** Ninguna (Ruta pública).
* **Entrada (JSON):** `{ "email": "juan@example.com" }`
* **Códigos HTTP:** `200 OK`, `400 Bad Request`, `404 Not Found`.

### 12.3 `POST /fotografos/aceptar-politicas` (HU31 / RF24)
* **Propósito:** Registrar la aceptación formal y obligatoria de las políticas de privacidad y Ley 18.331 de Uruguay en el primer inicio de sesión del fotógrafo.
* **Autenticación:** Obligatoria (`auth`, rol `fotografo`).
* **Códigos HTTP:**
  * `200 OK`: Políticas marcadas como aceptadas (`politicas_aceptadas = true`).
  * `401 Unauthorized`: Token no proporcionado o inválido.
  * `403 Forbidden`: El usuario autenticado es un cliente, no fotógrafo.

### 12.4 `GET /fotografos` (HU18 / RF19)
* **Propósito:** Directorio público de fotógrafos profesionales con biografía, especialidad y cantidad de colecciones públicas.
* **Autenticación:** Ninguna (Ruta pública).
* **Códigos HTTP:** `200 OK`.

### 12.5 `GET /fotografos/{id}` (HU18)
* **Propósito:** Perfil detallado de un fotógrafo profesional.
* **Autenticación:** Ninguna (Ruta pública).
* **Códigos HTTP:** `200 OK`, `404 Not Found`.

### 12.6 `PUT /fotografo/perfil` (HU18 / RF19)
* **Propósito:** Permite al fotógrafo autenticado actualizar su información profesional (nombre, teléfono, biografía, especialidad).
* **Autenticación:** Obligatoria (`auth`, rol `fotografo`).
* **Entrada (JSON):**
  ```json
  {
    "nombre_completo": "Nicolás Fotografía",
    "telefono": "+598 99 123 456",
    "biografia": "Especialista en bodas y eventos sociales en Montevideo y Punta del Este.",
    "especialidad": "Bodas y 15 Años"
  }
  ```
* **Códigos HTTP:** `200 OK`, `400 Bad Request`, `401 Unauthorized`, `403 Forbidden`.

### 12.7 `GET /fotografos/cuota` (HU16 / RF17)
* **Propósito:** Monitorear en tiempo real el espacio de almacenamiento utilizado, espacio disponible y porcentaje sobre la cuota máxima permitida de 3 GB.
* **Autenticación:** Obligatoria (`auth`, rol `fotografo`).
* **Salida (JSON):**
  ```json
  {
    "espacio_usado_bytes": 104857600,
    "espacio_usado_mb": 100.0,
    "espacio_total_bytes": 3221225472,
    "espacio_total_gb": 3.0,
    "espacio_disponible_bytes": 3116367872,
    "espacio_disponible_mb": 2972.0,
    "porcentaje_utilizado": 3.25
  }
  ```
* **Códigos HTTP:** `200 OK`, `401 Unauthorized`, `403 Forbidden`.

### 12.8 `GET /colecciones/publicas` (HU24 / HU27 / RF11)
* **Propósito:** Listar el catálogo de colecciones públicas con imagen de portada y filtro opcional por hashtag.
* **Autenticación:** Ninguna (Ruta pública).
* **Parámetros URL:** `?hashtag=bodas`
* **Salida (JSON):** Array de colecciones públicas con `id`, `titulo`, `descripcion`, `fotografo_nombre`, `portada_preview`, `total_archivos`, `hashtags`.
* **Códigos HTTP:** `200 OK`.

### 12.9 `GET /colecciones/{id}` (HU24 / HU20 / RF5, RF6)
* **Propósito:** Obtener detalle de una colección. Si la colección es privada, bloquea el acceso si el solicitante no es el dueño ni cuenta con invitación canjeada en `acceso_colecciones`.
* **Autenticación:** Opcional (`optional`).
* **Códigos HTTP:**
  * `200 OK`: Colección pública o colección privada autorizada.
  * `401 Unauthorized`: Colección privada sin token de sesión.
  * `403 Forbidden`: Colección privada solicitada por usuario no autorizado.
  * `404 Not Found`: Colección no encontrada.

### 12.10 `POST /colecciones/{id}/qr-acceso` (HU17 / RF16)
* **Propósito:** Generar o consultar el token y código QR de acceso directo permanente (sin caducidad) a una colección específica para clientes autorizados.
* **Autenticación:** Obligatoria (`auth`, fotógrafo dueño).
* **Salida (JSON):**
  ```json
  {
    "coleccion_id": 5,
    "titulo": "Casamiento Martín & Sofía",
    "token": "a1f9e2b83c7d4e5f...",
    "tipo": "acceso_permanente",
    "url_acceso": "http://localhost:8080/invitacion/a1f9e2b83c7d4e5f...",
    "svg_qr": "<svg xmlns=...></svg>"
  }
  ```
* **Códigos HTTP:** `200 OK`, `401 Unauthorized`, `403 Forbidden`, `404 Not Found`.

### 12.11 `GET /invitaciones/{token}` (HU3 / RF5)
* **Propósito:** Validar el enlace de invitación de una colección privada antes de canjear. Indica al frontend si el usuario ya inició sesión o si debe registrarse/loguearse primero.
* **Autenticación:** Opcional (`optional`).
* **Códigos HTTP:** `200 OK`, `404 Not Found`.

### 12.12 `POST /invitaciones/{token}/canjear` (HU3 / RF5)
* **Propósito:** Otorga y vincula formalmente el acceso permanente a la colección privada para el cliente autenticado en la tabla `acceso_colecciones`.
* **Autenticación:** Obligatoria (`auth`).
* **Códigos HTTP:** `200 OK`, `401 Unauthorized`, `404 Not Found`.

### 12.13 `GET /hashtags` (HU27)
* **Propósito:** Lista todos los hashtags existentes con la cantidad de colecciones asociadas para autocompletado y exploración temática.
* **Autenticación:** Ninguna (Ruta pública).
* **Códigos HTTP:** `200 OK`.

### 12.14 `GET /multimedia/{id}/descargar` (HU10 / RF10)
* **Propósito:** Descarga directa e individual en dos calidades:
  * `calidad=alta`: Archivo original íntegro sin procesar.
  * `calidad=buena`: Versión optimizada Full HD (1920px) limpia **sin marca de agua** (RF136).
* **Autenticación:** Opcional (`optional`), sujeta a las reglas de acceso de la colección.
* **Parámetros URL:** `?calidad=buena` o `?calidad=alta` (por defecto: `alta`).
* **Cabeceras:** `Content-Disposition: attachment; filename="..."`, `Cache-Control: no-store`.
* **Códigos HTTP:** `200 OK` (binario descargado), `401 Unauthorized`, `403 Forbidden`, `404 Not Found`.

### 12.15 `DELETE /multimedia/{id}` (HU6 / RF20)
* **Propósito:** Elimina definitivamente un archivo multimedia de una colección. Borra tanto la fila en la BD como los archivos físicos en disco (`uploads/originals`, `uploads/previews`, `uploads/standard`).
* **Autenticación:** Obligatoria (`auth`, fotógrafo dueño).
* **Códigos HTTP:** `200 OK`, `401 Unauthorized`, `403 Forbidden`, `404 Not Found`.

### 12.16 `PUT /multimedia/{id}` (HU22 / RF20)
* **Propósito:** Modifica título, descripción o reasigna una imagen/video a otra colección del mismo fotógrafo.
* **Autenticación:** Obligatoria (`auth`, fotógrafo dueño).
* **Entrada (JSON):**
  ```json
  {
    "titulo": "Vals de los novios",
    "descripcion": "Momento emotivo",
    "coleccion_id": 8
  }
  ```
* **Códigos HTTP:** `200 OK`, `400 Bad Request`, `401 Unauthorized`, `403 Forbidden`, `404 Not Found`.

### 12.17 `POST /colecciones/{id}/qr-colaborativo` (HU4 / RF13)
* **Propósito:** Genera un código QR de carga colaborativa único para un evento, con **fecha de caducidad estricta de 24 horas (1 día)** a partir de su creación.
* **Autenticación:** Obligatoria (`auth`, fotógrafo dueño).
* **Salida (JSON):**
  ```json
  {
    "token": "7c8d9e0f1a2b...",
    "coleccion_id": 3,
    "evento": "Fiesta de 15 Camila",
    "expiracion": "2026-09-05 16:00:00",
    "url_acceso": "http://localhost:8080/colaborativo/7c8d9e0f1a2b...",
    "url_imprimir": "http://localhost:8080/colecciones/3/qr-colaborativo/imprimir",
    "svg_qr": "<svg xmlns=...></svg>"
  }
  ```
* **Códigos HTTP:** `201 Created`, `401 Unauthorized`, `403 Forbidden`, `404 Not Found`.

### 12.18 `GET /colecciones/{id}/qr-colaborativo/imprimir` (HU7)
* **Propósito:** Renderiza una plantilla HTML formal y profesional con el código QR vectorizado, título del evento, instrucciones para los invitados y estilos `@media print` para ser impreso físicamente por el fotógrafo y expuesto en mesas o atriles durante el evento.
* **Autenticación:** Ninguna (Ruta pública imprimible).
* **Formato de respuesta:** `text/html; charset=utf-8`.
* **Códigos HTTP:** `200 OK`, `404 Not Found`.

### 12.19 `GET /qr/{token}/svg` (HU7)
* **Propósito:** Emite la imagen vectorial del código QR directamente como archivo gráfico SVG (`image/svg+xml`) sin pérdidas de calidad a cualquier resolución.
* **Autenticación:** Ninguna (Ruta pública).
* **Códigos HTTP:** `200 OK`, `404 Not Found`.

### 12.20 `GET /colaborativo/{token}` (HU11 / RF14)
* **Propósito:** Punto de entrada para el invitado al escanear el QR con su celular. Valida que el código esté activo (no expirado) y devuelve los metadatos mínimos del evento para la pantalla de subida.
* **Seguridad (RF14):** **NO** devuelve fotos ni videos de la colección; el invitado únicamente tiene permiso para cargar contenido.
* **Códigos HTTP:** `200 OK`, `404 Not Found`, `410 Gone` (si superó las 24 horas).

### 12.21 `POST /colaborativo/{token}/subir` (HU11 / RF14 / RF25)
* **Propósito:** Permite a los invitados subir fotos (JPG/PNG) y videos (clips) de forma anónima o con nombre opcional sin registrarse.
* **Restricciones:**
  * Clips de video: límite máximo de **80 MB** (RF25).
  * Persistencia: se registra en `multimedia` con `es_invitado = 1` y `aprobado = 0` (pendiente de aprobación).
* **Códigos HTTP:** `201 Created`, `400 Bad Request`, `404 Not Found`, `410 Gone`.

### 12.22 `GET /colecciones/{id}/colaborativo/pendientes` (HU12 / RF15)
* **Propósito:** Panel de moderación del fotógrafo para inspeccionar el material subido por invitados pendiente de aprobación.
* **Autenticación:** Obligatoria (`auth`, fotógrafo dueño).
* **Códigos HTTP:** `200 OK`, `401 Unauthorized`, `403 Forbidden`, `404 Not Found`.

### 12.23 `POST /colecciones/{id}/colaborativo/aprobar` (HU12 / RF15)
* **Propósito:** Aprueba de forma selectiva un conjunto de archivos multimedia subidos por invitados. Los archivos aprobados pasan a integrarse formalmente en la galería de la colección.
* **Autenticación:** Obligatoria (`auth`, fotógrafo dueño).
* **Entrada (JSON):** `{ "ids": [10, 11, 14] }`
* **Códigos HTTP:** `200 OK`, `400 Bad Request`, `401 Unauthorized`, `403 Forbidden`.

### 12.24 `POST /colecciones/{id}/colaborativo/rechazar` (HU12 / RF15)
* **Propósito:** Rechaza y elimina inmediatamente los archivos seleccionados (eliminando sus archivos físicos en disco y su fila en BD).
* **Autenticación:** Obligatoria (`auth`, fotógrafo dueño).
* **Entrada (JSON):** `{ "ids": [12, 13] }`
* **Códigos HTTP:** `200 OK`, `400 Bad Request`, `401 Unauthorized`, `403 Forbidden`.

### 12.25 `POST /favoritos/{id}` (HU23 / RF21)
* **Propósito:** Agrega una foto o video perteneciente a una colección pública a la lista privada de favoritos del usuario autenticado.
* **Autenticación:** Obligatoria (`auth`).
* **Códigos HTTP:** `201 Created`, `401 Unauthorized`, `403 Forbidden` (si la colección no es pública), `404 Not Found`.

### 12.26 `DELETE /favoritos/{id}` (HU23 / RF21)
* **Propósito:** Quita un archivo de la lista de favoritos del usuario.
* **Autenticación:** Obligatoria (`auth`).
* **Códigos HTTP:** `200 OK`, `401 Unauthorized`.

### 12.27 `GET /favoritos` (HU23 / RF21)
* **Propósito:** Lista los elementos favoritos guardados por el usuario autenticado (información privada, no expuesta a otros usuarios).
* **Autenticación:** Obligatoria (`auth`).
* **Códigos HTTP:** `200 OK`, `401 Unauthorized`.

### 12.28 `POST /sistema/backup` (HU13 / RNF5, RNF6, RNF7)
* **Propósito:** Ejecuta un respaldo SQL completo de la base de datos MySQL en PHP puro y rota automáticamente los respaldos conservando exactamente las últimas 3 copias. Registra la auditoría en la tabla `backups`.
* **Códigos HTTP:** `201 Created`.

### 12.29 `GET /sistema/backups` (HU13 / RNF7)
* **Propósito:** Consulta el historial de respaldos almacenados en el sistema con su nombre, ruta y fecha/hora.
* **Códigos HTTP:** `200 OK`.

### 12.30 `POST /sistema/limpiar-colaborativos` (HU12 / RF15)
* **Propósito:** Tarea programada para purgar y eliminar definitivamente del disco y de la base de datos todos los archivos colaborativos no aprobados con más de 24 horas de antigüedad.
* **Códigos HTTP:** `200 OK`.

---

## 13. Matriz de Trazabilidad: Backlog Priorizado (29 Historias de Usuario)

| Orden | ID | Historia de Usuario | Sprint | Estado Backend | Endpoint(s) / Mecanismo Técnico |
| :---: | :--- | :--- | :---: | :---: | :--- |
| 1 | HU1 | Inicio de sesión básico (acceso a paneles) | Sprint 1 | ✅ Completo | `POST /auth/login` (emite token JWT y rol) |
| 2 | HU8 | Registro con selección de rol (Fotógrafo / Cliente) | Sprint 1 | ✅ Completo | `POST /auth/register` (crea en usuarios + tabla hija) |
| 3 | HU25 | Registro obligatorio de campos (Nombre, correo, pass, tel) | Sprint 1 | ✅ Completo | `AuthValidator` y `UserRepository::create` |
| 4 | HU2 | Creación de colecciones y clasificación de visibilidad | Sprint 1 | ✅ Completo | `POST /colecciones` (privada o pública) |
| 5 | HU5 | Subida de imágenes o videos a colecciones | Sprint 1 | ✅ Completo | `POST /colecciones/{id}/multimedia` |
| 6 | HU14 | Visualización con marca de agua automática | Sprint 1 | ✅ Completo | `GET /multimedia/{id}/vista-previa` (GD diagonal) |
| 7 | HU17 | Generación de QR / enlace permanente de acceso directo | Sprint 2 | ✅ Completo | `POST /colecciones/{id}/qr-acceso` (`qr_tokens`) |
| 8 | HU3 | Acceso a colección privada vía enlace de invitación | Sprint 2 | ✅ Completo | `GET /invitaciones/{token}` y `POST .../canjear` |
| 9 | HU20 | Bloqueo de acceso directo por URL a colecciones privadas | Sprint 2 | ✅ Completo | `MultimediaService::verificarAccesoALaColeccion` |
| 10 | HU21 | Envío de código de verificación al correo | Sprint 2 | ✅ Completo | `POST /auth/verificar-email`, `.../reenviar-codigo` |
| 11 | HU24 | Acceso y visualización de galerías en colecciones públicas | Sprint 2 | ✅ Completo | `GET /colecciones/publicas`, `GET /colecciones/{id}` |
| 12 | HU19 | Impedir el registro de usuarios duplicados por correo | Sprint 2 | ✅ Completo | `AuthService` (código HTTP 409 Conflict) |
| 13 | HU31 | Aceptación de política de privacidad y Ley 18.331 | Sprint 2 | ✅ Completo | `POST /fotografos/aceptar-politicas` |
| 14 | HU10 | Descarga directa e individual en dos calidades | Sprint 2 | ✅ Completo | `GET /multimedia/{id}/descargar?calidad=buena\|alta` |
| 15 | HU4 | Generación de QR colaborativo de evento (caducidad 1 día)| Sprint 3 | ✅ Completo | `POST /colecciones/{id}/qr-colaborativo` (24h) |
| 16 | HU7 | Descarga e impresión física del QR colaborativo | Sprint 3 | ✅ Completo | `GET .../imprimir` y `GET /qr/{token}/svg` |
| 17 | HU11 | Carga de archivos vía QR por invitados (sin cuenta) | Sprint 3 | ✅ Completo | `GET /colaborativo/{token}` y `POST .../subir` |
| 18 | HU12 | Moderación y aprobación selectiva de material de invitados | Sprint 3 | ✅ Completo | `GET .../pendientes`, `POST .../aprobar`, `.../rechazar` |
| 19 | HU26 | Agregar hashtags a colecciones públicas | Sprint 3 | ✅ Completo | `POST /colecciones` (tabla `coleccion_hashtags`) |
| 20 | HU27 | Filtrado de colecciones públicas por hashtags | Sprint 3 | ✅ Completo | `GET /colecciones/publicas?hashtag=...`, `GET /hashtags` |
| 21 | HU16 | Control de cuota (3 GB) y subida parcial con excedentes | Sprint 4 | ✅ Completo | `MultimediaService::uploadMultiple`, `GET /fotografos/cuota` |
| 22 | HU28 | Validación de videos (clips y límite de 800MB) | Sprint 4 | ✅ Completo | `MultimediaValidator` (800MB fotógrafo, 80MB clips) |
| 23 | HU6 | Eliminación regular de imágenes o videos por fotógrafo | Sprint 4 | ✅ Completo | `DELETE /multimedia/{id}` (físico y BD) |
| 24 | HU32 | Procesamiento de recortes de video 15s y original | Sprint 4 | ✅ Completo | `MediaProcessor::generarPreviewVideo` (FFmpeg) |
| 25 | HU22 | Edición de datos básicos y reasignación de colección | Sprint 5 | ✅ Completo | `PUT /multimedia/{id}` |
| 26 | HU18 | Edición de perfil de fotógrafo y directorio público | Sprint 5 | ✅ Completo | `GET /fotografos`, `GET .../{id}`, `PUT .../perfil` |
| 27 | HU23 | Marcar como favorita una imagen o video pública | Sprint 5 | ✅ Completo | `POST /favoritos/{id}`, `DELETE .../{id}`, `GET /favoritos` |
| 28 | HU13 | Respaldo automático diario de base de datos (3 copias) | Sprint 5 | ✅ Completo | `BackupService`, `POST /sistema/backup`, `cron-backup.php` |
| 29 | HU15 | Entrega de guía de uso, capacitación y cierre | Sprint 5 | ✅ Completo | Documentado en `AUDITORIA_ENDPOINTS.md` |

---

## 14. Registro Consolidado de Archivos del Backend

| Archivo | Tipo | Capa | Responsabilidad / Historias de Usuario |
| :--- | :---: | :---: | :--- |
| `public/index.php` | Modificado | Front Controller | Autoloader, CORS, normalización de rutas y despacho |
| `routes.php` | Modificado | Rutas | Mapeo de los 30+ endpoints con sus requisitos de seguridad |
| `cron-backup.php` | Nuevo | CLI / Cron | Ejecución desatendida de respaldos SQL (HU13) y purga (HU12) |
| `database/schema.sql` | Modificado | Base de Datos | Esquema relacional completo en MySQL |
| `database/migration.sql` | Nuevo | Base de Datos | Script de migración incremental no destructivo |
| `src/Core/Router.php` | Modificado | Core | Despacho dinámico con múltiples parámetros `{param}` |
| `src/Core/Request.php` | Modificado | Core | Lectura de bodies JSON y query params en `$_GET` |
| `src/Core/Response.php` | Existente | Core | Emisión estandarizada de respuestas JSON (200, 201, 400, etc.) |
| `src/Core/Config.php` | Modificado | Core | Cuota 3 GB, límites de video 800MB/80MB, rutas y claves JWT |
| `src/Core/AuthMiddleware.php` | Existente | Core | Validación de tokens Bearer JWT y carga de usuario |
| `src/Core/Database.php` | Existente | Core | Conexión singleton PDO configurada para UTF-8 y excepciones |
| `src/helpers/Jwt.php` | Existente | Helper | Firma y verificación HMAC-SHA256 en PHP puro |
| `src/helpers/MediaProcessor.php` | Modificado | Helper | Marca de agua GD, clip 15s FFmpeg, buena calidad 1920px y borrado físico |
| `src/helpers/QrGenerator.php` | Nuevo | Helper | Generador de matriz QR en SVG nativo y plantilla imprimible HTML (HU7) |
| `src/dtos/RegisterDto.php` | Existente | DTO | DTO tipado inmutable de registro de usuarios |
| `src/dtos/LoginDto.php` | Existente | DTO | DTO tipado inmutable de inicio de sesión |
| `src/dtos/CreateColeccionDto.php` | Existente | DTO | DTO tipado inmutable de colecciones |
| `src/dtos/MultimediaDto.php` | Modificado | DTO | DTO con soporte para metadatos y flag `esInvitado` |
| `src/validators/AuthValidator.php` | Existente | Validador | Valida datos de registro y login |
| `src/validators/ColeccionValidator.php` | Modificado | Validador | Valida colecciones y autocompleta `fotografo_id` si hay sesión |
| `src/validators/MultimediaValidator.php`| Modificado | Validador | Valida MIME real, 800MB (fotógrafo) y 80MB clips (invitado) |
| `src/repository/UserRepository.php` | Modificado | Repositorio | CRUD usuarios, verificación de email (HU21), políticas (HU31) y perfiles (HU18) |
| `src/repository/ColeccionRepository.php`| Modificado | Repositorio | Consultas colecciones, hashtags (HU26/27), `qr_tokens` y `acceso_colecciones` |
| `src/repository/MultimediaRepository.php`| Modificado| Repositorio | Persistencia multimedia, cuota (HU16), moderación (HU12), borrado (HU6), edición (HU22) |
| `src/services/AuthService.php` | Modificado | Servicio | Lógica de registro, login, códigos de verificación (HU21) y token JWT |
| `src/services/ColeccionService.php` | Modificado | Servicio | Reglas de colecciones públicas, hashtags, invitaciones privadas (HU3) y QR (HU17) |
| `src/services/MultimediaService.php` | Modificado | Servicio | Subida con cuota 3GB, descargas en 2 calidades, moderación y purga 24h |
| `src/services/BackupService.php` | Nuevo | Servicio | Respaldo SQL de base de datos y rotación estricta de 3 copias (HU13) |
| `src/controllers/AuthController.php` | Modificado | Controlador | Endpoints de register, login, verificar email y reenviar código |
| `src/controllers/ColeccionController.php`| Modificado| Controlador | Endpoints de colecciones públicas, invitaciones, QR permanente y hashtags |
| `src/controllers/MultimediaController.php`| Modificado| Controlador | Endpoints de subida múltiple, descarga directa, borrado, edición y moderación |
| `src/controllers/FotografoController.php`| Nuevo | Controlador | Endpoints de directorio, perfil profesional, políticas y cuota de almacenamiento |
| `src/controllers/ColaborativoController.php`| Nuevo | Controlador | Endpoints de QR colaborativo, hoja de impresión HTML, SVG y subida de invitados |
| `src/controllers/FavoritoController.php`| Nuevo | Controlador | Endpoints de marcar, desmarcar y listar favoritos privados de contenido público |
| `src/controllers/SistemaController.php` | Nuevo | Controlador | Endpoints de respaldos SQL y limpieza programada |
| `src/controllers/HomeController.php` | Existente | Controlador | Endpoint diagnóstico `/api/ping` |
| `uploads/.htaccess` | Existente | Seguridad | Denegación estricta de acceso HTTP estático a binarios originales y vistas previas |

