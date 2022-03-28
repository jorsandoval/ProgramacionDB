/*------------------------------------------------------------------------------------------------------
--                        Jorge Sandoval - MDY3131_002V - Programación de Base de Datos
--                                            Guia 1.2.3
----------------------------------------------- Caso 1 -----------------------------------------------*/
SET SERVEROUTPUT ON

/* Datos a usar de forma parametrica (para copiar al block de notas)
11846972
12272880
12113369
11999100
12868553

2022

María Pinto
20000
Curacaví
25000
Talagante
30000
El Monte
35000
Buin
40000
*/

--Declaracion de variables bind AÑo proceso y Run emplado
VARIABLE b_annio_proceso NUMBER;
VARIABLE b_run_empleado NUMBER;

--Declaracion de Variables bind para comunas que se les paga movilización adicional
VARIABLE b_nombre_comuna_1 VARCHAR2(25);
VARIABLE b_nombre_comuna_2 VARCHAR2(25);
VARIABLE b_nombre_comuna_3 VARCHAR2(25);
VARIABLE b_nombre_comuna_4 VARCHAR2(25);
VARIABLE b_nombre_comuna_5 VARCHAR2(25);

--Declaracion de variables bind para el adicional por comuna con movilización extra
VARIABLE b_aumento_comuna_1 NUMBER;
VARIABLE b_aumento_comuna_2 NUMBER;
VARIABLE b_aumento_comuna_3 NUMBER;
VARIABLE b_aumento_comuna_4 NUMBER;
VARIABLE b_aumento_comuna_5 NUMBER;

--Solicitud parametrica para variables bind
EXEC :b_run_empleado:=&Ingresar_run_empleado;
EXEC :b_annio_proceso:=&Ingrese_año_actual;
EXEC :b_nombre_comuna_1:='&Ingrese_nombre_comuna_1_de_5';
EXEC :b_aumento_comuna_1:=&Ingrese_Movilización_adicional_Comuna_1_de_5;
EXEC :b_nombre_comuna_2:='&Ingrese_nombre_comuna_2_de_5';
EXEC :b_aumento_comuna_2:=&Ingrese_Movilización_adicional_Comuna_2_de_5;
EXEC :b_nombre_comuna_3:='&Ingrese_nombre_comuna_3_de_5';
EXEC :b_aumento_comuna_3:=&Ingrese_Movilización_adicional_Comuna_3_de_5;
EXEC :b_nombre_comuna_4:='&Ingrese_nombre_comuna_4_de_5';
EXEC :b_aumento_comuna_4:=&Ingrese_Movilización_adicional_Comuna_4_de_5;
EXEC :b_nombre_comuna_5:='&Ingrese_nombre_comuna_5_de_5';
EXEC :b_aumento_comuna_5:=&Ingrese_Movilización_adicional_Comuna_5_de_5;

/*--Habilitarlo solo para quitar la opción parametrica y deshabilitar desde la linea 45 a la 55.
EXEC :b_annio_proceso:=2022;
EXEC :b_nombre_comuna_1:='María Pinto';
EXEC :b_aumento_comuna_1:=20000;
EXEC :b_nombre_comuna_2:='Curacaví';
EXEC :b_aumento_comuna_2:=25000;
EXEC :b_nombre_comuna_3:='Talagante';
EXEC :b_aumento_comuna_3:=30000;
EXEC :b_nombre_comuna_4:='El Monte';
EXEC :b_aumento_comuna_4:=35000;
EXEC :b_nombre_comuna_5:='Buin';
EXEC :b_aumento_comuna_5:=40000;
*/

--Declaracion de variable escalar
DECLARE
v_filas_actualizadas VARCHAR2(50);

