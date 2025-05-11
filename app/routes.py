from flask import render_template, redirect, url_for, flash, request, abort
from werkzeug.security import generate_password_hash, check_password_hash
from flask_login import login_user, logout_user, current_user, login_required
from app.forms import RegistrationForm, LoginForm, UpdateProfileForm, ContactForm, ProductForm
from app.models import Usuario
from app import app, mysql
from functools import wraps


def get_or_create_carrito(user_id):
    cur = mysql.connection.cursor()
    # ¿Ya tiene carrito?
    cur.execute("SELECT id FROM carrito WHERE id_usuario = %s", (user_id,))
    row = cur.fetchone()
    if row:
        return row[0]
    # Si no, creamos uno
    cur.execute("INSERT INTO carrito (id_usuario) VALUES (%s)", (user_id,))
    mysql.connection.commit()
    return cur.lastrowid


@app.route('/')
def index():
    cur = mysql.connection.cursor()
    cur.execute("SELECT * FROM productos WHERE activo = 1 LIMIT 12")
    productos = cur.fetchall()
    return render_template('index.html', productos=productos)

@app.route('/producto/<int:id>')
def producto(id):
    cur = mysql.connection.cursor()
    cur.execute("SELECT * FROM productos WHERE id = %s", (id,))
    producto = cur.fetchone()

    cur.execute(
        """
        SELECT talla
        FROM tallas_producto
        WHERE id_producto = %s
        AND stock > 0
        ORDER BY CAST(talla AS UNSIGNED) ASC
        """,
        (id,)
    )
    tallas = cur.fetchall()


    return render_template('detalle_producto.html', producto=producto, tallas=tallas)

@app.route('/subcategoria/<int:id>')
def ver_subcategoria(id):
    cur = mysql.connection.cursor()
    cur.execute("""
        SELECT p.* FROM productos p
        WHERE p.id_subcategoria = %s AND p.activo = 1
    """, (id,))
    productos = cur.fetchall()

    # Puedes opcionalmente recuperar el nombre de la subcategoría
    cur.execute("SELECT nombre FROM subcategorias WHERE id = %s", (id,))
    subcategoria = cur.fetchone()

    return render_template('productos.html', productos=productos, subcategoria=subcategoria)

@app.route('/registro', methods=['GET', 'POST'])
def registro():
    if current_user.is_authenticated:
        return redirect(url_for('index'))
    form = RegistrationForm()
    if form.validate_on_submit():
        cur = mysql.connection.cursor()
        # 1) Comprueba si el email ya existe
        cur.execute("SELECT id FROM usuarios WHERE email = %s", (form.email.data,))
        if cur.fetchone():
            flash('Ese correo ya está registrado. Por favor, usa otro.', 'warning')
            return redirect(url_for('registro'))

        # 2) Si no existe, genera el hash e inserta
        hashed_pw = generate_password_hash(form.contraseña.data)
        cur.execute(
            "INSERT INTO usuarios (nombre, email, contraseña, rol) "
            "VALUES (%s, %s, %s, 'cliente')",
            (form.nombre.data, form.email.data, hashed_pw)
        )
        mysql.connection.commit()
        flash('¡Cuenta creada! Ahora puedes iniciar sesión.', 'success')
        return redirect(url_for('login'))

    return render_template('registro.html', form=form)


@app.route('/login', methods=['GET', 'POST'])
def login():
    if current_user.is_authenticated:
        return redirect(url_for('index'))
    form = LoginForm()
    if form.validate_on_submit():
        cur = mysql.connection.cursor()
        cur.execute("SELECT id, nombre, email, contraseña, rol FROM usuarios WHERE email = %s", (form.email.data,))
        row = cur.fetchone()
        if row and check_password_hash(row[3], form.contraseña.data):
            user = Usuario(*row)
            login_user(user, remember=form.recordar.data)
            next_page = request.args.get('next')
            return redirect(next_page) if next_page else redirect(url_for('index'))
        else:
            flash('Correo o contraseña incorrectos.', 'danger')
    return render_template('login.html', form=form)

@app.route('/logout')
@login_required
def logout():
    logout_user()
    return redirect(url_for('index'))

@app.route('/perfil', methods=['GET', 'POST'])
@login_required
def perfil():
    form = UpdateProfileForm()
    cur = mysql.connection.cursor()

    # Si envían el formulario de edición
    if form.validate_on_submit():
        nuevo_nombre = form.nombre.data
        cur.execute(
            "UPDATE usuarios SET nombre = %s WHERE id = %s",
            (nuevo_nombre, current_user.id)
        )
        mysql.connection.commit()
        flash('Nombre actualizado correctamente.', 'success')
        return redirect(url_for('perfil'))

    # Para GET o si no validó, precargar el formulario con el nombre actual
    cur.execute(
        "SELECT nombre, email, fecha_registro, rol FROM usuarios WHERE id = %s",
        (current_user.id,)
    )
    user = cur.fetchone()
    form.nombre.data = user[0]

    return render_template('perfil.html', user=user, form=form)

