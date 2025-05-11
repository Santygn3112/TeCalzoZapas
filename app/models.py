from flask_login import UserMixin
from app import login_manager, mysql

class Usuario(UserMixin):
    def __init__(self, id, nombre, email, contraseña, rol):
        self.id = id
        self.nombre = nombre
        self.email = email
        self.contraseña = contraseña
        self.rol = rol

@login_manager.user_loader
def load_user(user_id):
    cur = mysql.connection.cursor()
    cur.execute("SELECT id, nombre, email, contraseña, rol FROM usuarios WHERE id = %s", (user_id,))
    row = cur.fetchone()
    if row:
        return Usuario(*row)
    return None
