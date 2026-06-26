USE master;
GO
 
IF DB_ID('SistemaNomina2') IS NOT NULL
BEGIN
    ALTER DATABASE SistemaNomina2 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE SistemaNomina2;
END
GO
 
CREATE DATABASE SistemaNomina2;
GO
 
USE SistemaNomina2;
GO
 
-- ============================================================
--  USUARIOS Y ESQUEMAS
-- ============================================================
 
CREATE USER usr_rrhh        WITHOUT LOGIN;
CREATE USER usr_nomina      WITHOUT LOGIN;
CREATE USER usr_catalogos   WITHOUT LOGIN;
CREATE USER usr_fiscal      WITHOUT LOGIN;
CREATE USER usr_operaciones WITHOUT LOGIN;
CREATE USER usr_seguridad   WITHOUT LOGIN;
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
 
-- ============================================================
--  ESQUEMA: RRHH
-- ============================================================

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
        'Soltero','Soltera','Casado','Casada','Union de hecho','Divorciado','Divorciada','Viudo','Viuda'))
);
GO
 
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
 
-- ============================================================
--  ESQUEMA: CATALOGOS
-- ============================================================

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
 
-- ============================================================
--  ESQUEMA: FISCAL
-- ============================================================
 
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
 
-- ============================================================
--  ESQUEMA: NOMINA
-- ============================================================
 
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
 
-- ============================================================
--  ESQUEMA: OPERACIONES
-- ============================================================
 
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
 
-- ============================================================
--  ESQUEMA: SEGURIDAD
-- ============================================================
 
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
 
-- ============================================================
--  FK DIFERIDAS — FISCAL.Aporte_Patronal
-- ============================================================
ALTER TABLE FISCAL.Aporte_Patronal
    ADD CONSTRAINT fk_AporteP_Nomina     FOREIGN KEY (id_nomina)      REFERENCES NOMINA.Nomina(id_nomina),
        CONSTRAINT fk_AporteP_TipoAporte FOREIGN KEY (id_tipo_aporte) REFERENCES CATALOGOS.Tipo_Aporte(id_tipo_aporte);
GO
 
-- ============================================================
--  PERMISOS DE ESQUEMA
-- ============================================================
-- ============================================================
--  PERMISOS DE ESQUEMA
--  (Solo se otorgan permisos cruzados; el dueno de cada schema
--   ya tiene acceso total por ser AUTHORIZATION del mismo)
-- ============================================================
-- usr_seguridad puede leer todos los esquemas operativos
GRANT SELECT ON SCHEMA::RRHH        TO usr_seguridad;
GRANT SELECT ON SCHEMA::NOMINA      TO usr_seguridad;
GRANT SELECT ON SCHEMA::CATALOGOS   TO usr_seguridad;
GRANT SELECT ON SCHEMA::FISCAL      TO usr_seguridad;
GRANT SELECT ON SCHEMA::OPERACIONES TO usr_seguridad;
-- Permisos adicionales cruzados
GRANT SELECT ON SCHEMA::CATALOGOS   TO usr_rrhh;
GRANT SELECT ON SCHEMA::CATALOGOS   TO usr_nomina;
GRANT SELECT ON SCHEMA::CATALOGOS   TO usr_fiscal;
GRANT SELECT ON SCHEMA::CATALOGOS   TO usr_operaciones;
GRANT SELECT ON SCHEMA::NOMINA      TO usr_rrhh;
GRANT SELECT ON SCHEMA::RRHH        TO usr_nomina;
GRANT SELECT ON SCHEMA::RRHH        TO usr_operaciones;
GO
 
-- ============================================================
-- INSERT: RRHH.Rol_Empleado
-- ============================================================
INSERT INTO RRHH.Rol_Empleado (nombre_rol, descripcion) VALUES
    ('Gerente General',             'Maxima autoridad ejecutiva de la empresa'),
    ('Jefe de RRHH',                'Responsable de la gestion del personal'),
    ('Contador Senior',             'Supervision contable y fiscal'),
    ('Asistente Administrativo',    'Apoyo en tareas administrativas generales'),
    ('Responsable de Nomina',       'Elabora y supervisa el proceso de pago'),
    ('Supervisor de Area',          'Coordina operaciones de un departamento'),
    ('Tecnico de Soporte TI',       'Soporte tecnico interno de sistemas'),
    ('Vendedor Externo',            'Gestion de ventas en campo'),
    ('Bodeguero Principal',         'Control de inventario y almacen'),
    ('Auditor Interno',             'Revision y control de procesos internos'),
    ('Asistente Contable',          'Apoyo en registro de transacciones'),
    ('Coordinador de Compras',      'Gestion de proveedores y pedidos'),
    ('Analista de Sistemas',        'Desarrollo y mantenimiento de software'),
    ('Recepcionista',               'Atencion al publico y gestion de agenda'),
    ('Mensajero',                   'Distribucion de documentos y encomiendas'),
    ('Supervisor de Ventas',        'Coordinacion del equipo comercial'),
    ('Jefe de Operaciones',         'Responsable de procesos productivos'),
    ('Asistente de RRHH',           'Apoyo administrativo al departamento de personal'),
    ('Coordinador de Nomina',       'Apoyo en calculo y verificacion de pagos'),
    ('Analista Financiero',         'Analisis de estados financieros'),
    ('Tecnico de Redes',            'Administracion de infraestructura de red'),
    ('Diseñador Grafico',           'Creacion de material visual y publicidad'),
    ('Jefe de Logistica',           'Planificacion y control de cadena de suministro'),
    ('Promotor Comercial',          'Promocion de productos y marcas'),
    ('Auxiliar de Limpieza',        'Mantenimiento del aseo del local'),
    ('Gerente de Ventas',           'Estrategia y metas del area comercial'),
    ('Coordinador Legal',           'Gestion de contratos y cumplimiento normativo'),
    ('Tecnico Electricista',        'Mantenimiento de instalaciones electricas'),
    ('Almacenista',                 'Control de entradas y salidas de bodega'),
    ('Digitador',                   'Ingreso de datos al sistema'),
    ('Asistente de Gerencia',       'Apoyo directo a la gerencia general'),
    ('Jefe de Credito y Cobro',     'Gestion de cuentas por cobrar'),
    ('Analista de Mercadeo',        'Investigacion y estrategia de mercado'),
    ('Jefe de Compras',             'Negociacion con proveedores y compras'),
    ('Tecnico de Mantenimiento',    'Reparacion y mantenimiento de equipos'),
    ('Auditor Externo',             'Auditoria independiente de cuentas'),
    ('Coordinador de Proyectos',    'Planificacion y seguimiento de proyectos'),
    ('Asistente Legal',             'Apoyo en tramites y documentos legales'),
    ('Jefe de Sistemas',            'Liderazgo del area de tecnologia'),
    ('Vendedor Interno',            'Atencion de clientes en local'),
    ('Auxiliar de Bodega',          'Apoyo en organizacion del almacen'),
    ('Supervisor de Calidad',       'Control y aseguramiento de calidad'),
    ('Jefe de Seguridad',           'Coordinacion del personal de vigilancia'),
    ('Agente de Seguridad',         'Vigilancia y control de acceso'),
    ('Representante de Servicio',   'Atencion y seguimiento post venta'),
    ('Asistente de Logistica',      'Apoyo en coordinacion de entregas'),
    ('Coordinador de Capacitacion', 'Planificacion y ejecucion de formaciones'),
    ('Analista de Nomina',          'Procesamiento y revision de pagos de salario'),
    ('Jefe de Creditos',            'Evaluacion y aprobacion de solicitudes crediticias'),
    ('Gerente Administrativo',      'Supervisa procesos administrativos de la empresa');
GO
 
-- ============================================================
-- INSERT: RRHH.Cargo
-- ============================================================
INSERT INTO RRHH.Cargo (nombre_cargo, descripcion_cargo, salario_base, salario_minimo, salario_maximo, salario_extraordinario) VALUES
    ('Gerente General',              'Dirige la empresa',                           60000.00, 50000.00, 80000.00, 5000.00),
    ('Jefe de RRHH',                 'Administra recursos humanos',                 35000.00, 28000.00, 50000.00, 3000.00),
    ('Contador Senior',              'Supervision contable y fiscal',               30000.00, 25000.00, 45000.00, 2500.00),
    ('Asistente Administrativo',     'Apoyo operativo general',                     14000.00, 12000.00, 20000.00, 1200.00),
    ('Responsable de Nomina',        'Calculo y pago de salarios',                  28000.00, 22000.00, 40000.00, 2000.00),
    ('Supervisor de Ventas',         'Coordina equipo comercial',                   25000.00, 20000.00, 38000.00, 2200.00),
    ('Tecnico de TI',                'Mantenimiento de sistemas',                   22000.00, 18000.00, 32000.00, 1800.00),
    ('Vendedor',                     'Atencion y gestion de ventas',                15000.00, 12500.00, 25000.00, 1500.00),
    ('Bodeguero',                    'Control de inventario',                       13000.00, 11000.00, 18000.00, 1100.00),
    ('Auditor Interno',              'Supervision y control de procesos',           32000.00, 26000.00, 48000.00, 2800.00),
    ('Asistente Contable',           'Registro de asientos contables',              16000.00, 13000.00, 22000.00, 1300.00),
    ('Coordinador de Compras',       'Gestion de proveedores',                      24000.00, 19000.00, 35000.00, 2000.00),
    ('Analista de Sistemas',         'Desarrollo de software interno',              26000.00, 21000.00, 40000.00, 2300.00),
    ('Recepcionista',                'Atencion al publico',                         12500.00, 10500.00, 17000.00, 1000.00),
    ('Mensajero',                    'Distribucion de documentos',                  11000.00,  9500.00, 14000.00,  900.00),
    ('Jefe de Operaciones',          'Coordinacion operativa general',              40000.00, 33000.00, 55000.00, 3500.00),
    ('Asistente de RRHH',            'Apoyo a departamento de personal',            15000.00, 12000.00, 20000.00, 1200.00),
    ('Coordinador de Nomina',        'Apoyo en elaboracion de nomina',              21000.00, 17000.00, 30000.00, 1700.00),
    ('Analista Financiero',          'Analisis de finanzas corporativas',           29000.00, 23000.00, 42000.00, 2400.00),
    ('Tecnico de Redes',             'Administracion de red informatica',           23000.00, 18500.00, 34000.00, 1900.00),
    ('Disenador Grafico',            'Creacion de material publicitario',           18000.00, 14000.00, 26000.00, 1500.00),
    ('Jefe de Logistica',            'Gestion de la cadena de suministro',          33000.00, 27000.00, 48000.00, 2800.00),
    ('Promotor Comercial',           'Activaciones y promociones de marca',         13500.00, 11000.00, 19000.00, 1100.00),
    ('Auxiliar de Limpieza',          'Mantenimiento del aseo general',              10000.00,  8500.00, 12000.00,  800.00),
    ('Gerente de Ventas',            'Estrategia comercial y metas',                45000.00, 37000.00, 62000.00, 4000.00),
    ('Coordinador Legal',            'Gestion contractual y cumplimiento legal',    36000.00, 29000.00, 52000.00, 3100.00),
    ('Tecnico Electricista',         'Mantenimiento de instalaciones electricas',   17000.00, 14000.00, 24000.00, 1400.00),
    ('Almacenista',                  'Control de entradas y salidas de bodega',     12000.00, 10000.00, 16000.00,  950.00),
    ('Digitador',                    'Captura de datos al sistema',                 11500.00,  9800.00, 15000.00,  920.00),
    ('Asistente de Gerencia',        'Apoyo directo al gerente general',            20000.00, 16000.00, 28000.00, 1600.00),
    ('Jefe de Credito y Cobro',      'Administracion de cuentas por cobrar',        31000.00, 25000.00, 45000.00, 2600.00),
    ('Analista de Mercadeo',         'Estrategia y analisis de mercado',            27000.00, 22000.00, 39000.00, 2100.00),
    ('Jefe de Compras',              'Negociacion y adquisicion de bienes',         34000.00, 27500.00, 50000.00, 2900.00),
    ('Tecnico de Mantenimiento',     'Reparacion de equipos e infraestructura',     16500.00, 13500.00, 23000.00, 1350.00),
    ('Coordinador de Proyectos',     'Planificacion y seguimiento de proyectos',    32500.00, 26000.00, 47000.00, 2700.00),
    ('Asistente Legal',              'Apoyo en tramites juridicos',                 18500.00, 15000.00, 26000.00, 1500.00),
    ('Jefe de Sistemas',             'Liderazgo y estrategia de TI',                42000.00, 35000.00, 58000.00, 3700.00),
    ('Vendedor Interno',             'Ventas en mostrador o local',                 14500.00, 12000.00, 21000.00, 1150.00),
    ('Auxiliar de Bodega',           'Apoyo en clasificacion de productos',         10500.00,  9000.00, 13500.00,  840.00),
    ('Supervisor de Calidad',        'Aseguramiento de estandares de calidad',      27500.00, 22000.00, 39000.00, 2200.00),
    ('Jefe de Seguridad',            'Coordinacion del personal de seguridad',      26000.00, 21000.00, 37000.00, 2100.00),
    ('Agente de Seguridad',          'Vigilancia y control de acceso al edificio',  12500.00, 10500.00, 17000.00,  950.00),
    ('Representante de Servicio',    'Atencion y soporte post venta',               16000.00, 13000.00, 22000.00, 1250.00),
    ('Asistente de Logistica',       'Coordinacion de entregas y rutas',            15500.00, 12500.00, 21000.00, 1200.00),
    ('Coordinador de Capacitacion',  'Planificacion de programas de formacion',     24500.00, 19500.00, 35000.00, 1950.00),
    ('Analista de Nomina',           'Procesamiento y revision de nominas',         22500.00, 18000.00, 33000.00, 1750.00),
    ('Jefe de Creditos',             'Evaluacion de solicitudes de credito',        35000.00, 28000.00, 51000.00, 3000.00),
    ('Gerente Administrativo',       'Supervision de procesos administrativos',     48000.00, 39000.00, 65000.00, 4200.00),
    ('Coordinador de Importaciones', 'Gestion de importacion de mercancias',        30500.00, 24500.00, 44000.00, 2550.00),
    ('Analista de Credito',          'Evaluacion del riesgo crediticio de clientes',21000.00, 17000.00, 30000.00, 1650.00);
GO
 
