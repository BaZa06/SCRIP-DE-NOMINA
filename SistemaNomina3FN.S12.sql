--  SISTEMA DE NÓMINA — SQL SERVER 2022

USE master;
GO

IF DB_ID('SistemaNomina3FN') IS NOT NULL
BEGIN
    ALTER DATABASE SistemaNomina3FN
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE SistemaNomina3FN;
END
GO

CREATE DATABASE SistemaNomina3FN;
GO

USE SistemaNomina3FN;
GO

--  USUARIOS DE BASE DE DATOS

CREATE USER usr_rrhh       WITHOUT LOGIN;
CREATE USER usr_nomina     WITHOUT LOGIN;
CREATE USER usr_catalogos  WITHOUT LOGIN;
CREATE USER usr_fiscal     WITHOUT LOGIN;
CREATE USER usr_operaciones WITHOUT LOGIN;
CREATE USER usr_seguridad  WITHOUT LOGIN;
GO

CREATE SCHEMA RRHH        AUTHORIZATION usr_rrhh;
GO
CREATE SCHEMA NOMINA      AUTHORIZATION usr_nomina;
GO
CREATE SCHEMA CATALOGOS   AUTHORIZATION usr_catalogos;
GO
CREATE SCHEMA FISCAL      AUTHORIZATION usr_fiscal;
GO
CREATE SCHEMA OPERACIONES AUTHORIZATION usr_operaciones;
GO
CREATE SCHEMA SEGURIDAD   AUTHORIZATION usr_seguridad;
GO

--  ESQUEMA: RRHH

-- 1. ROL_EMPLEADO
CREATE TABLE RRHH.Rol_Empleado (
    id_rol      INT          IDENTITY(1,1),
    nombre_rol  VARCHAR(80)  NOT NULL,
    descripcion VARCHAR(200) NULL,
    is_active   BIT          CONSTRAINT df_RolEmpleado_is_active  DEFAULT 1         NOT NULL,
    created_at  DATETIME     CONSTRAINT df_RolEmpleado_created_at DEFAULT GETDATE() NOT NULL,
    updated_at  DATETIME     NULL,
    deleted_at  DATETIME     NULL,
    CONSTRAINT pk_Rol_Empleado PRIMARY KEY (id_rol),
    CONSTRAINT uq_Rol_nombre   UNIQUE (nombre_rol)
);
GO

-- 2. CARGO
CREATE TABLE RRHH.Cargo (
    id_cargo               INT           IDENTITY(1,1),
    nombre_cargo           VARCHAR(80)   NOT NULL,
    descripcion_cargo      VARCHAR(500)  NULL,
    salario_base           DECIMAL(10,2) NOT NULL,
    salario_minimo         DECIMAL(10,2) NOT NULL,
    salario_maximo         DECIMAL(10,2) NOT NULL,
    salario_extraordinario DECIMAL(10,2) NULL,
    is_active              BIT           CONSTRAINT df_Cargo_is_active  DEFAULT 1         NOT NULL,
    created_at             DATETIME      CONSTRAINT df_Cargo_created_at DEFAULT GETDATE() NOT NULL,
    updated_at             DATETIME      NULL,
    deleted_at             DATETIME      NULL,
    CONSTRAINT pk_Cargo           PRIMARY KEY (id_cargo),
    CONSTRAINT uq_Cargo_nombre    UNIQUE (nombre_cargo),
    CONSTRAINT ck_Cargo_salbase   CHECK (salario_base   > 0),
    CONSTRAINT ck_Cargo_salmin    CHECK (salario_minimo > 0),
    CONSTRAINT ck_Cargo_salext    CHECK (salario_extraordinario IS NULL OR salario_extraordinario > 0),
    CONSTRAINT ck_Cargo_salmaximo CHECK (salario_maximo >= salario_base)
);
GO

-- 3. EMPLEADO
CREATE TABLE RRHH.Empleado (
    id_empleado      INT           IDENTITY(1,1),
    primer_nombre    VARCHAR(60)   NOT NULL,
    segundo_nombre   VARCHAR(60)   NULL,
    primer_apellido  VARCHAR(60)   NOT NULL,
    segundo_apellido VARCHAR(60)   NULL,
    sexo             CHAR(1)       NOT NULL,
    fecha_nacimiento DATE          NOT NULL,
    ciudad           VARCHAR(80)   NOT NULL,
    estado_civil     VARCHAR(20)   NOT NULL,
    alergias         VARCHAR(200)  NULL,
    numero_inss      VARCHAR(20)   NULL,
    cedula           VARCHAR(20)   NOT NULL,
    telefono         VARCHAR(20)   NULL,
    correo           VARCHAR(100)  NULL,
    is_active        BIT           CONSTRAINT df_Empleado_is_active  DEFAULT 1         NOT NULL,
    created_at       DATETIME      CONSTRAINT df_Empleado_created_at DEFAULT GETDATE() NOT NULL,
    updated_at       DATETIME      NULL,
    deleted_at       DATETIME      NULL,
    CONSTRAINT pk_Empleado        PRIMARY KEY (id_empleado),
    CONSTRAINT uq_Empleado_inss   UNIQUE (numero_inss),
    CONSTRAINT uq_Empleado_ced    UNIQUE (cedula),
    CONSTRAINT ck_Empleado_sexo   CHECK (sexo IN ('M','F')),
    CONSTRAINT ck_Empleado_ecivil CHECK (estado_civil IN (
        'Soltero','Casado','Union de hecho','Divorciado','Viudo'))
);
GO

-- 4. EMPLEADO_CARGO
CREATE TABLE RRHH.Empleado_Cargo (
    id_emp_cargo     INT           IDENTITY(1,1),
    id_empleado      INT           NOT NULL,
    id_cargo         INT           NOT NULL,
    salario_asignado DECIMAL(10,2) NOT NULL,
    fecha_inicio     DATE          NOT NULL,
    fecha_fin        DATE          NULL,
    is_active        BIT           CONSTRAINT df_EmpCargo_is_active  DEFAULT 1         NOT NULL,
    created_at       DATETIME      CONSTRAINT df_EmpCargo_created_at DEFAULT GETDATE() NOT NULL,
    updated_at       DATETIME      NULL,
    deleted_at       DATETIME      NULL,
    CONSTRAINT pk_Empleado_Cargo       PRIMARY KEY (id_emp_cargo),
    CONSTRAINT fk_EmpCargo_Empleado    FOREIGN KEY (id_empleado) REFERENCES RRHH.Empleado(id_empleado),
    CONSTRAINT fk_EmpCargo_Cargo       FOREIGN KEY (id_cargo)    REFERENCES RRHH.Cargo(id_cargo),
    CONSTRAINT ck_EmpCargo_salasignado CHECK (salario_asignado > 0),
    CONSTRAINT ck_EmpCargo_Fechas      CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio)
);
GO

--  ESQUEMA: CATALOGOS

