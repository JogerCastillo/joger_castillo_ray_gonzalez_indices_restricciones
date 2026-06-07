# Trabajo: Índices y restricciones en Oracle

**Alumnos:** Joger Castillo, Ray Gonzalez  
**Asignatura:** Bases de Datos Avanzadas  
**Fecha:** Junio 2026

## Descripción

Este trabajo práctico explora los mecanismos de índices y restricciones en Oracle 21c utilizando el esquema HR. Se realizaron las siguientes tareas:

- Consulta de índices disponibles en EMPLOYEES y DEPARTMENTS
- Desactivación de restricciones
- Inserción de tuplas que violan restricciones
- Re-activación de restricciones (algunas fallan intencionalmente)
- Creación de tabla DEPARTMENTS2 y operaciones con transacciones
- Ejemplo práctico de COMMIT y ROLLBACK
- Explicación de archivos Redo en Oracle

## Contenido del repositorio

- `script_completo.sql` - Script SQL con todos los comandos ejecutados
- `memoria_indices_restricciones.pdf` - Memoria del trabajo con capturas y explicaciones

## Requisitos

- Oracle Database 21c XE (o superior)
- SQL Developer
- Esquema HR instalado

## Ejecución

1. Conectarse a SQL Developer con el usuario HR
2. Ejecutar el script `script_completo.sql` sección por sección
3. Seguir el orden indicado en la memoria

## Nota

El script incluye comandos que fallan intencionalmente para demostrar el comportamiento de Oracle al reactivar restricciones con datos inválidos.