--Inicio del bloquea anonimo
BEGIN
    --Inserta los resultados de la consulta en tabla PROY_MOVILIZACIÓN
    INSERT INTO PROY_MOVILIZACION
    SELECT
        :b_annio_proceso as ANNO_PROCESO,
        e.numrun_emp AS NUMRUN_EMP,
        e.dvrun_emp AS DVRUN_EMP,
        e.pnombre_emp||' '||e.snombre_emp||' '||e.appaterno_emp||' '||e.apmaterno_emp AS NOMBRE_EMPLEADO,
        e.sueldo_base AS SUELDO_BASE,
        TRUNC(e.sueldo_base/100000) AS PORC_MOVIL_NORMAL,
        ROUND((e.sueldo_base * TRUNC(e.sueldo_base/100000)) /100) AS VALOR_MOVIL_NORMAL,
        CASE
            WHEN c.nombre_comuna = :b_nombre_comuna_1 THEN
                :b_aumento_comuna_1
            WHEN c.nombre_comuna = :b_nombre_comuna_2 THEN
                :b_aumento_comuna_2
            WHEN c.nombre_comuna = :b_nombre_comuna_3 THEN
                :b_aumento_comuna_3
            WHEN c.nombre_comuna = :b_nombre_comuna_4 THEN
                :b_aumento_comuna_4
            WHEN c.nombre_comuna = :b_nombre_comuna_5 THEN
                :b_aumento_comuna_5
            ELSE
                0
        END AS VALOR_MOVIL_EXTRA,
        CASE
            WHEN c.nombre_comuna = :b_nombre_comuna_1 THEN
                :b_aumento_comuna_1 + ROUND((e.sueldo_base * TRUNC(e.sueldo_base/100000)) /100)
            WHEN c.nombre_comuna = :b_nombre_comuna_2 THEN
                :b_aumento_comuna_2 + ROUND((e.sueldo_base * TRUNC(e.sueldo_base/100000)) /100)
            WHEN c.nombre_comuna = :b_nombre_comuna_3 THEN
                :b_aumento_comuna_3 + ROUND((e.sueldo_base * TRUNC(e.sueldo_base/100000)) /100)
            WHEN c.nombre_comuna = :b_nombre_comuna_4 THEN
                :b_aumento_comuna_4 + ROUND((e.sueldo_base * TRUNC(e.sueldo_base/100000)) /100)
            WHEN c.nombre_comuna = :b_nombre_comuna_5 THEN
                :b_aumento_comuna_5 + ROUND((e.sueldo_base * TRUNC(e.sueldo_base/100000)) /100)
            ELSE
                0 + ROUND((e.sueldo_base * TRUNC(e.sueldo_base/100000)) /100)
        END AS VALOR_TOTAL_MOVIL
    FROM empleado e INNER JOIN comuna c ON (e.id_comuna=c.id_comuna)
    WHERE e.NUMRUN_EMP = :b_run_empleado;
    
    --Consulta cuantas filas han sido modificadas 
    v_filas_actualizadas:=(SQL%ROWCOUNT||' fila(s) Insertada(s) correctamente.');
    --Imprime el mensaje por pantalla
    DBMS_OUTPUT.PUT_LINE(v_filas_actualizadas);
    
--Si todo ha salido bien, realiza una confirmación y guarda la inserción en la base
COMMIT;
--Finaliza el bloque anonimo
END;

--Usadas para la revisión y validación de bloque
--SELECT * FROM PROY_MOVILIZACION;
--TRUNCATE TABLE PROY_MOVILIZACION;
--DELETE FROM PROY_MOVILIZACION WHERE NUMRUN_EMP = 12868553;

----------------------------------------------- Caso 2 -----------------------------------------------
SET SERVEROUTPUT ON

--Declaración de Variable Bind para el rut de empleado
VARIABLE b_run_empleado NUMBER;
--Solicitud de rut empleado de forma parametrica
EXEC :b_run_empleado:=&Rut_Empleado;

--Declaración de variable escalar
DECLARE
v_registro_actualizado VARCHAR2(50);
v_mes_anno NUMBER(6);
v_numrun_emp NUMBER(10);
v_dvrun_emp VARCHAR2(1);
v_nombre_empleado VARCHAR2(60);
v_nombre_usuario VARCHAR2(20);
v_clave_usuario VARCHAR2(20);

