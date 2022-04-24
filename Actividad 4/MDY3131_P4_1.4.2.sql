/*------------------------------------------------------------------------------------------------------
--                        Jorge Sandoval - MDY3131_002V - Programación de Base de Datos
--                                            Guia 1.4.2
----------------------------------------------- Caso 1 -----------------------------------------------*/
SET SERVEROUTPUT ON

VAR b_anno_pro NUMBER;
EXEC :b_anno_pro:=&anno_proceso;

DECLARE
v_id_min_empleado empleado.id_emp%TYPE;
v_id_max_empleado empleado.id_emp%TYPE;

v_id_emp NUMBER(3);
v_numrun_emp NUMBER(8);
v_dvrun_emp VARCHAR2(1);
v_nombre_emp VARCHAR2(80);
v_nom_comuna VARCHAR2(50);
v_sbase NUMBER(10);
v_porc_movil_normal NUMBER;
v_valor_movil_normal NUMBER;
v_valor_movil_extra NUMBER;
v_valor_total_movil NUMBER;
v_filas_actualizadas NUMBER:=0;

BEGIN
    TRUNCATE TABLE PROY_MOVILIZACION;
    COMMIT;

    SELECT 
        MIN(id_emp), MAX(id_emp)
    INTO
        v_id_min_empleado, v_id_max_empleado
    FROM EMPLEADO;
    
    WHILE v_id_max_empleado >= v_id_min_empleado LOOP

        SELECT
            e.id_emp,
            e.numrun_emp,
            e.dvrun_emp,
            e.pnombre_emp ||' '|| e.snombre_emp ||' '|| e.appaterno_emp ||' '|| e.apmaterno_emp,
            c.nombre_comuna,
            e.sueldo_base
        INTO
            v_id_emp,
            v_numrun_emp,
            v_dvrun_emp,
            v_nombre_emp,
            v_nom_comuna,
            v_sbase
        FROM
            empleado e INNER JOIN comuna c ON (e.id_comuna=c.id_comuna)
        WHERE
            e.id_emp = v_id_min_empleado;
        
        v_porc_movil_normal:= TRUNC(v_sbase / 100000);
        v_valor_movil_normal:= (v_sbase * v_porc_movil_normal) / 100;
        
        CASE v_nom_comuna
            WHEN 'María Pinto' THEN
                v_valor_movil_extra:= 20000;
                v_valor_total_movil:= v_valor_movil_normal + v_valor_movil_extra;
            WHEN 'Curacaví' THEN
                v_valor_movil_extra:= 25000;
                v_valor_total_movil:= v_valor_movil_normal + v_valor_movil_extra;
            WHEN 'Talagante' THEN
                v_valor_movil_extra:= 30000;
                v_valor_total_movil:= v_valor_movil_normal + v_valor_movil_extra;
            WHEN 'El Monte' THEN
                v_valor_movil_extra:= 35000;
                v_valor_total_movil:= v_valor_movil_normal + v_valor_movil_extra;
            WHEN 'Buin' THEN
                v_valor_movil_extra:= 40000;
                v_valor_total_movil:= v_valor_movil_normal + v_valor_movil_extra;
            ELSE
                v_valor_movil_extra:= 0;
                v_valor_total_movil:= v_valor_movil_normal + v_valor_movil_extra;
        END CASE;
    
        INSERT INTO
            PROY_MOVILIZACION
        VALUES
            (:b_anno_pro, v_id_emp, v_numrun_emp,v_dvrun_emp, v_nombre_emp,v_nom_comuna,v_sbase,v_porc_movil_normal,v_valor_movil_normal,v_valor_movil_extra,v_valor_total_movil);
        v_id_min_empleado := v_id_min_empleado + 10;
        v_filas_actualizadas:= v_filas_actualizadas + SQL%ROWCOUNT;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE(v_filas_actualizadas|| ' fila(s) Insertada(s) correctamente en PROY_MOVILIZACION');
COMMIT; 
END;

SELECT * FROM PROY_MOVILIZACION;
TRUNCATE TABLE PROY_MOVILIZACION;
----------------------------------------------- Caso 2 -----------------------------------------------
SET SERVEROUTPUT ON

TRUNCATE TABLE USUARIO_CLAVE;
COMMIT;

DECLARE
v_id_min_empleado empleado.id_emp%TYPE;
v_id_max_empleado empleado.id_emp%TYPE;


v_numrun_emp NUMBER(10);
v_dvrun_emp VARCHAR2(1);
v_pnombre_empleado VARCHAR2(60);
v_snombre_empleado VARCHAR2(60);
v_appaterno_empleado VARCHAR2(60);
v_apmaterno_empleado VARCHAR2(60);
v_sueldo_base NUMBER;
v_nom_comuna VARCHAR(40);
V_fecha_contrato DATE;
v_fecha_nac DATE;
v_estado_civil VARCHAR2(30);
v_id_estado_civil NUMBER;
v_nombre_usuario VARCHAR2(20);
v_clave_usuario VARCHAR2(20);
v_filas_actualizadas NUMBER:=0;
v_nombre_empleado VARCHAR2(100);

