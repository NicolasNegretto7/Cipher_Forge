# 2. Arquitectura Propuesta, Modelado y Justificación Tecnológica

---

## 1. Arquitectura Propuesta del Sistema

El sistema **Cipher_Forge** adopta una **arquitectura en capas (Layered Architecture)** basada en el patrón **Cliente-Servidor desacoplado**, donde el frontend (interfaz de usuario) interactúa con el backend exclusivamente a través de una **API RESTful** sobre HTTP, persistiendo datos en un motor relacional y almacenando archivos multimedia en el sistema de archivos protegido del contenedor.

### 1.1 Diagrama de Arquitectura Global

```mermaid
graph TD
    subgraph Clientes ["Capa de Presentación (Frontend)"]
        FC["Frontend Fotógrafo\n(HTML5 / CSS3 / Vanilla JS / Bootstrap)"]
        FU["Frontend Cliente\n(HTML5 / CSS3 / Vanilla JS / Bootstrap)"]
        INV["Invitado móvil\n(Escaneo QR / Carga rápida)"]
    end

    subgraph Red ["Capa de Entrada y Red"]
        APACHE["Servidor Web Apache 2.4\n(Puerto 8080 - mod_rewrite)"]
    end

    subgraph Backend ["Capa de Aplicación (PHP 8.2 Backend)"]
        ROUTER["Enrutador Front Controller\n(Router.php / Request / Response)"]
        AUTH_MID["Middleware de Autenticación\n(AuthMiddleware / Sesiones / Tokens)"]
        
        subgraph Modulos ["Controladores y Servicios"]
            CTRL["Controladores (Controllers)\n(AuthController, ColeccionController, etc.)"]
            VAL["Validadores (Validators) & DTOs"]
            SERV["Servicios de Negocio (Services)\n(AuthService, ColeccionService)"]
            REPO["Repositorios (Repositories - PDO)\n(UserRepository, ColeccionRepository)"]
        end
    end

    subgraph Multimedia ["Procesamiento y Almacenamiento Multimedia"]
        GD["Librería GD (PHP)\n(Marca de agua en imágenes)"]
        FFMPEG["FFmpeg (Docker)\n(Recorte de 15s para vista previa de videos)"]
        FS[("Volumen uploads_data\n(/var/www/html/uploads)")]
    end

    subgraph Persistencia ["Capa de Datos"]
        MYSQL[("MySQL 8.0 (Docker db)\n(Puerto 3306 - db_data)")]
    end

    FC -->|HTTP / JSON / Multipart| APACHE
    FU -->|HTTP / JSON| APACHE
    INV -->|HTTP / Multipart| APACHE
    
    APACHE --> ROUTER
    ROUTER --> AUTH_MID
    AUTH_MID --> CTRL
    CTRL --> VAL
    CTRL --> SERV
    SERV --> REPO
    SERV --> GD
    SERV --> FFMPEG
    
    GD --> FS
    FFMPEG --> FS
    REPO -->|PDO MySQL| MYSQL
```

### 1.2 Descripción de Capas

1. **Capa de Presentación (Frontend):**
   - Dividida en portales especializados según el rol de negocio: `frontend-fotografo` (gestión de colecciones, subida de medios, códigos QR y panel de moderación) y `frontend-cliente` (exploración de colecciones públicas, acceso privado por enlace y descarga directa individual).
   - Consumo asíncrono de la API mediante la API nativa `fetch` de JavaScript, procesando respuestas en formato JSON.

2. **Capa de Enrutamiento y Control de Acceso (Front Controller & Middleware):**
   - Apache redirige todas las peticiones entrantes hacia `public/index.php` utilizando `mod_rewrite`.
   - El componente `Router` despacha la solicitud hacia el controlador correspondiente basándose en el método HTTP (GET, POST, etc.) y la URI.
   - `AuthMiddleware` intercepta peticiones protegidas para validar autenticación y pertenencia de roles antes de ejecutar la lógica de negocio.

3. **Capa de Negocio y Dominio (Services, DTOs, Validators):**
   - **DTOs (Data Transfer Objects):** Encapsulan y tipan los datos de entrada evitando el manejo de arrays asociativos genéricos.
   - **Validators:** Verifican reglas de integridad (formatos de correo, complejidad de contraseña, tipos MIME de archivos y pesos máximos).
   - **Services:** Implementan las reglas de negocio (procesamiento de imágenes con marca de agua, generación de tokens QR con expiración, y reglas de cuota de 3 GB).

4. **Capa de Acceso a Datos (Repositories):**
   - Centraliza las consultas SQL hacia MySQL mediante `PDO` (PHP Data Objects).
   - Utiliza exclusivamente consultas preparadas (`prepared statements`) con vinculación de parámetros, mitigando ataques de inyección SQL (alineado con [04-seguridad.md](04-seguridad.md)).

