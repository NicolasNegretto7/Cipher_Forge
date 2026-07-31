let formRegistro = document.getElementById("formRegistro");
if (formRegistro) {
    formRegistro.onsubmit = function(evento) {
        evento.preventDefault();

        let nombre = document.getElementById("nombre").value;
        let correo = document.getElementById("correo").value;
        
            
        let contrasena = document.getElementById("contraseña").value;
        
             let rol = document.getElementById("rol").value;


        if (rol === "fotografo") {
            window.location.href = "fotografo/panel.html";
        } else {
            window.location.href = "cliente/galeria.html";
        }

        return false;
    };
}


let formLogin = document.getElementById("formLogin");
if (formLogin) {
    formLogin.onsubmit = function(evento) {
        evento.preventDefault();

        let correo = document.getElementById("correo").value;
        let contrasena = document.getElementById("contraseña").value;
        let rol = document.getElementById("rol").value;

        
       
    

        if (rol === "fotografo") {
            window.location.href = "fotografo/panel.html";
        } else {
            window.location.href = "cliente/galeria.html";
        }

        return false;
    };
}