-- =====================================================
-- TRABAJO: Índices y restricciones en Oracle
-- Autores: Joger Castillo, Ray Gonzalez
-- Asignatura: Bases de datos avanzadas
-- =====================================================

SET SERVEROUTPUT ON;
SET LINESIZE 150;

-- =====================================================
-- 1. Consultar índices disponibles (vía constraints PK/UK)
-- =====================================================

SELECT constraint_name AS index_name, 
       table_name, 
       CASE constraint_type 
           WHEN 'P' THEN 'PRIMARY KEY'
           WHEN 'U' THEN 'UNIQUE'
       END AS index_type,
       status
FROM user_constraints
WHERE table_name IN ('EMPLOYEES', 'DEPARTMENTS')
AND constraint_type IN ('P', 'U')
ORDER BY table_name, constraint_name;

-- =====================================================
-- 2. Ver todas las restricciones (para referencia)
-- =====================================================

SELECT constraint_name, table_name, constraint_type, status
FROM user_constraints
WHERE table_name IN ('EMPLOYEES', 'DEPARTMENTS')
ORDER BY table_name, constraint_name;

-- =====================================================
-- 3. Desactivar restricciones (con manejo de dependencias)
-- =====================================================

BEGIN
    -- Desactivar FOREIGN KEY que dependen de EMPLOYEES
    FOR c IN (SELECT constraint_name, table_name 
              FROM user_constraints 
              WHERE constraint_type = 'R' 
              AND table_name IN ('DEPARTMENTS', 'JOB_HISTORY'))
    LOOP
        EXECUTE IMMEDIATE 'ALTER TABLE ' || c.table_name || 
                          ' DISABLE CONSTRAINT ' || c.constraint_name;
    END LOOP;
    
    -- Desactivar PRIMARY KEY y UNIQUE de EMPLOYEES
    FOR c IN (SELECT constraint_name, table_name 
              FROM user_constraints 
              WHERE table_name = 'EMPLOYEES' 
              AND constraint_type IN ('P', 'U'))
    LOOP
        EXECUTE IMMEDIATE 'ALTER TABLE ' || c.table_name || 
                          ' DISABLE CONSTRAINT ' || c.constraint_name;
    END LOOP;
    
    -- Desactivar resto de restricciones de DEPARTMENTS
    FOR c IN (SELECT constraint_name, table_name 
              FROM user_constraints 
              WHERE table_name = 'DEPARTMENTS')
    LOOP
        EXECUTE IMMEDIATE 'ALTER TABLE ' || c.table_name || 
                          ' DISABLE CONSTRAINT ' || c.constraint_name;
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('Todas las restricciones desactivadas');
END;
/

-- Verificar desactivación
SELECT constraint_name, table_name, status
FROM user_constraints
WHERE table_name IN ('EMPLOYEES', 'DEPARTMENTS')
ORDER BY table_name;

-- =====================================================
-- 4. Insertar tuplas que violan restricciones
-- =====================================================

-- Empleado sin department_id (viola FK)
INSERT INTO employees (employee_id, first_name, last_name, email, hire_date, job_id)
VALUES (999, 'Prueba', 'SinDepto', 'prueba1@x.com', SYSDATE, 'SA_REP');

-- Empleado con email duplicado (viola UNIQUE)
INSERT INTO employees (employee_id, first_name, last_name, email, hire_date, job_id)
VALUES (998, 'Prueba', 'EmailDup', 'SKING', SYSDATE, 'SA_REP');

-- Departamento de prueba
INSERT INTO departments (department_id, department_name, location_id)
VALUES (999, 'Depto Prueba', 1700);

COMMIT;

-- Verificar inserciones
SELECT employee_id, first_name, last_name, email 
FROM employees 
WHERE employee_id IN (998, 999);

SELECT * FROM departments WHERE department_id = 999;

-- =====================================================
-- 5. Re-activar restricciones (algunas fallarán)
-- =====================================================

