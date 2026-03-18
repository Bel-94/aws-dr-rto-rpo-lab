# AWS Disaster Recovery Lab – Exploring RTO/RPO Tradeoffs

This project explores real-world **Disaster Recovery (DR)** strategies on AWS by building and testing a production-style application architecture while measuring **Recovery Time Objective (RTO)** and **Recovery Point Objective (RPO)** tradeoffs.

The goal is to simulate how modern systems are designed to remain resilient during outages while understanding the architectural decisions behind recovery strategies.

This project is now **complete**. All four disaster recovery strategies have been implemented, simulated, and documented.

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

### Phase 2 — Infrastructure as Code (Terraform)

In this phase, the application was deployed to **AWS using Terraform**, transforming the local baseline into a **production-style cloud architecture**.

All infrastructure is provisioned using **Infrastructure as Code (IaC)** to ensure the environment is **reproducible, version controlled, and easy to rebuild during disaster recovery scenarios**.

---

## Infrastructure Components

The following AWS resources were provisioned using Terraform.

### Networking

- **VPC** to isolate the application network
- **Public subnets** for internet-facing components
- **Private subnets** for application and database layers
- **Internet Gateway** to allow inbound internet traffic
- **Route tables** to control network traffic between layers

This setup follows a common cloud security pattern where sensitive resources remain inside **private networks**.

---

### Security

Security groups were configured to enforce **least privilege access**:

**ALB Security Group**
- Allows inbound HTTP traffic from the internet

**Application Security Group**
- Allows traffic only from the load balancer

**Database Security Group**
- Allows PostgreSQL access only from the application layer

This ensures the **database is never publicly accessible**.

---

### Load Balancing

An **Application Load Balancer (ALB)** was deployed to:

- distribute incoming traffic to the application containers
- provide health checks
- serve as the public entry point to the system

Health checks monitor the API endpoint:

```bash
/health
```

This allows the load balancer to automatically detect unhealthy containers.

---

### Containerized Application

The application is deployed using **Amazon ECS with AWS Fargate**, which allows running containers without managing servers.

Key components include:

- **ECS Cluster**
- **Task Definition**
- **Fargate Service**
- **Application container running the Flask API**

The Docker image is stored in **Amazon Elastic Container Registry (ECR)**.

This setup provides a **serverless container platform** where AWS manages compute capacity and container orchestration.

---

### Database Layer

The backend database runs on **Amazon RDS for PostgreSQL**.

Key characteristics:

- deployed in **private subnets**
- accessible only from the application containers
- supports automated backups
- designed to support later **disaster recovery experiments**

This database stores the **stateful data** used for measuring **Recovery Point Objective (RPO)** during failure simulations.

---

## Resulting Architecture (AWS)

The deployed cloud architecture now follows a **three-tier pattern**:

```bash
Internet
│
▼
Application Load Balancer
│
▼
ECS Fargate Service (Flask API containers)
│
▼
Amazon RDS PostgreSQL
```

![Architecture Diagram](images/baseline-architecture.png)


This architecture resembles real-world production systems and provides the foundation for testing **disaster recovery scenarios**.

---

## Why Terraform Was Used

Terraform enables:

- **Version-controlled infrastructure**
- **Automated environment rebuilds**
- **Consistent deployments**
- **Faster disaster recovery testing**

In later phases, this will allow entire environments to be **destroyed and recreated to simulate recovery scenarios** and measure **actual RTO values**.

---

## Outcome of Phase 2

At the end of this phase:

- The application runs on **AWS ECS Fargate**
- Traffic flows through an **Application Load Balancer**
- Data is stored in **Amazon RDS PostgreSQL**
- Infrastructure can be recreated **fully using Terraform**

The system is now ready for **observability and disaster recovery experiments**.

---

### Phase 3 — Observability

In this phase, observability is introduced to better understand how the system behaves in production and during failure scenarios.

Observability is critical for **disaster recovery experiments**, because it allows us to measure system health, detect failures quickly, and observe how long recovery processes take.

The focus in this phase is on **logging, monitoring, and health visibility** using AWS-native tools.

---

