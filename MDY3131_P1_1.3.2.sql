------------------------------------------------------------------------------------------------------
--                        Jorge Sandoval - MDY3131_002V - Programación de Base de Datos
----------------------------------------------- Caso 1 -----------------------------------------------
SET SERVEROUTPUT ON

VARIABLE b_run_cliente NUMBER
VARIABLE b_pesos_normales NUMBER
VARIABLE b_rango_menor NUMBER;
VARIABLE b_rango_mayor NUMBER;
VARIABLE b_pesos_extras_bajo NUMBER;
VARIABLE b_pesos_extras_medio NUMBER;
VARIABLE b_pesos_extras_alto NUMBER;

EXEC :b_run_cliente:=&run_cliente;
EXEC :b_rango_menor:=&rango_credito_menor;
EXEC :b_rango_mayor:=&rango_credito_mayor;
EXEC :b_pesos_normales:=&monto_pesos_normales;
EXEC :b_pesos_extras_bajo:=&monto_pesos_extras_rango_bajo;
EXEC :b_pesos_extras_medio:=&monto_pesos_extras_rango_medio;
EXEC :b_pesos_extras_alto:=&monto_pesos_extras_rango_alto;

DECLARE
v_nro_cliente NUMBER;
v_num_run_cli VARCHAR2(25);
v_nombre_cliente VARCHAR2(80);
v_tipo_cliente VARCHAR2(50);
v_monto_solic_creditos NUMBER;
v_monto_pesos_tdsm NUMBER;
v_registro_actualizado VARCHAR2(200);

BEGIN
    SELECT
        c.nro_cliente,
        TO_CHAR(c.numrun,'999G999G999')||'-'||c.dvrun,
        UPPER(c.pnombre ||' '|| c.snombre ||' '|| c.appaterno ||' '|| c.apmaterno),
        tpc.nombre_tipo_cliente,
        SUM(cc.monto_solicitado)
    INTO
        v_nro_cliente,
        v_num_run_cli,
        v_nombre_cliente,
        v_tipo_cliente,
        v_monto_solic_creditos
    FROM
        cliente c INNER JOIN tipo_cliente tpc ON (c.cod_tipo_cliente=tpc.cod_tipo_cliente)
        INNER JOIN credito_cliente cc ON (cc.nro_cliente=c.nro_cliente)
    WHERE
        c.numrun = :b_run_cliente AND
        EXTRACT(YEAR FROM cc.fecha_otorga_cred) = (EXTRACT(YEAR FROM SYSDATE) -1)
    GROUP BY
        c.nro_cliente,
        TO_CHAR(c.numrun,'999G999G999')||'-'||c.dvrun,
        UPPER(c.pnombre ||' '|| c.snombre ||' '|| c.appaterno ||' '|| c.apmaterno),
        tpc.nombre_tipo_cliente;
    
    IF v_tipo_cliente = 'Trabajadores independientes' THEN
        CASE 
            WHEN v_monto_solic_creditos < :b_rango_menor THEN
                v_monto_pesos_tdsm:= (TRUNC(v_monto_solic_creditos/100000) * :b_pesos_normales) + (TRUNC(v_monto_solic_creditos/100000) * :b_pesos_extras_bajo);
            WHEN v_monto_solic_creditos BETWEEN :b_rango_menor AND :b_rango_mayor THEN
                v_monto_pesos_tdsm:=(TRUNC(v_monto_solic_creditos/100000) * :b_pesos_normales)  + (TRUNC(v_monto_solic_creditos/100000) * :b_pesos_extras_medio);
            WHEN v_monto_solic_creditos > :b_rango_mayor THEN
                v_monto_pesos_tdsm:=(TRUNC(v_monto_solic_creditos/100000) * :b_pesos_normales)  + (TRUNC(v_monto_solic_creditos/100000) * :b_pesos_extras_alto);
            END CASE;
    ELSE
        v_monto_pesos_tdsm:= TRUNC(v_monto_solic_creditos/100000) * :b_pesos_normales;
    END IF;
        
    INSERT INTO
        CLIENTE_TODOSUMA
    VALUES
        (v_nro_cliente,v_num_run_cli,v_nombre_cliente,v_tipo_cliente,v_monto_solic_creditos,v_monto_pesos_tdsm);
    
    --Consulta cuantas filas han sido insertadas
    v_registro_actualizado:=(SQL%ROWCOUNT||' fila(s) Insertada(s) correctamente en tabla CLIENTE_TODOSUMA.');
    --Imprime en pantalla la confirmación
    DBMS_OUTPUT.PUT_LINE(v_registro_actualizado);
       
END;

SELECT * FROM CLIENTE_TODOSUMA; --Sentencias utilizadas para corroborar cargas.
--TRUNCATE TABLE CLIENTE_TODOSUMA; --Sentencias utilizadas para corroborar cargas.
--DELETE FROM CLIENTE_TODOSUMA WHERE NRO_cliente = 34;