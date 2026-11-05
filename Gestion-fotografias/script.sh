#!/usr/bin/env bash
# =============================================================================
#  Cipher Forge - Instalador automatico para un servidor Ubuntu (VPS)
# =============================================================================
#  Que hace:
#    Automatiza, en un solo comando, los pasos del manual tecnico
#    (docs/manual-de-usuario-tecnico.md): prepara el sistema, instala Docker,
#    configura el proyecto, crea el archivo .env, levanta los contenedores,
#    publica el sitio con Nginx y, si el DNS ya esta listo, activa HTTPS.
#
#  Como se usa (en el servidor, por SSH):
#      sudo bash script.sh
#
#  Opciones:
#      --dominio DOMINIO   Tu dominio (ej. cipherforge.com)
#      --correo EMAIL      Tu correo (avisos del certificado y pruebas)
#      --sin-https         No instalar HTTPS en esta ejecucion
#      --sin-correo        No configurar el correo (SMTP) en esta ejecucion
#      --asumir-si         Responder "si" a las confirmaciones (no borra datos)
#      --simular           Mostrar lo que haria sin cambiar nada (prueba segura)
#      --verificar         Revisar el estado actual sin modificar nada
#      --ayuda, -h         Mostrar esta ayuda
#
#  Seguridad:
#      - No guarda contrasenas ni claves dentro de este archivo.
#      - Pide confirmacion antes de mover datos o reemplazar archivos importantes.
#      - Nunca usa "docker compose down -v" (eso borraria la base y las fotos).
#
#  Este script NO reemplaza a los paneles de tu proveedor: contratar el
#  servidor/dominio/correo, abrir el firewall y crear los registros DNS son
#  acciones que tenes que hacer vos desde las paginas web de cada proveedor.
# =============================================================================

set -euo pipefail

# -- Opciones y estado --------------------------------------------------------
DOMAIN="${DOMAIN:-}"
EMAIL="${EMAIL:-}"
SKIP_HTTPS=0
SKIP_MAIL=0
ASSUME_YES=0
DRY_RUN=0
VERIFY_ONLY=0
SHOW_HELP=0
PENDIENTE_HTTPS=0
PENDIENTE_MAIL=0
HTTPS_SKIPPED=0
MAIL_SKIPPED=0
UFW_SKIPPED=0
MAIL_CONFIGURED=0
MAIL_READY=0
BACKUP_OK=0
QUARANTINE_USED=0
EXISTING_DEPLOYMENT=0

# -- Rutas --------------------------------------------------------------------
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$PROJECT_DIR/backend"
ENV_FILE="$BACKEND_DIR/.env"
COMPOSE_FILE="$BACKEND_DIR/docker-compose.yml"
NGINX_SITE="/etc/nginx/sites-available/cipher-forge"
QUARANTINE_DIR="/var/backups/cipher-forge/instalacion-$(date +%Y%m%d-%H%M%S)"
TEST_MAIL_FILE="$BACKEND_DIR/.cipher-forge-test-mail-$$.php"

# -- Colores (sin secuencias de escape escritas en el archivo) ----------------
if [ -t 1 ] && command -v tput >/dev/null 2>&1; then
    C_RESET="$(tput sgr0 2>/dev/null || true)"
    C_BLUE="$(tput setaf 4 2>/dev/null || true)$(tput bold 2>/dev/null || true)"
    C_GREEN="$(tput setaf 2 2>/dev/null || true)$(tput bold 2>/dev/null || true)"
    C_YELLOW="$(tput setaf 3 2>/dev/null || true)$(tput bold 2>/dev/null || true)"
    C_RED="$(tput setaf 1 2>/dev/null || true)$(tput bold 2>/dev/null || true)"
    C_DIM="$(tput dim 2>/dev/null || true)"
else
    C_RESET=""; C_BLUE=""; C_GREEN=""; C_YELLOW=""; C_RED=""; C_DIM=""
fi

# -- Mensajes -----------------------------------------------------------------
info()  { printf '%s[INFO]%s %s\n' "$C_BLUE" "$C_RESET" "$*"; }
ok()    { printf '%s[ OK ]%s %s\n' "$C_GREEN" "$C_RESET" "$*"; }
warn()  { printf '%s[AVISO]%s %s\n' "$C_YELLOW" "$C_RESET" "$*" >&2; }
err()   { printf '%s[ERROR]%s %s\n' "$C_RED" "$C_RESET" "$*" >&2; }

die() {
    err "$*"
    exit 1
}

banner() {
    printf '\n%s================================================================%s\n' "$C_BLUE" "$C_RESET"
    printf '%s %s%s\n' "$C_BLUE" "$*" "$C_RESET"
    printf '%s================================================================%s\n' "$C_BLUE" "$C_RESET"
}

# Limpieza de archivos temporales del propio script (nunca toca datos del proyecto).
cleanup_temp() {
    rm -f "$TEST_MAIL_FILE" 2>/dev/null || true
}
trap cleanup_temp EXIT

# Se ejecuta ante cualquier error inesperado (set -e).
trap 'err "Ocurrio un error inesperado en la linea $LINENO. Lee el mensaje anterior y consulta $PROJECT_DIR/docs/manual_de_usuario.md (seccion de solucion de problemas)."' ERR

# -- Confirmaciones y preguntas ----------------------------------------------
confirm() {
    # confirm "pregunta" -> devuelve 0 (si) o 1 (no)
    local prompt="${1:-Continuar?}"
    local respuesta=""
    if [ "$DRY_RUN" = 1 ]; then
        info "$prompt -> si (simulado)"
        return 0
    fi
    if [ "$ASSUME_YES" = 1 ]; then
        info "$prompt -> si (--asumir-si)"
        return 0
    fi
    if [ -t 0 ]; then
        read -r -p "$prompt [s/N]: " respuesta || respuesta=""
    elif [ -e /dev/tty ]; then
        read -r -p "$prompt [s/N]: " respuesta < /dev/tty || respuesta=""
    else
        warn "Entorno no interactivo: no puedo preguntar. Vuelve a ejecutar con --asumir-si si estas seguro."
        return 1
    fi
    case "$respuesta" in
        s|S|si|SI|Si|y|Y) return 0 ;;
        *) return 1 ;;
    esac
}

ask() {
    # ask VARIABLE "mensaje" [valor_por_defecto]
    local __var="$1" __prompt="$2" __default="${3:-}" __respuesta=""
    if [ "$DRY_RUN" = 1 ]; then
        printf -v "$__var" '%s' "${__default:-valor-de-ejemplo}"
        return 0
    fi
    if [ -t 0 ]; then
        read -r -p "$__prompt" __respuesta || __respuesta=""
    elif [ -e /dev/tty ]; then
        read -r -p "$__prompt" __respuesta < /dev/tty || __respuesta=""
    else
        warn "Entorno no interactivo: falta el dato $__var."
        return 1
    fi
    [ -z "$__respuesta" ] && __respuesta="$__default"
    printf -v "$__var" '%s' "$__respuesta"
}

ask_secret() {
    local __var="$1" __prompt="$2" __respuesta=""
    if [ "$DRY_RUN" = 1 ]; then
        printf -v "$__var" '%s' "clave-de-ejemplo"
        return 0
    fi
    if [ -t 0 ]; then
        read -r -s -p "$__prompt" __respuesta || __respuesta=""
    elif [ -e /dev/tty ]; then
        read -r -s -p "$__prompt" __respuesta < /dev/tty || __respuesta=""
    else
        return 1
    fi
    printf '\n'
    printf -v "$__var" '%s' "$__respuesta"
}

# -- Ejecucion de comandos (con modo simulacion) ------------------------------
run() {
    if [ "$DRY_RUN" = 1 ]; then
        printf '  %s[simulado]%s %s\n' "$C_DIM" "$C_RESET" "$*"
        return 0
    fi
    "$@"
}

write_file() {
    # write_file RUTA <<'EOF' ... EOF
    local path="$1"
    if [ "$DRY_RUN" = 1 ]; then
        printf '  %s[simulado]%s escribir %s\n' "$C_DIM" "$C_RESET" "$path"
        cat >/dev/null
        return 0
    fi
    cat > "$path"
}

dc() {
    # Atajo para "docker compose" dentro de la carpeta backend.
    if [ "$DRY_RUN" = 1 ]; then
        printf '  %s[simulado]%s (cd %s && docker compose %s)\n' "$C_DIM" "$C_RESET" "$BACKEND_DIR" "$*"
        return 0
    fi
    ( cd "$BACKEND_DIR" && docker compose "$@" )
}

set_env_var() {
    # set_env_var CLAVE VALOR ARCHIVO  (reemplaza o agrega la linea CLAVE=VALOR)
    local key="$1" value="$2" file="$3" tmp="" found=0 line="" display=""
    display="$value"
    case "$key" in
        *PASS*|*SECRET*) display="(oculto)" ;;
    esac
    if [ "$DRY_RUN" = 1 ]; then
        printf '  %s[simulado]%s %s=%s en %s\n' "$C_DIM" "$C_RESET" "$key" "$display" "$file"
        return 0
    fi
    [ -f "$file" ] || die "No existe el archivo de configuracion: $file"
    tmp="$(mktemp)"
    chmod 600 "$tmp"
    while IFS= read -r line || [ -n "$line" ]; do
        if [[ "$line" == "$key="* ]]; then
            printf '%s=%s\n' "$key" "$value" >> "$tmp"
            found=1
        else
            printf '%s\n' "$line" >> "$tmp"
        fi
    done < "$file"
    if [ "$found" = 0 ]; then
        printf '%s=%s\n' "$key" "$value" >> "$tmp"
    fi
    cat "$tmp" > "$file"
    rm -f "$tmp"
    chmod 600 "$file" 2>/dev/null || true
}

