/*
Parte 1: Crear entorno de trabajo
- Crear una base de datos
- Crear un usuario con todos los privilegios para trabajar con la base de datos recién creada.
*/

-- eliminar DB
-- DROP DATABASE db5;

-- crear base de datos
CREATE DATABASE db5;

-- crear usuario con priviligios sobre base de datos telovendo
CREATE USER 'otrousuario'@'localhost' IDENTIFIED BY '123456';
GRANT ALL PRIVILEGES ON db5.* TO 'otrousuario'@'localhost';
FLUSH PRIVILEGES;

-- seleccionar  base de datos
USE db5;

/*
Parte 2: Crear tres tablas.
*/
/*
- La primera almacena a los usuarios de la aplicación (id_usuario, nombre, apellido, contraseña, zona horaria
(por defecto UTC-3), género y teléfono de contacto).
*/
CREATE TABLE db5.usuario (
  id_usuario MEDIUMINT UNSIGNED PRIMARY KEY AUTO_INCREMENT, -- entero autoincrementable que funciona como clave primaria. Ver detalle en (Parte 5: Justifique cada tipo de dato utilizado)
  nombre VARCHAR(50) NOT NULL, -- esto debe ser un varchar de longituf variable con máximo 50 caracteres. (J01)
  apellido VARCHAR(50) NOT NULL, -- misma justificación (J01)
  contrasena VARCHAR(20) NOT NULL, -- misma justificación (J01) pero no requiere un largo tan grande (J02)
  zona_horaria VARCHAR(10) DEFAULT 'UTC-3', -- misma justificación (J02)
  genero VARCHAR(20), -- podria usar el bit para representar masculino 0 o femenino 1, pero como actualmente hay tantos generos mejor indicar el nombre 
  telefono_contacto BIGINT UNSIGNED -- ver detalle en (Parte 5: Justifique cada tipo de dato utilizado)
);


/*- La segunda tabla almacena información relacionada a la fecha-hora de ingreso de los usuarios a la
plataforma (id_ingreso, id_usuario y la fecha-hora de ingreso (por defecto la fecha-hora actual)).
*/
CREATE TABLE db5.registro_ingreso (
  id_ingreso MEDIUMINT UNSIGNED PRIMARY KEY AUTO_INCREMENT, -- entero autoincrementable que funciona como clave primaria.  ver detalle en (Parte 5: Justifique cada tipo de dato utilizado)
  id_usuario MEDIUMINT UNSIGNED, --  ver detalle en (Parte 5: Justifique cada tipo de dato utilizado)
  fecha_hora_ingreso DATETIME DEFAULT CURRENT_TIMESTAMP, -- campo de tipo DATETIME que almacena la fecha y hora de ingreso del usuario
  FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE -- indicamos la referencia de la clave foranea de esta tabla
);

/*ESTO NO LO PIDEN PERO LA DEJO IGUAL por si la necesitará má adelante
*/
CREATE TABLE db5.visitas_usuario (
  id_visita MEDIUMINT UNSIGNED PRIMARY KEY AUTO_INCREMENT, --  ver detalle en (Parte 5: Justifique cada tipo de dato utilizado)
  id_usuario MEDIUMINT UNSIGNED UNIQUE, -- esto es unico en la tabla.  Ver detalle en (Parte 5: Justifique cada tipo de dato utilizado)
  cantidad_visitas INT, -- esto seria la suma de registro_ingreso por usuario
  FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE -- indicamos la referencia de la clave foranea de esta tabla
);


-- Comentario: la cantidad de visitas se podria calcular como la sumataria de fecha_hora_ingreso distintas para cada id_usuario de la tabla "registro_ingreso"
USE db5;
DELIMITER $$
CREATE TRIGGER actualizar_visitas
AFTER INSERT ON registro_ingreso
FOR EACH ROW
BEGIN
    -- Verificar si el id_usuario ya existe en la tabla visitas_usuario
    IF EXISTS (SELECT 1 FROM visitas_usuario WHERE id_usuario = NEW.id_usuario) THEN
        -- Actualizar la cantidad de visitas del usuario en la tabla visitas_usuario
        UPDATE visitas_usuario
        SET cantidad_visitas = cantidad_visitas + 1
        WHERE id_usuario = NEW.id_usuario;
    ELSE
        -- Insertar el nuevo registro en la tabla visitas_usuario
        INSERT INTO visitas_usuario (id_usuario, cantidad_visitas)
        VALUES (NEW.id_usuario, 1);
    END IF;