BEGIN
    
    SELECT 
        MIN(id_emp), MAX(id_emp)
    INTO
        v_id_min_empleado, v_id_max_empleado
    FROM
        empleado;
    WHILE v_id_max_empleado >= v_id_min_empleado LOOP
        --En el siguiente Select se obtiene la información del empleado a partir del rut y se genera el usuario y clave según las condiciones de negocio informadas.
        SELECT
            e.numrun_emp,
            e.dvrun_emp,
            e.pnombre_emp,
            e.snombre_emp,
            e.appaterno_emp,
            e.apmaterno_emp,
            ec.nombre_estado_civil,
            e.fecha_contrato,
            e.sueldo_base,
            e.id_estado_civil,
            e.fecha_nac,
            c.nombre_comuna
        INTO
            v_numrun_emp,
            v_dvrun_emp,
            v_pnombre_empleado,
            v_snombre_empleado,
            v_appaterno_empleado,
            v_apmaterno_empleado,
            v_estado_civil,
            V_fecha_contrato,
            v_sueldo_base,
            v_id_estado_civil,
            v_fecha_nac,
            v_nom_comuna
        FROM
            empleado e INNER JOIN comuna c ON (e.id_comuna=c.id_comuna) INNER JOIN estado_civil ec ON (e.id_estado_civil=ec.id_estado_civil)
        WHERE
            e.id_emp = v_id_min_empleado;
        
        v_nombre_empleado:= v_pnombre_empleado || v_snombre_empleado || v_appaterno_empleado || v_apmaterno_empleado;

        CASE 
            WHEN TRUNC(MONTHS_BETWEEN(SYSDATE,V_fecha_contrato)/12) < 9 THEN
                v_nombre_usuario:= SUBSTR(v_pnombre_empleado,1,3) || LENGTH(v_pnombre_empleado) || '*' || SUBSTR(v_sueldo_base,-1) || v_dvrun_emp || ROUND(MONTHS_BETWEEN(SYSDATE,V_fecha_contrato)/12) || 'X';
            ELSE
                v_nombre_usuario:= SUBSTR(v_pnombre_empleado,1,3) || LENGTH(v_pnombre_empleado) || '*' || SUBSTR(v_sueldo_base,-1) || v_dvrun_emp || ROUND(MONTHS_BETWEEN(SYSDATE,V_fecha_contrato)/12);
        END CASE;
        
        CASE 
                WHEN v_id_estado_civil = 10 THEN
                  v_clave_usuario:= SUBSTR(v_numrun_emp,3,1) || EXTRACT(YEAR FROM v_fecha_nac)+2 || SUBSTR((v_sueldo_base-1),-3) || LOWER(SUBSTR(v_appaterno_empleado,1,2)) || TO_CHAR(SYSDATE,'MMYYYY') || SUBSTR(v_nom_comuna,1,1);
                WHEN  v_id_estado_civil = 60 THEN
                  v_clave_usuario:= SUBSTR(v_numrun_emp,3,1) || EXTRACT(YEAR FROM v_fecha_nac)+2 || SUBSTR((v_sueldo_base-1),-3) || LOWER(SUBSTR(v_appaterno_empleado,1,2)) || TO_CHAR(SYSDATE,'MMYYYY') || SUBSTR(v_nom_comuna,1,1);
                WHEN v_id_estado_civil LIKE 20 THEN
                    v_clave_usuario:= SUBSTR(v_numrun_emp,3,1) || EXTRACT(YEAR FROM v_fecha_nac)+2 || SUBSTR((v_sueldo_base-1),-3) || LOWER(SUBSTR(v_appaterno_empleado,1,1)) || LOWER(SUBSTR(v_appaterno_empleado,-1)) || TO_CHAR(SYSDATE,'MMYYYY') || SUBSTR(v_nom_comuna,1,1);
                WHEN v_id_estado_civil LIKE 30 THEN
                    v_clave_usuario:= SUBSTR(v_numrun_emp,3,1) || EXTRACT(YEAR FROM v_fecha_nac)+2 || SUBSTR((v_sueldo_base-1),-3) || LOWER(SUBSTR(v_appaterno_empleado,1,1)) || LOWER(SUBSTR(v_appaterno_empleado,-1)) || TO_CHAR(SYSDATE,'MMYYYY') || SUBSTR(v_nom_comuna,1,1);
                WHEN v_id_estado_civil LIKE 40 THEN
                    v_clave_usuario:= SUBSTR(v_numrun_emp,3,1) || EXTRACT(YEAR FROM v_fecha_nac)+2 || SUBSTR((v_sueldo_base-1),-3) || LOWER(SUBSTR(v_appaterno_empleado,-3,2)) || TO_CHAR(SYSDATE,'MMYYYY') || SUBSTR(v_nom_comuna,1,1);
                ELSE
                    v_clave_usuario:=SUBSTR(v_numrun_emp,3,1) || EXTRACT(YEAR FROM v_fecha_nac)+2 || SUBSTR((v_sueldo_base-1),-3) || LOWER(SUBSTR(v_appaterno_empleado,-2,2)) || TO_CHAR(SYSDATE,'MMYYYY') || SUBSTR(v_nom_comuna,1,1);
        END CASE;
        
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

        v_id_min_empleado:= v_id_min_empleado + 10;
    END LOOP;
