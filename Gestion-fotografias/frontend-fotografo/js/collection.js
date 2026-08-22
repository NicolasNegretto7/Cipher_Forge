const formulario = document.getElementById("formColeccion");
 
if (formulario) {
	formulario.addEventListener("submit", function (evento) {
		evento.preventDefault();
 
		const nombre = document.getElementById("nombreColeccion").value.trim();
		const parametros = new URLSearchParams();
		parametros.set("nombre", nombre);
		window.location.href = "SubirImagenes.html?" + parametros.toString();
	});
}
 