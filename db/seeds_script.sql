TRUNCATE TABLE countries RESTART IDENTITY CASCADE;
TRUNCATE TABLE roles RESTART IDENTITY CASCADE;
TRUNCATE TABLE subjects RESTART IDENTITY CASCADE;
TRUNCATE TABLE statuses RESTART IDENTITY CASCADE;
TRUNCATE TABLE users RESTART IDENTITY CASCADE;
TRUNCATE TABLE municipalities RESTART IDENTITY CASCADE;
TRUNCATE TABLE merchants RESTART IDENTITY CASCADE;
TRUNCATE TABLE establishments RESTART IDENTITY CASCADE;

INSERT INTO roles(name, description)
VALUES
('administrador', 'sujeto con el mayor control sobre los datos'),
('auxiliar de registro', 'sin descripcion');

INSERT INTO subjects (name, type)
VALUES
('Admin User', 'U'),
('Auxiliar User', 'U');

INSERT INTO users (email, password, subject_id, role_id)
VALUES
('admin@gmail.com', '$2a$14$vSlEo/g5EVvDQYVlwCqTzOmGkDeq4L6ctSE7TvJ76JZW8mYhCOnRu',
    (SELECT id FROM subjects WHERE subjects.name = 'Admin User' LIMIT 1),
    (SELECT id FROM roles WHERE roles.name = 'administrador' LIMIT 1)),
('auxiliar@hotmail.com', '$2a$14$4t6/fs9I8X.ZbdUSc26OF./OQlJjfvujeH/.yZr12Cq6rDuZOZ5X2',
    (SELECT id FROM subjects WHERE subjects.name = 'Auxiliar User' LIMIT 1),
    (SELECT id FROM roles WHERE roles.name = 'auxiliar de registro' LIMIT 1)
);

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

WITH inserted_merchant_subjects AS (
    INSERT INTO subjects (name, type)
    VALUES
    ('Merchant A', 'M'),
    ('Merchant B', 'M'),
    ('Merchant C', 'M'),
    ('Merchant D', 'M'),
    ('Merchant E', 'M')
    RETURNING id
)

INSERT INTO merchants (email, phone, registered_at, updated_at, status_id, subject_id, municipality_id, updater_id)
SELECT
    'merchant' || row_number() OVER () || '@gmail.com',
    '300000000' || row_number() OVER (),
    NOW(), NOW(),
    (SELECT id FROM statuses WHERE statuses.name = 'activo'),
    s.id,
    (SELECT id FROM municipalities ORDER BY RANDOM() LIMIT 1),
    (SELECT id FROM users ORDER BY RANDOM() LIMIT 1)
FROM inserted_merchant_subjects s;

WITH merchant_establishments AS (
    SELECT
        id AS merchant_id,
        FLOOR(RANDOM() * 10) + 1 AS num_establishments
    FROM merchants
)
INSERT INTO establishments (name, income, employees, owner_id, updated_at, updated_by)
SELECT
    'Establecimiento ' || row_number() OVER (),
    ROUND((RANDOM() * 10000000)::NUMERIC, 2),
    FLOOR(RANDOM() * 50),
    me.merchant_id,
    NOW(),
    (SELECT id FROM users ORDER BY RANDOM() LIMIT 1)
FROM merchant_establishments me, generate_series(1, 10) gs
WHERE gs <= me.num_establishments;