-- 5. CATEGORIA_PERCEPCION
CREATE TABLE CATALOGOS.Categoria_Percepcion (
    id_categoria_percep INT          IDENTITY(1,1),
    nombre              VARCHAR(80)  NOT NULL,
    aplica_impuesto     BIT          NOT NULL DEFAULT 1,
    descripcion         VARCHAR(200) NULL,
    is_active           BIT          CONSTRAINT df_CatPerc_is_active  DEFAULT 1         NOT NULL,
    created_at          DATETIME     CONSTRAINT df_CatPerc_created_at DEFAULT GETDATE() NOT NULL,
    updated_at          DATETIME     NULL,
    deleted_at          DATETIME     NULL,
    CONSTRAINT pk_Categoria_Percepcion PRIMARY KEY (id_categoria_percep),
    CONSTRAINT uq_CatPercep_nombre     UNIQUE (nombre)
);
GO

-- 6. CATEGORIA_DEDUCCION
CREATE TABLE CATALOGOS.Categoria_Deduccion (
    id_categoria_ded INT          IDENTITY(1,1),
    nombre           VARCHAR(80)  NOT NULL,
    porcentaje       DECIMAL(5,2) NULL,
    es_obligatoria   BIT          NOT NULL DEFAULT 0,
    descripcion      VARCHAR(200) NULL,
    is_active        BIT          CONSTRAINT df_CatDed_is_active  DEFAULT 1         NOT NULL,
    created_at       DATETIME     CONSTRAINT df_CatDed_created_at DEFAULT GETDATE() NOT NULL,
    updated_at       DATETIME     NULL,
    deleted_at       DATETIME     NULL,
    CONSTRAINT pk_Categoria_Deduccion PRIMARY KEY (id_categoria_ded),
    CONSTRAINT uq_CatDed_nombre       UNIQUE (nombre),
    CONSTRAINT ck_CatDed_pct          CHECK (porcentaje IS NULL OR porcentaje BETWEEN 0 AND 100)
);
GO

-- 7. TIPO_INCIDENCIA
CREATE TABLE CATALOGOS.Tipo_Incidencia (
    id_tipo_incidencia INT         IDENTITY(1,1),
    nombre_tipo        VARCHAR(60) NOT NULL,
    categoria          VARCHAR(30) NOT NULL DEFAULT 'Ninguna',
    afecta_salario     BIT         NOT NULL DEFAULT 1,
    is_active          BIT         CONSTRAINT df_TipoInc_is_active  DEFAULT 1         NOT NULL,
    created_at         DATETIME    CONSTRAINT df_TipoInc_created_at DEFAULT GETDATE() NOT NULL,
    updated_at         DATETIME    NULL,
    deleted_at         DATETIME    NULL,
    CONSTRAINT pk_Tipo_Incidencia PRIMARY KEY (id_tipo_incidencia),
    CONSTRAINT uq_TipoInc_nombre  UNIQUE (nombre_tipo),
    CONSTRAINT ck_TipoInc_cat     CHECK (categoria IN ('Percepcion','Deduccion','Ninguna'))
);
GO

-- 8. TIPO_APORTE
CREATE TABLE CATALOGOS.Tipo_Aporte (
    id_tipo_aporte INT          IDENTITY(1,1),
    nombre_aporte  VARCHAR(60)  NOT NULL,
    porcentaje     DECIMAL(5,2) NOT NULL,
    descripcion    VARCHAR(200) NULL,
    is_active      BIT          CONSTRAINT df_TipoAp_is_active  DEFAULT 1         NOT NULL,
    created_at     DATETIME     CONSTRAINT df_TipoAp_created_at DEFAULT GETDATE() NOT NULL,
    updated_at     DATETIME     NULL,
    deleted_at     DATETIME     NULL,
    CONSTRAINT pk_Tipo_Aporte    PRIMARY KEY (id_tipo_aporte),
    CONSTRAINT uq_TipoAporte_nom UNIQUE (nombre_aporte),
    CONSTRAINT ck_TipoAporte_pct CHECK (porcentaje BETWEEN 0 AND 100)
);
GO

-- 9. TIPO_PRESTACION
CREATE TABLE CATALOGOS.Tipo_Prestacion (
    id_tipo_prestacion INT          IDENTITY(1,1),
    nombre_prestacion  VARCHAR(60)  NOT NULL,
    regla_calculo      VARCHAR(200) NOT NULL,
    descripcion        VARCHAR(200) NULL,
    is_active          BIT          CONSTRAINT df_TipoPresta_is_active  DEFAULT 1         NOT NULL,
    created_at         DATETIME     CONSTRAINT df_TipoPresta_created_at DEFAULT GETDATE() NOT NULL,
    updated_at         DATETIME     NULL,
    deleted_at         DATETIME     NULL,
    CONSTRAINT pk_Tipo_Prestacion   PRIMARY KEY (id_tipo_prestacion),
    CONSTRAINT uq_TipoPresta_nombre UNIQUE (nombre_prestacion)
);
GO

--  ESQUEMA: FISCAL

-- 10. TRAMO_IR  (Ley 822 Nicaragua)
CREATE TABLE FISCAL.Tramo_IR (
    id_tramo              INT           IDENTITY(1,1),
    ingreso_anual_desde   DECIMAL(12,2) NOT NULL,
    ingreso_anual_hasta   DECIMAL(12,2) NULL,
    horas_laborales_desde DECIMAL(8,2)  NULL,
    tasa_marginal_pct     DECIMAL(5,2)  NOT NULL,
    impuesto_base         DECIMAL(12,2) NOT NULL DEFAULT 0,
    exceso_desde          DECIMAL(12,2) NOT NULL DEFAULT 0,
    fecha_vigencia_ini    DATE          NOT NULL,
    fecha_vigencia_fin    DATE          NULL,
    is_active             BIT           CONSTRAINT df_TramoIR_is_active  DEFAULT 1         NOT NULL,
    created_at            DATETIME      CONSTRAINT df_TramoIR_created_at DEFAULT GETDATE() NOT NULL,
    updated_at            DATETIME      NULL,
    deleted_at            DATETIME      NULL,
    CONSTRAINT pk_Tramo_IR       PRIMARY KEY (id_tramo),
    CONSTRAINT ck_TramoIR_desde  CHECK (ingreso_anual_desde >= 0),
    CONSTRAINT ck_TramoIR_tasa   CHECK (tasa_marginal_pct BETWEEN 0 AND 100),
    CONSTRAINT ck_TramoIR_base   CHECK (impuesto_base >= 0),
    CONSTRAINT ck_TramoIR_exceso CHECK (exceso_desde   >= 0)
);
GO

-- 11. APORTE_PATRONAL  (FKs se agregan al final)
CREATE TABLE FISCAL.Aporte_Patronal (
    id_aporte      INT           IDENTITY(1,1),
    id_nomina      INT           NOT NULL,
    id_tipo_aporte INT           NOT NULL,
    monto          DECIMAL(10,2) NOT NULL,
    is_active      BIT           CONSTRAINT df_AporteP_is_active  DEFAULT 1         NOT NULL,
    created_at     DATETIME      CONSTRAINT df_AporteP_created_at DEFAULT GETDATE() NOT NULL,
    updated_at     DATETIME      NULL,
    deleted_at     DATETIME      NULL,
    CONSTRAINT pk_Aporte_Patronal PRIMARY KEY (id_aporte),
    CONSTRAINT ck_AporteP_monto   CHECK (monto > 0)
);
GO

