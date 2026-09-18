<div align="center">

# SAP REST2RFC Gateway

[![GitHub Stars](https://img.shields.io/github/stars/shrek-abaper/sap-rest2rfc-gateway?style=flat-square&color=FFD700&logo=github&logoColor=white&label=Stars)](https://github.com/shrek-abaper/sap-rest2rfc-gateway/stargazers)
[![GitHub Forks](https://img.shields.io/github/forks/shrek-abaper/sap-rest2rfc-gateway?style=flat-square&color=3E40C9&logo=github&logoColor=white&label=Forks)](https://github.com/shrek-abaper/sap-rest2rfc-gateway/network/members)
[![Contributors](https://img.shields.io/github/contributors/shrek-abaper/sap-rest2rfc-gateway?style=flat-square&color=2EA043&logo=github&logoColor=white)](https://github.com/shrek-abaper/sap-rest2rfc-gateway/graphs/contributors)
[![Last Commit](https://img.shields.io/github/last-commit/shrek-abaper/sap-rest2rfc-gateway?style=flat-square&color=0066CC&logo=github&logoColor=white)](https://github.com/shrek-abaper/sap-rest2rfc-gateway/commits/main)
[![ABAP](https://img.shields.io/badge/ABAP-pure%20ABAP-0E83CD?style=flat-square&logo=sap&logoColor=white)](https://help.sap.com/doc/abapdocu_latest_index_htm/latest/en-US/index.htm)
[![SAP_BASIS](https://img.shields.io/badge/SAP%20BASIS-%E2%89%A57.40-0FAAFF?style=flat-square&logo=sap&logoColor=white)](https://support.sap.com/en/product/versions.html)

### 把 SAP RFC / BAPI 直接变成 HTTP REST 接口的 ABAP 网关

#### *纯 ABAP 实现、零额外中间件，在 SAP 系统内部完成 RFC 到 REST 的桥接。*

> 不需要 SAP PO/PI，不需要独立集成中间件。任意已注册的 RFC / BAPI 均可通过配置表零改造暴露为 JSON API；要求强契约的接口则走固定 `REQUEST`/`RESPONSE` 结构，支持 XML 报文与 Base64 二进制传输。两条路线共享同一张路由配置表与全量报文日志，按接口逐个选择，互不冲突。

**动态反射 &nbsp;·&nbsp; 类型化契约 &nbsp;·&nbsp; JSON / XML 双报文 &nbsp;·&nbsp; Base64 二进制传输**

**统一路由配置 &nbsp;·&nbsp; 全量报文日志 &nbsp;·&nbsp; 显式事务边界 &nbsp;·&nbsp; 鉴权留在业务函数内**

**纯 ABAP 实现 &nbsp;·&nbsp; 零中间件部署 &nbsp;·&nbsp; 逐接口自由选路 &nbsp;·&nbsp; 可审计可重放**

#### 面向需要把 SAP 功能安全、可控地对外开放的集成团队

**[核心能力](#核心能力)** &nbsp;·&nbsp; **[如何选择](#如何选择-dynamic-还是-typed)** &nbsp;·&nbsp; **[依赖与前置条件](#依赖与前置条件)** &nbsp;·&nbsp; **[安全与合规约定](#安全与合规约定)** &nbsp;·&nbsp; **[原始报文与扩展](#原始报文记录与后续扩展)** &nbsp;·&nbsp; **[已知限制](#已知限制)**

</div>

> 中文 | [English](README.en.md)

---

## 核心能力

| 目录                   | 能力                 | 适用场景                                                     | 文档                                          |
| ---------------------- | -------------------- | ------------------------------------------------------------ | --------------------------------------------- |
| `src/rest_rfc_dynamic` | **动态反射网关**     | 任意已在配置表注册的 RFC / BAPI，零改造暴露为 JSON API       | [查看 README](src/rest_rfc_dynamic/README.md) |
| `src/rest_rfc_typed`   | **类型化契约网关**   | 要求 `REQUEST`/`RESPONSE` 固定结构契约，兼容 XML Web Service | [查看 README](src/rest_rfc_typed/README.md)   |
| `src/rfc_log`          | **函数级日志埋点宏** | 在 Function Module 内部自助记录入参 / 出参 JSON 快照         | [查看 README](src/rfc_log/README.md)          |

## 目录结构

```
src/
├── core/                  # 共享基础设施：XML 序列化基类 + 通用接口日志查看报表 ZRIF_GENERAL_LOG
├── rest_rfc_dynamic/      # 动态反射网关（ZCL_REST2RFC_HANDLE / ZCL_REST2RFC_BIND）+ rest2rfc_meta.py CLI
├── rest_rfc_typed/        # 类型化契约网关（ZCL_HTTP_HANDLE）
└── rfc_log/               # RFC 函数级日志宏（zfmparasaveasjson / zfmparasavevariate）
```

## 如何选择 dynamic 还是 typed

两者解决的是同一个问题（把 RFC/BAPI 暴露成 HTTP 接口），但取舍不同：

- **dynamic（动态反射）**：不要求目标函数遵循任何命名契约，绑定关系在运行时通过 `RFC_GET_FUNCTION_INTERFACE_P` 读取真实参数元数据完成，新增接口只需在配置表加一行。代价是依赖 `/UI2/CL_JSON=>GENERATE` 解析 JSON，存在若干已知取舍（见子目录 README）。
- **typed（类型化契约）**：要求被暴露的函数只有 `IMPORTING REQUEST` + `EXPORTING RESPONSE` 两个 DDIC 结构参数。牺牲了"零改造复用任意 BAPI"的灵活性，换来契约可版本化、无逐字段解析歧义，并额外支持 XML 报文与 Base64 二进制传输。

两条路线共享同一张路由配置表 `ZTIF_GENERAL_CON` 和日志表 `ZTIF_GENERAL_LOG`（字段说明见各目录下 `dictionary/*.html`），因此可以按接口逐个决定走哪条路线，互不冲突。

## 依赖与前置条件

- 建议 `SAP_BASIS >= 7.40`（代码使用了内联声明、字符串模板等较新语法）。
- 依赖 `/UI2/CL_JSON`（随 `SAP_UI` add-on 交付，**不是** `SAP_BASIS` 标准对象，ECC 等老后端可能缺失）。缺失时的检查步骤与降级链见 [ABAP JSON 依赖与降级路径](src/core/abap-json-dependency.zh.md)。
- 需要提前维护好两张自定义表：
  - `ZTIF_GENERAL_CON`：接口路由 / 开关配置表（`IFCODE` 主键，`TASKFM` 指向目标 Function Module，`ACTFLG`/`LOGFLG` 控制激活与日志开关）。
  - `ZTIF_GENERAL_LOG`：接口调用日志表（入站/出站报文、状态码、调用用户等），可用 `ZRIF_GENERAL_LOG`（`src/core`）报表查看。

## 安全与合规约定

以下是代码注释中反复强调、必须遵守的约定，而非可选建议：

- **鉴权不下沉到网关层**：授权检查必须写在被暴露的函数内部，网关本身不做业务级鉴权判断。
- **RESPONSE 消息只读不判定**：`RESPONSE-MESSAGE` 仅供人读，调用端不得拿它做程序判定（应判 `RESULT` 枚举），消息文本中也不得拼接连接串、用户名、内部主机地址等敏感信息。
- **事务边界要明确**：dynamic 模式由配置表 `COMMITMODE` 显式声明事务托管方（网关 / 函数自身 / 只读），typed 模式下事务边界完全属于被调函数，网关不做隐式提交假设。

## 原始报文记录与后续扩展

当前日志表 `ZTIF_GENERAL_LOG` 完整保存了每次接口调用的入站 / 出站原始报文、状态码与调用用户（可用 `ZRIF_GENERAL_LOG` 报表查看）。这份原始报文记录本身就是后续业务能力的基础，可按实际业务情况渐进扩展，例如：

- **失败重处理**：对异常或失败的调用回溯原始入站报文并重放，无需调用方重新发起。
- **调用审计与 SLA 统计**：基于历史报文做合规审计、耗时分布与成功率分析。
- **报文归档与问题排查**：长期留存报文用于事后回溯与定界。

上述能力当前未内置，留给集成方按业务需要自建。

## 已知限制

- dynamic 模式依赖 `/UI2/CL_JSON=>GENERATE` 解析 JSON，存在空对象/空数组无法区分、标量类型退化为字符串、重复 key 静默合并等已知取舍，二进制字段当前不支持隐式转换；详见 [`src/rest_rfc_dynamic/README.md`](src/rest_rfc_dynamic/README.md)。
- typed 目录下的 `ZFM_RFCTYPED_EXAMPLE`、`rfc_log` 目录下的 `ZFM_RFCLOG_EXAMPLE` 均为契约范例骨架，不含可运行业务逻辑，需按注释范式在目标系统自行实现。
- `ZCL_HTTP_HANDLE`（typed）与 `ZCL_REST2RFC_HANDLE`（dynamic）存在较多重复代码（URI 解析、日志写入等），尚未抽象出公共基类。

## License

TBD（待补充）
