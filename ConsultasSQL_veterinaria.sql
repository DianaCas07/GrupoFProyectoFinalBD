

--1. Historial clínico completo de una mascota
--util para: Ver todo lo que ha pasado con un paciente en una sola vista.


SELECT m.nombre AS mascota, c.fecha_hora, d.descripcion AS diagnostico, t.descripcion AS tratamiento
FROM mascota m
JOIN cita c ON m.id_mascota = c.id_mascota
JOIN diagnostico d ON c.id_cita = d.id_cita
JOIN tratamiento t ON d.id_diagnostico = t.id_diagnostico
WHERE m.nombre = 'Mota';

select id_mascota from cita;
select nombre from mascota where id_mascota  = 12; -- lo dejare por si quiere consultar alguna mascota

--2. Facturación total por propietario
--util para: Saber cuánto ha gastado un cliente en total en la clínica.

SELECT p.nombre AS propietario, SUM(f.total) AS gasto_total
FROM propietario p
JOIN mascota m ON p.id_prop = m.id_prop
JOIN cita c ON m.id_mascota = c.id_mascota
JOIN factura f ON c.id_cita = f.id_cita
GROUP BY p.nombre;


--3. Listado de mascotas con sus medicamentos recetados
--util para: Revisar el historial de medicamentos de un paciente específico.

SELECT m.nombre AS mascota, med.nombre AS medicamento, med.dosis
FROM mascota m
JOIN cita c ON m.id_mascota = c.id_mascota
JOIN diagnostico d ON c.id_cita = d.id_cita
JOIN tratamiento t ON d.id_diagnostico = t.id_diagnostico
JOIN tratamiento_medicamento tm ON t.id_tratamiento = tm.id_tratamiento
JOIN medicamento med ON tm.id_medicamento = med.id_medicamento;

--4. Vets y sus especialidades
--util para: Saber qué médico es el mejor para asignar una cita según la especialidad necesaria.

SELECT v.nombre AS veterinario, e.nombre_espec AS especialidad
FROM veterinario v
JOIN hoja_de_vida hv ON v.id_veterinario = hv.id_veterinario
JOIN hoja_vida_especialidad hve ON hv.id_hoja = hve.id_hoja
JOIN especialidad e ON hve.id_espec = e.id_espec;


--5. Alertas de alergias
--util para: Evitar accidentes al recetar un medicamento.

SELECT m.nombre AS mascota, med.nombre AS medicamento_prohibido
FROM mascota m
JOIN mascota_medicamento_alergia mma ON m.id_mascota = mma.id_mascota
JOIN medicamento med ON mma.id_medicamento = med.id_medicamento;

--6. Procedimientos realizados en una fecha específica
--util para: Reporte diario de actividades de la clínica.

SELECT m.nombre AS mascota, proc.nombre AS procedimiento, f.fecha_emit
FROM mascota m
JOIN cita c ON m.id_mascota = c.id_mascota
JOIN factura f ON c.id_cita = f.id_cita
JOIN factura_procedimiento fp ON f.id_fact = fp.id_fact
JOIN procedimiento proc ON fp.id_proc = proc.id_proc
WHERE f.fecha_emit = '2026-01-20';

select fecha_hora from cita;


--7. Citas pendientes por veterinario
--util para: Organizar la agenda diaria de los médicos.
SELECT v.nombre AS veterinario, m.nombre AS paciente, c.fecha_hora, c.motivo
FROM veterinario v
JOIN cita c ON v.id_veterinario = c.id_veterinario
JOIN mascota m ON c.id_mascota = m.id_mascota
ORDER BY c.fecha_hora ASC;


--8. Ingresos por tipo de procedimiento
--util para: Saber qué servicio deja más dinero a la clínica.

SELECT tp.nombre AS tipo_procedimiento, SUM(p.costo) AS ingresos_totales
FROM tipo_procedimiento tp
JOIN procedimiento p ON tp.id_tipo_proc = p.id_tipo_proc
JOIN factura_procedimiento fp ON p.id_proc = fp.id_proc
GROUP BY tp.nombre;


--9. Inventario de medicamentos usados
--util para: Saber qué medicamentos se usan más y necesitan reabastecimiento.
SELECT med.nombre, COUNT(fm.id_medicamento) AS veces_facturado
FROM medicamento med
JOIN factura_medicamento fm ON med.id_medicamento = fm.id_medicamento
GROUP BY med.nombre
ORDER BY veces_facturado DESC;

--10. Propietarios con más de una mascota
--util para: Campañas de marketing o fidelización.

SELECT p.nombre AS propietario, COUNT(m.id_mascota) AS cantidad_mascotas
FROM propietario p
JOIN mascota m ON p.id_prop = m.id_prop
GROUP BY p.nombre
HAVING COUNT(m.id_mascota) > 1;



--===============CONSULTAS RECOMENDADAS POR EL INGENUERO===============

--11. Mascotas más atendidas por mes
--Útil para: Identificar temporadas de alta demanda de consultas.

SELECT m.nombre AS mascota, 
       EXTRACT(MONTH FROM c.fecha_hora) AS mes, 
       COUNT(c.id_cita) AS total_citas
FROM mascota m
JOIN cita c ON m.id_mascota = c.id_mascota
GROUP BY m.nombre, mes
ORDER BY mes, total_citas DESC;

--12. Veterinario con mayor número de citas en el trimestre
--Útil para: Evaluación de rendimiento y carga de trabajo.

SELECT v.nombre AS veterinario, COUNT(c.id_cita) AS total_citas
FROM veterinario v
JOIN cita c ON v.id_veterinario = c.id_veterinario
WHERE c.fecha_hora >= CURRENT_DATE - INTERVAL '3 months'
GROUP BY v.nombre
ORDER BY total_citas DESC
LIMIT 1; -- todos tienen 1 ;)


--13. Medicamentos prescritos con mayor frecuencia
--Útil para: Gestión de inventario y compras a proveedores.

SELECT med.nombre AS medicamento, COUNT(tm.id_medicamento) AS veces_prescrito
FROM medicamento med
JOIN tratamiento_medicamento tm ON med.id_medicamento = tm.id_medicamento
GROUP BY med.nombre
ORDER BY veces_prescrito DESC;

--14. Ingresos totales por especialidad veterinaria
--Útil para: Saber qué ramas de la medicina veterinaria son más rentables para la clínica.

SELECT e.nombre_espec AS especialidad, SUM(f.total) AS ingresos_totales
FROM especialidad e
JOIN hoja_vida_especialidad hve ON e.id_espec = hve.id_espec
JOIN hoja_de_vida hv ON hve.id_hoja = hv.id_hoja
JOIN veterinario v ON hv.id_veterinario = v.id_veterinario
JOIN cita c ON v.id_veterinario = c.id_veterinario
JOIN factura f ON c.id_cita = f.id_cita
GROUP BY e.nombre_espec
ORDER BY ingresos_totales DESC;

--15. Propietarios cuyas mascotas no han asistido a citas en los últimos 6 meses
--Útil para: Campañas de marketing de "recuperación de clientes" (recordatorios de vacunas o chequeos).


SELECT DISTINCT p.nombre AS propietario, p.email
FROM propietario p
JOIN mascota m ON p.id_prop = m.id_prop
WHERE NOT EXISTS (
    SELECT 1 
    FROM cita c 
    WHERE c.id_mascota = m.id_mascota 
    AND c.fecha_hora >= CURRENT_DATE - INTERVAL '6 months'
);
