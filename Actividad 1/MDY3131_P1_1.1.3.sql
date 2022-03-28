----------------------------------------------------------------------------------------------------------
--                        Jorge Sandoval - MDY3131_002V - Programación de Base de Datos
--------------------------------------------------Caso 1--------------------------------------------------
SET SERVEROUTPUT ON

VAR b_porcentaje_bono NUMBER;
EXEC :b_porcentaje_bono:=40;

VAR b_rut_a_consultar NUMBER;
--EXEC :b_rut_a_consultar:=11846972;
EXEC :b_rut_a_consultar:=18560875;

VAR b_bono_extra NUMBER;
 

DECLARE
v_nombre_emp VARCHAR2(20);
v_run VARCHAR2(10);
v_sueldo NUMBER;

BEGIN
    SELECT
        nombre_emp || ' ' || appaterno_emp || ' ' || apmaterno_emp, numrut_emp ||'-'|| dvrut_emp, sueldo_emp
    INTO
        v_nombre_emp,v_run,v_sueldo
    FROM
        Empleado
    WHERE
         numrut_emp LIKE :b_rut_a_consultar;
         
    :b_bono_extra:= v_sueldo * (:b_porcentaje_bono/100);     
    
    DBMS_OUTPUT.PUT_LINE(''); 
    DBMS_OUTPUT.PUT_LINE('DATOS CALCULO BONIFICACION EXTRA DEL '|| :b_porcentaje_bono || '% DEL SUELDO');
    DBMS_OUTPUT.PUT_LINE('NOMBRE EMPLEADO: ' || v_nombre_emp);
    DBMS_OUTPUT.PUT_LINE('RUN: '|| v_run);
    DBMS_OUTPUT.PUT_LINE('Sueldo: ' || v_sueldo);
    DBMS_OUTPUT.PUT_LINE('Bonificaci�n extra: '|| :b_bono_extra);
END;

--------------------------------------------------Caso 2--------------------------------------------------

SET SERVEROUTPUT ON

VAR b_run_cliennte NUMBER;
--EXEC :b_run_cliennte:=12487147;
--EXEC :b_run_cliennte:=12861354;
EXEC :b_run_cliennte:=13050258;


VAR b_renta_min NUMBER;
EXEC :b_renta_min:=800000;

DECLARE
    v_nombre_cli VARCHAR2(25);
    v_run_cli VARCHAR2(15);
    v_estd_civil VARCHAR2(10);
    v_renta_cli NUMBER;

BEGIN
    SELECT
        UPPER(c.nombre_cli || ' ' || c.appaterno_cli || ' ' || c.apmaterno_cli),
        c.numrut_cli ||'-'|| c.dvrut_cli, 
        ec.desc_estcivil,
        c.renta_cli
    INTO
        v_nombre_cli, v_run_cli, v_estd_civil, v_renta_cli
    FROM
        cliente c INNER JOIN estado_civil ec ON (c.id_estcivil=ec.id_estcivil)
    WHERE
        c.numrut_cli LIKE :b_run_cliennte;
    
    DBMS_OUTPUT.PUT_LINE(''); 
    DBMS_OUTPUT.PUT_LINE('DATOS DEL CLIENTE');
    DBMS_OUTPUT.PUT_LINE('------------------'); 
    DBMS_OUTPUT.PUT_LINE('Nombre: ' || v_nombre_cli);
    DBMS_OUTPUT.PUT_LINE('RUN: ' || v_run_cli);
    DBMS_OUTPUT.PUT_LINE('Estado Civil: ' || v_estd_civil);
    DBMS_OUTPUT.PUT_LINE('Renta : ' || TO_CHAR(v_renta_cli,'L999G999G999'));

END;

--------------------------------------------------Caso 3--------------------------------------------------

SET SERVEROUTPUT ON

VAR b_run_emp NUMBER;
--EXEC :b_run_emp:=12260812;
EXEC :b_run_emp:=11999100;

