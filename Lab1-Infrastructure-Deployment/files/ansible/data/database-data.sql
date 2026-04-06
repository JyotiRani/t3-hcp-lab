-- ============================================================================
-- Logistics Application - Demo Data
-- ============================================================================
-- Description: Sample data for logistics demo application
-- Version: 1.0
-- Date: 2026-03-13
-- ============================================================================

-- ============================================================================
-- 1. USERS DATA (5 users)
-- ============================================================================
-- Password for all users: admin123, manager123, driver123, customer123
-- Hashed with bcrypt (rounds=12)

INSERT INTO users (user_id, username, email, password_hash, full_name, phone, role, is_active) VALUES
('550e8400-e29b-41d4-a716-446655440000', 'admin', 'admin@logistics.com', '$2b$12$YnAPIBlU/L/pKeypsP783OoyppHjJtynEv3Ya/0B5DE9ykOp1IYcO', 'Admin User', '+1-555-0001', 'admin', true),
('550e8400-e29b-41d4-a716-446655440001', 'manager', 'manager@logistics.com', '$2b$12$98aN6MRD/7FMdRoFpShfFuGYkbhIb0.7VnXUzdjXHGFOrHl2wmPNa.', 'Manager User', '+1-555-0002', 'admin', true),
('550e8400-e29b-41d4-a716-446655440002', 'driver1', 'driver1@logistics.com', '$2b$12$BU8cE8RD/EWSeMQTYn7ZF.UJyAQz.TGPoPrmCAoVw4/Izh2aW25Xe', 'John Driver', '+1-555-0003', 'driver', true),
('550e8400-e29b-41d4-a716-446655440003', 'driver2', 'driver2@logistics.com', '$2b$12$BU8cE8RD/EWSeMQTYn7ZF.UJyAQz.TGPoPrmCAoVw4/Izh2aW25Xe', 'Jane Driver', '+1-555-0004', 'driver', true),
('550e8400-e29b-41d4-a716-446655440004', 'customer1', 'customer1@logistics.com', '$2b$12$PX2ILcYLG7LWf8/aW24vOuSpNvnzTOrznDBMVZUIbyfO4TgW60Jt6', 'Alice Customer', '+1-555-0005', 'customer', true);

-- ============================================================================
-- 2. TRUCKS DATA (3 trucks)
-- ============================================================================

INSERT INTO trucks (truck_id, truck_number, license_plate, truck_type, capacity_kg, current_location, status) VALUES
('660e8400-e29b-41d4-a716-446655440000', 'TRK-001', 'ABC-1234', 'Box Truck', 5000.00, 'New York Warehouse', 'available'),
('660e8400-e29b-41d4-a716-446655440001', 'TRK-002', 'XYZ-5678', 'Flatbed', 8000.00, 'Los Angeles Depot', 'in_use'),
('660e8400-e29b-41d4-a716-446655440002', 'TRK-003', 'DEF-9012', 'Refrigerated', 6000.00, 'Chicago Hub', 'maintenance');

-- ============================================================================
-- 3. DRIVERS DATA (2 drivers)
-- ============================================================================

INSERT INTO drivers (driver_id, user_id, license_number, license_expiry, current_truck_id, status, rating, total_deliveries) VALUES
('770e8400-e29b-41d4-a716-446655440000', '550e8400-e29b-41d4-a716-446655440002', 'DL-123456', '2025-12-31', '660e8400-e29b-41d4-a716-446655440001', 'on_duty', 4.85, 150),
('770e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440003', 'DL-789012', '2026-06-30', NULL, 'available', 4.92, 200);

-- ============================================================================
-- 4. ROUTES DATA (3 routes)
-- ============================================================================