--  ESQUEMA: NOMINA

-- 12. PERIODO_NOMINA
CREATE TABLE NOMINA.Periodo_Nomina (
    id_periodo   INT         IDENTITY(1,1),
    fecha_inicio DATE        NOT NULL,
    fecha_fin    DATE        NOT NULL,
    tipo_periodo VARCHAR(20) NOT NULL DEFAULT 'Mensual',
    estado       VARCHAR(20) NOT NULL DEFAULT 'Abierto',
    is_active    BIT         CONSTRAINT df_PerNom_is_active  DEFAULT 1         NOT NULL,
    created_at   DATETIME    CONSTRAINT df_PerNom_created_at DEFAULT GETDATE() NOT NULL,
    updated_at   DATETIME    NULL,
    deleted_at   DATETIME    NULL,
    CONSTRAINT pk_Periodo_Nomina PRIMARY KEY (id_periodo),
    CONSTRAINT uq_Periodo        UNIQUE (fecha_inicio, fecha_fin),
    CONSTRAINT ck_Periodo_tipo   CHECK (tipo_periodo IN ('Mensual','Quincenal','Semanal')),
    CONSTRAINT ck_Periodo_estado CHECK (estado IN ('Abierto','Calculado','Cerrado')),
    CONSTRAINT ck_Periodo_Fechas CHECK (fecha_fin >= fecha_inicio)
);
GO

-- 13. NOMINA
CREATE TABLE NOMINA.Nomina (
    id_nomina          INT           IDENTITY(1,1),
    id_empleado        INT           NOT NULL,
    id_periodo         INT           NOT NULL,
    id_cargo           INT           NOT NULL,
    id_autoriza        INT           NOT NULL,
    id_elabora         INT           NOT NULL,
    total_percepciones DECIMAL(10,2) NOT NULL DEFAULT 0,
    total_deducciones  DECIMAL(10,2) NOT NULL DEFAULT 0,
    salario_neto       DECIMAL(10,2) NOT NULL DEFAULT 0,
    fecha_elaboracion  DATETIME      NOT NULL DEFAULT GETDATE(),
    fecha_autorizacion DATETIME      NULL,
    is_active          BIT           CONSTRAINT df_Nomina_is_active  DEFAULT 1         NOT NULL,
    created_at         DATETIME      CONSTRAINT df_Nomina_created_at DEFAULT GETDATE() NOT NULL,
    updated_at         DATETIME      NULL,
    deleted_at         DATETIME      NULL,
    CONSTRAINT pk_Nomina              PRIMARY KEY (id_nomina),
    CONSTRAINT fk_Nomina_Empleado     FOREIGN KEY (id_empleado) REFERENCES RRHH.Empleado(id_empleado),
    CONSTRAINT fk_Nomina_Periodo      FOREIGN KEY (id_periodo)  REFERENCES NOMINA.Periodo_Nomina(id_periodo),
    CONSTRAINT fk_Nomina_Cargo        FOREIGN KEY (id_cargo)    REFERENCES RRHH.Cargo(id_cargo),
    CONSTRAINT fk_Nomina_Autoriza     FOREIGN KEY (id_autoriza) REFERENCES RRHH.Empleado(id_empleado),
    CONSTRAINT fk_Nomina_Elabora      FOREIGN KEY (id_elabora)  REFERENCES RRHH.Empleado(id_empleado),
    CONSTRAINT uq_Nomina_EmpPer       UNIQUE (id_empleado, id_periodo),
    CONSTRAINT ck_Nomina_percepciones CHECK (total_percepciones >= 0),
    CONSTRAINT ck_Nomina_deducciones  CHECK (total_deducciones  >= 0),
    CONSTRAINT ck_Nomina_Seguridad    CHECK (id_autoriza <> id_elabora)
);
GO

-- 14. PERCEPCION
CREATE TABLE NOMINA.Percepcion (
    id_percepcion       INT           IDENTITY(1,1),
    id_nomina           INT           NOT NULL,
    id_categoria_percep INT           NOT NULL,
    monto               DECIMAL(10,2) NOT NULL,
    aplica_impuesto     BIT           NOT NULL DEFAULT 1,
    descripcion         VARCHAR(200)  NULL,
    is_active           BIT           CONSTRAINT df_Percep_is_active  DEFAULT 1         NOT NULL,
    created_at          DATETIME      CONSTRAINT df_Percep_created_at DEFAULT GETDATE() NOT NULL,
    updated_at          DATETIME      NULL,
    deleted_at          DATETIME      NULL,
    CONSTRAINT pk_Percepcion       PRIMARY KEY (id_percepcion),
    CONSTRAINT fk_Percep_Nomina    FOREIGN KEY (id_nomina)           REFERENCES NOMINA.Nomina(id_nomina),
    CONSTRAINT fk_Percep_Categoria FOREIGN KEY (id_categoria_percep) REFERENCES CATALOGOS.Categoria_Percepcion(id_categoria_percep),
    CONSTRAINT ck_Percep_monto     CHECK (monto > 0)
);
GO

-- 15. DEDUCCION
CREATE TABLE NOMINA.Deduccion (
    id_deduccion     INT           IDENTITY(1,1),
    id_nomina        INT           NOT NULL,
    id_categoria_ded INT           NOT NULL,
    monto            DECIMAL(10,2) NOT NULL,
    descripcion      VARCHAR(200)  NULL,
    is_active        BIT           CONSTRAINT df_Deducc_is_active  DEFAULT 1         NOT NULL,
    created_at       DATETIME      CONSTRAINT df_Deducc_created_at DEFAULT GETDATE() NOT NULL,
    updated_at       DATETIME      NULL,
    deleted_at       DATETIME      NULL,
    CONSTRAINT pk_Deduccion        PRIMARY KEY (id_deduccion),
    CONSTRAINT fk_Deducc_Nomina    FOREIGN KEY (id_nomina)        REFERENCES NOMINA.Nomina(id_nomina),
    CONSTRAINT fk_Deducc_Categoria FOREIGN KEY (id_categoria_ded) REFERENCES CATALOGOS.Categoria_Deduccion(id_categoria_ded),
    CONSTRAINT ck_Deducc_monto     CHECK (monto > 0)
);
GO

--  ESQUEMA: OPERACIONES

