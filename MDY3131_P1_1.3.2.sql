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