env_get() {
    # env_get CLAVE [ARCHIVO] -> imprime el valor sin comillas. No imprime errores.
    local key="$1" file="${2:-$ENV_FILE}" line=""
    [ -f "$file" ] || return 1
    line="$(grep -m1 "^${key}=" "$file" 2>/dev/null || true)"
    [ -n "$line" ] || return 1
    line="${line#*=}"
    line="${line%$'\r'}"
    case "$line" in
        \'*\') line="${line#\'}"; line="${line%\'}" ;;
        \"*\") line="${line#\"}"; line="${line%\"}" ;;
    esac
    printf '%s' "$line"
}

env_has_secrets() {
    # Comprueba solo las claves que no se pueden regenerar sin romper una base ya creada.
    local key value
    for key in MYSQL_ROOT_PASSWORD MYSQL_DATABASE MYSQL_USER MYSQL_PASSWORD JWT_SECRET; do
        value="$(env_get "$key" || true)"
        [ -n "$value" ] || return 1
        case "$value" in
            cambia_esta_clave_root|cambia_esta_clave_app|pega_aqui_el_resultado_de_openssl_rand_hex_32) return 1 ;;
        esac
    done
    return 0
}

env_real_smtp() {
    local host from
    host="$(env_get SMTP_HOST || true)"
    from="$(env_get MAIL_FROM || true)"
    [ -n "$host" ] && [ -n "$from" ] || return 1
    [ "$host" != "smtp.ejemplo.com" ] && [ "$host" != "mailpit" ] || return 1
    return 0
}

ensure_env_defaults() {
    # Completa valores no sensibles que falten, sin cambiar los que ya existen.
    local current
    current="$(env_get FRONTEND_URL || true)"
    if [ -z "$current" ]; then
        set_env_var "FRONTEND_URL" "http://$DOMAIN" "$ENV_FILE"
        current="http://$DOMAIN"
    fi
    current="$(env_get COOKIE_SECURE || true)"
    if [ -z "$current" ]; then
        set_env_var "COOKIE_SECURE" "false" "$ENV_FILE"
    fi
    case "$(env_get FRONTEND_URL || true)" in
        http://*) set_env_var "COOKIE_SECURE" "false" "$ENV_FILE" ;;
        https://*) set_env_var "COOKIE_SECURE" "true" "$ENV_FILE" ;;
    esac
    current="$(env_get SMTP_HOST || true)"
    if [ -z "$current" ] || [ "$current" = "mailpit" ]; then
        set_env_var "SMTP_HOST" "smtp.ejemplo.com" "$ENV_FILE"
    fi
    current="$(env_get SMTP_PORT || true)"
    if [ -z "$current" ] || [ "$current" = "1025" ]; then
        set_env_var "SMTP_PORT" "587" "$ENV_FILE"
    fi
    current="$(env_get SMTP_USER || true)"
    if [ -z "$current" ]; then
        set_env_var "SMTP_USER" "" "$ENV_FILE"
    fi
    current="$(env_get SMTP_PASS || true)"
    if [ -z "$current" ]; then
        set_env_var "SMTP_PASS" "" "$ENV_FILE"
    fi
    current="$(env_get MAIL_FROM || true)"
    if [ -z "$current" ] || [ "$current" = "no-reply@cipherforge.local" ]; then
        set_env_var "MAIL_FROM" "no-reply@$DOMAIN" "$ENV_FILE"
    fi
    current="$(env_get MAIL_FROM_NAME || true)"
    if [ -z "$current" ]; then
        set_env_var "MAIL_FROM_NAME" "Cipher Forge" "$ENV_FILE"
    fi
}

deployment_exists() {
    # Hay datos previos si existe el contenedor de MySQL o un volumen *_db_data.
    [ "$DRY_RUN" = 1 ] && return 1
    command -v docker >/dev/null 2>&1 || return 1
    if docker ps -a --format '{{.Names}}' 2>/dev/null | grep -qx 'cipher_forge_db'; then
        return 0
    fi
    if docker volume ls --format '{{.Name}}' 2>/dev/null | grep -qE '(^|_)db_data$'; then
        return 0
    fi
    return 1
}

normalize_domain() {
    local d="$1"
    d="${d#http://}"
    d="${d#https://}"
    d="${d%%/*}"
    d="${d%.}"
    d="$(printf '%s' "$d" | tr '[:upper:]' '[:lower:]')"
    d="${d#www.}"
    printf '%s' "$d"
}