-- ============================================================
-- INSERT: RRHH.Empleado
-- ============================================================
INSERT INTO RRHH.Empleado (primer_nombre, segundo_nombre, primer_apellido, segundo_apellido, sexo, fecha_nacimiento, ciudad, estado_civil, numero_inss, cedula, telefono, correo) VALUES
    ('Carlos',   'Eduardo',   'Martinez',  'Lopez',     'M', '1980-03-15', 'Managua',    'Casado',         'INSS001', '001-010380-0001A', '88001111', 'cmartinez@empresa.com'),
    ('Ana',      'Maria',     'Gutierrez', 'Torres',    'F', '1985-07-22', 'Managua',    'Soltera',        'INSS002', '001-220785-0002B', '88002222', 'agutierrez@empresa.com'),
    ('Luis',     NULL,        'Hernandez', 'Ruiz',      'M', '1990-11-05', 'Leon',       'Casado',         'INSS003', '001-051190-0003C', '88003333', 'lhernandez@empresa.com'),
    ('Maria',    'Jose',      'Perez',     'Castillo',  'F', '1992-04-18', 'Managua',    'Union de hecho', 'INSS004', '001-180492-0004D', '88004444', 'mperez@empresa.com'),
    ('Roberto',  'Antonio',   'Sanchez',   'Morales',   'M', '1978-09-30', 'Granada',    'Divorciado',     'INSS005', '001-300978-0005E', '88005555', 'rsanchez@empresa.com'),
    ('Sofia',    'Alejandra', 'Ramirez',   'Diaz',      'F', '1995-02-14', 'Masaya',     'Soltera',        'INSS006', '001-140295-0006F', '88006666', 'sramirez@empresa.com'),
    ('Jorge',    'Alberto',   'Mendoza',   'Vega',      'M', '1988-06-27', 'Managua',    'Casado',         'INSS007', '001-270688-0007G', '88007777', 'jmendoza@empresa.com'),
    ('Laura',    NULL,        'Vargas',    'Reyes',     'F', '1993-12-03', 'Chinandega', 'Soltera',        'INSS008', '001-031293-0008H', '88008888', 'lvargas@empresa.com'),
    ('Miguel',   'Angel',     'Torres',    'Jimenez',   'M', '1983-08-11', 'Esteli',     'Casado',         'INSS009', '001-110883-0009I', '88009999', 'mtorres@empresa.com'),
    ('Carmen',   'Isabel',    'Flores',    'Cruz',      'F', '1991-05-25', 'Managua',    'Casado',         'INSS010', '001-250591-0010J', '88010000', 'cflores@empresa.com'),
    ('Andres',   'Felipe',    'Castillo',  'Rivas',     'M', '1987-01-19', 'Managua',    'Casado',         'INSS011', '001-190187-0011K', '88011111', 'acastillo@empresa.com'),
    ('Valeria',  NULL,        'Moreno',    'Campos',    'F', '1994-08-08', 'Leon',       'Soltera',        'INSS012', '001-080894-0012L', '88012222', 'vmoreno@empresa.com'),
    ('Hector',   'Ramon',     'Espinoza',  'Montoya',   'M', '1982-03-30', 'Matagalpa',  'Casado',         'INSS013', '001-300382-0013M', '88013333', 'hespinoza@empresa.com'),
    ('Patricia', 'Lucia',     'Lopez',     'Mendez',    'F', '1989-11-11', 'Managua',    'Divorciado',     'INSS014', '001-111189-0014N', '88014444', 'plopez@empresa.com'),
    ('Ricardo',  NULL,        'Aguilar',   'Fuentes',   'M', '1996-06-23', 'Masaya',     'Soltero',        'INSS015', '001-230696-0015O', '88015555', 'raguilar@empresa.com'),
    ('Diana',    'Carolina',  'Bravo',     'Ortega',    'F', '1991-09-05', 'Granada',    'Casado',         'INSS016', '001-050991-0016P', '88016666', 'dbravo@empresa.com'),
    ('Oscar',    'Manuel',    'Rios',      'Molina',    'M', '1984-04-17', 'Chinandega', 'Union de hecho', 'INSS017', '001-170484-0017Q', '88017777', 'orios@empresa.com'),
    ('Isabel',   'Fernanda',  'Cruz',      'Salinas',   'F', '1993-07-29', 'Esteli',     'Soltera',        'INSS018', '001-290793-0018R', '88018888', 'icruz@empresa.com'),
    ('Fernando', 'Jose',      'Nunez',     'Soto',      'M', '1979-12-02', 'Managua',    'Casado',         'INSS019', '001-021279-0019S', '88019999', 'fnunez@empresa.com'),
    ('Gabriela', NULL,        'Acosta',    'Paredes',   'F', '1997-05-15', 'Leon',       'Soltera',        'INSS020', '001-150597-0020T', '88020000', 'gacosta@empresa.com'),
    ('Alejandro','Ernesto',   'Reyes',     'Rueda',     'M', '1986-10-28', 'Managua',    'Casado',         'INSS021', '001-281086-0021U', '88021111', 'areyes@empresa.com'),
    ('Monica',   'Patricia',  'Jimenez',   'Herrera',   'F', '1990-02-14', 'Masaya',     'Divorciado',     'INSS022', '001-140290-0022V', '88022222', 'mjimenez@empresa.com'),
    ('Eduardo',  'Luis',      'Solis',     'Vargas',    'M', '1985-07-07', 'Granada',    'Casado',         'INSS023', '001-070785-0023W', '88023333', 'esolis@empresa.com'),
    ('Adriana',  NULL,        'Mejia',     'Fuentes',   'F', '1992-11-20', 'Managua',    'Soltera',        'INSS024', '001-201192-0024X', '88024444', 'amejia@empresa.com'),
    ('Juan',     'Pablo',     'Vega',      'Lara',      'M', '1981-03-09', 'Chinandega', 'Viudo',          'INSS025', '001-090381-0025Y', '88025555', 'jvega@empresa.com'),
    ('Claudia',  'Beatriz',   'Padilla',   'Espino',    'F', '1995-08-18', 'Esteli',     'Soltera',        'INSS026', '001-180895-0026Z', '88026666', 'cpadilla@empresa.com'),
    ('Marcos',   'Ignacio',   'Zelaya',    'Beltran',   'M', '1988-01-25', 'Managua',    'Casado',         'INSS027', '001-250188-0027A', '88027777', 'mzelaya@empresa.com'),
    ('Natalia',  'Elena',     'Chavarria', 'Obando',    'F', '1994-06-13', 'Leon',       'Union de hecho', 'INSS028', '001-130694-0028B', '88028888', 'nchavarria@empresa.com'),
    ('Alfonso',  NULL,        'Miranda',   'Carballo',  'M', '1977-09-01', 'Matagalpa',  'Casado',         'INSS029', '001-010977-0029C', '88029999', 'amiranda@empresa.com'),
    ('Karina',   'Liseth',    'Gutierrez', 'Palacios',  'F', '1998-04-04', 'Managua',    'Soltera',        'INSS030', '001-040498-0030D', '88030000', 'kgutierrez@empresa.com'),
    ('Pablo',    'Sebastian', 'Contreras', 'Valverde',  'M', '1983-11-17', 'Masaya',     'Casado',         'INSS031', '001-171183-0031E', '88031111', 'pcontreras@empresa.com'),
    ('Lorena',   NULL,        'Espinoza',  'Cano',      'F', '1991-08-30', 'Granada',    'Casado',         'INSS032', '001-300891-0032F', '88032222', 'lespinoza@empresa.com'),
    ('Francisco','Javier',    'Centeno',   'Quezada',   'M', '1980-05-12', 'Chinandega', 'Divorciado',     'INSS033', '001-120580-0033G', '88033333', 'fcenteno@empresa.com'),
    ('Silvia',   'Ruth',      'Palma',     'Meneses',   'F', '1989-02-27', 'Esteli',     'Casado',         'INSS034', '001-270289-0034H', '88034444', 'spalma@empresa.com'),
    ('Daniel',   'Enrique',   'Flores',    'Reina',     'M', '1996-10-10', 'Managua',    'Soltero',        'INSS035', '001-101096-0035I', '88035555', 'dflores@empresa.com'),
    ('Beatriz',  'Mercedes',  'Ortiz',     'Ulate',     'F', '1987-04-22', 'Leon',       'Soltera',        'INSS036', '001-220487-0036J', '88036666', 'bortiz@empresa.com'),
    ('Sergio',   NULL,        'Zamora',    'Guerrero',  'M', '1982-07-15', 'Matagalpa',  'Casado',         'INSS037', '001-150782-0037K', '88037777', 'szamora@empresa.com'),
    ('Rosa',     'Amalia',    'Lezama',    'Solano',    'F', '1993-12-28', 'Managua',    'Union de hecho', 'INSS038', '001-281293-0038L', '88038888', 'rlezama@empresa.com'),
    ('Victor',   'Hugo',      'Cano',      'Medrano',   'M', '1979-06-05', 'Masaya',     'Casado',         'INSS039', '001-050679-0039M', '88039999', 'vcano@empresa.com'),
    ('Wendy',    NULL,        'Mendez',    'Blanco',    'F', '1997-09-19', 'Granada',    'Soltera',        'INSS040', '001-190997-0040N', '88040000', 'wmendez@empresa.com'),
    ('Ernesto',  'Rafael',    'Ibarra',    'Lira',      'M', '1986-01-31', 'Chinandega', 'Casado',         'INSS041', '001-310186-0041O', '88041111', 'eibarra@empresa.com'),
    ('Norma',    'Cecilia',   'Delgado',   'Orozco',    'F', '1990-05-08', 'Esteli',     'Casado',         'INSS042', '001-080590-0042P', '88042222', 'ndelgado@empresa.com'),
    ('Raul',     'Alfredo',   'Montes',    'Sequeira',  'M', '1984-08-24', 'Managua',    'Divorciado',     'INSS043', '001-240884-0043Q', '88043333', 'rmontes@empresa.com'),
    ('Ingrid',   'Marlen',    'Suarez',    'Chacon',    'F', '1992-03-16', 'Leon',       'Soltera',        'INSS044', '001-160392-0044R', '88044444', 'isuarez@empresa.com'),
    ('German',   NULL,        'Mora',      'Espinoza',  'M', '1977-10-03', 'Matagalpa',  'Casado',         'INSS045', '001-031077-0045S', '88045555', 'gmora@empresa.com'),
    ('Yessenia', 'Paola',     'Alvarez',   'Vanegas',   'F', '1995-01-14', 'Managua',    'Soltera',        'INSS046', '001-140195-0046T', '88046666', 'yalvarez@empresa.com'),
    ('Cesar',    'Augusto',   'Jarquin',   'Acuna',     'M', '1983-06-27', 'Masaya',     'Casado',         'INSS047', '001-270683-0047U', '88047777', 'cjarquin@empresa.com'),
    ('Tania',    NULL,        'Ruiz',      'Gomez',     'F', '1998-11-09', 'Granada',    'Soltera',        'INSS048', '001-091198-0048V', '88048888', 'truiz@empresa.com'),
    ('Giancarlo','Fabian',    'Mendoza',   'Rivas',     'M', '1981-04-21', 'Chinandega', 'Union de hecho', 'INSS049', '001-210481-0049W', '88049999', 'gmendoza2@empresa.com'),
    ('Xiomara',  'Vanessa',   'Picado',    'Torrez',    'F', '1994-07-03', 'Managua',    'Casado',         'INSS050', '001-030794-0050X', '88050000', 'xpicado@empresa.com');
GO
 
-- ============================================================
-- INSERT: RRHH.Empleado_Cargo
-- ============================================================
INSERT INTO RRHH.Empleado_Cargo (id_empleado, id_cargo, salario_asignado, fecha_inicio, fecha_fin) VALUES
    ( 1,  1, 62000.00, '2018-01-02', NULL),
    ( 2,  2, 36000.00, '2019-03-01', NULL),
    ( 3,  3, 30500.00, '2020-06-15', NULL),
    ( 4,  4, 14500.00, '2021-01-10', NULL),
    ( 5,  5, 28500.00, '2017-08-01', NULL),
    ( 6,  8, 15500.00, '2022-02-14', NULL),
    ( 7,  7, 22500.00, '2019-11-01', NULL),
    ( 8,  8, 15000.00, '2023-03-06', NULL),
    ( 9,  9, 13500.00, '2020-09-20', NULL),
    (10, 10, 33000.00, '2021-05-03', NULL),
    (11, 11, 16500.00, '2022-07-01', NULL),
    (12, 12, 24500.00, '2021-10-15', NULL),
    (13, 13, 26500.00, '2020-03-01', NULL),
    (14, 14, 13000.00, '2023-01-09', NULL),
    (15, 15, 11500.00, '2022-06-20', NULL),
    (16,  6, 25500.00, '2019-08-12', NULL),
    (17, 17, 15500.00, '2021-04-05', NULL),
    (18, 18, 21500.00, '2020-11-23', NULL),
    (19, 19, 29500.00, '2018-05-14', NULL),
    (20, 20, 23500.00, '2022-09-19', NULL),
    (21, 21, 18500.00, '2021-03-07', NULL),
    (22, 22, 33500.00, '2019-06-18', NULL),
    (23, 23, 14000.00, '2023-02-28', NULL),
    (24, 24, 10500.00, '2022-08-01', NULL),
    (25,  1, 61000.00, '2016-09-01', NULL),
    (26, 26, 36500.00, '2020-12-10', NULL),
    (27, 27, 17500.00, '2021-07-22', NULL),
    (28, 28, 12500.00, '2022-04-04', NULL),
    (29, 29, 11800.00, '2023-05-15', NULL),
    (30, 30, 20500.00, '2019-02-11', NULL),
    (31, 31, 31500.00, '2020-08-03', NULL),
    (32, 32, 27500.00, '2021-01-18', NULL),
    (33, 33, 34500.00, '2018-11-25', NULL),
    (34, 34, 17000.00, '2022-03-14', NULL),
    (35, 35, 33000.00, '2020-07-06', NULL),
    (36, 36, 19000.00, '2021-09-29', NULL),
    (37, 37, 42500.00, '2017-04-17', NULL),
    (38, 38, 14800.00, '2022-10-10', NULL),
    (39, 39, 11000.00, '2023-06-01', NULL),
    (40, 40, 28000.00, '2019-11-11', NULL),
    (41, 41, 26500.00, '2020-05-25', NULL),
    (42, 42, 13000.00, '2022-01-17', NULL),
    (43, 43, 16500.00, '2021-08-09', NULL),
    (44, 44, 15800.00, '2022-11-21', NULL),
    (45, 45, 24800.00, '2020-04-13', NULL),
    (46, 46, 22800.00, '2019-07-30', NULL),
    (47, 47, 35500.00, '2018-03-26', NULL),
    (48, 48, 48500.00, '2016-10-14', NULL),
    (49, 49, 31000.00, '2019-12-02', NULL),
    (50, 50, 21500.00, '2021-06-28', NULL);
GO
 
-- ============================================================
-- INSERT: CATALOGOS.Categoria_Percepcion
-- ============================================================
INSERT INTO CATALOGOS.Categoria_Percepcion (nombre, aplica_impuesto, descripcion) VALUES
    ('Salario base',              1, 'Sueldo contractual mensual del empleado'),
    ('Horas extra diurnas',       1, 'Remuneracion por horas adicionales en horario diurno'),
    ('Horas extra nocturnas',     1, 'Remuneracion por horas adicionales en horario nocturno'),
    ('Viaticos',                  0, 'Gastos de transporte y alimentacion en comisiones'),
    ('Bono productividad',        1, 'Incentivo por cumplimiento de metas mensuales'),
    ('Premio puntualidad',        1, 'Reconocimiento por asistencia perfecta del mes'),
    ('Comision ventas',           1, 'Porcentaje sobre ventas realizadas en el periodo'),
    ('Subsidio transporte',       0, 'Apoyo economico para movilizacion diaria'),
    ('Bono antiguedad',           1, 'Reconocimiento por anos de servicio continuo'),
    ('Bono navidad',              1, 'Pago extra equivalente a un mes de salario en diciembre'),
    ('Reintegro por error',       0, 'Devolucion de descuento aplicado incorrectamente'),
    ('Subsidio alimentacion',     0, 'Apoyo economico para gastos de alimentacion'),
    ('Bono academico',            1, 'Incentivo por estudios relacionados al cargo'),
    ('Comision referidos',        1, 'Bonificacion por referir clientes nuevos'),
    ('Bono fin de ano',           1, 'Incentivo especial al cierre del ejercicio fiscal'),
    ('Incentivo por meta grupal', 1, 'Bono por logro de objetivos del equipo'),
    ('Complemento salarial',      1, 'Ajuste temporal al salario asignado'),
    ('Prima dominical',           1, 'Pago adicional por laborar en domingo'),
    ('Pago dia feriado',          1, 'Doble pago por laborar en dia feriado nacional'),
    ('Guardia nocturna',          1, 'Compensacion por turnos nocturnos asignados'),
    ('Retroactivo salarial',      1, 'Pago de diferencia salarial de periodos anteriores'),
    ('Bono de retencion',         1, 'Pago para retener al empleado en la empresa'),
    ('Beneficio escolar',         0, 'Apoyo para utiles escolares de hijos del empleado'),
    ('Bono de salud',             0, 'Contribucion a gastos medicos del empleado'),
    ('Comision exportaciones',    1, 'Porcentaje por ventas al exterior'),
    ('Bono gerencial',            1, 'Incentivo exclusivo para posiciones de liderazgo'),
    ('Pago de guardias',          1, 'Compensacion por turnos de guardia asignados'),
    ('Bono semestral',            1, 'Incentivo pagado cada seis meses'),
    ('Horas extra festivas',      1, 'Horas trabajadas en dias feriados nacionales'),
    ('Viaje de campo',            0, 'Viatico para visitas de trabajo en campo'),
    ('Subsidio lactancia INSS',   0, 'Complemento al subsidio de maternidad del INSS'),
    ('Comision recaudacion',      1, 'Porcentaje por cobros efectivos realizados'),
    ('Bono especial Covid',       0, 'Beneficio extraordinario en periodo pandemia'),
    ('Indemnizacion pactada',     0, 'Acuerdo de terminacion con pago pactado'),
    ('Bono capacitacion',         0, 'Apoyo para cursos y certificaciones externas'),
    ('Compensacion por traslado', 0, 'Apoyo economico por cambio de sede laboral'),
    ('Pago por disponibilidad',   1, 'Compensacion por estar disponible fuera de horario'),
    ('Bono liderazgo',            1, 'Incentivo para supervisores con equipo a cargo'),
    ('Aumento de emergencia',     1, 'Ajuste salarial de emergencia por inflacion'),
    ('Bono contratacion',         0, 'Pago unico al incorporarse a la empresa'),
    ('Prima turno rotativo',      1, 'Compensacion por laborar en turnos rotativos'),
    ('Beneficio deportivo',       0, 'Apoyo para actividades fisicas y deportivas'),
    ('Comision logro anual',      1, 'Bonificacion por superar la meta anual'),
    ('Subsidio vivienda',         0, 'Apoyo para gastos de alquiler del empleado'),
    ('Incentivo fidelizacion',    1, 'Bonificacion por permanencia continua en la empresa'),
    ('Bono cierre proyecto',      1, 'Pago al finalizar exitosamente un proyecto asignado'),
    ('Diferencia de turno',       1, 'Ajuste por cambio de turno de trabajo'),
    ('Bono de resultado',         1, 'Incentivo basado en indicadores de desempeno'),
    ('Comision por cobranza',     1, 'Porcentaje por recuperacion de cartera morosa'),
    ('Compensacion vacaciones',   1, 'Pago monetario de vacaciones no disfrutadas');
