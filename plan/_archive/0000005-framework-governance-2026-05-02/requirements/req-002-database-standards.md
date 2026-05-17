---
title: "Requirement: REQ-002 - database-standards"
status: "draft"
version: "0.1.0"
---
# Requirement: REQ-002 - database-standards

**Feature:** 0000005-framework-governance
**Source:** database-standards coverage user stories (feature-brief.md)
**Priority:** must-have

---

## Functional Requirements

- `planifest-framework/standards/library-standards/databases/` must contain prefer-avoid entries for each database paradigm:
  - SQL: PostgreSQL, MySQL/MariaDB, SQLite, SQL Server, Oracle
  - NoSQL: MongoDB, Redis, DynamoDB, Cassandra
  - Document: Firestore, CouchDB
  - Data lake: Delta Lake, Apache Iceberg
  - Graph: Neo4j, ArangoDB
  - Time-series: InfluxDB, TimescaleDB
  - Search: Elasticsearch, OpenSearch
- Each paradigm entry covers: client library prefer/avoid per language (where applicable), ORM/query-builder prefer/avoid, and any language-specific driver notes
- When an existing `database-standards.md` entry already covers schema/query patterns for a paradigm, the library-standards database entry defers to it for structure guidance and addresses only client library choices

## Acceptance Criteria

- [ ] `databases/` subdirectory exists under `library-standards/`
- [ ] All listed paradigms have entries covering client library prefer/avoid
- [ ] Entries do not duplicate schema/query pattern guidance already in `database-standards.md`

## Dependencies

- REQ-001 (library-standards-doc) — databases/ lives within that directory tree
