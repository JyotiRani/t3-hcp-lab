-- ============================================================================
-- Logistics Application - Database Schema
-- ============================================================================
-- Description: Complete database schema for logistics demo application
-- Version: 1.0
-- Date: 2026-03-13
-- ============================================================================

-- -- Drop existing tables if they exist (for clean setup)
DROP TABLE IF EXISTS feedback CASCADE;
DROP TABLE IF EXISTS notifications CASCADE;
DROP TABLE IF EXISTS ai_agent_logs CASCADE;
DROP TABLE IF EXISTS tracking_events CASCADE;
DROP TABLE IF EXISTS shipment_orders CASCADE;
DROP TABLE IF EXISTS shipments CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS routes CASCADE;
DROP TABLE IF EXISTS drivers CASCADE;
DROP TABLE IF EXISTS trucks CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- -- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- 1. USERS TABLE
-- ============================================================================
CREATE TABLE users (
    user_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    role VARCHAR(20) NOT NULL DEFAULT 'customer' 
        CHECK (role IN ('admin', 'driver', 'customer')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT true
);

-- Indexes for users table
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);

-- ============================================================================
-- 2. TRUCKS TABLE
-- ============================================================================
CREATE TABLE trucks (
    truck_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    truck_number VARCHAR(50) UNIQUE NOT NULL,
    license_plate VARCHAR(50) UNIQUE NOT NULL,
    truck_type VARCHAR(50) NOT NULL,
    capacity_kg DECIMAL(10, 2) NOT NULL,
    current_location TEXT,
    status VARCHAR(50) DEFAULT 'available',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for trucks table
CREATE INDEX idx_trucks_status ON trucks(status);
CREATE INDEX idx_trucks_number ON trucks(truck_number);

-- ============================================================================
-- 3. DRIVERS TABLE
-- ============================================================================
CREATE TABLE drivers (
    driver_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    license_number VARCHAR(50) UNIQUE NOT NULL,
    license_expiry DATE NOT NULL,
    current_truck_id UUID REFERENCES trucks(truck_id) ON DELETE SET NULL,
    status VARCHAR(50) DEFAULT 'available',
    rating DECIMAL(3, 2) DEFAULT 5.00,
    total_deliveries INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for drivers table
CREATE INDEX idx_drivers_user ON drivers(user_id);
CREATE INDEX idx_drivers_status ON drivers(status);
CREATE INDEX idx_drivers_truck ON drivers(current_truck_id);

-- ============================================================================
-- 4. ROUTES TABLE
-- ============================================================================
CREATE TABLE routes (
    route_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    route_name VARCHAR(255),
    start_location TEXT NOT NULL,
    end_location TEXT NOT NULL,
    waypoints TEXT[],
    estimated_distance_km DECIMAL(10, 2),
    estimated_duration_mins INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for routes table
CREATE INDEX idx_routes_name ON routes(route_name);

-- ============================================================================
-- 5. ORDERS TABLE
-- ============================================================================
CREATE TABLE orders (
    order_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    order_number VARCHAR(50) UNIQUE NOT NULL,
    pickup_location TEXT NOT NULL,
    delivery_location TEXT NOT NULL,
    package_weight DECIMAL(10, 2),
    package_dimensions JSONB,
    status VARCHAR(50) NOT NULL DEFAULT 'pending',
    priority VARCHAR(20) DEFAULT 'normal',
    special_instructions TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for orders table
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_number ON orders(order_number);

-- ============================================================================
-- 6. SHIPMENTS TABLE
-- ============================================================================
CREATE TABLE shipments (
    shipment_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    shipment_number VARCHAR(50) UNIQUE NOT NULL,
    truck_id UUID NOT NULL REFERENCES trucks(truck_id) ON DELETE RESTRICT,
    driver_id UUID NOT NULL REFERENCES drivers(driver_id) ON DELETE RESTRICT,
    route_id UUID REFERENCES routes(route_id) ON DELETE SET NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'pending',
    estimated_delivery TIMESTAMP,
    actual_delivery TIMESTAMP,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for shipments table
CREATE INDEX idx_shipments_truck ON shipments(truck_id);
CREATE INDEX idx_shipments_driver ON shipments(driver_id);
CREATE INDEX idx_shipments_route ON shipments(route_id);
CREATE INDEX idx_shipments_status ON shipments(status);
CREATE INDEX idx_shipments_number ON shipments(shipment_number);

-- ============================================================================
-- 7. SHIPMENT_ORDERS TABLE (Many-to-Many)
-- ============================================================================
CREATE TABLE shipment_orders (
    shipment_id UUID NOT NULL REFERENCES shipments(shipment_id) ON DELETE CASCADE,
    order_id UUID NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    sequence_number INTEGER,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (shipment_id, order_id)
);

-- Indexes for shipment_orders table
CREATE INDEX idx_shipment_orders_shipment ON shipment_orders(shipment_id);
CREATE INDEX idx_shipment_orders_order ON shipment_orders(order_id);

-- ============================================================================
-- 8. TRACKING_EVENTS TABLE
-- ============================================================================
CREATE TABLE tracking_events (
    event_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    shipment_id UUID NOT NULL REFERENCES shipments(shipment_id) ON DELETE CASCADE,
    event_type VARCHAR(50) NOT NULL,
    location TEXT,
    description TEXT,
    created_by UUID,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for tracking_events table
CREATE INDEX idx_tracking_shipment ON tracking_events(shipment_id);
CREATE INDEX idx_tracking_type ON tracking_events(event_type);
CREATE INDEX idx_tracking_created_at ON tracking_events(created_at);

-- ============================================================================
-- 9. AI_AGENT_LOGS TABLE
-- ============================================================================
CREATE TABLE ai_agent_logs (
    log_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    shipment_id UUID REFERENCES shipments(shipment_id) ON DELETE CASCADE,
    agent_type VARCHAR(50) NOT NULL 
        CHECK (agent_type IN ('delay_detection', 'eta_update', 'delivery_notification')),
    input_data JSONB,
    output_data JSONB,
    decision TEXT,
    confidence_score DECIMAL(5, 4),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for ai_agent_logs table
CREATE INDEX idx_ai_logs_shipment ON ai_agent_logs(shipment_id);
CREATE INDEX idx_ai_logs_type ON ai_agent_logs(agent_type);
CREATE INDEX idx_ai_logs_created_at ON ai_agent_logs(created_at);

-- ============================================================================
-- 10. NOTIFICATIONS TABLE
-- ============================================================================
CREATE TABLE notifications (
    notification_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    shipment_id UUID REFERENCES shipments(shipment_id) ON DELETE CASCADE,
    notification_type VARCHAR(50) NOT NULL 
        CHECK (notification_type IN ('order_created', 'shipment_assigned', 'in_transit', 
                                      'delivered', 'delayed', 'cancelled')),
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    email_sent BOOLEAN DEFAULT false,
    email_sent_at TIMESTAMP,
    is_read BOOLEAN DEFAULT false,
    read_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for notifications table
CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_shipment ON notifications(shipment_id);
CREATE INDEX idx_notifications_type ON notifications(notification_type);
CREATE INDEX idx_notifications_read ON notifications(is_read);

-- ============================================================================
-- 11. FEEDBACK TABLE
-- ============================================================================
CREATE TABLE feedback (
    feedback_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    shipment_id UUID NOT NULL REFERENCES shipments(shipment_id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_by UUID ,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for feedback table
CREATE INDEX idx_feedback_shipment ON feedback(shipment_id);
CREATE INDEX idx_feedback_user ON feedback(user_id);
CREATE INDEX idx_feedback_rating ON feedback(rating);

-- ============================================================================
-- SCHEMA CREATION COMPLETE
-- ============================================================================

-- Verify tables created
SELECT 
    table_name,
    (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = t.table_name) as column_count
FROM information_schema.tables t
WHERE table_schema = 'public' 
    AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- Made with Bob
