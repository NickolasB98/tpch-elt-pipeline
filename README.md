# TPC-H ELT Pipeline: Data Warehousing with Snowflake & dbt

A hands-on data engineering project implementing an ELT (Extract, Load, Transform) pipeline using the TPC-H benchmark dataset. This project demonstrates core data modeling concepts, dimensional design, and data quality testing with Snowflake and dbt.

## Project Overview

This project transforms raw TPC-H data (a standard benchmark dataset simulating an e-commerce supply chain) into a clean, well-structured data warehouse on Snowflake. The pipeline showcases:

- **Data Cleaning** via a staging layer that standardizes raw data
- **Dimensional Modeling** with fact and dimension tables using surrogate keys
- **Data Quality Testing** with dbt tests for validation and freshness checks
- **Aggregation Layer** with derived metrics for analytics
- **Clean Architecture** following dbt best practices

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           PROJECT ARCHITECTURE                                  │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│   Raw TPC-H        Snowflake            dbt TRANSFORMATIONS    Analytics       │
│   Sample Data      (Data Warehouse)     (Staging → Marts)      Ready Tables    │
│                                                                                 │
│   ┌─────────┐      ┌──────────────┐     ┌────────────────┐     ┌──────────────┐│
│   │ ORDERS  │      │   RAW LAYER  │     │  STAGING LAYER │     │  DIM TABLES  ││
│   │LINEITEM │──────│ (7 TPC-H     │────>│  (Column       │────>│  (Customers) ││
│   │CUSTOMER │      │  source      │     │   Cleaning &   │     │  (Parts)     ││
│   │SUPPLIER │      │  tables)     │     │   Renaming)    │     │  (Suppliers) ││
│   │PART     │      │              │     │                │     │  (Nations)   ││
│   │NATION   │      └──────────────┘     └────────┬───────┘     │  (Regions)   ││
│   │REGION   │                                    │              └──────────────┘│
│   └─────────┘                                    v                             │
│                                          ┌──────────────────┐                  │
│                                          │  MARTS LAYER     │                  │
│                                          │  ┌────────────┐  │                  │
│                                          │  │ fct_orders │  │                  │
│                                          │  ├────────────┤  │                  │
│                                          │  │ agg_daily_ │  │                  │
│                                          │  │ orders     │  │                  │
│                                          │  ├────────────┤  │                  │
│                                          │  │ agg_       │  │                  │
│                                          │  │ customer_  │  │                  │
│                                          │  │ metrics    │  │                  │
│                                          │  └────────────┘  │                  │
│                                          └──────────────────┘                  │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

## Tech Stack

| Technology | Purpose | Version |
|---|---|---|
| Snowflake | Cloud Data Warehouse | Enterprise |
| dbt Core | Data Transformation | 1.9+ |
| Python | Data Processing | 3.12 |
| SQL | Data Modeling & Queries | Snowflake Dialect |

## dbt Packages Used

| Package | Purpose |
|---|---|
| dbt_utils | Surrogate key generation, utility macros |

## Data Sources

The project uses Snowflake's built-in TPC-H sample dataset (`SNOWFLAKE_SAMPLE_DATA.TPCH_SF1`). The key source tables are:

| Table | Description |
|---|---|
| ORDERS | Order transactions with dates, status, and pricing |
| LINEITEM | Individual line items within orders |
| CUSTOMER | Customer master data with contact info |
| SUPPLIER | Supplier information and location details |
| PART | Product/part catalog |
| NATION | Nation/country reference data |
| REGION | Geographic region reference data |

## Data Transformation Layer (dbt)

### Project Structure

