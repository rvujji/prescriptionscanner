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
  isSynced boolean default false,
  createdAt timestamp with time zone default now(),
  updatedAt timestamp with time zone default now()
);


-- Faster queries on user logins or sync
create index idx_app_users_email on app_users(email);
create index idx_app_users_phone on app_users(phone);
create index idx_prescriptions_user_id on prescriptions(userid);