--Inicio de bloque anonimo
BEGIN
    --En el siguiente Select se obtiene la información del empleado a partir del rut y se genera el usuario y clave según las condiciones de negocio informadas.
    SELECT
        TO_CHAR(SYSDATE,'MMYYYY'),
        e.numrun_emp,
        e.dvrun_emp,
        e.pnombre_emp||' '||e.snombre_emp||' '||e.appaterno_emp||' '||e.apmaterno_emp,
        CASE
            WHEN TRUNC(MONTHS_BETWEEN(SYSDATE,e.fecha_contrato)/12) < 9 THEN
                SUBSTR(e.pnombre_emp,1,3) || LENGTH(e.pnombre_emp) || '*' || SUBSTR(e.sueldo_base,-1) || e.dvrun_emp || ROUND(MONTHS_BETWEEN(SYSDATE,e.fecha_contrato)/12) || 'X'
            ELSE
                SUBSTR(e.pnombre_emp,1,3) || LENGTH(e.pnombre_emp) || '*' || SUBSTR(e.sueldo_base,-1) || e.dvrun_emp || ROUND(MONTHS_BETWEEN(SYSDATE,e.fecha_contrato)/12)
        END,
        CASE
            WHEN e.id_estado_civil = 10 THEN
              SUBSTR(e.numrun_emp,3,1) || EXTRACT(YEAR FROM e.fecha_nac)+2 || SUBSTR((e.sueldo_base-1),-3) || LOWER(SUBSTR(e.appaterno_emp,1,2)) || TO_CHAR(SYSDATE,'MMYYYY') || SUBSTR(c.nombre_comuna,1,1)
            WHEN e.id_estado_civil = 60 THEN
              SUBSTR(e.numrun_emp,3,1) || EXTRACT(YEAR FROM e.fecha_nac)+2 || SUBSTR((e.sueldo_base-1),-3) || LOWER(SUBSTR(e.appaterno_emp,1,2)) || TO_CHAR(SYSDATE,'MMYYYY') || SUBSTR(c.nombre_comuna,1,1)
            WHEN e.id_estado_civil LIKE 20 THEN
                SUBSTR(e.numrun_emp,3,1) || EXTRACT(YEAR FROM e.fecha_nac)+2 || SUBSTR((e.sueldo_base-1),-3) || LOWER(SUBSTR(e.appaterno_emp,1,1)) || LOWER(SUBSTR(e.appaterno_emp,-1)) || TO_CHAR(SYSDATE,'MMYYYY') || SUBSTR(c.nombre_comuna,1,1)
            WHEN e.id_estado_civil LIKE 30 THEN
                SUBSTR(e.numrun_emp,3,1) || EXTRACT(YEAR FROM e.fecha_nac)+2 || SUBSTR((e.sueldo_base-1),-3) || LOWER(SUBSTR(e.appaterno_emp,1,1)) || LOWER(SUBSTR(e.appaterno_emp,-1)) || TO_CHAR(SYSDATE,'MMYYYY') || SUBSTR(c.nombre_comuna,1,1)
            WHEN e.id_estado_civil LIKE 40 THEN
                SUBSTR(e.numrun_emp,3,1) || EXTRACT(YEAR FROM e.fecha_nac)+2 || SUBSTR((e.sueldo_base-1),-3) || LOWER(SUBSTR(e.appaterno_emp,-3,2)) || TO_CHAR(SYSDATE,'MMYYYY') || SUBSTR(c.nombre_comuna,1,1)
            ELSE
                SUBSTR(e.numrun_emp,3,1) || EXTRACT(YEAR FROM e.fecha_nac)+2 || SUBSTR((e.sueldo_base-1),-3) || LOWER(SUBSTR(e.appaterno_emp,-2,2)) || TO_CHAR(SYSDATE,'MMYYYY') || SUBSTR(c.nombre_comuna,1,1)
        END
    INTO
        v_mes_anno,
        v_numrun_emp,
        v_dvrun_emp,
        v_nombre_empleado,
        v_nombre_usuario,
        v_clave_usuario
    FROM
        empleado e INNER JOIN comuna c ON (e.id_comuna=c.id_comuna)
    WHERE
       numrun_emp = :b_run_empleado ;
    
    --Inserta valores de la consulta a tabla 
    INSERT INTO 
        USUARIO_CLAVE
    VALUES
        (   v_mes_anno,
            v_numrun_emp,
            v_dvrun_emp,
            v_nombre_empleado,
            v_nombre_usuario,
            v_clave_usuario
        );
    
    --Consulta cuantas filas han sido modificadas
    v_registro_actualizado:=(SQL%ROWCOUNT||' fila(s) Insertada(s) correctamente.');
    --Imprime en pantalla la confirmación
    DBMS_OUTPUT.PUT_LINE(v_registro_actualizado);
    