GO
 
-- ============================================================
-- INSERT: CATALOGOS.Categoria_Deduccion
-- ============================================================
INSERT INTO CATALOGOS.Categoria_Deduccion (nombre, porcentaje, es_obligatoria, descripcion) VALUES
    ('INSS Laboral',               7.00, 1, 'Ley 539 — 7% del salario bruto'),
    ('IR Renta',                   NULL, 1, 'Ley 822 — tabla progresiva IR'),
    ('Embargo judicial',           NULL, 0, 'Descuento por orden judicial'),
    ('Anticipo de salario',        NULL, 0, 'Adelanto solicitado por el empleado'),
    ('Prestamo interno',           NULL, 0, 'Cuota de prestamo otorgado por la empresa'),
    ('Seguro medico privado',      2.50, 0, 'Prima de seguro de salud opcional'),
    ('Cuota sindical',             1.00, 0, 'Aporte mensual al sindicato'),
    ('Caja de ahorro',             5.00, 0, 'Ahorro voluntario mensual solidario'),
    ('Descuento por inasistencia', NULL, 0, 'Proporcional por dia no laborado'),
    ('Descuento por tardanza',     NULL, 0, 'Por llegadas tardes reiteradas'),
    ('Seguro de vida colectivo',   1.50, 0, 'Prima de seguro de vida grupal'),
    ('Descuento uniforme',         NULL, 0, 'Cuota por entrega de uniforme de trabajo'),
    ('Deduccion herramienta',      NULL, 0, 'Descuento por herramienta asignada'),
    ('Prestamo hipotecario',       NULL, 0, 'Cuota de prestamo hipotecario via planilla'),
    ('Descuento vehiculo',         NULL, 0, 'Cuota de vehiculo asignado en uso personal'),
    ('Multa disciplinaria',        NULL, 0, 'Sancion economica por falta disciplinaria'),
    ('Retencion garantia',         NULL, 0, 'Retencion hasta finalizacion de contrato'),
    ('Deduccion por dano',         NULL, 0, 'Descuento por activo danado bajo responsabilidad'),
    ('INATEC empleado',            2.00, 0, 'Contribucion voluntaria a formacion tecnica'),
    ('Pension alimenticia',        NULL, 0, 'Descuento por orden de pension familiar'),
    ('Cuota asociacion',           NULL, 0, 'Aporte a asociacion profesional del empleado'),
    ('Seguro dental',              1.00, 0, 'Prima de seguro dental opcional'),
    ('Seguro visual',              0.75, 0, 'Prima de seguro visual opcional'),
    ('Deduccion capacitacion',     NULL, 0, 'Cuota por capacitacion externa pagada por empresa'),
    ('Descuento comedor',          NULL, 0, 'Consumo en comedor de la empresa'),
    ('Cuota cooperativa',          3.00, 0, 'Aporte mensual a cooperativa de empleados'),
    ('Retencion impuesto especial',NULL, 0, 'Impuesto especifico retenido en planilla'),
    ('Pago en exceso anterior',    NULL, 0, 'Recuperacion de pago de mas en periodo previo'),
    ('Deduccion por prestamo BDF', NULL, 0, 'Cuota descontada por acuerdo con banco'),
    ('Deduccion educacion',        NULL, 0, 'Cuota por beca interna otorgada'),
    ('Seguro de accidente',        1.25, 0, 'Prima seguro accidentes personales'),
    ('Deduccion vacaciones anticipadas', NULL, 0, 'Recuperacion de vacaciones pagadas anticipadamente'),
    ('Retencion por fallo',        NULL, 0, 'Descuento por resolucion de auditoria interna'),
    ('Multa por incumplimiento',   NULL, 0, 'Sancion por incumplimiento de objetivo critico'),
    ('Deduccion lactancia privada',NULL, 0, 'Cuota periodo lactancia complementario empresa'),
    ('Ahorro programado',          4.00, 0, 'Ahorro en plan propio de la empresa'),
    ('Descuento hospedaje',        NULL, 0, 'Cuota por hospedaje en instalaciones de empresa'),
    ('Prima seguro auto',          NULL, 0, 'Porcion de seguro de vehiculo corporativo'),
    ('Cuota club deportivo',       NULL, 0, 'Membresia club interno para empleados'),
    ('Deduccion por avance',       NULL, 0, 'Recuperacion de avance de gastos no justificado'),
    ('Retencion legal emergencia', NULL, 0, 'Retencion temporal por proceso legal activo'),
    ('Descuento por faltante',     NULL, 0, 'Faltante de caja o inventario a cargo del empleado'),
    ('Cuota fondo retiro privado', 2.00, 0, 'Aporte voluntario a fondo de retiro privado'),
    ('Prima complementaria INSS',  NULL, 0, 'Complemento de cobertura del INSS por plan empresa'),
    ('Cuota plan funerario',       NULL, 0, 'Plan de exequias para el empleado y familia'),
    ('Descuento por error',        NULL, 0, 'Recuperacion por error de pago en nomina previa'),
    ('Cuota plan dental familiar', NULL, 0, 'Extension del seguro dental a familia directa'),
    ('Deduccion bono devuelto',    NULL, 0, 'Devolucion de bono pagado no devengado'),
    ('Seguro mascota',             NULL, 0, 'Plan de salud para mascota del empleado'),
    ('Cuota plan medico familiar', 3.50, 0, 'Extension del seguro medico a familiares directos');
GO
 
-- ============================================================
-- INSERT: CATALOGOS.Tipo_Incidencia
-- ============================================================
INSERT INTO CATALOGOS.Tipo_Incidencia (nombre_tipo, categoria, afecta_salario) VALUES
    ('Hora extra diurna',               'Percepcion', 1),
    ('Hora extra nocturna',             'Percepcion', 1),
    ('Bono por meta mensual',           'Percepcion', 1),
    ('Ausencia injustificada',          'Deduccion',  1),
    ('Incapacidad INSS',                'Ninguna',    0),
    ('Vacaciones programadas',          'Ninguna',    0),
    ('Licencia maternidad',             'Ninguna',    0),
    ('Licencia paternidad',             'Ninguna',    0),
    ('Permiso sin goce de sueldo',      'Deduccion',  1),
    ('Tardanza',                        'Deduccion',  1),
    ('Hora extra festiva',              'Percepcion', 1),
    ('Permiso con goce de sueldo',      'Ninguna',    0),
    ('Suspension disciplinaria',        'Deduccion',  1),
    ('Licencia por duelo',              'Ninguna',    0),
    ('Hora extra dominical',            'Percepcion', 1),
    ('Subsidio lactancia',              'Ninguna',    0),
    ('Accidente laboral',               'Ninguna',    0),
    ('Comision especial',               'Percepcion', 1),
    ('Bono de retencion puntual',       'Percepcion', 1),
    ('Descuento de uniformes',          'Deduccion',  1),
    ('Prima dominical',                 'Percepcion', 1),
    ('Ajuste retroactivo positivo',     'Percepcion', 1),
    ('Ajuste retroactivo negativo',     'Deduccion',  1),
    ('Salida temprana autorizada',      'Ninguna',    0),
    ('Descuento comedor empresa',       'Deduccion',  1),
    ('Licencia por estudio',            'Ninguna',    0),
    ('Horas de guardia nocturna',       'Percepcion', 1),
    ('Capacitacion pagada interna',     'Ninguna',    0),
    ('Hora de disponibilidad',          'Percepcion', 1),
    ('Multa por incumplimiento',        'Deduccion',  1),
    ('Reintegro de viatico',            'Percepcion', 0),
    ('Descuento herramienta danada',    'Deduccion',  1),
    ('Bono cierre de proyecto',         'Percepcion', 1),
    ('Permiso medico con subsidio',     'Ninguna',    0),
    ('Descuento por faltante de caja',  'Deduccion',  1),
    ('Traslado de sede',                'Ninguna',    0),
    ('Bono semestral',                  'Percepcion', 1),
    ('Incentivo anual',                 'Percepcion', 1),
    ('Huelga legal',                    'Deduccion',  1),
    ('Paro tecnico',                    'Ninguna',    0),
    ('Licencia sindical',               'Ninguna',    0),
    ('Hora extra en turno rotativo',    'Percepcion', 1),
    ('Descuento por prestamo interno',  'Deduccion',  1),
    ('Premio de puntualidad',           'Percepcion', 1),
    ('Falta justificada documentada',   'Ninguna',    0),
    ('Descuento por sancion',           'Deduccion',  1),
    ('Ingreso por turno adicional',     'Percepcion', 1),
    ('Pago de dias de descanso',        'Percepcion', 1),
    ('Cuota de cooperativa',            'Deduccion',  1),
    ('Bono fin de año especial',        'Percepcion', 1);
GO
 
-- ============================================================
-- INSERT: CATALOGOS.Tipo_Aporte
-- ============================================================
INSERT INTO CATALOGOS.Tipo_Aporte (nombre_aporte, porcentaje, descripcion) VALUES
    ('INSS Patronal grande',        22.50, 'Ley 539 — empresas con mas de 50 empleados'),
    ('INSS Patronal pequeno',       21.50, 'Ley 539 — empresas con 50 o menos empleados'),
    ('INATEC',                       2.00, 'Decreto 40-94 — formacion tecnica'),
    ('Fondo de retiro patronal',     3.00, 'Aporte voluntario patronal al fondo de pensiones'),
    ('Seguro colectivo patronal',    1.50, 'Prima de seguro de vida colectivo a cargo empresa'),
    ('Fondo social empresa',         0.50, 'Contribucion a actividades de bienestar social'),
    ('Fondo capacitacion patronal',  1.00, 'Financiamiento para formacion del personal'),
    ('Seguro riesgo laboral',        1.50, 'Cobertura de accidentes en el trabajo INSS'),
    ('Salud ocupacional patronal',   0.75, 'Programa de salud preventiva empresarial'),
    ('INATEC reducido',              1.00, 'Tasa aplicable a empresas exentas parciales'),
    ('Fondo escolar',                0.25, 'Apoyo patronal para hijos de empleados en edad escolar'),
    ('Seguro medico colectivo',      2.00, 'Aporte patronal al plan de salud grupal'),
    ('Plan dental colectivo',        0.50, 'Contribucion patronal al seguro dental grupal'),
    ('Fondo de vivienda',            1.00, 'Aporte patronal al fondo de prestamos de vivienda'),
    ('Prima funeraria empresa',      0.30, 'Cobertura de exequias costeada por la empresa'),
    ('Aporte plan retiro privado',   2.50, 'Contribucion patronal al plan de retiro adicional'),
    ('Seguro auto corporativo',      0.80, 'Aporte patronal a seguro de vehiculos empresa'),
    ('Fondo emergencia salud',       0.60, 'Reserva patronal para gastos medicos de emergencia'),
    ('Contribucion cooperativa',     1.20, 'Aporte patronal a cooperativa de empleados'),
    ('Bono alimentacion patronal',   0.40, 'Contribucion patronal al subsidio de comedor'),
    ('Fondo cultural empresa',       0.15, 'Apoyo para actividades culturales del personal'),
    ('Plan deportivo patronal',      0.20, 'Apoyo patronal a actividades deportivas del equipo'),
    ('Prima seguro dental familiar', 0.60, 'Extension patronal del seguro dental a familiares'),
    ('Seguro vision patronal',       0.45, 'Cobertura patronal para salud visual'),
    ('Fondo anticipo emergencia',    0.35, 'Reserva para anticipos por emergencia del empleado'),
    ('Aporte INSS adicional',        1.00, 'Contribucion patronal voluntaria extra al INSS'),
    ('Plan pension complementario',  3.50, 'Fondo privado de pension complementaria patronal'),
    ('Seguro accidentes patronal',   1.25, 'Prima patronal de seguro de accidentes personales'),
    ('Fondo becas estudio',          0.55, 'Apoyo patronal a becas de educacion superior'),
    ('Seguro mascota patronal',      0.10, 'Beneficio patronal de plan de salud para mascota'),
    ('Fondo tecnologia empleado',    0.30, 'Aporte para adquisicion de equipos personales'),
    ('Prima bienestar mental',       0.50, 'Apoyo patronal a salud psicologica del empleado'),
    ('Plan nutricion empresa',       0.25, 'Contribucion a consultoria nutricional interna'),
    ('Fondo movilidad sostenible',   0.20, 'Apoyo para transporte verde del empleado'),
    ('Aporte conciliacion familiar', 0.30, 'Apoyo a programas de balance vida-trabajo'),
    ('Fondo innovacion interna',     0.40, 'Reserva para proyectos de innovacion del personal'),
    ('Prima respaldo legal',         0.35, 'Cobertura de asesoria legal para empleados'),
    ('Plan de tutoria empresa',      0.15, 'Apoyo patronal a programas de mentoring'),
    ('Fondo retiro anticipado',      2.00, 'Complemento de retiro para empleados mayores de 55'),
    ('Seguro repatriacion',          0.25, 'Cobertura por fallecimiento fuera del pais'),
    ('Aporte salud bucal infantil',  0.20, 'Extension del plan dental a hijos menores de 12'),
    ('Fondo emergencia habitacional',0.50, 'Reserva para desastres naturales del empleado'),
    ('Prima seguro escolar',         0.15, 'Cobertura de accidentes escolares de hijos'),
    ('Plan psicologico empresarial', 0.40, 'Sesiones de apoyo psicologico pagadas por empresa'),
    ('Fondo recreacion empleado',    0.30, 'Subsidio para vacaciones y actividades recreativas'),
    ('Prima salud ocular familiar',  0.35, 'Extension del seguro de vision a familiares directos'),
    ('Aporte guardia y custodia',    0.20, 'Cobertura de custodio para hijos de empleados'),
    ('Fondo capacitacion idiomas',   0.45, 'Apoyo patronal a clases de idiomas del personal'),
    ('Plan bienestar emocional',     0.25, 'Programa de coaching y mindfulness empresarial'),
    ('Aporte huella carbono',        0.10, 'Contribucion patronal a compensacion ambiental');
GO
 