-- 16. INCIDENCIA
CREATE TABLE OPERACIONES.Incidencia (
    id_incidencia      INT           IDENTITY(1,1),
    id_empleado        INT           NOT NULL,
    id_periodo         INT           NOT NULL,
    id_tipo_incidencia INT           NOT NULL,
    fecha_incidencia   DATE          NOT NULL,
    cantidad           DECIMAL(10,2) NOT NULL DEFAULT 0,
    monto              DECIMAL(10,2) NOT NULL DEFAULT 0,
    descripcion        VARCHAR(200)  NULL,
    is_active          BIT           CONSTRAINT df_Incid_is_active  DEFAULT 1         NOT NULL,
    created_at         DATETIME      CONSTRAINT df_Incid_created_at DEFAULT GETDATE() NOT NULL,
    updated_at         DATETIME      NULL,
    deleted_at         DATETIME      NULL,
    CONSTRAINT pk_Incidencia     PRIMARY KEY (id_incidencia),
    CONSTRAINT fk_Incid_Empleado FOREIGN KEY (id_empleado)        REFERENCES RRHH.Empleado(id_empleado),
    CONSTRAINT fk_Incid_Periodo  FOREIGN KEY (id_periodo)         REFERENCES NOMINA.Periodo_Nomina(id_periodo),
    CONSTRAINT fk_Incid_Tipo     FOREIGN KEY (id_tipo_incidencia) REFERENCES CATALOGOS.Tipo_Incidencia(id_tipo_incidencia),
    CONSTRAINT ck_Incid_cantidad CHECK (cantidad >= 0)
);
GO

-- 17. PRESTACION
CREATE TABLE OPERACIONES.Prestacion (
    id_prestacion      INT           IDENTITY(1,1),
    id_nomina          INT           NOT NULL,
    id_tipo_prestacion INT           NOT NULL,
    monto              DECIMAL(10,2) NOT NULL DEFAULT 0,
    is_active          BIT           CONSTRAINT df_Presta_is_active  DEFAULT 1         NOT NULL,
    created_at         DATETIME      CONSTRAINT df_Presta_created_at DEFAULT GETDATE() NOT NULL,
    updated_at         DATETIME      NULL,
    deleted_at         DATETIME      NULL,
    CONSTRAINT pk_Prestacion    PRIMARY KEY (id_prestacion),
    CONSTRAINT fk_Presta_Nomina FOREIGN KEY (id_nomina)          REFERENCES NOMINA.Nomina(id_nomina),
    CONSTRAINT fk_Presta_Tipo   FOREIGN KEY (id_tipo_prestacion) REFERENCES CATALOGOS.Tipo_Prestacion(id_tipo_prestacion),
    CONSTRAINT ck_Presta_monto  CHECK (monto >= 0)
);
GO

--  ESQUEMA: SEGURIDAD

-- 18. PERMISO
CREATE TABLE SEGURIDAD.Permiso (
    id_permiso  INT          IDENTITY(1,1),
    nombre      VARCHAR(100) NOT NULL,
    descripcion VARCHAR(200) NULL,
    is_active   BIT          CONSTRAINT df_Permiso_is_active  DEFAULT 1         NOT NULL,
    created_at  DATETIME     CONSTRAINT df_Permiso_created_at DEFAULT GETDATE() NOT NULL,
    updated_at  DATETIME     NULL,
    deleted_at  DATETIME     NULL,
    CONSTRAINT pk_Permiso        PRIMARY KEY (id_permiso),
    CONSTRAINT uq_Permiso_nombre UNIQUE (nombre)
);
GO

-- 19. ROL
CREATE TABLE SEGURIDAD.Rol (
    id_rol      INT          IDENTITY(1,1),
    nombre_rol  VARCHAR(60)  NOT NULL,
    descripcion VARCHAR(200) NULL,
    is_active   BIT          CONSTRAINT df_Rol_is_active  DEFAULT 1         NOT NULL,
    created_at  DATETIME     CONSTRAINT df_Rol_created_at DEFAULT GETDATE() NOT NULL,
    updated_at  DATETIME     NULL,
    deleted_at  DATETIME     NULL,
    CONSTRAINT pk_Rol        PRIMARY KEY (id_rol),
    CONSTRAINT uq_Rol_nombre UNIQUE (nombre_rol)
);
GO

-- 20. ROL_PERMISO
CREATE TABLE SEGURIDAD.Rol_Permiso (
    id_rol_permiso INT      IDENTITY(1,1),
    id_rol         INT      NOT NULL,
    id_permiso     INT      NOT NULL,
    is_active      BIT      CONSTRAINT df_RolPerm_is_active  DEFAULT 1         NOT NULL,
    created_at     DATETIME CONSTRAINT df_RolPerm_created_at DEFAULT GETDATE() NOT NULL,
    updated_at     DATETIME NULL,
    deleted_at     DATETIME NULL,
    CONSTRAINT pk_Rol_Permiso     PRIMARY KEY (id_rol_permiso),
    CONSTRAINT uq_Rol_Permiso     UNIQUE (id_rol, id_permiso),
    CONSTRAINT fk_RolPerm_Rol     FOREIGN KEY (id_rol)     REFERENCES SEGURIDAD.Rol(id_rol),
    CONSTRAINT fk_RolPerm_Permiso FOREIGN KEY (id_permiso) REFERENCES SEGURIDAD.Permiso(id_permiso)
);
GO

-- 21. USUARIO
CREATE TABLE SEGURIDAD.Usuario (
    id_usuario    INT          IDENTITY(1,1),
    id_empleado   INT          NOT NULL,
    username      VARCHAR(60)  NOT NULL,
    password_hash VARCHAR(256) NOT NULL,
    ultimo_acceso DATETIME     NULL,
    is_active     BIT          CONSTRAINT df_Usuario_is_active  DEFAULT 1         NOT NULL,
    created_at    DATETIME     CONSTRAINT df_Usuario_created_at DEFAULT GETDATE() NOT NULL,
    updated_at    DATETIME     NULL,
    deleted_at    DATETIME     NULL,
    CONSTRAINT pk_Usuario          PRIMARY KEY (id_usuario),
    CONSTRAINT uq_Usuario_username UNIQUE (username),
    CONSTRAINT uq_Usuario_empleado UNIQUE (id_empleado),
    CONSTRAINT fk_Usuario_Empleado FOREIGN KEY (id_empleado) REFERENCES RRHH.Empleado(id_empleado)
);
GO

-- 22. USUARIO_ROL
CREATE TABLE SEGURIDAD.Usuario_Rol (
    id_usuario_rol INT      IDENTITY(1,1),
    id_usuario     INT      NOT NULL,
    id_rol         INT      NOT NULL,
    is_active      BIT      CONSTRAINT df_UsuarioRol_is_active  DEFAULT 1         NOT NULL,
    created_at     DATETIME CONSTRAINT df_UsuarioRol_created_at DEFAULT GETDATE() NOT NULL,
    updated_at     DATETIME NULL,
    deleted_at     DATETIME NULL,
    CONSTRAINT pk_Usuario_Rol        PRIMARY KEY (id_usuario_rol),
    CONSTRAINT uq_UsuarioRol         UNIQUE (id_usuario, id_rol),
    CONSTRAINT fk_UsuarioRol_Usuario FOREIGN KEY (id_usuario) REFERENCES SEGURIDAD.Usuario(id_usuario),
    CONSTRAINT fk_UsuarioRol_Rol     FOREIGN KEY (id_rol)     REFERENCES SEGURIDAD.Rol(id_rol)
);
GO