5. **Capa de Almacenamiento y Procesamiento de Medios:**
   - **Librería GD:** Imprime marcas de agua diagonales sobre copias de previsualización de imágenes JPG en el momento de la subida.
   - **FFmpeg:** Genera un clip de 15 segundos para la vista previa del video, preservando el archivo original de hasta 800 MB para la descarga directa.
   - **Filesystem montado:** Almacenamiento persistente desacoplado en el volumen de Docker `uploads_data`.

---

## 2. Modelado de Datos (Diagrama Entidad-Relación)

La base de datos relacional en MySQL 8.0 estructura los datos del sistema implementando herencia de roles (tabla padre `usuarios` con extensiones `fotografos` y `clientes`), colecciones, recursos multimedia y control de seguridad.

### 2.1 Diagrama Entidad-Relación (Mermaid ERD)

```mermaid
erDiagram
    USUARIOS ||--o| CLIENTES : "es un"
    USUARIOS ||--o| FOTOGRAFOS : "es un"
    USUARIOS ||--o{ COLECCIONES : "posee (fotografo)"
    USUARIOS ||--o{ FAVORITOS : "marca"
    USUARIOS ||--o{ ACCESO_COLECCIONES : "tiene acceso"
    
    COLECCIONES ||--o{ MULTIMEDIA : "contiene"
    COLECCIONES ||--o{ QR_TOKENS : "genera"
    COLECCIONES ||--o{ COLECCION_HASHTAGS : "clasificada por"
    COLECCIONES ||--o{ ACCESO_COLECCIONES : "asignada a"
    
    HASHTAGS ||--o{ COLECCION_HASHTAGS : "agrupa"
    MULTIMEDIA ||--o{ FAVORITOS : "es marcado en"

    USUARIOS {
        int id PK
        string nombre_completo
        string email UK
        string telefono
        boolean email_verificado
        string password_hash
        enum rol "fotografo, cliente"
    }

    CLIENTES {
        int id_cliente PK,FK
    }

    FOTOGRAFOS {
        int id_fotografo PK,FK
        boolean politicas_aceptadas
    }

    COLECCIONES {
        int id PK
        int fotografo_id FK
        enum tipo_visibilidad "privada, publica"
        string titulo
        string descripcion
        timestamp creado_en
    }

    MULTIMEDIA {
        int id_multimedia PK
        int coleccion_id FK
        string titulo
        string descripcion
        string ruta_original
        string vista_previa
        bigint tamanio
        boolean es_invitado
        enum tipo "video, imagen"
    }

    ACCESO_COLECCIONES {
        int usuario_id PK,FK
        int coleccion_id PK,FK
        boolean permitir_alta_calidad
        boolean permitir_buena_calidad
    }

    FAVORITOS {
        int usuario_id PK,FK
        int favorito_id PK,FK
    }

    QR_TOKENS {
        int id_token PK
        int coleccion_id FK
        string token UK
        enum tipo "colaborativo, acceso"
        datetime expiracion
        timestamp creacion_token
    }

    HASHTAGS {
        int id_hashtags PK
        string nombre_hashtags UK
    }

    COLECCION_HASHTAGS {
        int id_hashtags PK,FK
        int coleccion_id PK,FK
    }

    BACKUPS {
        int id_backup PK
        string ruta_backup
        string nombre_backup
        timestamp fecha_backup
    }
```

### 2.2 Decisiones de Diseño en el Modelo

* **Jerarquía de Usuarios (Herencia de Tablas):** La tabla `usuarios` concentra las credenciales y atributos comunes (autenticación segura, verificación de correo, rol). Las tablas hijas `fotografos` y `clientes` referencian a `usuarios.id` con eliminación en cascada (`ON DELETE CASCADE`). Esto previene duplicidad de cuentas y permite escalar datos específicos de cada rol en fases futuras.
* **Separación de Original y Vista Previa:** En `multimedia`, se almacenan `ruta_original` (archivo de máxima resolución para descarga directa) y `vista_previa` (copia optimizada con marca de agua o clip de 15 segundos). La ruta original no se expone directamente en el cliente.
* **Tokens QR Efímeros vs Permanentes:** La tabla `qr_tokens` gestiona tanto el QR de carga colaborativa (con caducidad de 24 horas mediante el campo `expiracion`) como el enlace permanente de acceso a colecciones privadas.

---

## 3. Flujos de Información y Comunicación

### 3.1 Flujo de Subida y Procesamiento de Imágenes

```mermaid
sequenceDiagram
    autonumber
    actor F as Fotógrafo
    participant Front as Frontend (UI)
    participant API as Backend (PHP Router / Service)
    participant GD as Motor GD
    participant FS as Filesystem (uploads/)
    participant DB as MySQL Database

    F->>Front: Selecciona imagen JPG y confirma subida
    Front->>API: POST /colecciones/{id}/multimedia (multipart/form-data + JWT/Cookie)
    API->>API: Valida cuota de almacenamiento (< 3 GB) y formato JPG
    API->>FS: Guarda archivo original en /uploads/originals/
    API->>GD: Procesa copia y superpone marca de agua en diagonal
    GD->>FS: Guarda vista previa optimizada en /uploads/previews/
    API->>DB: INSERT INTO multimedia (ruta_original, vista_previa, tamanio, ...)
    DB-->>API: Confirmación de registro (ID generado)
    API-->>Front: HTTP 201 Created (JSON con datos y URL de preview)
    Front-->>F: Renderiza miniatura en la galería
```

