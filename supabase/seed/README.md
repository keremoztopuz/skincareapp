# Catalogue seed

Run these in the Supabase Dashboard SQL editor, in order. The app ships only the
anon key, so it cannot write these rows itself.

| File | What it does |
|---|---|
| `00_schema.sql` | Adds `products.description_tr`, `articles.title_tr`, `articles.content_tr`, and seeds the five `conditions` rows that `RoutineEngine` looks up. |
| `01_products.sql` | 107 cosmetic products across the seven `product_type` keys, with English and Turkish descriptions. |
| `02_product_conditions.sql` | 111 links from products to the five condition keys. Routine recommendations read only from this table. |
| `03_articles.sql` | 40 content pieces, English and Turkish, with hero images. |
| `04_fill_images.sql` | Template for the 78 products still without a photo. Fill in each URL, delete the rest of the lines, then run. |

Every file re-runs safely: products and articles upsert on a fixed id, the rest
use `on conflict do nothing`.

## Where the data came from

Product names, brands and the 29 product photos come from
[Open Beauty Facts](https://world.openbeautyfacts.org) (data ODbL, images
CC-BY-SA). Article images come from [Pexels](https://www.pexels.com) under the
Pexels License. All descriptions and article copy were written for this app.

The catalogue is cosmetics only. Prescription products, medical devices, and
body, hair, children's and makeup products were excluded.

The remaining 78 products carry no image yet, pending an affiliate feed that
licenses official product photography.

## Regenerating

`generate_sql.py` in the session scratchpad builds these files from the
harvested JSON. Product and article ids are `uuid5` values derived from a fixed
namespace, so regenerating produces the same ids and the upserts stay stable.