-- 23. AUDITORIA
CREATE TABLE SEGURIDAD.Auditoria (
    id_auditoria   BIGINT        IDENTITY(1,1),
    id_usuario     INT           NOT NULL,
    tabla_afectada VARCHAR(100)  NOT NULL,
    accion         VARCHAR(10)   NOT NULL,
    descripcion    VARCHAR(500)  NULL,
    ip_origen      VARCHAR(45)   NULL,
    fecha_hora     DATETIME      NOT NULL DEFAULT GETDATE(),
    is_active      BIT           CONSTRAINT df_Auditoria_is_active  DEFAULT 1         NOT NULL,
    created_at     DATETIME      CONSTRAINT df_Auditoria_created_at DEFAULT GETDATE() NOT NULL,
    updated_at     DATETIME      NULL,
    deleted_at     DATETIME      NULL,
    CONSTRAINT pk_Auditoria     PRIMARY KEY (id_auditoria),
    CONSTRAINT fk_Audit_Usuario FOREIGN KEY (id_usuario) REFERENCES SEGURIDAD.Usuario(id_usuario),
    CONSTRAINT ck_Audit_accion  CHECK (accion IN ('INSERT','UPDATE','DELETE','SELECT'))
);
GO

--  FK DIFERIDAS — FISCAL.Aporte_Patronal

ALTER TABLE FISCAL.Aporte_Patronal
    ADD CONSTRAINT fk_AporteP_Nomina     FOREIGN KEY (id_nomina)      REFERENCES NOMINA.Nomina(id_nomina),
        CONSTRAINT fk_AporteP_TipoAporte FOREIGN KEY (id_tipo_aporte) REFERENCES CATALOGOS.Tipo_Aporte(id_tipo_aporte);
GO

--  PERMISOS DE ESQUEMA
--  GRANT/DENY SELECT ON SCHEMA::<nombre> TO <usuario>

GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::RRHH        TO usr_rrhh;
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::NOMINA      TO usr_nomina;
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::CATALOGOS   TO usr_catalogos;
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::FISCAL      TO usr_fiscal;
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::OPERACIONES TO usr_operaciones;
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::SEGURIDAD   TO usr_seguridad;


GRANT SELECT ON SCHEMA::RRHH        TO usr_seguridad;
GRANT SELECT ON SCHEMA::NOMINA      TO usr_seguridad;
GRANT SELECT ON SCHEMA::CATALOGOS   TO usr_seguridad;
GRANT SELECT ON SCHEMA::FISCAL      TO usr_seguridad;
GRANT SELECT ON SCHEMA::OPERACIONES TO usr_seguridad;
GO

--  DATOS INICIALES

-- ── RRHH.Rol_Empleado ───────────────────────────────────────
INSERT INTO RRHH.Rol_Empleado (nombre_rol, descripcion) VALUES
    ('Gerente General',        'Máxima autoridad ejecutiva de la empresa'),
    ('Jefe de RRHH',           'Responsable de la gestión del personal'),
    ('Contador',               'Manejo de contabilidad y finanzas'),
    ('Asistente Administrativo','Apoyo en tareas administrativas generales'),
    ('Responsable de Nomina',  'Elabora y supervisa el proceso de pago'),
    ('Supervisor de Area',     'Coordina operaciones de un departamento'),
    ('Tecnico de Soporte',     'Soporte tecnico interno de sistemas'),
    ('Vendedor',               'Gestion de ventas y atencion a clientes'),
    ('Bodeguero',              'Control de inventario y almacen'),
    ('Auditor Interno',        'Revision y control de procesos internos');
GO

-- ── RRHH.Cargo ──────────────────────────────────────────────
INSERT INTO RRHH.Cargo (nombre_cargo, descripcion_cargo, salario_base, salario_minimo, salario_maximo, salario_extraordinario) VALUES
    ('Gerente General',         'Dirige la empresa',                          60000.00, 50000.00,  80000.00, 5000.00),
    ('Jefe de RRHH',            'Administra recursos humanos',                35000.00, 28000.00,  50000.00, 3000.00),
    ('Contador Senior',         'Supervision contable y fiscal',              30000.00, 25000.00,  45000.00, 2500.00),
    ('Asistente Administrativo','Apoyo operativo general',                    14000.00, 12000.00,  20000.00, 1200.00),
    ('Responsable de Nomina',   'Calculo y pago de salarios',                 28000.00, 22000.00,  40000.00, 2000.00),
    ('Supervisor de Ventas',    'Coordina equipo comercial',                  25000.00, 20000.00,  38000.00, 2200.00),
    ('Tecnico de TI',           'Mantenimiento de sistemas',                  22000.00, 18000.00,  32000.00, 1800.00),
    ('Vendedor',                'Atencion y gestion de ventas',               15000.00, 12500.00,  25000.00, 1500.00),
    ('Bodeguero',               'Control de inventario',                      13000.00, 11000.00,  18000.00, 1100.00),
    ('Auditor Interno',         'Supervision y control de procesos',          32000.00, 26000.00,  48000.00, 2800.00);
GO

-- ── RRHH.Empleado (10 empleados; id 1-2 seran supervisores) ─
INSERT INTO RRHH.Empleado (primer_nombre, segundo_nombre, primer_apellido, segundo_apellido, sexo, fecha_nacimiento, ciudad, estado_civil, numero_inss, cedula, telefono, correo) VALUES
    ('Carlos',   'Eduardo',  'Martinez',  'Lopez',    'M', '1980-03-15', 'Managua',   'Casado',         'INSS001', '001-010380-0001A', '88001111', 'cmartinez@empresa.com'),
    ('Ana',      'Maria',    'Gutierrez', 'Torres',   'F', '1985-07-22', 'Managua',   'Soltera',        'INSS002', '001-220785-0002B', '88002222', 'agutierrez@empresa.com'),
    ('Luis',     NULL,       'Hernandez', 'Ruiz',     'M', '1990-11-05', 'Leon',      'Casado',         'INSS003', '001-051190-0003C', '88003333', 'lhernandez@empresa.com'),
    ('Maria',    'Jose',     'Perez',     'Castillo', 'F', '1992-04-18', 'Managua',   'Union de hecho', 'INSS004', '001-180492-0004D', '88004444', 'mperez@empresa.com'),
    ('Roberto',  'Antonio',  'Sanchez',   'Morales',  'M', '1978-09-30', 'Granada',   'Divorciado',     'INSS005', '001-300978-0005E', '88005555', 'rsanchez@empresa.com'),
    ('Sofia',    'Alejandra','Ramirez',   'Diaz',     'F', '1995-02-14', 'Masaya',    'Soltera',        'INSS006', '001-140295-0006F', '88006666', 'sramirez@empresa.com'),
    ('Jorge',    'Alberto',  'Mendoza',   'Vega',     'M', '1988-06-27', 'Managua',   'Casado',         'INSS007', '001-270688-0007G', '88007777', 'jmendoza@empresa.com'),
    ('Laura',    NULL,       'Vargas',    'Reyes',    'F', '1993-12-03', 'Chinandega','Soltera',        'INSS008', '001-031293-0008H', '88008888', 'lvargas@empresa.com'),
    ('Miguel',   'Angel',    'Torres',    'Jimenez',  'M', '1983-08-11', 'Esteli',    'Casado',         'INSS009', '001-110883-0009I', '88009999', 'mtorres@empresa.com'),
    ('Carmen',   'Isabel',   'Flores',    'Cruz',     'F', '1991-05-25', 'Managua',   'Casado',         'INSS010', '001-250591-0010J', '88010000', 'cflores@empresa.com');
