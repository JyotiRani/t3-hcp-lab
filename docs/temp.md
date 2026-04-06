
## 🧪 Application Testing

### Test 1: User Registration
```bash
curl -X POST http://<vsi-ip>:8001/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "password": "SecurePass123!",
    "role": "user"
  }'
```

### Test 2: User Login
```bash
curl -X POST http://<vsi-ip>:8001/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "password": "SecurePass123!"
  }'

# Save the access_token from response
```

### Test 3: Create Order
```bash
TOKEN="<your-access-token>"

curl -X POST http://<vsi-ip>:8002/orders \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "items": [
      {"name": "Laptop", "quantity": 1, "price": 1200.00}
    ],
    "total_amount": 1200.00,
    "shipping_address": "123 Main St, City, Country"
  }'
```

### Test 4: Create Shipment (Admin)
```bash
# Login as admin first
curl -X POST http://<vsi-ip>:8001/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "password": "AdminPass123!"
  }'

ADMIN_TOKEN="<admin-access-token>"

curl -X POST http://<vsi-ip>:8003/shipments \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "order_id": "<order-id-from-previous-step>",
    "origin": "Warehouse A",
    "destination": "123 Main St, City, Country",
    "carrier": "FastShip Express",
    "initial_eta": "2026-04-05T10:00:00Z"
  }'
```
