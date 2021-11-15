START TRANSACTION;

DROP SCHEMA public CASCADE;

CREATE SCHEMA public;

DROP TABLE IF EXISTS VIVEROS ;

CREATE TABLE IF NOT EXISTS VIVEROS (
  NOMBRE VARCHAR(40) NOT NULL UNIQUE,
  LOCALIDAD VARCHAR(45) NULL,
  LATITUD VARCHAR(45) NOT NULL,
  LONGITUD VARCHAR(45) NOT NULL,
  PRIMARY KEY (NOMBRE, LATITUD, LONGITUD));

DROP TABLE IF EXISTS ZONA;

CREATE TABLE IF NOT EXISTS ZONA (
  NOMBRE VARCHAR(40) NOT NULL,
  TIPO VARCHAR(45) NULL,
  VIVEROS_NOMBRE VARCHAR(40) NOT NULL,
  PRIMARY KEY (NOMBRE, VIVEROS_NOMBRE),
  CONSTRAINT fk_ZONA_VIVEROS
    FOREIGN KEY (VIVEROS_NOMBRE)
    REFERENCES VIVEROS (NOMBRE)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);

DROP TABLE IF EXISTS PRODUCTOS ;

CREATE TABLE IF NOT EXISTS PRODUCTOS (
  IDPRODUCTOS INT NOT NULL,
  NOMBRE VARCHAR(45) NOT NULL,
  STOCK INT NULL,
  PRECIO VARCHAR(45) NULL,
  PRIMARY KEY (IDPRODUCTOS));

DROP TABLE IF EXISTS UBICA ;

CREATE TABLE IF NOT EXISTS UBICA (
  ZONA_NOMBRE VARCHAR(40) NOT NULL,
  ZONA_VIVEROS_NOMBRE VARCHAR(40) NOT NULL,
  PRODUCTOS_IDPRODUCTOS INT NOT NULL,
  STOCK_ZONA INT NULL,
  PRIMARY KEY (ZONA_NOMBRE, ZONA_VIVEROS_NOMBRE, PRODUCTOS_IDPRODUCTOS),
  CONSTRAINT fk_ZONA_has_PRODUCTOS_ZONA1
    FOREIGN KEY (ZONA_NOMBRE , ZONA_VIVEROS_NOMBRE)
    REFERENCES ZONA (NOMBRE , VIVEROS_NOMBRE)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_ZONA_has_PRODUCTOS_PRODUCTOS1
    FOREIGN KEY (PRODUCTOS_IDPRODUCTOS)
    REFERENCES PRODUCTOS (IDPRODUCTOS)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);

DROP TABLE IF EXISTS EMPLEADO ;

CREATE TABLE IF NOT EXISTS EMPLEADO (
  DNI VARCHAR(9) NOT NULL,
  SUELDO VARCHAR(45) NULL,
  ANTIGÜEDAD VARCHAR(45) NULL,
  CSS VARCHAR(45) NULL,
  FECHA_INI DATE NULL,
  FECHA_FIN DATE NULL,
  VENTAS VARCHAR(45) NULL,
  ZONA_NOMBRE VARCHAR(40) NOT NULL,
  ZONA_VIVEROS_NOMBRE VARCHAR(40) NOT NULL,
  PRIMARY KEY (DNI),
  CONSTRAINT fk_EMPLEADO_ZONA1
    FOREIGN KEY (ZONA_NOMBRE , ZONA_VIVEROS_NOMBRE)
    REFERENCES ZONA (NOMBRE , VIVEROS_NOMBRE)
    ON DELETE CASCADE
    ON UPDATE CASCADE);

DROP TABLE IF EXISTS CLIENTE;

CREATE TABLE IF NOT EXISTS CLIENTE (
  DNI VARCHAR(9) NOT NULL,
  NOMBRE VARCHAR(30) NOT NULL,
  APELLIDOS VARCHAR(50) NOT NULL,
  BONIFICACION VARCHAR(45) NULL,
  TOTAL_MENSUAL VARCHAR(45) NULL,
  EMAIL VARCHAR(30),
  PRIMARY KEY (DNI));

DROP TABLE IF EXISTS COMPRA ;

CREATE TABLE IF NOT EXISTS COMPRA (
  PRODUCTOS_IDPRODUCTOS INT NULL,
  CLIENTE_DNI VARCHAR(9) NULL,
  EMPLEADO_DNI VARCHAR(9) NOT NULL,
  CANTIDAD INT NULL,
  FECHA TIMESTAMP NOT NULL,
  PRIMARY KEY (FECHA),
  CONSTRAINT fk_PRODUCTOS_has_CLIENTE_PRODUCTOS1
    FOREIGN KEY (PRODUCTOS_IDPRODUCTOS)
    REFERENCES PRODUCTOS (IDPRODUCTOS)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT fk_PRODUCTOS_has_CLIENTE_CLIENTE1
    FOREIGN KEY (CLIENTE_DNI)
    REFERENCES CLIENTE (DNI)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT fk_COMPRA_EMPLEADO1
    FOREIGN KEY (EMPLEADO_DNI)
    REFERENCES EMPLEADO (DNI)
    ON DELETE CASCADE
    ON UPDATE CASCADE);