valid_domain() {
    local d="$1"
    [ ${#d} -le 253 ] || return 1
    [[ "$d" =~ ^([a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z]{2,63}$ ]]
}

valid_email() {
    local correo="$1"
    [[ "$correo" =~ ^[^@[:space:]]+@[^@[:space:]]+\.[^@[:space:]]+$ ]] || return 1
    # Se escribe en .env: una comilla simple romperia el valor entrecomillado.
    case "$correo" in *"'"*) return 1 ;; esac
    return 0
}

valid_smtp_host() {
    # Hostname o IPv4 simple: sin espacios ni caracteres de shell.
    [ ${#1} -le 253 ] || return 1
    [[ "$1" =~ ^[A-Za-z0-9]([A-Za-z0-9.-]*[A-Za-z0-9])?$ ]]
}

quarantine_item() {
    # Mueve un archivo o carpeta a una cuarentena segura; nunca lo borra.
    local src="$1" name="${2:-$(basename "$1")}"
    [ -e "$src" ] || return 0
    if [ "$DRY_RUN" = 1 ]; then
        printf '  %s[simulado]%s mover %s a %s\n' "$C_DIM" "$C_RESET" "$src" "$QUARANTINE_DIR/$name"
        return 0
    fi
    mkdir -p "$QUARANTINE_DIR" || die "No pude crear la carpeta de cuarentena: $QUARANTINE_DIR"
    chmod 700 "$QUARANTINE_DIR" 2>/dev/null || true
    mv "$src" "$QUARANTINE_DIR/$name" || die "No pude mover $src a la cuarentena."
    QUARANTINE_USED=1
}

# =============================================================================
#  Etapa 0 - Comprobaciones previas
# =============================================================================
stage_preflight() {
    banner "0. Comprobaciones previas"

    if [ "$DRY_RUN" != 1 ]; then
        [ "$(id -u)" -eq 0 ] || die "Este script necesita permisos de administrador. Ejecutalo asi:  sudo bash script.sh"
    fi

    if [ -r /etc/os-release ]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        info "Sistema detectado: ${PRETTY_NAME:-desconocido}"
        case "${ID:-} ${ID_LIKE:-}" in
            *ubuntu*|*debian*) : ;;
            *)
                if [ "$DRY_RUN" = 1 ]; then
                    warn "Este script esta pensado para Ubuntu o Debian. En modo simulacion continuo."
                else
                    die "Este instalador funciona en Ubuntu 22.04/24.04 o Debian. No lo ejecutes en otro sistema."
                fi
                ;;
        esac
    else
        if [ "$DRY_RUN" = 1 ]; then
            warn "No pude leer /etc/os-release. Continuo en modo simulacion."
        else
            die "No pude identificar el sistema operativo. Este instalador es para Ubuntu o Debian."
        fi
    fi

    [ -f "$COMPOSE_FILE" ] || die "No encuentro backend/docker-compose.yml en: $PROJECT_DIR"
    [ -f "$PROJECT_DIR/frontend-cliente/pages/login.html" ] || die "Falta frontend-cliente/pages/login.html"
    [ -f "$PROJECT_DIR/frontend-fotografo/pages/login.html" ] || die "Falta frontend-fotografo/pages/login.html"
    [ -f "$PROJECT_DIR/frontend-cliente/services/config.js" ] || die "Falta frontend-cliente/services/config.js"
    [ -f "$PROJECT_DIR/frontend-fotografo/services/config.js" ] || die "Falta frontend-fotografo/services/config.js"
    [ -f "$PROJECT_DIR/lading-page/paginaprincipal.html" ] || die "Falta lading-page/paginaprincipal.html (respetá el nombre con una sola 'd')"
    [ -f "$BACKEND_DIR/database/schema.sql" ] || die "Falta backend/database/schema.sql"
    [ -d "$BACKEND_DIR/backups" ] || die "Falta la carpeta backend/backups"
    ok "Estructura del proyecto verificada."
    info "Carpeta del proyecto: $PROJECT_DIR"

    case "$PROJECT_DIR" in
        *"|"*|*"&"*|*"#"*|*";"*|*"{"*|*"}"*)
            die "La ruta del proyecto contiene un caracter no admitido (| & # ; { }). Movelo a /opt/cipher-forge/Gestion-fotografias." ;;
    esac

    if [ "$PROJECT_DIR" != "/opt/cipher-forge/Gestion-fotografias" ]; then
        warn "La carpeta recomendada es /opt/cipher-forge/Gestion-fotografias."
        warn "Si continuas aqui, Nginx servira el sitio desde $PROJECT_DIR (tambien funciona)."
    fi

    if [ "$DRY_RUN" != 1 ] && [ -r /proc/meminfo ]; then
        local mem_kb
        mem_kb="$(awk '/MemTotal/ {print $2}' /proc/meminfo 2>/dev/null || true)"
        if [ -n "$mem_kb" ] && [ "$mem_kb" -lt 1800000 ]; then
            warn "El servidor tiene menos de 2 GB de memoria. El proyecto recomienda 4 GB."
        fi
    fi
}

# =============================================================================
#  Etapa 1 - Preparar el sistema
# =============================================================================
stage_base() {
    banner "1. Preparar el sistema (actualizaciones, herramientas y hora)"

    export DEBIAN_FRONTEND=noninteractive
    export NEEDRESTART_MODE=a

    info "Actualizando la lista de paquetes..."
    run env DEBIAN_FRONTEND=noninteractive apt-get update -y

    info "Aplicando actualizaciones del sistema (puede tardar unos minutos)..."
    run env DEBIAN_FRONTEND=noninteractive apt-get upgrade -y \
        -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold

    info "Instalando herramientas basicas..."
    run env DEBIAN_FRONTEND=noninteractive apt-get install -y \
        ca-certificates curl gnupg unzip rsync nginx ufw nano openssl

    info "Configurando la zona horaria de Uruguay..."
    run timedatectl set-timezone America/Montevideo

    ok "Sistema preparado."
}

# =============================================================================
#  Etapa 2 - Docker
# =============================================================================
stage_docker() {
    banner "2. Instalar Docker (el programa que ejecuta la aplicacion)"

    if [ "$DRY_RUN" = 1 ]; then
        info "[simulado] comprobaria e instalaria Docker y Docker Compose si faltan."
        info "[simulado] habilitaria el servicio y daria permiso al usuario de la sesion."
        return 0
    fi

    if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
        ok "Docker y Docker Compose ya estan instalados. Se omite la instalacion."
    else
        info "Instalando Docker desde el repositorio oficial (puede tardar unos minutos)..."
        local os_id="${ID:-ubuntu}" repo="ubuntu" codename="" arch=""
        [ "$os_id" = "debian" ] && repo="debian"
        codename="${UBUNTU_CODENAME:-${VERSION_CODENAME:-}}"
        arch="$(dpkg --print-architecture)"
        [ -n "$codename" ] || die "No pude detectar la version de Ubuntu/Debian para instalar Docker."

        install -m 0755 -d /etc/apt/keyrings
        curl -fsSL "https://download.docker.com/linux/$repo/gpg" -o /etc/apt/keyrings/docker.asc \
            || die "No pude descargar la clave de Docker. Revisa la conexion a Internet."
        chmod a+r /etc/apt/keyrings/docker.asc
        printf 'deb [arch=%s signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/%s %s stable\n' \
            "$arch" "$repo" "$codename" > /etc/apt/sources.list.d/docker.list
        apt-get update -y || die "No pude actualizar la lista de paquetes despues de agregar Docker."
        apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin \
            || die "No se pudo instalar Docker. Revisa el mensaje anterior y el manual tecnico (Paso 12)."
    fi

    systemctl enable --now docker || die "No pude iniciar el servicio de Docker."
    docker info >/dev/null 2>&1 || die "El servicio de Docker no responde. Proba: sudo systemctl status docker"

    local login_user="${SUDO_USER:-${USER:-root}}"
    if [ "$login_user" != "root" ]; then
        usermod -aG docker "$login_user" || warn "No pude agregar '$login_user' al grupo docker. No es grave: el script corre como root."
    fi
    ok "Docker listo."
    if [ "$login_user" != "root" ]; then
        info "El usuario '$login_user' debera cerrar y volver a entrar por SSH para usar docker sin sudo."
    fi
    info "Este script, al correr como root, ya puede usar docker."
}

# =============================================================================
#  Etapa 3 - Limpieza de una instalacion nueva
# =============================================================================
stage_project() {
    banner "3. Limpieza de la instalacion nueva"

    if deployment_exists; then
        EXISTING_DEPLOYMENT=1
        warn "Ya existe un despliegue con base de datos en este servidor."
        warn "No se moveran respaldos, fotos ni claves a la cuarentena."
        ok "No hay nada que limpiar."
        return 0
    fi

    local encontrados=0 archivo
    for archivo in "$BACKEND_DIR"/backups/backup_cipher_forge_*.sql; do
        [ -e "$archivo" ] || continue
        encontrados=$((encontrados + 1))
    done

    if [ "$encontrados" -gt 0 ]; then
        warn "Se encontraron $encontrados respaldos de prueba incluidos en el ZIP."
        warn "Pueden contener datos de otros entornos y no deben quedar en una instalacion nueva."
        if confirm "Mover esos respaldos a una carpeta de cuarentena segura"; then
            for archivo in "$BACKEND_DIR"/backups/backup_cipher_forge_*.sql; do
                [ -e "$archivo" ] || continue
                quarantine_item "$archivo"
            done
            ok "Respaldos de prueba movidos a la cuarentena."
        else
            warn "Se conservaron. No los uses en produccion; pedi ayuda para revisarlos."
        fi
    fi

    if [ -d "$BACKEND_DIR/uploads_export" ]; then
        warn "La carpeta backend/uploads_export contiene fotos de prueba de una migracion."
        warn "Responde NO si vas a migrar fotos reales."
        if confirm "Mover backend/uploads_export a la cuarentena (solo instalacion nueva)"; then
            quarantine_item "$BACKEND_DIR/uploads_export" "uploads_export"
            ok "Carpeta uploads_export movida a la cuarentena."
        fi
    fi

    if [ -f "$BACKEND_DIR/uploads/.jwt_secret" ]; then
        if confirm "Mover la clave de desarrollo backend/uploads/.jwt_secret a la cuarentena"; then
            quarantine_item "$BACKEND_DIR/uploads/.jwt_secret" "jwt_secret_desarrollo"
            ok "Clave de desarrollo movida a la cuarentena."
        fi
    fi

    if [ "$QUARANTINE_USED" = 1 ]; then
        info "La cuarentena esta en: $QUARANTINE_DIR"
        info "No se borro nada. Revisala y eliminala cuando estes seguro."
    fi
    ok "Limpieza terminada."
}

# =============================================================================
#  Etapa 4 - Configurar el proyecto
# =============================================================================
stage_config() {
    banner "4. Configurar el proyecto"

    # -- Dominio --
    if [ -z "$DOMAIN" ] && [ "$DRY_RUN" = 1 ]; then
        DOMAIN="ejemplo.com"
    fi
    if [ -n "$DOMAIN" ]; then
        DOMAIN="$(normalize_domain "$DOMAIN")"
        valid_domain "$DOMAIN" || die "El dominio '$DOMAIN' no parece valido. Ejemplo correcto: cipherforge.com"
        info "Dominio: $DOMAIN"
    else
        while :; do
            ask DOMAIN "Escribi tu dominio (sin https:// y sin www), por ejemplo cipherforge.com: " \
                || die "No pude leer el dominio. Volve a ejecutar el script en una terminal interactiva."
            DOMAIN="$(normalize_domain "$DOMAIN")"
            valid_domain "$DOMAIN" && break
            warn "El dominio '$DOMAIN' no parece valido. Ejemplo correcto: cipherforge.com"
        done
    fi

    # -- Correo para avisos del certificado --
    if [ -z "$EMAIL" ] && [ "$DRY_RUN" = 1 ]; then
        EMAIL="ejemplo@ejemplo.com"
    fi
    if [ -z "$EMAIL" ]; then
        while :; do
            ask EMAIL "Escribi tu correo electronico (avisos del certificado y pruebas): " \
                || die "No pude leer el correo. Volve a ejecutar el script en una terminal interactiva."
            valid_email "$EMAIL" && break
            warn "El correo '$EMAIL' no parece valido."
        done
    else
        valid_email "$EMAIL" || die "El correo '$EMAIL' no parece valido."
    fi

    # -- Archivo .env: comprobar antes de tocar cualquier otra cosa --
    if deployment_exists; then
        if [ ! -f "$ENV_FILE" ]; then
            die "Ya existe una base de datos en este servidor pero falta backend/.env. No genero claves nuevas para no perder el acceso a los datos. Restaura el .env original o pedi ayuda antes de continuar."
        fi
        if ! env_has_secrets; then
            die "Ya hay una base de datos creada y backend/.env esta incompleto. No lo sobrescribo para no perder el acceso. Restaura el .env original o pedi ayuda antes de continuar."
        fi
    fi

    # -- Frontends: usar el mismo dominio (API_URL vacio) --
    info "Revisando la configuracion de los frontends..."
    local fe cfg necesita_ajuste=0
    for fe in frontend-cliente frontend-fotografo; do
        cfg="$PROJECT_DIR/$fe/services/config.js"
        if [ ! -f "$cfg" ]; then
            warn "No encontre $cfg (revisa la estructura del proyecto)."
            continue
        fi
        if ! grep -q 'export const API_URL = "";' "$cfg"; then
            necesita_ajuste=1
        fi
    done

    if [ "$necesita_ajuste" = 1 ]; then
        if confirm "Ajustar los enlaces de los frontends para que usen el mismo dominio (API_URL vacio)"; then
            for fe in frontend-cliente frontend-fotografo; do
                cfg="$PROJECT_DIR/$fe/services/config.js"
                [ -f "$cfg" ] || continue
                run sed -i 's|export const API_URL = .*|export const API_URL = "";|' "$cfg" \
                    || die "No pude ajustar $cfg. Revisa los permisos del archivo."
            done
        else
            die "No puedo continuar sin ajustar los frontends: seguiran apuntando a 127.0.0.1 y el sitio no funcionara para los usuarios."
        fi
    fi
    if [ "$DRY_RUN" != 1 ]; then
        for fe in frontend-cliente frontend-fotografo; do
            cfg="$PROJECT_DIR/$fe/services/config.js"
            grep -q 'export const API_URL = "";' "$cfg" \
                || die "No pude dejar $cfg apuntando al mismo dominio. Revisalo antes de continuar."
        done
    fi
    ok "Frontends configurados (API_URL vacio = mismo dominio)."

    # -- Archivo .env --
    local crear_env=1
    if [ -f "$ENV_FILE" ]; then
        if env_has_secrets; then
            info "Ya existe backend/.env: se conserva y NO se regeneran las claves."
            crear_env=0

            local current_url current_host
            current_url="$(env_get FRONTEND_URL || true)"
            current_host="${current_url#*://}"
            current_host="${current_host%%/*}"
            current_host="${current_host#www.}"
            if [ -n "$current_url" ] && [ "$current_host" != "$DOMAIN" ]; then
                warn "El .env actual apunta a '$current_host' y ahora elegiste '$DOMAIN'."
                if confirm "Actualizar FRONTEND_URL a http://$DOMAIN (no cambia las claves)"; then
                    set_env_var "FRONTEND_URL" "http://$DOMAIN" "$ENV_FILE"
                fi
            fi
            ensure_env_defaults
        else
            warn "El archivo backend/.env existe pero no tiene todas las claves necesarias."
            if deployment_exists; then
                die "Ya hay una base de datos creada y el .env esta incompleto. No lo sobrescribo para no perder el acceso. Restaura el .env o pedi ayuda antes de continuar."
            fi
            if confirm "Mover el .env incompleto a cuarentena y crear uno nuevo"; then
                quarantine_item "$ENV_FILE" "env.incompleto"
                crear_env=1
            else
                die "No puedo continuar sin un .env completo. Revisa backend/.env o pedi ayuda."
            fi
        fi
    fi

    if [ "$crear_env" = 1 ]; then
        local clave_root clave_app clave_jwt
        clave_root="$(openssl rand -hex 24)"
        clave_app="$(openssl rand -hex 24)"
        clave_jwt="$(openssl rand -hex 32)"

        if [ "$DRY_RUN" = 1 ]; then
            info "[simulado] se crearia $ENV_FILE con claves nuevas."
        else
            (
                umask 077
                {
                    printf '%s\n' '# ========================================'
                    printf '%s\n' '# Cipher Forge - Configuracion de produccion'
                    printf '%s\n' "# Generado por script.sh el $(date +%Y-%m-%d_%H-%M-%S)"
                    printf '%s\n' '# No compartas este archivo.'
                    printf '%s\n\n' '# ========================================'
                    printf 'MYSQL_ROOT_PASSWORD=%s\n' "$clave_root"
                    printf '%s\n'   'MYSQL_DATABASE=cipher_forge'
                    printf '%s\n'   'MYSQL_USER=cipher_user'
                    printf 'MYSQL_PASSWORD=%s\n\n' "$clave_app"
                    printf 'JWT_SECRET=%s\n\n' "$clave_jwt"
                    printf 'FRONTEND_URL=http://%s\n' "$DOMAIN"
                    printf '%s\n'   'COOKIE_NAME=cipher_forge_token'
                    printf '%s\n'   'COOKIE_SECURE=false'
                    printf '%s\n'   'COOKIE_SAMESITE=Strict'
                    printf '\n'
                    printf '%s\n'   '# Correo de produccion: se completa en la etapa 8 (SMTP).'
                    printf '%s\n'   'SMTP_HOST=smtp.ejemplo.com'
                    printf '%s\n'   'SMTP_PORT=587'
                    printf '%s\n'   'SMTP_USER='
                    printf '%s\n'   'SMTP_PASS='
                    printf 'MAIL_FROM=no-reply@%s\n' "$DOMAIN"
                    printf '%s\n'   'MAIL_FROM_NAME=Cipher Forge'
                } > "$ENV_FILE"
            )
            chmod 600 "$ENV_FILE"
        fi
        ok "Archivo .env creado con claves nuevas."
        if [ "$DRY_RUN" != 1 ]; then
            printf '\n%s================================================================%s\n' "$C_YELLOW" "$C_RESET"
            printf '%s  GUARDA ESTAS CLAVES EN UN LUGAR SEGURO%s\n' "$C_YELLOW" "$C_RESET"
            printf '%s================================================================%s\n' "$C_YELLOW" "$C_RESET"
            printf '  MYSQL_ROOT_PASSWORD=%s\n' "$clave_root"
            printf '  MYSQL_PASSWORD=%s\n'      "$clave_app"
            printf '  JWT_SECRET=%s\n'          "$clave_jwt"
            printf '%s================================================================%s\n\n' "$C_YELLOW" "$C_RESET"
            warn "No compartas esta pantalla ni el archivo .env. Las claves tambien quedan guardadas en backend/.env."
        fi
    fi

    if [ "$DRY_RUN" != 1 ]; then
        env_has_secrets || die "backend/.env no tiene las claves necesarias (MYSQL_* y JWT_SECRET)."
    fi
    ensure_env_defaults

    # -- docker-compose.yml de produccion --
    if grep -q 'cipher-forge:prod' "$COMPOSE_FILE" 2>/dev/null; then
        ok "docker-compose.yml ya es la version de produccion. Se omite."
    else
        if grep -q 'mailpit' "$COMPOSE_FILE" 2>/dev/null; then
            warn "El docker-compose.yml actual es de desarrollo (usa Mailpit, que no sirve en produccion)."
        fi
        if confirm "Reemplazar docker-compose.yml por la version de produccion"; then
            run cp -a "$COMPOSE_FILE" "${COMPOSE_FILE}.dev.bak.$(date +%Y%m%d-%H%M%S)"
            write_file "$COMPOSE_FILE" <<'YAML'
services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    image: cipher-forge:prod
    container_name: cipher_forge_app
    restart: unless-stopped
    ports:
      # Solo accesible desde el propio servidor. Nginx es el que publica al mundo.
      - "127.0.0.1:8080:8080"
    volumes:
      - .:/var/www/html
      - uploads_data:/var/www/html/uploads
    environment:
      - TZ=America/Montevideo
      - DB_HOST=db
      - DB_NAME=${MYSQL_DATABASE:-cipher_forge}
      - DB_USER=${MYSQL_USER:-cipher_user}
      - DB_PASS=${MYSQL_PASSWORD:?define MYSQL_PASSWORD en .env}
      - DB_PORT=3306
      - FRONTEND_URL=${FRONTEND_URL:?define FRONTEND_URL en .env}
      - JWT_SECRET=${JWT_SECRET:?define JWT_SECRET en .env}
      - COOKIE_NAME=cipher_forge_token
      - COOKIE_SECURE=${COOKIE_SECURE:-true}
      - COOKIE_SAMESITE=Strict
      - SMTP_HOST=${SMTP_HOST:?define SMTP_HOST en .env}
      - SMTP_PORT=${SMTP_PORT:?define SMTP_PORT en .env}
      - SMTP_USER=${SMTP_USER:-}
      - SMTP_PASS=${SMTP_PASS:-}
      - MAIL_FROM=${MAIL_FROM:?define MAIL_FROM en .env}
      - MAIL_FROM_NAME=${MAIL_FROM_NAME:-Cipher Forge}
    depends_on:
      - db

  worker:
    build:
      context: .
      dockerfile: Dockerfile
    image: cipher-forge:prod
    container_name: cipher_forge_worker
    restart: unless-stopped
    command: php cron-backup.php --loop
    volumes:
      - .:/var/www/html
      - uploads_data:/var/www/html/uploads
    environment:
      - TZ=America/Montevideo
      - DB_HOST=db
      - DB_NAME=${MYSQL_DATABASE:-cipher_forge}
      - DB_USER=${MYSQL_USER:-cipher_user}
      - DB_PASS=${MYSQL_PASSWORD:?define MYSQL_PASSWORD en .env}
      - DB_PORT=3306
      - BACKUP_INTERVAL_SEG=86400
      - PURGE_INTERVAL_SEG=3600
    depends_on:
      - db

  db:
    image: mysql:8.0
    container_name: cipher_forge_db
    restart: unless-stopped
    environment:
      - TZ=America/Montevideo
      - MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:?define MYSQL_ROOT_PASSWORD en .env}
      - MYSQL_DATABASE=${MYSQL_DATABASE:-cipher_forge}
      - MYSQL_USER=${MYSQL_USER:-cipher_user}
      - MYSQL_PASSWORD=${MYSQL_PASSWORD:?define MYSQL_PASSWORD en .env}
    volumes:
      - db_data:/var/lib/mysql
      - ./database/schema.sql:/docker-entrypoint-initdb.d/schema.sql

volumes:
  db_data:
  uploads_data:
YAML
            ok "docker-compose.yml de produccion instalado."
        else
            die "Se conserva el docker-compose.yml actual, pero no es el de produccion. No puedo continuar sin el porque Mailpit no sirve en produccion."
        fi
    fi

    # -- Permisos --
    info "Ajustando permisos de archivos..."
    mkdir -p "$BACKEND_DIR/backups"
    run chmod -R a+rX "$PROJECT_DIR"
    run chmod 600 "$ENV_FILE"
    run chown -R 33:33 "$BACKEND_DIR/backups" || warn "No pude cambiar el dueno de backend/backups. Revisa los permisos (manual tecnico, Paso 23)."
    run chmod -R 775 "$BACKEND_DIR/backups"

    # -- Validar compose --
    if ! dc config --quiet; then
        die "La configuracion de Docker Compose no es valida. Revisa backend/.env (manual de usuario, seccion de problemas)."
    fi
    ok "Configuracion de Docker Compose valida."
}

