-- Migration: Tambah kolom nutrition ke tabel products
-- Jalankan SQL ini di Supabase SQL Editor jika tabel products sudah ada

-- Tambah kolom nutrition (JSONB untuk fleksibilitas)
ALTER TABLE public.products 
ADD COLUMN IF NOT EXISTS nutrition jsonb;

-- Contoh update data produk dengan deskripsi, komposisi, dan nutrisi
-- (Sesuaikan dengan produk yang ada di database Anda)

-- Contoh format data:

-- UPDATE public.products 
-- SET 
--   description = 'Nastar adalah kue kering klasik yang lezat dengan isian selai nanas. Cocok untuk sajian lebaran, arisan, atau acara spesial lainnya. Dibuat dengan bahan premium dan proses higienis.',
--   composition = E'Tepung terigu premium\nMentega berkualitas\nGula halus\nKuning telur segar\nSelai nanas asli\nSusu bubuk',
--   nutrition = '{
--     "calories": "450",
--     "protein": "5.5",
--     "fat": "22.0",
--     "carbs": "58.0",
--     "sugar": "28.0",
--     "fiber": "1.5"
--   }'::jsonb
-- WHERE title = 'Nastar';

-- Catatan:
-- 1. Description: Text panjang deskripsi produk
-- 2. Composition: Setiap bahan dipisah dengan \n (newline) untuk ditampilkan sebagai list
-- 3. Nutrition: JSON object dengan key: calories, protein, fat, carbs, sugar, fiber
--    - Semua nilai dalam string untuk kemudahan input
--    - Unit sudah ditambahkan di UI (kcal, g)