-- ============================================================
-- INSERT: CATALOGOS.Tipo_Prestacion
-- ============================================================
INSERT INTO CATALOGOS.Tipo_Prestacion (nombre_prestacion, regla_calculo, descripcion) VALUES
    ('Aguinaldo',                   '1/12 del salario mensual acumulado',                'Art. 93 CT NI — pagadero en diciembre'),
    ('Vacaciones',                  '2.5 dias por mes trabajado (30 dias al ano)',        'Art. 76 CT NI'),
    ('Indemnizacion despido',       '1 mes por ano trabajado, maximo 5 meses',           'Art. 45 CT NI — despido sin causa'),
    ('Liquidacion final',           'Suma de prestaciones al termino del contrato',       'Incluye vacaciones, aguinaldo e indemnizacion'),
    ('Bono escolar',                'Monto fijo anual de 500 USD por hijo en primaria',  'Beneficio interno para hijos en edad escolar'),
    ('Subsidio lactancia',          '60% del salario durante 3 meses postparto',         'Complemento al subsidio INSS para madres lactantes'),
    ('Fondo de ahorro',             'Acumulado de cuota patronal al fondo solidario',    'Entregado al retiro o renuncia voluntaria'),
    ('Prima de antiguedad',         '1% adicional al salario base por cada 5 anos',      'Reconocimiento por permanencia en la empresa'),
    ('Gastos medicos',              'Reembolso hasta 3 salarios minimos por evento',     'Gastos no cubiertos por el INSS'),
    ('Seguro de vida',              '24 salarios en caso de fallecimiento',              'Pagadero a beneficiario designado'),
    ('Subsidio escolar',            'Monto fijo mensual de 200 USD durante periodo escolar', 'Apoyo para educacion de hijos'),
    ('Prima vacacional',            '30% adicional sobre el salario durante vacaciones', 'Incentivo vacacional interno'),
    ('Plan de retiro anticipado',   '6 meses de salario al cumplir 30 anos de servicio','Reconocimiento por larga trayectoria'),
    ('Bono por logros anuales',     '10% del salario anual si se alcanza 100% del plan','Basado en evaluacion de desempeno anual'),
    ('Complemento de incapacidad',  'Diferencia entre subsidio INSS y salario real',    'Garantiza el 100% del salario en incapacidad'),
    ('Seguro accidentes personales','Capital de 12 salarios por invalidez permanente',  'Aplica fuera y dentro del trabajo'),
    ('Subsidio funerario',          'Monto fijo de 2000 USD por fallecimiento de familiar directo', 'Para conyugue, hijos o padres del empleado'),
    ('Bono por retencion 2 anos',   'Pago unico equivalente a 2 meses de salario',      'Aplica al cumplir 2 anos continuos'),
    ('Plan dental colectivo',       'Cobertura de hasta 1500 USD anuales por empleado', 'Odontologia basica y especializada'),
    ('Vision empleado',             'Cobertura hasta 500 USD anuales para lentes/examenes', 'Beneficio anual de salud visual'),
    ('Subsidio guarderia',          '50% del costo mensual de guarderia por hijo menor de 5', 'Solo aplica a empleados con contrato indefinido'),
    ('Dias adicionales vacaciones', '5 dias extra de vacaciones por 5 anos de servicio','Acumulables, no monetizables'),
    ('Plan psicologico',            '6 sesiones gratuitas al ano con psicologo empresa', 'Bienestar mental del empleado'),
    ('Bono cierre fiscal',          '1 salario adicional si empresa logra utilidad meta', 'Distribucion de utilidades internas'),
    ('Capacitacion externa pagada', 'Hasta 2000 USD anuales en cursos externos aprobados','Con compromiso de permanencia 1 ano'),
    ('Seguro medico familiar',      'Extension del plan medico a conyugue e hijos',     'Plan HMO colectivo negociado por empresa'),
    ('Bono de puntualidad anual',   'Pago equivalente a 15 dias si asistencia perfecta','Aplica sobre 11 meses sin tardanzas ni ausencias'),
    ('Subsidio habitacional',       'Hasta 300 USD mensuales para pago de alquiler',    'Solo empleados foraneos de otra ciudad'),
    ('Plan de movilidad',           'Subsidio de 150 USD mensuales para transporte',    'Aplica a empleados sin vehiculo propio asignado'),
    ('Bono bienestar',              'Monto fijo de 400 USD semestrales para bienestar', 'Para actividades deportivas o salud preventiva'),
    ('Prestacion por traslado',     'Reembolso de gastos de mudanza hasta 3000 USD',    'Por cambio de ciudad por necesidad de la empresa'),
    ('Prima de responsabilidad',    '5% del salario base mensual para puestos de confianza', 'Solo para jefes y gerentes'),
    ('Canasta basica navidad',      'Canasta valorada en 150 USD entregada en diciembre','Beneficio en especie para todo el personal'),
    ('Plan de ahorro voluntario',   'Empleado define porcentaje, empresa duplica hasta 3%', 'Fondo acumulado entregable a los 5 anos'),
    ('Seguro mascota',              'Cobertura veterinaria hasta 300 USD anuales',      'Beneficio opcional para empleados con mascotas'),
    ('Bono por innovacion',         'Hasta 2000 USD por proyecto aprobado e implementado','Reconocimiento a ideas que generen valor'),
    ('Prima de idioma',             '100 USD mensuales por dominio de segundo idioma',  'Certificacion requerida cada 2 anos'),
    ('Subsidio lactancia ampliado', '80% del salario hasta 6 meses postparto',          'Extension interna del subsidio legal'),
    ('Bono mentor',                 'Pago mensual de 200 USD al mentor activo asignado','Para empleados que guian a nuevos ingresos'),
    ('Seguro viaje internacional',  'Cobertura medica y legal en el exterior',          'Aplica para viajes corporativos aprobados'),
    ('Plan nutricion',              '4 consultas nutricionales anuales cubiertas',       'Programa de salud preventiva interna'),
    ('Equipamiento home office',    'Hasta 600 USD para equipar puesto de trabajo remoto','Una sola vez por contratacion o cambio de modalidad'),
    ('Bono cumpleanos',             'Vale de regalo de 75 USD entregado en cumpleanos', 'Reconocimiento personal al empleado'),
    ('Prima turno mixto',           '7% adicional al salario para turnos mixtos',       'Aplica cuando turno cruza mas de 3 horas nocturnas'),
    ('Subsidio internet',           '40 USD mensuales para plan de internet en casa',   'Solo modalidad hibrida o remota'),
    ('Prestacion sindical',         'Segun convenio colectivo vigente aplicable',       'Determinada por negociacion sindical'),
    ('Bono anticipo escolar',       'Adelanto reintegrable de 600 USD en enero',        'Para gastos de matricula e inicio de clases'),
    ('Plan coaching ejecutivo',     '10 sesiones anuales con coach certificado',        'Solo para niveles de jefatura y gerencia'),
    ('Bono sostenibilidad',         '250 USD anuales por practicas sostenibles demostradas', 'Alineado a objetivos ESG de la empresa'),
    ('Prima de disponibilidad',     '10% del salario base mensual por estar en disponibilidad', 'Para cargos criticos de turno 24/7');
GO
 
-- ============================================================
-- INSERT: FISCAL.Tramo_IR
-- ============================================================
INSERT INTO FISCAL.Tramo_IR (ingreso_anual_desde, ingreso_anual_hasta, tasa_marginal_pct, impuesto_base, exceso_desde, fecha_vigencia_ini, fecha_vigencia_fin) VALUES
-- Vigencia 2024
(      0.00, 100000.00,  0.00,      0.00,      0.00, '2024-01-01', NULL),
(100000.01, 200000.00, 15.00,      0.00, 100000.00, '2024-01-01', NULL),
(200000.01, 350000.00, 20.00,  15000.00, 200000.00, '2024-01-01', NULL),
(350000.01, 500000.00, 25.00,  45000.00, 350000.00, '2024-01-01', NULL),
(500000.01,      NULL, 30.00,  82500.00, 500000.00, '2024-01-01', NULL),
-- Vigencia 2023
(      0.00, 100000.00,  0.00,      0.00,      0.00, '2023-01-01', '2023-12-31'),
(100000.01, 200000.00, 15.00,      0.00, 100000.00, '2023-01-01', '2023-12-31'),
(200000.01, 350000.00, 20.00,  15000.00, 200000.00, '2023-01-01', '2023-12-31'),
(350000.01, 500000.00, 25.00,  45000.00, 350000.00, '2023-01-01', '2023-12-31'),
(500000.01,      NULL, 30.00,  82500.00, 500000.00, '2023-01-01', '2023-12-31'),
-- Vigencia 2022
(      0.00, 100000.00,  0.00,      0.00,      0.00, '2022-01-01', '2022-12-31'),
(100000.01, 200000.00, 15.00,      0.00, 100000.00, '2022-01-01', '2022-12-31'),
(200000.01, 350000.00, 20.00,  15000.00, 200000.00, '2022-01-01', '2022-12-31'),
(350000.01, 500000.00, 25.00,  45000.00, 350000.00, '2022-01-01', '2022-12-31'),
(500000.01,      NULL, 30.00,  82500.00, 500000.00, '2022-01-01', '2022-12-31'),
-- Vigencia 2021
(      0.00, 100000.00,  0.00,      0.00,      0.00, '2021-01-01', '2021-12-31'),
(100000.01, 200000.00, 15.00,      0.00, 100000.00, '2021-01-01', '2021-12-31'),
(200000.01, 350000.00, 20.00,  15000.00, 200000.00, '2021-01-01', '2021-12-31'),
(350000.01, 500000.00, 25.00,  45000.00, 350000.00, '2021-01-01', '2021-12-31'),
(500000.01,      NULL, 30.00,  82500.00, 500000.00, '2021-01-01', '2021-12-31'),
-- Vigencia 2020
(      0.00, 100000.00,  0.00,      0.00,      0.00, '2020-01-01', '2020-12-31'),
(100000.01, 200000.00, 15.00,      0.00, 100000.00, '2020-01-01', '2020-12-31'),
(200000.01, 350000.00, 20.00,  15000.00, 200000.00, '2020-01-01', '2020-12-31'),
(350000.01, 500000.00, 25.00,  45000.00, 350000.00, '2020-01-01', '2020-12-31'),
(500000.01,      NULL, 30.00,  82500.00, 500000.00, '2020-01-01', '2020-12-31'),
-- Vigencia 2019
(      0.00, 100000.00,  0.00,      0.00,      0.00, '2019-01-01', '2019-12-31'),
(100000.01, 200000.00, 15.00,      0.00, 100000.00, '2019-01-01', '2019-12-31'),
(200000.01, 350000.00, 20.00,  15000.00, 200000.00, '2019-01-01', '2019-12-31'),
(350000.01, 500000.00, 25.00,  45000.00, 350000.00, '2019-01-01', '2019-12-31'),
(500000.01,      NULL, 30.00,  82500.00, 500000.00, '2019-01-01', '2019-12-31'),
-- Vigencia 2018
(      0.00, 100000.00,  0.00,      0.00,      0.00, '2018-01-01', '2018-12-31'),
(100000.01, 200000.00, 15.00,      0.00, 100000.00, '2018-01-01', '2018-12-31'),
(200000.01, 350000.00, 20.00,  15000.00, 200000.00, '2018-01-01', '2018-12-31'),
(350000.01, 500000.00, 25.00,  45000.00, 350000.00, '2018-01-01', '2018-12-31'),
(500000.01,      NULL, 30.00,  82500.00, 500000.00, '2018-01-01', '2018-12-31'),
-- Vigencia 2017
(      0.00, 100000.00,  0.00,      0.00,      0.00, '2017-01-01', '2017-12-31'),
(100000.01, 200000.00, 15.00,      0.00, 100000.00, '2017-01-01', '2017-12-31'),
(200000.01, 350000.00, 20.00,  15000.00, 200000.00, '2017-01-01', '2017-12-31'),
(350000.01, 500000.00, 25.00,  45000.00, 350000.00, '2017-01-01', '2017-12-31'),
(500000.01,      NULL, 30.00,  82500.00, 500000.00, '2017-01-01', '2017-12-31'),
-- Vigencia 2016
(      0.00, 100000.00,  0.00,      0.00,      0.00, '2016-01-01', '2016-12-31'),
(100000.01, 200000.00, 15.00,      0.00, 100000.00, '2016-01-01', '2016-12-31'),
(200000.01, 350000.00, 20.00,  15000.00, 200000.00, '2016-01-01', '2016-12-31'),
(350000.01, 500000.00, 25.00,  45000.00, 350000.00, '2016-01-01', '2016-12-31'),
(500000.01,      NULL, 30.00,  82500.00, 500000.00, '2016-01-01', '2016-12-31'),
-- Vigencia 2015
(      0.00, 100000.00,  0.00,      0.00,      0.00, '2015-01-01', '2015-12-31'),
(100000.01, 200000.00, 15.00,      0.00, 100000.00, '2015-01-01', '2015-12-31'),
(200000.01, 350000.00, 20.00,  15000.00, 200000.00, '2015-01-01', '2015-12-31'),
(350000.01, 500000.00, 25.00,  45000.00, 350000.00, '2015-01-01', '2015-12-31'),
(500000.01,      NULL, 30.00,  82500.00, 500000.00, '2015-01-01', '2015-12-31');
GO
 
-- ============================================================
-- INSERT: NOMINA.Periodo_Nomina
-- ============================================================
INSERT INTO NOMINA.Periodo_Nomina (fecha_inicio, fecha_fin, tipo_periodo, estado) VALUES
    ('2020-01-01','2020-01-31','Mensual','Cerrado'),
    ('2020-02-01','2020-02-29','Mensual','Cerrado'),
    ('2020-03-01','2020-03-31','Mensual','Cerrado'),
    ('2020-04-01','2020-04-30','Mensual','Cerrado'),
    ('2020-05-01','2020-05-31','Mensual','Cerrado'),
    ('2020-06-01','2020-06-30','Mensual','Cerrado'),
    ('2020-07-01','2020-07-31','Mensual','Cerrado'),
    ('2020-08-01','2020-08-31','Mensual','Cerrado'),
    ('2020-09-01','2020-09-30','Mensual','Cerrado'),
    ('2020-10-01','2020-10-31','Mensual','Cerrado'),
    ('2020-11-01','2020-11-30','Mensual','Cerrado'),
    ('2020-12-01','2020-12-31','Mensual','Cerrado'),
    ('2021-01-01','2021-01-31','Mensual','Cerrado'),
    ('2021-02-01','2021-02-28','Mensual','Cerrado'),
    ('2021-03-01','2021-03-31','Mensual','Cerrado'),
    ('2021-04-01','2021-04-30','Mensual','Cerrado'),
    ('2021-05-01','2021-05-31','Mensual','Cerrado'),
    ('2021-06-01','2021-06-30','Mensual','Cerrado'),
    ('2021-07-01','2021-07-31','Mensual','Cerrado'),
    ('2021-08-01','2021-08-31','Mensual','Cerrado'),
    ('2021-09-01','2021-09-30','Mensual','Cerrado'),
    ('2021-10-01','2021-10-31','Mensual','Cerrado'),
    ('2021-11-01','2021-11-30','Mensual','Cerrado'),
    ('2021-12-01','2021-12-31','Mensual','Cerrado'),
    ('2022-01-01','2022-01-31','Mensual','Cerrado'),
    ('2022-02-01','2022-02-28','Mensual','Cerrado'),
    ('2022-03-01','2022-03-31','Mensual','Cerrado'),
    ('2022-04-01','2022-04-30','Mensual','Cerrado'),
    ('2022-05-01','2022-05-31','Mensual','Cerrado'),
    ('2022-06-01','2022-06-30','Mensual','Cerrado'),
    ('2022-07-01','2022-07-31','Mensual','Cerrado'),
    ('2022-08-01','2022-08-31','Mensual','Cerrado'),
    ('2022-09-01','2022-09-30','Mensual','Cerrado'),
    ('2022-10-01','2022-10-31','Mensual','Cerrado'),
    ('2022-11-01','2022-11-30','Mensual','Cerrado'),
    ('2022-12-01','2022-12-31','Mensual','Cerrado'),
    ('2023-01-01','2023-01-31','Mensual','Cerrado'),
    ('2023-02-01','2023-02-28','Mensual','Cerrado'),
    ('2023-03-01','2023-03-31','Mensual','Cerrado'),
    ('2023-04-01','2023-04-30','Mensual','Cerrado'),
    ('2023-05-01','2023-05-31','Mensual','Cerrado'),
    ('2023-06-01','2023-06-30','Mensual','Cerrado'),
    ('2023-07-01','2023-07-31','Mensual','Cerrado'),
    ('2023-08-01','2023-08-31','Mensual','Cerrado'),
    ('2023-09-01','2023-09-30','Mensual','Cerrado'),
    ('2023-10-01','2023-10-31','Mensual','Cerrado'),
    ('2023-11-01','2023-11-30','Mensual','Cerrado'),
    ('2023-12-01','2023-12-31','Mensual','Cerrado'),
    ('2024-01-01','2024-01-31','Mensual','Calculado'),
    ('2024-02-01','2024-02-29','Mensual','Abierto');
GO
 
