
const API_URL = "http://localhost:8080/API%20REST%20PHP/public/api";


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


let formRegistro = document.getElementById("formRegistro");
if (formRegistro) {

    formRegistro.onsubmit = async function (evento) {
        evento.preventDefault();

        let nombre = document.getElementById("nombre").value;
        let correo = document.getElementById("correo").value;
        
          let contrasena = document.getElementById("contraseña").value;
        let rol = document.getElementById("rol").value;

        try {
          

            let respuesta = await fetch(API_URL + "/auth/register", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json"
                },
                body: JSON.stringify({
                    name: nombre,
                    email: correo,
                    password: contrasena,
                    role: rol
                })
            });

            let datos = await respuesta.json();

            if (datos.success) {
              
                alert("Cuenta creada correctamente. Ahora iniciá sesión.");
                window.location.href = "login.html";
            } else {
                alert("No se pudo registrar: " + datos.error);
            }

        } catch (error) {
            alert("No se pudo conectar con el servidor. ¿Está corriendo el backend?");
        }

        return false;
    };
}



let formLogin = document.getElementById("formLogin");
if (formLogin) {


    let tokenGuardado = localStorage.getItem("token");
    let usuarioGuardado = localStorage.getItem("usuario");

    if (tokenGuardado && usuarioGuardado) {
        let usuario = JSON.parse(usuarioGuardado);
        irSegunRol(usuario.role);
    }

    formLogin.onsubmit = async function (evento) {
        evento.preventDefault();

        let correo = document.getElementById("correo").value;
        let contrasena = document.getElementById("contraseña").value;

        try {
            let respuesta = await fetch(API_URL + "/auth/login", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json"
                },
                body: JSON.stringify({
                    email: correo,
                    password: contrasena
                })
            });

            let datos = await respuesta.json();

            if (datos.success) {
               

                guardarSesion(datos.data.token, datos.data.user);
                irSegunRol(datos.data.user.role);
            } else {
                alert("No se pudo iniciar sesión: " + datos.error);
            }

        } catch (error) {
            alert("No se pudo conecta esto al backend.");
        }

        return false;
    };
}