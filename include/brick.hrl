%%%----------------------------------------------------------------------
%%% Copyright (c) 2007-2010 Gemini Mobile Technologies, Inc.  All rights reserved.
%%%
%%% Licensed under the Apache License, Version 2.0 (the "License");
%%% you may not use this file except in compliance with the License.
%%% You may obtain a copy of the License at
%%%
%%%     http://www.apache.org/licenses/LICENSE-2.0
%%%
%%% Unless required by applicable law or agreed to in writing, software
%%% distributed under the License is distributed on an "AS IS" BASIS,
%%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%%% See the License for the specific language governing permissions and
%%% limitations under the License.
%%%
%%% File    : brick.hrl
%%% Purpose : ETS brick common stuff
%%%----------------------------------------------------------------------

-ifndef(ets_brick_hrl).
-define(ets_brick_hrl, true).

-record(log_q, {
          time,                                 % erlang:time() QQQ debugging only
          logging_serial = 0,                   % logging_op_serial
          thisdo_mods = [],                     % ops for this do
          doflags,                              % DoFlags for this do
          from,                                 % gen_server:reply() to
          reply                                 % gen_server:reply() info
         }).

-record(dirty_q, {
          from,                                 % gen_server:reply info
          do_op                                 % {do, SentAt, DoList, DoFlags}
         }).

-record(scav, {
          options = [],                         % prop_list()
          work_dir,                             % string() Working files tmp dir
          wal_mod,                              % atom()
          destructive,                          % boolean() Do we
                                                % delete/truncate/modify stuff?
          skip_reads,                           % boolean() Do we skip blob
                                                % reads also? For use with
                                                % destructive=false only!
          skip_live_percentage_greater_than = 0, % integer() skip threshold
          name,                                 % atom() brick name
          log,                                  % pid() log server
          log_dir,                              % string() log dir path
          cur_seq,                              % integer() current sequence #
          last_check_seq,                       % integer() last checkpoint seq#
          throttle_bytes,                       % integer() throttle byte rate
          throttle_pid,                         % pid() private throttle server
          sorter_size,                          % int() bytes
          bricks = [],                          % list() CommonLog bricks
          exclusive_p = true,                   % boolean() Avoid parallel runs
          log_fun,                              % fun/2 info logging impl.
          phase10_fun,                          % fun/7 Phase 10 implementation
          update_locations                      % fun/2
         }).

%% Write-ahead log hunk types
-define(LOGTYPE_METADATA,     1).
-define(LOGTYPE_BLOB,         2).
-define(LOGTYPE_BAD_SEQUENCE, 3).

%%
%% gmt_elog stuff
%%

-include("gmt_elog.hrl").

%% Any component
-define(CAT_GENERAL,              (1 bsl  0)). % General: init, terminate, ...
%% brick_ets, mostly, except where there's cross-over purpose.
-define(CAT_OP,                   (1 bsl  1)). % Op processing
-define(CAT_ETS,                  (1 bsl  2)). % ETS table
-define(CAT_TLOG,                 (1 bsl  3)). % Txn log
-define(CAT_REPAIR,               (1 bsl  4)). % Repair
%% brick_server, mostly, except where there's cross-over purpose.
-define(CAT_CHAIN,                (1 bsl  5)). % Chain-related
-define(CAT_MIGRATE,              (1 bsl  6)). % Migration-related
-define(CAT_HASH,                 (1 bsl  7)). % Hash-related

%% We put the error_logger calls in these macros because we want to
%% include those messages in the trace log also.  Otherwise, sorting
%% events between the app log and the gmt_elog log is a huge, huge
%% problem.

-define(E_INFO(Fmt, Args),
        begin ?ELOG_INFO_C(?CAT_GENERAL, Fmt, Args),
              error_logger:info_msg(Fmt, Args)
        end).
-define(E_ERROR(Fmt, Args),
        begin ?ELOG_ERR_C(?CAT_GENERAL, Fmt, Args),
              error_logger:error_msg(Fmt, Args)
        end).
-define(E_WARNING(Fmt, Args),
        begin ?ELOG_WARNING_C(?CAT_GENERAL, Fmt, Args),
              error_logger:warning_msg(Fmt, Args)
        end).
-define(E_DBG(Cat, Fmt, Args),
        ?ELOG_DEBUG_C(Cat, Fmt, Args)).

-define(DBG_GEN(Fmt, Args),
        ?ELOG_DEBUG_C(?CAT_GENERAL, Fmt, Args)).
-define(DBG_OP(Fmt, Args),
        ?ELOG_DEBUG_C(?CAT_OP, Fmt, Args)).
-define(DBG_ETS(Fmt, Args),
        ?ELOG_DEBUG_C(?CAT_ETS, Fmt, Args)).
-define(DBG_TLOG(Fmt, Args),
        ?ELOG_DEBUG_C(?CAT_TLOG, Fmt, Args)).
-define(DBG_REPAIR(Fmt, Args),
        ?ELOG_DEBUG_C(?CAT_REPAIR, Fmt, Args)).
-define(DBG_CHAIN(Fmt, Args),
        ?ELOG_DEBUG_C(?CAT_CHAIN, Fmt, Args)).
-define(DBG_CHAIN_TLOG(Fmt, Args),
        ?ELOG_DEBUG_C((?CAT_CHAIN bor ?CAT_TLOG), Fmt, Args)).
-define(DBG_MIGRATE(Fmt, Args),
        ?ELOG_DEBUG_C(?CAT_MIGRATE, Fmt, Args)).
-define(DBG_HASH(Fmt, Args),
        ?ELOG_DEBUG_C(?CAT_HASH, Fmt, Args)).

%% Hold-over from brick_simple:dumblog/1, which only took a single arg.

-define(DBG_GENx(Arg),
        ?ELOG_DEBUG_C(?CAT_GENERAL, "~p", [Arg])).
-define(DBG_OPx(Arg),
        ?ELOG_DEBUG_C(?CAT_OP, "~p", [Arg])).
-define(DBG_ETSx(Arg),
        ?ELOG_DEBUG_C(?CAT_ETS, "~p", [Arg])).
-define(DBG_TLOGx(Arg),
        ?ELOG_DEBUG_C(?CAT_TLOG, "~p", [Arg])).
-define(DBG_REPAIRx(Arg),
        ?ELOG_DEBUG_C(?CAT_REPAIR, "~p", [Arg])).
-define(DBG_CHAINx(Arg),
        ?ELOG_DEBUG_C(?CAT_CHAIN, "~p", [Arg])).
-define(DBG_CHAIN_TLOGx(Arg),
        ?ELOG_DEBUG_C((?CAT_CHAIN bor ?CAT_TLOG), "~p", [Arg])).
-define(DBG_MIGRATEx(Arg),
        ?ELOG_DEBUG_C(?CAT_MIGRATE, "~p", [Arg])).
-define(DBG_HASHx(Arg),
        ?ELOG_DEBUG_C(?CAT_HASH, "~p", [Arg])).

-endif. % -ifndef(ets_brick_hrl).
