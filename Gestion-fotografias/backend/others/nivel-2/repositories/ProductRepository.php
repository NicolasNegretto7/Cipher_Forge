<?php

/**
 * REPOSITORIO DE PRODUCTOS  (clase HIJA de Repository)
 * ------------------------------------------------------------------
 * Acá está el CRUD completo contra la tabla `productos`:
 *
 *   Create  -> create()
 *   Read    -> findAll(), findById() y findByName()
 *   Update  -> update()
 *   Delete  -> delete()
 *
 * Son las cuatro operaciones que tiene casi cualquier sistema:
 * altas, bajas, modificaciones y consultas.
 *
 * NOTA: dejamos create() y update() como dos métodos separados porque
 * cada uno es una consulta SQL distinta (INSERT y UPDATE). En Laravel
 * vas a ver un solo save() que decide adentro cuál de las dos
 * corresponde; es cómodo, pero esconde lo que está pasando y ahora
 * justamente queremos verlo.
 *
 * TODAS las consultas usan parámetros con nombre (:algo) en vez de
 * pegar el valor directo adentro del SQL. Eso es una CONSULTA
 * PREPARADA: evita la inyección SQL, porque el valor viaja separado
 * del texto de la consulta y el motor nunca lo interpreta como código.
 */
class ProductRepository extends Repository
{
    /**
     * READ: devuelve todos los productos.
     * Si le pasamos una categoría, filtra por esa categoría.
     *
     * @return Product[] un arreglo de objetos Product
     */
    public function findAll($category = null)
    {
        if ($category === null) {
            $sql   = 'SELECT * FROM productos';
            $query = $this->db->prepare($sql);
            $query->execute();
        } else {
            $sql   = 'SELECT * FROM productos WHERE categoria = :categoria';
            $query = $this->db->prepare($sql);
            $query->execute([':categoria' => $category]);
        }

        $products = [];

        foreach ($query->fetchAll() as $row) {
            $products[] = $this->buildProduct($row);
        }

        return $products;
    }

    /** READ: un solo producto. Devuelve null si no existe. */
    public function findById($id)
    {
        $sql = 'SELECT * FROM productos WHERE id = :id';

        $query = $this->db->prepare($sql);
        $query->execute([':id' => $id]);
        $row = $query->fetch();

        return $row === false ? null : $this->buildProduct($row);
    }

    /**
     * READ: busca por nombre exacto.
     * Lo usa el service para no dejar crear dos productos iguales.
     *
     * (No hace falta comparar en minúsculas a mano: la mayoría de las
     * columnas de texto en MySQL usan una collation *_ci ("case
     * insensitive"), así que "Mouse" y "mouse" ya cuentan como
     * iguales para el propio motor de la base.)
     */
    public function findByName($name)
    {
        $sql = 'SELECT * FROM productos WHERE nombre = :nombre';

        $query = $this->db->prepare($sql);
        $query->execute([':nombre' => trim($name)]);
        $row = $query->fetch();

        return $row === false ? null : $this->buildProduct($row);
    }

    /** CREATE: guarda un producto nuevo y le pone su id. */
    public function create(Product $product)
    {
        $sql = 'INSERT INTO productos (nombre, descripcion, precio, stock, categoria, activo)
                VALUES (:nombre, :descripcion, :precio, :stock, :categoria, 1)';

        $query = $this->db->prepare($sql);
        $query->execute([
            ':nombre'      => $product->getName(),
            ':descripcion' => $product->getDescription(),
            ':precio'      => $product->getPrice(),
            ':stock'       => $product->getStock(),
            ':categoria'   => $product->getCategory(),
        ]);

        // lastInsertId() devuelve el id que le puso la base
        // (el AUTO_INCREMENT de la columna `id`).
        $product->setId((int) $this->db->lastInsertId());

        return $product;
    }

    /** UPDATE: piso los datos del producto que tenga el mismo id. */
    public function update(Product $product)
    {
        $sql = 'UPDATE productos
                   SET nombre = :nombre,
                       descripcion = :descripcion,
                       precio = :precio,
                       stock = :stock,
                       categoria = :categoria
                 WHERE id = :id';

        $query = $this->db->prepare($sql);
        $query->execute([
            ':nombre'      => $product->getName(),
            ':descripcion' => $product->getDescription(),
            ':precio'      => $product->getPrice(),
            ':stock'       => $product->getStock(),
            ':categoria'   => $product->getCategory(),
            ':id'          => $product->getId(),
        ]);

        return $product;
    }

    /** DELETE: borra el producto con ese id. */
    public function delete($id)
    {
        $sql = 'DELETE FROM productos WHERE id = :id';

        $query = $this->db->prepare($sql);
        $query->execute([':id' => $id]);
    }

    // ------------------------------------------------------------------

    /** De fila de la base (arreglo) a OBJETO Product. */
    private function buildProduct($row)
    {
        return new Product(
            $row['id'],
            $row['nombre'],
            $row['descripcion'],
            $row['precio'],
            $row['stock'],
            $row['categoria'],
            (bool) $row['activo']
        );
    }
}