### 3.2 Flujo de Descarga Directa en Dos Calidades (Post-CC-01)

Tras la decisión del equipo documentada en [08_control_de_cambios.md](08_control_de_cambios.md) (CC-01 y CC-02), se eliminó el ciclo de solicitudes por notificación:

```mermaid
sequenceDiagram
    autonumber
    actor C as Cliente
    participant Front as Frontend Galería
    participant API as Backend Download Controller
    participant FS as Filesystem

    C->>Front: Elige "Buena Calidad" o "Alta Calidad" en imagen individual
    Front->>API: GET /multimedia/{id}/download?calidad={buena|alta}
    API->>API: Valida permiso de acceso a la colección (pública o token privado)
    alt Calidad = Buena
        API->>FS: Obtiene versión estándar/media procesada
    else Calidad = Alta
        API->>FS: Obtiene archivo original de alta resolución
    end
    API-->>Front: HTTP 200 OK (Content-Type: image/jpeg, Content-Disposition: attachment)
    Front-->>C: Descarga directa del archivo en el navegador
```

---

## 4. Justificación Tecnológica

A continuación se fundamenta la selección de cada tecnología que compone el stack de **Cipher_Forge**, evaluando ventajas técnicas, viabilidad dentro del marco curricular de UTU y alternativas descartadas.

| Componente | Tecnología Seleccionada | Justificación Técnica | Alternativas Descartadas y Motivo |
| :--- | :--- | :--- | :--- |
| **Backend** | **PHP 8.2 (Vanilla OOP)** | Tipado estricto (`declare(strict_types=1)`), manejo robusto de excepciones, soporte nativo de extensiones para manipulación de streams y binarios. Curva de aprendizaje óptima para estudiantes y portabilidad sin dependencias externas pesadas. | **Node.js / Express:** Mayor complejidad en el manejo de streams binarios pesados en entornos locales sin colas dedicadas.<br>**Laravel:** Sobrecarga de dependencias y magia sintáctica innecesaria para los requerimientos evaluables de UTU. |
| **Servidor Web** | **Apache 2.4 con mod_rewrite** | Compatibilidad nativa con PHP vía `mod_php` en la imagen oficial, estabilidad comprobada para redirección centralizada hacia Front Controller mediante `.htaccess` o configuración de VirtualHost. | **Nginx + PHP-FPM:** Excelente rendimiento, pero requiere configurar dos servicios o procesos independientes, aumentando la fricción de configuración en entorno local. |
| **Frontend** | **HTML5 Semántico, CSS3, Bootstrap 5 y Vanilla JavaScript** | Estructura accesible y limpia (HTML semántico), diseño adaptable e interactivo mediante Bootstrap 5 sin sobrecarga de frameworks, y JavaScript nativo moderno (ES6+, `fetch`, `async/await`) que garantiza comprensión línea por línea del código. | **React / Vue:** Requeriría tooling de compilación (Vite, Webpack, Node.js local), alejando el foco del proyecto de la lógica de negocio y arquitectura base. |
| **Base de Datos** | **MySQL 8.0** | Motor relacional estándar de la industria, soporte completo para integridad referencial (`FOREIGN KEY`, transacciones ACID), tipos ENUM para roles y estados, y funciones de agregación para cálculo de cuotas en bytes. | **PostgreSQL:** Prestaciones similares, pero MySQL ofrece mayor compatibilidad directa con las herramientas didácticas y el stack PHP habitual de UTU.<br>**MongoDB:** Inadecuado por la naturaleza fuertemente relacional de permisos, colecciones y usuarios. |
| **Procesamiento de Video** | **FFmpeg en Contenedor** | Herramienta líder para transcodificación y extracción de recortes de video. Permite generar previews de 15 segundos sin saturar memoria RAM, aislando códecs en el contenedor Linux. | **Librerías JS en cliente:** Imposibilitadas de manejar archivos de 800 MB sin colapsar el navegador del cliente. |
| **Contenedores y Despliegue** | **Docker & Docker Compose** | Garantiza paridad absoluta entre los entornos de desarrollo de los tres integrantes del equipo y la mesa de evaluación de UTU. Una única orden (`docker compose up`) levanta backend, base de datos, extensiones y dependencias compiladas. | **XAMPP / WampServer local:** Problemas frecuentes de incompatibilidad de versiones de PHP/MySQL entre sistemas operativos Windows de los alumnos, además de carecer de FFmpeg preinstalado. |