GO

-- ── RRHH.Empleado_Cargo ──────────────────────────────────────
INSERT INTO RRHH.Empleado_Cargo (id_empleado, id_cargo, salario_asignado, fecha_inicio, fecha_fin) VALUES
    (1,  1, 62000.00, '2018-01-02', NULL),
    (2,  2, 36000.00, '2019-03-01', NULL),
    (3,  3, 30500.00, '2020-06-15', NULL),
    (4,  4, 14500.00, '2021-01-10', NULL),
    (5,  5, 28500.00, '2017-08-01', NULL),
    (6,  6, 15500.00, '2022-02-14', NULL),
    (7,  7, 22500.00, '2019-11-01', NULL),
    (8,  8, 15000.00, '2023-03-06', NULL),
    (9,  9, 13500.00, '2020-09-20', NULL),
    (10, 10, 33000.00, '2021-05-03', NULL);
GO

-- ── CATALOGOS.Categoria_Percepcion ──────────────────────────
INSERT INTO CATALOGOS.Categoria_Percepcion (nombre, aplica_impuesto, descripcion) VALUES
    ('Salario base',        1, 'Sueldo contractual del empleado'),
    ('Horas extra',         1, 'Remuneracion por horas adicionales trabajadas'),
    ('Viaticos',            0, 'Gastos de transporte y alimentacion en comisiones'),
    ('Bono productividad',  1, 'Incentivo por cumplimiento de metas'),
    ('Premio',              1, 'Reconocimiento economico especial'),
    ('Comision',            1, 'Porcentaje sobre ventas realizadas'),
    ('Subsidio transporte', 0, 'Apoyo economico para movilizacion'),
    ('Bono antiguedad',     1, 'Reconocimiento por años de servicio'),
    ('Bono navidad',        1, 'Pago extra en periodo navideno'),
    ('Reintegro',           0, 'Devolucion de descuento aplicado en error');
GO

-- ── CATALOGOS.Categoria_Deduccion ───────────────────────────
INSERT INTO CATALOGOS.Categoria_Deduccion (nombre, porcentaje, es_obligatoria, descripcion) VALUES
    ('INSS Laboral',      7.00,  1, 'Ley 539 — 7% del salario bruto a cargo del trabajador'),
    ('IR Renta',          NULL,  1, 'Ley 822 — Calculado con tabla progresiva Tramo_IR'),
    ('Embargo judicial',  NULL,  0, 'Descuento por orden judicial'),
    ('Anticipo',          NULL,  0, 'Descuento de adelanto de salario solicitado'),
    ('Prestamo interno',  NULL,  0, 'Cuota de prestamo otorgado por la empresa'),
    ('Seguro medico',     2.50,  0, 'Prima de seguro de salud privado opcional'),
    ('Cuota sindical',    1.00,  0, 'Aporte mensual al sindicato de trabajadores'),
    ('Caja de ahorro',    5.00,  0, 'Ahorro voluntario mensual en caja solidaria'),
    ('Inasistencia',      NULL,  0, 'Descuento proporcional por dia no laborado'),
    ('Tardanza',          NULL,  0, 'Descuento por llegadas tardes reiteradas');
GO

-- ── CATALOGOS.Tipo_Incidencia ────────────────────────────────
INSERT INTO CATALOGOS.Tipo_Incidencia (nombre_tipo, categoria, afecta_salario) VALUES
    ('Hora extra diurna',          'Percepcion', 1),
    ('Hora extra nocturna',        'Percepcion', 1),
    ('Bono',                       'Percepcion', 1),
    ('Ausencia injustificada',     'Deduccion',  1),
    ('Incapacidad por enfermedad', 'Ninguna',    0),
    ('Vacaciones',                 'Ninguna',    0),
    ('Licencia maternidad',        'Ninguna',    0),
    ('Licencia paternidad',        'Ninguna',    0),
    ('Permiso sin goce',           'Deduccion',  1),
    ('Tardanza',                   'Deduccion',  1);
GO

-- ── CATALOGOS.Tipo_Aporte ────────────────────────────────────
INSERT INTO CATALOGOS.Tipo_Aporte (nombre_aporte, porcentaje, descripcion) VALUES
    ('INSS Patronal grande',   22.50, 'Ley 539 — empresas con mas de 50 empleados'),
    ('INSS Patronal pequeno',  21.50, 'Ley 539 — empresas con 50 o menos empleados'),
    ('INATEC',                  2.00, 'Decreto 40-94 — formacion tecnica'),
    ('Fondo de retiro',         3.00, 'Aporte voluntario al fondo de pensiones'),
    ('Seguro colectivo',        1.50, 'Prima de seguro de vida colectivo'),
    ('Fondo social',            0.50, 'Contribucion a actividades de bienestar'),
    ('Capacitacion',            1.00, 'Fondo para formacion y entrenamiento'),
    ('Riesgo laboral',          1.50, 'Cobertura de accidentes en el trabajo'),
    ('Salud ocupacional',       0.75, 'Programa de salud preventiva empresarial'),
    ('INATEC reducido',         1.00, 'Tasa aplicable a empresas exentas parciales');
GO

-- ── CATALOGOS.Tipo_Prestacion ────────────────────────────────
INSERT INTO CATALOGOS.Tipo_Prestacion (nombre_prestacion, regla_calculo, descripcion) VALUES
    ('Aguinaldo',             '1/12 del salario anual acumulado mensualmente',  'Art. 93 Codigo del Trabajo NI — se paga en diciembre'),
    ('Vacaciones',            '2.5 dias por mes trabajado (30 dias anuales)',   'Art. 76 Codigo del Trabajo NI'),
    ('Indemnizacion',         '1 mes por ano trabajado, maximo 5 meses',        'Art. 45 Codigo del Trabajo NI — aplica en despido sin causa'),
    ('Liquidacion final',     'Suma de prestaciones al termino del contrato',   'Incluye vacaciones, aguinaldo e indemnizacion proporcionales'),
    ('Bono escolar',          'Pago unico anual equivalente a 500 USD',         'Beneficio interno para hijos en edad escolar'),
    ('Subsidio lactancia',    '60% del salario durante 3 meses postparto',      'Complemento al subsidio INSS para madres lactantes'),
    ('Fondo de ahorro',       'Acumulado de cuota patronal al fondo solidario', 'Se entrega al retiro o renuncia voluntaria'),
    ('Prima de antiguedad',   '1% adicional al salario base por cada 5 anos',   'Reconocimiento por permanencia en la empresa'),
    ('Gastos medicos',        'Reembolso hasta 3 salarios minimos por evento',  'Cubre gastos no cubiertos por el INSS'),
    ('Seguro de vida',        'Beneficio de 24 salarios en caso de fallecimiento','Pagadero a beneficiario designado');
