TRUNCATE TABLE countries RESTART IDENTITY CASCADE;
TRUNCATE TABLE roles RESTART IDENTITY CASCADE;
TRUNCATE TABLE statuses RESTART IDENTITY CASCADE;
TRUNCATE TABLE users RESTART IDENTITY CASCADE;
TRUNCATE TABLE municipalities RESTART IDENTITY CASCADE;
TRUNCATE TABLE merchants RESTART IDENTITY CASCADE;
TRUNCATE TABLE establishments RESTART IDENTITY CASCADE;

INSERT INTO roles(name, description)
VALUES
('administrador', 'sujeto con el mayor control sobre los datos'),
('auxiliar de registro', 'sin descripcion');

INSERT INTO users (first_name, last_name, email, password, role_id)
VALUES
('juan camilo', 'zuniga', 'juan@gmail.com',
'$2a$14$ea/yfiMp2A.D0y60ZE4m6O3iNX7zUQHh6.Z1Dsaxd/yg9Ld0WyOPG',
(SELECT id FROM roles WHERE name = 'administrador'));
INSERT INTO users (first_name, last_name, email, password, role_id) VALUES
('Juan', 'Pérez', 'perezjuan@hotmail.com',
 '$2a$14$nmA33mubaj7HbrlGoqcHEOmVIj.AF5xnILqhdFd9/BlRFNTHsSmjq',
(SELECT id FROM roles WHERE name = 'auxiliar de registro'));

INSERT INTO countries (name, code)
VALUES
('Colombia', 57),
('Perú', 51),
('Ecuador', 593),
('Venezuela', 58),
('Chile', 56);

INSERT INTO municipalities (name, country_id)
VALUES
('Bogotá', (SELECT id FROM countries WHERE name = 'Colombia')),
('Medellín', (SELECT id FROM countries WHERE name = 'Colombia')),
('Cali', (SELECT id FROM countries WHERE name = 'Colombia')),
('Barranquilla', (SELECT id FROM countries WHERE name = 'Colombia')),
('Cartagena', (SELECT id FROM countries WHERE name = 'Colombia')),
('Manizales', (SELECT id FROM countries WHERE name = 'Colombia')),
('Pereira', (SELECT id FROM countries WHERE name = 'Colombia')),
('Ibagué', (SELECT id FROM countries WHERE name = 'Colombia')),
('Tunja', (SELECT id FROM countries WHERE name = 'Colombia')),
('Pasto', (SELECT id FROM countries WHERE name = 'Colombia'));

INSERT INTO statuses(name)
VALUES
('activo'),
('inactivo');

INSERT INTO merchants (name, email, phone, status_id, municipality_id, updater_id) VALUES
('Comerciante 1', 'comerciante1@gmail.com', '1234567890',
 (SELECT id FROM statuses WHERE name = 'activo'),
 (SELECT id FROM municipalities WHERE name = 'Bogotá'),
 (SELECT id FROM users WHERE first_name = 'juan camilo')),

('Comerciante 2', 'comerciante2@hotmail.com', '9876543210',
 (SELECT id FROM statuses WHERE name = 'activo'),
 (SELECT id FROM municipalities WHERE name = 'Medellín'),
 (SELECT id FROM users WHERE first_name = 'Juan')),

('Comerciante 3', 'comerciante3@outlook.com', '5551234567',
 (SELECT id FROM statuses WHERE name = 'activo'),
 (SELECT id FROM municipalities WHERE name = 'Cali'),
 (SELECT id FROM users WHERE first_name = 'juan camilo')),

('Comerciante 4', 'comerciante4@gmail.com', '1112223333',
 (SELECT id FROM statuses WHERE name = 'activo'),
 (SELECT id FROM municipalities WHERE name = 'Barranquilla'),
 (SELECT id FROM users WHERE first_name = 'Juan')),

('Comerciante 5', 'comerciante5@hotmail.com', '4445556666',
 (SELECT id FROM statuses WHERE name = 'activo'),
 (SELECT id FROM municipalities WHERE name = 'Cartagena'),
 (SELECT id FROM users WHERE first_name = 'Juan'));

INSERT INTO establishments (name, income, employees, owner_id, updated_by)
VALUES
-- Comerciante 1 (3 establecimientos)
('Tienda Central', 150000.00, 8,
 (SELECT id FROM merchants WHERE name = 'Comerciante 1'),
 (SELECT updater_id FROM merchants WHERE name = 'Comerciante 1')),
('Almacén Norte', 75000.50, 4,
 (SELECT id FROM merchants WHERE name = 'Comerciante 1'),
 (SELECT updater_id FROM merchants WHERE name = 'Comerciante 1')),
('Bodega Sur', 200000.00, 12,
 (SELECT id FROM merchants WHERE name = 'Comerciante 1'),
 (SELECT updater_id FROM merchants WHERE name = 'Comerciante 1')),

-- Comerciante 2 (2 establecimientos)
('Ferretería Moderna', 85000.00, 6,
 (SELECT id FROM merchants WHERE name = 'Comerciante 2'),
 (SELECT updater_id FROM merchants WHERE name = 'Comerciante 2')),
('Supermercado Express', 120000.75, 9,
 (SELECT id FROM merchants WHERE name = 'Comerciante 2'),
 (SELECT updater_id FROM merchants WHERE name = 'Comerciante 2')),

-- Comerciante 3 (1 establecimiento)
('Cafetería Gourmet', 50000.00, 3,
 (SELECT id FROM merchants WHERE name = 'Comerciante 3'),
 (SELECT updater_id FROM merchants WHERE name = 'Comerciante 3')),

-- Comerciante 4 (3 establecimientos)
('Óptica Visión Clara', 95000.00, 5,
 (SELECT id FROM merchants WHERE name = 'Comerciante 4'),
 (SELECT updater_id FROM merchants WHERE name = 'Comerciante 4')),
('Farmacia Salud Total', 180000.00, 10,
 (SELECT id FROM merchants WHERE name = 'Comerciante 4'),
 (SELECT updater_id FROM merchants WHERE name = 'Comerciante 4')),
('Librería El Saber', 60000.00, 4,
 (SELECT id FROM merchants WHERE name = 'Comerciante 4'),
 (SELECT updater_id FROM merchants WHERE name = 'Comerciante 4')),

-- Comerciante 5 (1 establecimiento)
('Electrodomésticos Power', 130000.00, 7,
 (SELECT id FROM merchants WHERE name = 'Comerciante 5'),
 (SELECT updater_id FROM merchants WHERE name = 'Comerciante 5'));
