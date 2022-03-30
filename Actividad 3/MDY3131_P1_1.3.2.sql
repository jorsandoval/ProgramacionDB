/*------------------------------------------------------------------------------------------------------
--                        Jorge Sandoval - MDY3131_002V - Programación de Base de Datos
--                                            Guia 1.3.2
----------------------------------------------- Caso 1 -----------------------------------------------*/
SET SERVEROUTPUT ON

--Declaración de Variables Globales Bind.

VARIABLE b_run_cliente NUMBER --Variable global bind que guardará el run de cliente ingresado de forma parametrica.
VARIABLE b_pesos_normales NUMBER --Variable global bind que guardará el valor de pesos normales por cada $100.000 (1200).
VARIABLE b_rango_menor NUMBER; --Variable global bind que guardará el monto menor de creditos solicitado según tabla de criterio por pesos extras (1000000).
VARIABLE b_rango_mayor NUMBER; --Variable global bind que guardará el monto mayor de creditos solicitado según tabla de criterio por pesos extras (3000000).
VARIABLE b_pesos_extras_bajo NUMBER; --Variable global bind que guardará la cantidad de pesos extras al rango menor, según tabla de criterios (100).
VARIABLE b_pesos_extras_medio NUMBER; --Variable global bind que guardará la cantidad de pesos extras al rango menor, según tabla de criterios (300).
VARIABLE b_pesos_extras_alto NUMBER; --Variable global bind que guardará la cantidad de pesos extras al rango menor, según tabla de criterios (550).

--Asignación de valores a variables bind de forma parametrica.

EXEC :b_run_cliente:=&run_cliente;
EXEC :b_rango_menor:=&rango_credito_menor;
EXEC :b_rango_mayor:=&rango_credito_mayor;
EXEC :b_pesos_normales:=&monto_pesos_normales;
EXEC :b_pesos_extras_bajo:=&monto_pesos_extras_rango_bajo;
EXEC :b_pesos_extras_medio:=&monto_pesos_extras_rango_medio;
EXEC :b_pesos_extras_alto:=&monto_pesos_extras_rango_alto;

--Declaración de variables locales para el bloque anonimo PL/SQL.

DECLARE
v_nro_cliente NUMBER; -- Variable local que guardará el N° de cliente.
v_num_run_cli VARCHAR2(25); -- Variable local que guardará el run de cliente con formato solicictado.
v_nombre_cliente VARCHAR2(80); -- Variable local que guardará el nombre completo del cliente.
v_tipo_cliente VARCHAR2(50); -- Variable local que guardará el tipo de cliente.
v_monto_solic_creditos NUMBER; -- Variable local que guardará la suma del total de creditos solicitados por el cliente.
v_monto_pesos_tdsm NUMBER; -- Variable local que guardará el monto de los pesos obtenidos por el cliente en base a los criterios y el total de los creditos solicitados hace un año.
v_registro_actualizado VARCHAR2(200); -- Variable local que guardará el mensaje de salida posterior al insertar los datos del cliente en la tabla CLIENTE_TODOSUMA.