GO

-- ── FISCAL.Tramo_IR ──────────────────────────────────────────
INSERT INTO FISCAL.Tramo_IR (ingreso_anual_desde, ingreso_anual_hasta, tasa_marginal_pct, impuesto_base, exceso_desde, fecha_vigencia_ini) VALUES
    (       0.00,  100000.00,  0.00,      0.00,      0.00, '2024-01-01'),
    (  100000.01,  200000.00, 15.00,      0.00, 100000.00, '2024-01-01'),
    (  200000.01,  350000.00, 20.00,  15000.00, 200000.00, '2024-01-01'),
    (  350000.01,  500000.00, 25.00,  45000.00, 350000.00, '2024-01-01'),
    (  500000.01,        NULL, 30.00,  82500.00, 500000.00, '2024-01-01'),
    (       0.00,  100000.00,  0.00,      0.00,      0.00, '2023-01-01'),
    (  100000.01,  200000.00, 15.00,      0.00, 100000.00, '2023-01-01'),
    (  200000.01,  350000.00, 20.00,  15000.00, 200000.00, '2023-01-01'),
    (  350000.01,  500000.00, 25.00,  45000.00, 350000.00, '2023-01-01'),
    (  500000.01,        NULL, 30.00,  82500.00, 500000.00, '2023-01-01');
GO

-- ── NOMINA.Periodo_Nomina ────────────────────────────────────
INSERT INTO NOMINA.Periodo_Nomina (fecha_inicio, fecha_fin, tipo_periodo, estado) VALUES
    ('2024-01-01', '2024-01-31', 'Mensual',  'Cerrado'),
    ('2024-02-01', '2024-02-29', 'Mensual',  'Cerrado'),
    ('2024-03-01', '2024-03-31', 'Mensual',  'Cerrado'),
    ('2024-04-01', '2024-04-30', 'Mensual',  'Cerrado'),
    ('2024-05-01', '2024-05-31', 'Mensual',  'Cerrado'),
    ('2024-06-01', '2024-06-30', 'Mensual',  'Cerrado'),
    ('2024-07-01', '2024-07-31', 'Mensual',  'Cerrado'),
    ('2024-08-01', '2024-08-31', 'Mensual',  'Cerrado'),
    ('2024-09-01', '2024-09-30', 'Mensual',  'Calculado'),
    ('2024-10-01', '2024-10-31', 'Mensual',  'Abierto');
GO

-- ── NOMINA.Nomina ────────────────────────────────────────────
-- Empleado 1 autoriza, Empleado 2 elabora (cumplen ck_Nomina_Seguridad)
INSERT INTO NOMINA.Nomina (id_empleado, id_periodo, id_cargo, id_autoriza, id_elabora, total_percepciones, total_deducciones, salario_neto, fecha_elaboracion) VALUES
    (3,  1, 3,  1, 2, 30500.00,  3392.50, 27107.50, '2024-01-31'),
    (4,  2, 4,  1, 2, 14500.00,  2421.50, 12078.50, '2024-02-29'),
    (5,  3, 5,  1, 2, 28500.00,  3192.50, 25307.50, '2024-03-31'),
    (6,  4, 6,  1, 2, 15500.00,  2461.50, 13038.50, '2024-04-30'),
    (7,  5, 7,  1, 2, 22500.00,  2852.50, 19647.50, '2024-05-31'),
    (8,  6, 8,  1, 2, 15000.00,  2430.50, 12569.50, '2024-06-30'),
    (9,  7, 9,  1, 2, 13500.00,  2362.50, 11137.50, '2024-07-31'),
    (10, 8, 10, 1, 2, 33000.00,  3762.50, 29237.50, '2024-08-31'),
    (3,  9, 3,  1, 2, 30500.00,  3392.50, 27107.50, '2024-09-30'),
    (4,  9, 4,  2, 5, 14500.00,  2421.50, 12078.50, '2024-09-30');
GO

-- ── NOMINA.Percepcion ────────────────────────────────────────
INSERT INTO NOMINA.Percepcion (id_nomina, id_categoria_percep, monto, aplica_impuesto, descripcion) VALUES
    (1,  1, 30500.00, 1, 'Salario base enero 2024'),
    (2,  1, 14500.00, 1, 'Salario base febrero 2024'),
    (3,  1, 28500.00, 1, 'Salario base marzo 2024'),
    (4,  1, 15500.00, 1, 'Salario base abril 2024'),
    (5,  1, 22500.00, 1, 'Salario base mayo 2024'),
    (6,  1, 15000.00, 1, 'Salario base junio 2024'),
    (7,  1, 13500.00, 1, 'Salario base julio 2024'),
    (8,  1, 33000.00, 1, 'Salario base agosto 2024'),
    (9,  1, 30500.00, 1, 'Salario base septiembre 2024'),
    (10, 4,  2000.00, 1, 'Bono productividad Q3 2024');
GO

-- ── NOMINA.Deduccion ─────────────────────────────────────────
INSERT INTO NOMINA.Deduccion (id_nomina, id_categoria_ded, monto, descripcion) VALUES
    (1,  1, 2135.00, 'INSS Laboral 7% enero 2024'),
    (2,  1,  945.00, 'INSS Laboral 7% febrero 2024 (correc. minima)'),
    (3,  1, 1995.00, 'INSS Laboral 7% marzo 2024'),
    (4,  1, 1085.00, 'INSS Laboral 7% abril 2024'),
    (5,  1, 1575.00, 'INSS Laboral 7% mayo 2024'),
    (6,  1, 1050.00, 'INSS Laboral 7% junio 2024'),
    (7,  1,  945.00, 'INSS Laboral 7% julio 2024'),
    (8,  1, 2310.00, 'INSS Laboral 7% agosto 2024'),
    (9,  2, 1257.50, 'IR Renta septiembre 2024'),
    (10, 4, 1336.50, 'Anticipo de salario solicitado');
GO

