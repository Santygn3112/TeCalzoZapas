from flask_wtf import FlaskForm
from wtforms import StringField, PasswordField, SubmitField, BooleanField, TextAreaField
from wtforms.validators import DataRequired, Email, EqualTo, Length

class RegistrationForm(FlaskForm):
    nombre = StringField(
        'Nombre completo',
        validators=[DataRequired(), Length(min=2, max=100)]
    )
    email = StringField(
        'Email',
        validators=[DataRequired(), Email()]
    )
    contraseña = PasswordField(
        'Contraseña',
        validators=[
            DataRequired(),
            Length(min=4, message='La contraseña debe tener al menos 4 caracteres')
        ]
    )
    confirmar_contraseña = PasswordField(
        'Confirmar contraseña',
        validators=[
            DataRequired(),
            Length(min=4, message='La contraseña debe tener al menos 4 caracteres'),
            EqualTo('contraseña', message='Las contraseñas deben coincidir')
        ]
    )
    submit = SubmitField('Registrarse')

class LoginForm(FlaskForm):
    email = StringField(
        'Email',
        validators=[DataRequired(), Email()]
    )
    contraseña = PasswordField(
        'Contraseña',
        validators=[DataRequired(), Length(min=4, message='La contraseña debe tener al menos 4 caracteres')]
    )
    recordar = BooleanField('Recordarme')
    submit = SubmitField('Iniciar sesión')
    
class UpdateProfileForm(FlaskForm):
    nombre = StringField(
        'Nombre completo',
        validators=[DataRequired(), Length(min=2, max=100)]
    )
    submit = SubmitField('Guardar cambios')
    
class ContactForm(FlaskForm):
    nombre = StringField(
        'Nombre',
        validators=[DataRequired(), Length(min=2, max=50)]
    )
    email = StringField(
        'Email',
        validators=[DataRequired(), Email()]
    )
    mensaje = TextAreaField(
        'Mensaje',
        validators=[DataRequired(), Length(min=10, max=500)]
    )
    submit = SubmitField('Enviar mensaje')

class ProductForm(FlaskForm):
    nombre       = StringField('Nombre', validators=[DataRequired(), Length(max=150)])
    descripcion  = TextAreaField('Descripción', validators=[DataRequired()])
    imagen       = StringField('Ruta imagen', validators=[DataRequired(), Length(max=255)])
    precio       = DecimalField('Precio', validators=[DataRequired(), NumberRange(min=0)])
    activo       = BooleanField('Activo', default=True)
    subcategoria = SelectField('Subcategoría', coerce=int, validators=[DataRequired()])
    submit       = SubmitField('Guardar')