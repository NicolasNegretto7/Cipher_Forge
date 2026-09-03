const formulario = document.getElementById("formColeccion");

if (formulario) {
	formulario.addEventListener("submit", function (evento) {
		evento.preventDefault();

		const coleccion = {
				id: Date.now() + Math.random(),
				localId: null,
				nombre: document.getElementById("nombreColeccion").value.trim(),
				descripcion: document.getElementById("descripcionColeccion").value.trim(),
				tipo_visibilidad: "privada",
				tags: [],
				favorita: false,
				publicada: false,
				imagenes: []
			};
			coleccion.localId = coleccion.id;

		const colecciones = JSON.parse(localStorage.getItem("colecciones") || "[]");
			colecciones.push(coleccion);
			localStorage.setItem("colecciones", JSON.stringify(colecciones));
			window.location.href = "SubirImagenes.html?coleccionId=" + coleccion.id;
	});
}
 