--Inicio de Bloque anonimo.
BEGIN
    SELECT -- Comienza la consulta
        c.nro_cliente, --Esta columna trae el  N° de cliente desde la tabla CLIENTE.
        TO_CHAR(c.numrun,'999G999G999')||'-'||c.dvrun, --Aquí se une el rut de cliente + DV y se les da formato.
        UPPER(c.pnombre ||' '|| c.snombre ||' '|| c.appaterno ||' '|| c.apmaterno), --En esta linea se concatena y conforma el nombre completo del cliente.
        tpc.nombre_tipo_cliente, -- Aquí consultamos el nombre del tipo de cliente desde la tabla TIPO_CLIENTE.
        SUM(cc.monto_solicitado) --Esa lina realiza la suma de todos los montos de creditos solicitados.
    INTO --Aquí indicamos que inserte los datos consultados en las lineas previas en las variables locales que se declaran (en orden).
        v_nro_cliente,  
        v_num_run_cli,
        v_nombre_cliente,
        v_tipo_cliente,
        v_monto_solic_creditos
    FROM -- Aquí se hace un inner join de las 3 tablas que necesitamos. 
        cliente c INNER JOIN tipo_cliente tpc ON (c.cod_tipo_cliente=tpc.cod_tipo_cliente)
        INNER JOIN credito_cliente cc ON (cc.nro_cliente=c.nro_cliente)
    WHERE -- Aquí comienza la condición de la consulta. 
        c.numrun = :b_run_cliente AND -- Acá especificamos que solo queremos los datos del cliente por el cual estamos consultado mediante el run.
        EXTRACT(YEAR FROM cc.fecha_otorga_cred) = (EXTRACT(YEAR FROM SYSDATE) -1) -- Acá extraemos el año de la fecha en que se otorgó el credito y el año de la fecha actual al que le restamos uno. 
        --de este modo solo nos traerá registros de hace un año. 
    GROUP BY --Aquí agrupamos los valores en caso de que el cliente haya solicitado 2 creditos o más durante el año pasado.
        c.nro_cliente,
        TO_CHAR(c.numrun,'999G999G999')||'-'||c.dvrun,
        UPPER(c.pnombre ||' '|| c.snombre ||' '|| c.appaterno ||' '|| c.apmaterno),
        tpc.nombre_tipo_cliente;
        
        
    --Comienza la condición para determinar qué aumento de valores le corresponde a cada cliente. (IF(CASE))
    IF v_tipo_cliente = 'Trabajadores independientes' THEN -- Si el tipo de cliente es igual a lo consultado, ingresará al CASE en caso contrario pasará al ELSE.
        CASE --Si ingresa al case validará que el monto solicitado en creditos (anuales) corresponde a algúno de los criterios.
            WHEN v_monto_solic_creditos < :b_rango_menor THEN
                v_monto_pesos_tdsm:= (TRUNC(v_monto_solic_creditos/100000) * :b_pesos_normales) + (TRUNC(v_monto_solic_creditos/100000) * :b_pesos_extras_bajo);
            WHEN v_monto_solic_creditos BETWEEN :b_rango_menor AND :b_rango_mayor THEN
                v_monto_pesos_tdsm:=(TRUNC(v_monto_solic_creditos/100000) * :b_pesos_normales)  + (TRUNC(v_monto_solic_creditos/100000) * :b_pesos_extras_medio);
            WHEN v_monto_solic_creditos > :b_rango_mayor THEN
                v_monto_pesos_tdsm:=(TRUNC(v_monto_solic_creditos/100000) * :b_pesos_normales)  + (TRUNC(v_monto_solic_creditos/100000) * :b_pesos_extras_alto);
            END CASE; --al ingresar en cualquiera de las opciones previas, despues de realizar el calculo, finaliza el case y retorna al IF.
    ELSE --Si el cliente no ingresó en la categoria principal, se calcularán sus puntos TODO SUMA con el valor de pesos normales (que pena).
        v_monto_pesos_tdsm:= TRUNC(v_monto_solic_creditos/100000) * :b_pesos_normales;
    END IF; -- Ya sea si ingresó al if y luego al case o pasó directo al ELSE al finalizar el calculo el IF se cierra.
    
    --Comienza la inserción de datos en tabla CLIENTE_TODOSUMA.
    INSERT INTO 
        CLIENTE_TODOSUMA
    VALUES -- Aquí pasamos los valores que hemos guardado en las variables locales.
        (v_nro_cliente,v_num_run_cli,v_nombre_cliente,v_tipo_cliente,v_monto_solic_creditos,v_monto_pesos_tdsm);
    
    --Consulta cuantas filas han sido insertadas
    v_registro_actualizado:=(SQL%ROWCOUNT||' fila(s) Insertada(s) correctamente en tabla CLIENTE_TODOSUMA.');
    --Imprime en pantalla la confirmación
    DBMS_OUTPUT.PUT_LINE(v_registro_actualizado);
       
END; --¡Al fin! aquí termina el bloque anonimo. ¡Taráan! \0/.

/*
SELECT * FROM CLIENTE_TODOSUMA; --Sentencias utilizadas para corroborar cargas.
--TRUNCATE TABLE CLIENTE_TODOSUMA; --Sentencias utilizadas para corroborar cargas.
--DELETE FROM CLIENTE_TODOSUMA WHERE NRO_cliente = 34;*/

----------------------------------------------- Caso 2 -----------------------------------------------
SET SERVEROUTPUT ON

VAR b_run_cli NUMBER;
EXEC :b_run_cli :=&Run_cliente;
VAR b_mmt1 NUMBER;
VAR b_mmt2 NUMBER;
VAR b_mmt3 NUMBER;
VAR b_mmt4 NUMBER;
VAR b_mmt5 NUMBER;

VAR b_giftcardt1 NUMBER;
VAR b_giftcardt2 NUMBER;
VAR b_giftcardt3 NUMBER;
VAR b_giftcardt4 NUMBER;
VAR b_giftcardt5 NUMBER;

EXEC :b_run_cli:=&Run_cliente;
EXEC :b_mmt1:=&Monto_mayor_tramo_1;
EXEC :b_mmt2:=&Monto_mayor_tramo_2;
EXEC :b_mmt3:=&Monto_mayor_tramo_3;
EXEC :b_mmt4:=&Monto_mayor_tramo_4;
EXEC :b_mmt5:=&Monto_mayor_tramo_5;

