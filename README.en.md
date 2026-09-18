# SAP REST2RFC Gateway

[![GitHub Stars](https://img.shields.io/github/stars/shrek-abaper/sap-rest2rfc-gateway?style=flat-square&color=FFD700&logo=github&logoColor=white&label=Stars)](https://github.com/shrek-abaper/sap-rest2rfc-gateway/stargazers)
[![GitHub Forks](https://img.shields.io/github/forks/shrek-abaper/sap-rest2rfc-gateway?style=flat-square&color=3E40C9&logo=github&logoColor=white&label=Forks)](https://github.com/shrek-abaper/sap-rest2rfc-gateway/network/members)
[![Contributors](https://img.shields.io/github/contributors/shrek-abaper/sap-rest2rfc-gateway?style=flat-square&color=2EA043&logo=github&logoColor=white)](https://github.com/shrek-abaper/sap-rest2rfc-gateway/graphs/contributors)
[![Last Commit](https://img.shields.io/github/last-commit/shrek-abaper/sap-rest2rfc-gateway?style=flat-square&color=0066CC&logo=github&logoColor=white)](https://github.com/shrek-abaper/sap-rest2rfc-gateway/commits/main)
[![ABAP](https://img.shields.io/badge/ABAP-pure%20ABAP-0E83CD?style=flat-square&logo=sap&logoColor=white)](https://help.sap.com/doc/abapdocu_latest_index_htm/latest/en-US/index.htm)
[![SAP_BASIS](https://img.shields.io/badge/SAP%20BASIS-%E2%89%A57.40-0FAAFF?style=flat-square&logo=sap&logoColor=white)](https://support.sap.com/en/product/versions.html)

### An ABAP Gateway That Turns SAP RFC / BAPI into HTTP REST Endpoints

#### _Pure ABAP, zero extra middleware — the RFC-to-REST bridge lives inside the SAP system itself._

> No SAP PO/PI, no standalone integration middleware. Any registered RFC / BAPI can be exposed as a JSON API with a single config-table row and zero code changes; contract-first interfaces use a fixed `REQUEST`/`RESPONSE` structure with XML payloads and Base64 binary transport. Both routes share one routing table and full payload logging — choose per interface, without conflict.

**Dynamic Reflection · Typed Contracts · JSON / XML Payloads · Base64 Binary Transport**

**Unified Routing Config · Full Payload Logging · Explicit Transaction Boundaries · Auth Stays in the Business Function**

**Pure ABAP · Zero-Middleware Deployment · Per-Interface Route Choice · Auditable and Replayable**

#### Built for Integration Teams Exposing SAP Functionality Safely and Under Control

**[Core Capabilities](#core-capabilities)** · **[Choosing Between Routes](#choosing-between-dynamic-and-typed)** · **[Dependencies](#dependencies-and-prerequisites)** · **[Security Conventions](#security-and-compliance-conventions)** · **[Payload Logging & Extensibility](#raw-payload-logging-and-extensibility)** · **[Known Limitations](#known-limitations)**

> English | [中文（默认）](README.md)

---

## Core Capabilities

| Directory | Capability | Use Case | Docs |
|---|---|---|---|
| `src/rest_rfc_dynamic` | **Dynamic reflection gateway** | Expose any RFC / BAPI registered in the config table as a JSON API with zero code changes | [README](src/rest_rfc_dynamic/README.md) (Chinese) |
| `src/rest_rfc_typed` | **Typed contract gateway** | Requires a fixed `REQUEST`/`RESPONSE` structure contract, also supports XML Web Service | [README](src/rest_rfc_typed/README.md) (Chinese) |
| `src/rfc_log` | **Function-level logging macros** | Self-service JSON snapshot logging of import/export parameters inside a Function Module | [README](src/rfc_log/README.md) (Chinese) |

> Note: the three capability-specific READMEs above are written in Chinese only for now.

## Directory Layout

```
src/
├── core/                  # Shared infrastructure: XML serialization base class + ZRIF_GENERAL_LOG viewer report
├── rest_rfc_dynamic/      # Dynamic reflection gateway (ZCL_REST2RFC_HANDLE / ZCL_REST2RFC_BIND) + rest2rfc_meta.py CLI
├── rest_rfc_typed/        # Typed contract gateway (ZCL_HTTP_HANDLE)
└── rfc_log/               # RFC function-level logging macros (zfmparasaveasjson / zfmparasavevariate)
```

## Choosing Between Dynamic and Typed

Both routes solve the same problem (exposing RFC/BAPI over HTTP) but with different trade-offs:

- **Dynamic (reflection-based)**: Does not require the target function to follow any naming contract. Parameter binding is resolved at runtime via `RFC_GET_FUNCTION_INTERFACE_P` against the real interface metadata; adding a new interface only requires a new row in the config table. The trade-off is a dependency on `/UI2/CL_JSON=>GENERATE` for JSON parsing, which has several known limitations (see the sub-directory README).
- **Typed (contract-based)**: Requires the exposed function to have exactly two DDIC structure parameters: `IMPORTING REQUEST` + `EXPORTING RESPONSE`. This sacrifices the "reuse any BAPI with zero changes" flexibility in exchange for a versionable contract, no field-by-field parsing ambiguity, and additional support for XML payloads and Base64 binary transport.

Both routes share the same routing config table `ZTIF_GENERAL_CON` and log table `ZTIF_GENERAL_LOG` (field details in each directory's `dictionary/*.html`), so you can decide per-interface which route to use without conflict.

## Dependencies and Prerequisites

- `SAP_BASIS >= 7.40` is recommended (the code uses newer ABAP syntax such as inline declarations and string templates).
- Depends on `/UI2/CL_JSON` (shipped with the `SAP_UI` add-on — **not** a `SAP_BASIS` standard object; older ECC backends may not have it). For availability checks and the fallback chain, see [ABAP JSON Dependency and Fallback Chain](src/core/abap-json-dependency.en.md).
- Two custom tables must be maintained beforehand:
  - `ZTIF_GENERAL_CON`: interface routing / switch configuration table (`IFCODE` as key, `TASKFM` points to the target Function Module, `ACTFLG`/`LOGFLG` control activation and logging).
  - `ZTIF_GENERAL_LOG`: interface call log table (inbound/outbound payloads, status code, calling user, etc.), viewable via the `ZRIF_GENERAL_LOG` report (in `src/core`).

## Security and Compliance Conventions

The following are conventions repeatedly emphasized in the code comments — they are requirements, not optional suggestions:

- **Authorization is not delegated to the gateway layer**: authorization checks must be implemented inside the exposed function itself; the gateway does not perform business-level authorization.
- **The response message is read-only, not a decision signal**: `RESPONSE-MESSAGE` is for humans only. Callers must not use it programmatically (use the `RESULT` enum instead), and the message text must never embed connection strings, usernames, internal hostnames, or other sensitive information.
- **Transaction boundaries must be explicit**: in dynamic mode, the config table's `COMMITMODE` field explicitly declares who owns the transaction (gateway / the function itself / read-only); in typed mode, the transaction boundary belongs entirely to the called function — the gateway makes no implicit commit assumptions.

## Raw Payload Logging and Extensibility

The log table `ZTIF_GENERAL_LOG` retains the full inbound / outbound raw payloads, status code, and calling user of every interface call (viewable via the `ZRIF_GENERAL_LOG` report). This raw payload record is itself a foundation for downstream business capabilities that can be built incrementally as needed, for example:

- **Failure reprocessing**: replay the original inbound payload for failed or abnormal calls without the caller having to re-issue the request.
- **Audit and SLA analytics**: compliance auditing, latency distribution, and success-rate analysis based on historical payloads.
- **Payload archival and troubleshooting**: long-term retention for post-incident reconstruction and fault isolation.

These capabilities are not built into the current implementation and are intentionally left for integrators to build per their business needs.

## Known Limitations

- Dynamic mode depends on `/UI2/CL_JSON=>GENERATE` for JSON parsing, which has known limitations: empty objects/arrays cannot be distinguished, scalars degrade to strings, duplicate keys are silently merged, and binary fields are not currently supported for implicit conversion. See [`src/rest_rfc_dynamic/README.md`](src/rest_rfc_dynamic/README.md) for details.
- `ZFM_RFCTYPED_EXAMPLE` (typed) and `ZFM_RFCLOG_EXAMPLE` (rfc_log) are both contract example skeletons without runnable business logic; they must be implemented following the pattern described in their comments.
- `ZCL_HTTP_HANDLE` (typed) and `ZCL_REST2RFC_HANDLE` (dynamic) share a fair amount of duplicated code (URI parsing, logging, etc.) that has not yet been factored into a common base class.

## License

TBD
