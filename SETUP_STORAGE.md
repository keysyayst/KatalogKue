# Setup Supabase Storage untuk Upload Gambar Produk

## Langkah-langkah Setup Storage Bucket di Supabase

### 1. Buka Dashboard Supabase

- Login ke https://supabase.com
- Pilih project Anda

### 2. Buat Storage Bucket

1. Klik menu **Storage** di sidebar kiri
2. Klik tombol **New bucket**
3. Isi form:
   - **Name**: `product-images`
   - **Public bucket**: Centang/aktifkan (agar gambar bisa diakses publik)
4. Klik **Create bucket**

### 3. Setup Storage Policies (RLS)

Setelah bucket dibuat, Anda perlu mengatur policies agar user bisa upload dan akses gambar:

#### Policy untuk Upload (INSERT)

```sql
-- Nama: Allow authenticated users to upload
-- Target roles: authenticated
-- Operation: INSERT

CREATE POLICY "Allow authenticated users to upload"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'product-images');
```

#### Policy untuk Read (SELECT)

```sql
-- Nama: Allow public to view images
-- Target roles: public, authenticated
-- Operation: SELECT

CREATE POLICY "Allow public to view images"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'product-images');
```

#### Policy untuk Update

```sql
-- Nama: Allow users to update their uploads
-- Target roles: authenticated
-- Operation: UPDATE

CREATE POLICY "Allow users to update their uploads"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'product-images')
WITH CHECK (bucket_id = 'product-images');
```

#### Policy untuk Delete

```sql
-- Nama: Allow users to delete their uploads
-- Target roles: authenticated
-- Operation: DELETE

CREATE POLICY "Allow users to delete their uploads"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'product-images');
```

### 4. Cara Setting Policies via Dashboard

1. Di halaman **Storage**, klik bucket `product-images`
2. Klik tab **Policies**
3. Klik **New policy**
4. Pilih template atau buat custom policy
5. Paste SQL di atas sesuai operasi yang diinginkan
6. Klik **Review** lalu **Save policy**

### 5. Verifikasi

Setelah setup selesai, coba:

1. Buka aplikasi Flutter
2. Login sebagai admin
3. Buka halaman "Kelola Produk"
4. Klik tombol **+** untuk tambah produk
5. Klik **Pilih Gambar**
6. Pilih gambar dari galeri atau kamera
7. Isi form dan klik **Simpan**

Jika berhasil, gambar akan ter-upload dan URL-nya otomatis tersimpan di database.

### Troubleshooting

**Error: "new row violates row-level security policy"**

- Pastikan RLS policies sudah dibuat dengan benar
- Pastikan user sudah login (authenticated)

**Error: "Bucket not found"**

- Pastikan nama bucket di kode sama persis: `product-images`
- Periksa di Storage dashboard apakah bucket sudah dibuat

**Gambar tidak muncul setelah upload**

- Pastikan bucket di-set sebagai **public**
- Periksa policy SELECT sudah dibuat untuk role `public`

### Struktur Path File

File akan disimpan dengan struktur:

```
product-images/
  └── products/
      └── {product-id}/
          └── product_{timestamp}.jpg
```

Contoh:

```
product-images/products/abc123/product_1700000000000.jpg
```