## CloudWatch Logs

Application logs from the ECS containers are sent to **Amazon CloudWatch Logs**.

This allows us to:

- monitor application behavior in real time
- troubleshoot errors during deployment
- inspect logs when simulating failures
- verify successful API requests and database operations

CloudWatch provides a centralized logging system where logs from containers can be searched and analyzed.

![CloudWatch Logs from ECS container](images/ecs-logs.jpeg)


---

## Health Checks

Health checks ensure that the application is **responding correctly** and help detect failures automatically.

The **Application Load Balancer (ALB)** continuously checks the API endpoint:

If the container stops responding or returns an unhealthy status:

- the load balancer will mark the task as **unhealthy**
- ECS can automatically replace the failing container

This mechanism is essential for maintaining **high availability** in containerized workloads.

![ALB Target Group Health Check (Healthy)](images/alb-health-status.png)

---

## Application Metrics

Metrics provide insight into the performance and behavior of the system.

Using **CloudWatch metrics**, we can monitor:

- request traffic through the load balancer
- container health and task status
- system availability
- potential error spikes

These metrics will be especially useful in later phases when measuring **Recovery Time Objective (RTO)** during simulated outages.

![CloudWatch Metrics graph](images/cloudwatch-metrics.jpeg)

---

## Why Observability Matters for Disaster Recovery

Observability enables us to measure the effectiveness of disaster recovery strategies.

By combining:

- logs
- metrics
- health checks

we can accurately determine:

- how quickly failures are detected
- how long systems take to recover
- whether any data loss occurred

This information will be used in later phases to evaluate **RTO and RPO tradeoffs** during disaster recovery simulations.

---
##### **You need a second region for the disaster recovery to work, and hence:**
---

## Multi-Region Deployment (Disaster Recovery Expansion)

To extend the disaster recovery capabilities of this architecture, a **second AWS region (Disaster Recovery region)** was introduced.

This allows the system to support **regional failover scenarios**, which are critical for minimizing downtime in case the primary region becomes unavailable.

---

### Regions Used

- **Primary Region:** us-east-1  
- **Disaster Recovery Region:** us-west-2  

---

### Implementation Approach

The multi-region setup was implemented using **Terraform provider aliases**, enabling infrastructure deployment across multiple regions from the same codebase.

```hcl
provider "aws" {
  alias  = "primary"
  region = "us-east-1"
}

provider "aws" {
  alias  = "dr"
  region = "us-west-2"
}
```

---
### A dedicated DR module was created to define all resources in the secondary region:

```hcl
module "dr" {
  source = "./dr"

  providers = {
    aws = aws.dr
  }
}
```

---

### DR Region Infrastructure

The following components were successfully deployed in the DR region:

- VPC with public and private subnets  
- Internet Gateway and route tables  
- Security groups (ALB, application, database)  
- Application Load Balancer  
- ECS Cluster and Fargate service  
- RDS PostgreSQL instance (restored from snapshot)  
- CloudWatch log group  

This mirrors the primary region setup and prepares the system for **failover testing**.

---

### Key Outcome

- Infrastructure is now running in **two regions**  
- The system is **disaster recovery ready at the infrastructure level**  
- Foundation established for:
  - failover simulations  
  - RTO (Recovery Time Objective) measurement  
  - RPO (Recovery Point Objective) evaluation  

---

### Key Learning

Implementing multi-region infrastructure highlighted the importance of:

- Correct use of **Terraform provider aliases**  
- Proper **module-to-provider mapping**  
- Understanding how **Terraform state interacts with provider configurations**

### Phase 4 — Disaster Recovery Scenarios

#### Strategy 1: Backup and Restore

This is the simplest and most cost-effective DR strategy. The system is recovered by restoring a database snapshot in the DR region and redeploying the application.

---

## Simulation Steps

1. Inserted pre-disaster data into primary RDS (us-east-1)
2. Took a manual RDS snapshot: `dr-rto-test-snapshot`
3. Inserted post-snapshot items to simulate data that would be lost
4. Scaled primary ECS service to 0 — simulating a regional disaster
5. Copied snapshot to us-west-2: `dr-rto-test-copy`
6. Restored new RDS instance from snapshot in us-west-2
7. Registered new ECS task definition pointing to restored RDS
8. Updated DR ECS service to use new task definition
9. Verified DR ALB returned pre-disaster data

