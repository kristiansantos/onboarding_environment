### Elixir version 1.8.1
### Phoenix version 1.5.13
### MongoDB version 4.0

## Deployment instructions

```bash
  $ docker-compose run phoenix bash  # Run command to start phoenix image.
  $ docker ps # List containers.
  $ docker exec -it my_container_id bash # Acess bash container.
  $ mix deps.get # Install dependencies with 
  $ mix phx.server # Start server
Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
```

## Challengers:
  - First challenge: create application in rails 4.x with mongodb 4.0 in mode API and create service for products.
  - Second challenge: create application in phoenix 1.5.13 with mongodb 4.0 in mode API and create service for products and query string filter in index.
  - Third challenge: integrate services with redis and elasticsearch.
  - Fourth challenge: (TDD, CD, DoD) test coverage.
  - Fifth challenge: export service.

## Services

### Products

* List products (index) [GET/api/products]
  * Status code: 200
  * Accept query string fields filter: sku, name, description, amount, price.
  * Response body:
      ```
      [
        {
          "id": {
            "$oid": "622a57e1df29eb0139000000"
          },
          "sku": "a12bcdr",
          "name": "name_one",
          "description": "Lorem ipsum dolor sit amet, consectetur.",
          "amount": 10,
          "price": 50.0
        },
        {
          "id": {
            "$oid": "622a5848df29eb0139000001"
          },
          "sku": "bc12re",
          "name": "name_two",
          "description": "Lorem ipsum dolor sit amet.",
          "amount": 100,
          "price": 30.0
        },
        {
          "id": {
            "$oid": "622a744bdf29eb0151000000"
          },
          "sku": "csd324e",
          "name": "name_tree",
          "description": "Lorem ipsum dolor.",
          "amount": 70,
          "price": 20.0
        }
      ]
      ```
* Get product (show) [GET/api/products/:id]
    * Status code: 200
    * Response body:
      ```
        {
          "id": {
            "$oid": "622a57e1df29eb0139000000"
          },
          "sku": "a12bcdr",
          "name": "name_one",
          "description": "Lorem ipsum dolor sit amet, consectetur.",
          "amount": 10,
          "price": 50.0
        }
      ```
* Create new product (Create) [POST/api/products]
    * Status code: 201
    * Request body:
      ```
        {
          "sku": "a12bcdr",
          "name": "name_one",
          "description": "Lorem ipsum dolor sit amet, consectetur.",
          "amount": 10,
          "price": 50.0
        }
      ```
    * Response body:
      ```
        {
          "id": {
            "$oid": "622a57e1df29eb0139000000"
          },
          "sku": "a12bcdr",
          "name": "name_one",
          "description": "Lorem ipsum dolor sit amet, consectetur.",
          "amount": 10,
          "price": 50.0
        }
      ```
* Update product (Update) [PUT/api/products/:id]
    * Status code: 200
    * Request body:
      ```
        {
          "sku": "a12bcdrr",
          "name": "name_one",
          "description": "Lorem ipsum dolor sit amet, consectetur.",
          "amount": 60,
          "price": 50.0
        }
      ```
    * Response body:
      ```
        {
          "id": {
            "$oid": "622a57e1df29eb0139000000"
          },
          "sku": "a12bcdrr",
          "name": "name_one",
          "description": "Lorem ipsum dolor sit amet, consectetur.",
          "amount": 60,
          "price": 50.0
        }
      ```
* Delete product (Delete) [DELETE/api/products/:id]
  * Status code: 204

### Exports
* Download export (index) [GET/api/exports]
  * Status code: 200
  * Response headers:
      ```
        content-type : text/csv
        content-disposition: attachment; filename="export-2022-05-13.csv"
      ```

* Create new export (Create) [POST/api/exports]
  * Status code: 202
  * Request body (optional):
    ```
      {
        "filters": {
          "name": "name_filter",
          "price": 50
        }
      }
    ```
    
  * Response body:
    ```
      "Export is being processed with success"
      ```