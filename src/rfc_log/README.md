# RFC Log Macro — 函数级日志埋点宏

与 `rest_rfc_dynamic` / `rest_rfc_typed` 在 HTTP handler 层统一做 `write_log` 不同，这是**面向 Function Module 内部**手工埋点的日志方案：不管调用方是 HTTP 网关、RFC destination 直连，还是批处理程序直接 `CALL FUNCTION`，只要在函数体首尾各插入一行宏调用，就能自动把该函数当次调用的全部 `IMPORTING`/`CHANGING`/`EXPORTING`/`TABLES` 参数按参数类别序列化成 JSON，落到与网关共用的同一张 `ZTIF_GENERAL_LOG` 表。

这弥补了网关层日志"只能看到网关自己转发的报文"的局限——对于非经由网关调用的 RFC，或需要记录 ABAP 侧真实取值（而非网关转换前的原始报文）的场景，这套宏更精细、更贴近实际执行状态。

## 核心组件

| 组件 | 职责 |
|---|---|
| `zfmparasavevariate`（宏，定义于 `zfmparasaveasjson.abap`） | 以函数名为参数：查 `ZTIF_GENERAL_CON` 判断该函数 `LOGFLG` 是否开启；开启则调 `RFC_GET_FUNCTION_INTERFACE_P` 缓存该函数的参数元数据，并落一份 SE37 测试变式（支持用真实报文原样回放） |
| `zfmparasaveasjson`（宏，同文件） | 以位置标记 `I`（入口）/`E`（出口）为参数：遍历缓存的参数元数据，用 `ASSIGN (string) TO <dync>` 动态解引用每个参数当前值，按参数类别调用 `/ui2/cl_json=>serialize` 拼成 JSON，写入 `ZTIF_GENERAL_LOG` 的 `MSGIN`（入口）/`MSGOT`（出口）；入口处用 `cl_system_uuid` 生成 `SERINO` 流水号，出口时用同一 `SERINO` 补齐同一行记录 |
| `ZFM_RFCLOG_EXAMPLE` | 埋点使用范例（非可运行实现），展示标准调用顺序与六段式业务逻辑范式 |
| `global-zfm_rfclog_example.abap` | Function-pool 全局 include，引入 `zfmparasaveasjson.abap` 与外部宏 `fbgenmac`（源码未随本仓库提供），声明位置常量 `gc_location_i`/`gc_location_e` |

## 使用方式

在需要埋点的函数体首尾按固定顺序插入：

```abap
FUNCTION z_my_function.

  fbgenmac 'Z_MY_FUNCTION'.           " 外部日志上下文宏：日志键 / 时间戳 / 调用方（本仓库未含源码，需目标系统已具备）
  zfmparasavevariate 'Z_MY_FUNCTION'. " 缓存参数元数据 + 判断 LOGFLG 开关 + 生成 SE37 测试变式
  zfmparasaveasjson gc_location_i.    " 入参快照 -> MSGIN，生成 SERINO 流水号
                                       " 此行之后禁止修改入参，否则日志与实际不符

  " ------ 六段式业务逻辑 ------
  " 1. 初始化
  " 2. 报文级校验
  " 3. 上下文与主数据校验
  " 4. 幂等校验
  " 5. 业务执行
  " 6. 提交边界（COMMIT/ROLLBACK）
  " 任何提前 RETURN 之前，必须先补一次出参快照再退出，
  " 否则同步 RFC 隐式 COMMIT WORK 会导致日志缺失出口记录。

  zfmparasaveasjson gc_location_e.    " 出参快照 -> MSGOT，正常路径的唯一出口

ENDFUNCTION.
```

写入的记录可用 `src/core` 目录下的 `ZRIF_GENERAL_LOG` 报表按 `IFCODE` + 日期/时间区间查询，双击报文列会按格式弹窗展示 JSON/XML/文本内容，也支持导出为本地文件。

## 已知限制

- `ZFM_RFCLOG_EXAMPLE` 本身是空骨架，仅保留契约与处理骨架说明，客户需按六段式范式自行实现真实业务逻辑。
- 宏依赖外部 include `fbgenmac`，其源码不在本仓库范围内，使用前需确认目标系统已具备该基础设施。
- `ASSIGN (string) TO <dync>` 属于动态字段访问，宏假设参数名与函数体内同名变量一致；若不一致，`sy-subrc <> 0` 会被 `CHECK` 静默跳过——该参数不会被记入日志，也不会报错，这是隐性的"漏记"风险点，需要开发者自行保证命名一致。
- 提交边界是最容易出错的一环：漏写出口快照会导致同步 RFC 隐式 `COMMIT WORK` 后日志缺失出口记录。