```
my_dbt_project/
├── models/
│   ├── staging/                    # Raw data cleaning & standardization
│   │   ├── stg_tpch_orders.sql
│   │   ├── stg_tpch_line_items.sql
│   │   ├── stg_tpch_customer.sql
│   │   ├── stg_tpch_supplier.sql
│   │   ├── stg_tpch_part.sql
│   │   ├── stg_tpch_nation.sql
│   │   ├── stg_tpch_region.sql
│   │   └── tphc_sources.yml        # Source definitions & tests
│   │
│   └── marts/                      # Business-ready analytics tables
│       ├── fct_orders.sql          # Fact table (orders + line items)
│       ├── dim_customers.sql       # Customer dimension with surrogate key
│       ├── dim_supplier.sql        # Supplier dimension
│       ├── dim_part.sql            # Product dimension
│       ├── dim_nation.sql          # Nation dimension
│       ├── dim_region.sql          # Region dimension
│       ├── agg_daily_orders.sql    # Daily order summary
│       ├── agg_customer_metrics.sql# Customer lifetime metrics
│       └── schema.yml              # Mart definitions & tests
│
├── tests/                          # Custom data quality tests
├── dbt_project.yml                 # Project configuration
└── packages.yml                    # dbt dependencies
```

### Layer Architecture

#### 1. Staging Layer (Views)
**Purpose:** Clean and standardize raw TPC-H data with minimal transformations

| Model | Source | Transformations |
|---|---|---|
| stg_tpch_orders | ORDERS | Column renaming (o_orderkey → orderkey, etc.) |
| stg_tpch_line_items | LINEITEM | Column standardization, field mapping |
| stg_tpch_customer | CUSTOMER | Column renaming, data standardization |
| stg_tpch_supplier | SUPPLIER | Column renaming, field standardization |
| stg_tpch_part | PART | Column renaming, data cleaning |
| stg_tpch_nation | NATION | Column renaming, reference data |
| stg_tpch_region | REGION | Column renaming, reference data |

**Materialization:** Views (cost-efficient, always reflects source data)

#### 2. Marts Layer (Tables)
**Purpose:** Clean, business-ready fact and dimension tables for analytics

**FCT_ORDERS**
- Joins orders and line items
- Columns: orderkey, custkey, orderstatus, orderdate, totalprice, line item details
- Used as base for all downstream aggregations

**Dimension Tables (with Surrogate Keys)**

| Table | Purpose | Key Feature |
|---|---|---|
| dim_customers | Customer master | Surrogate key generated via dbt_utils |
| dim_supplier | Supplier master | Surrogate key, includes supplier details |
| dim_part | Product master | Surrogate key, includes part attributes |
| dim_nation | Nation reference | Surrogate key, immutable reference |
| dim_region | Region reference | Surrogate key, immutable reference |

**Aggregation Tables**

| Table | Purpose | Grain |
|---|---|---|
| agg_daily_orders | Daily order summary by status | One row per day/status |
| agg_customer_metrics | Customer lifetime metrics | One row per customer |

### Data Quality Tests

Tests are defined in `tphc_sources.yml` (sources) and `schema.yml` (models):

**Source Tests:**
- **Primary Key Validation:** unique & not_null on o_orderkey, c_custkey, p_partkey, s_suppkey, n_nationkey, r_regionkey
- **Referential Integrity:** l_orderkey → orders.o_orderkey (lineitem to orders)

**Mart Tests:**
- **Dimension Uniqueness:** Each surrogate key is unique and not_null
- **Foreign Keys:** custkey references dim_customers
- **Accepted Values:** orderstatus constrained to ['O', 'F', 'P']
- **Freshness:** Data staleness monitoring via dbt_loaded_at timestamp

## dbt Best Practices Demonstrated

| Practice | Implementation |
|---|---|
| **Staging/Marts Pattern** | Clean separation of raw data cleaning from business logic |
| **Surrogate Keys** | Generated via dbt_utils for all dimensions |
| **Source Configuration** | Centralized source definitions with column tests |
| **Data Testing** | Comprehensive tests on sources and models |
| **Documentation** | YAML descriptions for all models and columns |
| **Materialization Strategy** | Views for staging (lightweight), tables for marts (queryable) |
| **Data Freshness** | dbt_loaded_at timestamps for monitoring |

