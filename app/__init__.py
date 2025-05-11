from flask import Flask
from flask_mysqldb import MySQL
from flask_login import LoginManager
from config import Config

app = Flask(__name__)
app.config.from_object(Config)

mysql = MySQL(app)

# Configurar Flask-Login
login_manager = LoginManager(app)
login_manager.login_view = 'login'
# Cambia aquí el mensaje por defecto
login_manager.login_message = 'Debes iniciar sesión para continuar.'
# (opcional) Categoría del flash: 'info', 'warning', 'danger', etc.
login_manager.login_message_category = 'warning'

from app import routes, models