-- ============================================================
-- INSERT: NOMINA.Nomina
-- ============================================================
INSERT INTO NOMINA.Nomina (id_empleado, id_periodo, id_cargo, id_autoriza, id_elabora, total_percepciones, total_deducciones, salario_neto, fecha_elaboracion) VALUES
    ( 3,  1,  3, 1, 2, 30500.00,  3392.50, 27107.50, '2020-01-31'),
    ( 4,  2,  4, 1, 2, 14500.00,  2421.50, 12078.50, '2020-02-29'),
    ( 5,  3,  5, 1, 2, 28500.00,  3192.50, 25307.50, '2020-03-31'),
    ( 6,  4,  8, 1, 2, 15500.00,  2461.50, 13038.50, '2020-04-30'),
    ( 7,  5,  7, 1, 2, 22500.00,  2852.50, 19647.50, '2020-05-31'),
    ( 8,  6,  8, 1, 2, 15000.00,  2430.50, 12569.50, '2020-06-30'),
    ( 9,  7,  9, 1, 2, 13500.00,  2362.50, 11137.50, '2020-07-31'),
    (10,  8, 10, 1, 2, 33000.00,  3762.50, 29237.50, '2020-08-31'),
    (11,  9, 11, 1, 2, 16500.00,  2612.50, 13887.50, '2020-09-30'),
    (12, 10, 12, 1, 2, 24500.00,  3012.50, 21487.50, '2020-10-31'),
    (13, 11, 13, 1, 2, 26500.00,  3162.50, 23337.50, '2020-11-30'),
    (14, 12, 14, 1, 2, 13000.00,  2360.50, 10639.50, '2020-12-31'),
    (15, 13, 15, 1, 2, 11500.00,  2305.00,  9195.00, '2021-01-31'),
    (16, 14,  6, 1, 2, 25500.00,  3112.50, 22387.50, '2021-02-28'),
    (17, 15, 17, 1, 2, 15500.00,  2461.50, 13038.50, '2021-03-31'),
    (18, 16, 18, 1, 2, 21500.00,  2812.50, 18687.50, '2021-04-30'),
    (19, 17, 19, 1, 2, 29500.00,  3292.50, 26207.50, '2021-05-31'),
    (20, 18, 20, 1, 2, 23500.00,  2962.50, 20537.50, '2021-06-30'),
    (21, 19, 21, 1, 2, 18500.00,  2712.50, 15787.50, '2021-07-31'),
    (22, 20, 22, 1, 2, 33500.00,  3812.50, 29687.50, '2021-08-31'),
    (23, 21, 23, 1, 2, 14000.00,  2380.00, 11620.00, '2021-09-30'),
    (24, 22, 24, 1, 2, 10500.00,  2235.00,  8265.00, '2021-10-31'),
    (25, 23,  1, 1, 2, 61000.00,  6562.50, 54437.50, '2021-11-30'),
    (26, 24, 26, 1, 2, 36500.00,  4012.50, 32487.50, '2021-12-31'),
    (27, 25, 27, 1, 2, 17500.00,  2662.50, 14837.50, '2022-01-31'),
    (28, 26, 28, 1, 2, 12500.00,  2337.50, 10162.50, '2022-02-28'),
    (29, 27, 29, 1, 2, 11800.00,  2326.00,  9474.00, '2022-03-31'),
    (30, 28, 30, 1, 2, 20500.00,  2785.00, 17715.00, '2022-04-30'),
    (31, 29, 31, 1, 2, 31500.00,  3562.50, 27937.50, '2022-05-31'),
    (32, 30, 32, 1, 2, 27500.00,  3162.50, 24337.50, '2022-06-30'),
    (33, 31, 33, 1, 2, 34500.00,  3862.50, 30637.50, '2022-07-31'),
    (34, 32, 34, 1, 2, 17000.00,  2645.00, 14355.00, '2022-08-31'),
    (35, 33, 35, 1, 2, 33000.00,  3762.50, 29237.50, '2022-09-30'),
    (36, 34, 36, 1, 2, 19000.00,  2730.00, 16270.00, '2022-10-31'),
    (37, 35, 37, 1, 2, 42500.00,  4612.50, 37887.50, '2022-11-30'),
    (38, 36, 38, 1, 2, 14800.00,  2416.00, 12384.00, '2022-12-31'),
    (39, 37, 39, 1, 2, 11000.00,  2285.00,  8715.00, '2023-01-31'),
    (40, 38, 40, 1, 2, 28000.00,  3190.00, 24810.00, '2023-02-28'),
    (41, 39, 41, 1, 2, 26500.00,  3062.50, 23437.50, '2023-03-31'),
    (42, 40, 42, 1, 2, 13000.00,  2360.00, 10640.00, '2023-04-30'),
    (43, 41, 43, 1, 2, 16500.00,  2612.50, 13887.50, '2023-05-31'),
    (44, 42, 44, 1, 2, 15800.00,  2506.00, 13294.00, '2023-06-30'),
    (45, 43, 45, 1, 2, 24800.00,  3016.00, 21784.00, '2023-07-31'),
    (46, 44, 46, 1, 2, 22800.00,  2846.00, 19954.00, '2023-08-31'),
    (47, 45, 47, 1, 2, 35500.00,  3962.50, 31537.50, '2023-09-30'),
    (48, 46, 48, 1, 2, 48500.00,  5212.50, 43287.50, '2023-10-31'),
    (49, 47, 49, 1, 2, 31000.00,  3535.00, 27465.00, '2023-11-30'),
    (50, 48, 50, 1, 2, 21500.00,  2812.50, 18687.50, '2023-12-31'),
    ( 3, 49,  3, 1, 2, 30500.00,  3392.50, 27107.50, '2024-01-31'),
    ( 4, 50,  4, 2, 5, 14500.00,  2421.50, 12078.50, '2024-02-29');
GO
 
-- ============================================================
-- INSERT: NOMINA.Percepcion
-- ============================================================
INSERT INTO NOMINA.Percepcion (id_nomina, id_categoria_percep, monto, aplica_impuesto, descripcion) VALUES
    ( 1,  1, 30500.00, 1, 'Salario base enero 2020'),
    ( 2,  1, 14500.00, 1, 'Salario base febrero 2020'),
    ( 3,  1, 28500.00, 1, 'Salario base marzo 2020'),
    ( 4,  1, 15500.00, 1, 'Salario base abril 2020'),
    ( 5,  1, 22500.00, 1, 'Salario base mayo 2020'),
    ( 6,  1, 15000.00, 1, 'Salario base junio 2020'),
    ( 7,  1, 13500.00, 1, 'Salario base julio 2020'),
    ( 8,  1, 33000.00, 1, 'Salario base agosto 2020'),
    ( 9,  1, 16500.00, 1, 'Salario base septiembre 2020'),
    (10,  1, 24500.00, 1, 'Salario base octubre 2020'),
    (11,  1, 26500.00, 1, 'Salario base noviembre 2020'),
    (12,  1, 13000.00, 1, 'Salario base diciembre 2020'),
    (12,  9,  1083.33, 1, 'Aguinaldo proporcional diciembre 2020'),
    (13,  1, 11500.00, 1, 'Salario base enero 2021'),
    (14,  1, 25500.00, 1, 'Salario base febrero 2021'),
    (15,  1, 15500.00, 1, 'Salario base marzo 2021'),
    (16,  1, 21500.00, 1, 'Salario base abril 2021'),
    (17,  1, 29500.00, 1, 'Salario base mayo 2021'),
    (18,  1, 23500.00, 1, 'Salario base junio 2021'),
    (19,  1, 18500.00, 1, 'Salario base julio 2021'),
    (20,  1, 33500.00, 1, 'Salario base agosto 2021'),
    (21,  1, 14000.00, 1, 'Salario base septiembre 2021'),
    (22,  1, 10500.00, 1, 'Salario base octubre 2021'),
    (23,  1, 61000.00, 1, 'Salario base noviembre 2021'),
    (24,  1, 36500.00, 1, 'Salario base diciembre 2021'),
    (24,  9,  3041.67, 1, 'Aguinaldo diciembre 2021'),
    (25,  1, 17500.00, 1, 'Salario base enero 2022'),
    (26,  1, 12500.00, 1, 'Salario base febrero 2022'),
    (27,  1, 11800.00, 1, 'Salario base marzo 2022'),
    (28,  1, 20500.00, 1, 'Salario base abril 2022'),
    (29,  1, 31500.00, 1, 'Salario base mayo 2022'),
    (30,  1, 27500.00, 1, 'Salario base junio 2022'),
    (31,  1, 34500.00, 1, 'Salario base julio 2022'),
    (32,  1, 17000.00, 1, 'Salario base agosto 2022'),
    (33,  1, 33000.00, 1, 'Salario base septiembre 2022'),
    (34,  1, 19000.00, 1, 'Salario base octubre 2022'),
    (35,  1, 42500.00, 1, 'Salario base noviembre 2022'),
    (36,  1, 14800.00, 1, 'Salario base diciembre 2022'),
    (36,  9,  1233.33, 1, 'Aguinaldo diciembre 2022'),
    (37,  1, 11000.00, 1, 'Salario base enero 2023'),
    (38,  1, 28000.00, 1, 'Salario base febrero 2023'),
    (39,  1, 26500.00, 1, 'Salario base marzo 2023'),
    (40,  1, 13000.00, 1, 'Salario base abril 2023'),
    (41,  1, 16500.00, 1, 'Salario base mayo 2023'),
    (42,  1, 15800.00, 1, 'Salario base junio 2023'),
    (43,  1, 24800.00, 1, 'Salario base julio 2023'),
    (44,  1, 22800.00, 1, 'Salario base agosto 2023'),
    (45,  1, 35500.00, 1, 'Salario base septiembre 2023'),
    (46,  5,  3000.00, 1, 'Bono productividad Q3 2023'),
    (47,  1, 48500.00, 1, 'Salario base octubre 2023');
GO
 
-- ============================================================
-- INSERT: NOMINA.Deduccion
-- ============================================================
INSERT INTO NOMINA.Deduccion (id_nomina, id_categoria_ded, monto, descripcion) VALUES
    ( 1,  1, 2135.00, 'INSS Laboral 7% enero 2020'),
    ( 2,  1,  945.00, 'INSS Laboral 7% febrero 2020'),
    ( 3,  1, 1995.00, 'INSS Laboral 7% marzo 2020'),
    ( 4,  1, 1085.00, 'INSS Laboral 7% abril 2020'),
    ( 5,  1, 1575.00, 'INSS Laboral 7% mayo 2020'),
    ( 6,  1, 1050.00, 'INSS Laboral 7% junio 2020'),
    ( 7,  1,  945.00, 'INSS Laboral 7% julio 2020'),
    ( 8,  1, 2310.00, 'INSS Laboral 7% agosto 2020'),
    ( 9,  1, 1155.00, 'INSS Laboral 7% septiembre 2020'),
    (10,  1, 1715.00, 'INSS Laboral 7% octubre 2020'),
    (11,  1, 1855.00, 'INSS Laboral 7% noviembre 2020'),
    (12,  1,  910.00, 'INSS Laboral 7% diciembre 2020'),
    (13,  1,  805.00, 'INSS Laboral 7% enero 2021'),
    (14,  1, 1785.00, 'INSS Laboral 7% febrero 2021'),
    (15,  1, 1085.00, 'INSS Laboral 7% marzo 2021'),
    (16,  1, 1505.00, 'INSS Laboral 7% abril 2021'),
    (17,  1, 2065.00, 'INSS Laboral 7% mayo 2021'),
    (18,  1, 1645.00, 'INSS Laboral 7% junio 2021'),
    (19,  1, 1295.00, 'INSS Laboral 7% julio 2021'),
    (20,  1, 2345.00, 'INSS Laboral 7% agosto 2021'),
    (21,  1,  980.00, 'INSS Laboral 7% septiembre 2021'),
    (22,  1,  735.00, 'INSS Laboral 7% octubre 2021'),
    (23,  1, 4270.00, 'INSS Laboral 7% noviembre 2021'),
    (24,  2, 1257.50, 'IR Renta diciembre 2021'),
    (25,  1, 1225.00, 'INSS Laboral 7% enero 2022'),
    (26,  1,  875.00, 'INSS Laboral 7% febrero 2022'),
    (27,  1,  826.00, 'INSS Laboral 7% marzo 2022'),
    (28,  1, 1435.00, 'INSS Laboral 7% abril 2022'),
    (29,  1, 2205.00, 'INSS Laboral 7% mayo 2022'),
    (30,  1, 1925.00, 'INSS Laboral 7% junio 2022'),
    (31,  1, 2415.00, 'INSS Laboral 7% julio 2022'),
    (32,  1, 1190.00, 'INSS Laboral 7% agosto 2022'),
    (33,  2, 1400.00, 'IR Renta septiembre 2022'),
    (34,  1, 1330.00, 'INSS Laboral 7% octubre 2022'),
    (35,  1, 2975.00, 'INSS Laboral 7% noviembre 2022'),
    (36,  1, 1036.00, 'INSS Laboral 7% diciembre 2022'),
    (37,  1,  770.00, 'INSS Laboral 7% enero 2023'),
    (38,  1, 1960.00, 'INSS Laboral 7% febrero 2023'),
    (39,  1, 1855.00, 'INSS Laboral 7% marzo 2023'),
    (40,  1,  910.00, 'INSS Laboral 7% abril 2023'),
    (41,  4,  825.00, 'Anticipo de salario mayo 2023'),
    (42,  1, 1106.00, 'INSS Laboral 7% junio 2023'),
    (43,  1, 1736.00, 'INSS Laboral 7% julio 2023'),
    (44,  1, 1596.00, 'INSS Laboral 7% agosto 2023'),
    (45,  1, 2485.00, 'INSS Laboral 7% septiembre 2023'),
    (46,  2, 1500.00, 'IR Renta octubre 2023'),
    (47,  1, 3395.00, 'INSS Laboral 7% noviembre 2023'),
    (48,  1, 2940.00, 'INSS Laboral 7% nomina 47'),
    (49,  1, 2170.00, 'INSS Laboral 7% nomina 48'),
    (50,  4, 1505.00, 'Anticipo de salario nomina 50');
GO
 