VAR b_porcentaje_all NUMBER;
EXEC :b_porcentaje_all:=8.5;

VAR b_porcentaje_rango NUMBER;
EXEC :b_porcentaje_rango:=20;

VAR b_simulacion_1 NUMBER;
VAR b_reajuste_1 NUMBER;
VAR b_simulacion_2 NUMBER;
VAR b_reajuste_2 NUMBER;

DECLARE

v_nombre_emp VARCHAR2(30);
v_run_emp VARCHAR2(10);
v_sueldo_act NUMBER(9);

BEGIN
    SELECT
        UPPER(nombre_emp || ' ' || appaterno_emp || ' ' || apmaterno_emp),
        numrut_emp || '-' || dvrut_emp,
        sueldo_emp
    INTO
        v_nombre_emp,v_run_emp,v_sueldo_act
    FROM
        empleado
    WHERE
        numrut_emp Like :b_run_emp;
    
    :b_reajuste_1:=ROUND(v_sueldo_act * (:b_porcentaje_all/100));
    :b_simulacion_1:=ROUND((v_sueldo_act + :b_reajuste_1));
    :b_reajuste_2:=ROUND(v_sueldo_act * (:b_porcentaje_rango/100));
    :b_simulacion_2:=ROUND((v_sueldo_act + :b_reajuste_2));
    
    DBMS_OUTPUT.PUT_LINE(''); 
    DBMS_OUTPUT.PUT_LINE('NOMBRE DEL EMPLEADO: '||v_nombre_emp);
    DBMS_OUTPUT.PUT_LINE('RUN: '|| v_run_emp);
    DBMS_OUTPUT.PUT_LINE('SIMULACI�N 1: Aumentar en '|| :b_porcentaje_all || '% el salario de todos los empleados');
    DBMS_OUTPUT.PUT_LINE('Sueldo actual: '||v_sueldo_act);
    DBMS_OUTPUT.PUT_LINE('Sueldo Reajustado: '|| :b_simulacion_1);
    DBMS_OUTPUT.PUT_LINE('Reajuste: '|| :b_reajuste_1);
    DBMS_OUTPUT.PUT_LINE('SIMULACI�N 2: Aumentar en '|| :b_porcentaje_rango || '% el salario de los empleados que poseen salarios entre $200.000 y $400.000');
    DBMS_OUTPUT.PUT_LINE('Sueldo actual: '||v_sueldo_act);
    DBMS_OUTPUT.PUT_LINE('Sueldo Reajustado: '|| :b_simulacion_2);
    DBMS_OUTPUT.PUT_LINE('Reajuste: '|| :b_reajuste_2);

END;

--------------------------------------------------Caso 4--------------------------------------------------

SET SERVEROUTPUT ON

VAR b_Tipo_Prop_a VARCHAR2(25);
VAR b_Tipo_Prop_b VARCHAR2(25);
VAR b_Tipo_Prop_c VARCHAR2(25);
VAR b_Tipo_Prop_d VARCHAR2(25);
VAR b_Tipo_Prop_e VARCHAR2(25);
VAR b_Tipo_Prop_f VARCHAR2(25);
VAR b_Tipo_Prop_g VARCHAR2(25);
VAR b_Tipo_Prop_h VARCHAR2(25);

EXEC :b_Tipo_Prop_a:='A';
EXEC :b_Tipo_Prop_b:='B';
EXEC :b_Tipo_Prop_c:='C';
EXEC :b_Tipo_Prop_d:='D';
EXEC :b_Tipo_Prop_e:='E';
EXEC :b_Tipo_Prop_f:='F';
EXEC :b_Tipo_Prop_g:='G';
EXEC :b_Tipo_Prop_h:='H';

DECLARE
v_cantidad_prop NUMBER;
v_valor_arriendo NUMBER;
v_descripcion VARCHAR2(25);