--Si todo ha salido bien, guarda las inserciones a la Base    
COMMIT;
END;

/*
--Validación de carga
Select * From USUARIO_CLAVE;
TRUNCATE TABLE USUARIO_CLAVE;
SELECT id_estado_civil FROM empleado WHERE numrun_emp = 12648200;
SELECT id_estado_civil FROM empleado WHERE numrun_emp = 12260812;
SELECT id_estado_civil FROM empleado WHERE numrun_emp = 12456905;
SELECT id_estado_civil FROM empleado WHERE numrun_emp = 11649964;
SELECT id_estado_civil FROM empleado WHERE numrun_emp = 12642309;
*/
----------------------------------------------- Caso 3 -----------------------------------------------
SET SERVEROUTPUT ON

--Declaración de variables bind
VARIABLE b_anno_proceso NUMBER;
VARIABLE b_patente_camion VARCHAR2(7);
VARIABLE b_porcentaje_rebaja NUMBER;

--Asignación de valores de forma parametrica a variables bind
EXEC :b_anno_proceso:=&ANNO_PROCESO;
EXEC :b_patente_camion:=UPPER('&Patente_cami�n');
EXEC :b_porcentaje_rebaja:=&Porcentaje_rebaja_con_punto_sin_comas;

--Declara las variables escalares
DECLARE
v_anno_proceso NUMBER;
v_nro_patente_p VARCHAR2(6);
v_valor_arriendo_dia NUMBER;
v_valor_garantia_dia NUMBER;
v_total_veces_arrendado NUMBER;
v_filas_Insertadas VARCHAR2(160);
v_filas_actualizadas VARCHAR2(160);
v_valor_arriendo_dia_ajustado NUMBER;
v_valor_garantia_dia_ajustado NUMBER;

BEGIN ---Inicio de bloquea anonimo
    --Esta consulta almacena sus valores en las variables escalares creadas
    SELECT
        :b_anno_proceso,
        :b_patente_camion,
        c.valor_arriendo_dia ,
        c.valor_garantia_dia ,
        COUNT(ac.id_arriendo)
    INTO
       v_anno_proceso,
       v_nro_patente_p,
       v_valor_arriendo_dia,
       v_valor_garantia_dia,
       v_total_veces_arrendado
    FROM
        arriendo_camion ac INNER JOIN camion c ON (ac.nro_patente=c.nro_patente)
    WHERE
        ac.nro_patente = :b_patente_camion 
        AND
        EXTRACT(YEAR FROM ac.fecha_ini_arriendo) = (:b_anno_proceso) -1
    GROUP BY
    :b_anno_proceso,
    :b_patente_camion,
    c.valor_arriendo_dia,
    c.valor_garantia_dia;
    
    --Inserta los valores de las variables escalares a la tabla HIST_ARRIENDO_ANUAL_CAMION según la patente que se vaya ingresando
    INSERT INTO 
        HIST_ARRIENDO_ANUAL_CAMION
    VALUES
        (v_anno_proceso, v_nro_patente_p, v_valor_arriendo_dia, v_valor_garantia_dia, v_total_veces_arrendado);
    
    --Consulta cuantas filas han sido insertadas 
    v_filas_Insertadas:=(SQL%ROWCOUNT||' fila(s) Insertada(s) correctamente en HIST_ARRIENDO_ANUAL_CAMION.');
    --Imprime el mensaje por pantalla
    DBMS_OUTPUT.PUT_LINE(v_filas_Insertadas);

    --Si existen camiones que tienen menos de 5 arriendos en el año, se actualiza su valor de arriendo dia y garantia dia
   IF v_total_veces_arrendado <= 4 THEN
        --Aqu� se calcula seg�n el % ingresado de forma parametrica en la variable Bind
        v_valor_arriendo_dia_ajustado:=ROUND((v_valor_arriendo_dia * (100 - :b_porcentaje_rebaja))/100);
        v_valor_garantia_dia_ajustado:=ROUND((v_valor_garantia_dia * (100 - :b_porcentaje_rebaja))/100);
        --Se actualiza el valor arriendo dia y valor garantia dia a partir de la patente ingresada de forma parametrica
        UPDATE CAMION
        SET VALOR_ARRIENDO_DIA = v_valor_arriendo_dia_ajustado, VALOR_GARANTIA_DIA = v_valor_garantia_dia_ajustado
        WHERE nro_patente = :b_patente_camion;
        
        --Consulta cuantas filas han sido Actulizadas 
        v_filas_actualizadas:=(SQL%ROWCOUNT ||' fila(s) actualizada(s) correctamente en camion.');
        --Imprime el mensaje por pantalla
        DBMS_OUTPUT.PUT_LINE(v_filas_actualizadas);
    END IF;
