---
name: batch-processing
description: Batch processing design skill — design job scheduling, idempotent execution, checkpointing, error handling, and monitoring for large-scale batch workloads; use when designing ETL pipelines, report generation, billing runs, or any large-volume periodic data processing.
---

# Batch Processing

You design batch workloads that process large volumes of data reliably — handling partial failure through checkpointing, ensuring idempotent re-execution, and providing operational visibility without manual intervention.

## When to Use

- Designing ETL pipelines that transform and load large datasets on a schedule
- Building billing, payroll, or settlement runs that must process every record exactly once
- Implementing data exports, report generation, or compliance reporting jobs
- Designing migration jobs that process millions of records with tolerable latency
- Refactoring a batch job that currently requires manual intervention to recover from partial failure

## Core Principles

**Idempotency Is the Foundation of Reliable Batch.** A batch job that cannot be safely re-run from the beginning without side effects is unreliable — because jobs will be re-run. Crashes, infrastructure failures, and deployment restarts will interrupt jobs mid-execution. Design every job to be idempotent: running it again on already-processed records produces no duplicate effects. Techniques: conditional writes ("insert if not exists with this batch-id"), upsert semantics, or tombstoning processed records with a completion marker before reading them.

**Checkpointing Limits Recovery Cost.** A job that processes 10 million records and fails at record 9,999,999 must not restart from record 1 unless it has no checkpoint mechanism. Checkpointing persists the last successfully processed position (offset, record ID, page cursor) to durable storage at regular intervals. On restart, the job resumes from the last checkpoint. Checkpoint granularity is a trade-off: fine-grained checkpoints (every 1,000 records) reduce recovery work but increase checkpoint overhead; coarse-grained checkpoints (every 100,000 records) reduce overhead but increase recovery cost. Choose based on processing time per record and acceptable recovery time.

**Bounded Parallelism Prevents Resource Exhaustion.** Parallel batch processing increases throughput but risks exhausting downstream resources. A batch job that spawns 10,000 parallel database connections will kill the database. Implement bounded worker pools: a fixed number of workers pull from a work queue. The queue absorbs backpressure; workers process at a rate the downstream system can sustain. Tune worker count and batch read size empirically against the downstream system's capacity.

**Error Handling Requires a Dead-Letter Strategy, Not Silent Skipping.** A record that fails processing must not be silently skipped — skipping hides data quality problems and causes silent data loss. Failed records must be written to a dead-letter store (a separate table, a DLQ, an error file) with: the original record, the error reason, the timestamp, and the job run ID. Dead-letter records must be monitored, alertable, and reprocessable after the root cause is fixed. A job with zero dead-letter records after processing 10 million records likely has silent error swallowing.

**Job Scheduling Must Handle Overlap and Missed Runs.** A scheduled batch job that takes longer than its scheduling interval will spawn overlapping runs. Overlapping runs on the same dataset cause double-processing, deadlocks, or corrupted aggregates. Implement distributed job locking (database advisory lock, Redis lock, a lease table) to ensure only one instance of a job runs at a time. For missed runs (job failed to run due to system downtime), decide: run once on recovery (idempotent catch-up) or skip (acceptable gap in processing). Document and implement the catch-up policy explicitly.

## Approach

Design the data flow before the implementation. Source (where data comes from), filter (which records are in scope), transform (what changes are applied), validate (what invariants must hold), load (where results go), and audit (what is recorded for compliance). Each stage is independently testable. The full pipeline is the composition of stages.

Choose the execution model based on dataset size and latency requirements. Pull-based paging (SQL OFFSET/LIMIT or cursor-based pagination) suits small-to-medium datasets with a relational source; at large scale (> 10 million records), cursor-based pagination avoids the OFFSET performance degradation. Partition-based parallel processing (divide the key space into N partitions, process each in parallel) suits large datasets where the key space is evenly distributed and ordering within a partition is sufficient. Event streaming (Kafka consumer group consuming from the beginning of a topic) suits unbounded datasets where the "batch" is a time-windowed slice of a continuous stream.

Implement the checkpoint store using the job's own database. A checkpoint table: `(job_name, run_id, last_processed_id, last_processed_at, record_count, status)`. Update within the same transaction as each batch of writes — the checkpoint and the work are atomically consistent. If using an external system for writes (S3, external API), checkpoint after verifying write acknowledgement, not before.

Design the run lifecycle explicitly. States: `SCHEDULED → RUNNING → COMPLETED | FAILED | PARTIAL`. Transitions are persisted. A job in `RUNNING` state that has not updated its heartbeat in N minutes is assumed crashed — a watchdog process transitions it to `FAILED` and alerts. This prevents silent zombie jobs. `PARTIAL` state indicates the job completed but with dead-letter records requiring attention.

Monitor batch jobs on throughput, not just completion. A job that processes 10,000 records per minute and slows to 100 records per minute is heading toward SLA breach hours before it fails. Alert on: records-per-minute drop below threshold, job duration exceeding expected completion time, dead-letter record count exceeding threshold, and checkpoint updates older than N minutes (stalled job).

## Common Mistakes to Avoid

- **Silent error swallowing.** Catching exceptions inside the record loop and continuing without writing to a dead-letter store means failed records vanish silently. Every record processing error must be observable.
- **No distributed lock on scheduled jobs.** Two instances of the same scheduled job running concurrently on the same dataset will double-process, deadlock, or corrupt aggregates. Lock before running; fail the second instance with a clear log message.
- **OFFSET-based pagination at scale.** `SELECT * FROM orders LIMIT 1000 OFFSET 5000000` performs a full scan to the offset row — latency grows linearly with dataset size. Use cursor-based pagination (`WHERE id > last_processed_id LIMIT 1000`) for large datasets.
- **Writing checkpoint before verifying downstream write.** Checkpointing position N before confirming that the writes for records up to N succeeded means a crash between checkpoint and write loses records without retrying them. Checkpoint after write confirmation.
- **Unbounded parallelism.** Spawning a goroutine or thread per record in a multi-million-record dataset exhausts memory and file descriptors. Always bound parallelism with a worker pool sized to the downstream system's capacity.

## Output

Batch processing design output includes: data flow stage diagram (source, filter, transform, validate, load, audit); execution model selection with partitioning or cursor strategy; checkpoint store schema; job lifecycle state machine; dead-letter store design and reprocessing runbook; distributed lock mechanism; worker pool sizing model; monitoring plan (throughput rate, stall detection, dead-letter alerting, SLA breach prediction); and a catch-up policy for missed scheduled runs.
