# Logistics Application Architecture

This document provides a comprehensive overview of the Logistics Application architecture, components, and data flows.

## Table of Contents

- [System Overview](#system-overview)
- [Component Architecture](#component-architecture)
- [Data Flow](#data-flow)
- [AI Agent Architecture](#ai-agent-architecture)
- [Infrastructure Architecture](#infrastructure-architecture)
- [Security Architecture](#security-architecture)
- [Observability Architecture](#observability-architecture)

---

## System Overview

The Logistics Application is a cloud-native, microservices-based system designed to manage logistics operations with AI-powered shipment tracking and ETA prediction.

### Key Characteristics

- **Architecture Pattern:** Microservices
- **Deployment:** Kubernetes (K3s)
- **Database:** PostgreSQL
- **AI Framework:** LangFlow + watsonx.ai
- **Observability:** Instana
- **API Gateway:** Kong/Nginx
- **Frontend:** React (SPA)
- **Backend:** FastAPI (Python)

---

## Component Architecture

### High-Level Architecture

```mermaid
graph TB
    subgraph "Client Layer"
        USER[User Browser]
        ADMIN[Admin Browser]
    end
    
    subgraph "Edge Layer"
        LB[Load Balancer]
        GW[API Gateway]
    end
    
    subgraph "Application Layer"
        FE[Frontend Service<br/>React SPA<br/>:8000]
        AUTH[Auth Service<br/>FastAPI<br/>:8001]
        ORDER[Order Service<br/>FastAPI<br/>:8002]
        SHIP[Shipment Service<br/>FastAPI<br/>:8003]
        TRACK[Tracking Service<br/>FastAPI<br/>:8004]
    end
    
    subgraph "AI Layer"
        AGENT[AI Agent Service<br/>LangFlow<br/>:8006]
        WX[watsonx.ai<br/>LLM]
    end
    
    subgraph "Data Layer"
        DB[(PostgreSQL<br/>Database)]
        CACHE[(Redis Cache)]
    end
    
    subgraph "External Services"
        WEATHER[Weather API]
        NEWS[News API]
        WM[webMethods<br/>Enterprise API]
    end
    
    subgraph "Observability"
        INST[Instana Agent]
        METRICS[Metrics Collector]
    end
    
    USER --> LB
    ADMIN --> LB
    LB --> GW
    GW --> FE
    GW --> AUTH
    GW --> ORDER
    GW --> SHIP
    GW --> TRACK
    
    FE --> AUTH
    ORDER --> AUTH
    SHIP --> AUTH
    TRACK --> AUTH
    
    ORDER --> DB
    SHIP --> DB
    TRACK --> DB
    AUTH --> DB
    
    AGENT --> SHIP
    AGENT --> WEATHER
    AGENT --> NEWS
    AGENT --> WX
    AGENT --> WM
    
    INST -.->|Monitors| AUTH
    INST -.->|Monitors| ORDER
    INST -.->|Monitors| SHIP
    INST -.->|Monitors| TRACK
    INST -.->|Monitors| AGENT
    INST --> METRICS
```

---

## Component Details

### 1. Frontend Service

**Technology:** React, Vite, TypeScript  
**Port:** 8000  
**Container:** Nginx

**Responsibilities:**
- User interface for customers and admins
- Order creation and management
- Shipment tracking visualization
- Real-time ETA updates
- Authentication flow

**Key Features:**
- Responsive design
- Real-time updates via WebSocket
- Role-based UI (User/Admin)
- Dashboard with analytics

---

### 2. Authentication Service

**Technology:** FastAPI, Python 3.11  
**Port:** 8001  
**Database:** PostgreSQL

**Responsibilities:**
- User registration and login
- JWT token generation and validation
- Role-based access control (RBAC)
- Session management

**API Endpoints:**
```
POST   /auth/register      - User registration
POST   /auth/login         - User login
POST   /auth/refresh       - Token refresh
GET    /auth/me            - Get current user
POST   /auth/logout        - User logout
GET    /health             - Health check
```

**Security:**
- Password hashing (bcrypt)
- JWT with RS256 algorithm
- Token expiration (30 min access, 7 days refresh)
- Rate limiting

---

### 3. Order Service

**Technology:** FastAPI, Python 3.11  
**Port:** 8002  
**Database:** PostgreSQL

**Responsibilities:**
- Order creation and management
- Order status tracking
- Order history
- Customer order queries

**API Endpoints:**
```
POST   /orders             - Create order
GET    /orders             - List orders
GET    /orders/{id}        - Get order details
PUT    /orders/{id}        - Update order
DELETE /orders/{id}        - Cancel order
GET    /orders/user/{id}   - Get user orders
GET    /health             - Health check
```

**Data Model:**
```python
Order:
  - id: UUID
  - user_id: UUID
  - items: JSON
  - total_amount: Decimal
  - status: Enum (pending, confirmed, shipped, delivered)
  - created_at: DateTime
  - updated_at: DateTime
```

---

### 4. Shipment Service

**Technology:** FastAPI, Python 3.11  
**Port:** 8003  
**Database:** PostgreSQL

**Responsibilities:**
- Shipment creation and management
- ETA calculation and updates
- Shipment status tracking
- Integration with AI agents

**API Endpoints:**
```
POST   /shipments          - Create shipment
GET    /shipments          - List shipments
GET    /shipments/{id}     - Get shipment details
PUT    /shipments/{id}     - Update shipment
PUT    /shipments/{id}/eta - Update ETA
GET    /shipments/order/{id} - Get order shipments
GET    /health             - Health check
```

**Data Model:**
```python
Shipment:
  - id: UUID
  - order_id: UUID
  - tracking_number: String
  - origin: String
  - destination: String
  - initial_eta: DateTime
  - current_eta: DateTime
  - status: Enum (created, in_transit, delayed, delivered)
  - carrier: String
  - created_at: DateTime
  - updated_at: DateTime
```

---

### 5. Tracking Service

**Technology:** FastAPI, Python 3.11  
**Port:** 8004  
**Database:** PostgreSQL

**Responsibilities:**
- Real-time shipment tracking
- Location updates
- Event logging
- Notification triggers

**API Endpoints:**
```
POST   /tracking           - Add tracking event
GET    /tracking/{shipment_id} - Get tracking history
GET    /tracking/latest/{shipment_id} - Get latest location
GET    /health             - Health check
```

**Data Model:**
```python
TrackingEvent:
  - id: UUID
  - shipment_id: UUID
  - location: String
  - latitude: Float
  - longitude: Float
  - status: String
  - description: String
  - timestamp: DateTime
```

---

### 6. AI Agent Service

**Technology:** LangFlow, Python, watsonx.ai  
**Port:** 8006

**Responsibilities:**
- Analyze shipment data
- Detect potential delays
- Recalculate ETAs
- Generate notifications
- Integrate with external APIs

**AI Agent Workflow:**

```mermaid
graph LR
    A[Scheduled Trigger] --> B[Fetch Active Shipments]
    B --> C[Analyze Each Shipment]
    C --> D{Delay Detected?}
    D -->|Yes| E[Fetch Weather Data]
    D -->|Yes| F[Fetch News Data]
    D -->|Yes| G[Query webMethods API]
    E --> H[LLM Analysis]
    F --> H
    G --> H
    H --> I[Calculate New ETA]
    I --> J[Update Shipment]
    J --> K[Send Notifications]
    D -->|No| L[Continue Monitoring]
```

**AI Capabilities:**
- Natural language processing for news analysis
- Weather impact assessment
- Route optimization suggestions
- Predictive delay detection
- Automated stakeholder communication

**Integration Points:**
- Weather API (OpenWeatherMap)
- News API (NewsAPI.org)
- webMethods (cost calculation)
- watsonx.ai (LLM reasoning)

---

## Data Flow

### Order Creation Flow

```mermaid
sequenceDiagram
    participant U as User
    participant FE as Frontend
    participant GW as API Gateway
    participant AUTH as Auth Service
    participant ORDER as Order Service
    participant DB as Database
    
    U->>FE: Create Order
    FE->>GW: POST /orders
    GW->>AUTH: Validate Token
    AUTH-->>GW: Token Valid
    GW->>ORDER: Create Order
    ORDER->>DB: Insert Order
    DB-->>ORDER: Order Created
    ORDER-->>GW: Order Response
    GW-->>FE: Order Confirmation
    FE-->>U: Display Confirmation
```

### Shipment Creation and AI Analysis Flow

```mermaid
sequenceDiagram
    participant A as Admin
    participant SHIP as Shipment Service
    participant DB as Database
    participant AGENT as AI Agent
    participant WX as watsonx.ai
    participant EXT as External APIs
    participant NOTIF as Notification
    
    A->>SHIP: Create Shipment
    SHIP->>DB: Insert Shipment
    DB-->>SHIP: Shipment Created
    
    Note over AGENT: Scheduled Analysis (every 15 min)
    
    AGENT->>DB: Fetch Active Shipments
    DB-->>AGENT: Shipment List
    AGENT->>EXT: Get Weather Data
    EXT-->>AGENT: Weather Info
    AGENT->>EXT: Get News Data
    EXT-->>AGENT: News Info
    AGENT->>WX: Analyze Delay Risk
    WX-->>AGENT: Risk Assessment
    
    alt Delay Detected
        AGENT->>SHIP: Update ETA
        SHIP->>DB: Update Shipment
        AGENT->>NOTIF: Send Alert
        NOTIF-->>A: Email/SMS Notification
    end
```

---

## AI Agent Architecture

### LangFlow Integration

```mermaid
graph TB
    subgraph "LangFlow Pipeline"
        INPUT[Input: Shipment Data]
        WEATHER[Weather Node]
        NEWS[News Node]
        COST[Cost API Node]
        PROMPT[Prompt Template]
        LLM[watsonx.ai LLM]
        PARSER[Output Parser]
        OUTPUT[Output: Decision]
    end
    
    INPUT --> WEATHER
    INPUT --> NEWS
    INPUT --> COST
    WEATHER --> PROMPT
    NEWS --> PROMPT
    COST --> PROMPT
    PROMPT --> LLM
    LLM --> PARSER
    PARSER --> OUTPUT
```

### AI Decision Logic

**Input Parameters:**
- Current shipment location
- Destination
- Original ETA
- Weather conditions
- Recent news (strikes, accidents, etc.)
- Historical delay patterns
- Shipment cost (from webMethods)

**Processing:**
1. Gather contextual data from multiple sources
2. Construct prompt for LLM
3. Query watsonx.ai for analysis
4. Parse LLM response
5. Calculate new ETA if needed
6. Generate notification content

**Output:**
- Updated ETA (if changed)
- Delay reason
- Confidence score
- Recommended actions
- Notification message

---

## Infrastructure Architecture

### Kubernetes Deployment

```mermaid
graph TB
    subgraph "K3s Cluster"
        subgraph "logistics namespace"
            FE_POD[Frontend Pod]
            AUTH_POD[Auth Pod]
            ORDER_POD[Order Pod]
            SHIP_POD[Shipment Pod]
            TRACK_POD[Tracking Pod]
            AGENT_POD[AI Agent Pod]
            DB_POD[PostgreSQL Pod]
        end
        
        subgraph "Services"
            FE_SVC[frontend-service]
            AUTH_SVC[auth-service]
            ORDER_SVC[order-service]
            SHIP_SVC[shipment-service]
            TRACK_SVC[tracking-service]
            AGENT_SVC[ai-agent-service]
            DB_SVC[postgres-service]
        end
        
        subgraph "Ingress"
            ING[API Gateway]
        end
        
        subgraph "instana-agent namespace"
            INST_POD[Instana Agent DaemonSet]
        end
    end
    
    ING --> FE_SVC
    ING --> AUTH_SVC
    ING --> ORDER_SVC
    ING --> SHIP_SVC
    ING --> TRACK_SVC
    
    FE_SVC --> FE_POD
    AUTH_SVC --> AUTH_POD
    ORDER_SVC --> ORDER_POD
    SHIP_SVC --> SHIP_POD
    TRACK_SVC --> TRACK_POD
    AGENT_SVC --> AGENT_POD
    DB_SVC --> DB_POD
    
    INST_POD -.->|Monitors| FE_POD
    INST_POD -.->|Monitors| AUTH_POD
    INST_POD -.->|Monitors| ORDER_POD
    INST_POD -.->|Monitors| SHIP_POD
    INST_POD -.->|Monitors| TRACK_POD
    INST_POD -.->|Monitors| AGENT_POD
```

### Resource Allocation

| Service | CPU Request | CPU Limit | Memory Request | Memory Limit | Replicas |
|---------|-------------|-----------|----------------|--------------|----------|
| Frontend | 100m | 200m | 1024Mi | 2048Mi | 1 |
| Auth | 100m | 200m | 128Mi | 256Mi | 1 |
| Order | 100m | 200m | 128Mi | 256Mi | 1 |
| Shipment | 100m | 200m | 128Mi | 256Mi | 1 |
| Tracking | 100m | 200m | 128Mi | 256Mi | 1 |
| AI Agent | 200m | 500m | 512Mi | 1024Mi | 1 |
| PostgreSQL | 200m | 500m | 512Mi | 1024Mi | 1 |

---

## Security Architecture

### Authentication Flow

```mermaid
sequenceDiagram
    participant C as Client
    participant GW as API Gateway
    participant AUTH as Auth Service
    participant SVC as Microservice
    
    C->>AUTH: POST /auth/login
    AUTH->>AUTH: Validate Credentials
    AUTH-->>C: JWT Access + Refresh Token
    
    C->>GW: Request + JWT
    GW->>AUTH: Validate JWT
    AUTH-->>GW: Token Valid + User Info
    GW->>SVC: Forward Request + User Context
    SVC-->>GW: Response
    GW-->>C: Response
```

### Security Layers

1. **Network Security:**
   - VPC isolation
   - Security groups
   - Network policies

2. **Application Security:**
   - JWT authentication
   - RBAC authorization
   - Input validation
   - SQL injection prevention

3. **Data Security:**
   - Encrypted secrets (Kubernetes Secrets)
   - TLS for data in transit
   - Database encryption at rest

4. **API Security:**
   - Rate limiting
   - CORS configuration
   - API key validation

---

## Observability Architecture

### Instana Integration

```mermaid
graph TB
    subgraph "Application"
        APP[Microservices]
        AGENT_SVC[AI Agent]
    end
    
    subgraph "Instana Agent"
        SENSOR[Sensors]
        COLLECTOR[Data Collector]
    end
    
    subgraph "Instana Backend"
        PROCESSOR[Data Processor]
        ANALYTICS[Analytics Engine]
        STORAGE[Time-Series DB]
        UI[Instana UI]
    end
    
    APP -->|Metrics| SENSOR
    APP -->|Traces| SENSOR
    APP -->|Logs| SENSOR
    AGENT_SVC -->|AI Traces| SENSOR
    
    SENSOR --> COLLECTOR
    COLLECTOR -->|Compressed Data| PROCESSOR
    PROCESSOR --> ANALYTICS
    PROCESSOR --> STORAGE
    STORAGE --> UI
    ANALYTICS --> UI
```

### Monitored Metrics

**Application Metrics:**
- Request rate
- Response time
- Error rate
- Throughput

**AI Agent Metrics:**
- Analysis duration
- LLM query latency
- External API response times
- Decision accuracy
- ETA update frequency

**Infrastructure Metrics:**
- CPU utilization
- Memory usage
- Network I/O
- Disk I/O
- Pod health

---

## Scalability Considerations

### Horizontal Scaling

Services can be scaled independently:

```bash
kubectl scale deployment order-service --replicas=3 -n logistics
```

### Database Scaling

- Read replicas for query distribution
- Connection pooling
- Query optimization

### Caching Strategy

- Redis for session data
- API response caching
- Database query caching

---

## Disaster Recovery

### Backup Strategy

- Database: Daily automated backups
- Configuration: Version controlled in Git
- Secrets: Encrypted backup in secure storage

### Recovery Procedures

1. Infrastructure: Terraform re-apply
2. Application: Kubernetes manifests re-deploy
3. Database: Restore from backup
4. Validation: Health checks and smoke tests

---

## Performance Optimization

### Database Optimization

- Indexed columns for frequent queries
- Connection pooling (max 20 connections per service)
- Query optimization with EXPLAIN ANALYZE

### API Optimization

- Response compression (gzip)
- Pagination for list endpoints
- Field filtering
- Caching headers

### AI Agent Optimization

- Batch processing of shipments
- Async external API calls
- LLM response caching
- Scheduled analysis (every 15 minutes)

---

## Technology Stack Summary

| Layer | Technology | Purpose |
|-------|-----------|---------|
| Frontend | React, Vite, TypeScript | User interface |
| API Gateway | Kong/Nginx | Request routing, rate limiting |
| Backend | FastAPI, Python 3.11 | Microservices |
| Database | PostgreSQL 15 | Data persistence |
| Cache | Redis | Session, response caching |
| AI/ML | LangFlow, watsonx.ai | Intelligent decision-making |
| Container | Docker | Application packaging |
| Orchestration | Kubernetes (K3s) | Container management |
| IaC | Terraform | Infrastructure provisioning |
| Config Mgmt | Ansible | Application deployment |
| Observability | Instana | Monitoring, tracing, analytics |
| Integration | webMethods | Enterprise API integration |

---

## Next Steps

- [Prerequisites Setup](./prerequisites.md)
- [Lab 1: Infrastructure Deployment](../Lab1-Infrastructure-Deployment/README.md)
- [Troubleshooting Guide](./troubleshooting.md)