-- ============================================================
-- INSERT: OPERACIONES.Incidencia
-- ============================================================
INSERT INTO OPERACIONES.Incidencia (id_empleado, id_periodo, id_tipo_incidencia, fecha_incidencia, cantidad, monto, descripcion) VALUES
    ( 3,  1,  1, '2020-01-10', 2.00,   636.46, 'Horas extra diurnas enero'),
    ( 4,  2,  4, '2020-02-05', 1.00,   483.33, 'Ausencia injustificada'),
    ( 5,  3,  3, '2020-03-31', 1.00,  2000.00, 'Bono cierre trimestral'),
    ( 6,  4,  1, '2020-04-18', 3.00,   775.00, 'Horas extra diurnas sabado'),
    ( 7,  5,  2, '2020-05-22', 4.00,  1500.00, 'Horas extra nocturnas'),
    ( 8,  6,  6, '2020-06-01', 5.00,     0.00, 'Vacaciones programadas'),
    ( 9,  7,  9, '2020-07-15', 1.00,   450.00, 'Permiso sin goce medico'),
    (10,  8,  5, '2020-08-03', 3.00,     0.00, 'Incapacidad INSS 3 dias'),
    ( 3,  9,  4, '2020-09-12', 1.00,  1016.67, 'Ausencia injustificada'),
    ( 4,  9, 10, '2020-09-20', 2.00,   193.33, 'Tardanza x2'),
    (11, 10,  1, '2020-10-07', 3.00,   773.44, 'Horas extra diurnas octubre'),
    (12, 11,  3, '2020-11-30', 1.00,  1800.00, 'Bono fin de periodo'),
    (13, 12,  9, '2020-12-18', 2.00,  1766.67, 'Permiso sin goce x2 dias'),
    (14, 13,  4, '2021-01-09', 1.00,   433.33, 'Ausencia primer semana'),
    (15, 14,  6, '2021-02-12', 10.00,    0.00, 'Vacaciones anuales aprobadas'),
    (16, 15,  2, '2021-03-05', 6.00,  2550.00, 'Horas extra nocturnas sabado'),
    (17, 16,  1, '2021-04-22', 2.00,   516.67, 'Horas extra diurnas'),
    (18, 17,  5, '2021-05-14', 5.00,     0.00, 'Incapacidad INSS 5 dias'),
    (19, 18,  3, '2021-06-30', 1.00,  2500.00, 'Bono semestral'),
    (20, 19, 10, '2021-07-09', 3.00,  1117.67, 'Tardanza reiterada'),
    (21, 20,  1, '2021-08-18', 4.00,  1233.33, 'Horas extra diurnas'),
    (22, 21,  4, '2021-09-03', 1.00,  1116.67, 'Ausencia sin justificar'),
    (23, 22,  6, '2021-10-11', 5.00,     0.00, 'Vacaciones programadas'),
    (24, 23,  3, '2021-11-30', 1.00,  3050.00, 'Bono anual noviembre'),
    (25, 24,  2, '2021-12-27', 3.00,  3050.00, 'Horas extra nocturnas navidad'),
    (26, 25,  9, '2022-01-17', 1.00,   583.33, 'Permiso sin goce'),
    (27, 26,  4, '2022-02-08', 2.00,  1216.67, 'Ausencia x2 dias'),
    (28, 27,  1, '2022-03-15', 5.00,   983.33, 'Horas extra diurnas'),
    (29, 28,  5, '2022-04-04', 2.00,     0.00, 'Incapacidad INSS'),
    (30, 29,  3, '2022-05-31', 1.00,  1708.33, 'Bono cierre mayo'),
    (31, 30, 10, '2022-06-14', 1.00,  1050.00, 'Tardanza prolongada'),
    (32, 31,  6, '2022-07-18', 15.00,    0.00, 'Vacaciones anuales'),
    (33, 32,  2, '2022-08-25', 8.00,  4533.33, 'Horas extra nocturnas'),
    (34, 33,  4, '2022-09-06', 1.00,   633.33, 'Ausencia sin justificacion'),
    (35, 34,  1, '2022-10-19', 3.00,  1650.00, 'Horas extra diurnas'),
    (36, 35,  9, '2022-11-07', 2.00,  2833.33, 'Permiso sin goce x2'),
    (37, 36,  3, '2022-12-31', 1.00,  1233.33, 'Bono fin de año'),
    (38, 37,  4, '2023-01-23', 1.00,   366.67, 'Ausencia inicio año'),
    (39, 38,  6, '2023-02-06', 5.00,     0.00, 'Vacaciones cortas'),
    (40, 39, 10, '2023-03-29', 4.00,  1733.33, 'Tardanzas acumuladas'),
    (41, 40,  1, '2023-04-11', 3.00,   825.00, 'Horas extra diurnas'),
    (42, 41,  5, '2023-05-02', 4.00,     0.00, 'Incapacidad INSS 4 dias'),
    (43, 42,  2, '2023-06-20', 5.00,  2066.67, 'Horas extra nocturnas'),
    (44, 43,  4, '2023-07-13', 1.00,   760.00, 'Ausencia injustificada'),
    (45, 44,  3, '2023-08-31', 1.00,  2066.67, 'Bono trimestral agosto'),
    (46, 45,  6, '2023-09-15', 10.00,    0.00, 'Vacaciones anuales'),
    (47, 46,  1, '2023-10-04', 2.00,  2383.33, 'Horas extra diurnas'),
    (48, 47,  9, '2023-11-22', 1.00,  1183.33, 'Permiso sin goce'),
    (49, 48,  4, '2023-12-05', 1.00,  1033.33, 'Ausencia diciembre'),
    (50, 49,  2, '2024-01-31', 3.00,  1525.00, 'Horas extra nocturnas cierre');
GO
 
-- ============================================================
-- INSERT: OPERACIONES.Prestacion
-- ============================================================
INSERT INTO OPERACIONES.Prestacion (id_nomina, id_tipo_prestacion, monto) VALUES
    ( 1,  1, 2541.67),
    ( 2,  2, 1208.33),
    ( 3,  1, 2375.00),
    ( 4,  2, 1291.67),
    ( 5,  1, 1875.00),
    ( 6,  2, 1250.00),
    ( 7,  1, 1125.00),
    ( 8,  1, 2750.00),
    ( 9,  2, 1375.00),
    (10,  1, 2041.67),
    (11,  2, 2208.33),
    (12,  1, 1083.33),
    (13,  2,  958.33),
    (14,  1, 2125.00),
    (15,  2, 1291.67),
    (16,  1, 1791.67),
    (17,  2, 2458.33),
    (18,  1, 1958.33),
    (19,  2, 1541.67),
    (20,  1, 2791.67),
    (21,  2, 1166.67),
    (22,  1,  875.00),
    (23,  2, 5083.33),
    (24,  1, 3041.67),
    (25,  2, 1458.33),
    (26,  1, 1041.67),
    (27,  2,  983.33),
    (28,  1, 1708.33),
    (29,  2, 2625.00),
    (30,  1, 2291.67),
    (31,  2, 2875.00),
    (32,  1, 1416.67),
    (33,  2, 2750.00),
    (34,  1, 1583.33),
    (35,  2, 3541.67),
    (36,  1, 1233.33),
    (37,  2,  916.67),
    (38,  1, 2333.33),
    (39,  2, 2208.33),
    (40,  1, 1083.33),
    (41,  2, 1375.00),
    (42,  1, 1316.67),
    (43,  2, 2066.67),
    (44,  1, 1900.00),
    (45,  2, 2958.33),
    (46,  1, 4041.67),
    (47,  2, 2583.33),
    (48,  1, 1791.67),
    (49,  2, 2583.33),
    (50,  1, 1208.33);
GO
 
-- ============================================================
-- INSERT: SEGURIDAD.Permiso
-- ============================================================
INSERT INTO SEGURIDAD.Permiso (nombre, descripcion) VALUES
    ('RRHH.Empleado.Ver',               'Consultar informacion de empleados'),
    ('RRHH.Empleado.Crear',             'Crear nuevos empleados en el sistema'),
    ('RRHH.Empleado.Editar',            'Modificar datos de empleados existentes'),
    ('RRHH.Empleado.Eliminar',          'Desactivar empleados del sistema'),
    ('RRHH.Cargo.Ver',                  'Consultar catalogo de cargos'),
    ('RRHH.Cargo.Editar',               'Crear y modificar cargos del sistema'),
    ('NOMINA.Periodo.Abrir',            'Abrir nuevos periodos de nomina'),
    ('NOMINA.Periodo.Cerrar',           'Cerrar periodos de nomina calculados'),
    ('NOMINA.Nomina.Elaborar',          'Elaborar nominas del periodo activo'),
    ('NOMINA.Nomina.Autorizar',         'Autorizar nominas en estado Calculado'),
    ('NOMINA.Nomina.Ver',               'Consultar nominas elaboradas'),
    ('NOMINA.Percepcion.Registrar',     'Registrar percepciones en nominas'),
    ('NOMINA.Deduccion.Registrar',      'Registrar deducciones en nominas'),
    ('CATALOGOS.Percepcion.Ver',        'Ver categorias de percepciones'),
    ('CATALOGOS.Percepcion.Editar',     'Crear y modificar categorias de percepcion'),
    ('CATALOGOS.Deduccion.Ver',         'Ver categorias de deducciones'),
    ('CATALOGOS.Deduccion.Editar',      'Crear y modificar categorias de deduccion'),
    ('CATALOGOS.Incidencia.Ver',        'Ver tipos de incidencias registradas'),
    ('CATALOGOS.Incidencia.Editar',     'Crear y modificar tipos de incidencia'),
    ('CATALOGOS.Aporte.Ver',            'Consultar tipos de aporte patronal'),
    ('CATALOGOS.Aporte.Editar',         'Crear y modificar tipos de aporte'),
    ('CATALOGOS.Prestacion.Ver',        'Consultar tipos de prestaciones'),
    ('CATALOGOS.Prestacion.Editar',     'Crear y modificar tipos de prestacion'),
    ('FISCAL.TramoIR.Ver',              'Consultar tramos IR vigentes'),
    ('FISCAL.TramoIR.Editar',           'Modificar tramos del IR'),
    ('FISCAL.AportePatronal.Ver',       'Consultar aportes patronales por nomina'),
    ('FISCAL.AportePatronal.Registrar', 'Registrar aportes patronales en nominas'),
    ('OPERACIONES.Incidencia.Ver',      'Ver incidencias de empleados'),
    ('OPERACIONES.Incidencia.Registrar','Registrar incidencias por periodo'),
    ('OPERACIONES.Prestacion.Ver',      'Consultar prestaciones calculadas'),
    ('OPERACIONES.Prestacion.Registrar','Registrar prestaciones en nominas'),
    ('SEGURIDAD.Usuarios.Ver',          'Consultar usuarios del sistema'),
    ('SEGURIDAD.Usuarios.Crear',        'Crear nuevos usuarios del sistema'),
    ('SEGURIDAD.Usuarios.Desactivar',   'Desactivar usuarios del sistema'),
    ('SEGURIDAD.Roles.Ver',             'Consultar roles del sistema'),
    ('SEGURIDAD.Roles.Editar',          'Crear y modificar roles del sistema'),
    ('SEGURIDAD.Permisos.Asignar',      'Asignar permisos a roles del sistema'),
    ('AUDITORIA.Ver',                   'Consultar log de auditoria del sistema'),
    ('AUDITORIA.Exportar',              'Exportar log de auditoria a Excel o PDF'),
    ('REPORTES.Nomina.Ver',             'Ver reportes de nomina del periodo'),
    ('REPORTES.Nomina.Exportar',        'Exportar reportes de nomina a Excel o PDF'),
    ('REPORTES.RRHH.Ver',               'Ver reportes del modulo de RRHH'),
    ('REPORTES.Fiscal.Ver',             'Ver reportes fiscales del sistema'),
    ('REPORTES.Fiscal.Exportar',        'Exportar reportes fiscales a formato requerido'),
    ('REPORTES.Incidencias.Ver',        'Ver reporte de incidencias del periodo'),
    ('REPORTES.Prestaciones.Ver',       'Consultar reporte de prestaciones calculadas'),
    ('SISTEMA.Config.Ver',              'Ver parametros de configuracion del sistema'),
    ('SISTEMA.Config.Editar',           'Modificar parametros generales del sistema'),
    ('SISTEMA.Backup.Ejecutar',         'Ejecutar copias de seguridad de la base de datos'),
    ('SISTEMA.Logs.Purgar',             'Depurar registros de auditoria antiguos');
GO
 
-- ============================================================
-- INSERT: SEGURIDAD.Rol
-- ============================================================
INSERT INTO SEGURIDAD.Rol (nombre_rol, descripcion) VALUES
    ('Administrador',           'Acceso total e irrestricto al sistema'),
    ('RRHH Completo',           'Gestion completa del modulo de personal'),
    ('RRHH Solo Lectura',       'Consulta de empleados y cargos sin edicion'),
    ('Elaborador Nomina',       'Elaboracion de nominas del periodo'),
    ('Autorizador Nomina',      'Autorizacion de nominas calculadas'),
    ('Auditor Interno',         'Solo lectura en todos los modulos'),
    ('Supervisor Operaciones',  'Aprobacion y seguimiento de incidencias'),
    ('Contador',                'Acceso a modulos fiscal y reportes financieros'),
    ('Gerente',                 'Visualizacion ejecutiva de indicadores y reportes'),
    ('Soporte Tecnico',         'Acceso tecnico limitado para soporte del sistema'),
    ('Solo Lectura General',    'Permiso de consulta minima en modulos clave'),
    ('Temporal Auditor',        'Acceso temporal para auditores externos'),
    ('Coordinador Nomina',      'Apoyo en elaboracion y revision de nominas'),
    ('Jefe RRHH',               'Gestion estrategica del modulo de personal'),
    ('Analista Fiscal',         'Analisis y reporte de obligaciones fiscales'),
    ('Supervisor RRHH',         'Supervision de procesos de gestion de personal'),
    ('Reportes Nomina',         'Acceso exclusivo a reportes del modulo nomina'),
    ('Reportes RRHH',           'Acceso a reportes estadisticos de personal'),
    ('Reportes Fiscales',       'Acceso a reportes fiscales y tributarios'),
    ('Operador Catalogos',      'Gestion y mantenimiento de catalogos del sistema'),
    ('Admin Seguridad',         'Gestion de usuarios, roles y permisos del sistema'),
    ('Visor Prestaciones',      'Consulta de prestaciones calculadas por nomina'),
    ('Visor Incidencias',       'Consulta de incidencias registradas por periodo'),
    ('Registrador Incidencias', 'Registro de incidencias en periodos activos'),
    ('Registrador Percepciones','Ingreso de percepciones en nominas del periodo'),
    ('Registrador Deducciones', 'Ingreso de deducciones en nominas del periodo'),
    ('Aprobador Periodos',      'Apertura y cierre de periodos de nomina'),
    ('Visor Aportes',           'Consulta de aportes patronales calculados'),
    ('Registrador Aportes',     'Registro de aportes patronales en el sistema'),
    ('Analista RRHH',           'Analisis de indicadores y datos del personal'),
    ('Admin Config',            'Administracion de configuracion y parametros'),
    ('Operador Backup',         'Ejecucion y monitoreo de copias de seguridad'),
    ('Visor Auditoria',         'Acceso de solo lectura al log de auditoria'),
    ('Exportador Reportes',     'Exportacion de reportes del sistema a distintos formatos'),
    ('Gerente Financiero',      'Acceso completo a modulos fiscales y de nomina'),
    ('Jefe Nomina',             'Acceso completo al modulo de nomina'),
    ('Director RRHH',           'Acceso estrategico al modulo de personal y nomina'),
    ('Consultores Externos',    'Acceso temporal y acotado para consultores de proyecto'),
    ('Empleado Autoservicio',   'Acceso a modulo de autoservicio del empleado'),
    ('Visor Tramos IR',         'Consulta de tabla de tramos del IR vigentes'),
    ('Asistente Contable',      'Apoyo en tareas contables y revision de nomina'),
    ('Coordinador RRHH',        'Apoyo a jefatura de RRHH en gestion diaria'),
    ('Analista Nomina',         'Analisis y verificacion de nominas procesadas'),
    ('Gestor Prestaciones',     'Registro y seguimiento de prestaciones laborales'),
    ('Supervisor Fiscal',       'Supervision de cumplimiento fiscal y tributario'),
    ('Administrador Nomina',    'Administracion integral del modulo de nomina'),
    ('Inspector Calidad Datos', 'Revision de calidad e integridad de datos del sistema'),
    ('Soporte Nivel 2',         'Soporte tecnico avanzado con acceso ampliado'),
    ('Soporte Nivel 1',         'Soporte tecnico basico con acceso minimo al sistema'),
    ('Visitante',               'Acceso de solo lectura minimo para demostraciones');
GO
 
-- ============================================================
-- INSERT: SEGURIDAD.Rol_Permiso
-- ============================================================
INSERT INTO SEGURIDAD.Rol_Permiso (id_rol, id_permiso) VALUES
-- Administrador (id_rol=1): 10 permisos
    (1,  1), (1,  2), (1,  3), (1,  4), (1,  9),
    (1, 10), (1, 24), (1, 32), (1, 38), (1, 49),
-- RRHH Completo (id_rol=2): 6 permisos
    (2,  1), (2,  2), (2,  3), (2,  4), (2,  5), (2,  6),
-- Elaborador Nomina (id_rol=4): 5 permisos
    (4,  9), (4, 11), (4, 12), (4, 13), (4, 28),
-- Autorizador Nomina (id_rol=5): 3 permisos
    (5, 10), (5, 11), (5, 40),
-- Auditor Interno (id_rol=6): 5 permisos
    (6,  1), (6, 11), (6, 24), (6, 38), (6, 46),
-- Contador (id_rol=8): 5 permisos
    (8, 24), (8, 25), (8, 26), (8, 43), (8, 44),
-- Gerente (id_rol=9): 4 permisos
    (9, 11), (9, 40), (9, 41), (9, 42),
-- Solo Lectura General (id_rol=11): 4 permisos
    (11,  1), (11,  5), (11, 11), (11, 28),
-- Admin Seguridad (id_rol=21): 4 permisos
    (21, 32), (21, 33), (21, 34), (21, 37),
-- Temporal Auditor (id_rol=12): 3 permisos
    (12, 38), (12, 40), (12, 43);
GO
 
