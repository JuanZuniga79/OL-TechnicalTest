CREATE TABLE IF NOT EXISTS ROLES(
    id SERIAL PRIMARY KEY,
    name VARCHAR(32) UNIQUE NOT NULL,
    description VARCHAR(500) DEFAULT 'sin descripcion'
);

CREATE TABLE IF NOT EXISTS SUBJECTS(
    id BIGSERIAL PRIMARY KEY,
    name varchar(256) NOT NULL,
    type CHAR(1) NOT NULL CHECK (type IN ('U', 'M'))
);

CREATE TABLE IF NOT EXISTS USERS(
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR(256) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    subject_id BIGINT NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
    role_id INTEGER NOT NULL REFERENCES ROLES(id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS COUNTRIES(
    id SERIAL PRIMARY KEY,
    name VARCHAR(64) NOT NULL UNIQUE,
    code INTEGER NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS MUNICIPALITIES(
    id SERIAL PRIMARY KEY,
    name VARCHAR(64) NOT NULL,
    country_id INTEGER NOT NULL REFERENCES COUNTRIES(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS STATUSES(
    id SERIAL PRIMARY KEY,
    name VARCHAR(32) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS MERCHANTS(
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR(256) UNIQUE,
    phone VARCHAR(10) UNIQUE,
    registered_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status_id INTEGER NOT NULL REFERENCES STATUSES(id) ON DELETE RESTRICT,
    subject_id INTEGER NOT NULL REFERENCES SUBJECTS(id) ON DELETE CASCADE,
    municipality_id INTEGER NOT NULL REFERENCES MUNICIPALITIES(id) ON DELETE RESTRICT,
    updater_id INTEGER NOT NULL REFERENCES USERS(id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS ESTABLISHMENTS(
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(128) NOT NULL,
    income NUMERIC(13,2) NOT NULL CHECK ( income >= 0 ),
    employees INTEGER NOT NULL DEFAULT 0 CHECK ( employees >= 0 ),
    owner_id INTEGER NOT NULL REFERENCES MERCHANTS(id) ON DELETE CASCADE,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by INTEGER NOT NULL REFERENCES USERS(id) ON DELETE RESTRICT
);

CREATE OR REPLACE FUNCTION check_disjoint_subjects()
    RETURNS TRIGGER AS $$
    BEGIN
        IF (TG_TABLE_NAME = 'users' AND EXISTS (SELECT 1 FROM merchants WHERE subject_id = NEW.subject_id))
        OR (TG_TABLE_NAME = 'merchants' AND EXISTS (SELECT 1 FROM users WHERE subject_id = NEW.subject_id)) THEN
            RAISE EXCEPTION 'Un subject_id no puede estar en ambas tablas';
        END IF;
        RETURN NEW;
    END;
    $$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION avoid_update_creation_date_function()
    RETURNS TRIGGER AS $$
    BEGIN
        IF OLD.registered_at IS NOT NULL AND NEW.registered_at <> OLD.registered_at THEN
            RAISE EXCEPTION 'No se puede actualizar la fecha de creación';
        END IF;
        RETURN NEW;
    END;
    $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION validate_email_function()
    RETURNS TRIGGER AS $$
    BEGIN
        IF NEW.email IS NOT NULL AND NEW.email !~ '^[a-zA-Z0-9._%+-]+@(gmail\.|hotmail\.|outlook\.)[a-z]{2,}$' THEN
            RAISE EXCEPTION 'Correo electrónico no válido. Debe ser de dominio gmail, hotmail o outlook';
        END IF;
        RETURN NEW;
    END;
    $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_date_function()
    RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER validate_users_email_trigger
    BEFORE INSERT OR UPDATE ON USERS
    FOR EACH ROW
    EXECUTE FUNCTION validate_email_function();

CREATE TRIGGER validate_merchant_email_trigger
    BEFORE INSERT OR UPDATE ON MERCHANTS
    FOR EACH ROW
    EXECUTE FUNCTION validate_email_function();

CREATE TRIGGER update_merchant_update_date_trigger
    BEFORE UPDATE ON MERCHANTS
    FOR EACH ROW
    EXECUTE PROCEDURE update_date_function();

CREATE TRIGGER avoid_update_creation_date_trigger
    BEFORE UPDATE ON MERCHANTS
    FOR EACH ROW
    EXECUTE PROCEDURE avoid_update_creation_date_function();

CREATE TRIGGER update_establishment_update_date_trigger
    BEFORE UPDATE ON ESTABLISHMENTS
    FOR EACH ROW
    EXECUTE PROCEDURE update_date_function();

CREATE TRIGGER enforce_disjoint_users
    BEFORE INSERT OR UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION check_disjoint_subjects();

CREATE TRIGGER enforce_disjoint_merchants
    BEFORE INSERT OR UPDATE ON merchants
    FOR EACH ROW
    EXECUTE FUNCTION check_disjoint_subjects();