---

## Recovery Verification

After recovery, the DR endpoint returned:

```json
[[2,"pre-disaster-item-2"],[1,"pre-disaster-item-1"]]
```

This confirmed:
- Pre-disaster data was successfully recovered 
- Post-snapshot data was lost as expected with this strategy 

---

## RTO and RPO Results

| Metric | Value | Notes |
|--------|-------|-------|
| **RTO** | ~30–45 minutes | Snapshot copy + RDS restore + ECS redeployment |
| **RPO** | Time since last snapshot | Data inserted after snapshot was permanently lost |

---

## Recovery Breakdown

| Step | Approximate Duration |
|------|---------------------|
| Snapshot copy (us-east-1 → us-west-2) | ~5–10 min |
| RDS restore from snapshot | ~15–20 min |
| ECS task definition update + redeployment | ~10–15 min |
| **Total active RTO** | **~30–45 min** |

---

## Key Observations

- Backup and Restore has the **highest RTO** of all DR strategies. Recovery requires manual steps and waiting for RDS to restore
- **RPO is directly tied to snapshot frequency** — the less frequent the snapshots, the more data is at risk
- This strategy is best suited for **non-critical workloads** where some downtime and data loss is acceptable
- All recovery steps were performed manually in this simulation; in production, these would be **automated using scripts or AWS Backup**

---

#### Strategy 2: Pilot Light

The Pilot Light strategy keeps a minimal version of the environment running in the DR region at all times. A **read replica** of the primary database continuously replicates data, so when disaster strikes, recovery only requires promoting the replica and scaling up the application. No snapshot copy or RDS restore needed.

This results in a significantly lower RTO and near-zero RPO compared to Backup and Restore.

---

## Simulation Steps

1. Confirmed primary RDS and ECS running in us-east-1
2. Inserted pilot light baseline data (items 1–4) into primary RDS
3. Created a cross-region read replica `dr-pilot-light-replica` in us-west-2
4. Scaled DR ECS service to 0 — establishing pilot light state
5. Inserted pilot light items (id:5, id:6) into primary while replica was replicating
6. Scaled primary ECS to 0 — simulating a regional disaster
7. Promoted read replica to standalone RDS instance in us-west-2
8. Registered new ECS task definition (`:6`) pointing to promoted replica endpoint
9. Updated DR ECS service network configuration to use public subnets with `assignPublicIp=ENABLED`
10. Verified DR ALB returned all data including pilot light items

---

## Recovery Verification

After recovery, the DR endpoint returned:

```json
[[6,"pilot-light-item-2"],[5,"pilot-light-item-1"],[4,"post-snapshot-lost-item-2"],[3,"post-snapshot-lost-item-1"],[2,"pre-disaster-item-2"],[1,"pre-disaster-item-1"]]
```

This confirmed:
- All 6 items recovered, including data inserted after the replica was created 
- Zero data loss — continuous replication captured everything 
- RPO = 0 

---

## RTO and RPO Results

| Metric | Value | Notes |
|--------|-------|-------|
| **RTO** | ~15–30 minutes | Replica promotion + ECS redeployment only — no snapshot copy or RDS restore |
| **RPO** | ~0 | Read replica was continuously in sync with primary |

---

## Recovery Breakdown

| Step | Approximate Duration |
|------|---------------------|
| Read replica creation (pre-provisioned) | Already running |
| Replica promotion to standalone DB | ~2–3 min |
| ECS task definition update + redeployment | ~5–10 min |
| Networking fix (assignPublicIp) + redeployment | ~5–10 min |
| **Total estimated RTO** | **~15–30 min** |

---

## Key Observations