# =============================================================================
#  Etapa 5 - Arrancar la base de datos, la aplicacion y el worker
# =============================================================================
# Envuelve una consulta SQL simple ejecutada dentro del contenedor de MySQL.
db_mysql() {
    dc exec -T -e CF_SQL="$1" db sh -c 'MYSQL_PWD="$MYSQL_ROOT_PASSWORD" mysql -uroot -N -e "$CF_SQL"'
}

stage_start() {
    banner "5. Arrancar la base de datos y la aplicacion"

    info "Levantando la base de datos MySQL..."
    if ! dc up -d db; then
        die "No pude levantar el contenedor de la base de datos. Revisa:  (cd $BACKEND_DIR && docker compose logs --tail=100 db)"
    fi

    if [ "$DRY_RUN" = 1 ]; then
        info "[simulado] se esperaria a MySQL, se construiria la imagen y se verificarian tablas y respaldo."
        return 0
    fi

    info "Esperando a que MySQL este listo..."
    local i ok_db=0
    for i in $(seq 1 90); do
        if db_mysql "SELECT 1" >/dev/null 2>&1; then
            ok_db=1
            break
        fi
        sleep 2
    done
    [ "$ok_db" = 1 ] || die "MySQL no respondio. Revisa con:  (cd $BACKEND_DIR && docker compose logs --tail=100 db)"
    ok "MySQL respondio."

    local db_intentos=0
    until db_mysql "SHOW DATABASES;" 2>/dev/null | grep -qx 'cipher_forge'; do
        db_intentos=$((db_intentos + 1))
        if [ "$db_intentos" -ge 30 ]; then
            die "La base 'cipher_forge' no aparece. Revisa los logs de db y no borres volumenes (manual de usuario, problemas frecuentes)."
        fi
        sleep 2
    done
    ok "La base de datos 'cipher_forge' existe."

    info "Construyendo y arrancando la aplicacion y el worker."
    info "La primera vez puede tardar entre 2 y 10 minutos (compila PHP con FFmpeg)."
    if ! dc up -d --build; then
        die "No se pudo construir o arrancar la aplicacion. Revisa:  (cd $BACKEND_DIR && docker compose logs --tail=100 app)"
    fi

    info "Esperando a que la API responda..."
    local api_ok=0 api_body=""
    for i in $(seq 1 90); do
        api_body="$(curl -fsS --max-time 3 http://127.0.0.1:8080/api/ping 2>/dev/null || true)"
        if printf '%s' "$api_body" | grep -q '"ok"[[:space:]]*:[[:space:]]*true'; then
            api_ok=1
            break
        fi
        sleep 2
    done
    if [ "$api_ok" != 1 ]; then
        die "La API no respondio correctamente. Revisa con:  (cd $BACKEND_DIR && docker compose logs --tail=100 app)"
    fi
    ok "La API responde correctamente."

    info "Comprobando que existan las tablas (deberian ser 11)..."
    local tablas=0 intento
    for intento in $(seq 1 30); do
        tablas="$( db_mysql "USE cipher_forge; SHOW TABLES;" 2>/dev/null | grep -c . )" || true
        [ "${tablas:-0}" -ge 11 ] && break
        sleep 2
    done
    if [ "${tablas:-0}" -ge 11 ]; then
        ok "La base tiene $tablas tablas."
    else
        die "Solo se encontraron ${tablas:-0} tablas. La migracion no se aplico bien. Revisa:  (cd $BACKEND_DIR && docker compose logs --tail=100 app)"
    fi

    info "Generando un respaldo de prueba..."
    if dc exec -T app php cron-backup.php; then
        BACKUP_OK=1
        ok "Respaldo de prueba generado en backend/backups/."
    else
        warn "No se pudo generar el respaldo. Revisa los permisos (manual de usuario, problemas frecuentes)."
    fi

    info "Estado de los contenedores:"
    dc ps || true
}

