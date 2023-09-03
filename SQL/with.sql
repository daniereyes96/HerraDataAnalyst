WITH Riesgos_Endosos AS (
    SELECT
        CODIGO_RAMO_CONTABLE,
        CODIGO_PRODUCTO,
        NUMERO_POLIZA,
        NOMBRE_POLIZA,
        KEY_ID_ASEGURADO,
        FECHA_INICIO_POLIZA,
        FECHA_FIN_POLIZA,
        VALOR_ASEGURADO_RETENIDO AS VALOR_ASEGURADO,
        VALOR_ASEGURADO_CEDIDO AS VALOR_CEDIDO
    FROM SB_t_polizas_riesgos_endosos
    WHERE
        CODIGO_RAMO_CONTABLE IN (18, 20, 24, 25, 26)
        AND FECHA_INICIO_POLIZA <= '2022-06-31 00:00:00'
        AND FECHA_FIN_POLIZA >= '2022-06-31 00:00:00'
),

RE_Tot AS (
    SELECT
        Riesgos_Endosos.*,
        SB_t_contabilidad_clientes.NOMBRE_CLIENTE,
        SB_t_contabilidad_clientes.SEXO,
        SB_t_contabilidad_clientes.FECHA_NACIMIENTO,
        SB_t_contabilidad_clientes.municipio
    FROM Riesgos_Endosos
    LEFT JOIN SB_t_contabilidad_clientes ON Riesgos_Endosos.KEY_ID_ASEGURADO = SB_t_contabilidad_clientes.KEY_ID
),

Bien AS (
    SELECT RE_Tot.*
    FROM RE_Tot
    WHERE
        CODIGO_RAMO_CONTABLE IN (18, 20, 24, 25, 26)
        AND CODIGO_PRODUCTO IN (540, 541, 715, 716, 736, 744, 764, 753, 12, 21, 758, 765, 712, 727, 500, 737, 757, 758)
),

Bien_1 AS (
    SELECT
        NUMERO_POLIZA,
        KEY_ID_ASEGURADO,
        CODIGO_RAMO_CONTABLE,
        CODIGO_PRODUCTO,
        FECHA_INICIO_POLIZA,
        FECHA_FIN_POLIZA,
        SUM(VALOR_ASEGURADO) AS VT,
        SUM(VALOR_CEDIDO) AS VC,
        SEXO,
        FECHA_NACIMIENTO,
        MUNICIPIO
    FROM Bien
    GROUP BY
        NUMERO_POLIZA,
        KEY_ID_ASEGURADO,
        CODIGO_RAMO_CONTABLE,
        CODIGO_PRODUCTO
),

Bien_2 AS (
    SELECT
        Bien_1.*,
        CASE WHEN VT > 0 THEN 'si' ELSE 'NO' END AS ACTIVO
    FROM Bien_1
),

Bien_3 AS (
    SELECT
        NUMERO_POLIZA,
        KEY_ID_ASEGURADO,
        CODIGO_RAMO_CONTABLE,
        CODIGO_PRODUCTO,
        VT,
        VC,
        ACTIVO,
        SEXO,
        FECHA_NACIMIENTO,
        MUNICIPIO
    FROM Bien_2
)

SELECT * FROM Bien_3;
