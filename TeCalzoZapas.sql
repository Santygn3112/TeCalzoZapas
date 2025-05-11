-- Crear base de datos
CREATE DATABASE tecalzozapas CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci;

USE tecalzozapas;

-- Tabla: usuarios
CREATE TABLE usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    contraseña VARCHAR(255) NOT NULL,
    rol ENUM('cliente', 'admin') DEFAULT 'cliente',
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Tabla: categorias
CREATE TABLE categorias (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE
);

-- Tabla: subcategorias
CREATE TABLE subcategorias (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    id_categoria INT NOT NULL,
    FOREIGN KEY (id_categoria) REFERENCES categorias(id) ON DELETE CASCADE
);

-- Tabla: productos
CREATE TABLE productos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
	imagen VARCHAR(255),
    precio DECIMAL(10,2) NOT NULL,
    activo BOOLEAN DEFAULT TRUE,
    id_subcategoria INT,
    FOREIGN KEY (id_subcategoria) REFERENCES subcategorias(id) ON DELETE SET NULL
);

CREATE TABLE tallas_producto (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_producto INT NOT NULL,
    talla VARCHAR(5) NOT NULL,
    stock INT DEFAULT 0,
    FOREIGN KEY (id_producto) REFERENCES productos(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Tabla carrito (sin cambios de estado)
CREATE TABLE carrito (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL UNIQUE,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id) ON DELETE CASCADE
);

-- Tabla detalle_carrito modificada
CREATE TABLE detalle_carrito (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_carrito INT NOT NULL,
    id_producto INT NOT NULL,
    talla VARCHAR(5),
    cantidad INT NOT NULL CHECK (cantidad >= 0),
    
    -- Evita duplicar la misma línea de producto+talla en un mismo carrito
    UNIQUE KEY unica_linea (id_carrito, id_producto, talla),
    
    FOREIGN KEY (id_carrito)  REFERENCES carrito(id)   ON DELETE CASCADE,
    FOREIGN KEY (id_producto) REFERENCES productos(id) ON DELETE CASCADE
);

-- Tabla: pedidos
CREATE TABLE pedidos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    fecha DATETIME DEFAULT CURRENT_TIMESTAMP,
    total DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id) ON DELETE CASCADE
);

-- Tabla: detalle_pedido
CREATE TABLE detalle_pedidos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido INT NOT NULL,
    id_producto INT NOT NULL,
    talla VARCHAR(5),
    cantidad INT NOT NULL CHECK (cantidad > 0),
    precio_unitario DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (id_pedido)   REFERENCES pedidos(id)   ON DELETE CASCADE,
    FOREIGN KEY (id_producto) REFERENCES productos(id) ON DELETE RESTRICT
);

