# ABAP JSON 依赖与降级路径

> 适用范围:本仓库所有需要在 ABAP 侧做 JSON 序列化 / 反序列化的代码。
> 结论先行:`/UI2/CL_JSON` **不是 SAP_BASIS 标准对象**,后端系统可能没有。缺失时优先从 SAP 官方开源仓库获取,不要等 add-on 安装。

## 1. 依赖声明

| 项目 | 说明 |
|---|---|
| 首选类 | `/UI2/CL_JSON` |
| 交付载体 | 软件组件 **SAP_UI**(UI add-on for SAP NetWeaver),包 `/UI2/FOUNDATION_NWBC` |
| **不属于** | `SAP_BASIS` —— 因此 ECC / 老 NetWeaver 后端可能完全没有 |
| 最低可用 patch | 类属性 `VERSION` >= 12(低于此值缺少 `TS_AS_ISO8601`、`CONVERSION_EXITS` 等参数) |

典型踩坑:双栈架构下 Gateway / Fiori 前端服务器有这个类,**ECC 后端没有**。代码写在后端就会激活失败。

## 2. 可用性检查(三步)

```text
1. SE24  -> 输入 /UI2/CL_JSON,看是否存在
2. SE80  -> 打开包 /UI2/FOUNDATION_NWBC,看对象树是否为空
3. System -> Status -> Component Information -> 是否有组件 SAP_UI 及其 SP 级别
```

存在但方法参数缺失时,查看类属性 `VERSION`,属于 **patch level 过低**,不是缺失。

典型报错:

```text
Type "/UI2/CL_JSON" is unknown
```

## 3. 缺失时的获取路径(推荐)

SAP 官方维护的开源版本,与标准类**同源同步**:

- 仓库:<https://github.com/SAP/abap-to-json>
- 包名:`Z_UI2_JSON`
- 文档:仓库 `docs/basic.md`、`docs/advanced.md`

安装方式:

1. **abapGit(推荐)**:abapGit -> New Online -> 填入仓库 URL -> 指定目标包(本地包 `$Z_UI2_JSON` 或可传输包 `ZUI2_JSON`)-> Pull -> 激活。
2. **无 abapGit / 无外网**:仓库内为 abapGit 格式的 `.clas.abap` 源码,复制实现,SE24 建全局类粘贴激活;或作为 **local class** 内嵌进 INCLUDE,限单程序自用。

调用方式与标准类一致,仅换前缀:

```abap
" 序列化
DATA(lv_json) = zcl_json=>serialize(
                  data          = ls_data
                  pretty_name   = zcl_json=>pretty_mode-camel_case
                  ts_as_iso8601 = abap_true
                  format_output = abap_true ).

" 反序列化
zcl_json=>deserialize(
  EXPORTING json        = lv_json
            pretty_name = zcl_json=>pretty_mode-camel_case
  CHANGING  data        = ls_data ).
```

> 类名以所拉取仓库的实际对象为准,导入后在 SE24 确认,勿照抄本文档。

## 4. 降级链(按优先级)

| 顺序 | 方案 | 前提 | 取舍 |
|---|---|---|---|
| 1 | `/UI2/CL_JSON` | 系统已装 SAP_UI 且 `VERSION` >= 12 | 标准对象,首选 |
| 2 | `Z_UI2_JSON`(SAP/abap-to-json) | abapGit 或手工导入,满足仓库 Requirements | API 与标准类完全一致,迁移成本约等于 0 |
| 3 | `CALL TRANSFORMATION id` + `CL_SXML_STRING_WRITER` | `SAP_BASIS` >= 7.40 | 纯标准零依赖、性能最好;但 key 为 ABAP 大写字段名,无 `PRETTY_MODE`,无初始值压缩 |
| 4 | `ajson`(sbcgua/ajson) | abapGit | 支持 downport 到 7.31 及以下;API 不同,已有代码需改造 |
| 5 | `CL_FDT_JSON` / `CL_TREX_JSON_*` | 多数系统自带 | 非公开 API,`CL_TREX_JSON_DESERIALIZER` 部分系统缺失且行为有坑,仅应急 |
| — | `XCO_CP_JSON` | ABAP Cloud / Steampunk | 经典 On-Prem 不可用 |

方案 3 的最小实现:

```abap
DATA: lo_writer TYPE REF TO cl_sxml_string_writer,
      lv_json   TYPE string.

lo_writer = cl_sxml_string_writer=>create( type = if_sxml=>co_xt_json ).
CALL TRANSFORMATION id
  SOURCE data = ls_data
  RESULT XML lo_writer.
lv_json = cl_abap_codepage=>convert_from( lo_writer->get_output( ) ).

" JSON -> ABAP(入参为 xstring)
CALL TRANSFORMATION id
  SOURCE XML cl_abap_codepage=>convert_to( lv_json )
  RESULT data = ls_data.
```

## 5. 低版本(<= 7.31)注意

开源版源码使用较新 ABAP 语法(内联声明、字符串模板、`NEW`)。在 7.31 及以下激活报语法错时,不要逐行手改:

- 优先改用 **`ajson`** 或社区 downport 分支(abap2UI5 生态有成熟实践);
- 或将 JSON 组装职责移出 ABAP(见第 6 节)。

## 6. 边界:先确认序列化职责在哪一层

若集成走 `/sap/bc/soap/rfc`(SOAP)或 IDoc,链路上交换的是 **XML**,JSON 组装应落在 ABAP **之外**的调用端(Python / CLI / Agent 层)。
在为「ABAP 里没有 JSON 类」投入成本之前,先判断这个需求是否本就不该出现在 ABAP 侧——这是本仓库的默认取向:**ABAP 只暴露稳定语义接口,结构化编解码交给外层。**

## 7. 参考

- SAP/abap-to-json:<https://github.com/SAP/abap-to-json>
- sbcgua/ajson:<https://github.com/sbcgua/ajson>
- SAP Note 2500033(UI add-on / Gateway 组件安装前置)
- SAP Note 3568088(`/UI2/CL_JSON` patch 21)
- ABAP Keyword Documentation — ABAP and JSON / JSON-XML / asXML