INSERT INTO routes (route_id, route_name, start_location, end_location, waypoints, estimated_distance_km, estimated_duration_mins) VALUES
('880e8400-e29b-41d4-a716-446655440000', 'NY-LA Express', 'New York, NY', 'Los Angeles, CA', ARRAY['Philadelphia, PA', 'Chicago, IL', 'Denver, CO', 'Las Vegas, NV'], 4500.00, 2700),
('880e8400-e29b-41d4-a716-446655440001', 'LA-SF Coastal', 'Los Angeles, CA', 'San Francisco, CA', ARRAY['Santa Barbara, CA', 'San Luis Obispo, CA', 'Monterey, CA'], 615.00, 420),
('880e8400-e29b-41d4-a716-446655440002', 'Chicago Local', 'Chicago, IL', 'Milwaukee, WI', ARRAY['Kenosha, WI'], 150.00, 120);

-- ============================================================================
-- 5. ORDERS DATA (37 orders to match 35 shipments)
-- ============================================================================

INSERT INTO orders (order_id, customer_id, order_number, pickup_location, delivery_location, package_weight, package_dimensions, status, priority, special_instructions) VALUES
-- Orders for in-transit shipments (15)
('990e8400-e29b-41d4-a716-446655440000', '550e8400-e29b-41d4-a716-446655440004', 'ORD-2024-001', '123 Main St, New York, NY 10001', '456 Oak Ave, Los Angeles, CA 90001', 150.50, '{"length": 100, "width": 80, "height": 60, "unit": "cm"}', 'in_transit', 'high', 'Fragile - Handle with care'),
('990e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440004', 'ORD-2024-002', '789 Elm St, Chicago, IL 60601', '321 Pine Rd, Milwaukee, WI 53201', 200.00, '{"length": 120, "width": 100, "height": 80, "unit": "cm"}', 'in_transit', 'normal', NULL),
('990e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440004', 'ORD-2024-003', '555 Maple Dr, Los Angeles, CA 90002', '888 Cedar Ln, San Francisco, CA 94102', 75.25, '{"length": 60, "width": 40, "height": 40, "unit": "cm"}', 'in_transit', 'urgent', 'Deliver before 5 PM'),
('990e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440004', 'ORD-2024-004', '111 Oak St, New York, NY 10002', '222 Birch Ave, Los Angeles, CA 90003', 120.00, '{"length": 90, "width": 70, "height": 50, "unit": "cm"}', 'in_transit', 'normal', NULL),
('990e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440004', 'ORD-2024-005', '333 Pine Rd, Chicago, IL 60602', '444 Spruce Dr, Milwaukee, WI 53202', 95.75, '{"length": 80, "width": 60, "height": 45, "unit": "cm"}', 'in_transit', 'low', NULL),
('990e8400-e29b-41d4-a716-446655440010', '550e8400-e29b-41d4-a716-446655440004', 'ORD-2024-011', '234 Broadway, New York, NY 10006', '567 Market St, Los Angeles, CA 90008', 175.00, '{"length": 105, "width": 82, "height": 62, "unit": "cm"}', 'in_transit', 'high', 'Fragile electronics'),
('990e8400-e29b-41d4-a716-446655440011', '550e8400-e29b-41d4-a716-446655440004', 'ORD-2024-012', '890 State St, Chicago, IL 60604', '123 Lake Dr, Milwaukee, WI 53205', 210.50, '{"length": 125, "width": 92, "height": 72, "unit": "cm"}', 'in_transit', 'normal', NULL),
('990e8400-e29b-41d4-a716-446655440012', '550e8400-e29b-41d4-a716-446655440004', 'ORD-2024-013', '456 Sunset Blvd, Los Angeles, CA 90009', '789 Bay St, San Francisco, CA 94104', 130.75, '{"length": 96, "width": 76, "height": 56, "unit": "cm"}', 'in_transit', 'urgent', NULL),
('990e8400-e29b-41d4-a716-446655440013', '550e8400-e29b-41d4-a716-446655440004', 'ORD-2024-014', '321 Park Ave, New York, NY 10007', '654 Ocean Dr, Los Angeles, CA 90010', 185.25, '{"length": 112, "width": 87, "height": 67, "unit": "cm"}', 'in_transit', 'high', NULL),
('990e8400-e29b-41d4-a716-446655440014', '550e8400-e29b-41d4-a716-446655440004', 'ORD-2024-015', '987 Michigan Ave, Chicago, IL 60605', '246 Wisconsin Ave, Milwaukee, WI 53206', 98.00, '{"length": 82, "width": 62, "height": 52, "unit": "cm"}', 'in_transit', 'normal', NULL),
('990e8400-e29b-41d4-a716-446655440015', '550e8400-e29b-41d4-a716-446655440004', 'ORD-2024-016', '135 Fifth Ave, New York, NY 10008', '468 Sunset Dr, Los Angeles, CA 90011', 165.50, '{"length": 103, "width": 83, "height": 63, "unit": "cm"}', 'in_transit', 'high', NULL),
('990e8400-e29b-41d4-a716-446655440016', '550e8400-e29b-41d4-a716-446655440004', 'ORD-2024-017', '579 Wacker Dr, Chicago, IL 60606', '802 River Rd, Milwaukee, WI 53207', 205.75, '{"length": 122, "width": 94, "height": 74, "unit": "cm"}', 'in_transit', 'normal', NULL),
('990e8400-e29b-41d4-a716-446655440017', '550e8400-e29b-41d4-a716-446655440004', 'ORD-2024-018', '913 Hollywood Blvd, Los Angeles, CA 90012', '246 Mission St, San Francisco, CA 94105', 128.25, '{"length": 94, "width": 74, "height": 54, "unit": "cm"}', 'in_transit', 'urgent', NULL),
('990e8400-e29b-41d4-a716-446655440018', '550e8400-e29b-41d4-a716-446655440004', 'ORD-2024-019', '357 Madison Ave, New York, NY 10009', '680 Venice Blvd, Los Angeles, CA 90013', 188.00, '{"length": 114, "width": 88, "height": 68, "unit": "cm"}', 'in_transit', 'high', NULL),
('990e8400-e29b-41d4-a716-446655440019', '550e8400-e29b-41d4-a716-446655440004', 'ORD-2024-020', '791 Rush St, Chicago, IL 60607', '135 North Ave, Milwaukee, WI 53208', 102.50, '{"length": 84, "width": 64, "height": 54, "unit": "cm"}', 'in_transit', 'normal', NULL),

