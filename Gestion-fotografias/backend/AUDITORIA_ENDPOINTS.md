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