## Key Technical Achievements

### 1. Surrogate Key Generation
Hash-based surrogate keys for all dimensions using dbt_utils:

```sql
{{ dbt_utils.generate_surrogate_key(['custkey']) }} as dim_customer_key
```

Ensures consistent, unique identifiers regardless of source changes.

### 2. Star Schema Implementation
Fact table (fct_orders) joined with 5 dimensions for a complete, queryable star schema:
- Central fact table with orders + line items
- Conformed dimensions for consistent analysis

### 3. String Manipulation & Parsing
Data cleaning in the staging layer:
- Extracting customer names from concatenated fields
- Removing special characters from phone numbers
- Data type casting and standardization

### 4. Aggregation Tables
Pre-aggregated metrics for performance:
- Daily order counts by status
- Customer lifetime value metrics
- Ready for dashboard consumption

### 5. Comprehensive Test Coverage
Multi-level testing strategy:
- Source-level tests (primary keys, relationships)
- Model-level tests (uniqueness, accepted values)
- Data freshness monitoring

## Project Statistics

| Metric | Count |
|---|---|
| dbt Models | 15 (7 staging + 8 marts) |
| Source Tables | 7 TPC-H tables |
| Tests | 15+ data quality tests |
| Fact Tables | 1 (fct_orders) |
| Dimension Tables | 5 (customers, supplier, part, nation, region) |
| Aggregation Tables | 2 (daily orders, customer metrics) |
| Surrogate Keys | 5 (one per dimension) |

## How to Run

### Prerequisites
- Snowflake account (free tier works—uses `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1`)
- Python 3.12+
- dbt Core installed
- VS Code with dbt extension (optional but recommended)

### Setup

**1. Clone the repository**
```bash
git clone https://github.com/yourusername/tpch-elt-pipeline.git
cd tpch-elt-pipeline/my_dbt_project
```

**2. Create virtual environment & install dependencies**
```bash
python -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate
pip install dbt-snowflake dbt-utils
```

**3. Configure dbt profile (~/.dbt/profiles.yml)**
```yaml
tpch_elt_pipeline:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: <your_account_id>
      user: <your_username>
      password: <your_password>
      warehouse: COMPUTE_WH
      database: <your_database>
      schema: tpch_dev
      threads: 4
```

**4. Run dbt**
```bash
# Install dependencies
dbt deps

# Build all models and run tests
dbt build

# Or separately:
dbt run       # Execute models
dbt test      # Run data quality tests
```

### Common Commands

```bash
# Run all models
dbt run

# Run only staging models
dbt run --select staging

# Run only marts
dbt run --select marts

# Run tests only
dbt test

# Run specific model
dbt run --select dim_customers

# Generate and serve documentation
dbt docs generate && dbt docs serve

# Dry-run to see what will execute
dbt run --dry-run

# Detailed debug output
dbt run --debug
```

## Running with Docker

Docker is the fastest way to get the pipeline running without configuring a local Python environment.

### Prerequisites
- Docker Desktop (or Docker Engine + Compose plugin)
- A Snowflake account with access to `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1`

### Quick Start

**1. Clone the repo**
```bash
git clone https://github.com/NickolasB98/tpch-elt-pipeline.git
cd tpch-elt-pipeline
```

**2. Configure credentials**
```bash
cp .env.example .env
# Open .env and fill in the four required SNOWFLAKE_* values
```

**3. Run the full pipeline**
```bash
docker-compose up
```
This builds the image (first run only), runs `dbt deps`, then `dbt build` (all models + all tests).

### Common Docker Commands

```bash
# Run only staging models
docker-compose run dbt dbt run --select staging

# Run only mart models
docker-compose run dbt dbt run --select marts

# Run tests only
docker-compose run dbt dbt test

# Open a shell inside the container for debugging
docker-compose run dbt bash
```

### Environment Variables Reference