- Pilot Light has a **significantly lower RTO** than Backup and Restore. The replica is already running, so no time is spent waiting for an RDS restore
- **RPO is effectively zero** — the read replica replicates continuously, so no data is lost at the point of failure
- The main networking challenge was that the promoted replica landed in the **default VPC**, while ECS tasks ran in the **Terraform DR VPC** — resolved by moving ECS tasks to public subnets with `assignPublicIp=ENABLED`
- In production, replica promotion and ECS redeployment would be **automated**, reducing RTO further
- Higher cost than Backup and Restore due to the **always-on read replica**

---

## Strategy Comparison So Far

| Strategy | RTO | RPO | Cost | Operational Effort | Best For |
|----------|-----|-----|------|--------------------|----------|
| Backup and Restore | ~30–45 min | Time since last snapshot | Lowest | High — manual snapshot, restore, and redeployment | Non-critical workloads |
| Pilot Light | ~15–30 min | ~0 | Medium | Medium — replica promotion and task definition update required | Moderate criticality workloads |

---

#### Strategy 3: Warm Standby

The Warm Standby strategy keeps a **fully functional but scaled-down version** of the application running in the DR region at all times. Unlike Pilot Light, both the application and database are already running. Recovery only requires **scaling up** the existing environment.

This results in the lowest RTO of manual DR strategies and zero RPO.

---

## Simulation Steps

1. Confirmed primary RDS and ECS running in us-east-1
2. Inserted warm standby baseline data (items 7–8) into primary RDS
3. Created a cross-region read replica `dr-warm-standby-replica` in us-west-2
4. Promoted replica to standalone DB — DR database is now writable and independent
5. Registered new ECS task definition (`:8`) pointing to promoted replica endpoint
6. Scaled DR ECS to 1 — warm standby state established (app running at reduced capacity)
7. Verified DR ALB was serving all 8 items — warm standby confirmed healthy
8. Scaled primary ECS to 0 — simulating a regional disaster
9. Scaled DR ECS from 1 to 2 — scaling up to full production capacity
10. Verified DR ALB returned all data at full capacity

---

## Recovery Verification

After scaling up, the DR endpoint returned:

```json
[[8,"warm-standby-item-2"],[7,"warm-standby-item-1"],[6,"pilot-light-item-2"],[5,"pilot-light-item-1"],[4,"post-snapshot-lost-item-2"],[3,"post-snapshot-lost-item-1"],[2,"pre-disaster-item-2"],[1,"pre-disaster-item-1"]]
```

This confirmed:
- All 8 items recovered — zero data loss 
- RPO = 0 — DB was already promoted and in sync 
- Recovery required only a single scale-up command 

---

## RTO and RPO Results

| Metric | Value | Notes |
|--------|-------|-------|
| **RTO** | ~2–5 minutes | Only ECS scale-up needed — DB and app already running |
| **RPO** | ~0 | Standalone DB was already promoted and fully synced |

---

## Recovery Breakdown

| Step | Approximate Duration |
|------|---------------------|
| Read replica creation + promotion (pre-provisioned) | Already running |
| ECS scale-up from 1 → 2 tasks | ~2–5 min |
| **Total active RTO** | **~2–5 min** |

---

## Key Observations

- Warm Standby has the **lowest RTO** of all manual DR strategies. The environment is already running, recovery is just a scale-up
- **RPO is zero** — the DB was promoted from a live replica before the disaster, so no data was lost
- The key difference from Pilot Light is that **no promotion or task definition update is needed during recovery** — everything is pre-configured and running
- Higher cost than Pilot Light due to the **always-on promoted DB and running ECS tasks**
- In production, the scale-up step would be **automated via CloudWatch alarms or Route 53 health checks**, reducing RTO to near zero

---

## Strategy Comparison So Far

| Strategy | RTO | RPO | Cost | Operational Effort | Best For |
|----------|-----|-----|------|--------------------|----------|
| Backup and Restore | ~30–45 min | Time since last snapshot | Lowest | High — manual snapshot, restore, and redeployment | Non-critical workloads |
| Pilot Light | ~15–30 min | ~0 | Medium | Medium — replica promotion and task definition update required | Moderate criticality workloads |
| Warm Standby | ~2–5 min | ~0 | Higher | Low — single scale-up command | Business-critical workloads |

---