-- Orders for delivered shipments (12)
('990e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440004', 'ORD-2024-006', '666 Lake Shore Dr, Chicago, IL 60601', '888 State St, Milwaukee, WI 53202', 180.00, '{"length": 110, "width": 90, "height": 70, "unit": "cm"}', 'delivered', 'normal', NULL),
('990e8400-e29b-41d4-a716-446655440006', '550e8400-e29b-41d4-a716-446655440004', 'ORD-2024-007', '999 Michigan Ave, Chicago, IL 60602', '111 Water St, Milwaukee, WI 53203', 145.50, '{"length": 95, "width": 75, "height": 55, "unit": "cm"}', 'delivered', 'high', 'Signature required'),
('990e8400-e29b-41d4-a716-446655440020', '550e8400-e29b-41d4-a716-446655440004', 'ORD-2024-021', '246 Lexington Ave, New York, NY 10010', '579 Santa Monica Blvd, Los Angeles, CA 90014', 172.25, '{"length": 106, "width": 84, "height": 64, "unit": "cm"}', 'delivered', 'high', NULL),
('990e8400-e29b-41d4-a716-446655440021', '550e8400-e29b-41d4-a716-446655440004', 'ORD-2024-022', '802 Clark St, Chicago, IL 60608', '913 Brady St, Milwaukee, WI 53209', 118.50, '{"length": 88, "width": 68, "height": 58, "unit": "cm"}', 'delivered', 'normal', NULL),
('990e8400-e29b-41d4-a716-446655440022', '550e8400-e29b-41d4-a716-446655440004', 'ORD-2024-023', '135 Rodeo Dr, Los Angeles, CA 90015', '468 Powell St, San Francisco, CA 94106', 155.00, '{"length": 100, "width": 80, "height": 60, "unit": "cm"}', 'delivered', 'urgent', NULL),
('990e8400-e29b-41d4-a716-446655440023', '550e8400-e29b-41d4-a716-446655440004', 'ORD-2024-024', '579 Wall St, New York, NY 10011', '802 Wilshire Blvd, Los Angeles, CA 90016', 192.75, '{"length": 116, "width": 90, "height": 70, "unit": "cm"}', 'delivered', 'high', NULL),
('990e8400-e29b-41d4-a716-446655440024', '550e8400-e29b-41d4-a716-446655440004', 'ORD-2024-025', '913 Division St, Chicago, IL 60609', '246 Farwell Ave, Milwaukee, WI 53210', 108.25, '{"length": 86, "width": 66, "height": 56, "unit": "cm"}', 'delivered', 'normal', NULL),
('990e8400-e29b-41d4-a716-446655440025', '550e8400-e29b-41d4-a716-446655440004', 'ORD-2024-026', '357 Melrose Ave, Los Angeles, CA 90017', '680 Geary St, San Francisco, CA 94107', 138.50, '{"length": 97, "width": 77, "height": 57, "unit": "cm"}', 'delivered', 'urgent', NULL),
('990e8400-e29b-41d4-a716-446655440026', '550e8400-e29b-41d4-a716-446655440004', 'ORD-2024-027', '791 Third Ave, New York, NY 10012', '135 Highland Ave, Los Angeles, CA 90018', 178.00, '{"length": 108, "width": 86, "height": 66, "unit": "cm"}', 'delivered', 'high', NULL),
('990e8400-e29b-41d4-a716-446655440027', '550e8400-e29b-41d4-a716-446655440004', 'ORD-2024-028', '246 Dearborn St, Chicago, IL 60610', '579 Oakland Ave, Milwaukee, WI 53211', 112.75, '{"length": 87, "width": 67, "height": 57, "unit": "cm"}', 'delivered', 'normal', NULL),
('990e8400-e29b-41d4-a716-446655440028', '550e8400-e29b-41d4-a716-446655440004', 'ORD-2024-029', '802 Beverly Blvd, Los Angeles, CA 90019', '913 Lombard St, San Francisco, CA 94108', 148.25, '{"length": 99, "width": 79, "height": 59, "unit": "cm"}', 'delivered', 'urgent', NULL),
('990e8400-e29b-41d4-a716-446655440029', '550e8400-e29b-41d4-a716-446655440004', 'ORD-2024-030', '135 Seventh Ave, New York, NY 10013', '468 Pico Blvd, Los Angeles, CA 90020', 185.50, '{"length": 113, "width": 89, "height": 69, "unit": "cm"}', 'delivered', 'high', NULL),

