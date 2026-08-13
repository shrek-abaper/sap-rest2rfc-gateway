# REST2RFC Dynamic Gateway — 动态反射式 REST→RFC 网关

让任意已在配置表 `ZTIF_GENERAL_CON` 注册、`ACTFLG` 已激活的标准/自定义 Function Module（含 BAPI）都能**零改造**地通过一个统一的 HTTP 入口以 JSON 调用，不要求目标函数遵循任何"REQUEST/RESPONSE"这类固定命名契约——绑定关系完全由 `RFC_GET_FUNCTION_INTERFACE_P` 在运行时读取的真实接口元数据驱动。新增一个接口只需要在配置表加一行，不需要为每个接口写映射代码。

## 核心组件

| 组件 | 职责 |
|---|---|
| `ZCL_REST2RFC_HANDLE` | 实现 `IF_HTTP_EXTENSION` 的 HTTP handler 类，挂在 SICF 节点上作为请求入口 |
| `check_uri` / `split_uri` | 只允许 `POST /sap/bc/rest2rfc?RFC=<taskfm>`；按 `RFC` 参数反查 `ZTIF_GENERAL_CON`，未注册返回 404，`ACTFLG` 未激活也返回 404，非 POST 返回 405 |
| `function_process` | 核心分发方法：调用 `ZCL_REST2RFC_BIND=>JSON_TO_PARMBIND` 做 JSON→参数绑定与校验，成功后动态 `CALL FUNCTION`，再按 `COMMITMODE` 决定事务归属，最后把输出参数拼成 JSON 返回 |
| `write_log` | 按 `LOGFLG` 开关把入站/出站报文、状态码写入 `ZTIF_GENERAL_LOG` |
| `http_consumer` | 反向能力：作为 HTTP 客户端调用外部系统，复用同一份日志写入逻辑 |
| `ZCL_REST2RFC_BIND` | JSON→动态 RFC 参数绑定的核心类，分三层：`PARSE_JSON`（依赖 `/UI2/CL_JSON`，唯一耦合 JSON 库的一层）→ `MAP_NODE`（递归校验+赋值，与具体 JSON 库无关）→ `JSON_TO_PARMBIND`（顶层 key → 参数 → `PARAMETER-TABLE`） |
| `get_interface` | 调 `RFC_GET_FUNCTION_INTERFACE_P` 读取目标函数的真实参数元数据 |
| `rest2rfc_meta.py` | 命令行工具：借助网关自身的动态调用能力，反向读取任意 RFC/BAPI 的完整参数树，生成结构说明、请求/响应示例 JSON 与接口文档 |

## 调用流程

```
ICF → ZCL_REST2RFC_HANDLE=>IF_HTTP_EXTENSION~HANDLE_REQUEST
  → SPLIT_URI → CHECK_URI（查 ZTIF_GENERAL_CON，校验 RFC 参数/激活状态）
  → WRITE_LOG(入站)
  → FUNCTION_PROCESS
      → ZCL_REST2RFC_BIND=>JSON_TO_PARMBIND
            → GET_INTERFACE（RFC_GET_FUNCTION_INTERFACE_P）
            → PARSE_JSON（/UI2/CL_JSON=>GENERATE）
            → MAP_NODE（递归校验+赋值）
      → CALL FUNCTION general_con-taskfm PARAMETER-TABLE ...
      → 按 COMMITMODE 判定 RETURN 消息并 COMMIT/ROLLBACK
      → 输出参数拼 JSON
  → WRITE_LOG(出站) → HTTP Response
```

## 配置说明

网关的路由完全由 `ZTIF_GENERAL_CON` 驱动，关键字段：

| 字段 | 说明 |
|---|---|
| `IFCODE` | 接口编码（主键） |
| `TASKFM` | 目标 Function Module 名称 |
| `ACTFLG` | 是否激活，'X' 才可被调用，否则 404 |
| `LOGFLG` | 是否记录调用日志 |
| `COMMITMODE` | 事务归属：` `/`N`=只读不管、`G`=网关托管（检查 `RETURN` 中的 E/A 消息后 COMMIT/ROLLBACK）、`F`=函数自行提交，网关不插手 |

`COMMITMODE` 是表结构后加的字段，若目标表尚未包含该字段，`function_process` 中需要把取值逻辑改为写死 `lv_commitmode = 'N'`。

## 请求示例

```
POST /sap/bc/rest2rfc?RFC=Z_MY_BAPI
Content-Type: application/json

{
  "REQUEST_PARAM_1": "value",
  "REQUEST_STRUCT": { "FIELD": "value" }
}
```

响应为该函数所有 `E`/`C`/`T` 类输出参数拼装出的一个 JSON 对象；出错时返回结构化错误 JSON（含 `UNKNOWN_PARAM`/`MISSING_PARAM`/`TYPE_MISMATCH` 等错误码）。

## rest2rfc_meta.py 使用方式

依赖环境变量或命令行参数提供连接信息：

```bash
export REST2RFC_HOST=https://sap-dev.example.com:44300
export REST2RFC_USER=RFCUSER
export REST2RFC_PASSWORD=secret
export REST2RFC_CLIENT=100

python rest2rfc_meta.py --func Z_MY_BAPI
```

会生成 `<FUNC>.structure.txt`（参数树）、`<FUNC>.request.json` / `.response.json`（示例报文骨架）、`<FUNC>.docs.md`（接口文档），凭证不会写入任何输出文件。工具依赖网关本身已注册好元数据 action（`IFCODE=SYS_META` 等），仅供内部开发排查使用。

## 已知限制（设计取舍，非 bug）

`/UI2/CL_JSON=>GENERATE` 路线存在以下已知取舍：

- 空对象 `{}` 与空数组 `[]` 无法区分，统一按空值处理，不会触发 `TYPE_MISMATCH`；
- 所有标量退化为字符串，原始 number/bool/null 类型区分丢失；
- JSON key 统一转大写，报错路径里看不到原始大小写；
- 重复的 JSON key 会被静默合并，`DUPLICATE_FIELD` 校验因此无法被触发。

此外：

- 二进制 / RAW / XSTRING 字段不支持隐式转换，`move_value` 会直接报 `NOT_SUPPORTED`（如需 Base64 传输二进制，参考 `rest_rfc_typed` 目录的实现）。
- 若语法检查器不识别 `ABAP_FUNC_EXCPBIND`/`_TAB` 等类型组对象，需要在目标系统手工替换为本地定义的哈希表类型。
