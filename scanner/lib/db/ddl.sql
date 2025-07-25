create table app_users (
  id uuid primary key,
  name text not null,
  email text unique not null,
  password_hash text not null,
  phone text unique not null,
  dob date not null,
  gender text not null,
  country text not null,
  logged_in boolean not null default false,
  access_token text,
  refresh_token text,
  token_expiry timestamp,
  is_synced boolean default false,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

create table prescriptions (
  id uuid primary key,
  date date not null,
  patient_name text not null,
  doctor_name text not null,
  medications jsonb not null,
  notes text,
  image_path text,
  user_id uuid references app_users(id) on delete cascade,
  is_synced boolean default false,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);


-- Faster queries on user logins or sync
create index idx_app_users_email on app_users(email);
create index idx_app_users_phone on app_users(phone);
create index idx_prescriptions_user_id on prescriptions(user_id);