| Variable | Required | Default | Description |
|---|---|---|---|
| `SNOWFLAKE_ACCOUNT` | Yes | — | Account identifier (e.g. `myorg-myaccount`) |
| `SNOWFLAKE_USER` | Yes | — | Snowflake username |
| `SNOWFLAKE_PASSWORD` | Yes | — | Snowflake password |
| `SNOWFLAKE_DATABASE` | Yes | — | Target database for dbt output |
| `SNOWFLAKE_ROLE` | No | `SYSADMIN` | Snowflake role |
| `SNOWFLAKE_WAREHOUSE` | No | `dbt_wh` | Compute warehouse |
| `SNOWFLAKE_SCHEMA` | No | `tpch_dev` | Target schema |
| `DBT_TARGET` | No | `dev` | dbt target (`dev` or `prod`) |
| `DBT_THREADS` | No | `4` | Parallel dbt threads |

## Skills Demonstrated

| Category | Skills |
|---|---|
| **Data Engineering** | ELT pipelines, incremental loading, data modeling, schema design |
| **SQL** | CTEs, window functions, aggregations, joins, subqueries, surrogate keys |
| **dbt** | Staging/marts pattern, macros, tests, documentation, incremental models |
| **Snowflake** | Cloud data warehouse, schema design, performance optimization |
| **Data Modeling** | Star schema, fact/dimension tables, conformed dimensions |
| **Best Practices** | Version control, documentation, testing, modularity, data quality |

## Database Schema

### Snowflake Architecture

```
SNOWFLAKE ACCOUNT
│
├── SNOWFLAKE_SAMPLE_DATA (Built-in Database)
│   └── TPCH_SF1 (Schema) ──── Source Data
│       ├── ORDERS
│       ├── LINEITEM
│       ├── CUSTOMER
│       ├── SUPPLIER
│       ├── PART
│       ├── NATION
│       └── REGION
│
└── <YOUR_DATABASE> (User Database)
    └── TPCH_DEV (Schema) ──── Transformed Data
        ├── STAGING LAYER (Views)
        │   ├── stg_tpch_orders
        │   ├── stg_tpch_line_items
        │   ├── stg_tpch_customer
        │   ├── stg_tpch_supplier
        │   ├── stg_tpch_part
        │   ├── stg_tpch_nation
        │   └── stg_tpch_region
        │
        └── MARTS LAYER (Tables)
            ├── fct_orders           (Fact)
            ├── dim_customers        (Dimension)
            ├── dim_supplier         (Dimension)
            ├── dim_part             (Dimension)
            ├── dim_nation           (Dimension)
            ├── dim_region           (Dimension)
            ├── agg_daily_orders     (Aggregation)
            └── agg_customer_metrics (Aggregation)
```

## Future Enhancements

- [ ] Build Streamlit dashboard for visualization (like Jaffle Shop example)
- [ ] Add incremental loading strategy to fct_orders for larger datasets
- [ ] Implement CI/CD pipeline with GitHub Actions (automated tests on PR)
- [ ] Add data quality monitoring with Elementary
- [ ] Create advanced metrics (RFM analysis, customer churn prediction)
- [ ] Slowly Changing Dimensions (SCD Type 2) for historical tracking
- [ ] Add macros for common transformation patterns
- [ ] Performance optimization with clustering keys
- [ ] Deploy to Snowflake Native App

## What You'll Learn

This project demonstrates:
- **ELT Pattern:** Clean architecture with staging → marts separation
- **Dimensional Modeling:** Star schema with conformed dimensions
- **Data Quality:** Multi-level testing (source, model, column level)
- **dbt Fundamentals:** Sources, models, tests, documentation, ref() & source()
- **Surrogate Keys:** Hash-based key generation for dimension tables
- **Analytics Engineering:** Building with the business user in mind

## Author

Nikolas - Data Engineer / Analytics Engineer

This project documents my learning journey building production-like data pipelines with modern tools. It follows the same patterns and best practices used by professional analytics engineers at leading data-driven companies.

## License

This project is for educational and portfolio purposes.