-- ============================================================
-- INSERT: SEGURIDAD.Usuario
-- ============================================================
INSERT INTO SEGURIDAD.Usuario (id_empleado, username, password_hash) VALUES
    ( 1, 'cmartinez',   '5E884898DA28047151D0E56F8DC629273603D0D6AABBDD62A11EF721D1542D8'),
    ( 2, 'agutierrez',  '5E884898DA28047151D0E56F8DC629273603D0D6AABBDD62A11EF721D1542D9'),
    ( 3, 'lhernandez',  '5E884898DA28047151D0E56F8DC629273603D0D6AABBDD62A11EF721D1542DA'),
    ( 4, 'mperez',      '5E884898DA28047151D0E56F8DC629273603D0D6AABBDD62A11EF721D1542DB'),
    ( 5, 'rsanchez',    '5E884898DA28047151D0E56F8DC629273603D0D6AABBDD62A11EF721D1542DC'),
    ( 6, 'sramirez',    '5E884898DA28047151D0E56F8DC629273603D0D6AABBDD62A11EF721D1542DD'),
    ( 7, 'jmendoza',    '5E884898DA28047151D0E56F8DC629273603D0D6AABBDD62A11EF721D1542DE'),
    ( 8, 'lvargas',     '5E884898DA28047151D0E56F8DC629273603D0D6AABBDD62A11EF721D1542DF'),
    ( 9, 'mtorres',     '5E884898DA28047151D0E56F8DC629273603D0D6AABBDD62A11EF721D1542E0'),
    (10, 'cflores',     '5E884898DA28047151D0E56F8DC629273603D0D6AABBDD62A11EF721D1542E1'),
    (11, 'acastillo',   '5E884898DA28047151D0E56F8DC629273603D0D6AABBDD62A11EF721D1542E2'),
    (12, 'vmoreno',     '5E884898DA28047151D0E56F8DC629273603D0D6AABBDD62A11EF721D1542E3'),
    (13, 'hespinoza',   '5E884898DA28047151D0E56F8DC629273603D0D6AABBDD62A11EF721D1542E4'),
    (14, 'plopez',      '5E884898DA28047151D0E56F8DC629273603D0D6AABBDD62A11EF721D1542E5'),
    (15, 'raguilar',    '5E884898DA28047151D0E56F8DC629273603D0D6AABBDD62A11EF721D1542E6'),
    (16, 'dbravo',      '5E884898DA28047151D0E56F8DC629273603D0D6AABBDD62A11EF721D1542E7'),
    (17, 'orios',       '5E884898DA28047151D0E56F8DC629273603D0D6AABBDD62A11EF721D1542E8'),
    (18, 'icruz',       '5E884898DA28047151D0E56F8DC629273603D0D6AABBDD62A11EF721D1542E9'),
    (19, 'fnunez',      '5E884898DA28047151D0E56F8DC629273603D0D6AABBDD62A11EF721D1542EA'),
    (20, 'gacosta',     '5E884898DA28047151D0E56F8DC629273603D0D6AABBDD62A11EF721D1542EB'),
    (21, 'areyes',      '5E884898DA28047151D0E56F8DC629273603D0D6AABBDD62A11EF721D1542EC'),
    (22, 'mjimenez',    '5E884898DA28047151D0E56F8DC629273603D0D6AABBDD62A11EF721D1542ED'),
    (23, 'esolis',      '5E884898DA28047151D0E56F8DC629273603D0D6AABBDD62A11EF721D1542EE'),
    (24, 'amejia',      '5E884898DA28047151D0E56F8DC629273603D0D6AABBDD62A11EF721D1542EF'),
    (25, 'jvega',       '5E884898DA28047151D0E56F8DC629273603D0D6AABBDD62A11EF721D1542F0'),
    (26, 'cpadilla',    '5E884898DA28047151D0E56F8DC629273603D0D6AABBDD62A11EF721D1542F1'),
    (27, 'mzelaya',     '5E884898DA28047151D0E56F8DC629273603D0D6AABBDD62A11EF721D1542F2'),
    (28, 'nchavarria',  '5E884898DA28047151D0E56F8DC629273603D0D6AABBDD62A11EF721D1542F3'),
    (29, 'amiranda',    '5E884898DA28047151D0E56F8DC629273603D0D6AABBDD62A11EF721D1542F4'),
    (30, 'kgutierrez',  '5E884898DA28047151D0E56F8DC629273603D0D6AABBDD62A11EF721D1542F5'),
    (31, 'pcontreras',  '5E884898DA28047151D0E56F8DC629273603D0D6AABBDD62A11EF721D1542F6'),
    (32, 'lespinoza',   '5E884898DA28047151D0E56F8DC629273603D0D6AABBDD62A11EF721D1542F7'),
    (33, 'fcenteno',    '5E884898DA28047151D0E56F8DC629273603D0D6AABBDD62A11EF721D1542F8'),
    (34, 'spalma',      '5E884898DA28047151D0E56F8DC629273603D0D6AABBDD62A11EF721D1542F9'),
    (35, 'dflores',     '5E884898DA28047151D0E56F8DC629273603D0D6AABBDD62A11EF721D1542FA'),
    (36, 'bortiz',      '5E884898DA28047151D0E56F8DC629273603D0D6AABBDD62A11EF721D1542FB'),
    (37, 'szamora',     '5E884898DA28047151D0E56F8DC629273603D0D6AABBDD62A11EF721D1542FC'),
    (38, 'rlezama',     '5E884898DA28047151D0E56F8DC629273603D0D6AABBDD62A11EF721D1542FD'),
    (39, 'vcano',       '5E884898DA28047151D0E56F8DC629273603D0D6AABBDD62A11EF721D1542FE'),
    (40, 'wmendez',     '5E884898DA28047151D0E56F8DC629273603D0D6AABBDD62A11EF721D1542FF'),
    (41, 'eibarra',     '5E884898DA28047151D0E56F8DC629273603D0D6AABBDD62A11EF721D154300'),
    (42, 'ndelgado',    '5E884898DA28047151D0E56F8DC629273603D0D6AABBDD62A11EF721D154301'),
    (43, 'rmontes',     '5E884898DA28047151D0E56F8DC629273603D0D6AABBDD62A11EF721D154302'),
    (44, 'isuarez',     '5E884898DA28047151D0E56F8DC629273603D0D6AABBDD62A11EF721D154303'),
    (45, 'gmora',       '5E884898DA28047151D0E56F8DC629273603D0D6AABBDD62A11EF721D154304'),
    (46, 'yalvarez',    '5E884898DA28047151D0E56F8DC629273603D0D6AABBDD62A11EF721D154305'),
    (47, 'cjarquin',    '5E884898DA28047151D0E56F8DC629273603D0D6AABBDD62A11EF721D154306'),
    (48, 'truiz',       '5E884898DA28047151D0E56F8DC629273603D0D6AABBDD62A11EF721D154307'),
    (49, 'gmendoza2',   '5E884898DA28047151D0E56F8DC629273603D0D6AABBDD62A11EF721D154308'),
    (50, 'xpicado',     '5E884898DA28047151D0E56F8DC629273603D0D6AABBDD62A11EF721D154309');
GO
 
-- ============================================================
-- INSERT: SEGURIDAD.Usuario_Rol
-- ============================================================
INSERT INTO SEGURIDAD.Usuario_Rol (id_usuario, id_rol) VALUES
    ( 1,  1),  -- cmartinez     → Administrador
    ( 2,  2),  -- agutierrez    → RRHH Completo
    ( 3,  4),  -- lhernandez    → Elaborador Nomina
    ( 4,  4),  -- mperez        → Elaborador Nomina
    ( 5,  5),  -- rsanchez      → Autorizador Nomina
    ( 6,  4),  -- sramirez      → Elaborador Nomina
    ( 7, 10),  -- jmendoza      → Soporte Tecnico
    ( 8, 11),  -- lvargas       → Solo Lectura General
    ( 9, 11),  -- mtorres       → Solo Lectura General
    (10,  6),  -- cflores       → Auditor Interno
    (11,  3),  -- acastillo     → RRHH Solo Lectura
    (12,  3),  -- vmoreno       → RRHH Solo Lectura
    (13,  8),  -- hespinoza     → Contador
    (14,  7),  -- plopez        → Supervisor Operaciones
    (15, 11),  -- raguilar      → Solo Lectura General
    (16,  9),  -- dbravo        → Gerente
    (17,  3),  -- orios         → RRHH Solo Lectura
    (18,  4),  -- icruz         → Elaborador Nomina
    (19,  8),  -- fnunez        → Contador
    (20, 11),  -- gacosta       → Solo Lectura General
    (21,  6),  -- areyes        → Auditor Interno
    (22,  7),  -- mjimenez      → Supervisor Operaciones
    (23,  8),  -- esolis        → Contador
    (24, 11),  -- amejia        → Solo Lectura General
    (25,  1),  -- jvega         → Administrador (segundo admin)
    (26,  3),  -- cpadilla      → RRHH Solo Lectura
    (27,  4),  -- mzelaya       → Elaborador Nomina
    (28, 11),  -- nchavarria    → Solo Lectura General
    (29, 11),  -- amiranda      → Solo Lectura General
    (30,  3),  -- kgutierrez    → RRHH Solo Lectura
    (31,  9),  -- pcontreras    → Gerente
    (32,  7),  -- lespinoza     → Supervisor Operaciones
    (33,  8),  -- fcenteno      → Contador
    (34,  3),  -- spalma        → RRHH Solo Lectura
    (35, 11),  -- dflores       → Solo Lectura General
    (36,  6),  -- bortiz        → Auditor Interno
    (37, 10),  -- szamora       → Soporte Tecnico
    (38,  3),  -- rlezama       → RRHH Solo Lectura
    (39, 11),  -- vcano         → Solo Lectura General
    (40,  3),  -- wmendez       → RRHH Solo Lectura
    (41,  4),  -- eibarra       → Elaborador Nomina
    (42,  7),  -- ndelgado      → Supervisor Operaciones
    (43,  8),  -- rmontes       → Contador
    (44,  3),  -- isuarez       → RRHH Solo Lectura
    (45, 11),  -- gmora         → Solo Lectura General
    (46, 11),  -- yalvarez      → Solo Lectura General
    (47,  4),  -- cjarquin      → Elaborador Nomina
    (48, 11),  -- truiz         → Solo Lectura General
    (49,  5),  -- gmendoza2     → Autorizador Nomina
    (50,  6);  -- xpicado       → Auditor Interno
GO
 
-- ============================================================
-- INSERT: FISCAL.Aporte_Patronal
-- ============================================================
INSERT INTO FISCAL.Aporte_Patronal (id_nomina, id_tipo_aporte, monto) VALUES
    ( 1,  1,  6862.50),
    ( 2,  2,  3117.50),
    ( 3,  1,  6412.50),
    ( 4,  2,  3317.50),
    ( 5,  1,  5062.50),
    ( 6,  2,  3225.00),
    ( 7,  1,  3037.50),
    ( 8,  1,  7425.00),
    ( 9,  3,   330.00),
    (10,  1,  5512.50),
    (11,  1,  5962.50),
    (12,  2,  2795.00),
    (13,  2,  2472.50),
    (14,  1,  5737.50),
    (15,  2,  3397.50),
    (16,  1,  4837.50),
    (17,  1,  6637.50),
    (18,  1,  5287.50),
    (19,  1,  6637.50),
    (20,  1,  7537.50),
    (21,  2,  3010.00),
    (22,  2,  2257.50),
    (23,  1, 13725.00),
    (24,  3,   730.00),
    (25,  2,  3762.50),
    (26,  2,  2687.50),
    (27,  2,  2537.00),
    (28,  1,  4612.50),
    (29,  1,  7087.50),
    (30,  1,  6187.50),
    (31,  1,  7762.50),
    (32,  1,  3825.00),
    (33,  3,   660.00),
    (34,  1,  4275.00),
    (35,  1,  9562.50),
    (36,  2,  3182.00),
    (37,  2,  2365.00),
    (38,  1,  6300.00),
    (39,  1,  5962.50),
    (40,  2,  2795.00),
    (41,  1,  3712.50),
    (42,  2,  3397.00),
    (43,  1,  5580.00),
    (44,  1,  5130.00),
    (45,  1,  7987.50),
    (46,  3,   910.00),
    (47,  1,  9112.50),
    (48,  1,  6637.50),
    (49,  1,  4882.50),
    (50,  3,   430.00);
GO
 
-- ============================================================
-- INSERT: SEGURIDAD.Auditoria
-- ============================================================
INSERT INTO SEGURIDAD.Auditoria (id_usuario, tabla_afectada, accion, descripcion, ip_origen) VALUES
    ( 1, 'RRHH.Empleado',                'INSERT', 'Alta masiva de 50 empleados',                    '192.168.1.10'),
    ( 2, 'RRHH.Cargo',                   'INSERT', 'Registro de 50 cargos en el sistema',            '192.168.1.11'),
    ( 1, 'NOMINA.Periodo_Nomina',         'INSERT', 'Apertura de periodos 2020-2024',                 '192.168.1.10'),
    ( 3, 'NOMINA.Nomina',                 'INSERT', 'Elaboracion de nomina id 1 enero 2020',          '192.168.1.12'),
    ( 1, 'NOMINA.Nomina',                 'UPDATE', 'Autorizacion de nomina id 1',                    '192.168.1.10'),
    ( 2, 'RRHH.Cargo',                   'UPDATE', 'Actualizacion salario cargo Contador Senior',     '192.168.1.11'),
    ( 4, 'FISCAL.Tramo_IR',              'SELECT', 'Consulta de tramos IR vigentes 2024',            '192.168.1.13'),
    ( 1, 'SEGURIDAD.Usuario',            'INSERT', 'Creacion de 50 usuarios del sistema',            '192.168.1.10'),
    ( 5, 'OPERACIONES.Incidencia',        'INSERT', 'Registro hora extra empleado 6 abril 2020',      '192.168.1.14'),
    ( 1, 'NOMINA.Periodo_Nomina',         'UPDATE', 'Cierre de periodo agosto 2020',                  '192.168.1.10'),
    ( 2, 'RRHH.Empleado_Cargo',          'INSERT', 'Asignacion de cargo a empleado 11',              '192.168.1.11'),
    ( 3, 'NOMINA.Nomina',                 'INSERT', 'Elaboracion de nomina id 2 febrero 2020',        '192.168.1.12'),
    ( 5, 'OPERACIONES.Incidencia',        'INSERT', 'Ausencia injustificada empleado 4 febrero 2020', '192.168.1.14'),
    ( 1, 'NOMINA.Nomina',                 'UPDATE', 'Autorizacion de nomina id 2',                    '192.168.1.10'),
    ( 6, 'FISCAL.Tramo_IR',              'SELECT', 'Consulta tramos IR 2023 para auditoria',         '192.168.1.15'),
    ( 2, 'CATALOGOS.Categoria_Deduccion','INSERT', 'Alta de nueva categoria seguro mascota',          '192.168.1.11'),
    ( 3, 'NOMINA.Percepcion',             'INSERT', 'Registro percepciones nomina id 3',              '192.168.1.12'),
    ( 3, 'NOMINA.Deduccion',              'INSERT', 'Registro deducciones INSS nomina id 3',          '192.168.1.12'),
    ( 7, 'SEGURIDAD.Usuario',            'SELECT', 'Consulta de usuarios activos del sistema',       '192.168.1.16'),
    ( 1, 'NOMINA.Periodo_Nomina',         'UPDATE', 'Cierre de periodo diciembre 2020',               '192.168.1.10'),
    ( 2, 'RRHH.Empleado',                'UPDATE', 'Actualizacion telefono empleado 15',             '192.168.1.11'),
    ( 5, 'OPERACIONES.Incidencia',        'INSERT', 'Registro bono cierre trimestral empleado 5',     '192.168.1.14'),
    ( 4, 'NOMINA.Nomina',                 'INSERT', 'Elaboracion nomina id 5 mayo 2020',              '192.168.1.13'),
    ( 1, 'NOMINA.Nomina',                 'UPDATE', 'Autorizacion nominas del periodo mayo 2020',     '192.168.1.10'),
    ( 8, 'FISCAL.Aporte_Patronal',        'SELECT', 'Consulta aportes patronales Q2 2020',           '192.168.1.17'),
    ( 2, 'RRHH.Cargo',                   'UPDATE', 'Actualizacion rango salarial cargo Gerente',     '192.168.1.11'),
    ( 6, 'NOMINA.Nomina',                 'SELECT', 'Revision de nominas periodo 2021 auditoria',    '192.168.1.15'),
    ( 3, 'NOMINA.Percepcion',             'INSERT', 'Percepciones aguinaldo diciembre 2020',          '192.168.1.12'),
    ( 1, 'SEGURIDAD.Rol_Permiso',        'INSERT', 'Asignacion de permisos a rol Gerente',           '192.168.1.10'),
    ( 9, 'NOMINA.Nomina',                 'SELECT', 'Vista ejecutiva nominas periodo 2022',           '192.168.1.18'),
    ( 2, 'RRHH.Empleado',                'UPDATE', 'Actualizacion estado civil empleado 22',         '192.168.1.11'),
    ( 5, 'OPERACIONES.Incidencia',        'INSERT', 'Horas extra nocturnas empleado 7 mayo 2020',     '192.168.1.14'),
    ( 3, 'NOMINA.Nomina',                 'INSERT', 'Elaboracion nomina id 10 octubre 2020',          '192.168.1.12'),
    ( 1, 'NOMINA.Nomina',                 'UPDATE', 'Autorizacion nominas periodo octubre 2020',      '192.168.1.10'),
    ( 4, 'NOMINA.Deduccion',              'INSERT', 'Deduccion anticipo salario nomina 41',           '192.168.1.13'),
    ( 6, 'SEGURIDAD.Auditoria',          'SELECT', 'Consulta log auditoria mes de enero 2023',       '192.168.1.15'),
    ( 2, 'CATALOGOS.Tipo_Prestacion',    'INSERT', 'Alta nueva prestacion bono bienestar',           '192.168.1.11'),
    ( 8, 'FISCAL.Tramo_IR',              'UPDATE', 'Actualizacion tramos IR vigencia 2025',          '192.168.1.17'),
    ( 1, 'SEGURIDAD.Usuario',            'UPDATE', 'Desactivacion usuario temporal auditoria',       '192.168.1.10'),
    (10, 'RRHH.Empleado',                'SELECT', 'Soporte TI consulta datos empleado 33',          '192.168.1.19'),
    ( 3, 'NOMINA.Nomina',                 'INSERT', 'Elaboracion nomina id 49 enero 2024',            '192.168.1.12'),
    ( 1, 'NOMINA.Nomina',                 'UPDATE', 'Autorizacion nomina id 49 enero 2024',           '192.168.1.10'),
    ( 2, 'RRHH.Empleado_Cargo',          'INSERT', 'Alta cargo empleado 50 junio 2021',              '192.168.1.11'),
    ( 5, 'OPERACIONES.Prestacion',        'INSERT', 'Registro prestacion aguinaldo nomina 24',        '192.168.1.14'),
    ( 6, 'NOMINA.Percepcion',             'SELECT', 'Auditoria percepciones nominas 2022',            '192.168.1.15'),
    ( 8, 'FISCAL.Aporte_Patronal',        'INSERT', 'Registro aportes INATEC nominas 9 y 24',        '192.168.1.17'),
    ( 4, 'NOMINA.Nomina',                 'INSERT', 'Elaboracion nomina id 50 febrero 2024',          '192.168.1.13'),
    ( 2, 'RRHH.Empleado',                'UPDATE', 'Actualizacion correo electronico empleado 3',    '192.168.1.11'),
    ( 1, 'SEGURIDAD.Rol_Permiso',        'INSERT', 'Asignacion permisos adicionales rol Contador',   '192.168.1.10'),
    ( 9, 'REPORTES.Nomina',              'SELECT', 'Consulta ejecutiva reporte nomina anual 2023',   '192.168.1.18');