# =============================================================================
#  Etapa 6 - Nginx y cortafuegos
# =============================================================================
stage_nginx() {
    banner "6. Publicar el sitio con Nginx"

    local crear_sitio=1
    if [ -f "$NGINX_SITE" ]; then
        if grep -Fq "$DOMAIN" "$NGINX_SITE" && grep -Fq "$PROJECT_DIR" "$NGINX_SITE"; then
            ok "Ya existe una configuracion de Nginx para este dominio y esta carpeta. Se conserva."
            crear_sitio=0
        else
            warn "Ya existe el sitio de Nginx: $NGINX_SITE, pero no coincide con este dominio o esta carpeta."
            if confirm "Guardar una copia y reemplazarlo por la configuracion de este proyecto"; then
                run cp -a "$NGINX_SITE" "${NGINX_SITE}.bak.$(date +%Y%m%d-%H%M%S)"
                crear_sitio=1
            else
                warn "Se conserva el sitio actual. Revisa que el dominio y la carpeta sean correctos."
                crear_sitio=0
            fi
        fi
    fi

    if [ "$crear_sitio" = 1 ]; then
        info "Creando la configuracion de Nginx para $DOMAIN..."
        write_file "$NGINX_SITE" <<'NGINX'
server {
    listen 80;
    listen [::]:80;
    server_name __DOMAIN__ www.__DOMAIN__;

    root "__ROOT__";
    index index.html;

    # Permite subir videos de hasta 800 MB (con margen).
    client_max_body_size 900m;
    client_body_timeout 600s;

    # La raiz redirige a la landing.
    location = / {
        return 302 /lading-page/paginaprincipal.html;
    }

    # No servir codigo, respaldos, documentacion ni archivos ocultos.
    location ~ ^/(backend|docs)(/|$) { deny all; }
    location ~ /\. { deny all; }
    location ~* \.(env|sql|md|yml|yaml|ini|log|sh|properties)$ { deny all; }

    # Rutas de la API. Se excluye /sistema/* a proposito.
    location ~ ^/(auth|fotografos?|colecciones|multimedia|invitaciones|hashtags|favoritos|colaborativo|qr|api)(/|$) {
        proxy_pass http://127.0.0.1:8080;
        proxy_http_version 1.1;
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 600s;
        proxy_send_timeout 600s;
        proxy_request_buffering off;
    }

    # Endpoints administrativos: se deniegan por completo.
    location ^~ /sistema { deny all; }

    location / {
        try_files $uri $uri/ =404;
    }
}
NGINX
        run sed -i "s|__DOMAIN__|$DOMAIN|g; s|__ROOT__|$PROJECT_DIR|g" "$NGINX_SITE"
        ok "Sitio de Nginx creado."
    fi

    info "Activando el sitio y recargando Nginx..."
    run ln -sf /etc/nginx/sites-available/cipher-forge /etc/nginx/sites-enabled/cipher-forge
    if [ -e /etc/nginx/sites-enabled/default ]; then
        if confirm "Desactivar el sitio predeterminado de Nginx (necesario para publicar Cipher Forge)"; then
            run rm -f /etc/nginx/sites-enabled/default
        else
            warn "Se conserva el sitio predeterminado. Puede interceptar visitas si el dominio no coincide."
        fi
    fi

    if ! run nginx -t; then
        die "La configuracion de Nginx tiene un error. Revisa $NGINX_SITE (manual de usuario, problemas frecuentes)."
    fi
    run systemctl reload nginx || die "No pude recargar Nginx."
    ok "Nginx activo."

    info "Configurando el cortafuegos de Ubuntu (UFW)..."
    local ssh_ports=() puerto
    if command -v sshd >/dev/null 2>&1; then
        while IFS= read -r puerto; do
            [ -n "$puerto" ] && ssh_ports+=("$puerto")
        done < <(sshd -T 2>/dev/null | awk '$1=="port" {print $2}' | sort -u)
    fi
    if [ ${#ssh_ports[@]} -eq 0 ]; then
        ssh_ports=(22)
        warn "No pude detectar el puerto SSH; se permitira el puerto 22 por seguridad."
    fi
    if ! confirm "Activar el cortafuegos de Ubuntu (se permitiran SSH, HTTP y HTTPS)"; then
        UFW_SKIPPED=1
        warn "Cortafuegos omitido. El sitio puede quedar accesible, pero revisalo desde el panel del proveedor."
    else
        for puerto in "${ssh_ports[@]}"; do
            # Se usa el puerto explicito (no el perfil "OpenSSH") para no
            # depender de que ese perfil exista en el servidor.
            run ufw allow "$puerto/tcp" || warn "No pude permitir el puerto SSH $puerto."
        done
        run ufw allow "Nginx Full" || die "No pude permitir HTTP y HTTPS en UFW."
        run ufw --force enable || die "No pude activar UFW."
        run ufw status verbose || true
        ok "Cortafuegos configurado (SSH, HTTP y HTTPS permitidos)."
    fi

    if [ "$DRY_RUN" != 1 ]; then
        info "Comprobando el sitio desde el propio servidor..."
        local code api_body
        code="$(curl -s -o /dev/null -w '%{http_code}' -L http://127.0.0.1/ || true)"
        if [ "$code" = "200" ]; then
            ok "La landing responde (HTTP $code)."
        else
            warn "La landing respondio HTTP ${code:-sin respuesta}. Revisa: sudo nginx -t"
        fi
        for ruta in /frontend-cliente/pages/login.html /frontend-fotografo/pages/login.html; do
            code="$(curl -s -L -o /dev/null -w '%{http_code}' "http://127.0.0.1$ruta" || true)"
            if [ "$code" = "200" ]; then
                ok "Responde $ruta (HTTP 200)."
            else
                warn "$ruta respondio HTTP ${code:-sin respuesta}."
            fi
        done
        api_body="$(curl -fsS -L --max-time 5 http://127.0.0.1/api/ping 2>/dev/null || true)"
        if printf '%s' "$api_body" | grep -q '"ok"[[:space:]]*:[[:space:]]*true'; then
            ok "La API responde a traves de Nginx."
        else
            warn "La API no responde a traves de Nginx. Revisa los logs de app."
        fi
        for ruta in /backend/.env /sistema/backups; do
            code="$(curl -s -L -o /dev/null -w '%{http_code}' "http://127.0.0.1$ruta" || true)"
            if [ "$code" = "403" ]; then
                ok "Ruta privada protegida: $ruta (HTTP 403)."
            else
                warn "ATENCION: $ruta respondio HTTP ${code:-sin respuesta}; deberia responder 403."
            fi
        done
    fi
}

# =============================================================================
#  Etapa 7 - HTTPS
# =============================================================================
dns_resuelve() { getent hosts "$1" >/dev/null 2>&1; }
dns_contiene() { getent hosts "$1" 2>/dev/null | grep -qw -- "$2"; }

stage_https() {
    banner "7. HTTPS (candado de seguridad)"

    if [ "$SKIP_HTTPS" = 1 ]; then
        HTTPS_SKIPPED=1
        if env_get FRONTEND_URL 2>/dev/null | grep -q '^https://'; then
            PENDIENTE_HTTPS=0
            warn "HTTPS omitido por --sin-https (el .env ya usa https; no se comprobo el certificado)."
        else
            PENDIENTE_HTTPS=1
            warn "HTTPS omitido por --sin-https."
        fi
        return 0
    fi

    if [ "$DRY_RUN" = 1 ]; then
        info "[simulado] comprobaria el DNS de $DOMAIN y pediria el certificado con Certbot."
        info "[simulado] pondria FRONTEND_URL=https://$DOMAIN y COOKIE_SECURE=true en .env, y recrearia app/worker."
        return 0
    fi

    local server_ip=""
    server_ip="$(curl -fsS --max-time 10 https://api.ipify.org 2>/dev/null || true)"
    if [ -z "$server_ip" ]; then
        server_ip="$(hostname -I 2>/dev/null | awk '{print $1}')"
    fi
    info "IP publica del servidor: ${server_ip:-desconocida}"
    info "Comprobando si $DOMAIN ya apunta a este servidor..."

    local dns_listo=0
    if dns_resuelve "$DOMAIN"; then
        if [ -n "$server_ip" ] && dns_contiene "$DOMAIN" "$server_ip"; then
            ok "$DOMAIN ya apunta a $server_ip."
        else
            warn "$DOMAIN resuelve, pero no coincide con $server_ip (puede ser un proxy/CDN como Cloudflare)."
        fi
        dns_listo=1
    else
        warn "$DOMAIN todavia no resuelve. Los registros DNS tardan entre 5 minutos y 48 horas."
    fi

    if [ "$dns_listo" != 1 ]; then
        warn "Antes de pedir el certificado, crea en el panel DNS de tu dominio:"
        warn "   Registro A   nombre: @     valor: ${server_ip:-IP_DEL_SERVIDOR}"
        warn "   Registro A   nombre: www   valor: ${server_ip:-IP_DEL_SERVIDOR}"
        warn "Espera entre 5 minutos y 48 horas a que el DNS se actualice."
        if ! confirm "El DNS ya esta listo. Intentar obtener el certificado ahora"; then
            warn "Se omite HTTPS por ahora. Cuando el DNS funcione, volve a ejecutar el mismo comando."
            PENDIENTE_HTTPS=1
            return 0
        fi
    fi

    info "Instalando Certbot..."
    run env DEBIAN_FRONTEND=noninteractive apt-get install -y certbot python3-certbot-nginx \
        || die "No pude instalar Certbot."

    local nginx_backup=""
    if [ -f "$NGINX_SITE" ]; then
        nginx_backup="${NGINX_SITE}.antes-certbot.$(date +%Y%m%d-%H%M%S)"
        cp -a "$NGINX_SITE" "$nginx_backup" || warn "No pude guardar una copia de Nginx antes de Certbot."
    fi

    local args=(-d "$DOMAIN")
    if dns_resuelve "www.$DOMAIN"; then
        args+=(-d "www.$DOMAIN")
    else
        warn "www.$DOMAIN no resuelve: pedire el certificado solo para $DOMAIN."
    fi

    if certbot --nginx "${args[@]}" --non-interactive --agree-tos --no-eff-email -m "$EMAIL" --redirect; then
        ok "Certificado HTTPS instalado."
    else
        warn "No se pudo obtener el certificado. Revisa el DNS y volve a ejecutar el script."
        if ! nginx -t >/dev/null 2>&1 && [ -n "$nginx_backup" ] && [ -f "$nginx_backup" ]; then
            warn "Restaurando la configuracion anterior de Nginx..."
            cp -a "$nginx_backup" "$NGINX_SITE"
            nginx -t >/dev/null 2>&1 && systemctl reload nginx || true
        fi
        PENDIENTE_HTTPS=1
        return 0
    fi

    if ! nginx -t >/dev/null 2>&1; then
        if [ -n "$nginx_backup" ] && [ -f "$nginx_backup" ]; then
            warn "La configuracion de Nginx quedo invalida. Restaurando la copia anterior..."
            cp -a "$nginx_backup" "$NGINX_SITE"
            nginx -t >/dev/null 2>&1 && systemctl reload nginx || true
        fi
        die "Certbot modifico Nginx y la configuracion no es valida. Revisa el manual de usuario."
    fi

    info "Actualizando .env para HTTPS y recreando la aplicacion..."
    set_env_var "FRONTEND_URL" "https://$DOMAIN" "$ENV_FILE"
    set_env_var "COOKIE_SECURE" "true" "$ENV_FILE"
    if ! dc up -d --force-recreate app worker; then
        die "HTTPS se instalo, pero no pude reiniciar la aplicacion. Revisa los logs de app."
    fi

    if run certbot renew --dry-run; then
        ok "Renovacion automatica del certificado comprobada."
    else
        warn "La prueba de renovacion automatica fallo. Revisala mas tarde."
    fi
    PENDIENTE_HTTPS=0
    ok "HTTPS activo."
}

# =============================================================================
#  Etapa 8 - Correo de produccion (SMTP)
# =============================================================================
stage_mail() {
    banner "8. Correo de produccion"

    if [ "$SKIP_MAIL" = 1 ]; then
        MAIL_SKIPPED=1
        if env_real_smtp; then
            MAIL_CONFIGURED=1
            PENDIENTE_MAIL=0
            warn "Correo omitido por --sin-correo (ya habia datos SMTP; no se probo el envio)."
        else
            PENDIENTE_MAIL=1
            warn "Correo omitido por --sin-correo. La verificacion de cuentas no funcionara hasta configurarlo."
        fi
        return 0
    fi

    cat <<'TXT'
La aplicacion envia los correos de verificacion por SMTP (no por una API).
Necesitas los datos de un proveedor de correo real (Resend, Brevo, Mailgun, etc.).
Mailpit (el buzon de prueba de desarrollo) NO sirve en produccion.
TXT

    if [ "$DRY_RUN" = 1 ]; then
        info "[simulado] pediria los datos SMTP y los guardaria en .env."
        return 0
    fi

    local smtp_host smtp_port smtp_user smtp_pass mail_from
    local configurar=0 actual_host="" actual_port="" actual_user="" actual_pass="" actual_from=""

    if env_real_smtp; then
        ok "Ya hay datos SMTP configurados en backend/.env."
        if confirm "Queres cambiar los datos SMTP actuales"; then
            configurar=1
        fi
    else
        if confirm "Ya tenes los datos SMTP de tu proveedor y queres configurarlos ahora"; then
            configurar=1
        else
            warn "El correo quedo pendiente. La verificacion de cuentas no funcionara hasta configurarlo."
            PENDIENTE_MAIL=1
            return 0
        fi
    fi

    if [ "$configurar" = 1 ]; then
        actual_host="$(env_get SMTP_HOST || true)"
        [ "$actual_host" = "smtp.ejemplo.com" ] && actual_host=""
        actual_port="$(env_get SMTP_PORT || true)"
        [ -z "$actual_port" ] && actual_port="587"
        actual_user="$(env_get SMTP_USER || true)"
        actual_pass="$(env_get SMTP_PASS || true)"
        actual_from="$(env_get MAIL_FROM || true)"
        [ -z "$actual_from" ] && actual_from="no-reply@$DOMAIN"

        while :; do
            ask smtp_host "Host SMTP${actual_host:+ [$actual_host]} (ej. smtp.resend.com): " "$actual_host" \
                || die "No pude leer el host SMTP. Volve a ejecutar el script en una terminal interactiva."
            valid_smtp_host "$smtp_host" && break
            warn "El host SMTP '$smtp_host' no parece valido. Usa un nombre como smtp.tuproveedor.com."
        done

        while :; do
            ask smtp_port "Puerto SMTP [$actual_port] (normalmente 587): " "$actual_port" \
                || die "No pude leer el puerto SMTP. Volve a ejecutar el script en una terminal interactiva."
            [[ "$smtp_port" =~ ^[0-9]+$ ]] && [ "$smtp_port" -ge 1 ] && [ "$smtp_port" -le 65535 ] && break
            warn "El puerto '$smtp_port' no es valido. Usa un numero entre 1 y 65535."
        done

        ask smtp_user "Usuario SMTP${actual_user:+ [$actual_user]} (vacio si no usa usuario): " "$actual_user" \
            || die "No pude leer el usuario SMTP. Volve a ejecutar el script en una terminal interactiva."
        ask_secret smtp_pass "Contrasena o clave SMTP${actual_pass:+ (Enter para conservar la actual)} (no se muestra): " \
            || die "No pude leer la clave SMTP. Volve a ejecutar el script en una terminal interactiva."
        if [ -z "$smtp_pass" ] && [ -n "$actual_pass" ]; then
            smtp_pass="$actual_pass"
        fi
        if [ -n "$smtp_user" ] && [ -z "$smtp_pass" ]; then
            die "Indicaste un usuario SMTP pero no una clave. Pedile la clave a tu proveedor o deja el usuario vacio si no usa autenticacion."
        fi
        if [ -z "$smtp_user" ] && [ -n "$smtp_pass" ]; then
            warn "Hay una clave SMTP pero no un usuario. Es probable que el envio falle."
        fi
        case "$smtp_user" in
            *"'"*) die "El usuario SMTP contiene comillas simples ('). Pedile otro usuario a tu proveedor." ;;
        esac

        while :; do
            ask mail_from "Correo remitente [$actual_from]: " "$actual_from" \
                || die "No pude leer el correo remitente. Volve a ejecutar el script en una terminal interactiva."
            valid_email "$mail_from" && break
            warn "El correo remitente '$mail_from' no parece valido."
        done

        case "$smtp_pass" in
            *"'"*) die "La contrasena SMTP contiene comillas simples ('). Pedile otra clave a tu proveedor." ;;
        esac

        set_env_var "SMTP_HOST" "$smtp_host" "$ENV_FILE"
        set_env_var "SMTP_PORT" "$smtp_port" "$ENV_FILE"
        if [ -n "$smtp_user" ]; then
            set_env_var "SMTP_USER" "'$smtp_user'" "$ENV_FILE"
        else
            set_env_var "SMTP_USER" "" "$ENV_FILE"
        fi
        if [ -n "$smtp_pass" ]; then
            set_env_var "SMTP_PASS" "'$smtp_pass'" "$ENV_FILE"
        else
            set_env_var "SMTP_PASS" "" "$ENV_FILE"
        fi
        set_env_var "MAIL_FROM" "'$mail_from'" "$ENV_FILE"
        set_env_var "MAIL_FROM_NAME" "Cipher Forge" "$ENV_FILE"

        info "Recreando la aplicacion para aplicar el correo..."
        if ! dc up -d --force-recreate app worker; then
            die "No pude reiniciar la aplicacion con la configuracion de correo. Revisa los logs de app."
        fi
    fi

    MAIL_CONFIGURED=1
    smtp_host="$(env_get SMTP_HOST || true)"
    smtp_port="$(env_get SMTP_PORT || true)"

    if dc exec -T -e CF_SMTP_HOST="$smtp_host" -e CF_SMTP_PORT="$smtp_port" app php -r '
        $h = getenv("CF_SMTP_HOST");
        $p = (int) getenv("CF_SMTP_PORT");
        $c = @fsockopen($h, $p, $errno, $errstr, 5);
        if ($c) { fclose($c); exit(0); }
        fwrite(STDERR, $errstr . "\n");
        exit(1);
    ' >/dev/null 2>&1; then
        ok "El servidor SMTP es alcanzable desde la aplicacion ($smtp_host:$smtp_port)."
    else
        warn "No pude conectarme a $smtp_host:$smtp_port desde la aplicacion. Revisa el host, el puerto y el firewall del proveedor."
    fi

    if confirm "Enviar un correo de prueba a $EMAIL"; then
        write_file "$TEST_MAIL_FILE" <<'PHP'
<?php
spl_autoload_register(function (string $class): void {
    $prefix = 'App\\';
    if (strncmp($prefix, $class, strlen($prefix)) !== 0) {
        return;
    }
    $file = '/var/www/html/src/' . str_replace('\\', '/', substr($class, strlen($prefix))) . '.php';
    if (file_exists($file)) {
        require_once $file;
    }
});

$destino = getenv('CF_DESTINO') ?: 'sin-destino@ejemplo.com';
$ok = App\helpers\Mailer::enviar(
    $destino,
    'Prueba de correo de Cipher Forge',
    'Correo de prueba enviado desde el servidor.',
    '<p>Correo de prueba enviado desde el servidor.</p>'
);
echo $ok ? "ENVIADO\n" : "ERROR\n";
$error = App\helpers\Mailer::lastError();
if ($error !== null) {
    echo $error . "\n";
}
PHP
        local salida=""
        if salida="$(dc exec -T -e CF_DESTINO="$EMAIL" app php "/var/www/html/$(basename "$TEST_MAIL_FILE")" 2>&1)"; then
            printf '%s\n' "$salida"
            if printf '%s' "$salida" | grep -q 'ENVIADO'; then
                MAIL_READY=1
                ok "Correo de prueba enviado. Revisa tu bandeja de entrada y la carpeta de spam."
            else
                warn "El envio de prueba fallo. El mensaje de arriba explica el motivo."
                if printf '%s' "$salida" | grep -qiE 'STARTTLS|TLS|cifrado|530'; then
                    warn "El proveedor probablemente exige cifrado TLS/STARTTLS."
                    warn "El codigo actual del proyecto no implementa ese cifrado: hace falta que el equipo tecnico aplique el cambio del Paso 47 del manual tecnico."
                fi
            fi
        else
            printf '%s\n' "$salida"
            warn "No pude ejecutar la prueba de correo dentro del contenedor."
        fi
        rm -f "$TEST_MAIL_FILE" 2>/dev/null || true
    else
        warn "No se envio el correo de prueba. La configuracion queda sin verificar."
    fi

    if [ "$MAIL_READY" = 1 ]; then
        PENDIENTE_MAIL=0
    else
        PENDIENTE_MAIL=1
        warn "El correo quedo PENDIENTE de verificacion. La verificacion de cuentas puede no funcionar."
        warn "Si tu proveedor exige TLS, pedi al equipo tecnico que aplique el Paso 47 del manual tecnico."
    fi
}

