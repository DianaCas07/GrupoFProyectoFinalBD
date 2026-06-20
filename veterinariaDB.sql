CREATE TABLE propietario (
    id_prop SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    direccion VARCHAR(200),
    email VARCHAR(100),
    telefono VARCHAR(20)
);

CREATE TABLE especie (
    id_especie SERIAL PRIMARY KEY,
    nombre_esp VARCHAR(100) NOT NULL
);

CREATE TABLE mascota (
    id_mascota SERIAL PRIMARY KEY,
    id_prop INTEGER NOT NULL,
    id_especie INTEGER NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    fecha_nac DATE,
    peso DECIMAL(8,2),

    FOREIGN KEY (id_prop)
        REFERENCES propietario(id_prop),

    FOREIGN KEY (id_especie)
        REFERENCES especie(id_especie)
);

CREATE TABLE veterinario (
    id_veterinario SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    telefono VARCHAR(20),
    licencia VARCHAR(100) UNIQUE
);

CREATE TABLE especialidad (
    id_espec SERIAL PRIMARY KEY,
    nombre_espec VARCHAR(100) NOT NULL
);

CREATE TABLE hoja_de_vida (
    id_hoja SERIAL PRIMARY KEY,
    id_veterinario INTEGER NOT NULL UNIQUE,

    FOREIGN KEY (id_veterinario)
        REFERENCES veterinario(id_veterinario)
);

CREATE TABLE hoja_vida_especialidad (
    id_hoja INTEGER,
    id_espec INTEGER,

    PRIMARY KEY (id_hoja, id_espec),

    FOREIGN KEY (id_hoja)
        REFERENCES hoja_de_vida(id_hoja),

    FOREIGN KEY (id_espec)
        REFERENCES especialidad(id_espec)
);

CREATE TABLE cita (
    id_cita SERIAL PRIMARY KEY,
    id_mascota INTEGER NOT NULL,
    id_veterinario INTEGER NOT NULL,
    fecha_hora TIMESTAMP NOT NULL,
    motivo TEXT,

    FOREIGN KEY (id_mascota)
        REFERENCES mascota(id_mascota),

    FOREIGN KEY (id_veterinario)
        REFERENCES veterinario(id_veterinario)
);

CREATE TABLE diagnostico (
    id_diagnostico SERIAL PRIMARY KEY,
    id_cita INTEGER NOT NULL,
    fecha DATE,
    descripcion TEXT,

    FOREIGN KEY (id_cita)
        REFERENCES cita(id_cita)
);

CREATE TABLE tratamiento (
    id_tratamiento SERIAL PRIMARY KEY,
    id_diagnostico INTEGER NOT NULL,
    descripcion TEXT,
    duracion VARCHAR(100),

    FOREIGN KEY (id_diagnostico)
        REFERENCES diagnostico(id_diagnostico)
);

CREATE TABLE medicamento (
    id_medicamento SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    presentacion VARCHAR(100),
    dosis VARCHAR(100)
);

CREATE TABLE tipo_procedimiento (
    id_tipo_proc SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT
);

CREATE TABLE procedimiento (
    id_proc SERIAL PRIMARY KEY,
    id_tipo_proc INTEGER NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    duracion VARCHAR(100),
    costo DECIMAL(10,2),

    FOREIGN KEY (id_tipo_proc)
        REFERENCES tipo_procedimiento(id_tipo_proc)
);

CREATE TABLE factura (
    id_fact SERIAL PRIMARY KEY,
    id_cita INTEGER NOT NULL UNIQUE,
    fecha_emit DATE,
    total DECIMAL(10,2),
    estado VARCHAR(50),
    impuesto DECIMAL(10,2),

    FOREIGN KEY (id_cita)
        REFERENCES cita(id_cita)
);

CREATE TABLE det_factura (
    id_detalle SERIAL PRIMARY KEY,
    id_fact INTEGER NOT NULL,
    descripcion TEXT,
    cantidad INTEGER,
    precio_unitario DECIMAL(10,2),
    subtotal DECIMAL(10,2),

    FOREIGN KEY (id_fact)
        REFERENCES factura(id_fact)
);

CREATE TABLE tratamiento_medicamento (
    id_tratamiento INTEGER,
    id_medicamento INTEGER,

    PRIMARY KEY (id_tratamiento, id_medicamento),

    FOREIGN KEY (id_tratamiento)
        REFERENCES tratamiento(id_tratamiento),

    FOREIGN KEY (id_medicamento)
        REFERENCES medicamento(id_medicamento)
);

CREATE TABLE mascota_medicamento_alergia (
    id_mascota INTEGER,
    id_medicamento INTEGER,

    PRIMARY KEY (id_mascota, id_medicamento),

    FOREIGN KEY (id_mascota)
        REFERENCES mascota(id_mascota),

    FOREIGN KEY (id_medicamento)
        REFERENCES medicamento(id_medicamento)
);

CREATE TABLE diagnostico_procedimiento (
    id_diagnostico INTEGER,
    id_proc INTEGER,

    PRIMARY KEY (id_diagnostico, id_proc),

    FOREIGN KEY (id_diagnostico)
        REFERENCES diagnostico(id_diagnostico),

    FOREIGN KEY (id_proc)
        REFERENCES procedimiento(id_proc)
);

CREATE TABLE factura_procedimiento (
    id_fact INTEGER,
    id_proc INTEGER,

    PRIMARY KEY (id_fact, id_proc),

    FOREIGN KEY (id_fact)
        REFERENCES factura(id_fact),

    FOREIGN KEY (id_proc)
        REFERENCES procedimiento(id_proc)
);

CREATE TABLE factura_medicamento (
    id_fact INTEGER,
    id_medicamento INTEGER,

    PRIMARY KEY (id_fact, id_medicamento),

    FOREIGN KEY (id_fact)
        REFERENCES factura(id_fact),

    FOREIGN KEY (id_medicamento)
        REFERENCES medicamento(id_medicamento)
);