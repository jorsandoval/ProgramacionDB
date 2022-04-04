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


