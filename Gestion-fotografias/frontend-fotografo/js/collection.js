const formulario = document.getElementById("formColeccion");
 
if (formulario) {
	formulario.addEventListener("submit", function (evento) {
		evento.preventDefault();
 
		const nombre = document.getElementById("nombreColeccion").value.trim();
		const colecciones = JSON.parse(localStorage.getItem("colecciones") || "[]");
		const nuevaColeccion = {
			id: Date.now() + Math.random(),
			nombre: nombre,
			tags: [],
			favorita: false,
			publicada: false,
			imagenes: []
		};

		colecciones.push(nuevaColeccion);
		localStorage.setItem("colecciones", JSON.stringify(colecciones));
		window.location.href = "SubirImagenes.html?coleccionId=" + nuevaColeccion.id;
	});
}
 