# =============================================================================
#  Verificacion (solo lectura)
# =============================================================================
verify_all() {
    banner "Verificacion del sistema (solo lectura)"
    local errores=0 advertencias=0

    v_ok()  { ok "$*"; }
    v_err() { err "$*"; errores=$((errores + 1)); }
    v_warn(){ warn "$*"; advertencias=$((advertencias + 1)); }

    info "Carpeta del proyecto: $PROJECT_DIR"

    if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
        v_ok "Docker y Docker Compose estan instalados."
    else
        v_err "Docker o Docker Compose no estan disponibles. Ejecuta el instalador con: sudo bash script.sh"
    fi

    if command -v docker >/dev/null 2>&1; then
        local ps_out=""
        ps_out="$(cd "$BACKEND_DIR" && docker compose ps --format '{{.Service}} {{.State}}' 2>/dev/null || true)"
        if [ -n "$ps_out" ]; then
            local servicio
            for servicio in app worker db; do
                if printf '%s\n' "$ps_out" | grep -qiE "^${servicio}[[:space:]]+(running|up)"; then
                    v_ok "Contenedor $servicio: en ejecucion."
                else
                    v_err "Contenedor $servicio: no esta en ejecucion."
                fi
            done
        else
            v_err "No pude consultar los contenedores. Revisa: cd $BACKEND_DIR && sudo docker compose ps"
        fi
    fi

    local api_body=""
    api_body="$(curl -fsS --max-time 5 http://127.0.0.1:8080/api/ping 2>/dev/null || true)"
    if printf '%s' "$api_body" | grep -q '"ok"[[:space:]]*:[[:space:]]*true'; then
        v_ok "La API responde directamente en el servidor."
    else
        v_err "La API no responde en http://127.0.0.1:8080/api/ping."
    fi

    if command -v nginx >/dev/null 2>&1; then
        if nginx -t >/dev/null 2>&1; then
            v_ok "La configuracion de Nginx es valida."
        else
            v_err "La configuracion de Nginx tiene errores. Revisa: sudo nginx -t"
        fi
        if systemctl is-active --quiet nginx; then
            v_ok "Nginx esta en ejecucion."
        else
            v_err "Nginx no esta en ejecucion."
        fi
    else
        v_err "Nginx no esta instalado."
    fi

    local code=""
    code="$(curl -s -o /dev/null -w '%{http_code}' -L http://127.0.0.1/ 2>/dev/null || true)"
    if [ "$code" = "200" ]; then
        v_ok "La landing responde por HTTP (200)."
    else
        v_err "La landing no responde por HTTP (codigo ${code:-sin respuesta})."
    fi

    local ruta
    for ruta in /frontend-cliente/pages/login.html /frontend-fotografo/pages/login.html; do
        code="$(curl -s -L -o /dev/null -w '%{http_code}' "http://127.0.0.1$ruta" 2>/dev/null || true)"
        if [ "$code" = "200" ]; then
            v_ok "Responde $ruta (200)."
        else
            v_err "No responde $ruta (codigo ${code:-sin respuesta})."
        fi
    done

    local api_nginx=""
    api_nginx="$(curl -fsS -L --max-time 5 http://127.0.0.1/api/ping 2>/dev/null || true)"
    if printf '%s' "$api_nginx" | grep -q '"ok"[[:space:]]*:[[:space:]]*true'; then
        v_ok "La API responde a traves de Nginx."
    else
        v_err "La API no responde a traves de Nginx."
    fi

    for ruta in /backend/.env /sistema/backups; do
        code="$(curl -s -L -o /dev/null -w '%{http_code}' "http://127.0.0.1$ruta" 2>/dev/null || true)"
        if [ "$code" = "403" ]; then
            v_ok "Ruta privada protegida: $ruta (403)."
        else
            v_err "Ruta privada expuesta: $ruta respondio ${code:-sin respuesta} (deberia ser 403)."
        fi
    done

    if command -v docker >/dev/null 2>&1; then
        local tablas="0"
        tablas="$(db_mysql "USE cipher_forge; SHOW TABLES;" 2>/dev/null | grep -c . || true)"
        if [ "${tablas:-0}" -ge 11 ]; then
            v_ok "La base de datos tiene $tablas tablas."
        else
            v_err "La base de datos tiene ${tablas:-0} tablas (se esperaban al menos 11)."
        fi
    fi

    local ultimo_backup=""
    ultimo_backup="$(ls -1t "$BACKEND_DIR"/backups/backup_cipher_forge_*.sql 2>/dev/null | head -n1 || true)"
    if [ -n "$ultimo_backup" ]; then
        v_ok "Hay respaldos. El mas reciente es: $(basename "$ultimo_backup")"
    else
        v_warn "No encontre respaldos de la base en backend/backups/."
    fi

    local frontend_url="" host=""
    frontend_url="$(env_get FRONTEND_URL || true)"
    host="${frontend_url#*://}"
    host="${host%%/*}"
    if [ -n "$frontend_url" ] && [[ "$frontend_url" == https://* ]]; then
        code="$(curl -sS -o /dev/null -w '%{http_code}' --max-time 20 "$frontend_url/" 2>/dev/null || true)"
        if [ "$code" = "200" ]; then
            v_ok "El sitio responde por HTTPS (200)."
        else
            v_err "El sitio no responde por HTTPS (codigo ${code:-sin respuesta})."
        fi
        code="$(curl -s -o /dev/null -w '%{http_code}' --max-time 15 "http://$host/" 2>/dev/null || true)"
        case "$code" in
            301|302|308) v_ok "HTTP redirige a HTTPS (codigo $code)." ;;
            *) v_warn "HTTP no redirige a HTTPS (codigo ${code:-sin respuesta})." ;;
        esac
    elif [ -n "$host" ]; then
        v_warn "El sitio esta configurado por HTTP, sin HTTPS. Revisa el DNS y volve a ejecutar el instalador."
    else
        v_warn "No pude leer FRONTEND_URL desde backend/.env."
    fi

    if [ -n "$host" ]; then
        local public_ip="" dns_ips=""
        public_ip="$(curl -fsS --max-time 10 https://api.ipify.org 2>/dev/null || true)"
        dns_ips="$(getent ahostsv4 "$host" 2>/dev/null | awk '{print $1}' | sort -u || true)"
        if [ -n "$public_ip" ] && printf '%s\n' "$dns_ips" | grep -qx "$public_ip"; then
            v_ok "El DNS de $host apunta a la IP de este servidor ($public_ip)."
        elif [ -n "$dns_ips" ]; then
            v_warn "El DNS de $host responde, pero no coincide con la IP detectada ($public_ip). Puede ser un proxy/CDN."
        else
            v_warn "El DNS de $host todavia no responde."
        fi
    fi

    local libre_kb=""
    libre_kb="$(df -Pk / 2>/dev/null | awk 'NR==2 {print $4}' || true)"
    if [ -n "$libre_kb" ] && [ "$libre_kb" -lt 5000000 ]; then
        v_warn "Queda poco espacio libre en el disco. Revisa con: df -h"
    else
        v_ok "Espacio en disco suficiente."
    fi

    if env_real_smtp; then
        v_ok "El correo SMTP esta configurado (la prueba de envio no se ejecuta en esta revision)."
    else
        v_warn "El correo SMTP no esta configurado. La verificacion de cuentas no funcionara."
    fi

    printf '\n'
    if [ "$errores" -gt 0 ]; then
        err "Encontre $errores problema(s) importante(s) y $advertencias aviso(s)."
        err "Revisa la seccion de solucion de problemas de $PROJECT_DIR/docs/manual_de_usuario.md."
        return 1
    fi
    ok "No encontre problemas importantes. Avisos: $advertencias."
    info "Completa las pruebas del manual de usuario (registro, correo, subida y QR)."
    return 0
}

