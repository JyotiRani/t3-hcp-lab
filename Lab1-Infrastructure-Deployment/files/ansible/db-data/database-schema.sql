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


-- Drop views first (they depend on tables)
DROP VIEW IF EXISTS recent_agent_tasks CASCADE;
DROP VIEW IF EXISTS active_news_events CASCADE;
DROP VIEW IF EXISTS active_weather_scenarios CASCADE;

-- Drop tables in reverse dependency order
DROP TABLE IF EXISTS agent_analysis_logs CASCADE;
DROP TABLE IF EXISTS agent_tasks CASCADE;
DROP TABLE IF EXISTS route_analysis CASCADE;
DROP TABLE IF EXISTS news_events CASCADE;
DROP TABLE IF EXISTS weather_data CASCADE;


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
-- 1. WEATHER DATA TABLE
-- ============================================================================
-- Stores weather information for different locations and scenarios
CREATE TABLE IF NOT EXISTS weather_data (
    weather_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    location VARCHAR(255) NOT NULL,
    scenario VARCHAR(50) NOT NULL CHECK (scenario IN ('clear', 'rain', 'snow', 'fog', 'storm', 'heat', 'traffic')),
    temperature VARCHAR(20),
    conditions VARCHAR(100),
    severity VARCHAR(20) CHECK (severity IN ('low', 'medium', 'high')),
    delay_minutes INTEGER DEFAULT 0,
    summary TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT true
);

CREATE INDEX idx_weather_location ON weather_data(location);
CREATE INDEX idx_weather_scenario ON weather_data(scenario);
CREATE INDEX idx_weather_severity ON weather_data(severity);

COMMENT ON TABLE weather_data IS 'Stores weather scenarios and their impact on shipments';
COMMENT ON COLUMN weather_data.scenario IS 'Weather scenario type: clear, rain, snow, fog, storm, heat, traffic';
COMMENT ON COLUMN weather_data.severity IS 'Impact severity: low, medium, high';

