----------------------------------------------- Caso 1 -----------------------------------------------
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

--Declaracion de variables bind Año proceso y Run emplado
VARIABLE b_annio_proceso NUMBER;
VARIABLE b_run_empleado NUMBER;

--Declaracion de Variables bidn para comunas que se les paga movilización adicional
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
    --Inserta los resultados de la consulta en tabla PROY_MOVILIZACION
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

--Usadas para la revisión
--SELECT * FROM PROY_MOVILIZACION;
--TRUNCATE TABLE PROY_MOVILIZACION;
--DELETE FROM PROY_MOVILIZACION WHERE NUMRUN_EMP = 12868553;

----------------------------------------------- Caso 2 -----------------------------------------------
SET SERVEROUTPUT ON

VARIABLE b_run_empleado NUMBER;

EXEC