# =============================================================================
#  Resumen final
# =============================================================================
stage_summary() {
    banner "9. Resumen"
    printf '  Dominio:              %s\n' "$DOMAIN"
    printf '  Carpeta del proyecto: %s\n' "$PROJECT_DIR"
    printf '  Configuracion:        %s\n' "$ENV_FILE"
    printf '  Respaldos:            %s/backups\n' "$BACKEND_DIR"
    if [ "$QUARANTINE_USED" = 1 ]; then
        printf '  Cuarentena:           %s\n' "$QUARANTINE_DIR"
    fi

    printf '\n  Direcciones para probar:\n'
    if [ "$PENDIENTE_HTTPS" = 1 ]; then
        printf '    http://%s/\n' "$DOMAIN"
        printf '    http://%s/frontend-fotografo/pages/login.html\n' "$DOMAIN"
        printf '    http://%s/frontend-cliente/pages/login.html\n' "$DOMAIN"
    else
        printf '    https://%s/\n' "$DOMAIN"
        printf '    https://%s/frontend-fotografo/pages/login.html\n' "$DOMAIN"
        printf '    https://%s/frontend-cliente/pages/login.html\n' "$DOMAIN"
    fi

    printf '\n  Estado:\n'
    if [ "$DRY_RUN" = 1 ]; then
        warn "MODO SIMULACION: no se inicio ni modifico nada. El estado siguiente es una descripcion."
        if [ "$HTTPS_SKIPPED" = 1 ]; then
            info "HTTPS: se omitiria por --sin-https."
        else
            info "HTTPS: se intentaria si el DNS esta listo."
        fi
        if [ "$MAIL_SKIPPED" = 1 ]; then
            info "Correo: se omitiria por --sin-correo."
        else
            info "Correo: se configuraria si proporcionas los datos SMTP."
        fi
        info "Respaldo: se generaria despues de arrancar la aplicacion."
    else
        ok "Sistema, Docker, base de datos, aplicacion y Nginx iniciados."
        if [ "$EXISTING_DEPLOYMENT" = 1 ]; then
            info "Se detecto un despliegue existente: se conservaron los datos y las claves."
        fi
        if [ "$HTTPS_SKIPPED" = 1 ]; then
            warn "HTTPS: omitido en esta ejecucion (no se comprobo el certificado)."
        elif [ "$PENDIENTE_HTTPS" = 1 ]; then
            warn "HTTPS: PENDIENTE. Crea los registros DNS y volve a ejecutar el script."
        else
            ok "HTTPS: activo con certificado."
        fi
        if [ "$MAIL_SKIPPED" = 1 ]; then
            if [ "$MAIL_CONFIGURED" = 1 ]; then
                warn "Correo: omitido en esta ejecucion (ya estaba configurado; no se probo)."
            else
                warn "Correo: omitido en esta ejecucion. La verificacion de cuentas no funcionara hasta configurarlo."
            fi
        elif [ "$MAIL_READY" = 1 ]; then
            ok "Correo: configurado y probado."
        elif [ "$MAIL_CONFIGURED" = 1 ]; then
            warn "Correo: configurado, pero el envio de prueba no se verifico."
        else
            warn "Correo: PENDIENTE. La verificacion de cuentas no funcionara hasta configurarlo."
        fi
        if [ "$BACKUP_OK" = 1 ]; then
            ok "Respaldo de prueba: generado."
        else
            warn "Respaldo de prueba: no se pudo confirmar."
        fi
        if [ "$UFW_SKIPPED" = 1 ]; then
            warn "Cortafuegos de Ubuntu: omitido en esta ejecucion. Revisalo antes de abrir el sitio."
        fi

        printf '\n'
        if [ "$PENDIENTE_HTTPS" = 0 ] && [ "$PENDIENTE_MAIL" = 0 ] \
            && [ "$HTTPS_SKIPPED" = 0 ] && [ "$MAIL_SKIPPED" = 0 ] \
            && [ "$UFW_SKIPPED" = 0 ]; then
            ok "Instalacion completa. Segui la seccion 'Comprobar que todo funciona' del manual de usuario."
        else
            warn "La instalacion base termino, pero quedan tareas o comprobaciones pendientes (ver arriba)."
        fi
    fi

    printf '\n'
    info "Para comprobar el sistema:  sudo bash \"$PROJECT_DIR/script.sh\" --verificar"
    info "Manual de usuario: $PROJECT_DIR/docs/manual_de_usuario.md"
    info "Manual tecnico: $PROJECT_DIR/docs/manual-de-usuario-tecnico.md"
    warn "Nunca ejecutes 'docker compose down -v': borraria la base y las fotos."
}

