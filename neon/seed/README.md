# Catalogue seed

Run these against the Neon project in order. `psql` is the reliable way:

```bash
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f 00_schema.sql
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f 01_products.sql
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f 02_product_conditions.sql
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f 03_articles.sql
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f 04_fill_images.sql
```

`04_fill_images.sql` must come **after** `01_products.sql`, which overwrites
`image_url` from its own values. Run them the other way round and the photos
silently revert to null.

Use the project owner's URL, not the proxy's. The role the proxy connects with
(`skinner_reader`) can only `SELECT`, which is the point of it.

| File | What it does |
|---|---|
| `00_schema.sql` | The full DDL: `products`, `articles`, `conditions`, `product_conditions`, their indexes, and the five `conditions` rows `RoutineEngine` looks up. |
| `01_products.sql` | 107 cosmetic products across the seven `product_type` keys, with English and Turkish descriptions. |
| `02_product_conditions.sql` | 111 links from products to the five condition keys. Routine recommendations read only from this table. |
| `03_articles.sql` | 40 content pieces, English and Turkish, with hero images. |
| `04_fill_images.sql` | The 43 product photos that `01_products.sql` does not carry, then the 35 products still without one, commented out as a template. |

Every file re-runs safely: products and articles upsert on a fixed id, the rest
use `on conflict do nothing`, and the image fills are plain updates by id.

## Where the data came from

Product names, brands and the 29 product photos come from
[Open Beauty Facts](https://world.openbeautyfacts.org) (data ODbL, images
CC-BY-SA). Article images come from [Pexels](https://www.pexels.com) under the
Pexels License. All descriptions and article copy were written for this app.

The catalogue is cosmetics only. Prescription products, medical devices, and
body, hair, children's and makeup products were excluded.

72 of the 107 products now carry a photo: 29 came with the original seed, 43
were matched to Open Beauty Facts listings afterwards. The remaining 35 have
none, pending either a listing that turns up later or an affiliate feed that
licenses official product photography.

Open Beauty Facts photos are **CC BY-SA 3.0**: usable, but attribution is
required. The app needs a visible credit before any of these ship.

## Regenerating

`generate_sql.py` in the session scratchpad builds these files from the
harvested JSON. Product and article ids are `uuid5` values derived from a fixed
namespace, so regenerating produces the same ids and the upserts stay stable.
