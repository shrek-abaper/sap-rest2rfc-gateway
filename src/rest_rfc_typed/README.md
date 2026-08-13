# REST2RFC Typed Handler — 类型化契约网关

与 `rest_rfc_dynamic` 是同一问题的另一种解法：不做运行时反射式的任意参数绑定，而是要求每个被暴露的 Function Module 严格遵守"只有两个参数：`IMPORTING REQUEST` + `EXPORTING RESPONSE`，均为 DDIC 结构"的契约。JSON 直接反序列化进 `REQUEST`，`RESPONSE` 直接序列化回 JSON。

相比 dynamic 模式，typed 模式牺牲了"零改造复用任意 BAPI"的灵活性，换来的是：契约集中、可随 DDIC 结构变更留痕追溯、参数解析代码不随字段增删而改动，且同一函数可被 HTTP handler / 批处理 / RFC 等多入口复用。此外还额外提供了 XML 序列化（依赖 `src/core` 的 `ZCL_XML_DOCUMENT_BASE`）与 Base64 编解码能力，适用面比 dynamic 更广。

## 核心组件

| 组件 | 职责 |
|---|---|
| `ZCL_HTTP_HANDLE` | 实现 `IF_HTTP_EXTENSION` 的 HTTP handler 类，与 `ZCL_REST2RFC_HANDLE`（dynamic）是平行演进的姊妹类 |
| `check_uri` / `split_uri` / `write_log` / `http_consumer` | 与 dynamic 版本代码基本相同（URI 解析、日志写入、反向 HTTP 调用） |
| `function_process` | 与 dynamic 版本的核心区别所在：用 `RFC_GET_FUNCTION_INTERFACE_P` 只是为了按名找到 `REQUEST`/`RESPONSE` 两个固定参数对应的结构类型名，动态 `CREATE DATA` 实例化后直接 JSON 反序列化/序列化，**没有**逐字段校验，也**没有** `COMMITMODE` 事务托管——事务边界完全交给被调函数自己处理 |
| `xml_serialize` / `xml_deserialize` | typed 模式独有能力：借助 `ZCL_XML_DOCUMENT_BASE` 做 ABAP 数据对象 ⇄ XML 互转，支持通过 `name_mappings` 做字段名 ↔ XML 标签名映射，用于对接要求 XML 报文的 Web Service 场景 |
| `encode_base64` / `decode_base64` | 薄封装 `cl_http_utility`，用于传输二进制内容（如附件），正好补上 dynamic 模式"二进制字段不支持"的空白 |
| `ZFM_RFCTYPED_EXAMPLE` | 契约范例（非可运行实现），展示 typed 模式要求的接口形状与六步处理范式 |

## 调用流程

```
ICF → ZCL_HTTP_HANDLE=>IF_HTTP_EXTENSION~HANDLE_REQUEST
  → SPLIT_URI → CHECK_URI（查 ZTIF_GENERAL_CON）
  → WRITE_LOG(入站)
  → FUNCTION_PROCESS
      → RFC_GET_FUNCTION_INTERFACE_P 只为定位 REQUEST/RESPONSE 结构类型
      → CREATE DATA + json_deserialize 填充 REQUEST
      → CALL FUNCTION general_con-taskfm PARAMETER-TABLE (REQUEST/RESPONSE)
      → json_serialize 输出 RESPONSE
  → WRITE_LOG(出站) → HTTP Response
```

被暴露的每个函数必须自行完成：输入校验、幂等判断、BAPI 调用、`RETURN` 消息判定（E 和 A 都算失败，只判 E 会漏掉 A）、显式 COMMIT/ROLLBACK——网关层完全不介入事务与业务校验。

## 契约要求（以 `ZFM_RFCTYPED_EXAMPLE` 为范例）

```abap
FUNCTION zfm_xxx_example.
*"  IMPORTING
*"     REFERENCE(REQUEST) TYPE  YOUR_REQUEST_STRUCT
*"  EXPORTING
*"     REFERENCE(RESPONSE) TYPE  YOUR_RESPONSE_STRUCT
```

`RESPONSE` 结构固定包含两个字段：

- `RESULT`：success/fail 枚举，调用端必须判定此字段
- `MESSAGE`：人读文本，**禁止**调用端拿它做程序判定，也**禁止**在其中拼接连接串、用户名、内部主机地址等敏感信息

推荐的六步处理范式：输入归一化（如 ALPHA 转换）→ 存在性检查（幂等前置）→ 组装 BAPI 入参 → 调用标准 BAPI → 判定 `RETURN` 中的 E/A 消息 → 显式 COMMIT/ROLLBACK。

授权检查必须写在函数内部，不能依赖 HTTP 层已登录身份放行。

## 排障对照表

| 现象 | 排查方向 |
|---|---|
| 返回 404 | 检查 SICF 节点是否激活、`ZTIF_GENERAL_CON` 是否有对应 `IFCODE`/`ACTFLG` |
| 返回 401/403 | 检查 SU53 授权对象 |
| 字段值丢失/错位 | 检查 SE11 中 JSON key 大小写与结构字段名是否一致 |
| 调用返回成功但业务数据查不到 | 检查是否遗漏 `COMMIT WORK AND WAIT`，或用 SM13 查看更新任务 |
| 失败但消息不明确 | 用 SLG1 查看应用日志 |
| 链路层报错（连接失败等） | 检查 SMICM（ICM 状态）与 STRUST（SSL 证书） |

## 已知限制

- `ZFM_RFCTYPED_EXAMPLE` 是空实现骨架，客户必须按上述六步范式在目标系统自行实现真实的物料类型/行业领域/物料组等编码规则（这些编码属客户特定，不应写死在骨架中）。
- `ZCL_HTTP_HANDLE` 与 dynamic 模式的 `ZCL_REST2RFC_HANDLE` 存在大量重复代码（URI 解析、日志写入等），尚未抽出公共基类。
