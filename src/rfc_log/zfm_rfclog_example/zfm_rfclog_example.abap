FUNCTION zfm_rfclog_example.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(INPUT_EXAMPLE) TYPE  STRING
*"  EXPORTING
*"     VALUE(OUTPUT_EXAMPLE) TYPE  STRING
*"     VALUE(EV_MSGTYPE) TYPE  BAPI_MTYPE
*"     VALUE(EV_MESSAGE) TYPE  BAPI_MSG
*"----------------------------------------------------------------------

  fbgenmac 'ZFM_RFCLOG_EXAMPLE'.           " 生成本函数的日志宏上下文（日志键 / 时间戳 / 调用方）
  zfmparasavevariate 'ZFM_RFCLOG_EXAMPLE'. " 落 SE37 测试变式，支持用真实报文原样回放
  zfmparasaveasjson gc_location_i.         " 入参快照（I=Import）。此行之后禁止修改入参，否则日志与实际不符

  "=================STRART===================
*
* 【本段填写实际 RFC 业务逻辑，建议固定为六段式】
*
* Step 0  初始化
*         出参与消息字段显式 CLEAR，消息类型置默认成功态。
*         RFC 跑在长生命周期工作进程里，不能依赖上次调用的残值。
*
* Step 1  报文级校验（纯确定性，不读数据库）
*         必填 / 长度 / 枚举 / 日期格式。属于「调用方错误」，一次性收集全部错误再返回，
*         比查到第一个错就退更省联调回合。
*
* Step 2  上下文与主数据校验
*         组织（BUKRS / WERKS）→ 主数据存在性（MARA / MARC / LFA1）→ 业务权限（AUTHORITY-CHECK）。
*
* Step 3  幂等校验
*         以调用方业务唯一键（如 XBLNR / 外部单号）查 Z 日志表的处理状态，不要用「查业务表是否存在」，
*         并发双开时那是 TOCTOU 竞态。已成功 → 直接回原单据号；处理中 → 返回并发中让调用方重试。
*
* Step 4  业务执行
*         优先调标准 BAPI，其次自研逻辑；收集 RETURN 表，不在这一步提交。
*
* Step 5  提交边界（本函数最容易出事的一段）
*         有 E 消息或关键单据号为空 → BAPI_TRANSACTION_ROLLBACK；
*         否则 → BAPI_TRANSACTION_COMMIT（WAIT = 'X'，保证后续能读到刚过账的凭证）。
*
* Step 6  组装出参与日志状态
*         回写单据号、消息类型、消息文本，并更新 Z 日志表状态为成功 / 失败。
*
* 【错误分支的强制写法】任何提前退出前，必须先补一次 E 快照再 RETURN：
*
*           ev_msgtype = gc_type_e.
*           " ...拼装 ev_message...
*           zfmparasaveasjson gc_location_e.
*           RETURN.                        " 缺 RETURN → 同步 RFC 返回触发隐式 COMMIT WORK
*
  "=================END======================

  zfmparasaveasjson gc_location_e.         " 出参快照（E=Export）。正常路径唯一出口
ENDFUNCTION.


*Messages
*----------------------------------------------------------
*
* Message class: V2
*436   Test data record &1 was created for function module &2

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2026. Sap Release 750
