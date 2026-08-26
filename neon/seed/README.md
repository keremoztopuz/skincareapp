# Catalogue seed

Run these against the Neon project in order. `psql` is the reliable way:

```bash
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f 00_schema.sql
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f 01_products.sql
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f 02_product_conditions.sql
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f 03_articles.sql
```

Use the project owner's URL, not the proxy's. The role the proxy connects with
(`skinner_reader`) can only `SELECT`, which is the point of it.

| File | What it does |
|---|---|
| `00_schema.sql` | The full DDL: `products`, `articles`, `conditions`, `product_conditions`, their indexes, and the five `conditions` rows `RoutineEngine` looks up. |
| `01_products.sql` | 107 cosmetic products across the seven `product_type` keys, with English and Turkish descriptions. |
| `02_product_conditions.sql` | 111 links from products to the five condition keys. Routine recommendations read only from this table. |
| `03_articles.sql` | 40 content pieces, English and Turkish, with hero images. |
| `04_fill_images.sql` | Template for the 78 products still without a photo. Fill in each URL, delete the rest of the lines, then run. |

Every file re-runs safely: products and articles upsert on a fixed id, the rest
use `on conflict do nothing`.

`04_fill_images.sql` is the only one that is not ready to run — it is a
template with 78 empty URLs.

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
