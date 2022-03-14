### Ruby version 2.2.7
### RoR version 4.0.0
### MongoDB version 4.0

## Deployment instructions

```bash
  $ docker-compose run rails bash  # Run command to start rails image
  $ cd /products_manager  # Acess project directory for command: cd /products_manager
  $ rails s  # Run command to start server
```

## Challengers:
  - First challenge: create application in rails 4.x with mongodb 4.0 in mode API and create service for products 

## Services

### Products

* List products (index) [GET/products]
  * Status code: 200
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
* Get product (show) [GET/products/:id]
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
* Create new product (Create) [POST/products]
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
* Update product (Update) [PUT/products/:id]
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
* Delete product (Delete) [DELETE/products/:id]
  * Status code: 204