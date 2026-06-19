--triggers y funciones

CREATE OR REPLACE FUNCTION obtener_historial_clinico(p_id_mascota INT)
RETURNS TABLE (
    nombre_mascota VARCHAR,           
    fecha_cita TIMESTAMP,
    motivo_consulta TEXT,
    veterinario_atendio VARCHAR(100),
    diagnostico_descripcion TEXT,
    tratamiento_indicado TEXT,
    medicamento_recetado VARCHAR(100),
    procedimiento_realizado VARCHAR(100)
) 
AS $$
BEGIN
    -- Verificar primero si la mascota existe
    IF NOT EXISTS (SELECT 1 FROM mascota WHERE id_mascota = p_id_mascota) THEN
        RAISE EXCEPTION 'La mascota con ID % no existe en la base de datos.', p_id_mascota;
    END IF;

    RETURN QUERY
    SELECT 
        m_ref.nombre::varchar,         
        c.fecha_hora,
        c.motivo,
        v.nombre AS veterinario_atendio,
        d.descripcion AS diagnostico_descripcion,
        t.descripcion AS tratamiento_indicado,
        COALESCE(m.nombre, 'Ninguno') AS medicamento_recetado,
        COALESCE(p.nombre, 'Ninguno') AS procedimiento_realizado
    FROM cita c
    JOIN mascota m_ref ON c.id_mascota = m_ref.id_mascota 
    JOIN veterinario v ON c.id_veterinario = v.id_veterinario
    LEFT JOIN diagnostico d ON c.id_cita = d.id_cita
    LEFT JOIN tratamiento t ON d.id_diagnostico = t.id_diagnostico
    LEFT JOIN tratamiento_medicamento tm ON t.id_tratamiento = tm.id_tratamiento
    LEFT JOIN medicamento m ON tm.id_medicamento = m.id_medicamento
    LEFT JOIN diagnostico_procedimiento dp ON d.id_diagnostico = dp.id_diagnostico
    LEFT JOIN procedimiento p ON dp.id_proc = p.id_proc
    WHERE c.id_mascota = p_id_mascota
    ORDER BY c.fecha_hora DESC; 
END;
$$ LANGUAGE plpgsql;


--funcion del trigger calcular subtotal
create or replace function fn_calcular_subtotal()
returns trigger
language plpgsql
as $$
begin
	new.subtotal := new.cantidad * new.precio_unitario;
	return new;
end;
$$;

--trigger calcular_subtotal
create trigger tr_calcular_subtotal
before insert on det_factura
for each row
execute function fn_calcular_subtotal();


--funcion del trigger de validacion de peso positivo
create or replace function fn_validar_peso_positivo()
returns trigger
language plpgsql
as $$
begin
	if new.peso < 0 then
		new.peso := new.peso * -1;
	end if;
	return new;
end;
$$;

--trigger validar peso positivo
create trigger tr_validar_peso_positivo
before insert on mascota
for each row
execute function fn_validar_peso_positivo();

--se puede validar el peso positivo con un check tambien
ALTER TABLE mascota
ADD CONSTRAINT chk_peso_positivo
CHECK (peso > 0);


--funcion del trigger de alerta de mascota alergica
create or replace function fn_alerta_mascota_alergica()
returns trigger
language plpgsql
as $$
declare
	v_id_mascota integer;
begin
	SELECT c.id_mascota
	INTO v_id_mascota
	FROM tratamiento t
	JOIN diagnostico d
	    ON t.id_diagnostico = d.id_diagnostico
	JOIN cita c
	    ON d.id_cita = c.id_cita
	WHERE t.id_tratamiento = NEW.id_tratamiento;

    IF EXISTS (
        SELECT 1
        FROM mascota_medicamento_alergia mma
        WHERE mma.id_mascota = v_id_mascota
        AND mma.id_medicamento = NEW.id_medicamento
    ) THEN

        RAISE EXCEPTION
        'La mascota es alergica a este medicamento, cambiar medicamento';
end if;
	return new;
end;
$$;

 
--trigger mascota alergica
create trigger tr_alerta_mascota_alergica
before insert on tratamiento_medicamento
for each row
execute function fn_alerta_mascota_alergica();