-- ============================================================================
-- 2. NEWS EVENTS TABLE
-- ============================================================================
-- Stores news and traffic events affecting logistics
CREATE TABLE IF NOT EXISTS news_events (
    news_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    location VARCHAR(255) NOT NULL,
    title VARCHAR(500) NOT NULL,
    description TEXT,
    impact VARCHAR(20) CHECK (impact IN ('low', 'medium', 'high')),
    delay_minutes INTEGER DEFAULT 0,
    source VARCHAR(255),
    event_date DATE,
    event_type VARCHAR(50) CHECK (event_type IN ('traffic', 'construction', 'accident', 'weather', 'strike', 'event', 'other')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT true
);

CREATE INDEX idx_news_location ON news_events(location);
CREATE INDEX idx_news_impact ON news_events(impact);
CREATE INDEX idx_news_event_date ON news_events(event_date);
CREATE INDEX idx_news_active ON news_events(is_active);

COMMENT ON TABLE news_events IS 'Stores news and traffic events that may affect shipment delivery';
COMMENT ON COLUMN news_events.impact IS 'Impact level on logistics: low, medium, high';
COMMENT ON COLUMN news_events.event_type IS 'Type of event: traffic, construction, accident, weather, strike, event, other';

-- ============================================================================
-- 3. ROUTE ANALYSIS TABLE
-- ============================================================================
-- Stores route information and analysis
CREATE TABLE IF NOT EXISTS route_analysis (
    route_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    origin VARCHAR(255) NOT NULL,
    destination VARCHAR(255) NOT NULL,
    waypoints JSONB,
    total_distance_km DECIMAL(10, 2),
    estimated_duration_minutes INTEGER,
    route_hash VARCHAR(64) UNIQUE, -- Hash of origin+destination for quick lookup
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_route_origin ON route_analysis(origin);
CREATE INDEX idx_route_destination ON route_analysis(destination);
CREATE INDEX idx_route_hash ON route_analysis(route_hash);

COMMENT ON TABLE route_analysis IS 'Stores route information for shipment analysis';
COMMENT ON COLUMN route_analysis.waypoints IS 'JSON array of intermediate locations along the route';
COMMENT ON COLUMN route_analysis.route_hash IS 'MD5 hash of origin+destination for caching';

-- ============================================================================
-- 4. AGENT TASKS TABLE
-- ============================================================================
-- Tracks AI agent task execution (Langflow workflows)
CREATE TABLE IF NOT EXISTS agent_tasks (
    id SERIAL PRIMARY KEY,
    task_type VARCHAR(50) NOT NULL CHECK (task_type IN ('weather_analysis', 'news_analysis', 'eta_calculation', 'full_analysis')),
    agent_name VARCHAR(100) NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('pending', 'running', 'completed', 'failed', 'cancelled')) DEFAULT 'pending',
    priority INTEGER DEFAULT 5,
    shipment_id UUID REFERENCES shipments(shipment_id) ON DELETE CASCADE,
    
    -- Langflow integration (optional)
    langflow_flow_id VARCHAR(255),
    langflow_session_id VARCHAR(255),
    
    -- Task data
    input_data JSONB,
    output_data JSONB,
    error_message TEXT,
    
    -- AI model info
    model_used VARCHAR(100),
    tokens_used INTEGER,
    
    -- Timing
    started_at TIMESTAMP,
    completed_at TIMESTAMP,
    execution_time_ms INTEGER,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_agent_tasks_shipment ON agent_tasks(shipment_id);
CREATE INDEX idx_agent_tasks_type ON agent_tasks(task_type);
CREATE INDEX idx_agent_tasks_status ON agent_tasks(status);
CREATE INDEX idx_agent_tasks_created ON agent_tasks(created_at);

COMMENT ON TABLE agent_tasks IS 'Tracks AI agent task execution and Langflow workflow runs';
COMMENT ON COLUMN agent_tasks.langflow_flow_id IS 'Langflow workflow ID that was executed';
COMMENT ON COLUMN agent_tasks.langflow_session_id IS 'Langflow session ID for tracking';

-- ============================================================================
-- 5. AGENT ANALYSIS LOGS TABLE (Enhanced)
-- ============================================================================
-- Stores complete analysis results from AI agents
CREATE TABLE IF NOT EXISTS agent_analysis_logs (
    log_id SERIAL PRIMARY KEY,
    shipment_id UUID REFERENCES shipments(shipment_id) ON DELETE CASCADE,
    task_id INTEGER REFERENCES agent_tasks(id) ON DELETE SET NULL,
    analysis_type VARCHAR(50) NOT NULL CHECK (analysis_type IN ('weather_check', 'news_check', 'eta_calculation', 'full_analysis')),
    
    -- Weather data (references weather_data table)
    weather_data_ids UUID[],
    weather_summary TEXT,
    weather_severity VARCHAR(20),
    weather_delay_minutes INTEGER DEFAULT 0,
    
    -- News data (references news_events table)
    news_event_ids UUID[],
    news_items JSONB,
    news_impact_level VARCHAR(20),
    news_delay_minutes INTEGER DEFAULT 0,
    
    -- ETA calculation
    old_eta TIMESTAMP,
    new_eta TIMESTAMP,
    total_delay_minutes INTEGER,
    
    -- AI reasoning (from watsonx.ai)
    reasoning TEXT,
    confidence_score DECIMAL(5, 4),
    ai_model_used VARCHAR(100),
    prompt_used TEXT,
    
    -- Metadata
    use_dummy_data BOOLEAN DEFAULT false,
    processing_time_ms INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_agent_analysis_shipment ON agent_analysis_logs(shipment_id);
CREATE INDEX idx_agent_analysis_task ON agent_analysis_logs(task_id);
CREATE INDEX idx_agent_analysis_type ON agent_analysis_logs(analysis_type);
CREATE INDEX idx_agent_analysis_created ON agent_analysis_logs(created_at);

COMMENT ON TABLE agent_analysis_logs IS 'Stores detailed analysis logs from the multi-agent AI system';
COMMENT ON COLUMN agent_analysis_logs.weather_data_ids IS 'Array of weather_data UUIDs used in analysis';
COMMENT ON COLUMN agent_analysis_logs.news_event_ids IS 'Array of news_events UUIDs used in analysis';
COMMENT ON COLUMN agent_analysis_logs.reasoning IS 'AI-generated reasoning from watsonx.ai LLM';
COMMENT ON COLUMN agent_analysis_logs.ai_model_used IS 'watsonx.ai model ID used for reasoning';

-- ============================================================================
-- VIEWS FOR EASY QUERYING
-- ============================================================================

-- View for active weather scenarios
CREATE OR REPLACE VIEW active_weather_scenarios AS
SELECT 
    location,
    scenario,
    severity,
    delay_minutes,
    summary
FROM weather_data
WHERE is_active = true
ORDER BY location, scenario;

-- View for active news events
CREATE OR REPLACE VIEW active_news_events AS
SELECT 
    location,
    title,
    impact,
    delay_minutes,
    event_type,
    event_date
FROM news_events
WHERE is_active = true
ORDER BY event_date DESC, location;

-- View for recent agent tasks
CREATE OR REPLACE VIEW recent_agent_tasks AS
SELECT
    t.id as task_id,
    t.shipment_id,
    t.task_type,
    t.agent_name,
    t.status,
    t.execution_time_ms,
    t.created_at,
    s.shipment_number
FROM agent_tasks t
LEFT JOIN shipments s ON t.shipment_id = s.shipment_id
ORDER BY t.created_at DESC
LIMIT 100;

-- ============================================================================
-- GRANTS (adjust user as needed)
-- ============================================================================

GRANT SELECT, INSERT, UPDATE, DELETE ON weather_data TO logistics_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON news_events TO logistics_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON route_analysis TO logistics_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON agent_tasks TO logistics_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON agent_analysis_logs TO logistics_user;

GRANT SELECT ON active_weather_scenarios TO logistics_user;
GRANT SELECT ON active_news_events TO logistics_user;
GRANT SELECT ON recent_agent_tasks TO logistics_user;


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
