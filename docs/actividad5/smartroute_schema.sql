-- SmartRoute DSS - FlashLogistics
-- Actividad 5: Arquitectura de Persistencia

CREATE TABLE conductores (
    id_conductor INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    licencia VARCHAR(30) NOT NULL UNIQUE,
    telefono VARCHAR(20),
    estado VARCHAR(20) NOT NULL DEFAULT 'activo',
    CONSTRAINT chk_conductor_estado CHECK (estado IN ('activo', 'inactivo'))
);

CREATE TABLE vehiculos (
    id_vehiculo INT AUTO_INCREMENT PRIMARY KEY,
    placa VARCHAR(20) NOT NULL UNIQUE,
    tipo VARCHAR(50) NOT NULL,
    capacidad_kg DECIMAL(10,2) NOT NULL,
    estado VARCHAR(20) NOT NULL DEFAULT 'disponible',
    id_conductor INT NULL,
    CONSTRAINT chk_vehiculo_capacidad CHECK (capacidad_kg > 0),
    CONSTRAINT chk_vehiculo_estado CHECK (estado IN ('disponible', 'en_ruta', 'mantenimiento')),
    CONSTRAINT fk_vehiculo_conductor FOREIGN KEY (id_conductor) REFERENCES conductores(id_conductor)
);

CREATE TABLE rutas (
    id_ruta INT AUTO_INCREMENT PRIMARY KEY,
    origen VARCHAR(150) NOT NULL,
    destino VARCHAR(150) NOT NULL,
    distancia_km DECIMAL(10,2) NOT NULL,
    tiempo_estimado_min INT NOT NULL,
    costo_estimado DECIMAL(10,2) NOT NULL,
    id_vehiculo INT NOT NULL,
    id_conductor INT NOT NULL,
    CONSTRAINT chk_ruta_distancia CHECK (distancia_km > 0),
    CONSTRAINT chk_ruta_tiempo CHECK (tiempo_estimado_min > 0),
    CONSTRAINT chk_ruta_costo CHECK (costo_estimado >= 0),
    CONSTRAINT fk_ruta_vehiculo FOREIGN KEY (id_vehiculo) REFERENCES vehiculos(id_vehiculo),
    CONSTRAINT fk_ruta_conductor FOREIGN KEY (id_conductor) REFERENCES conductores(id_conductor)
);

CREATE TABLE pedidos (
    id_pedido INT AUTO_INCREMENT PRIMARY KEY,
    cliente VARCHAR(100) NOT NULL,
    direccion VARCHAR(200) NOT NULL,
    fecha_pedido DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(30) NOT NULL DEFAULT 'pendiente',
    prioridad VARCHAR(20) NOT NULL DEFAULT 'media',
    id_ruta INT NULL,
    CONSTRAINT chk_pedido_estado CHECK (estado IN ('pendiente', 'asignado', 'en_camino', 'entregado', 'cancelado')),
    CONSTRAINT chk_pedido_prioridad CHECK (prioridad IN ('alta', 'media', 'baja')),
    CONSTRAINT fk_pedido_ruta FOREIGN KEY (id_ruta) REFERENCES rutas(id_ruta)
);

CREATE TABLE entregas (
    id_entrega INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido INT NOT NULL,
    fecha_salida DATETIME,
    fecha_entrega DATETIME,
    estado VARCHAR(30) NOT NULL DEFAULT 'pendiente',
    observacion TEXT,
    CONSTRAINT chk_entrega_estado CHECK (estado IN ('pendiente', 'en_camino', 'entregada', 'tardia')),
    CONSTRAINT fk_entrega_pedido FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido)
);

CREATE TABLE alertas (
    id_alerta INT AUTO_INCREMENT PRIMARY KEY,
    id_entrega INT NOT NULL,
    tipo VARCHAR(50) NOT NULL,
    mensaje TEXT NOT NULL,
    fecha_generada DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(20) NOT NULL DEFAULT 'abierta',
    CONSTRAINT chk_alerta_estado CHECK (estado IN ('abierta', 'cerrada')),
    CONSTRAINT fk_alerta_entrega FOREIGN KEY (id_entrega) REFERENCES entregas(id_entrega)
);

CREATE TABLE reportes_operativos (
    id_reporte INT AUTO_INCREMENT PRIMARY KEY,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    total_entregas INT NOT NULL DEFAULT 0,
    entregas_tardias INT NOT NULL DEFAULT 0,
    costo_total DECIMAL(10,2) NOT NULL DEFAULT 0,
    CONSTRAINT chk_reporte_fechas CHECK (fecha_fin >= fecha_inicio),
    CONSTRAINT chk_reporte_totales CHECK (total_entregas >= 0 AND entregas_tardias >= 0),
    CONSTRAINT chk_reporte_costo CHECK (costo_total >= 0)
);