COMMIT;
END;
----------------------------------------------- Caso 3 -----------------------------------------------
SET SERVEROUTPUT ON

TRUNCATE TABLE hist_arriendo_anual_camion;

COMMIT;

--Declaración de variables bind
VARIABLE b_anno_proceso NUMBER;
--VARIABLE b_por_reba NUMBER;--22,5%
VAR b_por_reba NUMBER;

--Asignación de valores de forma parametrica a variables bind
--EXEC :b_anno_proceso:=&ANNO_PROCESO;
EXEC :b_anno_proceso:=2022;
--EXEC :b_porcentaje_rebaja:=&Porcentaje_rebaja_con_punto_sin_comas;
--EXEC :b_por_reba:=&Porcentaje_Rebaja_con_punto_sin_comas;
EXEC :b_por_reba:=22.5;

--Declara las variables escalares
DECLARE
    v_anno_proceso                NUMBER;
    v_nro_patente_p               VARCHAR2(6);
    v_valor_arriendo_dia          NUMBER;
    v_valor_garantia_dia          NUMBER;
    v_total_veces_arrendado       NUMBER;
    v_filas_insertadas            VARCHAR2(160);
    v_filas_actualizadas          VARCHAR2(160);
    v_valor_arriendo_dia_ajustado NUMBER;
    v_valor_garantia_dia_ajustado NUMBER;
    v_id_min                      NUMBER;
    v_id_max                      NUMBER;
BEGIN ---Inicio de bloquea anonimo

    SELECT
        MIN(id_camion),
        MAX(id_camion)
    INTO
        v_id_min,
        v_id_max
    FROM
        camion;

    WHILE v_id_max >= v_id_min LOOP
        SELECT
            c.nro_patente,
            nvl(c.valor_arriendo_dia, 0),
            nvl(c.valor_garantia_dia, 0),
            COUNT(ac.id_arriendo)
        INTO
            v_nro_patente_p,
            v_valor_arriendo_dia,
            v_valor_garantia_dia,
            v_total_veces_arrendado
        FROM
            arriendo_camion ac
            RIGHT JOIN camion          c ON ( ac.id_camion = c.id_camion
                                     AND EXTRACT(YEAR FROM ac.fecha_ini_arriendo) = ( :b_anno_proceso ) )
        WHERE
            c.id_camion = v_id_min
        GROUP BY
            c.nro_patente,
            c.valor_arriendo_dia,
            c.valor_garantia_dia;
             
            --Inserta los valores de las variables escalares a la tabla HIST_ARRIENDO_ANUAL_CAMION según la patente que se vaya ingresando
        INSERT INTO hist_arriendo_anual_camion VALUES (
            :b_anno_proceso,
            v_id_min,
            v_nro_patente_p,
            v_valor_arriendo_dia,
            v_valor_garantia_dia,
            v_total_veces_arrendado
        );
      
            --Si existen camiones que tienen menos de 5 arriendos en el año, se actualiza su valor de arriendo dia y garantia dia
        IF v_total_veces_arrendado <= 4 THEN
                --Aqu� se calcula según el % ingresado de forma parametrica en la variable Bind
            v_valor_arriendo_dia_ajustado := round((v_valor_arriendo_dia *(100 - :b_por_reba)) / 100);

            v_valor_garantia_dia_ajustado := round((v_valor_garantia_dia *(100 - :b_por_reba)) / 100);
                --Se actualiza el valor arriendo dia y valor garantia dia a partir de la patente ingresada de forma parametrica
            UPDATE camion
            SET
                valor_arriendo_dia = v_valor_arriendo_dia_ajustado,
                valor_garantia_dia = v_valor_garantia_dia_ajustado
            WHERE
                id_camion = v_id_min;

        END IF; 
        --si todo ha resultado bien, guarda los cambios  
        v_id_min := v_id_min + 1;
    END LOOP;

END;

COMMIT;
----------------------------------------------- Caso 4 -----------------------------------------------
SET SERVEROUTPUT ON

VARIABLE 






