GO
 
 
-- ============================================================
-- SECCIÓN CRUD 1: EMPLEADO
-- ============================================================
 
-- CREAR — Insertar un nuevo empleado
INSERT INTO RRHH.Empleado
    (primer_nombre, segundo_nombre, primer_apellido, segundo_apellido,
     sexo, fecha_nacimiento, ciudad, estado_civil,
     numero_inss, cedula, telefono, correo)
VALUES
    ('Pedro', 'Luis', 'Gonzalez', 'Mendez',
     'M', '1990-05-21', 'Managua', 'Soltero',
     'INSS999', '001-210590-9999Z', '88099999', 'pgonzalez@empresa.com');
GO
 
-- CONSULTAR — Ver empleados activos con su cargo actual
SELECT
    E.id_empleado,
    E.primer_nombre + ' ' + E.primer_apellido       AS nombre_completo,
    E.cedula,
    E.ciudad,
    E.estado_civil,
    C.nombre_cargo,
    EC.salario_asignado,
    EC.fecha_inicio                                  AS desde
FROM RRHH.Empleado       AS E
JOIN RRHH.Empleado_Cargo AS EC ON E.id_empleado = EC.id_empleado
JOIN RRHH.Cargo          AS C  ON EC.id_cargo   = C.id_cargo
WHERE E.is_active  = 1
  AND EC.is_active = 1
  AND EC.fecha_fin IS NULL
ORDER BY E.primer_apellido;
GO
 
-- ACTUALIZAR — Actualizar telefono y correo de un empleado
UPDATE RRHH.Empleado
SET    telefono   = '88799001',
       correo     = 'pgonzalez_nuevo@empresa.com',
       updated_at = GETDATE()
WHERE  cedula = '001-210590-9999Z';
GO
 
-- ELIMINAR — Desactivar empleado sin borrar fisicamente
UPDATE RRHH.Empleado
SET    is_active  = 0,
       deleted_at = GETDATE(),
       updated_at = GETDATE()
WHERE  cedula = '001-210590-9999Z';
GO
 
-- ============================================================
-- SECCIÓN CRUD 2: NOMINA
-- ============================================================
 
-- CREAR — Elaborar una nomina para un nuevo periodo
INSERT INTO NOMINA.Nomina
    (id_empleado, id_periodo, id_cargo, id_autoriza, id_elabora,
     total_percepciones, total_deducciones, salario_neto, fecha_elaboracion)
VALUES
    (1, 50, 1, 2, 5, 30500.00, 3392.50, 27107.50, GETDATE());
GO
 
-- CONSULTAR — Detalle de nominas con percepciones y deducciones por periodo
SELECT
    N.id_nomina,
    E.primer_nombre + ' ' + E.primer_apellido AS empleado,
    P.fecha_inicio,
    P.fecha_fin,
    N.total_percepciones,
    N.total_deducciones,
    N.salario_neto,
    N.fecha_elaboracion,
    N.fecha_autorizacion
FROM NOMINA.Nomina          AS N
JOIN RRHH.Empleado          AS E ON N.id_empleado = E.id_empleado
JOIN NOMINA.Periodo_Nomina  AS P ON N.id_periodo  = P.id_periodo
ORDER BY P.fecha_inicio DESC, E.primer_apellido;
GO
 
-- ACTUALIZAR — Autorizar una nomina (registra fecha de autorizacion)
UPDATE NOMINA.Nomina
SET    fecha_autorizacion = GETDATE(),
       updated_at         = GETDATE()
WHERE  id_nomina = 1
  AND  fecha_autorizacion IS NULL;
GO
 
-- ELIMINAR — Desactivar nomina anulada
UPDATE NOMINA.Nomina
SET    is_active  = 0,
       deleted_at = GETDATE(),
       updated_at = GETDATE()
WHERE  id_nomina = 50
  AND  is_active = 1;
GO
 
-- ============================================================
-- SECCIÓN CRUD 3: CARGO
-- ============================================================
 
-- CREAR — Agregar un nuevo cargo
INSERT INTO RRHH.Cargo
    (nombre_cargo, descripcion_cargo, salario_base, salario_minimo, salario_maximo, salario_extraordinario)
VALUES
    ('Director de Innovacion', 'Estrategia y ejecucion de innovacion empresarial',
     55000.00, 45000.00, 75000.00, 4500.00);
GO
 
-- CONSULTAR — Listar cargos activos con rango salarial
SELECT
    id_cargo,
    nombre_cargo,
    descripcion_cargo,
    salario_base,
    salario_minimo,
    salario_maximo,
    salario_extraordinario
FROM RRHH.Cargo
WHERE is_active = 1
ORDER BY salario_base DESC;
GO
 
-- ACTUALIZAR — Ajustar rango salarial de un cargo existente
UPDATE RRHH.Cargo
SET    salario_base   = 57000.00,
       salario_maximo = 78000.00,
       updated_at     = GETDATE()
WHERE  nombre_cargo = 'Director de Innovacion';
GO
 
-- ELIMINAR — Desactivar cargo obsoleto
UPDATE RRHH.Cargo
SET    is_active  = 0,
       deleted_at = GETDATE(),
       updated_at = GETDATE()
WHERE  nombre_cargo = 'Director de Innovacion';
GO
 
-- ============================================================
-- SECCIÓN CRUD 4: INCIDENCIA
-- ============================================================
 
-- CREAR — Registrar una nueva incidencia
INSERT INTO OPERACIONES.Incidencia
    (id_empleado, id_periodo, id_tipo_incidencia, fecha_incidencia, cantidad, monto, descripcion)
VALUES
    (3, 49, 1, '2024-01-15', 4.00, 1016.67, 'Horas extra diurnas por cierre de mes');
GO
 
-- CONSULTAR — Ver incidencias por empleado y periodo con tipo
SELECT
    I.id_incidencia,
    E.primer_nombre + ' ' + E.primer_apellido AS empleado,
    P.fecha_inicio,
    P.fecha_fin,
    TI.nombre_tipo,
    TI.categoria,
    I.fecha_incidencia,
    I.cantidad,
    I.monto,
    I.descripcion
FROM OPERACIONES.Incidencia      AS I
JOIN RRHH.Empleado               AS E  ON I.id_empleado        = E.id_empleado
JOIN NOMINA.Periodo_Nomina        AS P  ON I.id_periodo         = P.id_periodo
JOIN CATALOGOS.Tipo_Incidencia    AS TI ON I.id_tipo_incidencia = TI.id_tipo_incidencia
WHERE I.is_active = 1
ORDER BY I.fecha_incidencia DESC;
GO
 
-- ACTUALIZAR — Corregir el monto de una incidencia registrada
UPDATE OPERACIONES.Incidencia
SET    monto      = 1200.00,
       updated_at = GETDATE()
WHERE  id_incidencia = 51;
GO
 
-- ELIMINAR — Anular incidencia registrada por error
UPDATE OPERACIONES.Incidencia
SET    is_active  = 0,
       deleted_at = GETDATE(),
       updated_at = GETDATE()
WHERE  id_incidencia = 51;
GO
 
-- ============================================================
-- SECCIÓN CRUD 5: PERCEPCION
-- ============================================================
 
-- CREAR — Agregar una percepcion de bono a una nomina
INSERT INTO NOMINA.Percepcion
    (id_nomina, id_categoria_percep, monto, aplica_impuesto, descripcion)
VALUES
    (1, 5, 3000.00, 1, 'Bono productividad Q1 2020');
GO
 
-- CONSULTAR — Percepciones desglosadas por nomina y empleado
SELECT
    PE.id_percepcion,
    E.primer_nombre + ' ' + E.primer_apellido AS empleado,
    PN.fecha_inicio,
    CP.nombre                                  AS tipo_percepcion,
    PE.monto,
    PE.aplica_impuesto,
    PE.descripcion
FROM NOMINA.Percepcion               AS PE
JOIN NOMINA.Nomina                   AS N  ON PE.id_nomina           = N.id_nomina
JOIN RRHH.Empleado                   AS E  ON N.id_empleado          = E.id_empleado
JOIN NOMINA.Periodo_Nomina           AS PN ON N.id_periodo           = PN.id_periodo
JOIN CATALOGOS.Categoria_Percepcion  AS CP ON PE.id_categoria_percep = CP.id_categoria_percep
WHERE PE.is_active = 1
ORDER BY PN.fecha_inicio DESC, E.primer_apellido;
GO
 
-- ACTUALIZAR — Corregir monto de una percepcion
UPDATE NOMINA.Percepcion
SET    monto      = 3500.00,
       updated_at = GETDATE()
WHERE  id_percepcion = 51;
GO
 
-- ELIMINAR — Anular percepcion incorrecta
UPDATE NOMINA.Percepcion
SET    is_active  = 0,
       deleted_at = GETDATE(),
       updated_at = GETDATE()
WHERE  id_percepcion = 51;
GO
 
-- ============================================================
-- SECCIÓN CRUD 6: USUARIO y SEGURIDAD
-- ============================================================
 
-- CREAR — Crear usuario del sistema para nuevo empleado
-- (Primero se inserta el empleado si no existe; aqui se asume id_empleado = 51)
INSERT INTO SEGURIDAD.Usuario
    (id_empleado, username, password_hash)
VALUES
    (51, 'pgonzalez', '5E884898DA28047151D0E56F8DC629273603D0D6AABBDD62A11EF721D154310');
GO
 
-- CONSULTAR — Ver usuarios activos con su rol asignado
SELECT
    U.id_usuario,
    E.primer_nombre + ' ' + E.primer_apellido AS nombre_empleado,
    U.username,
    R.nombre_rol,
    U.ultimo_acceso,
    U.is_active
FROM SEGURIDAD.Usuario     AS U
JOIN RRHH.Empleado         AS E  ON U.id_empleado = E.id_empleado
LEFT JOIN SEGURIDAD.Usuario_Rol AS UR ON U.id_usuario = UR.id_usuario AND UR.is_active = 1
LEFT JOIN SEGURIDAD.Rol    AS R  ON UR.id_rol = R.id_rol
WHERE U.is_active = 1
ORDER BY U.username;
GO
 
-- ACTUALIZAR — Registrar ultimo acceso de un usuario
UPDATE SEGURIDAD.Usuario
SET    ultimo_acceso = GETDATE(),
       updated_at    = GETDATE()
WHERE  username = 'pgonzalez';
GO
 
-- ELIMINAR — Desactivar usuario sin borrar el registro
UPDATE SEGURIDAD.Usuario
SET    is_active  = 0,
       deleted_at = GETDATE(),
       updated_at = GETDATE()
WHERE  username = 'pgonzalez';
GO
 
-- ============================================================
-- SECCIÓN CRUD 7: CONSULTAS GERENCIALES
-- ============================================================
 
-- Resumen de nomina por periodo: total a pagar y numero de empleados
SELECT
    PN.fecha_inicio,
    PN.fecha_fin,
    COUNT(N.id_nomina)           AS num_empleados,
    SUM(N.total_percepciones)    AS total_percepciones,
    SUM(N.total_deducciones)     AS total_deducciones,
    SUM(N.salario_neto)          AS total_neto_pagar
FROM NOMINA.Nomina         AS N
JOIN NOMINA.Periodo_Nomina AS PN ON N.id_periodo = PN.id_periodo
WHERE N.is_active = 1
GROUP BY PN.fecha_inicio, PN.fecha_fin
ORDER BY PN.fecha_inicio DESC;
GO
 
-- Top 10 empleados con mayor salario neto acumulado en 2023
SELECT TOP 10
    E.primer_nombre + ' ' + E.primer_apellido AS empleado,
    C.nombre_cargo,
    SUM(N.salario_neto)                        AS salario_neto_acumulado_2023
FROM NOMINA.Nomina          AS N
JOIN RRHH.Empleado          AS E  ON N.id_empleado = E.id_empleado
JOIN RRHH.Cargo             AS C  ON N.id_cargo    = C.id_cargo
JOIN NOMINA.Periodo_Nomina  AS PN ON N.id_periodo  = PN.id_periodo
WHERE YEAR(PN.fecha_inicio) = 2023
  AND N.is_active = 1
GROUP BY E.id_empleado, E.primer_nombre, E.primer_apellido, C.nombre_cargo
ORDER BY salario_neto_acumulado_2023 DESC;
GO
 
-- Resumen de deducciones obligatorias (INSS e IR) por periodo
SELECT
    PN.fecha_inicio,
    CD.nombre                    AS tipo_deduccion,
    COUNT(D.id_deduccion)        AS cantidad_empleados,
    SUM(D.monto)                 AS total_deducido
FROM NOMINA.Deduccion            AS D
JOIN NOMINA.Nomina               AS N  ON D.id_nomina        = N.id_nomina
JOIN NOMINA.Periodo_Nomina       AS PN ON N.id_periodo        = PN.id_periodo
JOIN CATALOGOS.Categoria_Deduccion AS CD ON D.id_categoria_ded = CD.id_categoria_ded
WHERE CD.es_obligatoria = 1
  AND D.is_active = 1
GROUP BY PN.fecha_inicio, CD.nombre
ORDER BY PN.fecha_inicio DESC, total_deducido DESC;
GO