-- Orders for pending shipments (5)
('990e8400-e29b-41d4-a716-446655440030', '550e8400-e29b-41d4-a716-446655440004', 'ORD-2024-031', '579 Canal St, New York, NY 10014', '802 Fairfax Ave, Los Angeles, CA 90021', 168.00, '{"length": 104, "width": 82, "height": 62, "unit": "cm"}', 'pending', 'high', 'Schedule pickup'),
('990e8400-e29b-41d4-a716-446655440031', '550e8400-e29b-41d4-a716-446655440004', 'ORD-2024-032', '913 Halsted St, Chicago, IL 60611', '246 Prospect Ave, Milwaukee, WI 53212', 122.50, '{"length": 90, "width": 70, "height": 60, "unit": "cm"}', 'pending', 'normal', NULL),
('990e8400-e29b-41d4-a716-446655440032', '550e8400-e29b-41d4-a716-446655440004', 'ORD-2024-033', '357 La Brea Ave, Los Angeles, CA 90022', '680 Castro St, San Francisco, CA 94109', 142.75, '{"length": 98, "width": 78, "height": 58, "unit": "cm"}', 'pending', 'urgent', NULL),
('990e8400-e29b-41d4-a716-446655440033', '550e8400-e29b-41d4-a716-446655440004', 'ORD-2024-034', '791 Ashland Ave, Chicago, IL 60612', '135 Humboldt Blvd, Milwaukee, WI 53213', 115.00, '{"length": 88, "width": 68, "height": 58, "unit": "cm"}', 'pending', 'normal', NULL),
('990e8400-e29b-41d4-a716-446655440034', '550e8400-e29b-41d4-a716-446655440004', 'ORD-2024-035', '246 Diversey Pkwy, Chicago, IL 60613', '579 Kinnickinnic Ave, Milwaukee, WI 53214', 128.00, '{"length": 92, "width": 72, "height": 62, "unit": "cm"}', 'pending', 'low', NULL),

