START TRANSACTION;
-- -----------------------------------------------------
-- Table VIVEROS
-- -----------------------------------------------------
DROP TABLE IF EXISTS VIVEROS ;

CREATE TABLE IF NOT EXISTS VIVEROS (
  NOMBRE VARCHAR(40) NOT NULL UNIQUE,
  LOCALIDAD VARCHAR(45) NULL,
  LATITUD VARCHAR(45) NOT NULL,
  LONGITUD VARCHAR(45) NOT NULL,
  PRIMARY KEY (NOMBRE, LATITUD, LONGITUD))
;


-- -----------------------------------------------------
-- Table ZONA
-- -----------------------------------------------------
DROP TABLE IF EXISTS ZONA ;

CREATE TABLE IF NOT EXISTS ZONA (
  NOMBRE VARCHAR(40) NOT NULL,
  TIPO VARCHAR(45) NULL,
  VIVEROS_NOMBRE VARCHAR(40) NOT NULL,
  PRIMARY KEY (NOMBRE, VIVEROS_NOMBRE),
  CONSTRAINT fk_ZONA_VIVEROS
    FOREIGN KEY (VIVEROS_NOMBRE)
    REFERENCES VIVEROS (NOMBRE)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
;


-- -----------------------------------------------------
-- Table PRODUCTOS
-- -----------------------------------------------------
DROP TABLE IF EXISTS PRODUCTOS ;

CREATE TABLE IF NOT EXISTS PRODUCTOS (
  IDPRODUCTOS INT NOT NULL,
  NOMBRE VARCHAR(45) NOT NULL,
  STOCK INT NULL,
  PRECIO VARCHAR(45) NULL,
  PRIMARY KEY (IDPRODUCTOS))
;


-- -----------------------------------------------------
-- Table UBICA
-- -----------------------------------------------------
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
    ON UPDATE NO ACTION)
;


-- -----------------------------------------------------
-- Table EMPLEADO
-- -----------------------------------------------------
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
    ON UPDATE CASCADE)
;


-- -----------------------------------------------------
-- Table CLIENTE
-- -----------------------------------------------------
DROP TABLE IF EXISTS CLIENTE ;

CREATE TABLE IF NOT EXISTS CLIENTE (
  DNI VARCHAR(9) NOT NULL,
  BONIFICACION VARCHAR(45) NULL,
  TOTAL_MENSUAL VARCHAR(45) NULL,
  PRIMARY KEY (DNI))
;

-- -----------------------------------------------------
-- Table COMPRA
-- -----------------------------------------------------
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
    ON UPDATE CASCADE)
;

COMMIT;


-- -----------------------------------------------------
-- Data for table VIVEROS
-- -----------------------------------------------------
START TRANSACTION;
INSERT INTO VIVEROS (NOMBRE, LOCALIDAD, LATITUD, LONGITUD) VALUES ('Flores Pepe', 'La Laguna', '026', '014');

COMMIT;


-- -----------------------------------------------------
-- Data for table ZONA
-- -----------------------------------------------------
START TRANSACTION;
INSERT INTO ZONA (NOMBRE, TIPO, VIVEROS_NOMBRE) VALUES ('Rodeos', 'Exterior', 'Flores Pepe');

COMMIT;

-- -----------------------------------------------------
-- Data for table PRODUCTOS
-- -----------------------------------------------------
START TRANSACTION;
INSERT INTO PRODUCTOS(IDPRODUCTOS, NOMBRE, STOCK, PRECIO) VALUES (12345678, 'Cafe Caracol', 20, '2.5');

COMMIT;

-- -----------------------------------------------------
-- Data for table UBICA
-- -----------------------------------------------------
START TRANSACTION;
INSERT INTO UBICA(ZONA_NOMBRE, ZONA_VIVEROS_NOMBRE, PRODUCTOS_IDPRODUCTOS, STOCK_ZONA) VALUES ('Rodeos', 'Flores Pepe', 12345678, 20);

COMMIT;

-- -----------------------------------------------------
-- Data for table CLIENTE
-- -----------------------------------------------------
START TRANSACTION;
INSERT INTO CLIENTE(DNI, BONIFICACION, TOTAL_MENSUAL) VALUES ('78451296', '100', '250');

COMMIT;

-- -----------------------------------------------------
-- Data for table EMPLEADO
-- -----------------------------------------------------
START TRANSACTION;
INSERT INTO EMPLEADO(DNI, SUELDO, ANTIGÜEDAD, CSS, FECHA_INI, FECHA_FIN, VENTAS, ZONA_NOMBRE, ZONA_VIVEROS_NOMBRE) VALUES ('42587898', '1000', '10', '24534', '2000-08-10', '2021-11-02', '1500', 'Rodeos', 'Flores Pepe');

COMMIT;

-- -----------------------------------------------------
-- Data for table COMPRA
-- -----------------------------------------------------
START TRANSACTION;
INSERT INTO COMPRA(PRODUCTOS_IDPRODUCTOS, CLIENTE_DNI, EMPLEADO_DNI, CANTIDAD, FECHA) VALUES (12345678, '78451296', '42587898', 1, '2021-05-20 10:05:45');

COMMIT;