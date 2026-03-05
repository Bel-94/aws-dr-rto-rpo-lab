# AWS Disaster Recovery Lab – Exploring RTO/RPO Tradeoffs

This project explores real-world **Disaster Recovery (DR)** strategies on AWS by building and testing a production-style application architecture while measuring **Recovery Time Objective (RTO)** and **Recovery Point Objective (RPO)** tradeoffs.

The goal is to simulate how modern systems are designed to remain resilient during outages while understanding the architectural decisions behind recovery strategies.

This project is currently **ongoing** and will evolve through multiple phases.

---

## Project Goals

- Understand how **RTO and RPO influence architecture decisions**
- Build a **production-style application baseline**
- Deploy infrastructure using **Infrastructure as Code (Terraform)**
- Implement and compare different **Disaster Recovery strategies**
- Document real observations from testing recovery scenarios

---

## Current Progress (Phase 1 – Baseline Application)

The current phase focuses on building a **simple but realistic baseline application** that can later be used to simulate failures and recovery scenarios.

### Application Stack

- Python **Flask API**
- **PostgreSQL** database
- **Dockerized application**
- Local orchestration using **Docker Compose**

This baseline allows us to test application behavior before introducing cloud infrastructure.

---

## Current Architecture (Local Baseline)

```
Client
   │
   ▼
Flask API (Docker)
   │
   ▼
PostgreSQL Database (Docker)
```

The API exposes endpoints for:

- Health checks
- Creating items
- Listing items

This allows us to simulate **stateful workloads**, which are critical when testing RPO and RTO.

---

## Project Structure

```
dr-rto-rpo-terraform/

app/
  app.py
  requirements.txt
  Dockerfile
  .dockerignore

local/
  docker-compose.yml
  init.sql

infra/   # Terraform infrastructure (coming next)

README.md
```

---

## Running the Project Locally

### Start the services

```
cd local
docker compose up --build
```

### Health check

```
curl http://localhost:3000/health
```

### Create item

```
curl -X POST http://localhost:3000/items \
-H "Content-Type: application/json" \
-d '{"name":"first item"}'
```

### List items

```
curl http://localhost:3000/items
```

---

## Why This Baseline Matters

Before implementing Disaster Recovery strategies, it's important to establish a **controlled baseline environment**.

This application will later be used to test:

- Database recovery scenarios
- Region failover
- Infrastructure rebuild with Terraform
- Data loss scenarios affecting RPO
- Downtime measurement affecting RTO

---

## Next Steps (Upcoming Phases)

### Phase 2 — Infrastructure as Code (Terraform)

Provision AWS infrastructure:

- VPC
- Public and private subnets
- Security groups
- Application load balancer
- ECS service
- RDS PostgreSQL database

---

### Phase 3 — Observability

Introduce monitoring and logging:

- CloudWatch logs
- health checks
- application metrics

---

### Phase 4 — Disaster Recovery Scenarios

Test and document:

- RDS backup and restore
- Multi-AZ database failover
- Multi-region replication
- DNS failover strategies
- Infrastructure rebuild using Terraform

Each experiment will include **measured RTO and RPO results**.

---

## Learning Focus

This project is helping me deepen my understanding of:

- Cloud architecture
- Infrastructure as Code
- Containerized applications
- AWS networking
- Disaster recovery planning

---

## Author

Belinda Ntinyari

AWS Cloud Engineer  
Building production-style cloud systems and documenting the learning journey.

## Connect With Me

LinkedIn:  
https://www.linkedin.com/in/belinda-ntinyari

Medium:  
https://medium.com/@ntinyaribelinda