CREATE TABLE mensajes_contacto (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(50) NOT NULL,
  email VARCHAR(100) NOT NULL,
  mensaje TEXT NOT NULL,
  fecha DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Insertar categorías
INSERT INTO categorias (nombre) VALUES 
('Nike'),
('Jordan'),
('Adidas'),
('Exclusivo'),
('Complementos');

-- Insertar subcategorías
INSERT INTO subcategorias (nombre, id_categoria) VALUES
-- Subcategorías de Nike (id_categoria = 1)
('Air Max', 1),
('Air Force', 1),
('Dunk', 1),

-- Subcategorías de Jordan (id_categoria = 2)
('Jordan I', 2),
('Jordan III', 2),
('Jordan IV', 2),

-- Subcategorías de Adidas (id_categoria = 3)
('NMD', 3),
('Ozweego', 3),
('Forum', 3),

-- Subcategorías de Exclusivo (id_categoria = 4)
('Travis', 4),
('Yeezy', 4),
('Rarezas', 4),

-- Subcategorías de Complementos (id_categoria = 5)
('Cinturones', 5),
('Bandoleras', 5),
('Bolsos', 5);

-- Inserts de productos
-- Air Max
INSERT INTO productos (nombre, descripcion, precio, imagen, activo, id_subcategoria)
VALUES 
(
    'Vapormax',
    'Las Nike Air Max 95 no dejan a nadie indiferente. Su estilo retro se consolida con un enfoque absolutamente renovado, capaz de enamorar a los fashionistas más convencidos. Su interior ha sido confeccionado en tejido textil, lo que lo ha convertido en todavía más cómodo, amable y agradable en el uso. La suela, por su parte, es de goma y tiene un dibujo capaz de mejorar su agarre y su tracción sobre el terreno. En concreto, incorpora surcos de flexión y superficie waffle. Asimismo, una de sus características más curiosas es el levantamiento ergonómico de la parte delantera, además de presentar una cámara de aire bien visible.',
    128.00,
    'img/vapormax',
    TRUE,
    1
),
(
    'Air Max 95',
    'Las Nike Air Max 95 no dejan a nadie indiferente. Su estilo retro se consolida con un enfoque absolutamente renovado, capaz de enamorar a los fashionistas más convencidos. Su interior ha sido confeccionado en tejido textil, lo que lo ha convertido en todavía más cómodo, amable y agradable en el uso. La suela, por su parte, es de goma y tiene un dibujo capaz de mejorar su agarre y su tracción sobre el terreno. En concreto, incorpora surcos de flexión y superficie waffle. Asimismo, una de sus características más curiosas es el levantamiento ergonómico de la parte delantera, además de presentar una cámara de aire bien visible.',
    180.00,
    'img/air_max_95',
    TRUE,
    1
),
(
    'Air Max 97',
    'Las zapatillas Nike Air Max 97 fueron pioneras en el uso de una unidad completa de amortiguación Max Air en la suela. Hasta entonces, solo se usaban en el talón o el antepié, y la sensación de comodidad que lograron revolucionó el mercado del calzado deportivo. La tecnología Max Air protege contra los impactos gracias a la capa de aire que incorpora en la mediasuela. Además, con esta técnica se logra que las zapatillas sean más ligeras.',
    190.00,
    'img/air_max_97',
    TRUE,
    1
);

-- Air Force 1
INSERT INTO productos (nombre, descripcion, precio, imagen, activo, id_subcategoria) VALUES (
    'Air Force 1 Swarovski',
    'Estas Nike Air Force 1 apenas son reconocibles como tal, porque su cuero premium se ha cubierto con un panel superior removible sintético. El panel, que luce un estampado abstracto, tiene una particularidad: como no podía ser de otra manera, está cubierto de cristales Swarovski. En lugar de ir cosidos al modelo, los paneles van atornillados a la mediasuela, y las Nike Air Force 1 vienen acompañadas de un destornillador que lleva el nombre del modelo grabado, en caso de que quisiéramos prescindir de ellos. Las zapatillas están terminadas con mediasuelas y suelas tonales.',
    460.00,
    'img/air_force_1_swarovski',
    TRUE,
    2
);

INSERT INTO productos (nombre, descripcion, precio, imagen, activo, id_subcategoria) VALUES (
    'Air Force 1 Purple Skeleton',
    'Desafiar al miedo e infundirlo son grandes premisas de la noche de Halloween y las Air Force 1 ‘Skeleton’ son ideales para dar tus mejores sustos con mucho estilo. Este clásico de Nike aparecido en 2018 vuelve de entre los muertos con un colorway Court Purple que te va a combinar más allá de la noche del 31 de octubre. Si quieres ser una alma de las tinieblas estas Air Force 1 ‘Skeleton’ tiene todo lo que buscas con detalles como el clásico efecto de rayos X que muestra de manera tenebrosa los huesos del pie o la suela translúcida que brilla en la oscuridad.',
    190.00,
    'img/air_force_1_purple_skeleton',
    TRUE,
    2
);

INSERT INTO productos (nombre, descripcion, precio, imagen, activo, id_subcategoria) VALUES (
    'Air Force 1 Travis Scott',
    'Desafiar al miedo e infundirlo son grandes premisas de la noche de Halloween y las Air Force 1 ‘Skeleton’ son ideales para dar tus mejores sustos con mucho estilo. Este clásico de Nike aparecido en 2018 vuelve de entre los muertos con un colorway Court Purple que te va a combinar más allá de la noche del 31 de octubre. Si quieres ser una alma de las tinieblas estas Air Force 1 ‘Skeleton’ tiene todo lo que buscas con detalles como el clásico efecto de rayos X que muestra de manera tenebrosa los huesos del pie o la suela translúcida que brilla en la oscuridad.',
    550.00,
    'img/air_force_1_travis_scott',
    TRUE,
    2
);

-- Dunk
INSERT INTO productos (nombre, descripcion, precio, imagen, activo, id_subcategoria) VALUES (
    'Dunk Purple Pulse',
    'Una nueva saga de Dunk Low ha llegado, incluyendo el Purple Pulse. Con una estética similar a la de su hermano "Yellow Strike", la lowtop viene en una base de cuero blanco con inserciones azules, con un swoosh de gamuza púrpura que añade contraste. Este último tono se encontrará en las marcas y en la suela exterior, que se combina con una entresuela prístina.',
    270.00,
    'img/dunk_purple_pulse',
    TRUE,
    3
);

INSERT INTO productos (nombre, descripcion, precio, imagen, activo, id_subcategoria) VALUES (
    'Dunk Parra Abstract',
    'El estampado sigue los códigos creativos de esta marca urbana que tiene fans en todo el mundo. Una zapatilla con ADN skater que busca, según la descripción de Nike del producto, “fomentar la abstracción paisajística”. Y la verdad es que la zapatilla funciona muy bien. Tienen personalidad propia y los materiales son buenos. Calzado edición limitada que no puede faltar en tu colección.',
    305.00,
    'img/dunk_parra_abstract',
    TRUE,
    3
);

INSERT INTO productos (nombre, descripcion, precio, imagen, activo, id_subcategoria) VALUES (
    'Dunk GDB Yellow',
    'Nike Skateboarding se asoció con la legendaria banda de rock psicodélico Grateful Dead para lanzar Nike SB Dunk Low Grateful Dead Bears Green. El tema de diseño de esta colaboración rinde homenaje a los Grateful Dead Bears, una serie de estilizados osos bailarines ilustrados por Bob Thomas en la contraportada del álbum History of the Grateful Dead, Volume One (Bear’s Choice) en 1973. El SB Dunk Low Grateful Dead Bears Yellow presenta una parte superior de piel sintética verde difusa con superposiciones de ante y un Swoosh dentado para representar la estilización del pelaje del pecho del oso. Dentro de la lengüeta se incluye un bolsillo oculto que es perfecto para almacenamiento adicional. Una entresuela verde, una suela azul y la marca Grateful Dead en la lengüeta completan este diseño eufórico.',
    950.00,
    'img/dunk_gdb_yellow',
    TRUE,
    3
);

-- Jordan I
INSERT INTO productos (nombre, descripcion, precio, imagen, activo, id_subcategoria) VALUES (
    'Jordan I Retro High OG Patent Bred',
    'La Air Jordan 1 High Bred Patent presenta una parte superior de charol negro y rojo con etiquetas de lengüeta Nike Air tejidas con la firma. A partir de ahí, un logotipo clásico de Wings en el cuello y un blanco con suela Air roja completan el diseño retro.',
    510.00,
    'img/jordan_i_retro_high_og_patent_bred',
    TRUE,
    4
);

INSERT INTO productos (nombre, descripcion, precio, imagen, activo, id_subcategoria) VALUES (
    'Jordan I Low Spades',
    'La parte superior de las Low Spades Jordan 1 utiliza diseños de paisley rojo en relieve sobre cuero negro. Un Swoosh dorado agrega más detalles brillantes y lujosos a la zapatilla con una calcomanía de espadas cosida en la etiqueta de la lengüeta. Por último, una "Q" y una "K" de oro se bordan más cerca de la punta de la zapatilla para la reina y el rey de una baraja de cartas.',
    365.00,
    'img/jordan_i_low_spades',
    TRUE,
    4
);

INSERT INTO productos (nombre, descripcion, precio, imagen, activo, id_subcategoria) VALUES (
    'Jordan I University Blue Retro',
    'La Air Jordan 1 High "University Blue" está inspirada en un color original del primer zapato de la firma de Michael Jordan. Un lanzamiento de principios de 2021 de Jordan Brand, el Jordan 1 "University Blue" viene en la deseable silueta alta y recluta una mezcla de materiales y colores con sabor "UNC" para un diseño atractivo. El cuero blanco de grano completo aparece en el panel central y en el dedo del pie perforado. Las superposiciones de cuero nubuck University Blue en el antepié, los ojales, el cuello y el talón contrastan con la base blanca y nítida. Jordan Brand agrega un Swoosh de cuero negro a cada lado y un logotipo negro de "Wings" al cuello. Los detalles adicionales incluyen cordones negros en una lengüeta de nylon blanca, un logotipo azul claro "Nike Air" en la etiqueta de la lengüeta de nylon negro y cuero negro flexible en el cuello.',
    2225.00,
    'img/jordan_i_university_blue_retro',
    TRUE,
    4
);

-- Jordan III
INSERT INTO productos (nombre, descripcion, precio, imagen, activo, id_subcategoria) VALUES (
    'Jordan III Blue Retro',
    'La Air Jordan 3 Racer Blue presenta una parte superior de cuero blanco con perillas de cuero perforado gris y superposiciones de cemento. A partir de ahí, los golpes de Racer Blue en los logotipos y la mediasuela de Jumpman agregan vitalidad al modelo clásico.',
    415.00,
    'img/jordan_iii_blue_retro',
    TRUE,
    5
);

INSERT INTO productos (nombre, descripcion, precio, imagen, activo, id_subcategoria) VALUES (
    'Jordan III Green Retro',
    'El Air Jordan 3 Pine Green presenta una parte superior De Durabuck negro con superposiciones de estampado de elefante y collares perforados verdes. Los toques de Pine Green en la mediasuela y el bordado de lengua Jumpman destacan sobre sus fondos neutros. A partir de ahí, una pestaña de tacón Jumpman y suela Air añaden los toques finales a este diseño retro.',
    420.00,
    'img/jordan_iii_green_retro',
    TRUE,
    5
);

INSERT INTO productos (nombre, descripcion, precio, imagen, activo, id_subcategoria) VALUES (
    'Jordan III Red Retro',
    'Jordan Brand trajo un colorway OG Air Jordan 7 a air Jordan 3 para el Air Jordan 3 Cardinal Red. Construido con cuero blanco y superposiciones de Elephant Print, el Air Jordan 3 Cardinal Red adopta un enfoque tradicional en su bloqueo y fabricación de color, similar al icónico Black Cement 3s. Condimentando el diseño, las afiladas medias cardinales rojas y los detalles resaltan contra la parte superior de tono neutro. El bordado del logotipo de Jumpman de color naranja brillante en la lengüeta agrega el toque final.',
    375.00,
    'img/jordan_iii_red_retro',
    TRUE,
    5
);

-- Jordan IV
INSERT INTO productos (nombre, descripcion, precio, imagen, activo, id_subcategoria) VALUES (
    'Jordan IV Retro Kaws',
    'El famoso artista KAWS ha sido bastante solitario desde que descontinuó su marca de ropa urbana OriginalFake, solo mostrando cara para el proyecto ocasional de alto arte o la colaboración que vale la pena. Jordan Brand lo encargó para este último; su lienzo: el Air Jordan 4. El resultado, magnífico. El KAWS x Air Jordan 4 presenta una parte superior de gamuza premium mantecosa en texturas lisas y brezosas, todo empapado en un color gris tonal. Los gráficos a mano de KAWS también están grabados en la parte superior, junto con la etiqueta colgante correspondiente. La mediasuela y la parte superior "Wings" también están envueltas en gamuza. Finalmente, un brillo en la suela oscura completa el look.',
    5646.00,
    'img/jordan_iv_retro_kaws',
    TRUE,
    6
);

INSERT INTO productos (nombre, descripcion, precio, imagen, activo, id_subcategoria) VALUES (
    'Jordan 4 Green Retro Golf',
    'Uno de los zapatos más codiciados de todos los tiempos se reconstruye para el golf en el Jordan 4 G. Con una unidad Air-Sole visible y púas extraíbles, este zapato ofrece el agarre y la comodidad que necesitas para jugar al máximo con el estilo legendario del original.',
    531.00,
    'img/jordan_4_green_retro_golf',
    TRUE,
    6
);

INSERT INTO productos (nombre, descripcion, precio, imagen, activo, id_subcategoria) VALUES (
    'Jordan IV Retro OG Oreo',
    'La Air Jordan 4 Retro White Oreo cuenta con una parte superior de cuero blanco y malla con toques de Tech Grey en sus ojales y mediasuela. A partir de ahí, un logotipo rojo de Jumpman se borda en la lengüeta, agregando un toque de color al diseño de tonos neutros.',
    1127.00,
    'img/jordan_iv_retro_og_oreo',
    TRUE,
    6
);

-- NMD
INSERT INTO productos (nombre, descripcion, precio, imagen, activo, id_subcategoria) VALUES (
    'Adidas NMD R1 Boost',
    'Esta zapatilla cuenta con una parte superior de punto elástico que incluye una inscripción en el lateral e incorpora una suela traslúcida que aporta un toque de estilo urbano. La tecnología Boost te ofrece una comodidad inigualable desde el primer paso.',
    199.00,
    'img/adidas_nmd_r1_boost',
    TRUE,
    7
);

INSERT INTO productos (nombre, descripcion, precio, imagen, activo, id_subcategoria) VALUES (
    'Adidas NMD x Pharrell Williams',
    'Después de un descanso más corto del modelo, Pharrell Williams y adidas están listos para presentar un puñado de nuevas versiones del NMD Hu. Una de ellas es esta versión "Cream White", que luce un diseño súper elegante que consiste en una parte superior blanca crema con "BREATHE" y "THOUGHT" bordadas en blanco, una suela BOOST blanca tiza y una suela de goma con patrón de terreno.',
    532.00,
    'img/adidas_nmd_x_pharrell_williams',
    TRUE,
    7
);

INSERT INTO productos (nombre, descripcion, precio, imagen, activo, id_subcategoria) VALUES (
    'Adidas NMD Hu Trail x Pharrell Williams x BBC',
    'Zapatillas NMD Hu Trail BBC de adidas by Pharell Williams en nylon de adidas con puntera redonda, diseño tejido y suela dentada. POSITIVELY CONSCIOUS: adidas Group recibe una puntuación de 4 sobre 5 por parte de la agencia ética Good On You. La marca utiliza materiales ecológicos en muchos de sus productos, el 100% del algodón proviene de fuentes sostenibles, y se ha comprometido a utilizar poliéster 100% reciclado para el 2024. La firma efectúa auditorías en casi toda su cadena de suministros para garantizar que se cumplen los estándares laborales. Además, se compromete a reducir el carbono y el desperdicio de agua en toda su cadena de producción.',
    690.00,
    'img/adidas_nmd_hu_trail_x_pharrell_williams_x_bbc',
    TRUE,
    7
);

-- Ozweego
INSERT INTO productos (nombre, descripcion, precio, imagen, activo, id_subcategoria) VALUES (
    'Adidas Ozweego Green Grey',
    'Zapatillas no triviales de uno de los diseñadores más reconocibles del mundo. En este modelo, Raf Simons presenta su visión futurista del estilo de carrera. Parte superior de varias capas',
    514.00,
    'img/adidas_ozweego_green_grey',
    TRUE,
    8
);

INSERT INTO productos (nombre, descripcion, precio, imagen, activo, id_subcategoria) VALUES (
    'Adidas Ozweego III',
    'Zapatillas Ozweego III de color borgoña de adidas by Raf Simons con cierre con cordones, puntera redonda, plantilla con logo, parche del logo en la lengüeta y suela de goma dividida. POSITIVELY CONSCIOUS: adidas Group recibe una puntuación de 4 sobre 5 por parte de la agencia ética Good On You. La marca utiliza materiales ecológicos en muchos de sus productos, el 100% del algodón proviene de fuentes sostenibles, y se ha comprometido a utilizar poliéster 100% reciclado para el 2024. La firma efectúa auditorías en casi toda su cadena de suministros para garantizar que se cumplen los estándares laborales. Además, se compromete a reducir el carbono y el desperdicio de agua en toda su cadena de producción.',
    1734.00,
    'img/adidas_ozweego_iii',
    TRUE,
    8
);

INSERT INTO productos (nombre, descripcion, precio, imagen, activo, id_subcategoria) VALUES (
    'Adidas Ozweego RS',
    'Zapatillas RS Ozweego de adidas. POSITIVELY CONSCIOUS: adidas Group recibe una puntuación de 4 sobre 5 por parte de la agencia ética Good On You. La marca utiliza materiales ecológicos en muchos de sus productos, el 100% del algodón proviene de fuentes sostenibles, y se ha comprometido a utilizar poliéster 100% reciclado para el 2024. La firma efectúa auditorías en casi toda su cadena de suministros para garantizar que se cumplen los estándares laborales. Además, se compromete a reducir el carbono y el desperdicio de agua en toda su cadena de producción.',
    1556.00,
    'img/adidas_ozweego_rs',
    TRUE,
    8
);

-- 	Forum
INSERT INTO productos (nombre, descripcion, precio, imagen, activo, id_subcategoria) VALUES (
    'Adidas Forum 84 x Eric Emmanuek',
    'Detalle de raya lateral, logo bordado, lengüeta con logo estampado, detalle del logo Trefoil, cierre con cordones en la parte delantera, cierre autoadherente en la parte delantera, puntera redonda y suela plana de goma. Material: cuero.',
    226.00,
    'img/adidas_forum_84_x_eric_emmanuek',
    TRUE,
    9
);

INSERT INTO productos (nombre, descripcion, precio, imagen, activo, id_subcategoria) VALUES (
    'Adidas Forum Low "Easter Egg" x Bad Bunny',
    'Logo 3-Stripes característico, cordones con sistema de cierre rápido, puntera redonda, cierre con cordones en la parte delantera, parche del logo en la lengüeta, cierre lateral con hebilla, plantilla con logo y suela de goma. Estos estilos son suministrados por un marketplace de zapatillas premium, el cual ofrece el calzado más codiciado y difícil de encontrar de todo el mundo.',
    775.00,
    'img/adidas_forum_low_easter_egg_x_bad_bunny',
    TRUE,
    9
);

INSERT INTO productos (nombre, descripcion, precio, imagen, activo, id_subcategoria) VALUES (
    'Adidas Forum Low Wings 1.0 Money x Jeremy Scoot',
    'Estampado gráfico en toda la pieza, puntera redonda, cierre con cordones en la parte delantera, parche del logo en la lengüeta, plantilla con logo y suela de goma. Material: cuero. Estos estilos son suministrados por un marketplace de zapatillas premium, el cual ofrece el calzado más codiciado y difícil de encontrar de todo el mundo.',
    581.00,
    'img/adidas_forum_low_wings_1_0_money_x_jeremy_scoot',
    TRUE,
    9
);

-- Travis
INSERT INTO productos (nombre, descripcion, precio, imagen, activo, id_subcategoria) VALUES (
    'Air Force 1 Travis Scott',
    'Las Nike Air Force One ‘1 X Travis Scott’ Blancas son la revolución de la marca Nike. En colaboración con Travis Scott, han sacado este modelo junto al jugador más legendario de básquetbol. Esto ha permitido aportar a estos sneakers la cultura urbana con innovación y pasión. Disponibles dos modelos al mejor precio.',
    2149.00,
    'img/air_force_1_travis_scottv2',
    TRUE,
    10
);

INSERT INTO productos (nombre, descripcion, precio, imagen, activo, id_subcategoria) VALUES (
    'Jordan IV Travis Scott',
    'El par comparte la estructura general de todas las Air Jordan de corte alto, pero añade deliciosos detalles como el swoosh invertido, el logo de Cactus Jack bordado en blanco en el lateral y el símbolo emblemático del artista en el talón.Entre sus materiales encontramos ante y piel de alta calidad que evita arrugas en la sneaker al andar y hace que resulte un par flexible, atractivo y duradero.Su nobuk marrón con acentos blancos y la suela bicolor de vela marrón hacen que estas sneakers queden brutales cuando te las pones. Pero lo que realmente nos vuelve locos es el detalle del bolsillo oculto en el tobillo. Un escondite donde podrás guardar lo que quieras.',
    1901.00,
    'img/jordan_iv_travis_scott',
    TRUE,
    10
);

INSERT INTO productos (nombre, descripcion, precio, imagen, activo, id_subcategoria) VALUES (
    'Jordan I Travis Scott',
    'El par comparte la estructura general de todas las Air Jordan de corte alto, pero añade deliciosos detalles como el swoosh invertido, el logo de Cactus Jack bordado en blanco en el lateral y el símbolo emblemático del artista en el talón.Entre sus materiales encontramos ante y piel de alta calidad que evita arrugas en la sneaker al andar y hace que resulte un par flexible, atractivo y duradero.Su nobuk marrón con acentos blancos y la suela bicolor de vela marrón hacen que estas sneakers queden brutales cuando te las pones. Pero lo que realmente nos vuelve locos es el detalle del bolsillo oculto en el tobillo. Un escondite donde podrás guardar lo que quieras.',
    2938.00,
    'img/jordan_i_travis_scott',
    TRUE,
    10
);

-- Yeezy
INSERT INTO productos (nombre, descripcion, precio, imagen, activo, id_subcategoria) VALUES (
    'Yeezy 350',
    'Estas zapatillas Yeezy vienen de la mano de Kanye West el cual ha sido el diseñador de estas Sneakers, se aprecia la mano del rapero en estas Adidas las cuales ha sabido llevar a lo mas alto del podium en el mundo del calzado de marca, haciendo de ellas un modelo premium de edición limitada. Pero no solo eso, su tecnología Boost en la suela las lleva al extremo, haciendo de cada paso una delicia.',
    1770.00,
    'img/yeezy_350',
    TRUE,
    11
);

INSERT INTO productos (nombre, descripcion, precio, imagen, activo, id_subcategoria) VALUES (
    'Yeezy 450',
    'Estas zapatillas Yeezy vienen de la mano de Kanye West el cual ha sido el diseñador de estas Sneakers, se aprecia la mano del rapero en estas Adidas las cuales ha sabido llevar a lo mas alto del podium en el mundo del calzado de marca, haciendo de ellas un modelo premium de edición limitada. Pero no solo eso, su tecnología Boost en la suela las lleva al extremo, haciendo de cada paso una delicia.',
    476.00,
    'img/yeezy_450',
    TRUE,
    11
);

INSERT INTO productos (nombre, descripcion, precio, imagen, activo, id_subcategoria) VALUES (
    'Yeezy 500',
    'Estas zapatillas Yeezy vienen de la mano de Kanye West el cual ha sido el diseñador de estas Sneakers, se aprecia la mano del rapero en estas Adidas las cuales ha sabido llevar a lo mas alto del podium en el mundo del calzado de marca, haciendo de ellas un modelo premium de edición limitada. Pero no solo eso, su tecnología Boost en la suela las lleva al extremo, haciendo de cada paso una delicia.',
    464.00,
    'img/yeezy_500',
    TRUE,
    11
);

-- Rarezas
INSERT INTO productos (nombre, descripcion, precio, imagen, activo, id_subcategoria) VALUES (
    'Jordan I Dior',
    'Las nuevas Dior x Air Jordan 1 fusionan la alta costura francesa con las características técnicas y estéticas del calzado deportivo de alto rendimiento, mezclando mundos, ideas y culturas diferentes en una exclusiva zapatilla. El modelo ha sido fabricado en Italia y confeccionado en cuero, con los bordes y los laterales pintados en “Gris Dior”. Sobre este fondo se ha grabado el emblema propio de la firma deportiva, las alas Air Dior en relieve, que se puede encontrar en la parte superior junto con las palabras “AIR DIOR”. Entre sus detalles hay que destacar la suela traslúcida, en la que se aprecia el logo de Dior y el de Air Jordan. Sin olvidar también las etiquetas metálicas colgantes del mítico “Jordan Fly”.',
    20796.00,
    'img/jordan_i_dior',
    TRUE,
    12
);

INSERT INTO productos (nombre, descripcion, precio, imagen, activo, id_subcategoria) VALUES (
    'Air Yeezy',
    'Las Nike Air Yeezy 2 se consideran una de las zapatillas más publicitadas y buscadas de todos los tiempos. Lanzado en tres combinaciones de colores de la asociación de Kanye West con Nike. Diseñado por Nathan VanHook, las Nike Air Yeezy 2 se inspiró en las siluetas clásicas de Nike como: Air Trainer 1, Air Foamposite One y Air Tech Challenge 2.',
    20796.00,
    'img/air_yeezy',
    TRUE,
    12
);

INSERT INTO productos (nombre, descripcion, precio, imagen, activo, id_subcategoria) VALUES (
    'Air Mag',
    'La marca Nike, lanzó al mercado comercial una colección limitada de este tipo de zapatillas, conocidas como las zapatillas de ‘Regreso al Futuro‘ y como las más caras del mundo. Las mismas, se distinguen por tener características especiales, ajustándose de manera automática a la forma del pie. Además, el área de la suela está integrada con luces coloridas que la hacen llamativa a simple vista. Mientras que el talón y las correas que se ubican en la parte superior, son los elementos que convierten a la zapatilla en un artículo futurista. Cabe destacar, que la comodidad es una de las características que siempre va de la mano con Nike.',
    40601.00,
    'img/air_mag',
    TRUE,
    12
);

-- Cinturones
INSERT INTO productos (nombre, descripcion, precio, imagen, activo, id_subcategoria) VALUES (
    'Cinturon Burberry TB',
    'Placa del monograma TB característico, estampado del monograma y reversible. Material de cuero. Hecho en Italia.',
    390.00,
    'img/cinturon_burberry_tb',
    TRUE,
    13
);

INSERT INTO productos (nombre, descripcion, precio, imagen, activo, id_subcategoria) VALUES (
    'Cinturon Prada Classic',
    'Reversible, cierre con hebilla en tono plateado, estampado del logo en la parte delantera y diseño ajustable. Material de cuero.',
    2000.00,
    'img/cinturon_prada_classic',
    TRUE,
    13
);

INSERT INTO productos (nombre, descripcion, precio, imagen, activo, id_subcategoria) VALUES (
    'Cinturon Off-White Classic Industrial',
    'Correa con logo Industrial, motivo del logo en jacquard, cierre con hebilla y diseño ajustable. Por favor, ten en cuenta que este artículo es unisex y se vende en la talla estándar de hombre.',
    195.00,
    'img/cinturon_off_white_classic_industrial',
    TRUE,
    13
);

-- Bandoleras
INSERT INTO productos (nombre, descripcion, precio, imagen, activo, id_subcategoria) VALUES (
    'Bandolera Prada Logo Triangular',
    'Logo triangular, cierre con cremallera en el tope y tirantes cruzados en los hombros. Material de piel de becerro.',
    890.00,
    'img/bandolera_prada_logo_triangular',
    TRUE,
    14
);

INSERT INTO productos (nombre, descripcion, precio, imagen, activo, id_subcategoria) VALUES (
    'Bandolera JW Anderson Cap Nano',
    'Costura en contraste, cierre con cremallera en el tope, correa de hombro ajustable, parche del logo en el interior y acabado en tono plateado. Material de cuero.',
    295.00,
    'img/bandolera_jw_anderson_cap_nano',
    TRUE,
    14
);

INSERT INTO productos (nombre, descripcion, precio, imagen, activo, id_subcategoria) VALUES (
    'Bandolera Gucci Ophidia GG',
    'Bolso de hombro Ophidia GG en lona de Gucci con detalle Web característico de la marca en verde y rojo, detalles en tono dorado con efecto envejecido, correa ajustable para el hombro, cierre con cremallera en la parte de arriba, bolsillo con cremallera en la parte delantera y compartimento interno.',
    780.00,
    'img/bandolera_gucci_ophidia_gg',
    TRUE,
    14
);

-- Bolsos
INSERT INTO productos (nombre, descripcion, precio, imagen, activo, id_subcategoria) VALUES (
    'Bolso de Viaje Bottega Veneta Tejido Intrecciato',
    'Diseño Intrecciato, cierre con cremallera en el tope, bolsillos laterales, compartimento principal, bolsa removible, dos asas redondas en la parte superior y correa ajustable y removible para el hombro. Material de cuero.',
    3950.00,
    'img/bolso_de_viaje_bottega_veneta_tejido_intrecciato',
    TRUE,
    15
);

INSERT INTO productos (nombre, descripcion, precio, imagen, activo, id_subcategoria) VALUES (
    'Bolso Gucci Off The Grind',
    'Estampado GG Supreme, detalle de parche, cierre con cremallera en el contorno y compartimento principal.',
    450.00,
    'img/bolso_gucci_off_the_grind',
    TRUE,
    15
);

INSERT INTO productos (nombre, descripcion, precio, imagen, activo, id_subcategoria) VALUES (
    'Bolso Dolce & Gabanna Piel de Cocodrilo',
    'Efecto de piel de cocodrilo, etiqueta de cuero, cierre con cremallera en el tope, dos asas redondas en la parte superior, correa ajustable y removible para el hombro, bolsillo interno con cremallera y parche del logo en el interior.',
    37500.00,
    'img/bolso_dolce_&_gabanna_piel_de_cocodrilo',
    TRUE,
    15
);

-- Insert de tallas
-- Nike
INSERT INTO tallas_producto (id_producto, talla, stock) VALUES
( 1, '44', 10 ),
( 1, '42', 9 ),
( 1, '40', 7 ),
( 1, '39', 2 ),
( 1, '43', 10 ),
( 2, '44', 8 ),
( 2, '43', 9 ),
( 2, '41', 8 ),
( 2, '42', 10 ),
( 2, '40', 7 ),
( 2, '39', 9 ),
( 3, '44', 2 ),
( 3, '40', 10 ),
( 3, '42', 7 ),
( 4, '43', 2 ),
( 4, '44', 9 ),
( 4, '42', 9 ),
( 4, '39', 3 ),
( 4, '38', 4 ),
( 5, '38', 5 ),
( 5, '42', 4 ),
( 5, '39', 5 ),
( 6, '39', 5 ),
( 6, '41', 6 ),
( 6, '38', 5 ),
( 6, '43', 4 ),
( 6, '44', 9 ),
( 6, '42', 8 ),
( 7, '40', 8 ),
( 7, '39', 2 ),
( 7, '42', 6 ),
( 8, '43', 1 ),
( 8, '40', 2 ),
( 8, '44', 10 ),
( 8, '41', 6 ),
( 8, '38', 7 ),
( 9, '44', 4 ),
( 9, '42', 8 ),
( 9, '41', 7 ),
( 9, '39', 4 );

-- Jordan
INSERT INTO tallas_producto (id_producto, talla, stock) VALUES
( 10, '41', 6 ),
( 10, '44', 5 ),
( 10, '38', 2 ),
( 10, '42', 6 ),
( 11, '42', 3 ),
( 11, '38', 8 ),
( 11, '41', 4 ),
( 12, '43', 3 ),
( 12, '42', 6 ),
( 12, '38', 5 ),
( 12, '44', 9 ),
( 12, '40', 1 ),
( 13, '42', 7 ),
( 13, '41', 7 ),
( 13, '44', 5 ),
( 13, '38', 7 ),
( 13, '40', 8 ),
( 13, '43', 7 ),
( 14, '42', 10 ),
( 14, '43', 10 ),
( 14, '41', 3 ),
( 15, '42', 5 ),
( 15, '40', 7 ),
( 15, '43', 2 ),
( 15, '38', 10 ),
( 15, '41', 4 ),
( 15, '39', 3 ),
( 16, '38', 9 ),
( 16, '42', 2 ),
( 16, '41', 5 ),
( 16, '44', 1 ),
( 17, '41', 4 ),
( 17, '38', 8 ),
( 17, '40', 10 ),
( 18, '39', 6 ),
( 18, '38', 4 ),
( 18, '43', 2 ),
( 18, '41', 3 );

-- Adidas
INSERT INTO tallas_producto (id_producto, talla, stock) VALUES
( 19, '39', 6 ),
( 19, '42', 6 ),
( 19, '43', 4 ),
( 20, '40', 3 ),
( 20, '44', 6 ),
( 20, '39', 3 ),
( 20, '42', 4 ),
( 20, '38', 10 ),
( 20, '41', 6 ),
( 21, '44', 4 ),
( 21, '39', 5 ),
( 21, '43', 3 ),
( 21, '41', 2 ),
( 21, '42', 8 ),
( 21, '40', 4 ),
( 22, '38', 10 ),
( 22, '39', 9 ),
( 22, '41', 5 ),
( 22, '43', 4 ),
( 23, '44', 7 ),
( 23, '42', 10 ),
( 23, '39', 1 ),
( 24, '40', 6 ),
( 24, '43', 7 ),
( 24, '41', 5 ),
( 24, '42', 5 ),
( 24, '44', 2 ),
( 24, '39', 6 ),
( 25, '42', 7 ),
( 25, '43', 2 ),
( 25, '39', 10 ),
( 25, '41', 7 ),
( 26, '43', 1 ),
( 26, '41', 3 ),
( 26, '44', 7 ),
( 26, '38', 8 ),
( 26, '42', 3 ),
( 27, '39', 3 ),
( 27, '41', 1 ),
( 27, '44', 10 ),
( 27, '40', 3 ),
( 27, '38', 5 ),
( 27, '42', 5 );

-- Exclusivo
INSERT INTO tallas_producto (id_producto, talla, stock) VALUES
( 28, '40', 2 ),
( 28, '41', 7 ),
( 28, '42', 1 ),
( 28, '38', 1 ),
( 28, '43', 4 ),
( 29, '38', 3 ),
( 29, '44', 6 ),
( 29, '43', 8 ),
( 29, '42', 9 ),
( 29, '40', 2 ),
( 30, '38', 3 ),
( 30, '42', 1 ),
( 30, '41', 1 ),
( 31, '41', 2 ),
( 31, '38', 2 ),
( 31, '42', 7 ),
( 31, '40', 3 ),
( 32, '44', 9 ),
( 32, '42', 3 ),
( 32, '40', 2 ),
( 33, '40', 2 ),
( 33, '44', 4 ),
( 33, '38', 5 ),
( 34, '42', 8 ),
( 34, '40', 2 ),
( 34, '43', 9 ),
( 34, '38', 2 ),
( 35, '38', 9 ),
( 35, '40', 2 ),
( 35, '42', 1 ),
( 35, '44', 8 ),
( 35, '43', 1 ),
( 35, '41', 10 ),
( 36, '39', 1 ),
( 36, '38', 3 ),
( 36, '41', 3 ),
( 36, '43', 9 ),
( 36, '40', 7 ),
( 36, '42', 5 );

-- Insertar usuario admin 
INSERT INTO usuarios (nombre, email, contraseña, rol)
VALUES (
    'Santiago Guillen Nazareno',
    'guillennazareno@gmail.com',
    'scrypt:32768:8:1$TiDfLE4KSujBCkvK$d15cc9c8c8ec2366533242dcf9fe40266b5b48ad1d288f83ba663dc57c5fff0f10770fa92f8016251b2dd787ee1db895229696e7aa011781445717fdc905614b',
    'admin'
);

-- Insertar el carrito asociado al usuario
INSERT INTO carrito (id_usuario) VALUES (1);

-- Olvidé añadir la extension de las imagenes en la ruta, por lo que no cargaban en la web
UPDATE productos SET imagen = CONCAT(imagen, '.jpg') WHERE imagen NOT LIKE '%.%';

select * from usuarios;