-- ── OPERACIONES.Incidencia ───────────────────────────────────
INSERT INTO OPERACIONES.Incidencia (id_empleado, id_periodo, id_tipo_incidencia, fecha_incidencia, cantidad, monto, descripcion) VALUES
    (3,  1, 1, '2024-01-10', 2.00,   636.46, 'Horas extra diurnas'),
    (4,  2, 4, '2024-02-05', 1.00,   483.33, 'Ausencia injustificada lunes'),
    (5,  3, 3, '2024-03-31', 1.00,  2000.00, 'Bono por cierre trimestral'),
    (6,  4, 1, '2024-04-18', 3.00,   775.00, 'Horas extra diurnas sabado'),
    (7,  5, 2, '2024-05-22', 4.00,  1500.00, 'Horas extra nocturnas'),
    (8,  6, 6, '2024-06-01', 5.00,     0.00, 'Vacaciones aprobadas'),
    (9,  7, 9, '2024-07-15', 1.00,   450.00, 'Permiso sin goce medico'),
    (10, 8, 5, '2024-08-03', 3.00,     0.00, 'Incapacidad INSS 3 dias'),
    (3,  9, 4, '2024-09-12', 1.00,  1016.67, 'Ausencia injustificada'),
    (4,  9, 10,'2024-09-20', 2.00,   193.33, 'Tardanza x2 descuento');
GO

-- ── OPERACIONES.Prestacion ───────────────────────────────────
INSERT INTO OPERACIONES.Prestacion (id_nomina, id_tipo_prestacion, monto) VALUES
    (1,  1, 2541.67),
    (2,  1, 1208.33),
    (3,  2, 2375.00),
    (4,  2, 1291.67),
    (5,  1, 1875.00),
    (6,  2, 1250.00),
    (7,  1, 1125.00),
    (8,  1, 2750.00),
    (9,  1, 2541.67),
    (10, 2, 1208.33);
GO

-- ── SEGURIDAD.Permiso ────────────────────────────────────────
INSERT INTO SEGURIDAD.Permiso (nombre, descripcion) VALUES
    ('RRHH.Empleado.Ver',          'Consultar informacion de empleados'),
    ('RRHH.Empleado.Editar',       'Crear y modificar empleados'),
    ('NOMINA.Nomina.Elaborar',     'Elaborar nominas del periodo'),
    ('NOMINA.Nomina.Autorizar',    'Autorizar nominas calculadas'),
    ('CATALOGOS.Ver',              'Consultar catalogos del sistema'),
    ('CATALOGOS.Editar',           'Modificar catalogos del sistema'),
    ('FISCAL.TramoIR.Ver',         'Consultar tramos del IR'),
    ('SEGURIDAD.Usuarios.Gestionar','Crear y desactivar usuarios del sistema'),
    ('REPORTES.Nomina.Exportar',   'Exportar reportes de nomina'),
    ('AUDITORIA.Ver',              'Consultar log de auditoria');
GO

-- ── SEGURIDAD.Rol ────────────────────────────────────────────
INSERT INTO SEGURIDAD.Rol (nombre_rol, descripcion) VALUES
    ('Administrador',    'Acceso total al sistema'),
    ('RRHH',             'Gestion de empleados, cargos e incidencias'),
    ('Nomina',           'Elaboracion y consulta de nominas'),
    ('Auditor',          'Solo lectura sobre todas las tablas'),
    ('Supervisor',       'Aprobacion de incidencias y permisos'),
    ('Contador',         'Acceso a modulo fiscal y reportes'),
    ('Soporte',          'Acceso limitado para soporte tecnico'),
    ('Gerencia',         'Visualizacion de indicadores y reportes ejecutivos'),
    ('Readonly',         'Permiso de solo lectura general'),
    ('Temporal',         'Acceso temporal para usuarios externos auditados');
GO

-- ── SEGURIDAD.Rol_Permiso ────────────────────────────────────
INSERT INTO SEGURIDAD.Rol_Permiso (id_rol, id_permiso) VALUES
    (1,  1), (1,  2), (1,  3), (1,  4), (1,  5),
    (1,  6), (1,  7), (1,  8), (1,  9), (1, 10);
GO

-- ── SEGURIDAD.Usuario (requiere empleados ya insertados) ─────
INSERT INTO SEGURIDAD.Usuario (id_empleado, username, password_hash) VALUES
    (1,  'cmartinez',  '5E884898DA280471...hash1'),
    (2,  'agutierrez', '5E884898DA280471...hash2'),
    (3,  'lhernandez', '5E884898DA280471...hash3'),
    (4,  'mperez',     '5E884898DA280471...hash4'),
    (5,  'rsanchez',   '5E884898DA280471...hash5'),
    (6,  'sramirez',   '5E884898DA280471...hash6'),
    (7,  'jmendoza',   '5E884898DA280471...hash7'),
    (8,  'lvargas',    '5E884898DA280471...hash8'),
    (9,  'mtorres',    '5E884898DA280471...hash9'),
    (10, 'cflores',    '5E884898DA280471...hash10');
GO

-- ── SEGURIDAD.Usuario_Rol ────────────────────────────────────
INSERT INTO SEGURIDAD.Usuario_Rol (id_usuario, id_rol) VALUES
    (1,  1),
    (2,  2),
    (3,  3),
    (4,  3),
    (5,  5),
    (6,  3),
    (7,  7),
    (8,  9),
    (9,  9),
    (10, 4);
GO

-- ── FISCAL.Aporte_Patronal ───────────────────────────────────
INSERT INTO FISCAL.Aporte_Patronal (id_nomina, id_tipo_aporte, monto) VALUES
    (1,  1,  6862.50),
    (2,  2,  3117.50),
    (3,  1,  6412.50),
    (4,  2,  3317.50),
    (5,  1,  5062.50),
    (6,  2,  3225.00),
    (7,  1,  3037.50),
    (8,  1,  7425.00),
    (9,  3,   610.00),
    (10, 3,   290.00);
GO

-- ── SEGURIDAD.Auditoria ──────────────────────────────────────
INSERT INTO SEGURIDAD.Auditoria (id_usuario, tabla_afectada, accion, descripcion, ip_origen) VALUES
    (1, 'RRHH.Empleado',            'INSERT', 'Alta de empleado Luis Hernandez',        '192.168.1.10'),
    (2, 'RRHH.Empleado_Cargo',      'INSERT', 'Asignacion de cargo a empleado 3',       '192.168.1.11'),
    (1, 'NOMINA.Periodo_Nomina',    'INSERT', 'Apertura de periodo enero 2024',         '192.168.1.10'),
    (3, 'NOMINA.Nomina',            'INSERT', 'Elaboracion de nomina id 1',             '192.168.1.12'),
    (1, 'NOMINA.Nomina',            'UPDATE', 'Autorizacion de nomina id 1',            '192.168.1.10'),
    (2, 'RRHH.Cargo',               'UPDATE', 'Actualizacion salario cargo Contador',   '192.168.1.11'),
    (4, 'FISCAL.Tramo_IR',          'SELECT', 'Consulta de tramos vigentes 2024',       '192.168.1.13'),
    (1, 'SEGURIDAD.Usuario',        'INSERT', 'Creacion de 10 usuarios del sistema',    '192.168.1.10'),
    (5, 'OPERACIONES.Incidencia',   'INSERT', 'Registro de hora extra empleado 6',      '192.168.1.14'),
    (1, 'NOMINA.Periodo_Nomina',    'UPDATE', 'Cierre de periodo agosto 2024',          '192.168.1.10');
GO