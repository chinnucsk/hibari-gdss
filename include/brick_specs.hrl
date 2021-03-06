%%%----------------------------------------------------------------------
%%% Copyright (c) 2009-2010 Gemini Mobile Technologies, Inc.  All rights reserved.
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
%%% File    : brick_specs.hrl
%%% Purpose : brick specs
%%%----------------------------------------------------------------------

-ifndef(brick_specs).
-define(brick_specs, true).

%% Hibari: Experiment from UBF contract.  Reordering is required, since
%%      the -type definitions cannot "look ahead".  Also, the syntax
%%      is very slightly different.

-type do_flags_list():: [] | [sync_override].
-type key()          :: binary() | iolist().  % Differs from UBF contract
-type bin_key()      :: binary().
-type table_name()   :: atom().
-type time_t()       :: integer().
-type ts()           :: non_neg_integer().
-type val()          :: binary() | iolist().  % Differs from UBF contract

-type exp_time()     :: time_t().
-type do_op_flag0()  :: {testset, ts()} |
                        local_op_only_do_not_forward | %% internal use only
                        value_in_ram |                 %% internal use only
                        witness |
                        get_all_attribs |
                        %% Flags for get_many
                        {max_num, integer()} |
                        {binary_prefix, binary()} |
                        %% hide: get_many_raw_storetuples |
                        must_exist |
                        must_not_exist |
                        %% Sent by server, should not be sent by client.
                        {val_len, integer()} |
                        {quota_items | quota_bytes |
                         quota_items_used | quota_bytes_used, integer()}.
-type do_op_flag()   :: do_op_flag0() |
                        %% Section: Flags that pass through brick and are
                        %%          stored with key.
                        {binary(), binary()}.
-type flags_list()   :: [do_op_flag()].
-type flags_list0()  :: [do_op_flag0()].

-type txn()          :: txn.
-type add()          :: {add,     bin_key(), ts(), val(), exp_time(), flags_list()}.
-type delete()       :: {delete,  bin_key(),                          flags_list()}.
-type get()          :: {get,     bin_key(),                          flags_list()}.
-type get_many()     :: {get_many,bin_key(),                          flags_list()}.
-type replace()      :: {replace, bin_key(), ts(), val(), exp_time(), flags_list()}.
%% set() is a built-in type now, must use a different name for this type.
-type 'set__'()      :: {set,     bin_key(), ts(), val(), exp_time(), flags_list()}.

-type do1_op()       :: txn() | add() | delete() | get() | get_many() |
                        replace() | 'set__'().
-type do_op_list()   :: [do1_op()].

-type do1_res_ok()   :: ok |
                        key_not_exist |
                        {ok, val()} |
                        {ok, ts()} |
                        {ok, ts(), val()} |
                        {ok, ts(), flags_list()} |
                        {ok, ts(), val(), time_t(), flags_list()} |
                        {ok, {[{key(), ts()}], boolean()}} |
                        {ok, {[{key(), ts(), flags_list()}], boolean()}} |
                        {ok, {[{key(), ts(), val(), time_t(), flags_list()}], boolean()}} |
                        %% The 'txn' atom is present only because of QuickCheck:
                        %% a dumb generator may put 'txn' anywhere in the
                        %% do_op_list().  Real users must take greater care when
                        %% sending 'txn' (see above), and real users won't see
                        %% 'txn' in their results.
                        txn.
-type do1_res_fail() :: {key_exists, ts()} |
                        key_not_exist |
                        {ts_error, ts()} |
                        invalid_flag_present |
                        brick_not_available.

-type do1_res()      :: do1_res_ok() | do1_res_fail().
-type do_res_fail()  :: {txn_fail, [{integer(), do1_res_fail()}]} | {wrong_brick, term()}.
-type do_res()       :: [do1_res()] | do_res_fail().

-endif. % -ifndef(brick_specs)