--si todo ha resultado bien, guarda los cambios    
COMMIT;
END; --Finaliza el bloquea anonimo

/* --sentencias de prueba
--SELECT * FROM camion;
SELECT * FROM HIST_ARRIENDO_ANUAL_CAMION;
TRUNCATE TABLE HIST_ARRIENDO_ANUAL_CAMION;
SELECT * FROM camion WHERE nro_patente IN ( 'AHEW11','ASEZ11','BC1002', 'BT1002','VR1003');
UPDATE CAMION SET VALOR_ARRIENDO_DIA = 14500 WHERE nro_patente = 'ASEZ11';*/
----------------------------------------------- Caso 4 -----------------------------------------------
SET SERVEROUTPUT ON

--Declaración de variables Bind Universales
VARIABLE B_nro_patente VARCHAR2(6);
VARIABLE B_valor_multa NUMBER;

--Asignación de valores a variables bind de forma parametrica
EXEC :B_nro_patente:=UPPER('&Patente_de_Camión');
EXEC :B_valor_multa:=&Valor_multa_atraso_por_dia;

DECLARE
v_dias_atraso NUMBER;
V_valor_multa NUMBER;
v_anno_mes_proceso NUMBER;
v_fecha_inicio_arriendo DATE;
v_dias_solicitados NUMBER;
v_fecha_devolucion DATE;
v_valor_garantia_dia NUMBER;
v_registro_actualizado VARCHAR2(200);

BEGIN
    
    SELECT
        TO_CHAR(SYSDATE,'YYYYMM'),
        dias_solicitados,
        fecha_ini_arriendo,
        fecha_devolucion
    INTO
        v_anno_mes_proceso,
        v_dias_solicitados,
        v_fecha_inicio_arriendo,
        v_fecha_devolucion
    FROM
        arriendo_camion
    WHERE
        nro_patente = :B_nro_patente
        AND
        EXTRACT(MONTH FROM fecha_ini_arriendo) = EXTRACT(MONTH FROM SYSDATE)-1
        AND
        EXTRACT(YEAR FROM fecha_ini_arriendo) = EXTRACT(YEAR FROM SYSDATE)
        AND
        ((fecha_devolucion - fecha_ini_arriendo) - dias_solicitados) >= 1;
        
        v_dias_atraso:= (v_fecha_devolucion - v_fecha_inicio_arriendo) - v_dias_solicitados;
        V_valor_multa:= v_dias_atraso * :B_valor_multa;

    INSERT INTO
        MULTA_ARRIENDO
    VALUES (v_anno_mes_proceso,:B_nro_patente,v_fecha_inicio_arriendo,v_dias_solicitados,v_fecha_devolucion,v_dias_atraso,V_valor_multa);
    
    --Consulta cuantas filas han sido insertadas
    v_registro_actualizado:=(SQL%ROWCOUNT||' fila(s) Insertada(s) correctamente en tabla MULTA_ARRIENDO.');
    --Imprime en pantalla la confirmación
    DBMS_OUTPUT.PUT_LINE(v_registro_actualizado);

END;

--Sentencias utilizadas para corroborar cargas.
SELECT * FROM MULTA_ARRIENDO;
TRUNCATE TABLE MULTA_ARRIENDO;
DELETE FROM MULTA_ARRIENDO WHERE NRO_PATENTE = 'VR1003';































