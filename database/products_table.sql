-- Tabel Products untuk KatalogKue
-- Jalankan SQL ini di Supabase SQL Editor

create table public.products (
  id uuid not null default gen_random_uuid (),
  title text not null,
  price text not null,
  location text not null,
  product_url text null,
  description text null,
  composition text null,
  nutrition jsonb null,
  created_by uuid null,
  created_at timestamp with time zone null default now(),
  updated_at timestamp with time zone null default now(),
  constraint products_pkey primary key (id),
  constraint products_created_by_fkey foreign key (created_by) references auth.users (id)
) tablespace pg_default;

-- Enable Row Level Security (RLS)
alter table public.products enable row level security;

-- Policy: Allow everyone to read products
create policy "Allow public read access"
  on public.products
  for select
  to public
  using (true);

-- Policy: Allow authenticated users to insert products
create policy "Allow authenticated users to insert"
  on public.products
  for insert
  to authenticated
  with check (auth.uid() = created_by);

-- Policy: Allow users to update their own products
create policy "Allow users to update own products"
  on public.products
  for update
  to authenticated
  using (auth.uid() = created_by)
  with check (auth.uid() = created_by);

-- Policy: Allow users to delete their own products
create policy "Allow users to delete own products"
  on public.products
  for delete
  to authenticated
  using (auth.uid() = created_by);

-- Create index for better performance
create index products_created_by_idx on public.products (created_by);
create index products_created_at_idx on public.products (created_at desc);

-- Tambahkan trigger untuk auto-update updated_at
create or replace function public.handle_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger products_updated_at
  before update on public.products
  for each row
  execute function public.handle_updated_at();