END$$
DELIMITER ;
SHOW TRIGGERS;

DESCRIBE db5.usuario;
DESCRIBE db5.registro_ingreso;
DESCRIBE db5.visitas_usuario;

TRUNCATE db5.registro_ingreso;
TRUNCATE db5.visitas_usuario;
TRUNCATE db5.usuario;

SELECT * FROM db5.usuario;
SELECT * FROM db5.registro_ingreso;
SELECT * FROM db5.visitas_usuario;

USE db5;
SHOW TABLES;

/*
Parte 3: Modificación de la tabla
Modifique el UTC por defecto.Desde UTC-3 a UTC-2.
*/
ALTER TABLE db5.usuario MODIFY zona_horaria VARCHAR(10) DEFAULT 'UTC-2';


/*
Parte 4: Creación de registros.
- Para cada tabla crea 8 registros.
*/
INSERT INTO db5.usuario (nombre, apellido, contrasena, zona_horaria, genero, telefono_contacto)
VALUES
  ('Juan', 'Pérez', 'pass123', 'UTC-3', 'Masculino', '1234567890'),
  ('María', 'González', 'abc456', 'UTC-3', 'Femenino', '9876543210'),
  ('Pedro', 'López', 'qwerty', 'UTC-3', 'Masculino', '5555555555'),
  ('Ana', 'Sánchez', 'password', 'UTC-3', 'Femenino', '7777777777'),
  ('Carlos', 'Rodríguez', '123abc', 'UTC-3', 'Masculino', '9999999999'),
  ('Laura', 'Fernández', 'xyz789', 'UTC-3', 'Femenino', '4444444444'),
  ('Roberto', 'Martínez', 'pass456', 'UTC-3', 'Masculino', '2222222222'),
  ('Sofía', 'López', 'abc123', 'UTC-3', 'Femenino', '8888888888');

INSERT INTO db5.registro_ingreso (id_usuario)
VALUES
  (1),
  (2),
  (3),
  (4),
  (5),
  (6),
  (7),
  (8);
  
-- db5.visitas_usuario (id_usuario) se realiza con el trigger 

/*
Parte 5: Justifique cada tipo de dato utilizado. ¿Es el óptimo en cada caso?
*/

/* 
- En el individual tenia los id como INT que utiliza 4 bytes y tiene rango de -2147483648 a 2147483647, pero en realidad este número puede ser muy grande además 
 que no usamos los negativo, entonces podriamos usar un MEDIUMINT UNSIGNED, entero sin signo de 3 bytes. con esto optimizamos almacenamiento.
 
 - telefono eventualmente podría ser un BIGINT UNSIGNED tamaño 8 bytes y un número tan grande como 18446744073709551615  ... más que suficiente por el 
 momento, a diferencia de almacenar un varchar(20) donde en general vamos a usar 12 caracteres, es decir un tamaño promedio 12 caracteres * 4 bytes/caracter = 48 bytes
 considerablemente mayor al BIGINT UNSIGNED.
 
 - Otros comentarios adicionales se indica junto a cada campo 
 
 */


/*
Parte 6: Creen una nueva tabla llamada Contactos (id_contacto, id_usuario, número de teléfono,
correo electrónico).
*/
CREATE TABLE contacto (
  id_contacto MEDIUMINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  id_usuario MEDIUMINT UNSIGNED,
  numero_telefono BIGINT UNSIGNED,
  correo_electronico VARCHAR(50)
);

/*
Parte 7: Modifique la columna teléfono de contacto, para crear un vínculo entre la tabla Usuarios y la
tabla Contactos.
*/
ALTER TABLE db5.contacto
ADD FOREIGN KEY (id_usuario) REFERENCES db5.usuario(id_usuario);

DESCRIBE db5.contacto;

-- 	COMENTARIO FINAL: suelo preceder los nombres de las tablas con su BD pues a veces se me olvida ejecutar el USE Database;

