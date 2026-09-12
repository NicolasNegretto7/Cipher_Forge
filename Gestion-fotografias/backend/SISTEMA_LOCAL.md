# SISTEMA_LOCAL.md — Restricción de `/sistema/*` a la red local (H02)

> Documentación de la implementación del hallazgo **H02** aprobado por el responsable (2026-09-12).
> Registro canónico del hallazgo: `important.md` → H02.

## 1. Propósito

Evitar que operaciones administrativas queden expuestas a cualquier llamador HTTP sin necesidad de introducir un rol "administrador": la solución aprobada fue **restringir los tres endpoints de `/sistema/*` a la máquina local / red local**.

Endpoints afectados:

- `POST /sistema/backup` — genera un respaldo manual (HU13 / RNF5, RNF6).
- `GET /sistema/backups` — lista el historial de respaldos (RNF7).
- `POST /sistema/limpiar-colaborativos` — purga material de invitados no aprobado > 24 h (HU12 / RF15).

## 2. Decisión

Ante el hallazgo H02 (Riesgo Medio) se evaluaron dos caminos:

1. Crear un rol "administrador" y exigir `auth` en esas rutas.
2. Restringir por origen de red (sin nuevas tablas ni roles). ← **elegido**

Se eligió la opción 2 porque el sistema no tiene un rol administrador definido en el alcance (`docs/01-requerimientos.md`) y la restricción por red cubre el riesgo real (evitar que cualquiera dispare respaldos/purgas o lea el historial).

## 3. Cómo funciona

El guard vive en `backend/src/controllers/SistemaController.php` (`restringirALocal()`, invocado en el constructor) y aplica a los tres endpoints porque todos pasan por ese controlador.

Regla por defecto (sin configuración):

```
PERMITIDO  si REMOTE_ADDR NO es una IP pública globalmente enrutable
           (loopback 127.0.0.1/::1, rangos privados RFC1918 10/8, 172.16/12, 192.168/16,
            direcciones de reserva y enlaces locales, incluida la red del bridge de Docker)
BLOQUEADO  con HTTP 403 JSON en cualquier otro caso (IP pública de internet)
```

Lógica implementada: se acepta el peer si `filter_var(REMOTE_ADDR, FILTER_VALIDATE_IP, FILTER_FLAG_NO_PRIV_RANGE | FILTER_FLAG_NO_RES_RANGE)` devuelve `false` (es decir, la IP **no** es pública). Solo confía en `REMOTE_ADDR` (el peer real de la conexión TCP de Apache); **no** se procesa `X-Forwarded-For`.

### Endurecimiento opcional por entorno

La variable `SISTEMA_ALLOWED_IPS` (CIDRs o IPs separados por coma) reemplaza la regla por defecto por una coincidencia explícita:

```bash
SISTEMA_ALLOWED_IPS=10.0.0.0/8,192.168.0.0/16
```

Con esta variable definida, cualquier IP que no caiga dentro de la lista responde `403`. En `docker-compose.yml` está documentada como comentario en el servicio `app` (descomentar y ajustar según la red de despliegue).

### Por qué el respaldo automático no se ve afectado

El respaldo y la purga automáticos **no usan HTTP**: `backend/cron-backup.php` (worker `docker-compose`, servicio `worker`) instancia `BackupService` y `MultimediaService` directamente por CLI (`cron-backup.php:61-64`). Por lo tanto HU13 (respaldo diario) y HU12 (purga tras 24 h) siguen activos en su intervalo normal (`BACKUP_INTERVAL_SEG=86400`, `PURGE_INTERVAL_SEG=3600`) sin depender de las rutas restringidas.

## 4. Implementación

| Archivo | Cambio |
| --- | --- |
| `backend/src/controllers/SistemaController.php` | Guard `restringirALocal()` en el constructor + helpers `ipEnSubred()`. |
| `backend/src/Core/Config.php` | Nuevo método `ipsPermitidasSistema()` (lee `SISTEMA_ALLOWED_IPS`; vacío = regla por defecto). |
| `backend/routes.php` | Comentario de trazabilidad H02 (rutas sin cambios). |
| `backend/docker-compose.yml` | Comentario de descubrimiento de `SISTEMA_ALLOWED_IPS`. |
| `backend/SISTEMA_LOCAL.md` | Este documento. |

## 5. Cómo verificarlo

Levantar el stack y probar desde el host (`http://localhost:8080`):

1. **Caso normal (host local → permitido):** el tráfico entra por el bridge de Docker con IP privada (`172.x`, `10.x` o `192.168.x`) y debe responder `200`.

   ```powershell
   Invoke-RestMethod -Method Get -Uri http://localhost:8080/sistema/backups
   ```

2. **Caso bloqueado (simulación de origen externo):** definir una lista explícita que excluya al caller:

   ```yaml
   environment:
     - SISTEMA_ALLOWED_IPS=8.8.8.8/32
   ```

   Tras `docker compose up -d`, la misma llamada responde `HTTP 403` con cuerpo JSON `{"ok":false,"mensaje":"Acceso restringido a la máquina local."}`.

3. **Sanidad de sintaxis:** `php -l src/controllers/SistemaController.php` y `php -l src/Core/Config.php`.

## 6. Límites y consideraciones

- Es una defensa por origen de red, no una autenticación: si el stack se publicara a internet, debe ajustarse `SISTEMA_ALLOWED_IPS` o añadirse `auth`.
- El host de desarrollo se ve como IP del NAT del bridge (privada), por lo que el caso "loopback puro" (`127.0.0.1`) no aplica dentro del contenedor; la regla por defecto lo cubre al aceptar todo el tráfico no público.
- No se introdujo rol administrador ni cambios de esquema (`schema.sql`/`migration.sql` intactos).