-- Orders for assigned shipments (3)
('990e8400-e29b-41d4-a716-446655440007', '550e8400-e29b-41d4-a716-446655440004', 'ORD-2024-008', '222 River Rd, New York, NY 10004', '333 Valley Dr, Los Angeles, CA 90006', 165.00, '{"length": 105, "width": 85, "height": 65, "unit": "cm"}', 'assigned', 'normal', NULL),
('990e8400-e29b-41d4-a716-446655440008', '550e8400-e29b-41d4-a716-446655440004', 'ORD-2024-009', '444 Hill St, New York, NY 10005', '555 Mountain Ave, Los Angeles, CA 90007', 135.25, '{"length": 92, "width": 72, "height": 52, "unit": "cm"}', 'assigned', 'urgent', 'Call before delivery'),
('990e8400-e29b-41d4-a716-446655440035', '550e8400-e29b-41d4-a716-446655440004', 'ORD-2024-036', '802 Lincoln Ave, Chicago, IL 60614', '913 Vliet St, Milwaukee, WI 53215', 142.00, '{"length": 96, "width": 76, "height": 66, "unit": "cm"}', 'assigned', 'normal', NULL),

-- Cancelled order
('990e8400-e29b-41d4-a716-446655440009', '550e8400-e29b-41d4-a716-446655440004', 'ORD-2024-010', '777 Forest Ln, Chicago, IL 60603', '999 Garden Way, Milwaukee, WI 53204', 110.00, '{"length": 85, "width": 65, "height": 48, "unit": "cm"}', 'cancelled', 'low', NULL);

-- ============================================================================
-- 6. SHIPMENTS DATA (3 shipments)
-- ============================================================================

INSERT INTO shipments (shipment_id, shipment_number, truck_id, driver_id, route_id, status, estimated_delivery, actual_delivery, notes) VALUES
('aa0e8400-e29b-41d4-a716-446655440000', 'SHP-2024-001', '660e8400-e29b-41d4-a716-446655440001', '770e8400-e29b-41d4-a716-446655440000', '880e8400-e29b-41d4-a716-446655440000', 'in_transit', '2024-03-20 18:00:00', NULL,  'On schedule'),
('aa0e8400-e29b-41d4-a716-446655440001', 'SHP-2024-002', '660e8400-e29b-41d4-a716-446655440000', '770e8400-e29b-41d4-a716-446655440001', '880e8400-e29b-41d4-a716-446655440002', 'delivered', '2024-03-15 14:00:00', '2024-03-15 13:45:00', 'Delivered successfully'),
('aa0e8400-e29b-41d4-a716-446655440002', 'SHP-2024-003', '660e8400-e29b-41d4-a716-446655440001', '770e8400-e29b-41d4-a716-446655440000', '880e8400-e29b-41d4-a716-446655440000', 'pending', '2024-03-25 16:00:00', NULL,  'Awaiting departure');

-- ============================================================================
-- 7. SHIPMENT_ORDERS DATA (Link orders to shipments)
-- ============================================================================

INSERT INTO shipment_orders (shipment_id, order_id, sequence_number) VALUES
('aa0e8400-e29b-41d4-a716-446655440000', '990e8400-e29b-41d4-a716-446655440000', 1),
('aa0e8400-e29b-41d4-a716-446655440000', '990e8400-e29b-41d4-a716-446655440001', 2),
('aa0e8400-e29b-41d4-a716-446655440000', '990e8400-e29b-41d4-a716-446655440002', 3),
('aa0e8400-e29b-41d4-a716-446655440001', '990e8400-e29b-41d4-a716-446655440005', 1),
('aa0e8400-e29b-41d4-a716-446655440001', '990e8400-e29b-41d4-a716-446655440006', 2),
('aa0e8400-e29b-41d4-a716-446655440002', '990e8400-e29b-41d4-a716-446655440007', 1),
('aa0e8400-e29b-41d4-a716-446655440002', '990e8400-e29b-41d4-a716-446655440008', 2);