@app.route('/perfil/eliminar', methods=['POST'])
@login_required
def eliminar_cuenta():
    cur = mysql.connection.cursor()
    # Borra al usuario de la base de datos
    cur.execute("DELETE FROM usuarios WHERE id = %s", (current_user.id,))
    mysql.connection.commit()
    logout_user()
    flash('Tu cuenta ha sido eliminada.', 'info')
    return redirect(url_for('index'))

@app.route('/contacto', methods=['GET', 'POST'])
def contacto():
    form = ContactForm()
    if form.validate_on_submit():
        cur = mysql.connection.cursor()
        cur.execute(
            "INSERT INTO mensajes_contacto (nombre, email, mensaje) VALUES (%s, %s, %s)",
            (form.nombre.data, form.email.data, form.mensaje.data)
        )
        mysql.connection.commit()
        flash('Tu mensaje ha sido recibido. ¡Gracias!', 'success')
        return redirect(url_for('contacto'))
    return render_template('contacto.html', form=form)

@app.route('/carrito')
@login_required
def carrito():
    # Carga todas las líneas del carrito del usuario
    cur = mysql.connection.cursor()
    cur.execute("""
        SELECT dc.id, p.nombre, p.imagen, p.precio, dc.talla, dc.cantidad
          FROM detalle_carrito dc
          JOIN carrito c ON dc.id_carrito = c.id
          JOIN productos p ON dc.id_producto = p.id
         WHERE c.id_usuario = %s
    """, (current_user.id,))
    lineas = cur.fetchall()  # lista de (id, nombre, imagen, precio, talla, cantidad)

    # Calcula totales
    total = sum(row[3] * row[5] for row in lineas)

    return render_template('carrito.html', lineas=lineas, total=total)

@app.route('/carrito/add', methods=['POST'])
@login_required
def carrito_add():
    producto_id = request.form.get('id_producto')
    talla      = request.form.get('talla', None)
    cantidad   = int(request.form.get('cantidad', 1))

    carrito_id = get_or_create_carrito(current_user.id)
    cur = mysql.connection.cursor()
    # Comprueba si ya existe la línea
    cur.execute(
        """
        SELECT id, cantidad
          FROM detalle_carrito
         WHERE id_carrito = %s
           AND id_producto = %s
           AND (talla = %s OR (%s IS NULL AND talla IS NULL))
        """,
        (carrito_id, producto_id, talla, talla)
    )
    row = cur.fetchone()
    if row:
        nueva = row[1] + cantidad
        cur.execute("UPDATE detalle_carrito SET cantidad = %s WHERE id = %s", (nueva, row[0]))
    else:
        cur.execute(
            "INSERT INTO detalle_carrito (id_carrito, id_producto, talla, cantidad) VALUES (%s, %s, %s, %s)",
            (carrito_id, producto_id, talla, cantidad)
        )
    mysql.connection.commit()
    
    # REDIRIGIMOS A LA PÁGINA DEL CARRITO
    return redirect(url_for('carrito'))


@app.route('/carrito/update', methods=['POST'])
@login_required
def carrito_update():
    linea_id = request.form.get('linea_id')
    cantidad = int(request.form.get('cantidad', 0))
    cur = mysql.connection.cursor()
    if cantidad > 0:
        cur.execute("UPDATE detalle_carrito SET cantidad = %s WHERE id = %s", (cantidad, linea_id))
    else:
        cur.execute("DELETE FROM detalle_carrito WHERE id = %s", (linea_id,))
    mysql.connection.commit()
    return redirect(url_for('carrito'))

