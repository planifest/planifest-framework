---
name: data-pipeline-design
description: Data pipeline architecture skill — design ingestion, transformation, and loading patterns with lineage tracking, schema evolution, and operational reliability; use when building data platforms, analytics pipelines, or data integration systems.
---

# Data Pipeline Design

You architect data pipelines that are operationally reliable, schema-evolvable, and lineage-traceable — from raw data ingestion through transformation to queryable analytical stores.

## When to Use

- Building a data platform that ingests from multiple operational systems into an analytical store
- Designing ETL/ELT pipelines for a data warehouse, lakehouse, or data mesh
- Implementing real-time streaming pipelines alongside or replacing batch pipelines
- Adding data lineage and observability to existing pipelines that break silently
- Planning schema evolution strategy for a pipeline serving downstream consumers

## Core Principles

**ELT Supersedes ETL for Analytical Workloads.** Extract-Transform-Load (ETL) transforms data before landing it, consuming compute in the pipeline layer. Extract-Load-Transform (ELT) loads raw data first, then transforms using the analytical store's compute (BigQuery, Snowflake, Redshift, DuckDB). ELT is preferred for analytical workloads because: raw data is preserved for reprocessing; transformation is decoupled from ingestion and can be versioned independently; cloud warehouses offer cost-efficient bulk compute for transformation; and debugging is easier when you can query the raw layer. ETL remains appropriate when: data must be masked or filtered before landing for compliance, or the analytical store cannot handle the raw format.

**Medallion Architecture Structures Data Quality Progressively.** The Bronze/Silver/Gold (or Raw/Curated/Serving) layering pattern separates data by transformation maturity. Bronze: raw, immutable data as received from sources — no transformation, only type casting. Silver: cleansed, deduplicated, enriched data with business keys resolved and validated. Gold: purpose-built aggregations and models serving specific analytical consumers. Each layer is queryable independently; a consumer that needs raw access uses Bronze; a BI tool uses Gold. New requirements are met by adding Silver or Gold transformations without modifying ingestion.

**Lineage Is Not Optional for Regulated Data.** Data lineage tracks: where each data element came from, what transformations were applied, when it was processed, and which downstream artefacts it contributed to. For regulated industries (financial services, healthcare), lineage is a compliance requirement — "show me the provenance of this regulatory report's figures" must be answerable. Implement lineage at the pipeline framework level (Apache Atlas, OpenLineage, dbt lineage) rather than documenting it in wikis that diverge from reality.

**Schema Evolution Must Be Planned Before the First Consumer Exists.** A pipeline's schema is a contract with its consumers. Once a downstream dashboard or analytical model depends on a column, that column cannot be dropped without a migration. Strategies: backward-compatible additions only (new columns with defaults; never drop or rename); schema versioning with explicit version column in every table; or a schema registry for streaming topics. Choose the strategy at pipeline design time — retrofitting schema governance onto an existing pipeline with 40 consumers is extremely expensive.

**Data Quality Is an Operational Concern, Not a One-Time Check.** Data quality (completeness, accuracy, timeliness, consistency) degrades continuously as upstream sources evolve without coordination. Implement automated data quality tests that run after each pipeline execution: row count variance from expected range, null rate in required fields, referential integrity between tables, business rule assertions (revenue cannot be negative, date cannot be in the future). Alert on quality failures before downstream consumers are served stale or incorrect data. dbt tests, Great Expectations, or Soda Core are implementations of this pattern.

## Approach

Map the data topology before designing the pipeline. Sources (operational databases, SaaS APIs, event streams, files), frequency of updates per source (real-time, hourly, daily), volume per source, and downstream consumers (BI tools, ML feature stores, operational reports, regulatory reports). The topology drives technology selection: high-frequency low-latency sources need streaming (Kafka, Flink, Spark Streaming); low-frequency high-volume sources suit batch (Spark, dbt on a warehouse).

Design the ingestion layer with CDC for database sources. Change Data Capture (Debezium for MySQL/Postgres, Striim for Oracle) captures database changes at the transaction log level — every insert, update, and delete — with sub-second latency and no query overhead on the source. For SaaS APIs, implement incremental ingestion (query by last-modified timestamp) rather than full-table extraction — full-table extraction scales poorly as source tables grow and creates unnecessary load on the source system.

Define the transformation layer's execution model. For batch transformations: dbt (SQL-based, version-controlled, lineage-aware, test-integrated) is the current standard for warehouse transformations. For streaming transformations: Apache Flink (stateful stream processing, exactly-once semantics) or Spark Structured Streaming. The choice between streaming and micro-batch (Spark with a 5-minute trigger interval) depends on the freshness requirement — sub-minute freshness requires true streaming; 15-minute freshness can be served by micro-batch at lower operational cost.

Implement late-arriving data handling explicitly. Events from mobile clients or IoT devices may arrive hours or days after they occurred. A pipeline that windows data by ingestion time will misattribute late events to the wrong window. Use event time (the timestamp the event occurred) rather than processing time for windowing. Implement a watermark — the maximum expected delay for late data — and buffer events until the watermark passes before closing a window. Events arriving after the watermark may be discarded, counted separately, or trigger a window correction depending on business requirements.

Design the serving layer for consumer access patterns. A data warehouse optimised for sequential scans (Snowflake, BigQuery) serves BI tools well but is inefficient for point lookups. An operational analytics store (ClickHouse, Druid) serves high-concurrency sub-second queries on recent data. A feature store (Feast, Tecton) serves ML model serving endpoints. A single Gold layer served directly from the warehouse is the simplest starting point; specialised serving layers are added when the warehouse cannot satisfy specific latency or concurrency requirements.

## Common Mistakes to Avoid

- **Full-table extraction from production databases.** Extracting `SELECT * FROM orders` daily from a production OLTP database introduces query load that degrades production performance and misses intra-day updates. Use CDC or incremental extraction.
- **Schema-on-read without schema enforcement.** Landing raw JSON or Avro in a data lake without schema enforcement lets schema drift pass silently into downstream consumers. Validate schema on ingestion; reject or quarantine records that violate the expected schema.
- **No data quality monitoring.** A pipeline that runs successfully but produces incorrect output is worse than a failed pipeline — at least a failure is visible. Implement data quality assertions; a pipeline that produces wrong data silently is a compliance and trust risk.
- **Ignoring late-arriving data.** A streaming pipeline that windows by processing time and never re-opens closed windows will silently misattribute late events. Define the late-arrival policy explicitly before deployment.
- **Tight coupling between ingestion and transformation.** A pipeline that transforms data during ingestion prevents reprocessing with new transformation logic against historical data. Separate ingestion (land raw) from transformation (apply business logic to raw) — the medallion architecture enforces this separation.

## Output

Data pipeline design output includes: data topology map (sources, volumes, frequencies, consumers); medallion layer design (Bronze/Silver/Gold definitions); ingestion strategy per source (CDC, incremental, full with justification); transformation framework selection; streaming vs batch decision per pipeline with freshness requirement; schema evolution policy; lineage implementation (tool and coverage); data quality test catalogue per layer; late-arriving data handling policy; and serving layer design per consumer access pattern.
