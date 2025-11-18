CREATE EXTENSION IF NOT EXISTS pgcrypto;
-- These commands should be run once by a superuser (e.g., postgres)
-- to set up the database and user. They are commented out to prevent errors
-- if this script is run multiple times.

-- CREATE DATABASE scanner;
-- CREATE USER scanner1 WITH PASSWORD 'scanner11';
-- ALTER DATABASE scanner OWNER TO scanner1;

-- After running the commands above, connect to the 'scanner' database as 'scanner1'
-- and then run the rest of this script.
-- For example, using psql:
-- \c scanner scanner1

drop table if exists prescriptions;
drop table if exists app_users cascade;

create table app_users (
  id uuid primary key,
  name text not null,
  email text unique not null,
  passwordHash text not null,
  phone text unique not null,
  dob date not null,
  gender text not null,
  country text not null,
  loggedIn boolean not null default false,
  accessToken text,
  refreshToken text,
  tokenExpiry timestamp,
  isSynced boolean default false,
  createdAt timestamp with time zone default now(),
  updatedAt timestamp with time zone default now()
);

create table prescriptions (
  id uuid primary key,
  date date not null,
  patientName text not null,
  doctorName text not null,
  medications jsonb not null,
  notes text,
  imagePath text,
  userId uuid references app_users(id) on delete cascade,
  isarchived boolean default false,
  isSynced boolean default false,
  createdAt timestamp with time zone default now(),
  updatedAt timestamp with time zone default now()
);


-- Faster queries on user logins or sync
create index idx_app_users_email on app_users(email);
create index idx_app_users_phone on app_users(phone);
create index idx_prescriptions_user_id on prescriptions(userid);

-- 1) Create anon role (unauthenticated users)
CREATE ROLE anon NOLOGIN;

-- 2) Allow usage of public schema
GRANT USAGE ON SCHEMA public TO anon;

GRANT anon TO scanner1;

-- 5) Deny anon any data access

CREATE POLICY no_anon_access_users
  ON app_users
  FOR ALL
  TO anon
  USING (false)
  WITH CHECK (false);

CREATE POLICY no_anon_access_prescriptions
  ON prescriptions
  FOR ALL
  TO anon
  USING (false)
  WITH CHECK (false);



REVOKE ALL ON app_users FROM anon;
REVOKE ALL ON prescriptions FROM anon;

ALTER TABLE app_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE prescriptions ENABLE ROW LEVEL SECURITY;

DROP FUNCTION public.login_user(text, text);

CREATE OR REPLACE FUNCTION public.login_user(
    identifier TEXT,
    pwd TEXT
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    user_exists BOOLEAN;
BEGIN
    -- Check if a user exists with correct password
    SELECT TRUE INTO user_exists
    FROM app_users
    WHERE (phone = identifier OR email = identifier)
      AND passwordHash = pwd
    LIMIT 1;

    -- If no match found → return false
    IF user_exists IS NULL THEN
        RETURN FALSE;
    END IF;

    RETURN TRUE;
END;
$$;

GRANT EXECUTE ON FUNCTION public.login_user(text, text) TO anon;

CREATE OR REPLACE FUNCTION public.register_user(
    name TEXT,
    email TEXT,
    phone TEXT,
    pwd TEXT,
    dob DATE,
    gender TEXT,
    country TEXT
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    new_id UUID := gen_random_uuid();
BEGIN
    INSERT INTO app_users(
        id,
        name,
        email,
        passwordHash,
        phone,
        dob,
        gender,
        country
    )
    VALUES (
        new_id,
        name,
        email,
        pwd,
        phone,
        dob,
        gender,
        country
    );

    RETURN new_id;
EXCEPTION
    WHEN unique_violation THEN
        -- Email or phone already exists
        RETURN NULL;
END;
$$;

GRANT EXECUTE ON FUNCTION public.register_user(
    text, text, text, text, date, text, text
) TO anon;
