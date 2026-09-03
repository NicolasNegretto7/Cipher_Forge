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

## Archivos modificados/creados en este sprint (referencia rápida)

| Archivo | Tipo | Acción |
| :--- | :--- | :--- |
| `src/helpers/Jwt.php` | Nuevo | Tokens JWT HS256 (encode/decode) |
| `src/Core/Config.php` | Nuevo | Clave JWT, horas de validez y rutas de uploads |
| `src/Core/AuthMiddleware.php` | Modificado | Auth obligatoria y opcional a partir del token |
| `src/services/AuthService.php` | Modificado | `login()` emite token JWT |
| `routes.php` | Modificado | Rutas multimedia y requisitos de seguridad |
| `src/controllers/MultimediaController.php` | Nuevo | Subida, vista previa, original y listado |
| `src/services/MultimediaService.php` | Nuevo | Reglas de negocio y control de acceso (HU20) |
| `src/validators/MultimediaValidator.php` | Nuevo | Validación MIME, tamaño y metadatos |
| `src/dtos/MultimediaDto.php` | Nuevo | DTO de metadatos multimedia |
| `src/repository/MultimediaRepository.php` | Nuevo | Persistencia multimedia + acceso a colecciones |
| `src/helpers/MediaProcessor.php` | Nuevo | Procesamiento binario (gd / ffmpeg) |
| `uploads/.htaccess` | Nuevo | Deniega acceso estático directo a uploads |
| `docker-entrypoint.sh` | Nuevo | Crea y da permisos a las carpetas de uploads |
| `Dockerfile` | Modificado | Copia el entrypoint personalizado |