-- ============================================================================
-- 8. TRACKING_EVENTS DATA (15 events)
-- ============================================================================

INSERT INTO tracking_events (event_id, shipment_id, event_type, location, description, created_by, created_at) VALUES
-- Shipment 1 events (in_transit)
('bb0e8400-e29b-41d4-a716-446655440000', 'aa0e8400-e29b-41d4-a716-446655440000', 'pickup', 'New York, NY', 'Package picked up from warehouse', '770e8400-e29b-41d4-a716-446655440000', '2024-03-18 08:00:00'),
('bb0e8400-e29b-41d4-a716-446655440001', 'aa0e8400-e29b-41d4-a716-446655440000', 'checkpoint', 'Philadelphia, PA', 'Passed through Philadelphia checkpoint', '770e8400-e29b-41d4-a716-446655440000', '2024-03-18 12:00:00'),
('bb0e8400-e29b-41d4-a716-446655440002', 'aa0e8400-e29b-41d4-a716-446655440000', 'checkpoint', 'Chicago, IL', 'Arrived at Chicago hub', '770e8400-e29b-41d4-a716-446655440000', '2024-03-19 06:00:00'),
('bb0e8400-e29b-41d4-a716-446655440003', 'aa0e8400-e29b-41d4-a716-446655440000', 'in_transit', 'Denver, CO', 'Currently in Denver', '770e8400-e29b-41d4-a716-446655440000', '2024-03-19 18:00:00'),

-- Shipment 2 events (delivered)
('bb0e8400-e29b-41d4-a716-446655440004', 'aa0e8400-e29b-41d4-a716-446655440001', 'pickup', 'Chicago, IL', 'Package picked up', '770e8400-e29b-41d4-a716-446655440001', '2024-03-15 09:00:00'),
('bb0e8400-e29b-41d4-a716-446655440005', 'aa0e8400-e29b-41d4-a716-446655440001', 'checkpoint', 'Kenosha, WI', 'Passed through Kenosha', '770e8400-e29b-41d4-a716-446655440001', '2024-03-15 11:00:00'),
('bb0e8400-e29b-41d4-a716-446655440006', 'aa0e8400-e29b-41d4-a716-446655440001', 'delivered', 'Milwaukee, WI', 'Package delivered successfully', '770e8400-e29b-41d4-a716-446655440001', '2024-03-15 13:45:00'),

-- Shipment 3 events (pending)
('bb0e8400-e29b-41d4-a716-446655440007', 'aa0e8400-e29b-41d4-a716-446655440002', 'pickup', 'New York, NY', 'Scheduled for pickup', '770e8400-e29b-41d4-a716-446655440000', '2024-03-23 08:00:00');

-- ============================================================================
-- 9. AI_AGENT_LOGS DATA (5 logs)
-- ============================================================================

INSERT INTO ai_agent_logs (log_id, shipment_id, agent_type, input_data, output_data, decision, confidence_score, created_at) VALUES
('cc0e8400-e29b-41d4-a716-446655440000', 'aa0e8400-e29b-41d4-a716-446655440000', 'delay_detection', 
    '{"current_location": "Denver, CO", "estimated_arrival": "2024-03-20 18:00:00", "current_time": "2024-03-19 18:00:00"}',
    '{"delay_detected": false, "estimated_delay_minutes": 0}',
    'No delay detected - shipment on schedule', 0.9500, '2024-03-19 18:15:00'),

('cc0e8400-e29b-41d4-a716-446655440001', 'aa0e8400-e29b-41d4-a716-446655440000', 'eta_update',
    '{"current_location": "Denver, CO", "destination": "Los Angeles, CA", "remaining_distance_km": 1500}',
    '{"updated_eta": "2024-03-20 17:30:00", "confidence": "high"}',
    'ETA updated based on current progress', 0.9200, '2024-03-19 18:20:00'),

