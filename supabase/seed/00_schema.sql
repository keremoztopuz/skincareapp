-- Skinner katalog seed
-- Uretim: scratchpad/generate_sql.py. Elle duzenleme, scripti guncelle.
-- Supabase Dashboard > SQL Editor icinde sirayla calistir.

-- Icerik cevirisi icin TR kolonlari. Urun adi marka adidir, cevrilmez.
alter table public.products add column if not exists description_tr text;
alter table public.articles  add column if not exists title_tr   text;
alter table public.articles  add column if not exists content_tr text;

-- conditions.key uzerinde tekillik, asagidaki upsert icin gerekli
create unique index if not exists conditions_key_uniq on public.conditions (key);

-- RoutineEngine.swift:83-87 icindeki bes anahtar
insert into public.conditions (id, key) values
  ('3b785e3c-be84-5e2e-8326-9511297d1832'::uuid, 'acne'),
  ('82771f2c-1b0a-5404-8c90-8bc58151bfb3'::uuid, 'redness'),
  ('e9223a50-65ca-5963-88c8-e5433f6c0e49'::uuid, 'pigmentation'),
  ('29bfd43d-b889-5776-bb43-a7354fd168d9'::uuid, 'wrinkles'),
  ('43bb440a-6d6e-52e6-a726-ae74e71f71df'::uuid, 'eyebags')
on conflict (key) do nothing;