# =============================================================================
#  Ayuda y argumentos
# =============================================================================
print_banner() {
    printf '%s\n' "  ____ _             __        _____                    "
    printf '%s\n' " / ___(_)_ __   ___ / _|      |  ___|__  _ __ __ _  ___ "
    printf '%s\n' "| |   | | '_ \\ / _ \\ |_ _____| |_ / _ \\| '__/ _\` |/ _ \\"
    printf '%s\n' "| |___| | |_) |  __/  _|_____|  _| (_) | | | (_| |  __/"
    printf '%s\n' " \\____|_| .__/ \\___|_|       |_|  \\___/|_|  \\__, |\\___|"
    printf '%s\n' "        |_|                                 |___/       "
    printf '%s\n' "  Instalador para servidor Ubuntu (VPS)"
    printf '%s\n' "  Manual de usuario: docs/manual_de_usuario.md"
    printf '%s\n\n' "  Manual tecnico: docs/manual-de-usuario-tecnico.md"
}

print_help() {
    cat <<'HELP'
Uso:
    sudo bash script.sh [opciones]

Opciones:
    --dominio DOMINIO   Tu dominio (ej. cipherforge.com)
    --correo EMAIL      Tu correo (avisos del certificado y pruebas)
    --sin-https         No instalar HTTPS en esta ejecucion
    --sin-correo        No configurar el correo (SMTP) en esta ejecucion
    --asumir-si         Responder "si" a las confirmaciones (no borra datos)
    --simular           Mostrar lo que haria sin cambiar nada (prueba segura)
    --verificar         Revisar el estado actual sin modificar nada
    --ayuda, -h         Mostrar esta ayuda

Ejemplos:
    sudo bash script.sh --dominio cipherforge.com --correo admin@cipherforge.com
    sudo bash script.sh --simular --dominio cipherforge.com --correo admin@cipherforge.com
    sudo bash script.sh --verificar

Que automatiza:
    sistema, Docker, cuarentena de archivos de prueba, .env, docker-compose de
    produccion, permisos, arranque de contenedores, Nginx, UFW, HTTPS y correo.

Que NO automatiza (lo haces vos en las paginas web de cada proveedor):
    contratar el servidor, el dominio y el correo; abrir el firewall del
    proveedor; crear los registros DNS; verificar el dominio en el proveedor
    de correo.

Seguridad:
    - No guarda contrasenas ni claves dentro de este archivo.
    - No borra datos: mueve archivos de prueba a /var/backups/cipher-forge/.
    - Nunca usa "docker compose down -v".
    - Si ya existe una base de datos, conserva el .env y no regenera claves.
HELP
}

parse_args() {
    while [ $# -gt 0 ]; do
        case "$1" in
            --dominio)
                [ $# -ge 2 ] || die "--dominio necesita un valor. Ejemplo: --dominio cipherforge.com"
                DOMAIN="$2"; shift 2 ;;
            --correo)
                [ $# -ge 2 ] || die "--correo necesita un valor. Ejemplo: --correo tu@correo.com"
                EMAIL="$2"; shift 2 ;;
            --sin-https)  SKIP_HTTPS=1; shift ;;
            --sin-correo) SKIP_MAIL=1; shift ;;
            --asumir-si|--yes|-y) ASSUME_YES=1; shift ;;
            --simular|--dry-run)  DRY_RUN=1; shift ;;
            --verificar|--estado) VERIFY_ONLY=1; shift ;;
            -h|--ayuda|--help)    SHOW_HELP=1; shift ;;
            *) die "Opcion desconocida: $1. Usa --ayuda para ver las opciones." ;;
        esac
    done
    if [ "$VERIFY_ONLY" = 1 ] && [ "$DRY_RUN" = 1 ]; then
        die "No combines --verificar con --simular. Usa solo una de las dos opciones."
    fi
}

# =============================================================================
#  Programa principal
# =============================================================================
main() {
    parse_args "$@"
    if [ "$SHOW_HELP" = 1 ]; then
        print_help
        exit 0
    fi
    print_banner
    stage_preflight

    if [ "$VERIFY_ONLY" = 1 ]; then
        if verify_all; then
            exit 0
        else
            exit 1
        fi
    fi

    if [ "$DRY_RUN" = 1 ]; then
        warn "MODO SIMULACION: no se cambiara nada en el sistema."
    fi

    stage_base
    stage_docker
    stage_project
    stage_config
    stage_start
    stage_nginx
    stage_https
    stage_mail
    stage_summary
}

main "$@"