('cc0e8400-e29b-41d4-a716-446655440002', 'aa0e8400-e29b-41d4-a716-446655440001', 'delivery_notification',
    '{"shipment_id": "aa0e8400-e29b-41d4-a716-446655440001", "delivery_time": "2024-03-15 13:45:00"}',
    '{"notification_sent": true, "email_sent": true}',
    'Delivery notification sent to customer', 0.9800, '2024-03-15 13:50:00'),

('cc0e8400-e29b-41d4-a716-446655440003', 'aa0e8400-e29b-41d4-a716-446655440001', 'delay_detection',
    '{"current_location": "Kenosha, WI", "estimated_arrival": "2024-03-15 14:00:00", "current_time": "2024-03-15 11:00:00"}',
    '{"delay_detected": false, "estimated_delay_minutes": 0}',
    'Shipment ahead of schedule', 0.9600, '2024-03-15 11:15:00'),

('cc0e8400-e29b-41d4-a716-446655440004', 'aa0e8400-e29b-41d4-a716-446655440002', 'eta_update',
    '{"current_location": "New York, NY", "destination": "Los Angeles, CA", "remaining_distance_km": 4500}',
    '{"updated_eta": "2024-03-25 16:00:00", "confidence": "medium"}',
    'Initial ETA calculated', 0.8500, '2024-03-23 08:30:00');

-- ============================================================================
-- 10. NOTIFICATIONS DATA (10 notifications)
-- ============================================================================

INSERT INTO notifications (notification_id, user_id, shipment_id, notification_type, title, message, email_sent, email_sent_at, is_read, read_at, created_at) VALUES
('dd0e8400-e29b-41d4-a716-446655440000', '550e8400-e29b-41d4-a716-446655440004', 'aa0e8400-e29b-41d4-a716-446655440000', 'shipment_assigned', 'Shipment Assigned', 'Your order has been assigned to shipment SHP-2024-001', true, '2024-03-18 08:05:00', true, '2024-03-18 09:00:00', '2024-03-18 08:05:00'),

('dd0e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440004', 'aa0e8400-e29b-41d4-a716-446655440000', 'in_transit', 'Shipment In Transit', 'Your shipment SHP-2024-001 is now in transit from New York', true, '2024-03-18 08:10:00', true, '2024-03-18 10:00:00', '2024-03-18 08:10:00'),

('dd0e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440004', 'aa0e8400-e29b-41d4-a716-446655440000', 'in_transit', 'Checkpoint Update', 'Your shipment has passed through Philadelphia, PA', true, '2024-03-18 12:05:00', true, '2024-03-18 14:00:00', '2024-03-18 12:05:00'),

('dd0e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440004', 'aa0e8400-e29b-41d4-a716-446655440000', 'in_transit', 'Checkpoint Update', 'Your shipment has arrived at Chicago hub', true, '2024-03-19 06:05:00', false, NULL, '2024-03-19 06:05:00'),

('dd0e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440004', 'aa0e8400-e29b-41d4-a716-446655440000', 'in_transit', 'Location Update', 'Your shipment is currently in Denver, CO', true, '2024-03-19 18:05:00', false, NULL, '2024-03-19 18:05:00'),

('dd0e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440004', 'aa0e8400-e29b-41d4-a716-446655440001', 'shipment_assigned', 'Shipment Assigned', 'Your order has been assigned to shipment SHP-2024-002', true, '2024-03-15 09:05:00', true, '2024-03-15 09:30:00', '2024-03-15 09:05:00'),

('dd0e8400-e29b-41d4-a716-446655440006', '550e8400-e29b-41d4-a716-446655440004', 'aa0e8400-e29b-41d4-a716-446655440001', 'in_transit', 'Shipment In Transit', 'Your shipment SHP-2024-002 is now in transit', true, '2024-03-15 09:10:00', true, '2024-03-15 10:00:00', '2024-03-15 09:10:00'),