#### Strategy 4: Multi-Site Active/Active

The Multi-Site Active/Active strategy runs **fully independent application and database stacks in both regions simultaneously**. Traffic is distributed across both regions using **Route 53 weighted routing with health checks**. When one region fails, Route 53 automatically removes it from DNS and routes 100% of traffic to the surviving region, with no manual intervention required.

This is the highest availability DR strategy, with the lowest possible RTO.

---

## Architecture

```
Internet
│
▼
Route 53 (Weighted Routing + Health Checks)
├── 50% → Primary ALB (us-east-1)
└── 50% → DR ALB (us-west-2)
```

Both regions run independent:
- ECS Fargate services
- RDS PostgreSQL instances
- Application Load Balancers

---

## Simulation Steps

1. Confirmed both primary (us-east-1) and DR (us-west-2) ECS services running at 2 tasks each
2. Created Route 53 public hosted zone `dr-lab.internal`
3. Created two weighted CNAME records (50/50) for `app.dr-lab.internal` — one per ALB — each associated with a Route 53 health check
4. Seeded DR region independently: `active-active-dr-item-1`, `active-active-dr-item-2`
5. Seeded primary region independently: `active-active-primary-item-1`, `active-active-primary-item-2`
6. Confirmed both regions accepting writes simultaneously — active/active state established
7. Scaled primary ECS to 0 — simulating a regional disaster
8. Observed Route 53 health check transition: all 16 global checkers reported `Failure` within ~60 seconds
9. Verified DR ALB continued serving traffic with no manual intervention
10. Scaled primary ECS back to 2 — Route 53 health checks returned `Success` and primary was automatically reintroduced into rotation

---

## Recovery Verification

During primary failure, the DR endpoint returned:

```json
[[2,"active-active-dr-item-2"],[1,"active-active-dr-item-1"]]
```

This confirmed:
- DR region served traffic automatically during primary failure 
- No manual DNS changes or intervention required 
- Primary was automatically reintroduced after recovery 
- RTO = Route 53 TTL (~30 seconds) 

---

## RTO and RPO Results

| Metric | Value | Notes |
|--------|-------|-------|
| **RTO** | ~30 seconds | Route 53 TTL — no human action required |
| **RPO** | 0 | Each region has its own independent DB — no replication lag |

---

## Recovery Breakdown

| Step | Approximate Duration |
|------|---------------------|
| Route 53 health check failure detection | ~30–60 sec |
| DNS TTL expiry and traffic reroute | ~30 sec |
| **Total active RTO** | **~30–60 sec** |

---

## Key Observations

- Active/Active has the **lowest RTO of all strategies** — recovery is fully automated via Route 53, no human action needed
- **RPO is zero** — both regions have independent databases serving live traffic, so no data is lost on failover
- Route 53 health checks use **16 global checkers** — all must agree on failure before DNS is updated, preventing false positives
- The key tradeoff is **data consistency** — because each region has an independent database, writes to one region are not visible in the other. This is acceptable for workloads that can tolerate regional data isolation
- **Self-healing** was demonstrated: after primary recovered, Route 53 automatically reintroduced it into the 50/50 rotation with no manual DNS changes
- Highest cost of all strategies due to **fully redundant infrastructure running in both regions at all times**
- In production, this pattern would use **global data replication** (e.g. Aurora Global Database) to keep both databases in sync

---

## Final Strategy Comparison

| Strategy | RTO | RPO | Cost | Operational Effort | Best For |
|----------|-----|-----|------|--------------------|----------|
| Backup and Restore | ~30–45 min | Time since last snapshot | Lowest | High — manual snapshot, restore, and redeployment | Non-critical workloads |
| Pilot Light | ~15–30 min | ~0 | Medium | Medium — replica promotion and task definition update required | Moderate criticality workloads |
| Warm Standby | ~2–5 min | ~0 | Higher | Low — single scale-up command | Business-critical workloads |
| Multi-Site Active/Active | ~30–60 sec | 0 | Highest | Minimal — fully automated via Route 53, no human action | Mission-critical workloads |

---

## Learning Focus

This project helped me deepen my understanding of:

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