BEGIN
    -- Activar PK y UNIQUE de EMPLOYEES
    FOR c IN (SELECT constraint_name, table_name 
              FROM user_constraints 
              WHERE table_name = 'EMPLOYEES' 
              AND constraint_type IN ('P', 'U'))
    LOOP
        BEGIN
            EXECUTE IMMEDIATE 'ALTER TABLE ' || c.table_name || 
                              ' ENABLE CONSTRAINT ' || c.constraint_name;
            DBMS_OUTPUT.PUT_LINE('Activada: ' || c.constraint_name);
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('FALLÓ: ' || c.constraint_name || ' - ' || SQLERRM);
        END;
    END LOOP;
    
    -- Activar FK de DEPARTMENTS y JOB_HISTORY
    FOR c IN (SELECT constraint_name, table_name 
              FROM user_constraints 
              WHERE constraint_type = 'R' 
              AND table_name IN ('DEPARTMENTS', 'JOB_HISTORY'))
    LOOP
        BEGIN
            EXECUTE IMMEDIATE 'ALTER TABLE ' || c.table_name || 
                              ' ENABLE CONSTRAINT ' || c.constraint_name;
            DBMS_OUTPUT.PUT_LINE('Activada: ' || c.constraint_name);
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('FALLÓ: ' || c.constraint_name || ' - ' || SQLERRM);
        END;
    END LOOP;
    
    -- Activar resto de restricciones de DEPARTMENTS
    FOR c IN (SELECT constraint_name, table_name 
              FROM user_constraints 
              WHERE table_name = 'DEPARTMENTS')
    LOOP
        BEGIN
            EXECUTE IMMEDIATE 'ALTER TABLE ' || c.table_name || 
                              ' ENABLE CONSTRAINT ' || c.constraint_name;
            DBMS_OUTPUT.PUT_LINE('Activada: ' || c.constraint_name);
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('FALLÓ: ' || c.constraint_name || ' - ' || SQLERRM);
        END;
    END LOOP;
END;
/

-- Verificar estado final
SELECT constraint_name, table_name, status
FROM user_constraints
WHERE table_name IN ('EMPLOYEES', 'DEPARTMENTS')
ORDER BY table_name;

-- =====================================================
-- 6. Crear DEPARTMENTS2
-- =====================================================
CREATE TABLE departments2 AS SELECT * FROM departments WHERE 1=0;
SELECT COUNT(*) FROM departments2;

-- =====================================================
-- 7. Insertar tres tuplas en DEPARTMENTS2
-- =====================================================
INSERT INTO departments2 (department_id, department_name, manager_id, location_id)
VALUES (300, 'Depto Ray', 100, 1700);

INSERT INTO departments2 (department_id, department_name, manager_id, location_id)
VALUES (301, 'Depto Joger', 101, 1800);

INSERT INTO departments2 (department_id, department_name, manager_id, location_id)
VALUES (302, 'Depto Prueba', NULL, 1900);

COMMIT;
SELECT * FROM departments2;

-- =====================================================
-- 8. Bloque anónimo con transacción
-- =====================================================
DECLARE
    v_count NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== INICIO DE TRANSACCION ===');
    
    INSERT INTO departments2 VALUES (303, 'Depto Transaccion', 102, 2000);
    UPDATE departments2 SET location_id = 2500 WHERE department_name = 'Depto Ray';
    
    SELECT COUNT(*) INTO v_count FROM departments2;
    DBMS_OUTPUT.PUT_LINE('Registros en departments2: ' || v_count);
    
    DBMS_OUTPUT.PUT_LINE('=== FIN DE TRANSACCION ===');
    COMMIT;
END;
/
SELECT * FROM departments2;

-- =====================================================
-- 9. Cierre y reapertura de sesión (MANUAL)
--    Cerra la conexión en SQL Developer y volvé a conectar.
--    Luego ejecutá: SELECT * FROM departments2;
-- =====================================================

-- =====================================================
-- 10. Ejemplo de ROLLBACK
-- =====================================================
INSERT INTO departments2 VALUES (304, 'Depto a Eliminar', 103, 2100);
SELECT * FROM departments2 WHERE department_id = 304;
ROLLBACK;
SELECT * FROM departments2 WHERE department_id = 304;

-- =====================================================
-- 11. Modo de los archivos Redo
-- =====================================================
SELECT log_mode FROM v$database;

-- =====================================================
-- 12. Limpieza final (OPCIONAL - ejecutar al terminar)
-- =====================================================
-- DELETE FROM employees WHERE employee_id IN (998, 999);
-- DELETE FROM departments WHERE department_id = 999;
-- DROP TABLE departments2 PURGE;
-- COMMIT;