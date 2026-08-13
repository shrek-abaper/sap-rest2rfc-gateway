# ABAP JSON Dependency and Fallback Chain

> Scope: all code in this repository that serializes or deserializes JSON on the ABAP side.
> Bottom line first: `/UI2/CL_JSON` is **not a `SAP_BASIS` standard object**. Your backend system may not have it. If it is missing, pull it from the official SAP open-source repository instead of waiting for an add-on installation.

## 1. Dependency Declaration

| Item | Detail |
|---|---|
| Preferred class | `/UI2/CL_JSON` |
| Shipped in | Software component **SAP_UI** (UI add-on for SAP NetWeaver), package `/UI2/FOUNDATION_NWBC` |
| **Not part of** | `SAP_BASIS` — so ECC and older NetWeaver backends may not have it at all |
| Minimum usable patch | Class attribute `VERSION` >= 12 (lower versions lack parameters such as `TS_AS_ISO8601` and `CONVERSION_EXITS`) |

Common pitfall: in a dual-stack landscape the class exists on the Gateway / Fiori front-end server but **not on the ECC backend**. Code written on the backend fails activation.

## 2. Availability Check (3 Steps)

```text
1. SE24   -> enter /UI2/CL_JSON and check whether it exists
2. SE80   -> open package /UI2/FOUNDATION_NWBC and check whether the object tree is empty
3. System -> Status -> Component Information -> check for component SAP_UI and its SP level
```

If the class exists but method parameters are missing, check the class attribute `VERSION`. That is a **low patch level**, not a missing class.

Typical error:

```text
Type "/UI2/CL_JSON" is unknown
```

## 3. Where to Get the Source (Recommended)

The official SAP-maintained open-source version, kept **in sync with the standard class**:

- Repository: <https://github.com/SAP/abap-to-json>
- Package name: `Z_UI2_JSON`
- Docs: `docs/basic.md` and `docs/advanced.md` in the repository

Installation options:

1. **abapGit (recommended)**: abapGit -> New Online -> enter the repository URL -> choose the target package (local package `$Z_UI2_JSON` or a transportable package such as `ZUI2_JSON`) -> Pull -> activate.
2. **No abapGit / no internet access**: the repository contains abapGit-format `.clas.abap` sources. Copy the implementation and create a global class in SE24, or embed it as a **local class** in an INCLUDE for single-program use.

The API is identical to the standard class; only the prefix changes:

```abap
" Serialize
DATA(lv_json) = zcl_json=>serialize(
                  data          = ls_data
                  pretty_name   = zcl_json=>pretty_mode-camel_case
                  ts_as_iso8601 = abap_true
                  format_output = abap_true ).

" Deserialize
zcl_json=>deserialize(
  EXPORTING json        = lv_json
            pretty_name = zcl_json=>pretty_mode-camel_case
  CHANGING  data        = ls_data ).
```

> The class name depends on the repository you actually pull. Confirm it in SE24 after import instead of copying this document verbatim.

## 4. Fallback Chain (in Priority Order)

| # | Option | Prerequisite | Trade-off |
|---|---|---|---|
| 1 | `/UI2/CL_JSON` | SAP_UI installed and `VERSION` >= 12 | Standard object; first choice |
| 2 | `Z_UI2_JSON` (SAP/abap-to-json) | abapGit or manual import; repository Requirements met | API identical to the standard class; migration cost close to zero |
| 3 | `CALL TRANSFORMATION id` + `CL_SXML_STRING_WRITER` | `SAP_BASIS` >= 7.40 | Pure standard, zero dependency, best performance; but keys are upper-case ABAP field names, no `PRETTY_MODE`, no suppression of initial values |
| 4 | `ajson` (sbcgua/ajson) | abapGit | Supports downport to 7.31 and below; different API, existing code must be reworked |
| 5 | `CL_FDT_JSON` / `CL_TREX_JSON_*` | Present in most systems | Not public APIs; `CL_TREX_JSON_DESERIALIZER` is missing in some systems and has behavioural quirks. Emergency use only |
| — | `XCO_CP_JSON` | ABAP Cloud / Steampunk | Not available in classic On-Premise |

Minimal implementation of option 3:

```abap
DATA: lo_writer TYPE REF TO cl_sxml_string_writer,
      lv_json   TYPE string.

lo_writer = cl_sxml_string_writer=>create( type = if_sxml=>co_xt_json ).
CALL TRANSFORMATION id
  SOURCE data = ls_data
  RESULT XML lo_writer.
lv_json = cl_abap_codepage=>convert_from( lo_writer->get_output( ) ).

" JSON -> ABAP (input must be xstring)
CALL TRANSFORMATION id
  SOURCE XML cl_abap_codepage=>convert_to( lv_json )
  RESULT data = ls_data.
```

## 5. Notes for Low Releases (<= 7.31)

The open-source sources use newer ABAP syntax (inline declarations, string templates, `NEW`). If activation fails with syntax errors on 7.31 or below, do not patch it line by line:

- Switch to **`ajson`** or a community downport branch (the abap2UI5 ecosystem has proven practices), or
- Move JSON assembly out of ABAP entirely (see section 6).

## 6. Boundary: Decide Which Layer Owns Serialization

If the integration goes through `/sap/bc/soap/rfc` (SOAP) or IDoc, the payload on the wire is **XML**. JSON assembly then belongs **outside** ABAP, in the calling layer (Python / CLI / Agent).
Before spending effort on "ABAP has no JSON class", decide whether the requirement should exist on the ABAP side at all. This is the default stance of this repository: **ABAP exposes stable semantic interfaces; structured encoding and decoding belong to the outer layer.**

## 7. References

- SAP/abap-to-json: <https://github.com/SAP/abap-to-json>
- sbcgua/ajson: <https://github.com/sbcgua/ajson>
- SAP Note 2500033 (prerequisites for UI add-on / Gateway component installation)
- SAP Note 3568088 (`/UI2/CL_JSON` patch 21)
- ABAP Keyword Documentation — ABAP and JSON / JSON-XML / asXML
