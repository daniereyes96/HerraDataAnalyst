--PRIMERA TABLA POLIZAS RIESGOS ENDOSOS
CREATE TABLE sbecosistemaanaliticolago_SB_t_polizas_riesgos_endosos (
    CODIGO_RAMO_CONTABLE VARCHAR(10),
    CODIGO_PRODUCTO VARCHAR(10),
    NUMERO_POLIZA VARCHAR(10),
    KEY_ID_ASEGURADO VARCHAR(50),
	NOMBRE_POLIZA VARCHAR(15),
    VALOR_ASEGURADO_RETENIDO REAL,
    VALOR_ASEGURADO_CEDIDO REAL,
  	FECHA_INICIO_POLIZA DATE,
  	FECHA_FIN_POLIZA DATE,
    PRIMARY KEY (KEY_ID_ASEGURADO));


INSERT INTO sbecosistemaanaliticolago_SB_t_polizas_riesgos_endosos (CODIGO_RAMO_CONTABLE,
																	CODIGO_PRODUCTO,
																	NUMERO_POLIZA,
																	KEY_ID_ASEGURADO,
																	NOMBRE_POLIZA,
																	VALOR_ASEGURADO_RETENIDO,
																	VALOR_ASEGURADO_CEDIDO,
  																	FECHA_INICIO_POLIZA,
  																	FECHA_FIN_POLIZA)

VALUES (20,758,121355,'A32B','Bienestar',1800000,1290000,'2022-05-30','2022-07-30'),
       (18,540,1213114,'A30B','Bienestar',1600000,1270000,'2022-05-30','2022-07-30'),
	   (26,758,1213123,'A29B','Bienestar',1500000,1260000,'2022-05-30','2022-07-30'),
	   (18,541,121315,'A24B','Bienestar',1000000,1210000,'2022-05-30','2022-07-30'),
	   (19,715,121316,'A79B','Bienestar',1100000,1220000,'2022-05-30','2022-07-30'),
       (24,727,121317,'A26B','Bienestar',1200000,1230000,'2022-05-30','2022-07-30'),
	   (20,712,121318,'A27B','Bienestar',1300000,1240000,'2022-05-30','2022-07-30'),
	   (25,737,121319,'A28B','Bienestar',1400000,1250000,'2022-05-30','2022-07-30'),
	   (26,758,125318,'A11B','Bienestar',1300000,1240000,'2022-05-30','2022-07-30'),
	   (24,500,124319,'A14B','Bienestar',1450000,1256000,'2022-05-30','2022-07-30');



SELECT * FROM sbecosistemaanaliticolago_SB_t_polizas_riesgos_endosos


--SEGUNDA TABLA CLIENTES

CREATE TABLE sbecosistemaanaliticolago_SB_t_contabilidad_clientes (
    NOMBRE_CLIENTE VARCHAR(30),
    SEXO VARCHAR(10),
    FECHA_NACIMIENTO DATE,
    MUNICIPIO VARCHAR(50),
	KEY_ID VARCHAR(20),
    PRIMARY KEY (KEY_ID));
    
SELECT * FROM sbecosistemaanaliticolago_SB_t_contabilidad_clientes

INSERT INTO sbecosistemaanaliticolago_SB_t_contabilidad_clientes (NOMBRE_CLIENTE ,
    															  SEXO,
    															  FECHA_NACIMIENTO,
   																  MUNICIPIO,
														      KEY_ID)

VALUES ('DANIEL ROA','MASCULINO','1989-12-30','Bogotá','A32B'),
	   ('JUAN ROA','MASCULINO','1980-11-28','Bogotá','A24B'),
       ('LAURA MARIA','FEMENINO','1979-08-07','Bogotá','A26B'),
       ('CAROLINA GOMEZ','FEMENINO','1996-10-23','Bogotá','A14B'),
       ('NICOLAS MORALES','MASCULINO','1978-03-13','Bogotá','A37B'),
       ('PEDRO GOMEZ','MASCULINO','1969-05-24','Bogotá','A11B'),
       ('PEPE GARCIA','MASCULINO','1989-10-24','Bogotá','A28B'),
       ('PAOLA PUERTAS','FEMENINO','1999-10-24','Bogotá','A40B'),
       ('ANDREA TORRES','FEMENINO','1991-12-12','Bogotá','A25B'),
       ('CAMILO CASTAÑEDA','MASCULINO','1985-07-15','Bogotá','A29B'),
       ('LAURA FLORIAN','FEMENINO','1997-05-10','Bogotá','A27B'),
       ('RAUL DUARTE','MASCULINO','1995-07-15','Bogotá','A30B'),
       ('MARIO ROA','MASCULINO','1987-11-01','Bogotá','A79B');
       
SELECT * FROM sbecosistemaanaliticolago_SB_t_contabilidad_clientes