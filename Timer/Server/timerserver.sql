create table timers (id integer primary key, user_id integer, description, start_datetime, duration, end_datetime, status);
create table users (id integer primary key, password, email, mac);
create unique index user_email on users (email);
create unique index user_mac on users (mac); -- this is OK in sqlite, but not mysql, postgres etc.