BEGIN
    ---------------------------- Tipo de Propiedad A----------------------------------------------------------
    SELECT
        COUNT(p.nro_propiedad),
        SUM(p.valor_arriendo),
        tp.desc_tipo_propiedad
    INTO
        v_cantidad_prop, v_valor_arriendo, v_descripcion
    FROM
        Propiedad p INNER JOIN tipo_propiedad tp ON (p.id_tipo_propiedad=tp.id_tipo_propiedad)
    WHERE
        p.id_tipo_propiedad LIKE  :b_Tipo_Prop_a
    GROUP BY
        tp.desc_tipo_propiedad;
    
    DBMS_OUTPUT.PUT_LINE(' ');  
    DBMS_OUTPUT.PUT_LINE('RESUMEN DE: '|| v_descripcion);
    DBMS_OUTPUT.PUT_LINE('Total de Propiedades: '|| v_cantidad_prop);
    DBMS_OUTPUT.PUT_LINE('Valor Total Arriendo: '|| TRIM(TO_CHAR(v_valor_arriendo,'L999G999G999')));
    
    ---------------------------- Tipo de Propiedad B----------------------------------------------------------
    SELECT
        COUNT(p.nro_propiedad),
        SUM(p.valor_arriendo),
        tp.desc_tipo_propiedad
    INTO
        v_cantidad_prop, v_valor_arriendo, v_descripcion
    FROM
        Propiedad p INNER JOIN tipo_propiedad tp ON (p.id_tipo_propiedad=tp.id_tipo_propiedad)
    WHERE
        p.id_tipo_propiedad LIKE  :b_Tipo_Prop_b
    GROUP BY
        tp.desc_tipo_propiedad;
        
    DBMS_OUTPUT.PUT_LINE('RESUMEN DE: '|| v_descripcion);
    DBMS_OUTPUT.PUT_LINE('Total de Propiedades: '|| v_cantidad_prop);
    DBMS_OUTPUT.PUT_LINE('Valor Total Arriendo: '|| TRIM(TO_CHAR(v_valor_arriendo,'L999G999G999')));
    
    ---------------------------- Tipo de Propiedad C----------------------------------------------------------
    SELECT
        COUNT(p.nro_propiedad),
        SUM(p.valor_arriendo),
        tp.desc_tipo_propiedad
    INTO
        v_cantidad_prop, v_valor_arriendo, v_descripcion
    FROM
        Propiedad p INNER JOIN tipo_propiedad tp ON (p.id_tipo_propiedad=tp.id_tipo_propiedad)
    WHERE
        p.id_tipo_propiedad LIKE  :b_Tipo_Prop_c
    GROUP BY
        tp.desc_tipo_propiedad;
        
    DBMS_OUTPUT.PUT_LINE('RESUMEN DE: '|| v_descripcion);
    DBMS_OUTPUT.PUT_LINE('Total de Propiedades: '|| v_cantidad_prop);
    DBMS_OUTPUT.PUT_LINE('Valor Total Arriendo: '|| TRIM(TO_CHAR(v_valor_arriendo,'L999G999G999')));
    
    ---------------------------- Tipo de Propiedad D----------------------------------------------------------
    SELECT
        COUNT(p.nro_propiedad),
        SUM(p.valor_arriendo),
        tp.desc_tipo_propiedad
    INTO
        v_cantidad_prop, v_valor_arriendo, v_descripcion
    FROM
        Propiedad p INNER JOIN tipo_propiedad tp ON (p.id_tipo_propiedad=tp.id_tipo_propiedad)
    WHERE
        p.id_tipo_propiedad LIKE  :b_Tipo_Prop_d
    GROUP BY
        tp.desc_tipo_propiedad;
        
    DBMS_OUTPUT.PUT_LINE('RESUMEN DE: '|| v_descripcion);
    DBMS_OUTPUT.PUT_LINE('Total de Propiedades: '|| v_cantidad_prop);
    DBMS_OUTPUT.PUT_LINE('Valor Total Arriendo: '|| TRIM(TO_CHAR(v_valor_arriendo,'L999G999G999')));
    
    ---------------------------- Tipo de Propiedad E----------------------------------------------------------
    SELECT
        COUNT(p.nro_propiedad),
        SUM(p.valor_arriendo),
        tp.desc_tipo_propiedad
    INTO
        v_cantidad_prop, v_valor_arriendo, v_descripcion
    FROM
        Propiedad p INNER JOIN tipo_propiedad tp ON (p.id_tipo_propiedad=tp.id_tipo_propiedad)
    WHERE
        p.id_tipo_propiedad LIKE  :b_Tipo_Prop_e
    GROUP BY
        tp.desc_tipo_propiedad;
        
    DBMS_OUTPUT.PUT_LINE('RESUMEN DE: '|| v_descripcion);
    DBMS_OUTPUT.PUT_LINE('Total de Propiedades: '|| v_cantidad_prop);
    DBMS_OUTPUT.PUT_LINE('Valor Total Arriendo: '|| TRIM(TO_CHAR(v_valor_arriendo,'L999G999G999')));
    
    ---------------------------- Tipo de Propiedad F----------------------------------------------------------
    SELECT
        COUNT(p.nro_propiedad),
        SUM(p.valor_arriendo),
        tp.desc_tipo_propiedad
    INTO
        v_cantidad_prop, v_valor_arriendo, v_descripcion
    FROM
        Propiedad p INNER JOIN tipo_propiedad tp ON (p.id_tipo_propiedad=tp.id_tipo_propiedad)
    WHERE
        p.id_tipo_propiedad LIKE  :b_Tipo_Prop_f
    GROUP BY
        tp.desc_tipo_propiedad;
        
    DBMS_OUTPUT.PUT_LINE('RESUMEN DE: '|| v_descripcion);
    DBMS_OUTPUT.PUT_LINE('Total de Propiedades: '|| v_cantidad_prop);
    DBMS_OUTPUT.PUT_LINE('Valor Total Arriendo: '|| TRIM(TO_CHAR(v_valor_arriendo,'L999G999G999')));
    
    
    ---------------------------- Tipo de Propiedad G----------------------------------------------------------
    SELECT
        COUNT(p.nro_propiedad),
        SUM(p.valor_arriendo),
        tp.desc_tipo_propiedad
    INTO
        v_cantidad_prop, v_valor_arriendo, v_descripcion
    FROM
        Propiedad p INNER JOIN tipo_propiedad tp ON (p.id_tipo_propiedad=tp.id_tipo_propiedad)
    WHERE
        p.id_tipo_propiedad LIKE  :b_Tipo_Prop_g
    GROUP BY
        tp.desc_tipo_propiedad;
        
    DBMS_OUTPUT.PUT_LINE('RESUMEN DE: '|| v_descripcion);
    DBMS_OUTPUT.PUT_LINE('Total de Propiedades: '|| v_cantidad_prop);
    DBMS_OUTPUT.PUT_LINE('Valor Total Arriendo: '|| TRIM(TO_CHAR(v_valor_arriendo,'L999G999G999')));
    
    
    ---------------------------- Tipo de Propiedad H----------------------------------------------------------
    SELECT
        COUNT(p.nro_propiedad),
        SUM(p.valor_arriendo),
        tp.desc_tipo_propiedad
    INTO
        v_cantidad_prop, v_valor_arriendo, v_descripcion
    FROM
        Propiedad p INNER JOIN tipo_propiedad tp ON (p.id_tipo_propiedad=tp.id_tipo_propiedad)
    WHERE
        p.id_tipo_propiedad LIKE  :b_Tipo_Prop_h
    GROUP BY
        tp.desc_tipo_propiedad;
        
    DBMS_OUTPUT.PUT_LINE('RESUMEN DE: '|| v_descripcion);
    DBMS_OUTPUT.PUT_LINE('Total de Propiedades: '|| v_cantidad_prop);
    DBMS_OUTPUT.PUT_LINE('Valor Total Arriendo: '|| TRIM(TO_CHAR(v_valor_arriendo,'L999G999G999')));
    
END;