@app.route('/checkout', methods=['POST'])
@login_required
def checkout():
    cur = mysql.connection.cursor()
    # 1) Obtén el id del carrito y las líneas
    cur.execute("SELECT id FROM carrito WHERE id_usuario = %s", (current_user.id,))
    carrito_row = cur.fetchone()
    if not carrito_row:
        flash('No tienes productos en el carrito.', 'warning')
        return redirect(url_for('carrito'))

    carrito_id = carrito_row[0]
    cur.execute("""
        SELECT dc.id, dc.id_producto, dc.talla, dc.cantidad, p.precio
          FROM detalle_carrito dc
          JOIN productos p ON dc.id_producto = p.id
         WHERE dc.id_carrito = %s
    """, (carrito_id,))
    lineas = cur.fetchall()  # [(linea_id, prod_id, talla, cantidad, precio), ...]

    if not lineas:
        flash('Tu carrito está vacío.', 'warning')
        return redirect(url_for('carrito'))

    # 2) Calcula total
    total = sum(cantidad * float(precio) for _, _, _, cantidad, precio in lineas)

    # 3) Inserta en pedidos
    cur.execute(
        "INSERT INTO pedidos (id_usuario, total) VALUES (%s, %s)",
        (current_user.id, total)
    )
    pedido_id = cur.lastrowid

    # 4) Inserta en detalle_pedidos y 5) Ajusta stock
    for _, prod_id, talla, cantidad, precio in lineas:
        # inserta línea de pedido
        cur.execute("""
            INSERT INTO detalle_pedidos
              (id_pedido, id_producto, talla, cantidad, precio_unitario)
            VALUES (%s, %s, %s, %s, %s)
        """, (pedido_id, prod_id, talla, cantidad, precio))

        # ajusta stock por talla
        if talla:
            cur.execute("""
                UPDATE tallas_producto
                   SET stock = stock - %s
                 WHERE id_producto = %s AND talla = %s
            """, (cantidad, prod_id, talla))

    # 6) Vacía carrito
    cur.execute("DELETE FROM detalle_carrito WHERE id_carrito = %s", (carrito_id,))
    cur.execute("DELETE FROM carrito WHERE id = %s", (carrito_id,))

    mysql.connection.commit()
    return redirect(url_for('checkout_success'))

@app.route('/checkout/success')
@login_required
def checkout_success():
    return render_template('checkout_success.html')

def admin_required(f):
    @wraps(f)
    def wrapped(*args, **kwargs):
        if not current_user.is_authenticated or current_user.role != 'admin':
            abort(403)
        return f(*args, **kwargs)
    return wrapped

@app.route('/admin/productos')
@admin_required
def admin_productos():
    cur = mysql.connection.cursor()
    cur.execute("SELECT id, nombre, precio, activo FROM productos")
    productos = cur.fetchall()
    return render_template('admin/productos.html', productos=productos)

@app.route('/admin/productos/nuevo', methods=['GET','POST'])
@admin_required
def admin_producto_nuevo():
    form = ProductForm()
    # Carga subcategorías
    cur = mysql.connection.cursor()
    cur.execute("SELECT id, nombre FROM subcategorias")
    form.subcategoria.choices = cur.fetchall()

    if form.validate_on_submit():
        cur.execute("""
            INSERT INTO productos 
              (nombre, descripcion, imagen, precio, activo, id_subcategoria)
            VALUES (%s, %s, %s, %s, %s, %s)
        """, (
            form.nombre.data,
            form.descripcion.data,
            form.imagen.data,
            float(form.precio.data),
            1 if form.activo.data else 0,
            form.subcategoria.data
        ))
        mysql.connection.commit()
        flash('Producto creado.', 'success')
        return redirect(url_for('admin_productos'))

    return render_template('admin/producto_form.html', form=form, titulo='Nuevo producto')

@app.route('/admin/productos/<int:id>/editar', methods=['GET','POST'])
@admin_required
def admin_producto_editar(id):
    form = ProductForm()
    cur = mysql.connection.cursor()
    # Choices
    cur.execute("SELECT id, nombre FROM subcategorias")
    form.subcategoria.choices = cur.fetchall()

    # GET: precargar
    if request.method == 'GET':
        cur.execute("SELECT nombre, descripcion, imagen, precio, activo, id_subcategoria FROM productos WHERE id = %s", (id,))
        p = cur.fetchone()
        form.nombre.data, form.descripcion.data, form.imagen.data, form.precio.data, form.activo.data, form.subcategoria.data = p

    if form.validate_on_submit():
        cur.execute("""
            UPDATE productos 
               SET nombre=%s, descripcion=%s, imagen=%s, precio=%s, activo=%s, id_subcategoria=%s
             WHERE id = %s
        """, (
            form.nombre.data,
            form.descripcion.data,
            form.imagen.data,
            float(form.precio.data),
            1 if form.activo.data else 0,
            form.subcategoria.data,
            id
        ))
        mysql.connection.commit()
        flash('Producto actualizado.', 'success')
        return redirect(url_for('admin_productos'))

    return render_template('admin/producto_form.html', form=form, titulo='Editar producto')

@app.route('/admin/productos/<int:id>/borrar', methods=['POST'])
@admin_required
def admin_producto_borrar(id):
    cur = mysql.connection.cursor()
    cur.execute("DELETE FROM productos WHERE id = %s", (id,))
    mysql.connection.commit()
    flash('Producto eliminado.', 'info')
    return redirect(url_for('admin_productos'))