DROP TABLE IF EXISTS DOMICILIO;

CREATE TABLE IF NOT EXISTS DOMICILIO (
  CLIENTE_DNI VARCHAR(40) NOT NULL,
  MUNICIPIO VARCHAR(45) NOT NULL,
  DIRECCION VARCHAR(40) NOT NULL,
  PRIMARY KEY (CLIENTE_DNI, MUNICIPIO, DIRECCION),
  CONSTRAINT fk_DOMICILIO_CLIENTE
    FOREIGN KEY (CLIENTE_DNI)
    REFERENCES CLIENTE (DNI)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);
    
COMMIT;

CREATE OR REPLACE FUNCTION crear_email() RETURNS TRIGGER AS $crear_email$
   BEGIN
      IF NEW.EMAIL IS NULL THEN
        NEW.EMAIL := CONCAT(lower(NEW.NOMBRE), REGEXP_REPLACE(lower(NEW.APELLIDOS), '\s+', ''), '@', TG_ARGV[0]);
      
      ELSIF NEW.EMAIL LIKE '/^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$/g' THEN
        RAISE EXCEPTION 'El email introducido no es valido, la estructura del email deberia ser "example@domain.com"';
      END IF;
      RETURN NEW;
   END;
$crear_email$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_crear_email_before_insert BEFORE INSERT ON CLIENTE
FOR EACH ROW EXECUTE PROCEDURE crear_email("gmail.com");

CREATE OR REPLACE FUNCTION check_viviendas() RETURNS TRIGGER AS $check_viviendas$
	BEGIN 
		IF NEW.municipio IS NULL THEN RAISE EXCEPTION 'Municipio vacío';
		END IF;
		IF NEW.direccion IS NULL THEN RAISE EXCEPTION 'Vivienda vacía';
		END IF;
		IF NEW.municipio IN (SELECT d.municipio
					FROM DOMICILIO d
					WHERE d.cliente_dni = NEW.cliente_dni) THEN
					RAISE EXCEPTION 'No puede tener dos viviendas en el mismo municipio';
		END IF;
		RETURN NEW;
		END;
$check_viviendas$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_check_viviendas_before_insert BEFORE INSERT OR UPDATE ON DOMICILIO FOR EACH ROW EXECUTE PROCEDURE check_viviendas();

CREATE OR REPLACE FUNCTION actualizar_stock() RETURNS TRIGGER AS $actualizar_stock$
	BEGIN
		IF (NEW.cantidad > 0) THEN
			UPDATE PRODUCTOS SET stock = stock - NEW.cantidad
  			WHERE idProductos = NEW.productos_idProductos;
		END IF;
		RETURN NEW;
	END;
$actualizar_stock$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_actualizar_stock BEFORE INSERT ON COMPRA
FOR EACH ROW EXECUTE PROCEDURE actualizar_stock();

START TRANSACTION;
INSERT INTO VIVEROS (NOMBRE, LOCALIDAD, LATITUD, LONGITUD) VALUES ('Flores Pepe', 'La Laguna', '026', '014');

COMMIT;

START TRANSACTION;
INSERT INTO ZONA (NOMBRE, TIPO, VIVEROS_NOMBRE) VALUES ('Rodeos', 'Exterior', 'Flores Pepe');

COMMIT;

START TRANSACTION;
INSERT INTO PRODUCTOS(IDPRODUCTOS, NOMBRE, STOCK, PRECIO) VALUES (12345678, 'Cafe Caracol', 20, '2.5');

COMMIT;

START TRANSACTION;
INSERT INTO UBICA(ZONA_NOMBRE, ZONA_VIVEROS_NOMBRE, PRODUCTOS_IDPRODUCTOS, STOCK_ZONA) VALUES ('Rodeos', 'Flores Pepe', 12345678, 20);

COMMIT;

START TRANSACTION;
INSERT INTO CLIENTE(DNI, NOMBRE, APELLIDOS, BONIFICACION, TOTAL_MENSUAL, EMAIL) VALUES ('78451296P', 'Pedro', 'Armas Rodriguez','250', '100', 'pedro@gmail.com');

COMMIT;

START TRANSACTION;
INSERT INTO EMPLEADO(DNI, SUELDO, ANTIGÜEDAD, CSS, FECHA_INI, FECHA_FIN, VENTAS, ZONA_NOMBRE, ZONA_VIVEROS_NOMBRE) VALUES ('42587898', '1000', '10', '24534', '2000-08-10', '2021-11-02', '1500', 'Rodeos', 'Flores Pepe');

COMMIT;

START TRANSACTION;
INSERT INTO COMPRA(PRODUCTOS_IDPRODUCTOS, CLIENTE_DNI, EMPLEADO_DNI, CANTIDAD, FECHA) VALUES (12345678, '78451296P', '42587898', 1, '2021-05-20 10:05:45');

COMMIT;

START TRANSACTION;
INSERT INTO DOMICILIO(CLIENTE_DNI, MUNICIPIO, DIRECCION) VALUES ('78451296P', 'La Laguna' , 'Calle 13');

COMMIT;
