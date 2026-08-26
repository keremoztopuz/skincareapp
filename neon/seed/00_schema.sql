-- Skinner katalog semasi (Neon / PostgreSQL).
-- Neon Console > SQL Editor icinde ya da psql ile, dosya sirasiyla calistir.
--
-- Bu dosya tek basina yeterli: tablolar Supabase konsolunda elle kurulmustu,
-- burada tam DDL olarak yeniden yazildi. Tekrar calistirmak guvenli.

create extension if not exists "pgcrypto";

-- Katalogu yalnizca proxy okur; uygulamada DB kimlik bilgisi yok.
create table if not exists public.products (
  id                 uuid primary key default gen_random_uuid(),
  name               text        not null,
  brand              text,
  description        text,
  -- Icerik cevirisi. Urun adi marka adidir, cevrilmez.
  description_tr     text,
  image_url          text,
  product_type       text,
  active_ingredients text,
  usage_time         text,
  frequency          text,
  contraindications  text,
  skin_types         text[],
  is_active          boolean     not null default true,
  created_at         timestamptz not null default now()
);

create table if not exists public.articles (
  id           uuid primary key default gen_random_uuid(),
  title        text        not null,
  title_tr     text,
  content      text,
  content_tr   text,
  image_url    text,
  read_time    integer,
  article_type text,
  is_active    boolean     not null default true,
  is_fixed     boolean     not null default false,
  created_at   timestamptz not null default now()
);

-- RoutineEngine.swift:83-87 icindeki bes anahtar.
create table if not exists public.conditions (
  id  uuid primary key default gen_random_uuid(),
  key text not null
);

create unique index if not exists conditions_key_uniq on public.conditions (key);

-- Routine onerileri yalnizca bu tablodan okunur.
create table if not exists public.product_conditions (
  product_id   uuid not null references public.products (id)   on delete cascade,
  condition_id uuid not null references public.conditions (id) on delete cascade,
  primary key (product_id, condition_id)
);

-- Search ve Home listeleri is_active + product_type uzerinden filtreliyor.
create index if not exists products_active_type_idx
  on public.products (product_type) where is_active;
create index if not exists articles_active_created_idx
  on public.articles (created_at desc) where is_active;
create index if not exists product_conditions_condition_idx
  on public.product_conditions (condition_id);

insert into public.conditions (id, key) values
  ('3b785e3c-be84-5e2e-8326-9511297d1832'::uuid, 'acne'),
  ('82771f2c-1b0a-5404-8c90-8bc58151bfb3'::uuid, 'redness'),
  ('e9223a50-65ca-5963-88c8-e5433f6c0e49'::uuid, 'pigmentation'),
  ('29bfd43d-b889-5776-bb43-a7354fd168d9'::uuid, 'wrinkles'),
  ('43bb440a-6d6e-52e6-a726-ae74e71f71df'::uuid, 'eyebags')
on conflict (key) do nothing;
