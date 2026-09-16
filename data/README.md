# Al Baraka data

`products.json` is the initial catalogue used to seed the standalone local data store.
`orders.json` documents the expected order collection shape and starts empty.

In the browser, products and orders are persisted in `localStorage` under `albaraka_data`.
When the hosted `dataSdk` is available, the application continues to use that backend instead.
