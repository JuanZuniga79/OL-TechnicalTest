CREATE TABLE IF NOT EXISTS ROLES(
    id SERIAL PRIMARY KEY,
    name VARCHAR(32) UNIQUE NOT NULL,
    description VARCHAR(500) DEFAULT 'sin descripcion'
);

CREATE TABLE IF NOT EXISTS USERS(
    id BIGSERIAL PRIMARY KEY,
    first_name VARCHAR(128) NOT NULL,
    last_name VARCHAR(128) NOT NULL,
    email VARCHAR(256) NOT NULL UNIQUE
        CHECK (email ~* '^[a-zA-Z0-9._%+-]+@(gmail\.|hotmail\.|outlook\.)[a-z]{2,}$'),
    password VARCHAR(255) NOT NULL,
    role_id INTEGER NOT NULL,
    CONSTRAINT fk_user_role FOREIGN KEY (role_id) REFERENCES ROLES(id)
);

CREATE TABLE IF NOT EXISTS COUNTRIES(
    id SERIAL PRIMARY KEY,
    name VARCHAR(64) NOT NULL UNIQUE,
    code INTEGER NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS MUNICIPALITIES(
    id SERIAL PRIMARY KEY,
    name VARCHAR(64) NOT NULL,
    country_id INTEGER NOT NULL,
    CONSTRAINT fk_municipality_country FOREIGN KEY (country_id) REFERENCES COUNTRIES(id)
);

CREATE TABLE IF NOT EXISTS STATUSES(
    id SERIAL PRIMARY KEY,
    name VARCHAR(32) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS MERCHANTS(
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(256) NOT NULL,
    email VARCHAR(256) UNIQUE
        CHECK ( email ~* '^[a-zA-Z0-9._%+-]+@(gmail\.|hotmail\.|outlook\.)[a-z]{2,}$' ),
    phone VARCHAR(10) UNIQUE,
    registered_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status_id INTEGER NOT NULL,
    CONSTRAINT fk_status_merchant FOREIGN KEY (status_id) REFERENCES STATUSES(id),
    municipality_id INTEGER NOT NULL,
    CONSTRAINT fk_municipality_merchant FOREIGN KEY (municipality_id) REFERENCES MUNICIPALITIES(id),
    updater_id INTEGER NOT NULL,
    CONSTRAINT fk_merchant_updater FOREIGN KEY (updater_id) REFERENCES USERS(id)
);

CREATE TABLE IF NOT EXISTS ESTABLISHMENTS(
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(128) NOT NULL,
    income NUMERIC(13,2) NOT NULL CHECK ( income >= 0 ),
    employees INTEGER NOT NULL DEFAULT 0 CHECK ( employees >= 0 ),
    owner_id INTEGER NOT NULL,
    CONSTRAINT fk_establishment_owner FOREIGN KEY (owner_id) REFERENCES MERCHANTS(id),
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by INTEGER NOT NULL,
    CONSTRAINT fk_establishment_updater FOREIGN KEY (updated_by) REFERENCES USERS(id)
);

CREATE OR REPLACE FUNCTION avoid_update_creation_date_function()
    RETURNS TRIGGER AS $$
    BEGIN
        IF OLD.registered_at IS NOT NULL AND NEW.registered_at <> OLD.registered_at THEN
            RAISE EXCEPTION 'No se puede actualizar la fecha de creación';
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