# TeCalzoZapas

**TeCalzoZapas** es una tienda online de sneakers y artículos limitados donde podrás navegar por categorías y subcategorías, ver detalles de productos, gestionar tu carrito de compras, registrarte/iniciar sesión, finalizar pedidos y enviar mensajes de contacto.

---

## Requisitos

- Python 3.9+  
- MySQL Server  
- Git  

---

## Instalación y configuración

1. **Clona el repositorio**  
   ```bash
   git clone https://github.com/tu-usuario/TeCalzoZapas.git
   cd TeCalzoZapas
   ```

2. **Crea un entorno virtual**  
   ```bash
   python -m venv venv
   source venv/bin/activate    # Linux/macOS
   venv\Scripts\activate     # Windows
   ```

3. **Instala las dependencias**  
   ```bash
   pip install -r requirements.txt
   ```

4. **Prepara la base de datos**  
   - Crea una base de datos llamada `tecalzozapas` en MySQL.  
   - Importa el esquema y datos iniciales:
     ```bash
     mysql -u TU_USUARIO -p tecalzozapas < TeCalzoZapas.sql
     ```  
   - Copia `config.example.py` a `config.py` y ajusta tus credenciales:
     ```python
     class Config:
         SECRET_KEY     = 'una_clave_segura'
         MYSQL_HOST     = 'localhost'
         MYSQL_USER     = 'TU_USUARIO'
         MYSQL_PASSWORD = 'TU_CONTRASEÑA'
         MYSQL_DB       = 'tecalzozapas'
     ```

---

## Ejecución

```bash
python run.py
```

Abre tu navegador en:  
```
http://localhost:5000
```

