
const API_URL = "http://localhost:8080";

function guardarSesion(token, usuario) {
    localStorage.setItem("token", token);
    localStorage.setItem("usuario", JSON.stringify(usuario));
}

function irSegunRol(rol) {
    if (rol === "fotografo") {
        window.location.href = "panel.html";
    } else {
        window.location.href = "panelcliente.html";
    }
}

async function registrarUsuario(datos) {
    const respuesta = await fetch(API_URL + "/auth/register", {
        method: "POST",
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify({
            nombre_completo: datos.nombre,
            email: datos.correo,
            password: datos.password,
            rol: datos.rol,
            telefono: datos.telefono || ""
        })
    });

    const json = await respuesta.json();

    if (!respuesta.ok) {
        throw new Error(json.mensaje || json.error || "No se pudo registrar.");
    }

    return json;
}

async function iniciarSesion(datos) {
    const respuesta = await fetch(API_URL + "/auth/login", {
        method: "POST",
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify({
            email: datos.correo,
            password: datos.password
        })
    });

    const json = await respuesta.json();

    if (!respuesta.ok) {
        throw new Error(json.mensaje || json.error || "Credenciales incorrectas.");
    }

    return json.datos;
}

const formRegistro = document.getElementById("formRegistro");
if (formRegistro) {
    formRegistro.onsubmit = async function (evento) {
        evento.preventDefault();

        const nombre = document.getElementById("nombre").value;
        const correo = document.getElementById("correo").value;
        const contrasena = document.getElementById("contraseña").value;
        const telefono = document.getElementById("telefono")?.value || "";
        const rol = document.getElementById("rol").value;

        try {
            await registrarUsuario({
                nombre: nombre,
                correo: correo,
                password: contrasena,
                telefono: telefono,
                rol: rol
            });

            alert("Cuenta creada correctamente. Ahora iniciá sesión.");
            window.location.href = "login.html";
        } catch (error) {
            alert(error.message);
        }

        return false;
    };
}

const formLogin = document.getElementById("formLogin");
if (formLogin) {
    const tokenGuardado = localStorage.getItem("token");
    const usuarioGuardado = localStorage.getItem("usuario");

    if (tokenGuardado && usuarioGuardado) {
        const usuario = JSON.parse(usuarioGuardado);
        irSegunRol(usuario.rol || usuario.role);
    }

    formLogin.onsubmit = async function (evento) {
        evento.preventDefault();

        const correo = document.getElementById("correo").value;
        const contrasena = document.getElementById("contraseña").value;

        try {
            const usuario = await iniciarSesion({
                correo: correo,
                password: contrasena
            });

            guardarSesion("token-temporal", usuario);
            irSegunRol(usuario.rol || usuario.role);
        } catch (error) {
            alert(error.message);
        }

        return false;
    };
}