('dd0e8400-e29b-41d4-a716-446655440007', '550e8400-e29b-41d4-a716-446655440004', 'aa0e8400-e29b-41d4-a716-446655440001', 'delivered', 'Delivery Complete', 'Your shipment SHP-2024-002 has been delivered successfully', true, '2024-03-15 13:50:00', true, '2024-03-15 14:30:00', '2024-03-15 13:50:00'),

('dd0e8400-e29b-41d4-a716-446655440008', '550e8400-e29b-41d4-a716-446655440004', 'aa0e8400-e29b-41d4-a716-446655440002', 'shipment_assigned', 'Shipment Assigned', 'Your order has been assigned to shipment SHP-2024-003', true, '2024-03-23 08:05:00', false, NULL, '2024-03-23 08:05:00'),

('dd0e8400-e29b-41d4-a716-446655440009', '550e8400-e29b-41d4-a716-446655440004', 'aa0e8400-e29b-41d4-a716-446655440002', 'in_transit', 'Shipment Scheduled', 'Your shipment SHP-2024-003 is scheduled for pickup', true, '2024-03-23 08:10:00', false, NULL, '2024-03-23 08:10:00');

-- ============================================================================
-- 11. FEEDBACK DATA (5 feedback entries)
-- ============================================================================

INSERT INTO feedback (feedback_id, shipment_id, user_id, rating, comment, created_at) VALUES
('ee0e8400-e29b-41d4-a716-446655440000', 'aa0e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440004', 5, 'Excellent service! Package arrived on time and in perfect condition.', '2024-03-15 15:00:00'),

('ee0e8400-e29b-41d4-a716-446655440001', 'aa0e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440004', 5, 'Very professional driver. Great communication throughout.', '2024-03-15 15:30:00'),

('ee0e8400-e29b-41d4-a716-446655440002', 'aa0e8400-e29b-41d4-a716-446655440000', '550e8400-e29b-41d4-a716-446655440004', 4, 'Good service overall. Tracking updates were helpful.', '2024-03-19 19:00:00'),

('ee0e8400-e29b-41d4-a716-446655440003', 'aa0e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440004', 5, 'Fast delivery and careful handling. Highly recommend!', '2024-03-15 16:00:00'),

('ee0e8400-e29b-41d4-a716-446655440004', 'aa0e8400-e29b-41d4-a716-446655440000', '550e8400-e29b-41d4-a716-446655440004', 4, 'Package is on the way. Looking forward to delivery.', '2024-03-19 20:00:00');

-- ============================================================================
-- DATA INSERTION COMPLETE
-- ============================================================================

-- Verify data inserted
SELECT 
    'users' as table_name, COUNT(*) as record_count FROM users
UNION ALL
SELECT 'trucks', COUNT(*) FROM trucks
UNION ALL
SELECT 'drivers', COUNT(*) FROM drivers
UNION ALL
SELECT 'routes', COUNT(*) FROM routes
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'shipments', COUNT(*) FROM shipments
UNION ALL
SELECT 'shipment_orders', COUNT(*) FROM shipment_orders
UNION ALL
SELECT 'tracking_events', COUNT(*) FROM tracking_events
UNION ALL
SELECT 'ai_agent_logs', COUNT(*) FROM ai_agent_logs
UNION ALL
SELECT 'notifications', COUNT(*) FROM notifications
UNION ALL
SELECT 'feedback', COUNT(*) FROM feedback
ORDER BY table_name;

-- Display demo user credentials
SELECT 
    '=== DEMO USER CREDENTIALS ===' as info
UNION ALL
SELECT '================================'
UNION ALL
SELECT 'Username: admin | Password: admin123 | Role: admin'
UNION ALL
SELECT 'Username: manager | Password: manager123 | Role: admin'
UNION ALL
SELECT 'Username: driver1 | Password: driver123 | Role: driver'
UNION ALL
SELECT 'Username: driver2 | Password: driver123 | Role: driver'
UNION ALL
SELECT 'Username: customer1 | Password: customer123 | Role: customer'
UNION ALL
SELECT '================================';

-- Made with Bob