EXEC :b_giftcardt1:=&Monto_giftcard_tramo_1;
EXEC :b_giftcardt2:=&Monto_giftcard_tramo_2;
EXEC :b_giftcardt3:=&Monto_giftcard_tramo_3;
EXEC :b_giftcardt4:=&Monto_giftcard_tramo_4;
EXEC :b_giftcardt5:=&Monto_giftcard_tramo_5;

/*
EXEC :b_run_cli :=24617341;
EXEC :b_mmt1 := 900000;
EXEC :b_mmt2 := 2000000;
EXEC :b_mmt3 := 5000000;
EXEC :b_mmt4 := 8000000;
EXEC :b_mmt5 := 15000000;

EXEC :b_giftcardt1 := 0;
EXEC :b_giftcardt2 := 50000;
EXEC :b_giftcardt3 := 100000;
EXEC :b_giftcardt4 := 200000;
EXEC :b_giftcardt5 := 300000;
*/
DECLARE
v_nro_cliente NUMBER;
v_run_clliente VARCHAR2(15);
v_nombre_cliente VARCHAR2(80);
v_profesion_oficio VARCHAR2(40);
v_dia_cumpleano DATE;
v_monto_giftcard NUMBER;
v_observacion  VARCHAR2(200) DEFAULT NULL;
v_monto_total_ahorrado NUMBER DEFAULT NULL;
v_registro_actualizado VARCHAR2(200);

BEGIN

    SELECT
        c.nro_cliente,
        TO_CHAR(c.numrun,'09G999G999')||'-'||c.dvrun,
        INITCAP(c.pnombre ||' '|| c.snombre ||' '|| c.appaterno ||' '|| c.apmaterno),
        po.nombre_prof_ofic,
        c.fecha_nacimiento,
        pic.monto_total_ahorrado
    INTO
        v_nro_cliente,
        v_run_clliente,
        v_nombre_cliente,
        v_profesion_oficio,
        v_dia_cumpleano,
        v_monto_total_ahorrado
    FROM
        cliente c LEFT JOIN producto_inversion_cliente pic ON (c.nro_cliente=pic.nro_cliente)
        INNER JOIN profesion_oficio po ON (c.cod_prof_ofic=po.cod_prof_ofic)
    WHERE
        c.numrun = :b_run_cli;
        
    IF EXTRACT(MONTH FROM v_dia_cumpleano) = EXTRACT(MONTH FROM ADD_MONTHS(SYSDATE,1)) THEN
        CASE
            WHEN v_monto_total_ahorrado BETWEEN 0 AND :b_mmt1 THEN
                v_monto_giftcard:= :b_giftcardt1;
                v_observacion:=NULL;
                
            WHEN v_monto_total_ahorrado BETWEEN (:b_mmt1 + 1) AND :b_mmt2 THEN
                v_monto_giftcard:= :b_giftcardt2;
                v_observacion:=NULL;
                
            WHEN v_monto_total_ahorrado BETWEEN (:b_mmt2 + 1) AND :b_mmt3 THEN
                v_monto_giftcard:= :b_giftcardt3;
                v_observacion:=NULL;
                
            WHEN v_monto_total_ahorrado BETWEEN (:b_mmt3 + 1 ) AND :b_mmt4 THEN
                v_monto_giftcard:= :b_giftcardt4;
                v_observacion:=NULL;
                
            WHEN v_monto_total_ahorrado BETWEEN (:b_mmt3 + 1) AND :b_mmt5 THEN
                v_monto_giftcard:= :b_giftcardt5;
                v_observacion:=NULL;
            ELSE
                v_monto_giftcard:=0;
        END CASE;
    ELSE
        v_monto_giftcard:=NULL;
        v_observacion:= 'El cliente no está de cumpleaños en el mes procesado';
    END IF;
    
    INSERT INTO
        CUMPLEANNO_CLIENTE
    VALUES
        (v_nro_cliente, v_run_clliente, v_nombre_cliente, v_profesion_oficio, TO_CHAR(v_dia_cumpleano,'DD " de " MONTH'), v_monto_giftcard, v_observacion );
    
    --Consulta cuantas filas han sido insertadas
    v_registro_actualizado:=(SQL%ROWCOUNT||' fila(s) Insertada(s) correctamente en tabla CUMPLEANNO_CLIENTE.');
    --Imprime en pantalla la confirmación
    DBMS_OUTPUT.PUT_LINE(v_registro_actualizado);
END;

SELECT * FROM CUMPLEANNO_CLIENTE;

