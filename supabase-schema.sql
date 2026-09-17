-- Run this file in Supabase SQL Editor before using admin data in production.
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  role text not null default 'customer' check (role in ('customer', 'admin')),
  created_at timestamptz not null default now()
);

create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  category text not null,
  price numeric(12, 2) not null check (price >= 0),
  stock integer not null default 0 check (stock >= 0),
  description text not null default '',
  image text not null default '',
  discount numeric(5, 2) not null default 0 check (discount between 0 and 100),
  created_at timestamptz not null default now()
);

create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  customer_name text not null,
  customer_email text not null,
  customer_phone text not null,
  pickup_location text not null default 'Al Baraka, Kénitra',
  items jsonb not null,
  total numeric(12, 2) not null check (total >= 0),
  payment_method text not null default 'store' check (payment_method = 'store'),
  status text not null default 'pending' check (status in ('pending', 'processing', 'ready', 'collected', 'cancelled')),
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;
alter table public.products enable row level security;
alter table public.orders enable row level security;

create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'admin'
  );
$$;

drop policy if exists "Anyone can read products" on public.products;
drop policy if exists "Admins can manage products" on public.products;
drop policy if exists "Anyone can create store orders" on public.orders;
drop policy if exists "Admins can read orders" on public.orders;
drop policy if exists "Admins can update orders" on public.orders;
drop policy if exists "Admins can delete orders" on public.orders;
drop policy if exists "Users can read their profile" on public.profiles;

create policy "Anyone can read products"
on public.products for select
using (true);

create policy "Admins can manage products"
on public.products for all
using (public.is_admin())
with check (public.is_admin());

create policy "Anyone can create store orders"
on public.orders for insert
with check (payment_method = 'store');

create policy "Admins can read orders"
on public.orders for select
using (public.is_admin());

create policy "Admins can update orders"
on public.orders for update
using (public.is_admin())
with check (public.is_admin());

create policy "Admins can delete orders"
on public.orders for delete
using (public.is_admin());

create policy "Users can read their profile"
on public.profiles for select
using (id = auth.uid());

-- After creating the admin user in Authentication > Users, run:
-- insert into public.profiles (id, role)
-- select id, 'admin' from auth.users
-- where email = 'drogueriealbaraka@gmail.com'
-- on conflict (id) do update set role = excluded.role;
