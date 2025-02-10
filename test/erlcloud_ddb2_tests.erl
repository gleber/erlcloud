%% -*- mode: erlang;erlang-indent-level: 4;indent-tabs-mode: nil -*-
-module(erlcloud_ddb2_tests).
-include_lib("eunit/include/eunit.hrl").
-include("erlcloud.hrl").
-include("erlcloud_ddb2.hrl").

%% Unit tests for ddb.
%% These tests work by using meck to mock erlcloud_httpc. There are two classes of test: input and output.
%%
%% Input tests verify that different function args produce the desired JSON request.
%% An input test list provides a list of funs and the JSON that is expected to result.
%%
%% Output tests verify that the http response produces the correct return from the fun.
%% An output test lists provides a list of response bodies and the expected return.

%% The _ddb_test macro provides line number annotation to a test, similar to _test, but doesn't wrap in a fun
-define(_ddb_test(T), {?LINE, T}).
%% The _f macro is a terse way to wrap code in a fun. Similar to _test but doesn't annotate with a line number
-define(_f(F), fun() -> F end).

-export([validate_body/2]).

%%%===================================================================
%%% Test entry points
%%%===================================================================

operation_test_() ->
    {foreach,
     fun start/0,
     fun stop/1,
     [fun error_handling_tests/1,
      fun batch_get_item_input_tests/1,
      fun batch_get_item_output_tests/1,
      fun batch_write_item_input_tests/1,
      fun batch_write_item_output_tests/1,
      fun create_backup_input_tests/1,
      fun create_backup_output_tests/1,
      fun create_global_table_input_tests/1,
      fun create_global_table_output_tests/1,
      fun create_table_input_tests/1,
      fun create_table_output_tests/1,
      fun delete_backup_input_tests/1,
      fun delete_backup_output_tests/1,
      fun delete_item_input_tests/1,
      fun delete_item_output_tests/1,
      fun delete_table_input_tests/1,
      fun delete_table_output_tests/1,
      fun describe_backup_input_tests/1,
      fun describe_backup_output_tests/1,
      fun describe_continuous_backups_input_tests/1,
      fun describe_continuous_backups_output_tests/1,
      fun describe_limits_input_tests/1,
      fun describe_limits_output_tests/1,
      fun describe_global_table_input_tests/1,
      fun describe_global_table_output_tests/1,
      fun describe_global_table_settings_input_tests/1,
      fun describe_global_table_settings_output_tests/1,
      fun describe_table_input_tests/1,
      fun describe_table_output_tests/1,
      fun describe_table_replica_auto_scaling_input_tests/1,
      fun describe_table_replica_auto_scaling_output_tests/1,
      fun describe_time_to_live_input_tests/1,
      fun describe_time_to_live_output_tests/1,
      fun get_item_input_tests/1,
      fun get_item_output_tests/1,
      fun get_item_output_map_tests/1,
      fun get_item_output_typed_tests/1,
      fun get_item_output_typed_map_tests/1,
      fun list_backups_input_tests/1,
      fun list_backups_output_tests/1,
      fun list_global_tables_input_tests/1,
      fun list_global_tables_output_tests/1,
      fun list_tables_input_tests/1,
      fun list_tables_output_tests/1,
      fun list_tags_of_resource_input_tests/1,
      fun list_tags_of_resource_output_tests/1,
      fun put_item_input_tests/1,
      fun put_item_output_tests/1,
      fun put_item_output_map_tests/1,
      fun q_input_tests/1,
      fun q_output_tests/1,
      fun restore_table_from_backup_input_tests/1,
      fun restore_table_from_backup_output_tests/1,
      fun restore_table_to_point_in_time_input_tests/1,
      fun restore_table_to_point_in_time_output_tests/1,
      fun scan_input_tests/1,
      fun scan_output_tests/1,
      fun tag_resource_input_tests/1,
      fun tag_resource_output_tests/1,
      fun transact_get_items_input_tests/1,
      fun transact_get_items_output_tests/1,
      fun transact_write_items_input_tests/1,
      fun transact_write_items_output_tests/1,
      fun untag_resource_input_tests/1,
      fun untag_resource_output_tests/1,
      fun update_continuous_backups_input_tests/1,
      fun update_continuous_backups_output_tests/1,
      fun update_item_input_tests/1,
      fun update_item_output_tests/1,
      fun update_global_table_input_tests/1,
      fun update_global_table_output_tests/1,
      fun update_global_table_settings_input_tests/1,
      fun update_global_table_settings_output_tests/1,
      fun update_table_input_tests/1,
      fun update_table_output_tests/1,
      fun update_table_replica_auto_scaling_input_tests/1,
      fun update_table_replica_auto_scaling_output_tests/1,
      fun update_time_to_live_input_tests/1,
      fun update_time_to_live_output_tests/1
     ]}.

start() ->
    meck:new(erlcloud_httpc),
    ok.

stop(_) ->
    meck:unload(erlcloud_httpc).

%%%===================================================================
%%% Input test helpers
%%%===================================================================

-type expected_body() :: string().

sort_json([{_, _} | _] = Json) ->
    %% Value is an object
    SortedChildren = [{K, sort_json(V)} || {K,V} <- Json],
    lists:keysort(1, SortedChildren);
sort_json([_|_] = Json) ->
    %% Value is an array
    [sort_json(I) || I <- Json];
sort_json(V) ->
    V.

%% verifies that the parameters in the body match the expected parameters
-spec validate_body(binary(), expected_body()) -> ok.
validate_body(<<>>, "") -> ok;
validate_body(<<>> = Actual, Want) ->
  ?debugFmt("~nEXPECTED~n~p~nACTUAL~n~p~n", [Want, Actual]),
  ?assertEqual(Want, Actual);
validate_body(Body, Expected) ->
    Want = sort_json(jsx:decode(list_to_binary(Expected), [{return_maps, false}])),
    Actual = sort_json(jsx:decode(Body, [{return_maps, false}])),
    case Want =:= Actual of
        true -> ok;
        false ->
            ?debugFmt("~nEXPECTED~n~p~nACTUAL~n~p~n", [Want, Actual])
    end,
    ?assertEqual(Want, Actual).

%% returns the mock of the erlcloud_httpc function input tests expect to be called.
%% Validates the request body and responds with the provided response.
-spec input_expect(string(), expected_body()) -> fun().
input_expect(Response, Expected) ->
    fun(_Url, post, _Headers, Body, _Timeout, _Config) ->
            validate_body(Body, Expected),
            {ok, {{200, "OK"}, [], list_to_binary(Response)}}
    end.

%% input_test converts an input_test specifier into an eunit test generator
-type input_test_spec() :: {pos_integer(), {fun(), expected_body()} | {string(), fun(), expected_body()}}.
-spec input_test(string(), input_test_spec()) -> tuple().
input_test(Response, {Line, {Description, Fun, Expected}}) when
      is_list(Description) ->
    {Description,
     {Line,
      fun() ->
              meck:expect(erlcloud_httpc, request, input_expect(Response, Expected)),
              erlcloud_ddb2:configure(string:copies("A", 20), string:copies("a", 40)),
              Fun()
      end}}.
%% input_test(Response, {Line, {Fun, Params}}) ->
%%     input_test(Response, {Line, {"", Fun, Params}}).

%% input_tests converts a list of input_test specifiers into an eunit test generator
-spec input_tests(string(), [input_test_spec()]) -> [tuple()].
input_tests(Response, Tests) ->
    [input_test(Response, Test) || Test <- Tests].

%%%===================================================================
%%% Output test helpers
%%%===================================================================

%% returns the mock of the erlcloud_httpc function output tests expect to be called.
-spec output_expect(string()) -> fun().
output_expect(Response) ->
    fun(_Url, post, _Headers, _Body, _Timeout, _Config) ->
            {ok, {{200, "OK"}, [], list_to_binary(Response)}}
    end.

%% output_test converts an output_test specifier into an eunit test generator
-type output_test_spec() :: {pos_integer(), {string(), term()} | {string(), string(), term()}}.
-spec output_test(fun(), output_test_spec()) -> tuple().
output_test(Fun, {Line, {Description, Response, Result}}) ->
    {Description,
     {Line,
      fun() ->
              meck:expect(erlcloud_httpc, request, output_expect(Response)),
              erlcloud_ddb2:configure(string:copies("A", 20), string:copies("a", 40)),
              Actual = Fun(),
              case Result =:= Actual of
                  true -> ok;
                  false ->
                      ?debugFmt("~nEXPECTED~n~p~nACTUAL~n~p~n", [Result, Actual])
              end,
              ?assertEqual(Result, Actual)
      end}}.
%% output_test(Fun, {Line, {Response, Result}}) ->
%%     output_test(Fun, {Line, {"", Response, Result}}).

%% output_tests converts a list of output_test specifiers into an eunit test generator
-spec output_tests(fun(), [output_test_spec()]) -> [term()].
output_tests(Fun, Tests) ->
    [output_test(Fun, Test) || Test <- Tests].


%%%===================================================================
%%% Error test helpers
%%%===================================================================

-spec httpc_response(pos_integer(), string()) -> tuple().
httpc_response(Code, Body) ->
    {ok, {{Code, ""}, [], list_to_binary(Body)}}.

-type error_test_spec() :: {pos_integer(), {string(), list(), term()}}.
-spec error_test(fun(), error_test_spec()) -> tuple().
error_test(Fun, {Line, {Description, Responses, Result}}) ->
    %% Add a bogus response to the end of the request to make sure we don't call too many times
    Responses1 = Responses ++ [httpc_response(200, "TOO MANY REQUESTS")],
    {Description,
     {Line,
      fun() ->
              meck:sequence(erlcloud_httpc, request, 6, Responses1),
              erlcloud_ddb2:configure(string:copies("A", 20), string:copies("a", 40)),
              Actual = Fun(),
              ?assertEqual(Result, Actual)
      end}}.

-spec error_tests(fun(), [error_test_spec()]) -> [term()].
error_tests(Fun, Tests) ->
    [error_test(Fun, Test) || Test <- Tests].

%%%===================================================================
%%% Actual test specifiers
%%%===================================================================

input_exception_test_() ->
    [?_assertError({erlcloud_ddb, {invalid_attr_value, {n, "string"}}},
                   erlcloud_ddb2:get_item(<<"Table">>, {<<"K">>, {n, "string"}}))]
    ++ input_exception_failures_test_().

-dialyzer({nowarn_function, input_exception_failures_test_/0}).
input_exception_failures_test_() ->
     %% This test causes an expected dialyzer error
    [?_assertError({erlcloud_ddb, {invalid_item, <<"Attr">>}},
                   erlcloud_ddb2:put_item(<<"Table">>, <<"Attr">>)),
     ?_assertError({erlcloud_ddb, {invalid_opt, {myopt, myval}}},
                   erlcloud_ddb2:list_tables([{myopt, myval}]))].

%% Error handling tests based on:
%% http://docs.aws.amazon.com/amazondynamodb/latest/developerguide/ErrorHandling.html
error_handling_tests(_) ->
    OkResponse = httpc_response(200, "
{\"Item\":
    {\"friends\":{\"SS\":[\"Lynda\", \"Aaron\"]},
     \"status\":{\"S\":\"online\"}
    },
\"ConsumedCapacityUnits\": 1
}"
                                  ),
    OkResult = {ok, [{<<"friends">>, [<<"Lynda">>, <<"Aaron">>]},
                     {<<"status">>, <<"online">>}]},

    Tests =
        [?_ddb_test(
            {"Test retry after ProvisionedThroughputExceededException",
             [httpc_response(400, "
{\"__type\":\"com.amazonaws.dynamodb.v20111205#ProvisionedThroughputExceededException\",
\"message\":\"The level of configured provisioned throughput for the table was exceeded. Consider increasing your provisioning level with the UpdateTable API\"}"
                            ),
              OkResponse],
             OkResult}),
         ?_ddb_test(
            {"Test ConditionalCheckFailed error",
             [httpc_response(400, "
{\"__type\":\"com.amazonaws.dynamodb.v20111205#ConditionalCheckFailedException\",
\"message\":\"The expected value did not match what was stored in the system.\"}"
                            )],
             {error, {<<"ConditionalCheckFailedException">>, <<"The expected value did not match what was stored in the system.">>}}}),
         ?_ddb_test(
            {"Test retry after 500",
             [httpc_response(500, ""),
              OkResponse],
             OkResult})
        ],

    error_tests(?_f(erlcloud_ddb2:get_item(<<"table">>, {<<"k">>, <<"v">>})), Tests),

    TransactionErrorResult = {error, {<<"TransactionCanceledException">>,
                                      {<<"Transaction cancelled, please refer cancellation reasons for specific reasons [None, ConditionalCheckFailed]">>,
                                       [{<<"None">>, null}, {<<"ConditionalCheckFailed">>, <<"The conditional request failed">>}]}}},

    TransactOkResponse = httpc_response(200, "{}"),
    TransactOkResult = {ok, []},

    TransactTests =
        [?_ddb_test(
            {"Test return output for TransactionCanceledException error",
             [httpc_response(400, "
{
    \"__type\":\"com.amazonaws.dynamodb.v20120810#TransactionCanceledException\",
    \"CancellationReasons\": [
        {
            \"Code\":\"None\",
        },
        {
            \"Code\":\"ConditionalCheckFailed\",
            \"Message\":\"The conditional request failed\",
        }
    ],
    \"message\":\"Transaction cancelled, please refer cancellation reasons for specific reasons [None, ConditionalCheckFailed]\"
}"
                            )],
              TransactionErrorResult}),
         ?_ddb_test(
            {"Test retry after ProvisionedThroughputExceeded cancellation reason",
             [httpc_response(400, "
{
    \"__type\":\"com.amazonaws.dynamodb.v20120810#TransactionCanceledException\",
    \"CancellationReasons\": [
        {
            \"Code\":\"None\",
        },
        {
            \"Code\":\"ProvisionedThroughputExceeded\",
            \"Message\":\"The level of configured provisioned throughput for the table was exceeded. Consider increasing your provisioning level with the UpdateTable API\",
        }
    ],
    \"message\":\"Transaction cancelled, please refer cancellation reasons for specific reasons [None, ProvisionedThroughputExceeded]\"
}"
                            ),
              TransactOkResponse],
             TransactOkResult})
        ],

    Transact = [{put, {<<"table">>, [{<<"k">>, {s, <<"v">>}}], []}},
                {condition_check, {<<"table">>, [{<<"k">>, {s, <<"v2">>}}],
                                   [{condition_expression, <<"approved = :a">>},
                                    {expression_attribute_values, [{<<":a">>, <<"yes">>}]}]}}],

    error_tests(?_f(erlcloud_ddb2:transact_write_items(Transact)), TransactTests).

%% BatchGetItem test based on the API examples:
%% http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_BatchGetItem.html
batch_get_item_input_tests(_) ->
    Tests =
        [?_ddb_test(
            {"BatchGetItem example request",
             ?_f(erlcloud_ddb2:batch_get_item(
                   [{<<"Forum">>,
                     [{<<"Name">>, {s, <<"Amazon DynamoDB">>}},
                      {<<"Name">>, {s, <<"Amazon RDS">>}},
                      {<<"Name">>, {s, <<"Amazon Redshift">>}}],
                     [{attributes_to_get, [<<"Name">>, <<"Threads">>, <<"Messages">>, <<"Views">>]}]},
                    {<<"Thread">>,
                     [[{<<"ForumName">>, {s, <<"Amazon DynamoDB">>}},
                       {<<"Subject">>, {s, <<"Concurrent reads">>}}]],
                     [{attributes_to_get, [<<"Tags">>, <<"Message">>]}]}],
                   [{return_consumed_capacity, total}])), "
{
    \"RequestItems\": {
        \"Forum\": {
            \"Keys\": [
                {
                    \"Name\":{\"S\":\"Amazon DynamoDB\"}
                },
                {
                    \"Name\":{\"S\":\"Amazon RDS\"}
                },
                {
                    \"Name\":{\"S\":\"Amazon Redshift\"}
                }
            ],
            \"AttributesToGet\": [
                \"Name\",\"Threads\",\"Messages\",\"Views\"
            ]
        },
        \"Thread\": {
            \"Keys\": [
                {
                    \"ForumName\":{\"S\":\"Amazon DynamoDB\"},
                    \"Subject\":{\"S\":\"Concurrent reads\"}
                }
            ],
            \"AttributesToGet\": [
                \"Tags\",\"Message\"
            ]
        }
    },
    \"ReturnConsumedCapacity\": \"TOTAL\"
}"
            }),
         ?_ddb_test(
             {"BatchGetItem example request with ProjectionExpression",
              ?_f(erlcloud_ddb2:batch_get_item(
                    [{<<"Forum">>,
                      [{<<"Name">>, {s, <<"Amazon DynamoDB">>}},
                       {<<"Name">>, {s, <<"Amazon RDS">>}},
                       {<<"Name">>, {s, <<"Amazon Redshift">>}}],
                      [{projection_expression, <<"Id, ISBN, Title, Authors">>}]},
                     {<<"Thread">>,
                      [[{<<"ForumName">>, {s, <<"Amazon DynamoDB">>}},
                        {<<"Subject">>, {s, <<"Concurrent reads">>}}]],
                      [{projection_expression, <<"Tags, Message">>}]}],
                    [{return_consumed_capacity, total}])), "
{
    \"RequestItems\": {
        \"Forum\": {
            \"Keys\": [
                {
                    \"Name\":{\"S\":\"Amazon DynamoDB\"}
                },
                {
                    \"Name\":{\"S\":\"Amazon RDS\"}
                },
                {
                    \"Name\":{\"S\":\"Amazon Redshift\"}
                }
            ],
            \"ProjectionExpression\":\"Id, ISBN, Title, Authors\"
        },
        \"Thread\": {
            \"Keys\": [
                {
                    \"ForumName\":{\"S\":\"Amazon DynamoDB\"},
                    \"Subject\":{\"S\":\"Concurrent reads\"}
                }
            ],
            \"ProjectionExpression\":\"Tags, Message\"
        }
    },
    \"ReturnConsumedCapacity\": \"TOTAL\"
}"
            })
        ],

    Response = "
{
    \"Responses\": {
        \"Forum\": [
            {
                \"Name\":{
                    \"S\":\"Amazon DynamoDB\"
                },
                \"Threads\":{
                    \"N\":\"5\"
                },
                \"Messages\":{
                    \"N\":\"19\"
                },
                \"Views\":{
                    \"N\":\"35\"
                }
            },
            {
                \"Name\":{
                    \"S\":\"Amazon RDS\"
                },
                \"Threads\":{
                    \"N\":\"8\"
                },
                \"Messages\":{
                    \"N\":\"32\"
                },
                \"Views\":{
                    \"N\":\"38\"
                }
            },
            {
                \"Name\":{
                    \"S\":\"Amazon Redshift\"
                },
                \"Threads\":{
                    \"N\":\"12\"
                },
                \"Messages\":{
                    \"N\":\"55\"
                },
                \"Views\":{
                    \"N\":\"47\"
                }
            }
        ],
        \"Thread\": [
            {
                \"Tags\":{
                    \"SS\":[\"Reads\",\"MultipleUsers\"]
                },
                \"Message\":{
                    \"S\":\"How many users can read a single data item at a time? Are there any limits?\"
                }
            }
        ]
    },
    \"UnprocessedKeys\": {
    },
    \"ConsumedCapacity\": [
        {
            \"TableName\": \"Forum\",
            \"CapacityUnits\": 3
        },
        {
            \"TableName\": \"Thread\",
            \"CapacityUnits\": 1
        }
    ]
}",
    input_tests(Response, Tests).

batch_get_item_output_tests(_) ->
    Tests =
        [?_ddb_test(
            {"BatchGetItem example response", "
{
    \"Responses\": {
        \"Forum\": [
            {
                \"Name\":{
                    \"S\":\"Amazon DynamoDB\"
                },
                \"Threads\":{
                    \"N\":\"5\"
                },
                \"Messages\":{
                    \"N\":\"19\"
                },
                \"Views\":{
                    \"N\":\"35\"
                }
            },
            {
                \"Name\":{
                    \"S\":\"Amazon RDS\"
                },
                \"Threads\":{
                    \"N\":\"8\"
                },
                \"Messages\":{
                    \"N\":\"32\"
                },
                \"Views\":{
                    \"N\":\"38\"
                }
            },
            {
                \"Name\":{
                    \"S\":\"Amazon Redshift\"
                },
                \"Threads\":{
                    \"N\":\"12\"
                },
                \"Messages\":{
                    \"N\":\"55\"
                },
                \"Views\":{
                    \"N\":\"47\"
                }
            }
        ],
        \"Thread\": [
            {
                \"Tags\":{
                    \"SS\":[\"Reads\",\"MultipleUsers\"]
                },
                \"Message\":{
                    \"S\":\"How many users can read a single data item at a time? Are there any limits?\"
                }
            }
        ]
    },
    \"UnprocessedKeys\": {
    },
    \"ConsumedCapacity\": [
        {
            \"TableName\": \"Forum\",
            \"CapacityUnits\": 3
        },
        {
            \"TableName\": \"Thread\",
            \"CapacityUnits\": 1
        }
    ]
}",
             {ok, #ddb2_batch_get_item
              {consumed_capacity =
                   [#ddb2_consumed_capacity{table_name = <<"Forum">>, capacity_units = 3},
                    #ddb2_consumed_capacity{table_name = <<"Thread">>, capacity_units = 1}],
               responses =
                   [#ddb2_batch_get_item_response
                    {table = <<"Forum">>,
                     items = [[{<<"Name">>, <<"Amazon DynamoDB">>},
                               {<<"Threads">>, 5},
                               {<<"Messages">>, 19},
                               {<<"Views">>, 35}],
                              [{<<"Name">>, <<"Amazon RDS">>},
                               {<<"Threads">>, 8},
                               {<<"Messages">>, 32},
                               {<<"Views">>, 38}],
                              [{<<"Name">>, <<"Amazon Redshift">>},
                               {<<"Threads">>, 12},
                               {<<"Messages">>, 55},
                               {<<"Views">>, 47}]]},
                    #ddb2_batch_get_item_response
                    {table = <<"Thread">>,
                     items = [[{<<"Tags">>, [<<"Reads">>, <<"MultipleUsers">>]},
                               {<<"Message">>, <<"How many users can read a single data item at a time? Are there any limits?">>}]]}],
               unprocessed_keys = []}}}),
         ?_ddb_test(
            {"BatchGetItem unprocessed keys", "
{
    \"Responses\": {},
    \"UnprocessedKeys\": {
        \"Forum\": {
            \"Keys\": [
                {
                    \"Name\":{\"S\":\"Amazon DynamoDB\"}
                },
                {
                    \"Name\":{\"S\":\"Amazon RDS\"}
                },
                {
                    \"Name\":{\"S\":\"Amazon Redshift\"}
                }
            ],
            \"AttributesToGet\": [
                \"Name\",\"Threads\",\"Messages\",\"Views\"
            ]
        },
        \"Thread\": {
            \"Keys\": [
                {
                    \"ForumName\":{\"S\":\"Amazon DynamoDB\"},
                    \"Subject\":{\"S\":\"Concurrent reads\"}
                }
            ],
            \"AttributesToGet\": [
                \"Tags\",\"Message\"
            ]
        }
    }
}",
             {ok, #ddb2_batch_get_item
              {responses = [],
               unprocessed_keys =
                   [{<<"Forum">>,
                     [[{<<"Name">>, {s, <<"Amazon DynamoDB">>}}],
                      [{<<"Name">>, {s, <<"Amazon RDS">>}}],
                      [{<<"Name">>, {s, <<"Amazon Redshift">>}}]],
                     [{attributes_to_get, [<<"Name">>, <<"Threads">>, <<"Messages">>, <<"Views">>]}]},
                    {<<"Thread">>,
                     [[{<<"ForumName">>, {s, <<"Amazon DynamoDB">>}},
                       {<<"Subject">>, {s, <<"Concurrent reads">>}}]],
                     [{attributes_to_get, [<<"Tags">>, <<"Message">>]}]}]}}})
        ],

    output_tests(?_f(erlcloud_ddb2:batch_get_item([{<<"table">>, [{<<"k">>, <<"v">>}]}], [{out, record}])), Tests).

%% BatchWriteItem test based on the API examples:
%% http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_BatchWriteItem.html
batch_write_item_input_tests(_) ->
    Tests =
        [?_ddb_test(
            {"BatchWriteItem example request",
             ?_f(erlcloud_ddb2:batch_write_item(
                   [{<<"Forum">>, [{put, [{<<"Name">>, {s, <<"Amazon DynamoDB">>}},
                                          {<<"Category">>, {s, <<"Amazon Web Services">>}}]},
                                   {put, [{<<"Name">>, {s, <<"Amazon RDS">>}},
                                          {<<"Category">>, {s, <<"Amazon Web Services">>}}]},
                                   {put, [{<<"Name">>, {s, <<"Amazon Redshift">>}},
                                          {<<"Category">>, {s, <<"Amazon Web Services">>}}]},
                                   {put, [{<<"Name">>, {s, <<"Amazon ElastiCache">>}},
                                          {<<"Category">>, {s, <<"Amazon Web Services">>}}]}
                                   ]}],
                  [{return_consumed_capacity, total}])), "
{
    \"RequestItems\": {
        \"Forum\": [
            {
                \"PutRequest\": {
                    \"Item\": {
                        \"Name\": {
                            \"S\": \"Amazon DynamoDB\"
                        },
                        \"Category\": {
                            \"S\": \"Amazon Web Services\"
                        }
                    }
                }
            },
            {
                \"PutRequest\": {
                    \"Item\": {
                        \"Name\": {
                            \"S\": \"Amazon RDS\"
                        },
                        \"Category\": {
                            \"S\": \"Amazon Web Services\"
                        }
                    }
                }
            },
            {
                \"PutRequest\": {
                    \"Item\": {
                        \"Name\": {
                            \"S\": \"Amazon Redshift\"
                        },
                        \"Category\": {
                            \"S\": \"Amazon Web Services\"
                        }
                    }
                }
            },
            {
                \"PutRequest\": {
                    \"Item\": {
                        \"Name\": {
                            \"S\": \"Amazon ElastiCache\"
                        },
                        \"Category\": {
                            \"S\": \"Amazon Web Services\"
                        }
                    }
                }
            }
        ]
    },
    \"ReturnConsumedCapacity\": \"TOTAL\"
}"
            }),
        ?_ddb_test(
            {"BatchWriteItem put, delete and item collection metrics",
             ?_f(erlcloud_ddb2:batch_write_item(
                   [{<<"Forum">>, [{put, [{<<"Name">>, {s, <<"Amazon DynamoDB">>}},
                                          {<<"Category">>, {s, <<"Amazon Web Services">>}}]},
                                   {delete, {<<"Name">>, {s, <<"Amazon RDS">>}}}
                                  ]}],
                  [{return_item_collection_metrics, size}])), "
{
    \"RequestItems\": {
        \"Forum\": [
            {
                \"PutRequest\": {
                    \"Item\": {
                        \"Name\": {
                            \"S\": \"Amazon DynamoDB\"
                        },
                        \"Category\": {
                            \"S\": \"Amazon Web Services\"
                        }
                    }
                }
            },
            {
                \"DeleteRequest\": {
                    \"Key\": {
                        \"Name\": {
                            \"S\": \"Amazon RDS\"
                        }
                    }
                }
            }
        ]
    },
    \"ReturnItemCollectionMetrics\": \"SIZE\"
}"
            })
        ],

    Response = "
{
    \"UnprocessedItems\": {
        \"Forum\": [
            {
                \"PutRequest\": {
                    \"Item\": {
                        \"Name\": {
                            \"S\": \"Amazon ElastiCache\"
                        },
                        \"Category\": {
                            \"S\": \"Amazon Web Services\"
                        }
                    }
                }
            }
        ]
    },
    \"ConsumedCapacity\": [
        {
            \"TableName\": \"Forum\",
            \"CapacityUnits\": 3
        }
    ]
}",
    input_tests(Response, Tests).

batch_write_item_output_tests(_) ->
    Tests =
        [?_ddb_test(
            {"BatchWriteItem example response", "
{
    \"UnprocessedItems\": {
        \"Forum\": [
            {
                \"PutRequest\": {
                    \"Item\": {
                        \"Name\": {
                            \"S\": \"Amazon ElastiCache\"
                        },
                        \"Category\": {
                            \"S\": \"Amazon Web Services\"
                        }
                    }
                }
            }
        ]
    },
    \"ConsumedCapacity\": [
        {
            \"TableName\": \"Forum\",
            \"CapacityUnits\": 3
        }
    ]
}",
             {ok, #ddb2_batch_write_item
              {consumed_capacity = [#ddb2_consumed_capacity{table_name = <<"Forum">>, capacity_units = 3}],
               item_collection_metrics = undefined,
               unprocessed_items = [{<<"Forum">>,
                                     [{put, [{<<"Name">>, {s, <<"Amazon ElastiCache">>}},
                                             {<<"Category">>, {s, <<"Amazon Web Services">>}}]}]}]}}}),
         ?_ddb_test(
            {"BatchWriteItem unprocessed response", "
{
   \"UnprocessedItems\":{
        \"Forum\": [
            {
                \"PutRequest\": {
                    \"Item\": {
                        \"Name\": {
                            \"S\": \"Amazon DynamoDB\"
                        },
                        \"Category\": {
                            \"S\": \"Amazon Web Services\"
                        }
                    }
                }
            },
            {
                \"DeleteRequest\": {
                    \"Key\": {
                        \"Name\": {
                            \"S\": \"Amazon RDS\"
                        }
                    }
                }
            }
        ]
    }
}",
             {ok, #ddb2_batch_write_item
              {consumed_capacity = undefined,
               item_collection_metrics = undefined,
               unprocessed_items =
                   [{<<"Forum">>, [{put, [{<<"Name">>, {s, <<"Amazon DynamoDB">>}},
                                          {<<"Category">>, {s, <<"Amazon Web Services">>}}]},
                                   {delete, [{<<"Name">>, {s, <<"Amazon RDS">>}}]}
                                  ]}]}}}),
         ?_ddb_test(
            {"BatchWriteItem item collection metrics", "
{
    \"ItemCollectionMetrics\": {
        \"Table1\": [
            {
                \"ItemCollectionKey\": {
                    \"key\": {
                        \"S\": \"value1\"
                    }
                },
                \"SizeEstimateRangeGB\": [
                    2,
                    4
                ]
            },
            {
                \"ItemCollectionKey\": {
                    \"key\": {
                        \"S\": \"value2\"
                    }
                },
                \"SizeEstimateRangeGB\": [
                    0.1,
                    0.2
                ]
            }
        ],
        \"Table2\": [
            {
                \"ItemCollectionKey\": {
                    \"key2\": {
                        \"N\": \"3\"
                    }
                },
                \"SizeEstimateRangeGB\": [
                    1.2,
                    1.4
                ]
            }
        ]
    }
}",
             {ok, #ddb2_batch_write_item
              {consumed_capacity = undefined,
               item_collection_metrics =
                   [{<<"Table1">>,
                     [#ddb2_item_collection_metrics
                      {item_collection_key = <<"value1">>,
                       size_estimate_range_gb = {2, 4}},
                      #ddb2_item_collection_metrics
                      {item_collection_key = <<"value2">>,
                       size_estimate_range_gb = {0.1, 0.2}}
                     ]},
                    {<<"Table2">>,
                     [#ddb2_item_collection_metrics
                      {item_collection_key = 3,
                       size_estimate_range_gb = {1.2, 1.4}}
                     ]}],
               unprocessed_items = []}}})
        ],

    output_tests(?_f(erlcloud_ddb2:batch_write_item([], [{out, record}])), Tests).

%% CreateBackup test based on the API examples:
%% https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_CreateBackup.html
create_backup_input_tests(_) ->
 Tests =
  [?_ddb_test(
   {"CreateBackup example request",
    ?_f(erlcloud_ddb2:create_backup(<<"Forum_Backup">>,<<"Forum">>)), "
    {
        \"BackupName\": \"Forum_Backup\",
        \"TableName\": \"Forum\"
    }"
   })
  ],
 Response = "
{
    \"BackupDetails\": {
          \"BackupArn\": \"arn:aws:dynamodb:us-east-1:387047610112:table/Forum/backup/01523517555423-69b67bcb\",
          \"BackupCreationDateTime\": 1523269031.475,
          \"BackupName\": \"Forum_Backup\",
          \"BackupSizeBytes\": 6,
          \"BackupStatus\": \"CREATING\"
      }
}",
 input_tests(Response, Tests).

create_backup_output_tests(_) ->
 Tests =
  [?_ddb_test(
   {"CreateBackup example response", "
{
    \"BackupDetails\": {
        \"BackupArn\": \"arn:aws:dynamodb:us-east-1:387047610112:table/Forum/backup/01523517555423-69b67bcb\",
        \"BackupCreationDateTime\": 1523269031.475,
        \"BackupName\": \"Forum_Backup\",
        \"BackupSizeBytes\": 6,
        \"BackupStatus\": \"CREATING\"
       }
}",
    {ok,#ddb2_backup_details{
        backup_arn = <<"arn:aws:dynamodb:us-east-1:387047610112:table/Forum/backup/01523517555423-69b67bcb">>,
        backup_creation_date_time = 1523269031.475,
        backup_name = <<"Forum_Backup">>,
        backup_size_Bytes = 6,
        backup_status = creating}}
   })
  ],

 output_tests(?_f(erlcloud_ddb2:create_backup(<<"Forum_Backup">>,<<"Forum">>)), Tests).

%% CreateGlobalTable input test:
create_global_table_input_tests(_) ->
    Tests =
          [?_ddb_test(
              {"CreateGlobalTable example request (2 regions)",
               ?_f(erlcloud_ddb2:create_global_table(<<"Thread">>, [{region_name, <<"us-east-1">>},
                                                                    {region_name, <<"us-west-2">>}])), "
{
   \"GlobalTableName\": \"Thread\",
   \"ReplicationGroup\": [
      {
         \"RegionName\": \"us-east-1\"
      },{
         \"RegionName\": \"us-west-2\"
      }
   ]
}"
              }),
           ?_ddb_test(
              {"CreateGlobalTable example request (1 region)",
               ?_f(erlcloud_ddb2:create_global_table(<<"Thread">>, [#ddb2_replica{region_name = <<"us-west-2">>}])), "
{
   \"GlobalTableName\": \"Thread\",
   \"ReplicationGroup\": [
      {
         \"RegionName\": \"us-west-2\"
      }
   ]
}"
              })],
      Response = "
{
   \"GlobalTableDescription\": {
      \"CreationDateTime\": 1519161181.107,
      \"GlobalTableArn\": \"arn:aws:dynamodb::111122223333:global-table/Thread\",
      \"GlobalTableName\": \"Thread\",
      \"GlobalTableStatus\": \"CREATING\",
      \"ReplicationGroup\": [
          {
             \"RegionName\": \"us-east-1\"
          },{
             \"RegionName\": \"us-west-2\"
          }
      ]
   }
}",
      input_tests(Response, Tests).

%% CreateGlobalTable output test:
create_global_table_output_tests(_) ->
    Tests =
        [?_ddb_test(
            {"CreateGlobalTable example response with CREATING status ", "
{
   \"GlobalTableDescription\": {
      \"CreationDateTime\": 1519161181.107,
      \"GlobalTableArn\": \"arn:aws:dynamodb::111122223333:global-table/Thread\",
      \"GlobalTableName\": \"Thread\",
      \"GlobalTableStatus\": \"CREATING\",
      \"ReplicationGroup\": [
          {
             \"RegionName\": \"us-east-1\"
          }
      ]
   }
}",
              {ok, #ddb2_global_table_description{
                creation_date_time = 1519161181.107,
                global_table_arn = <<"arn:aws:dynamodb::111122223333:global-table/Thread">>,
                global_table_name = <<"Thread">>,
                global_table_status = creating,
                replication_group = [#ddb2_replica_description{region_name = <<"us-east-1">>}]}}}),

         ?_ddb_test(
            {"CreateGlobalTable example response with ACTIVE status ", "
{
   \"GlobalTableDescription\": {
      \"CreationDateTime\": 1519161181.107,
      \"GlobalTableArn\": \"arn:aws:dynamodb::111122223333:global-table/Thread\",
      \"GlobalTableName\": \"Thread\",
      \"GlobalTableStatus\": \"ACTIVE\",
      \"ReplicationGroup\": [
          {
             \"RegionName\": \"us-east-1\"
          },{
             \"RegionName\": \"eu-west-1\"
          }
      ]
   }
}",
              {ok, #ddb2_global_table_description{
                creation_date_time = 1519161181.107,
                global_table_arn = <<"arn:aws:dynamodb::111122223333:global-table/Thread">>,
                global_table_name = <<"Thread">>,
                global_table_status = active,
                replication_group = [#ddb2_replica_description{region_name = <<"us-east-1">>},
                                     #ddb2_replica_description{region_name = <<"eu-west-1">>}]}}})],
    output_tests(?_f(erlcloud_ddb2:create_global_table(<<"Thread">>, [{region_name, <<"us-east-1">>}])), Tests).

%% CreateTable test based on the API examples:
%% http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_CreateTable.html
create_table_input_tests(_) ->
    Tests =
        [?_ddb_test(
            {"CreateTable example request",
             ?_f(erlcloud_ddb2:create_table(
                   <<"Thread">>,
                   [{<<"ForumName">>, s},
                    {<<"Subject">>, s},
                    {<<"LastPostDateTime">>, s}],
                   {<<"ForumName">>, <<"Subject">>},
                   5,
                   5,
                   [{local_secondary_indexes,
                     [{<<"LastPostIndex">>, <<"LastPostDateTime">>, keys_only}]},
                    {global_secondary_indexes,
                     [{<<"SubjectIndex">>, {<<"Subject">>, <<"LastPostDateTime">>}, keys_only, 10, 5}]}]
                  )), "
{
    \"AttributeDefinitions\": [
        {
            \"AttributeName\": \"ForumName\",
            \"AttributeType\": \"S\"
        },
        {
            \"AttributeName\": \"Subject\",
            \"AttributeType\": \"S\"
        },
        {
            \"AttributeName\": \"LastPostDateTime\",
            \"AttributeType\": \"S\"
        }
    ],
    \"GlobalSecondaryIndexes\": [
        {
            \"IndexName\": \"SubjectIndex\",
            \"KeySchema\": [
                {
                    \"AttributeName\": \"Subject\",
                    \"KeyType\": \"HASH\"
                },
                {
                    \"AttributeName\": \"LastPostDateTime\",
                    \"KeyType\": \"RANGE\"
                }
            ],
            \"Projection\": {
                \"ProjectionType\": \"KEYS_ONLY\"
            },
            \"ProvisionedThroughput\": {
                \"ReadCapacityUnits\": 10,
                \"WriteCapacityUnits\": 5
            }
        }
    ],
    \"TableName\": \"Thread\",
    \"KeySchema\": [
        {
            \"AttributeName\": \"ForumName\",
            \"KeyType\": \"HASH\"
        },
        {
            \"AttributeName\": \"Subject\",
            \"KeyType\": \"RANGE\"
        }
    ],
    \"LocalSecondaryIndexes\": [
        {
            \"IndexName\": \"LastPostIndex\",
            \"KeySchema\": [
                {
                    \"AttributeName\": \"ForumName\",
                    \"KeyType\": \"HASH\"
                },
                {
                    \"AttributeName\": \"LastPostDateTime\",
                    \"KeyType\": \"RANGE\"
                }
            ],
            \"Projection\": {
                \"ProjectionType\": \"KEYS_ONLY\"
            }
        }
    ],
    \"ProvisionedThroughput\": {
        \"ReadCapacityUnits\": 5,
        \"WriteCapacityUnits\": 5
    }
}"
            }),
         ?_ddb_test(
            {"CreateTable with INCLUDE local and global secondary index",
             ?_f(erlcloud_ddb2:create_table(
                   <<"Thread">>,
                   [{<<"ForumName">>, s},
                    {<<"Subject">>, s},
                    {<<"LastPostDateTime">>, s}],
                   {<<"ForumName">>, <<"Subject">>},
                   5,
                   5,
                   [{local_secondary_indexes,
                     [{<<"LastPostIndex">>, <<"LastPostDateTime">>, {include, [<<"Author">>, <<"Body">>]}}]},
                    {global_secondary_indexes,
                     [{<<"SubjectIndex">>, {<<"Subject">>, <<"LastPostDateTime">>}, {include, [<<"Author">>]}, 10, 5}]}]
                  )), "
{
    \"AttributeDefinitions\": [
        {
            \"AttributeName\": \"ForumName\",
            \"AttributeType\": \"S\"
        },
        {
            \"AttributeName\": \"Subject\",
            \"AttributeType\": \"S\"
        },
        {
            \"AttributeName\": \"LastPostDateTime\",
            \"AttributeType\": \"S\"
        }
    ],
    \"GlobalSecondaryIndexes\": [
        {
            \"IndexName\": \"SubjectIndex\",
            \"KeySchema\": [
                {
                    \"AttributeName\": \"Subject\",
                    \"KeyType\": \"HASH\"
                },
                {
                    \"AttributeName\": \"LastPostDateTime\",
                    \"KeyType\": \"RANGE\"
                }
            ],
            \"Projection\": {
                \"NonKeyAttributes\": [
                    \"Author\"
                ],
                \"ProjectionType\": \"INCLUDE\"
            },
            \"ProvisionedThroughput\": {
                \"ReadCapacityUnits\": 10,
                \"WriteCapacityUnits\": 5
            }
        }
    ],
    \"TableName\": \"Thread\",
    \"KeySchema\": [
        {
            \"AttributeName\": \"ForumName\",
            \"KeyType\": \"HASH\"
        },
        {
            \"AttributeName\": \"Subject\",
            \"KeyType\": \"RANGE\"
        }
    ],
    \"LocalSecondaryIndexes\": [
        {
            \"IndexName\": \"LastPostIndex\",
            \"KeySchema\": [
                {
                    \"AttributeName\": \"ForumName\",
                    \"KeyType\": \"HASH\"
                },
                {
                    \"AttributeName\": \"LastPostDateTime\",
                    \"KeyType\": \"RANGE\"
                }
            ],
            \"Projection\": {
                \"ProjectionType\": \"INCLUDE\",
                \"NonKeyAttributes\": [\"Author\", \"Body\"]
            }
        }
    ],
    \"ProvisionedThroughput\": {
        \"ReadCapacityUnits\": 5,
        \"WriteCapacityUnits\": 5
    }
}"
            }),
         ?_ddb_test(
            {"CreateTable with only hash key",
             ?_f(erlcloud_ddb2:create_table(
                   <<"Thread">>,
                   {<<"ForumName">>, s},
                   <<"ForumName">>,
                   1,
                   1
                  )), "
{
    \"AttributeDefinitions\": [
        {
            \"AttributeName\": \"ForumName\",
            \"AttributeType\": \"S\"
        }
    ],
    \"TableName\": \"Thread\",
    \"KeySchema\": [
        {
            \"AttributeName\": \"ForumName\",
            \"KeyType\": \"HASH\"
        }
    ],
    \"ProvisionedThroughput\": {
        \"ReadCapacityUnits\": 1,
        \"WriteCapacityUnits\": 1
    }
}"
            }),
         ?_ddb_test(
            {"CreateTable with billing_mode = provisioned",
             ?_f(erlcloud_ddb2:create_table(
                   <<"Thread">>,
                   {<<"ForumName">>, s},
                   <<"ForumName">>,
                   [{billing_mode, provisioned},
                    {provisioned_throughput, {1,1}}]
                  )), "
{
    \"AttributeDefinitions\": [
        {
            \"AttributeName\": \"ForumName\",
            \"AttributeType\": \"S\"
        }
    ],
    \"BillingMode\": \"PROVISIONED\",
    \"TableName\": \"Thread\",
    \"KeySchema\": [
        {
            \"AttributeName\": \"ForumName\",
            \"KeyType\": \"HASH\"
        }
    ],
    \"ProvisionedThroughput\": {
        \"ReadCapacityUnits\": 1,
        \"WriteCapacityUnits\": 1
    }
}"
            }),
         ?_ddb_test(
            {"CreateTable with billing_mode = pay_per_request",
             ?_f(erlcloud_ddb2:create_table(
                   <<"Thread">>,
                   {<<"ForumName">>, s},
                   <<"ForumName">>,
                   [{billing_mode, pay_per_request},
                    {global_secondary_indexes,
                     [{<<"SubjectIndex">>, {<<"Subject">>, <<"LastPostDateTime">>}, {include, [<<"Author">>]}}]}]
                  )), "
{
    \"AttributeDefinitions\": [
        {
            \"AttributeName\": \"ForumName\",
            \"AttributeType\": \"S\"
        }
    ],
    \"BillingMode\": \"PAY_PER_REQUEST\",
    \"GlobalSecondaryIndexes\": [
        {
            \"IndexName\": \"SubjectIndex\",
            \"KeySchema\": [
                {
                    \"AttributeName\": \"Subject\",
                    \"KeyType\": \"HASH\"
                },
                {
                    \"AttributeName\": \"LastPostDateTime\",
                    \"KeyType\": \"RANGE\"
                }
            ],
            \"Projection\": {
                \"NonKeyAttributes\": [
                    \"Author\"
                ],
                \"ProjectionType\": \"INCLUDE\"
            }
        }
    ],
    \"TableName\": \"Thread\",
    \"KeySchema\": [
        {
            \"AttributeName\": \"ForumName\",
            \"KeyType\": \"HASH\"
        }
    ]
}"
            }),
         ?_ddb_test(
            {"CreateTable with deletion_protection_enabled = true",
             ?_f(erlcloud_ddb2:create_table(
                   <<"Thread">>,
                   [{<<"ForumName">>, s},
                    {<<"Subject">>, s},
                    {<<"LastPostDateTime">>, s}],
                   {<<"ForumName">>, <<"Subject">>},
                   5,
                   5,
                   [{local_secondary_indexes,
                     [{<<"LastPostIndex">>, <<"LastPostDateTime">>, keys_only}]},
                    {global_secondary_indexes,
                     [{<<"SubjectIndex">>, {<<"Subject">>, <<"LastPostDateTime">>}, keys_only, 10, 5}]},
                    {deletion_protection_enabled, true}]
                  )), "
{
    \"AttributeDefinitions\": [
        {
            \"AttributeName\": \"ForumName\",
            \"AttributeType\": \"S\"
        },
        {
            \"AttributeName\": \"Subject\",
            \"AttributeType\": \"S\"
        },
        {
            \"AttributeName\": \"LastPostDateTime\",
            \"AttributeType\": \"S\"
        }
    ],
    \"GlobalSecondaryIndexes\": [
        {
            \"IndexName\": \"SubjectIndex\",
            \"KeySchema\": [
                {
                    \"AttributeName\": \"Subject\",
                    \"KeyType\": \"HASH\"
                },
                {
                    \"AttributeName\": \"LastPostDateTime\",
                    \"KeyType\": \"RANGE\"
                }
            ],
            \"Projection\": {
                \"ProjectionType\": \"KEYS_ONLY\"
            },
            \"ProvisionedThroughput\": {
                \"ReadCapacityUnits\": 10,
                \"WriteCapacityUnits\": 5
            }
        }
    ],
    \"DeletionProtectionEnabled\": true,
    \"TableName\": \"Thread\",
    \"KeySchema\": [
        {
            \"AttributeName\": \"ForumName\",
            \"KeyType\": \"HASH\"
        },
        {
            \"AttributeName\": \"Subject\",
            \"KeyType\": \"RANGE\"
        }
    ],
    \"LocalSecondaryIndexes\": [
        {
            \"IndexName\": \"LastPostIndex\",
            \"KeySchema\": [
                {
                    \"AttributeName\": \"ForumName\",
                    \"KeyType\": \"HASH\"
                },
                {
                    \"AttributeName\": \"LastPostDateTime\",
                    \"KeyType\": \"RANGE\"
                }
            ],
            \"Projection\": {
                \"ProjectionType\": \"KEYS_ONLY\"
            }
        }
    ],
    \"ProvisionedThroughput\": {
        \"ReadCapacityUnits\": 5,
        \"WriteCapacityUnits\": 5
    }
}"
            })
        ],

    Response = "
{
    \"TableDescription\": {
        \"AttributeDefinitions\": [
            {
                \"AttributeName\": \"ForumName\",
                \"AttributeType\": \"S\"
            },
            {
                \"AttributeName\": \"LastPostDateTime\",
                \"AttributeType\": \"S\"
            },
            {
                \"AttributeName\": \"Subject\",
                \"AttributeType\": \"S\"
            }
        ],
        \"CreationDateTime\": 1.36372808007E9,
        \"ItemCount\": 0,
        \"KeySchema\": [
            {
                \"AttributeName\": \"ForumName\",
                \"KeyType\": \"HASH\"
            },
            {
                \"AttributeName\": \"Subject\",
                \"KeyType\": \"RANGE\"
            }
        ],
        \"LocalSecondaryIndexes\": [
            {
                \"IndexName\": \"LastPostIndex\",
                \"IndexSizeBytes\": 0,
                \"ItemCount\": 0,
                \"KeySchema\": [
                    {
                        \"AttributeName\": \"ForumName\",
                        \"KeyType\": \"HASH\"
                    },
                    {
                        \"AttributeName\": \"LastPostDateTime\",
                        \"KeyType\": \"RANGE\"
                    }
                ],
                \"Projection\": {
                    \"ProjectionType\": \"KEYS_ONLY\"
                }
            }
        ],
        \"ProvisionedThroughput\": {
            \"NumberOfDecreasesToday\": 0,
            \"ReadCapacityUnits\": 5,
            \"WriteCapacityUnits\": 5
        },
        \"TableName\": \"Thread\",
        \"TableSizeBytes\": 0,
        \"TableStatus\": \"CREATING\"
    }
}",
    input_tests(Response, Tests).

%% DeleteBackup test based on the API examples:
%% https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_DeleteBackup.html
delete_backup_input_tests(_) ->
 Tests =
  [?_ddb_test(
   {"DeleteBackup example request",
    ?_f(erlcloud_ddb2:delete_backup(<<"arn:aws:dynamodb:us-east-1:387047610112:table/Forum/backup/01523517555423-69b67bcb">>)), "
    {
        \"BackupArn\": \"arn:aws:dynamodb:us-east-1:387047610112:table/Forum/backup/01523517555423-69b67bcb\"
    }"
   })
  ],
 Response = "
{
   \"BackupDescription\": {
      \"BackupDetails\": {
         \"BackupArn\": \"arn:aws:dynamodb:us-east-1:387047610112:table/Forum/backup/01523517555423-69b67bcb\",
         \"BackupCreationDateTime\": 1523269031.475,
         \"BackupName\": \"Forum_Backup\",
         \"BackupSizeBytes\": 1,
         \"BackupStatus\": \"DELETED\"
      },
      \"SourceTableDetails\": {
         \"ItemCount\": 0,
         \"KeySchema\": [
            {
               \"AttributeName\": \"id\",
               \"KeyType\": \"HASH\"
            }
         ],
         \"ProvisionedThroughput\": {
            \"ReadCapacityUnits\": 5,
            \"WriteCapacityUnits\": 5
         },
         \"TableArn\": \"arn:aws:dynamodb:us-east-1:387047610112:table/Forum\",
         \"TableCreationDateTime\": 1523269031.475,
         \"TableId\": \"284a7e42-42ed-4854-b9fd-9a5a4b972dc4\",
         \"TableName\": \"Forum\",
         \"TableSizeBytes\": 1
      },
      \"SourceTableFeatureDetails\": {
         \"GlobalSecondaryIndexes\": [
            {
               \"IndexName\": \"Idx\",
               \"KeySchema\": [
                  {
                     \"AttributeName\": \"Atr\",
                     \"KeyType\": \"HASH\"
                  }
               ],
               \"Projection\": {
                  \"NonKeyAttributes\": [ \"Atr2\" ],
                  \"ProjectionType\": \"ALL\"
               },
               \"ProvisionedThroughput\": {
                  \"ReadCapacityUnits\": 5,
                  \"WriteCapacityUnits\": 5
               }
            }
         ],
         \"LocalSecondaryIndexes\": [
            {
               \"IndexName\": \"Idx2\",
               \"KeySchema\": [
                  {
                     \"AttributeName\": \"Atr3\",
                     \"KeyType\": \"RANGE\"
                  }
               ],
               \"Projection\": {
                  \"NonKeyAttributes\": [ \"Atr4\" ],
                  \"ProjectionType\": \"KEYS_ONLY\"
               }
            }
         ],
         \"SSEDescription\": {
            \"Status\": \"DISABLED\"
         },
         \"StreamDescription\": {
            \"StreamEnabled\": true,
            \"StreamViewType\": \"NEW_AND_OLD_IMAGES\"
         },
         \"TimeToLiveDescription\": {
            \"AttributeName\": \"none\",
           \"TimeToLiveStatus\": \"DISABLED\"
         }
      }
   }
}",
 input_tests(Response, Tests).

delete_backup_output_tests(_) ->
 Tests =
  [?_ddb_test(
   {"DeleteBackup example response", "
{
    \"BackupDescription\": {
         \"BackupDetails\": {
             \"BackupArn\": \"arn:aws:dynamodb:us-east-1:387047610112:table/Forum/backup/01523517555423-69b67bcb\",
             \"BackupCreationDateTime\": 1523269031.475,
             \"BackupName\": \"Forum_Backup\",
             \"BackupSizeBytes\": 1,
             \"BackupStatus\": \"DELETED\"
         },
         \"SourceTableDetails\": {
            \"ItemCount\": 0,
            \"KeySchema\": [
                {
                   \"AttributeName\": \"id\",
                   \"KeyType\": \"HASH\"
                }
             ],
            \"ProvisionedThroughput\": {
                \"ReadCapacityUnits\": 5,
                \"WriteCapacityUnits\": 5
            },
            \"TableArn\": \"arn:aws:dynamodb:us-east-1:387047610112:table/Forum\",
            \"TableCreationDateTime\": 1523269031.475,
            \"TableId\": \"284a7e42-42ed-4854-b9fd-9a5a4b972dc4\",
            \"TableName\": \"Forum\",
            \"TableSizeBytes\": 1
         },
        \"SourceTableFeatureDetails\": {
            \"GlobalSecondaryIndexes\": [
               {
                  \"IndexName\": \"Idx\",
                  \"KeySchema\": [
                     {
                        \"AttributeName\": \"Atr\",
                        \"KeyType\": \"HASH\"
                     }
                  ],
                  \"Projection\": {
                     \"NonKeyAttributes\": [ \"Atr2\" ],
                     \"ProjectionType\": \"ALL\"
                  },
                  \"ProvisionedThroughput\": {
                     \"ReadCapacityUnits\": 5,
                     \"WriteCapacityUnits\": 5
                  }
               }
            ],
            \"LocalSecondaryIndexes\": [
               {
                  \"IndexName\": \"Idx2\",
                  \"KeySchema\": [
                     {
                        \"AttributeName\": \"Atr3\",
                        \"KeyType\": \"RANGE\"
                     }
                  ],
                  \"Projection\": {
                     \"NonKeyAttributes\": [ \"Atr4\" ],
                     \"ProjectionType\": \"KEYS_ONLY\"
                  }
               }
            ],
            \"SSEDescription\": {
               \"Status\": \"DISABLED\"
            },
            \"StreamDescription\": {
               \"StreamEnabled\": true,
               \"StreamViewType\": \"NEW_AND_OLD_IMAGES\"
            },
            \"TimeToLiveDescription\": {
               \"AttributeName\": \"none\",
              \"TimeToLiveStatus\": \"DISABLED\"
            }
        }
   }
}",
    {ok,#ddb2_backup_description{
     backup_details =
     #ddb2_backup_details{
         backup_arn = <<"arn:aws:dynamodb:us-east-1:387047610112:table/Forum/backup/01523517555423-69b67bcb">>,
         backup_creation_date_time = 1523269031.475,
         backup_name = <<"Forum_Backup">>,
         backup_size_Bytes = 1,
         backup_status = deleted},
     source_table_details =
     #ddb2_source_table_details{
         item_count = 0,
         key_schema = <<"id">>,
         provisioned_throughput =
         #ddb2_provisioned_throughput{
             read_capacity_units = 5,
             write_capacity_units = 5},
         table_arn = <<"arn:aws:dynamodb:us-east-1:387047610112:table/Forum">>,
         table_creation_date_time = 1523269031.475,
         table_id = <<"284a7e42-42ed-4854-b9fd-9a5a4b972dc4">>,
         table_name = <<"Forum">>,
         table_size_bytes = 1},
     source_table_feature_details =
     #ddb2_source_table_feature_details{
         global_secondary_indexes =
         [#ddb2_global_secondary_index_info{
              index_name = <<"Idx">>,
              key_schema = <<"Atr">>,
              projection = all,
              provisioned_throughput =
              #ddb2_provisioned_throughput{
               read_capacity_units = 5,
               write_capacity_units = 5
              }}],
         local_secondary_indexes =
         [#ddb2_local_secondary_index_info{
              index_name = <<"Idx2">>,
              key_schema = <<"Atr3">>,
              projection = keys_only
             }],
         sse_description = {status,disabled},
         stream_description = {true,new_and_old_images},
         time_to_live_description =
         #ddb2_time_to_live_description{
             attribute_name = <<"none">>,
             time_to_live_status = disabled}}
    }}
   })
  ],

 output_tests(?_f(erlcloud_ddb2:delete_backup(<<"arn:aws:dynamodb:">>)), Tests).

create_table_output_tests(_) ->
    Tests =
        [?_ddb_test(
            {"CreateTable example response", "
{
    \"TableDescription\": {
        \"AttributeDefinitions\": [
            {
                \"AttributeName\": \"ForumName\",
                \"AttributeType\": \"S\"
            },
            {
                \"AttributeName\": \"LastPostDateTime\",
                \"AttributeType\": \"S\"
            },
            {
                \"AttributeName\": \"Subject\",
                \"AttributeType\": \"S\"
            }
        ],
        \"BillingModeSummary\": {
            \"BillingMode\": \"PROVISIONED\",
            \"LastUpdateToPayPerRequestDateTime\": 1.36372808007E9
        },
        \"CreationDateTime\": 1.36372808007E9,
        \"GlobalSecondaryIndexes\": [
            {
                \"IndexName\": \"SubjectIndex\",
                \"IndexSizeBytes\": 2048,
                \"IndexStatus\": \"CREATING\",
                \"ItemCount\": 47,
                \"KeySchema\": [
                    {
                        \"AttributeName\": \"Subject\",
                        \"KeyType\": \"HASH\"
                    },
                    {
                        \"AttributeName\": \"LastPostDateTime\",
                        \"KeyType\": \"RANGE\"
                    }
                ],
                \"Projection\": {
                    \"ProjectionType\": \"KEYS_ONLY\"
                },
                \"ProvisionedThroughput\": {
                    \"LastDecreaseDateTime\": 0,
                    \"LastIncreaseDateTime\": 1,
                    \"NumberOfDecreasesToday\": 2,
                    \"ReadCapacityUnits\": 3,
                    \"WriteCapacityUnits\": 4
                }
            }
        ],
        \"ItemCount\": 0,
        \"KeySchema\": [
            {
                \"AttributeName\": \"ForumName\",
                \"KeyType\": \"HASH\"
            },
            {
                \"AttributeName\": \"Subject\",
                \"KeyType\": \"RANGE\"
            }
        ],
        \"LocalSecondaryIndexes\": [
            {
                \"IndexName\": \"LastPostIndex\",
                \"IndexSizeBytes\": 0,
                \"ItemCount\": 0,
                \"KeySchema\": [
                    {
                        \"AttributeName\": \"ForumName\",
                        \"KeyType\": \"HASH\"
                    },
                    {
                        \"AttributeName\": \"LastPostDateTime\",
                        \"KeyType\": \"RANGE\"
                    }
                ],
                \"Projection\": {
                    \"ProjectionType\": \"KEYS_ONLY\"
                }
            }
        ],
        \"ProvisionedThroughput\": {
            \"NumberOfDecreasesToday\": 0,
            \"ReadCapacityUnits\": 5,
            \"WriteCapacityUnits\": 5
        },
        \"TableName\": \"Thread\",
        \"TableSizeBytes\": 0,
        \"TableStatus\": \"CREATING\"
    }
}",
             {ok, #ddb2_table_description
              {attribute_definitions = [{<<"ForumName">>, s},
                                        {<<"LastPostDateTime">>, s},
                                        {<<"Subject">>, s}],
               billing_mode_summary =
                   #ddb2_billing_mode_summary{
                       billing_mode = provisioned,
                       last_update_to_pay_per_request_date_time = 1363728080.07},
               creation_date_time = 1363728080.07,
               item_count = 0,
               key_schema = {<<"ForumName">>, <<"Subject">>},
               local_secondary_indexes =
                   [#ddb2_local_secondary_index_description{
                       index_name = <<"LastPostIndex">>,
                       index_size_bytes = 0,
                       item_count = 0,
                       key_schema = {<<"ForumName">>, <<"LastPostDateTime">>},
                       projection = keys_only}],
               global_secondary_indexes =
                   [#ddb2_global_secondary_index_description{
                       index_name = <<"SubjectIndex">>,
                       index_size_bytes = 2048,
                       index_status = creating,
                       item_count = 47,
                       key_schema = {<<"Subject">>, <<"LastPostDateTime">>},
                       projection = keys_only,
                       provisioned_throughput = #ddb2_provisioned_throughput_description{
                          last_decrease_date_time = 0,
                          last_increase_date_time = 1,
                          number_of_decreases_today = 2,
                          read_capacity_units = 3,
                          write_capacity_units = 4}
                    }],
               provisioned_throughput =
                   #ddb2_provisioned_throughput_description{
                      last_decrease_date_time = undefined,
                      last_increase_date_time = undefined,
                      number_of_decreases_today = 0,
                      read_capacity_units = 5,
                      write_capacity_units = 5},
               table_name = <<"Thread">>,
               table_size_bytes = 0,
               table_status = creating}}}),
         ?_ddb_test(
            {"CreateTable response with INCLUDE projection", "
{
    \"TableDescription\": {
        \"AttributeDefinitions\": [
            {
                \"AttributeName\": \"ForumName\",
                \"AttributeType\": \"S\"
            },
            {
                \"AttributeName\": \"LastPostDateTime\",
                \"AttributeType\": \"S\"
            },
            {
                \"AttributeName\": \"Subject\",
                \"AttributeType\": \"S\"
            }
        ],
        \"BillingModeSummary\": {
            \"BillingMode\": \"PROVISIONED\",
            \"LastUpdateToPayPerRequestDateTime\": 1.36372808007E9
        },
        \"GlobalSecondaryIndexes\": [
            {
                \"IndexName\": \"SubjectIndex\",
                \"IndexSizeBytes\": 2048,
                \"IndexStatus\": \"CREATING\",
                \"ItemCount\": 47,
                \"KeySchema\": [
                    {
                        \"AttributeName\": \"Subject\",
                        \"KeyType\": \"HASH\"
                    },
                    {
                        \"AttributeName\": \"LastPostDateTime\",
                        \"KeyType\": \"RANGE\"
                    }
                ],
                \"Projection\": {
                    \"NonKeyAttributes\" : [
                        \"Author\"
                    ],
                    \"ProjectionType\": \"INCLUDE\"
                },
                \"ProvisionedThroughput\": {
                    \"LastDecreaseDateTime\": 0,
                    \"LastIncreaseDateTime\": 1,
                    \"NumberOfDecreasesToday\": 2,
                    \"ReadCapacityUnits\": 3,
                    \"WriteCapacityUnits\": 4
                }
            }
        ],
        \"CreationDateTime\": 1.36372808007E9,
        \"ItemCount\": 0,
        \"KeySchema\": [
            {
                \"AttributeName\": \"ForumName\",
                \"KeyType\": \"HASH\"
            },
            {
                \"AttributeName\": \"Subject\",
                \"KeyType\": \"RANGE\"
            }
        ],
        \"LocalSecondaryIndexes\": [
            {
                \"IndexName\": \"LastPostIndex\",
                \"IndexSizeBytes\": 0,
                \"ItemCount\": 0,
                \"KeySchema\": [
                    {
                        \"AttributeName\": \"ForumName\",
                        \"KeyType\": \"HASH\"
                    },
                    {
                        \"AttributeName\": \"LastPostDateTime\",
                        \"KeyType\": \"RANGE\"
                    }
                ],
                \"Projection\": {
                    \"ProjectionType\": \"INCLUDE\",
                    \"NonKeyAttributes\": [\"Author\", \"Body\"]
                }
            }
        ],
        \"ProvisionedThroughput\": {
            \"NumberOfDecreasesToday\": 0,
            \"ReadCapacityUnits\": 5,
            \"WriteCapacityUnits\": 5
        },
        \"TableName\": \"Thread\",
        \"TableSizeBytes\": 0,
        \"TableStatus\": \"CREATING\"
    }
}",
             {ok, #ddb2_table_description
              {attribute_definitions = [{<<"ForumName">>, s},
                                        {<<"LastPostDateTime">>, s},
                                        {<<"Subject">>, s}],
               billing_mode_summary =
                   #ddb2_billing_mode_summary{
                       billing_mode = provisioned,
                       last_update_to_pay_per_request_date_time = 1363728080.07},
               creation_date_time = 1363728080.07,
               item_count = 0,
               key_schema = {<<"ForumName">>, <<"Subject">>},
               local_secondary_indexes =
                   [#ddb2_local_secondary_index_description{
                       index_name = <<"LastPostIndex">>,
                       index_size_bytes = 0,
                       item_count = 0,
                       key_schema = {<<"ForumName">>, <<"LastPostDateTime">>},
                       projection = {include, [<<"Author">>, <<"Body">>]}}],
               global_secondary_indexes =
                   [#ddb2_global_secondary_index_description{
                       index_name = <<"SubjectIndex">>,
                       index_size_bytes = 2048,
                       index_status = creating,
                       item_count = 47,
                       key_schema = {<<"Subject">>, <<"LastPostDateTime">>},
                       projection = {include, [<<"Author">>]},
                       provisioned_throughput = #ddb2_provisioned_throughput_description{
                          last_decrease_date_time = 0,
                          last_increase_date_time = 1,
                          number_of_decreases_today = 2,
                          read_capacity_units = 3,
                          write_capacity_units = 4}
                    }],
               provisioned_throughput =
                   #ddb2_provisioned_throughput_description{
                      last_decrease_date_time = undefined,
                      last_increase_date_time = undefined,
                      number_of_decreases_today = 0,
                      read_capacity_units = 5,
                      write_capacity_units = 5},
               table_name = <<"Thread">>,
               table_size_bytes = 0,
               table_status = creating}}}),
         ?_ddb_test(
            {"CreateTable response with hash key only", "
{
    \"TableDescription\": {
        \"AttributeDefinitions\": [
            {
                \"AttributeName\": \"ForumName\",
                \"AttributeType\": \"S\"
            }
        ],
        \"BillingModeSummary\": {
            \"BillingMode\": \"PROVISIONED\",
            \"LastUpdateToPayPerRequestDateTime\": 1.36372808007E9
        },
        \"CreationDateTime\": 1.36372808007E9,
        \"ItemCount\": 0,
        \"KeySchema\": [
            {
                \"AttributeName\": \"ForumName\",
                \"KeyType\": \"HASH\"
            }
        ],
        \"ProvisionedThroughput\": {
            \"NumberOfDecreasesToday\": 0,
            \"ReadCapacityUnits\": 1,
            \"WriteCapacityUnits\": 1
        },
        \"TableName\": \"Thread\",
        \"TableSizeBytes\": 0,
        \"TableStatus\": \"CREATING\"
    }
}",
             {ok, #ddb2_table_description
              {attribute_definitions = [{<<"ForumName">>, s}],
               billing_mode_summary =
               #ddb2_billing_mode_summary{
                   billing_mode = provisioned,
                   last_update_to_pay_per_request_date_time = 1363728080.07},
               creation_date_time = 1363728080.07,
               item_count = 0,
               key_schema = <<"ForumName">>,
               local_secondary_indexes = undefined,
               provisioned_throughput =
                   #ddb2_provisioned_throughput_description{
                      last_decrease_date_time = undefined,
                      last_increase_date_time = undefined,
                      number_of_decreases_today = 0,
                      read_capacity_units = 1,
                      write_capacity_units = 1},
               table_name = <<"Thread">>,
               table_size_bytes = 0,
               table_status = creating}}}),
         ?_ddb_test(
            {"CreateTable response with billing_mode = pay_per_request", "
{
    \"TableDescription\": {
        \"AttributeDefinitions\": [
            {
                \"AttributeName\": \"ForumName\",
                \"AttributeType\": \"S\"
            }
        ],
        \"BillingModeSummary\": {
            \"BillingMode\": \"PAY_PER_REQUEST\",
            \"LastUpdateToPayPerRequestDateTime\": 1.36372808007E9
        },
        \"CreationDateTime\": 1.36372808007E9,
        \"ItemCount\": 0,
        \"KeySchema\": [
            {
                \"AttributeName\": \"ForumName\",
                \"KeyType\": \"HASH\"
            }
        ],
        \"ProvisionedThroughput\": {
            \"NumberOfDecreasesToday\": 0,
            \"ReadCapacityUnits\": 1,
            \"WriteCapacityUnits\": 1
        },
        \"TableName\": \"Thread\",
        \"TableSizeBytes\": 0,
        \"TableStatus\": \"CREATING\"
    }
}",
             {ok, #ddb2_table_description
              {attribute_definitions = [{<<"ForumName">>, s}],
               billing_mode_summary =
               #ddb2_billing_mode_summary{
                   billing_mode = pay_per_request,
                   last_update_to_pay_per_request_date_time = 1363728080.07},
               creation_date_time = 1363728080.07,
               item_count = 0,
               key_schema = <<"ForumName">>,
               local_secondary_indexes = undefined,
               provisioned_throughput =
                   #ddb2_provisioned_throughput_description{
                      last_decrease_date_time = undefined,
                      last_increase_date_time = undefined,
                      number_of_decreases_today = 0,
                      read_capacity_units = 1,
                      write_capacity_units = 1},
               table_name = <<"Thread">>,
               table_size_bytes = 0,
               table_status = creating}}})
        ],

    output_tests(?_f(erlcloud_ddb2:create_table(<<"name">>, [{<<"key">>, s}], <<"key">>, 5, 10)), Tests).

%% DeleteItem test based on the API examples:
%% http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_DeleteItem.html
delete_item_input_tests(_) ->
    Tests =
        [?_ddb_test(
            {"DeleteItem example request",
             ?_f(erlcloud_ddb2:delete_item(<<"Thread">>,
                                          [{<<"ForumName">>, {s, <<"Amazon DynamoDB">>}},
                                           {<<"Subject">>, {s, <<"How do I update multiple items?">>}}],
                                          [{return_values, all_old},
                                           {expected, {<<"Replies">>, null}}])), "
{
    \"TableName\": \"Thread\",
    \"Key\": {
        \"ForumName\": {
            \"S\": \"Amazon DynamoDB\"
        },
        \"Subject\": {
            \"S\": \"How do I update multiple items?\"
        }
    },
    \"Expected\": {
        \"Replies\": {
            \"ComparisonOperator\": \"NULL\"
        }
    },
    \"ReturnValues\": \"ALL_OLD\"
}"
            }),
         ?_ddb_test(
            {"DeleteItem example request with ConditionExpression",
             ?_f(erlcloud_ddb2:delete_item(<<"Thread">>,
                                          [{<<"ForumName">>, {s, <<"Amazon DynamoDB">>}},
                                           {<<"Subject">>, {s, <<"How do I update multiple items?">>}}],
                                          [{return_values, all_old},
                                           {condition_expression, <<"attribute_not_exists(Replies)">>}])), "
{
    \"TableName\": \"Thread\",
    \"Key\": {
        \"ForumName\": {
            \"S\": \"Amazon DynamoDB\"
        },
        \"Subject\": {
            \"S\": \"How do I update multiple items?\"
        }
    },
    \"ConditionExpression\": \"attribute_not_exists(Replies)\",
    \"ReturnValues\": \"ALL_OLD\"
}"
            }),
         ?_ddb_test(
            {"DeleteItem return metrics",
             ?_f(erlcloud_ddb2:delete_item(<<"Thread">>,
                                          {<<"ForumName">>, {s, <<"Amazon DynamoDB">>}},
                                          [{return_consumed_capacity, total},
                                           {return_item_collection_metrics, size}])), "
{
    \"TableName\": \"Thread\",
    \"Key\": {
        \"ForumName\": {
            \"S\": \"Amazon DynamoDB\"
        }
    },
    \"ReturnConsumedCapacity\": \"TOTAL\",
    \"ReturnItemCollectionMetrics\": \"SIZE\"
}"
            })
        ],

    Response = "
{
    \"Attributes\": {
        \"LastPostedBy\": {
            \"S\": \"fred@example.com\"
        },
        \"ForumName\": {
            \"S\": \"Amazon DynamoDB\"
        },
        \"LastPostDateTime\": {
            \"S\": \"201303201023\"
        },
        \"Tags\": {
            \"SS\": [\"Update\",\"Multiple Items\",\"HelpMe\"]
        },
        \"Subject\": {
            \"S\": \"How do I update multiple items?\"
        },
        \"Message\": {
            \"S\": \"I want to update multiple items in a single API call. What's the best way to do that?\"
        }
    }
}",
    input_tests(Response, Tests).

delete_item_output_tests(_) ->
    Tests =
        [?_ddb_test(
            {"DeleteItem example response", "
{
    \"Attributes\": {
        \"LastPostedBy\": {
            \"S\": \"fred@example.com\"
        },
        \"ForumName\": {
            \"S\": \"Amazon DynamoDB\"
        },
        \"LastPostDateTime\": {
            \"S\": \"201303201023\"
        },
        \"Tags\": {
            \"SS\": [\"Update\",\"Multiple Items\",\"HelpMe\"]
        },
        \"Subject\": {
            \"S\": \"How do I update multiple items?\"
        },
        \"Message\": {
            \"S\": \"I want to update multiple items in a single API call. What's the best way to do that?\"
        }
    }
}",
             {ok, #ddb2_delete_item{
                     attributes = [{<<"LastPostedBy">>, <<"fred@example.com">>},
                                   {<<"ForumName">>, <<"Amazon DynamoDB">>},
                                   {<<"LastPostDateTime">>, <<"201303201023">>},
                                   {<<"Tags">>, [<<"Update">>, <<"Multiple Items">>, <<"HelpMe">>]},
                                   {<<"Subject">>, <<"How do I update multiple items?">>},
                                   {<<"Message">>, <<"I want to update multiple items in a single API call. What's the best way to do that?">>}
                                  ]}}}),
         ?_ddb_test(
            {"DeleteItem metrics response", "
{
    \"ConsumedCapacity\": {
        \"CapacityUnits\": 1,
        \"TableName\": \"Thread\"
    },
    \"ItemCollectionMetrics\": {
        \"ItemCollectionKey\": {
            \"ForumName\": {
                \"S\": \"Amazon DynamoDB\"
            }
        },
        \"SizeEstimateRangeGB\": [1, 2]
    }
}",
             {ok, #ddb2_delete_item{
                     consumed_capacity =
                         #ddb2_consumed_capacity{
                            table_name = <<"Thread">>,
                            capacity_units = 1},
                     item_collection_metrics =
                         #ddb2_item_collection_metrics{
                            item_collection_key = <<"Amazon DynamoDB">>,
                            size_estimate_range_gb = {1,2}}
                     }}})
        ],

    output_tests(?_f(erlcloud_ddb2:delete_item(<<"table">>, {<<"k">>, <<"v">>}, [{out, record}])), Tests).

%% DeleteTable test based on the API examples:
%% http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_DeleteTable.html
delete_table_input_tests(_) ->
    Tests =
        [?_ddb_test(
            {"DeleteTable example request",
             ?_f(erlcloud_ddb2:delete_table(<<"Reply">>)), "
{
    \"TableName\": \"Reply\"
}"
            })
        ],

    Response = "
{
    \"TableDescription\": {
        \"ItemCount\": 0,
        \"ProvisionedThroughput\": {
            \"NumberOfDecreasesToday\": 0,
            \"ReadCapacityUnits\": 5,
            \"WriteCapacityUnits\": 5
        },
        \"TableName\": \"Reply\",
        \"TableSizeBytes\": 0,
        \"TableStatus\": \"DELETING\"
    }
}",
    input_tests(Response, Tests).

delete_table_output_tests(_) ->
    Tests =
        [?_ddb_test(
            {"DeleteTable example response", "
{
    \"TableDescription\": {
        \"ItemCount\": 0,
        \"ProvisionedThroughput\": {
            \"NumberOfDecreasesToday\": 0,
            \"ReadCapacityUnits\": 5,
            \"WriteCapacityUnits\": 5
        },
        \"TableName\": \"Reply\",
        \"TableSizeBytes\": 0,
        \"TableStatus\": \"DELETING\"
    }
}",
             {ok, #ddb2_table_description
              {item_count = 0,
               provisioned_throughput = #ddb2_provisioned_throughput_description{
                                           read_capacity_units = 5,
                                           write_capacity_units = 5,
                                           number_of_decreases_today = 0},
               table_name = <<"Reply">>,
               table_size_bytes = 0,
               table_status = deleting}}})
        ],

    output_tests(?_f(erlcloud_ddb2:delete_table(<<"name">>)), Tests).

%% DescribeBackup test based on the API examples:
%% https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_DescribeContinuousBackups.html
describe_backup_input_tests(_) ->
 Tests =
  [?_ddb_test(
   {"DescribeBackup example request",
    ?_f(erlcloud_ddb2:describe_backup(<<"arn:aws:dynamodb:us-east-1:387047610112:table/Forum/backup/01523517555423-69b67bcb">>)), "
    {
        \"BackupArn\": \"arn:aws:dynamodb:us-east-1:387047610112:table/Forum/backup/01523517555423-69b67bcb\"
    }"
   })
  ],
 Response = "
{
    \"BackupDescription\": {
        \"BackupDetails\": {
            \"BackupArn\": \"arn:aws:dynamodb:us-east-1:387047610112:table/Forum/backup/01523517555423-69b67bcb\",
            \"BackupCreationDateTime\": 1523269031.475,
            \"BackupName\": \"Forum_Backup\",
            \"BackupSizeBytes\": 1,
            \"BackupStatus\": \"DELETED\"
        },
        \"SourceTableDetails\": {
            \"ItemCount\": 0,
            \"KeySchema\": [
               {
                  \"AttributeName\": \"id\",
                  \"KeyType\": \"HASH\"
               }
            ],
            \"ProvisionedThroughput\": {
               \"ReadCapacityUnits\": 5,
               \"WriteCapacityUnits\": 5
            },
            \"TableArn\": \"arn:aws:dynamodb:us-east-1:387047610112:table/Forum\",
            \"TableCreationDateTime\": 1523269031.475,
            \"TableId\": \"284a7e42-42ed-4854-b9fd-9a5a4b972dc4\",
            \"TableName\": \"Forum\",
            \"TableSizeBytes\": 1
        },
       \"SourceTableFeatureDetails\": {
           \"GlobalSecondaryIndexes\": [
               {
                  \"IndexName\": \"Idx\",
                  \"KeySchema\": [
                      {
                          \"AttributeName\": \"Atr\",
                          \"KeyType\": \"HASH\"
                      }
                  ],
                  \"Projection\": {
                      \"NonKeyAttributes\": [ \"Atr2\" ],
                      \"ProjectionType\": \"ALL\"
                  },
                   \"ProvisionedThroughput\": {
                      \"ReadCapacityUnits\": 5,
                      \"WriteCapacityUnits\": 5
                  }
               }
           ],
           \"LocalSecondaryIndexes\": [
               {
                   \"IndexName\": \"Idx2\",
                    \"KeySchema\": [
                        {
                            \"AttributeName\": \"Atr3\",
                            \"KeyType\": \"RANGE\"
                        }
                   ],
                   \"Projection\": {
                       \"NonKeyAttributes\": [ \"Atr4\" ],
                       \"ProjectionType\": \"KEYS_ONLY\"
                   }
               }
           ],
           \"SSEDescription\": {
               \"Status\": \"DISABLED\"
           },
           \"StreamDescription\": {
               \"StreamEnabled\": true,
               \"StreamViewType\": \"NEW_AND_OLD_IMAGES\"
           },
           \"TimeToLiveDescription\": {
               \"AttributeName\": \"none\",
               \"TimeToLiveStatus\": \"DISABLED\"
           }
       }
    }
}",
 input_tests(Response, Tests).

describe_backup_output_tests(_) ->
 Tests =
  [?_ddb_test(
   {"DescribeBackup example response", "
{
     \"BackupDescription\": {
         \"BackupDetails\": {
             \"BackupArn\": \"arn:aws:dynamodb:us-east-1:387047610112:table/Forum/backup/01523517555423-69b67bcb\",
             \"BackupCreationDateTime\": 1523269031.475,
             \"BackupName\": \"Forum_Backup\",
             \"BackupSizeBytes\": 1,
             \"BackupStatus\": \"DELETED\"
         },
         \"SourceTableDetails\": {
             \"ItemCount\": 0,
             \"KeySchema\": [
                 {
                     \"AttributeName\": \"id\",
                     \"KeyType\": \"HASH\"
                 }
             ],
             \"ProvisionedThroughput\": {
                 \"ReadCapacityUnits\": 5,
                 \"WriteCapacityUnits\": 5
             },
             \"TableArn\": \"arn:aws:dynamodb:us-east-1:387047610112:table/Forum\",
             \"TableCreationDateTime\": 1523269031.475,
             \"TableId\": \"284a7e42-42ed-4854-b9fd-9a5a4b972dc4\",
             \"TableName\": \"Forum\",
             \"TableSizeBytes\": 1
         },
         \"SourceTableFeatureDetails\": {
             \"GlobalSecondaryIndexes\": [
                {
                    \"IndexName\": \"Idx\",
                    \"KeySchema\": [
                       {
                           \"AttributeName\": \"Atr\",
                           \"KeyType\": \"HASH\"
                       }
                    ],
                    \"Projection\": {
                        \"NonKeyAttributes\": [ \"Atr2\" ],
                        \"ProjectionType\": \"ALL\"
                    },
                    \"ProvisionedThroughput\": {
                        \"ReadCapacityUnits\": 5,
                        \"WriteCapacityUnits\": 5
                    }
                }
            ],
            \"LocalSecondaryIndexes\": [
                {
                    \"IndexName\": \"Idx2\",
                    \"KeySchema\": [
                        {
                            \"AttributeName\": \"Atr3\",
                            \"KeyType\": \"RANGE\"
                        }
                    ],
                    \"Projection\": {
                        \"NonKeyAttributes\": [ \"Atr4\" ],
                        \"ProjectionType\": \"KEYS_ONLY\"
                    }
                }
            ],
             \"SSEDescription\": {
                 \"Status\": \"DISABLED\"
             },
             \"StreamDescription\": {
                 \"StreamEnabled\": true,
                 \"StreamViewType\": \"NEW_AND_OLD_IMAGES\"
             },
             \"TimeToLiveDescription\": {
                 \"AttributeName\": \"none\",
                 \"TimeToLiveStatus\": \"DISABLED\"
             }
         }
    }
}",
    {ok,#ddb2_backup_description{
        backup_details =
            #ddb2_backup_details{
                backup_arn = <<"arn:aws:dynamodb:us-east-1:387047610112:table/Forum/backup/01523517555423-69b67bcb">>,
                backup_creation_date_time = 1523269031.475,
                backup_name = <<"Forum_Backup">>,
                backup_size_Bytes = 1,
                backup_status = deleted},
        source_table_details =
            #ddb2_source_table_details{
                item_count = 0,
                key_schema = <<"id">>,
                provisioned_throughput =
                    #ddb2_provisioned_throughput{
                     read_capacity_units = 5,
                     write_capacity_units = 5},
                table_arn = <<"arn:aws:dynamodb:us-east-1:387047610112:table/Forum">>,
                table_creation_date_time = 1523269031.475,
                table_id = <<"284a7e42-42ed-4854-b9fd-9a5a4b972dc4">>,
                table_name = <<"Forum">>,
                table_size_bytes = 1},
        source_table_feature_details =
            #ddb2_source_table_feature_details{
             global_secondary_indexes =
                 [#ddb2_global_secondary_index_info{
                     index_name = <<"Idx">>,
                     key_schema = <<"Atr">>,
                     projection = all,
                     provisioned_throughput =
                        #ddb2_provisioned_throughput{
                         read_capacity_units = 5,
                         write_capacity_units = 5
                      }}],
             local_secondary_indexes =
                 [#ddb2_local_secondary_index_info{
                   index_name = <<"Idx2">>,
                   key_schema = <<"Atr3">>,
                   projection = keys_only
                  }],
             sse_description = {status,disabled},
             stream_description = {true,new_and_old_images},
             time_to_live_description =
                 #ddb2_time_to_live_description{
                  attribute_name = <<"none">>,
                  time_to_live_status = disabled}}
       }}
   })
  ],

 output_tests(?_f(erlcloud_ddb2:describe_backup(<<"BackupArn">>)), Tests).

%% DescribeContinuousBackups test based on the API examples:
%% https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_DescribeContinuousBackups.html
describe_continuous_backups_input_tests(_) ->
 Tests =
  [?_ddb_test(
   {"DescribeContinuousBackups example request",
    ?_f(erlcloud_ddb2:describe_continuous_backups(<<"Forum">>)), "
    {
        \"TableName\": \"Forum\"
    }"
   })
  ],
 Response = "
{
   \"ContinuousBackupsDescription\": {
       \"ContinuousBackupsStatus\": \"ENABLED\",
        \"PointInTimeRecoveryDescription\": {
            \"EarliestRestorableDateTime\": 1,
            \"LatestRestorableDateTime\": 1,
            \"PointInTimeRecoveryStatus\": \"DISABLED\"
        }
   }
}",
 input_tests(Response, Tests).

describe_continuous_backups_output_tests(_) ->
 Tests =
  [?_ddb_test(
   {"DescribeContinuousBackups example response", "
{
   \"ContinuousBackupsDescription\": {
       \"ContinuousBackupsStatus\": \"ENABLED\",
        \"PointInTimeRecoveryDescription\": {
            \"EarliestRestorableDateTime\": 1,
            \"LatestRestorableDateTime\": 1,
            \"PointInTimeRecoveryStatus\": \"DISABLED\"
        }
   }
}",
    {ok,#ddb2_continuous_backups_description{
        continuous_backups_status = enabled,
        point_in_time_recovery_description =
            #ddb2_point_in_time_recovery_description{
                earliest_restorable_date_time = 1,
                latest_restorable_date_time = 1,
                point_in_time_recovery_status = disabled}
    }}
   })
  ],

 output_tests(?_f(erlcloud_ddb2:describe_continuous_backups(<<"Forum">>)), Tests).

%% DescribeLimits test based on the API examples:
%% http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_DescribeLimits.html
describe_limits_input_tests(_) ->
    Tests =
        [?_ddb_test(
            {"DescribeLimits example request",
             ?_f(erlcloud_ddb2:describe_limits()), "
{
}"
            })
        ],

    Response = "
{
    \"AccountMaxReadCapacityUnits\": 20000,
    \"AccountMaxWriteCapacityUnits\": 20000,
    \"TableMaxReadCapacityUnits\": 10000,
    \"TableMaxWriteCapacityUnits\": 10000
}",
    input_tests(Response, Tests).

describe_limits_output_tests(_) ->
    Tests =
        [?_ddb_test(
            {"DescribeLimits example response", "
{
    \"AccountMaxReadCapacityUnits\": 20000,
    \"AccountMaxWriteCapacityUnits\": 20000,
    \"TableMaxReadCapacityUnits\": 10000,
    \"TableMaxWriteCapacityUnits\": 10000
}",
             {ok, #ddb2_describe_limits
              {account_max_read_capacity_units = 20000,
               account_max_write_capacity_units = 20000,
               table_max_read_capacity_units = 10000,
               table_max_write_capacity_units = 10000}}})
        ],

    output_tests(?_f(erlcloud_ddb2:describe_limits()), Tests).

%% DescribeGlobalTable input test:
describe_global_table_input_tests(_) ->
    Tests =
          [?_ddb_test(
              {"DescribeGlobalTable example request",
               ?_f(erlcloud_ddb2:describe_global_table(<<"Thread">>)), "
{
   \"GlobalTableName\": \"Thread\"
}"
              })],
      Response = "
{
   \"GlobalTableDescription\": {
      \"CreationDateTime\": 1519161181.107,
      \"GlobalTableArn\": \"arn:aws:dynamodb::111122223333:global-table/Thread\",
      \"GlobalTableName\": \"Thread\",
      \"GlobalTableStatus\": \"ACTIVE\",
      \"ReplicationGroup\": [
          {
             \"RegionName\": \"us-east-1\"
          },{
             \"RegionName\": \"us-west-2\"
          }
      ]
   }
}",
      input_tests(Response, Tests).

%% DescribeGlobalTable output test:
describe_global_table_output_tests(_) ->
    Tests =
        [?_ddb_test(
            {"DescribeGlobalTable example response with CREATING status ", "
{
   \"GlobalTableDescription\": {
      \"CreationDateTime\": 1519161181.107,
      \"GlobalTableArn\": \"arn:aws:dynamodb::111122223333:global-table/Thread\",
      \"GlobalTableName\": \"Thread\",
      \"GlobalTableStatus\": \"CREATING\",
      \"ReplicationGroup\": [
          {
             \"RegionName\": \"us-east-1\"
          }
      ]
   }
}",
              {ok, #ddb2_global_table_description{
                creation_date_time = 1519161181.107,
                global_table_arn = <<"arn:aws:dynamodb::111122223333:global-table/Thread">>,
                global_table_name = <<"Thread">>,
                global_table_status = creating,
                replication_group = [#ddb2_replica_description{region_name = <<"us-east-1">>}]}}}),

         ?_ddb_test(
            {"DescribeGlobalTable example response with ACTIVE status ", "
{
   \"GlobalTableDescription\": {
      \"CreationDateTime\": 1519161181.107,
      \"GlobalTableArn\": \"arn:aws:dynamodb::111122223333:global-table/Thread\",
      \"GlobalTableName\": \"Thread\",
      \"GlobalTableStatus\": \"ACTIVE\",
      \"ReplicationGroup\": [
          {
             \"RegionName\": \"us-east-1\"
          },{
             \"RegionName\": \"eu-west-1\"
          }
      ]
   }
}",
              {ok, #ddb2_global_table_description{
                creation_date_time = 1519161181.107,
                global_table_arn = <<"arn:aws:dynamodb::111122223333:global-table/Thread">>,
                global_table_name = <<"Thread">>,
                global_table_status = active,
                replication_group = [#ddb2_replica_description{region_name = <<"us-east-1">>},
                                     #ddb2_replica_description{region_name = <<"eu-west-1">>}]}}})],
    output_tests(?_f(erlcloud_ddb2:describe_global_table(<<"Thread">>)), Tests).

%% DescribeGlobalTableSettings tests based on the API request/response syntax:
%% http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_DescribeGlobalTableSettings.html
describe_global_table_settings_input_tests(_) ->
    Tests =
        [?_ddb_test(
            {"DescribeGlobalTableSettings example request",
             ?_f(erlcloud_ddb2:describe_global_table_settings(<<"Thread">>)), "
{
    \"GlobalTableName\":\"Thread\"
}"
            })
        ],
    Response = "
{
  \"GlobalTableName\": \"Thread\",
  \"ReplicaSettings\": [
    {
      \"RegionName\": \"us-west-2\",
      \"ReplicaBillingModeSummary\": {
        \"BillingMode\": \"PROVISIONED\",
        \"LastUpdateToPayPerRequestDateTime\": 1578092745.455
      },
      \"ReplicaGlobalSecondaryIndexSettings\": [
        {
          \"IndexName\": \"id-index\",
          \"IndexStatus\": \"ACTIVE\",
          \"ProvisionedReadCapacityAutoScalingSettings\": {
            \"AutoScalingDisabled\": false,
            \"AutoScalingRoleArn\": \"arn:test\",
            \"MaximumUnits\": 20,
            \"MinimumUnits\": 10,
            \"ScalingPolicies\": [
              {
                \"PolicyName\": \"PolicyName\",
                \"TargetTrackingScalingPolicyConfiguration\": {
                  \"DisableScaleIn\": false,
                  \"ScaleInCooldown\": 600,
                  \"ScaleOutCooldown\": 600,
                  \"TargetValue\": 70.0
                }
              }
            ]
          },
          \"ProvisionedReadCapacityUnits\": 10,
          \"ProvisionedWriteCapacityAutoScalingSettings\": {
            \"AutoScalingDisabled\": false,
            \"AutoScalingRoleArn\": \"arn:test\",
            \"MaximumUnits\": 20,
            \"MinimumUnits\": 10,
            \"ScalingPolicies\": [
              {
                \"PolicyName\": \"PolicyName\",
                \"TargetTrackingScalingPolicyConfiguration\": {
                  \"DisableScaleIn\": true,
                  \"ScaleInCooldown\": 600,
                  \"ScaleOutCooldown\": 600,
                  \"TargetValue\": 70.0
                }
              }
            ]
          },
          \"ProvisionedWriteCapacityUnits\": 10
        }
      ],
      \"ReplicaProvisionedReadCapacityAutoScalingSettings\": {
        \"AutoScalingDisabled\": true,
        \"AutoScalingRoleArn\": \"arn:test\",
        \"MaximumUnits\": 20,
        \"MinimumUnits\": 10,
        \"ScalingPolicies\": [
          {
            \"PolicyName\": \"policy\",
            \"TargetTrackingScalingPolicyConfiguration\": {
              \"DisableScaleIn\": false,
              \"ScaleInCooldown\": 600,
              \"ScaleOutCooldown\": 600,
              \"TargetValue\": 70.0
            }
          }
        ]
      },
      \"ReplicaProvisionedReadCapacityUnits\": 10,
      \"ReplicaProvisionedWriteCapacityAutoScalingSettings\": {
        \"AutoScalingDisabled\": false,
        \"AutoScalingRoleArn\": \"arn:test\",
        \"MaximumUnits\": 20,
        \"MinimumUnits\": 10,
        \"ScalingPolicies\": [
          {
            \"PolicyName\": \"policy\",
            \"TargetTrackingScalingPolicyConfiguration\": {
              \"DisableScaleIn\": false,
              \"ScaleInCooldown\": 600,
              \"ScaleOutCooldown\": 600,
              \"TargetValue\": 70.0
            }
          }
        ]
      },
      \"ReplicaProvisionedWriteCapacityUnits\": 10,
      \"ReplicaStatus\": \"ACTIVE\"
    }
  ]
}",
    input_tests(Response, Tests).

describe_global_table_settings_output_tests(_) ->
    Tests =
    [?_ddb_test(
        {"DescribeGlobalTableSettings example response", "
{
  \"GlobalTableName\": \"Thread\",
  \"ReplicaSettings\": [
    {
      \"RegionName\": \"us-west-2\",
      \"ReplicaBillingModeSummary\": {
        \"BillingMode\": \"PROVISIONED\",
        \"LastUpdateToPayPerRequestDateTime\": 1578092745.455
      },
      \"ReplicaGlobalSecondaryIndexSettings\": [
        {
          \"IndexName\": \"id-index\",
          \"IndexStatus\": \"ACTIVE\",
          \"ProvisionedReadCapacityAutoScalingSettings\": {
            \"AutoScalingDisabled\": false,
            \"AutoScalingRoleArn\": \"arn:test\",
            \"MaximumUnits\": 20,
            \"MinimumUnits\": 10,
            \"ScalingPolicies\": [
              {
                \"PolicyName\": \"PolicyName\",
                \"TargetTrackingScalingPolicyConfiguration\": {
                  \"DisableScaleIn\": false,
                  \"ScaleInCooldown\": 600,
                  \"ScaleOutCooldown\": 600,
                  \"TargetValue\": 70.0
                }
              }
            ]
          },
          \"ProvisionedReadCapacityUnits\": 10,
          \"ProvisionedWriteCapacityAutoScalingSettings\": {
            \"AutoScalingDisabled\": false,
            \"AutoScalingRoleArn\": \"arn:test\",
            \"MaximumUnits\": 20,
            \"MinimumUnits\": 10,
            \"ScalingPolicies\": [
              {
                \"PolicyName\": \"PolicyName\",
                \"TargetTrackingScalingPolicyConfiguration\": {
                  \"DisableScaleIn\": false,
                  \"ScaleInCooldown\": 600,
                  \"ScaleOutCooldown\": 600,
                  \"TargetValue\": 70.0
                }
              }
            ]
          },
          \"ProvisionedWriteCapacityUnits\": 10
        }
      ],
      \"ReplicaProvisionedReadCapacityAutoScalingSettings\": {
        \"AutoScalingDisabled\": false,
        \"AutoScalingRoleArn\": \"arn:test\",
        \"MaximumUnits\": 20,
        \"MinimumUnits\": 10,
        \"ScalingPolicies\": [
          {
            \"PolicyName\": \"PolicyName\",
            \"TargetTrackingScalingPolicyConfiguration\": {
              \"DisableScaleIn\": false,
              \"ScaleInCooldown\": 600,
              \"ScaleOutCooldown\": 600,
              \"TargetValue\": 70.0
            }
          }
        ]
      },
      \"ReplicaProvisionedReadCapacityUnits\": 10,
      \"ReplicaProvisionedWriteCapacityAutoScalingSettings\": {
        \"AutoScalingDisabled\": false,
        \"AutoScalingRoleArn\": \"arn:test\",
        \"MaximumUnits\": 20,
        \"MinimumUnits\": 10,
        \"ScalingPolicies\": [
          {
            \"PolicyName\": \"PolicyName\",
            \"TargetTrackingScalingPolicyConfiguration\": {
              \"DisableScaleIn\": false,
              \"ScaleInCooldown\": 600,
              \"ScaleOutCooldown\": 600,
              \"TargetValue\": 70.0
            }
          }
        ]
      },
      \"ReplicaProvisionedWriteCapacityUnits\": 10,
      \"ReplicaStatus\": \"ACTIVE\"
    }
  ]
}", {ok, [#ddb2_replica_settings_description{region_name = <<"us-west-2">>,
                                             replica_billing_mode_summary = #ddb2_billing_mode_summary{billing_mode = provisioned,
                                                                                                       last_update_to_pay_per_request_date_time = 1578092745.455},
                                             replica_global_secondary_index_settings = [#ddb2_replica_global_secondary_index_settings_description{index_name = <<"id-index">>,
                                                                                                                                                  index_status = active,
                                                                                                                                                  provisioned_read_capacity_auto_scaling_settings = #ddb2_auto_scaling_settings_description{auto_scaling_disabled = false,
                                                                                                                                                                                                                                            auto_scaling_role_arn = <<"arn:test">>,
                                                                                                                                                                                                                                            maximum_units = 20,
                                                                                                                                                                                                                                            minimum_units = 10,
                                                                                                                                                                                                                                            scaling_policies = [#ddb2_auto_scaling_policy_description{policy_name = <<"PolicyName">>,
                                                                                                                                                                                                                                                                                                      target_tracking_scaling_policy_configuration = #ddb2_auto_scaling_target_tracking_scaling_policy_configuration_description{disable_scale_in = false,
                                                                                                                                                                                                                                                                                                                                                                                                                                 scale_in_cooldown = 600,
                                                                                                                                                                                                                                                                                                                                                                                                                                 scale_out_cooldown = 600,
                                                                                                                                                                                                                                                                                                                                                                                                                                 target_value = 70.0}}]},
                                                                                                                                                  provisioned_read_capacity_units = 10,
                                                                                                                                                  provisioned_write_capacity_auto_scaling_settings = #ddb2_auto_scaling_settings_description{auto_scaling_disabled = false,
                                                                                                                                                                                                                                             auto_scaling_role_arn = <<"arn:test">>,
                                                                                                                                                                                                                                             maximum_units = 20,
                                                                                                                                                                                                                                             minimum_units = 10,
                                                                                                                                                                                                                                             scaling_policies = [#ddb2_auto_scaling_policy_description{policy_name = <<"PolicyName">>,
                                                                                                                                                                                                                                                                                                      target_tracking_scaling_policy_configuration = #ddb2_auto_scaling_target_tracking_scaling_policy_configuration_description{disable_scale_in = false,
                                                                                                                                                                                                                                                                                                                                                                                                                                 scale_in_cooldown = 600,
                                                                                                                                                                                                                                                                                                                                                                                                                                 scale_out_cooldown = 600,
                                                                                                                                                                                                                                                                                                                                                                                                                                 target_value = 70.0}}]},
                                                                                                                                                  provisioned_write_capacity_units = 10}],
                                             replica_provisioned_read_capacity_auto_scaling_settings = #ddb2_auto_scaling_settings_description{auto_scaling_disabled = false,
                                                                                                                                               auto_scaling_role_arn = <<"arn:test">>,
                                                                                                                                               maximum_units = 20,
                                                                                                                                               minimum_units = 10,
                                                                                                                                               scaling_policies = [#ddb2_auto_scaling_policy_description{policy_name = <<"PolicyName">>,
                                                                                                                                                                                                         target_tracking_scaling_policy_configuration = #ddb2_auto_scaling_target_tracking_scaling_policy_configuration_description{disable_scale_in = false,
                                                                                                                                                                                                                                                                                                                                    scale_in_cooldown = 600,
                                                                                                                                                                                                                                                                                                                                    scale_out_cooldown = 600,
                                                                                                                                                                                                                                                                                                                                    target_value = 70.0}}]},
                                             replica_provisioned_read_capacity_units = 10,
                                             replica_provisioned_write_capacity_auto_scaling_settings = #ddb2_auto_scaling_settings_description{auto_scaling_disabled = false,
                                                                                                                                                auto_scaling_role_arn = <<"arn:test">>,
                                                                                                                                                maximum_units = 20,
                                                                                                                                                minimum_units = 10,
                                                                                                                                                scaling_policies = [#ddb2_auto_scaling_policy_description{policy_name = <<"PolicyName">>,
                                                                                                                                                                                                          target_tracking_scaling_policy_configuration = #ddb2_auto_scaling_target_tracking_scaling_policy_configuration_description{disable_scale_in = false,
                                                                                                                                                                                                                                                                                                                                     scale_in_cooldown = 600,
                                                                                                                                                                                                                                                                                                                                     scale_out_cooldown = 600,
                                                                                                                                                                                                                                                                                                                                     target_value = 70.0}}]},
                                             replica_provisioned_write_capacity_units = 10,
                                             replica_status = active}]}})],
    output_tests(?_f(erlcloud_ddb2:describe_global_table_settings(<<"Thread">>)), Tests).

%% DescribeTable test based on the API examples:
%% http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_DescribeTable.html
describe_table_input_tests(_) ->
    Tests =
        [?_ddb_test(
            {"DescribeTable example request",
             ?_f(erlcloud_ddb2:describe_table(<<"Thread">>)), "
{
    \"TableName\":\"Thread\"
}"
            })
        ],

    Response = "
{
    \"Table\": {
        \"AttributeDefinitions\": [
            {
                \"AttributeName\": \"ForumName\",
                \"AttributeType\": \"S\"
            },
            {
                \"AttributeName\": \"LastPostDateTime\",
                \"AttributeType\": \"S\"
            },
            {
                \"AttributeName\": \"Subject\",
                \"AttributeType\": \"S\"
            }
        ],
        \"CreationDateTime\": 1.363729002358E9,
        \"GlobalTableVersion\": \"2019.11.21\",
        \"ItemCount\": 0,
        \"KeySchema\": [
            {
                \"AttributeName\": \"ForumName\",
                \"KeyType\": \"HASH\"
            },
            {
                \"AttributeName\": \"Subject\",
                \"KeyType\": \"RANGE\"
            }
        ],
        \"LocalSecondaryIndexes\": [
            {
                \"IndexName\": \"LastPostIndex\",
                \"IndexSizeBytes\": 0,
                \"ItemCount\": 0,
                \"KeySchema\": [
                    {
                        \"AttributeName\": \"ForumName\",
                        \"KeyType\": \"HASH\"
                    },
                    {
                        \"AttributeName\": \"LastPostDateTime\",
                        \"KeyType\": \"RANGE\"
                    }
                ],
                \"Projection\": {
                    \"ProjectionType\": \"KEYS_ONLY\"
                }
            }
        ],
        \"Replicas\": [
            {
                \"RegionName\": \"us-west-2\",
                \"ReplicaStatus\": \"ACTIVE\",
            },
            {
                \"RegionName\": \"eu-west-2\",
                \"ReplicaStatus\": \"ACTIVE\"
            }
        ],
        \"ProvisionedThroughput\": {
            \"NumberOfDecreasesToday\": 0,
            \"ReadCapacityUnits\": 5,
            \"WriteCapacityUnits\": 5
        },
        \"TableName\": \"Thread\",
        \"TableSizeBytes\": 0,
        \"TableStatus\": \"ACTIVE\"
    }
}",
    input_tests(Response, Tests).

describe_table_output_tests(_) ->
    Tests =
        [?_ddb_test(
            {"DescribeTable example response", "
{
    \"Table\": {
        \"AttributeDefinitions\": [
            {
                \"AttributeName\": \"ForumName\",
                \"AttributeType\": \"S\"
            },
            {
                \"AttributeName\": \"LastPostDateTime\",
                \"AttributeType\": \"S\"
            },
            {
                \"AttributeName\": \"Subject\",
                \"AttributeType\": \"S\"
            }
        ],
        \"GlobalSecondaryIndexes\": [
            {
                \"IndexName\": \"SubjectIndex\",
                \"IndexSizeBytes\": 2048,
                \"IndexStatus\": \"CREATING\",
                \"ItemCount\": 47,
                \"KeySchema\": [
                    {
                        \"AttributeName\": \"Subject\",
                        \"KeyType\": \"HASH\"
                    },
                    {
                        \"AttributeName\": \"LastPostDateTime\",
                        \"KeyType\": \"RANGE\"
                    }
                ],
                \"Projection\": {
                    \"NonKeyAttributes\" : [
                        \"Author\"
                    ],
                    \"ProjectionType\": \"INCLUDE\"
                },
                \"ProvisionedThroughput\": {
                    \"LastDecreaseDateTime\": 0,
                    \"LastIncreaseDateTime\": 1,
                    \"NumberOfDecreasesToday\": 2,
                    \"ReadCapacityUnits\": 3,
                    \"WriteCapacityUnits\": 4
                }
            }
        ],
        \"CreationDateTime\": 1.363729002358E9,
        \"GlobalTableVersion\": \"2019.11.21\",
        \"ItemCount\": 0,
        \"KeySchema\": [
            {
                \"AttributeName\": \"ForumName\",
                \"KeyType\": \"HASH\"
            },
            {
                \"AttributeName\": \"Subject\",
                \"KeyType\": \"RANGE\"
            }
        ],
        \"LocalSecondaryIndexes\": [
            {
                \"IndexName\": \"LastPostIndex\",
                \"IndexSizeBytes\": 0,
                \"ItemCount\": 0,
                \"KeySchema\": [
                    {
                        \"AttributeName\": \"ForumName\",
                        \"KeyType\": \"HASH\"
                    },
                    {
                        \"AttributeName\": \"LastPostDateTime\",
                        \"KeyType\": \"RANGE\"
                    }
                ],
                \"Projection\": {
                    \"ProjectionType\": \"KEYS_ONLY\"
                }
            }
        ],
        \"Replicas\": [
            {
                \"RegionName\": \"us-west-2\",
                \"ReplicaStatus\": \"ACTIVE\",
            },
            {
                \"RegionName\": \"eu-west-2\",
                \"ReplicaStatus\": \"ACTIVE\"
            }
        ],
        \"ProvisionedThroughput\": {
            \"NumberOfDecreasesToday\": 0,
            \"ReadCapacityUnits\": 5,
            \"WriteCapacityUnits\": 5
        },
        \"TableName\": \"Thread\",
        \"TableSizeBytes\": 0,
        \"TableStatus\": \"ACTIVE\",
        \"DeletionProtectionEnabled\": true
    }
}",
             {ok, #ddb2_table_description
              {attribute_definitions = [{<<"ForumName">>, s},
                                        {<<"LastPostDateTime">>, s},
                                        {<<"Subject">>, s}],
               creation_date_time = 1363729002.358,
               global_table_version = <<"2019.11.21">>,
               item_count = 0,
               key_schema = {<<"ForumName">>, <<"Subject">>},
               local_secondary_indexes =
                   [#ddb2_local_secondary_index_description{
                       index_name = <<"LastPostIndex">>,
                       index_size_bytes = 0,
                       item_count = 0,
                       key_schema = {<<"ForumName">>, <<"LastPostDateTime">>},
                       projection = keys_only}],
               global_secondary_indexes =
                   [#ddb2_global_secondary_index_description{
                       index_name = <<"SubjectIndex">>,
                       index_size_bytes = 2048,
                       index_status = creating,
                       item_count = 47,
                       key_schema = {<<"Subject">>, <<"LastPostDateTime">>},
                       projection = {include, [<<"Author">>]},
                       provisioned_throughput = #ddb2_provisioned_throughput_description{
                          last_decrease_date_time = 0,
                          last_increase_date_time = 1,
                          number_of_decreases_today = 2,
                          read_capacity_units = 3,
                          write_capacity_units = 4}
                    }],
               provisioned_throughput =
                   #ddb2_provisioned_throughput_description{
                      last_decrease_date_time = undefined,
                      last_increase_date_time = undefined,
                      number_of_decreases_today = 0,
                      read_capacity_units = 5,
                      write_capacity_units = 5},
               replicas = [#ddb2_replica_description{region_name = <<"us-west-2">>,
                                                     replica_status = active},
                           #ddb2_replica_description{region_name = <<"eu-west-2">>,
                                                     replica_status = active}],
               table_name = <<"Thread">>,
               table_size_bytes = 0,
               table_status = active,
               deletion_protection_enabled = true}}})
        ],

    output_tests(?_f(erlcloud_ddb2:describe_table(<<"name">>)), Tests).


%% DescribeTableReplicaAutoScaling test based on API request/response syntax
describe_table_replica_auto_scaling_input_tests(_) ->
    Tests =
        [?_ddb_test(
            {"DescribeTableReplicaAutoScaling example request",
             ?_f(erlcloud_ddb2:describe_table_replica_auto_scaling(<<"Thread">>)), "
{
    \"TableName\":\"Thread\"
}"
             })],
    Response = "
{
  \"TableAutoScalingDescription\": {
    \"Replicas\": [
      {
        \"GlobalSecondaryIndexes\": [
          {
            \"IndexName\": \"id-index\",
            \"IndexStatus\": \"ACTIVE\",
            \"ProvisionedReadCapacityAutoScalingSettings\": {
              \"AutoScalingDisabled\": false,
              \"AutoScalingRoleArn\": \"arn:test\",
              \"MaximumUnits\": 20,
              \"MinimumUnits\": 10,
              \"ScalingPolicies\": [
                {
                  \"PolicyName\": \"PolicyName\",
                  \"TargetTrackingScalingPolicyConfiguration\": {
                    \"DisableScaleIn\": false,
                    \"ScaleInCooldown\": 600,
                    \"ScaleOutCooldown\": 600,
                    \"TargetValue\": 70.0
                  }
                }
              ]
            },
            \"ProvisionedWriteCapacityAutoScalingSettings\": {
              \"AutoScalingDisabled\": false,
              \"AutoScalingRoleArn\": \"arn:test\",
              \"MaximumUnits\": 20,
              \"MinimumUnits\": 10,
              \"ScalingPolicies\": [
                {
                  \"PolicyName\": \"PolicyName\",
                  \"TargetTrackingScalingPolicyConfiguration\": {
                    \"DisableScaleIn\": false,
                    \"ScaleInCooldown\": 600,
                    \"ScaleOutCooldown\": 600,
                    \"TargetValue\": 70.0
                  }
                }
              ]
            }
          }
        ],
        \"RegionName\": \"us-west-2\",
        \"ReplicaProvisionedReadCapacityAutoScalingSettings\": {
          \"AutoScalingDisabled\": false,
          \"AutoScalingRoleArn\": \"arn:test\",
          \"MaximumUnits\": 20,
          \"MinimumUnits\": 10,
          \"ScalingPolicies\": [
            {
              \"PolicyName\": \"PolicyName\",
              \"TargetTrackingScalingPolicyConfiguration\": {
                \"DisableScaleIn\": false,
                \"ScaleInCooldown\": 600,
                \"ScaleOutCooldown\": 600,
                \"TargetValue\": 70.0
              }
            }
          ]
        },
        \"ReplicaProvisionedWriteCapacityAutoScalingSettings\": {
          \"AutoScalingDisabled\": false,
          \"AutoScalingRoleArn\": \"arn:test\",
          \"MaximumUnits\": 20,
          \"MinimumUnits\": 10,
          \"ScalingPolicies\": [
            {
              \"PolicyName\": \"PolicyName\",
              \"TargetTrackingScalingPolicyConfiguration\": {
                \"DisableScaleIn\": false,
                \"ScaleInCooldown\": 600,
                \"ScaleOutCooldown\": 600,
                \"TargetValue\": 70.0
              }
            }
          ]
        },
        \"ReplicaStatus\": \"ACTIVE\"
      }
    ],
    \"TableName\": \"Thread\",
    \"TableStatus\": \"ACTIVE\"
  }
}",
        input_tests(Response, Tests).

describe_table_replica_auto_scaling_output_tests(_) ->
    AutoScalingSettings = #ddb2_auto_scaling_settings_description{auto_scaling_disabled = false,
                                                                  auto_scaling_role_arn = <<"arn:test">>,
                                                                  maximum_units = 20,
                                                                  minimum_units = 10,
                                                                  scaling_policies = [#ddb2_auto_scaling_policy_description{policy_name = <<"PolicyName">>,
                                                                                                                            target_tracking_scaling_policy_configuration = #ddb2_auto_scaling_target_tracking_scaling_policy_configuration_description{disable_scale_in = false,
                                                                                                                                                                                                                                                       scale_in_cooldown = 600,
                                                                                                                                                                                                                                                       scale_out_cooldown = 600,
                                                                                                                                                                                                                                                       target_value = 70.0}}]},
    Tests =
    [?_ddb_test(
        {"DescribeGlobalTableSettings example response", "
{
  \"TableAutoScalingDescription\": {
    \"Replicas\": [
      {
        \"GlobalSecondaryIndexes\": [
          {
            \"IndexName\": \"id-index\",
            \"IndexStatus\": \"ACTIVE\",
            \"ProvisionedReadCapacityAutoScalingSettings\": {
              \"AutoScalingDisabled\": false,
              \"AutoScalingRoleArn\": \"arn:test\",
              \"MaximumUnits\": 20,
              \"MinimumUnits\": 10,
              \"ScalingPolicies\": [
                {
                  \"PolicyName\": \"PolicyName\",
                  \"TargetTrackingScalingPolicyConfiguration\": {
                    \"DisableScaleIn\": false,
                    \"ScaleInCooldown\": 600,
                    \"ScaleOutCooldown\": 600,
                    \"TargetValue\": 70.0
                  }
                }
              ]
            },
            \"ProvisionedWriteCapacityAutoScalingSettings\": {
              \"AutoScalingDisabled\": false,
              \"AutoScalingRoleArn\": \"arn:test\",
              \"MaximumUnits\": 20,
              \"MinimumUnits\": 10,
              \"ScalingPolicies\": [
                {
                  \"PolicyName\": \"PolicyName\",
                  \"TargetTrackingScalingPolicyConfiguration\": {
                    \"DisableScaleIn\": false,
                    \"ScaleInCooldown\": 600,
                    \"ScaleOutCooldown\": 600,
                    \"TargetValue\": 70.0
                  }
                }
              ]
            }
          }
        ],
        \"RegionName\": \"us-west-2\",
        \"ReplicaProvisionedReadCapacityAutoScalingSettings\": {
          \"AutoScalingDisabled\": false,
          \"AutoScalingRoleArn\": \"arn:test\",
          \"MaximumUnits\": 20,
          \"MinimumUnits\": 10,
          \"ScalingPolicies\": [
            {
              \"PolicyName\": \"PolicyName\",
              \"TargetTrackingScalingPolicyConfiguration\": {
                \"DisableScaleIn\": false,
                \"ScaleInCooldown\": 600,
                \"ScaleOutCooldown\": 600,
                \"TargetValue\": 70.0
              }
            }
          ]
        },
        \"ReplicaProvisionedWriteCapacityAutoScalingSettings\": {
          \"AutoScalingDisabled\": false,
          \"AutoScalingRoleArn\": \"arn:test\",
          \"MaximumUnits\": 20,
          \"MinimumUnits\": 10,
          \"ScalingPolicies\": [
            {
              \"PolicyName\": \"PolicyName\",
              \"TargetTrackingScalingPolicyConfiguration\": {
                \"DisableScaleIn\": false,
                \"ScaleInCooldown\": 600,
                \"ScaleOutCooldown\": 600,
                \"TargetValue\": 70.0
              }
            }
          ]
        },
        \"ReplicaStatus\": \"ACTIVE\"
      }
    ],
    \"TableName\": \"Thread\",
    \"TableStatus\": \"ACTIVE\"
  }
}",
         {ok, #ddb2_table_auto_scaling_description{replicas = [#ddb2_replica_auto_scaling_description{global_secondary_indexes = [#ddb2_replica_global_secondary_index_auto_scaling_description{index_name = <<"id-index">>,
                                                                                                                                                                                                index_status = active,
                                                                                                                                                                                                provisioned_read_capacity_auto_scaling_settings = AutoScalingSettings,
                                                                                                                                                                                                provisioned_write_capacity_auto_scaling_settings = AutoScalingSettings}],
                                                                                                      region_name = <<"us-west-2">>,
                                                                                                      replica_provisioned_read_capacity_auto_scaling_settings = AutoScalingSettings,
                                                                                                      replica_provisioned_write_capacity_auto_scaling_settings = AutoScalingSettings,
                                                                                                      replica_status = active}],
                                                    table_name = <<"Thread">>,
                                                    table_status = active}}})],
    output_tests(?_f(erlcloud_ddb2:describe_table_replica_auto_scaling(<<"Thread">>)), Tests).

%% DescribeTimeToLive test
describe_time_to_live_input_tests(_) ->
    Tests =
          [?_ddb_test(
              {"DescribeTimeToLive example request",
               ?_f(erlcloud_ddb2:describe_time_to_live(<<"SessionData">>)), "
{
    \"TableName\": \"SessionData\"
}"
              })],
      Response = "
{
    \"TimeToLiveDescription\": {
        \"AttributeName\": \"ExpirationTime\",
        \"TimeToLiveStatus\": \"ENABLED\"
    }
}",
      input_tests(Response, Tests).

%% DescribeTimeToLive test:
describe_time_to_live_output_tests(_) ->
    Tests =
        [?_ddb_test(
            {"DescribeTimeToLive example response with enabled TTL", "
{
    \"TimeToLiveDescription\": {
        \"AttributeName\": \"ExpirationTime\",
        \"TimeToLiveStatus\": \"ENABLED\"
    }
}",
              {ok, #ddb2_time_to_live_description{
                attribute_name = <<"ExpirationTime">>,
                time_to_live_status = enabled}}}),

?_ddb_test(
            {"DescribeTimeToLive example response with disabled TTL", "
{
    \"TimeToLiveDescription\": {
        \"AttributeName\": \"ExpirationTime\",
        \"TimeToLiveStatus\": \"DISABLED\"
    }
}",
              {ok, #ddb2_time_to_live_description{
                attribute_name = <<"ExpirationTime">>,
                time_to_live_status = disabled}}}),


?_ddb_test(
            {"DescribeTimeToLive example response while TTL is enabling", "
{
    \"TimeToLiveDescription\": {
        \"AttributeName\": \"ExpirationTime\",
        \"TimeToLiveStatus\": \"ENABLING\"
    }
}",
              {ok, #ddb2_time_to_live_description{
                attribute_name = <<"ExpirationTime">>,
                time_to_live_status = enabling}}}),

?_ddb_test(
            {"DescribeTimeToLive example response while TTL is disabling", "
{
    \"TimeToLiveDescription\": {
        \"AttributeName\": \"ExpirationTime\",
        \"TimeToLiveStatus\": \"DISABLING\"
    }
}",
              {ok, #ddb2_time_to_live_description{
                attribute_name = <<"ExpirationTime">>,
                time_to_live_status = disabling}}})],
    output_tests(?_f(erlcloud_ddb2:describe_time_to_live(<<"SessionData">>)), Tests).


%% GetItem test based on the API examples:
%% http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_GetItem.html
get_item_input_tests(_) ->
    Example1Response = "
{
    \"TableName\": \"Thread\",
    \"Key\": {
        \"ForumName\": {
            \"S\": \"Amazon DynamoDB\"
        },
        \"Subject\": {
            \"S\": \"How do I update multiple items?\"
        }
    },
    \"AttributesToGet\": [\"LastPostDateTime\",\"Message\",\"Tags\"],
    \"ConsistentRead\": true,
    \"ReturnConsumedCapacity\": \"TOTAL\"
}",

    Tests =
        [?_ddb_test(
            {"GetItem example request, with fully specified keys",
             ?_f(erlcloud_ddb2:get_item(<<"Thread">>,
                                       [{<<"ForumName">>, {s, <<"Amazon DynamoDB">>}},
                                        {<<"Subject">>, {s, <<"How do I update multiple items?">>}}],
                                       [{attributes_to_get, [<<"LastPostDateTime">>, <<"Message">>, <<"Tags">>]},
                                        consistent_read,
                                        {return_consumed_capacity, total},
                                        %% Make sure options at beginning of list override later options
                                        {consistent_read, false}]
                                      )),
             Example1Response}),
         ?_ddb_test(
            {"GetItem example request, with inferred key types",
             ?_f(erlcloud_ddb2:get_item(<<"Thread">>,
                                       [{<<"ForumName">>, "Amazon DynamoDB"},
                                        {<<"Subject">>, <<"How do I update multiple items?">>}],
                                       [{attributes_to_get, [<<"LastPostDateTime">>, <<"Message">>, <<"Tags">>]},
                                        {consistent_read, true},
                                        {return_consumed_capacity, total}]
                                      )),
             Example1Response}),
         ?_ddb_test(
            {"GetItem example request, with ProjectionExpression",
             ?_f(erlcloud_ddb2:get_item(<<"Thread">>,
                                       [{<<"ForumName">>, {s, <<"Amazon DynamoDB">>}},
                                        {<<"Subject">>, {s, <<"How do I update multiple items?">>}}],
                                       [{projection_expression, <<"LastPostDateTime, Message, Tags">>},
                                        consistent_read,
                                        {return_consumed_capacity, total}]
                                      )), "
{
    \"TableName\": \"Thread\",
    \"Key\": {
        \"ForumName\": {
            \"S\": \"Amazon DynamoDB\"
        },
        \"Subject\": {
            \"S\": \"How do I update multiple items?\"
        }
    },
    \"ProjectionExpression\": \"LastPostDateTime, Message, Tags\",
    \"ConsistentRead\": true,
    \"ReturnConsumedCapacity\": \"TOTAL\"
}"
            }),
         ?_ddb_test(
            {"GetItem Simple call with only hash key and no options",
             ?_f(erlcloud_ddb2:get_item(<<"TableName">>, {<<"HashKey">>, 1})), "
{\"TableName\":\"TableName\",
 \"Key\":{\"HashKey\":{\"N\":\"1\"}}
}"
             })
        ],

    Response = "
{
    \"ConsumedCapacity\": {
        \"CapacityUnits\": 1,
        \"TableName\": \"Thread\"
    },
    \"Item\": {
        \"Tags\": {
            \"SS\": [\"Update\",\"Multiple Items\",\"HelpMe\"]
        },
        \"LastPostDateTime\": {
            \"S\": \"201303190436\"
        },
        \"Message\": {
            \"S\": \"I want to update multiple items in a single API call. What's the best way to do that?\"
        }
    }
}",
    input_tests(Response, Tests).

get_item_output_tests(_) ->
    Tests =
        [?_ddb_test(
            {"GetItem example response", "
{
    \"ConsumedCapacity\": {
        \"CapacityUnits\": 1,
        \"TableName\": \"Thread\"
    },
    \"Item\": {
        \"Tags\": {
            \"SS\": [\"Update\",\"Multiple Items\",\"HelpMe\"]
        },
        \"LastPostDateTime\": {
            \"S\": \"201303190436\"
        },
        \"Message\": {
            \"S\": \"I want to update multiple items in a single API call. What's the best way to do that?\"
        }
    }
}",
             {ok, #ddb2_get_item{
                     item = [{<<"Tags">>, [<<"Update">>, <<"Multiple Items">>, <<"HelpMe">>]},
                             {<<"LastPostDateTime">>, <<"201303190436">>},
                             {<<"Message">>, <<"I want to update multiple items in a single API call. What's the best way to do that?">>}],
                    consumed_capacity = #ddb2_consumed_capacity{
                                          capacity_units = 1,
                                          table_name = <<"Thread">>}}}}),
         ?_ddb_test(
            {"GetItem test all attribute types", "
{\"Item\":
    {\"ss\":{\"SS\":[\"Lynda\", \"Aaron\"]},
     \"ns\":{\"NS\":[\"12\",\"13.0\",\"14.1\"]},
     \"bs\":{\"BS\":[\"BbY=\"]},
     \"es\":{\"SS\":[]},
     \"s\":{\"S\":\"Lynda\"},
     \"n\":{\"N\":\"12\"},
     \"f\":{\"N\":\"12.34\"},
     \"b\":{\"B\":\"BbY=\"},
     \"l\":{\"L\":[{\"S\":\"Listen\"},{\"S\":\"Linda\"}]},
     \"m\":{\"M\":{\"k\": {\"S\": \"v\"}}},
     \"empty_string\":{\"S\":\"\"},
     \"empty_map\":{\"M\":{}}
    }
}",
             {ok, #ddb2_get_item{
                     item = [{<<"ss">>, [<<"Lynda">>, <<"Aaron">>]},
                             {<<"ns">>, [12,13.0,14.1]},
                             {<<"bs">>, [<<5,182>>]},
                             {<<"es">>, []},
                             {<<"s">>, <<"Lynda">>},
                             {<<"n">>, 12},
                             {<<"f">>, 12.34},
                             {<<"b">>, <<5,182>>},
                             {<<"l">>, [<<"Listen">>, <<"Linda">>]},
                             {<<"m">>, [{<<"k">>, <<"v">>}]},
                             {<<"empty_string">>, <<>>},
                             {<<"empty_map">>, []}],
                    consumed_capacity = undefined}}}),
         ?_ddb_test(
            {"GetItem item not found",
             "{}",
             {ok, #ddb2_get_item{item = undefined}}}),
         ?_ddb_test(
            {"GetItem no attributes returned",
             "{\"Item\":{}}",
             {ok, #ddb2_get_item{item = []}}})
        ],

    output_tests(?_f(erlcloud_ddb2:get_item(<<"table">>, {<<"k">>, <<"v">>}, [{out, record}])), Tests).

get_item_output_map_tests(_) ->
    Tests =
        [?_ddb_test(
            {"GetItem example response", "
{
    \"ConsumedCapacity\": {
        \"CapacityUnits\": 1,
        \"TableName\": \"Thread\"
    },
    \"Item\": {
        \"Tags\": {
            \"SS\": [\"Update\",\"Multiple Items\",\"HelpMe\"]
        },
        \"LastPostDateTime\": {
            \"S\": \"201303190436\"
        },
        \"Message\": {
            \"S\": \"I want to update multiple items in a single API call. What's the best way to do that?\"
        }
    }
}",
             {ok, #ddb2_get_item{
                     item = [{<<"Tags">>, [<<"Update">>, <<"Multiple Items">>, <<"HelpMe">>]},
                             {<<"LastPostDateTime">>, <<"201303190436">>},
                             {<<"Message">>, <<"I want to update multiple items in a single API call. What's the best way to do that?">>}],
                    consumed_capacity = #ddb2_consumed_capacity{
                                          capacity_units = 1,
                                          table_name = <<"Thread">>}}}}),
         ?_ddb_test(
            {"GetItem test all attribute types", "
{\"Item\":
    {\"ss\":{\"SS\":[\"Lynda\", \"Aaron\"]},
     \"ns\":{\"NS\":[\"12\",\"13.0\",\"14.1\"]},
     \"bs\":{\"BS\":[\"BbY=\"]},
     \"es\":{\"SS\":[]},
     \"s\":{\"S\":\"Lynda\"},
     \"n\":{\"N\":\"12\"},
     \"f\":{\"N\":\"12.34\"},
     \"b\":{\"B\":\"BbY=\"},
     \"l\":{\"L\":[{\"S\":\"Listen\"},{\"S\":\"Linda\"}]},
     \"m\":{\"M\":{\"k\": {\"S\": \"v\"}}},
     \"empty_string\":{\"S\":\"\"},
     \"empty_map\":{\"M\":{}}
    }
}",
             {ok, #ddb2_get_item{
                     item = [{<<"ss">>, [<<"Lynda">>, <<"Aaron">>]},
                             {<<"ns">>, [12,13.0,14.1]},
                             {<<"bs">>, [<<5,182>>]},
                             {<<"es">>, []},
                             {<<"s">>, <<"Lynda">>},
                             {<<"n">>, 12},
                             {<<"f">>, 12.34},
                             {<<"b">>, <<5,182>>},
                             {<<"l">>, [<<"Listen">>, <<"Linda">>]},
                             {<<"m">>, #{<<"k">> => <<"v">>}},
                             {<<"empty_string">>, <<>>},
                             {<<"empty_map">>, #{}}],
                    consumed_capacity = undefined}}}),
         ?_ddb_test(
            {"GetItem item not found",
             "{}",
             {ok, #ddb2_get_item{item = undefined}}}),
         ?_ddb_test(
            {"GetItem no attributes returned",
             "{\"Item\":{}}",
             {ok, #ddb2_get_item{item = []}}})
        ],

    output_tests(?_f(erlcloud_ddb2:get_item(<<"table">>, {<<"k">>, <<"v">>}, [{out, record}, return_maps])), Tests).

get_item_output_typed_tests(_) ->
    Tests =
        [?_ddb_test(
            {"GetItem typed test all attribute types", "
{\"Item\":
    {\"ss\":{\"SS\":[\"Lynda\", \"Aaron\"]},
     \"ns\":{\"NS\":[\"12\",\"13.0\",\"14.1\"]},
     \"bs\":{\"BS\":[\"BbY=\"]},
     \"es\":{\"SS\":[]},
     \"s\":{\"S\":\"Lynda\"},
     \"n\":{\"N\":\"12\"},
     \"f\":{\"N\":\"12.34\"},
     \"b\":{\"B\":\"BbY=\"},
     \"l\":{\"L\":[{\"S\":\"Listen\"},{\"S\":\"Linda\"}]},
     \"m\":{\"M\":{\"k\": {\"S\": \"v\"}}},
     \"empty_string\":{\"S\":\"\"},
     \"empty_map\":{\"M\":{}}
    }
}",
             {ok, #ddb2_get_item{
                     item = [{<<"ss">>, {ss, [<<"Lynda">>, <<"Aaron">>]}},
                             {<<"ns">>, {ns, [12,13.0,14.1]}},
                             {<<"bs">>, {bs, [<<5,182>>]}},
                             {<<"es">>, {ss,  []}},
                             {<<"s">>, {s, <<"Lynda">>}},
                             {<<"n">>, {n, 12}},
                             {<<"f">>, {n, 12.34}},
                             {<<"b">>, {b, <<5,182>>}},
                             {<<"l">>, {l, [{s, <<"Listen">>}, {s, <<"Linda">>}]}},
                             {<<"m">>, {m, [{<<"k">>, {s, <<"v">>}}]}},
                             {<<"empty_string">>, {s, <<>>}},
                             {<<"empty_map">>, {m, []}}],
                    consumed_capacity = undefined}}})
        ],

    output_tests(?_f(erlcloud_ddb2:get_item(
                       <<"table">>, {<<"k">>, <<"v">>}, [{out, typed_record}])), Tests).

get_item_output_typed_map_tests(_) ->
    Tests =
        [?_ddb_test(
            {"GetItem typed test all attribute types", "
{\"Item\":
    {\"ss\":{\"SS\":[\"Lynda\", \"Aaron\"]},
     \"ns\":{\"NS\":[\"12\",\"13.0\",\"14.1\"]},
     \"bs\":{\"BS\":[\"BbY=\"]},
     \"es\":{\"SS\":[]},
     \"s\":{\"S\":\"Lynda\"},
     \"n\":{\"N\":\"12\"},
     \"f\":{\"N\":\"12.34\"},
     \"b\":{\"B\":\"BbY=\"},
     \"l\":{\"L\":[{\"S\":\"Listen\"},{\"S\":\"Linda\"}]},
     \"m\":{\"M\":{\"k\": {\"S\": \"v\"}}},
     \"empty_string\":{\"S\":\"\"},
     \"empty_map\":{\"M\":{}}
    }
}",
             {ok, #ddb2_get_item{
                     item = [{<<"ss">>, {ss, [<<"Lynda">>, <<"Aaron">>]}},
                             {<<"ns">>, {ns, [12,13.0,14.1]}},
                             {<<"bs">>, {bs, [<<5,182>>]}},
                             {<<"es">>, {ss,  []}},
                             {<<"s">>, {s, <<"Lynda">>}},
                             {<<"n">>, {n, 12}},
                             {<<"f">>, {n, 12.34}},
                             {<<"b">>, {b, <<5,182>>}},
                             {<<"l">>, {l, [{s, <<"Listen">>}, {s, <<"Linda">>}]}},
                             {<<"m">>, {m, #{<<"k">> => {s, <<"v">>}}}},
                             {<<"empty_string">>, {s, <<>>}},
                             {<<"empty_map">>, {m, #{}}}],
                    consumed_capacity = undefined}}})
        ],

    output_tests(?_f(erlcloud_ddb2:get_item(
                       <<"table">>, {<<"k">>, <<"v">>}, [{out, typed_record}, return_maps])), Tests).

%% ListBackups test based on the API examples:
%% https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_ListBackups.html
list_backups_input_tests(_) ->
 Tests =
  [?_ddb_test(
   {"ListBackups example request",
    ?_f(erlcloud_ddb2:list_backups([{limit, 4},{exclusive_start_backup_arn, <<"arn:aws:dynamodb:us-east-1:387047610112:table/Forum/backup/01523516528459-dfd5667f">>},{table_name, <<"Forum">>},{time_range_lower_bound,1522926603.688},{time_range_upper_bound, 1523022454.098}])), "
    {
        \"Limit\": 4,
        \"TableName\": \"Forum\",
        \"ExclusiveStartBackupArn\": \"arn:aws:dynamodb:us-east-1:387047610112:table/Forum/backup/01523516528459-dfd5667f\",
        \"TimeRangeLowerBound\": 1522926603.688,
        \"TimeRangeUpperBound\": 1523022454.098
    }"
   })
  ],
 Response = "
{
    \"BackupSummaries\": [
        {
            \"BackupArn\": \"arn:aws:dynamodb:us-east-1:387047610112:table/Forum/backup/01523517555423-69b67bcb\",
            \"BackupCreationDateTime\": 1522926603.688,
            \"BackupName\": \"Forum_backup\",
            \"BackupSizeBytes\": 1,
            \"BackupStatus\": \"AVAILABLE\",
            \"TableArn\": \"arn:aws:dynamodb:us-east-1:387047610112:table/Forum\",
            \"TableId\": \"64d52641-ca33-4d44-8620-c8eccf22ef3d\",
            \"TableName\": \"Forum\"
        }
    ],
    \"LastEvaluatedBackupArn\": \"arn:aws:dynamodb:us-east-1:387047610112:table/Forum/backup/01523517555423-69b66bcb\"
}",
 input_tests(Response, Tests).

list_backups_output_tests(_) ->
 Tests =
  [?_ddb_test(
   {"ListBackups example response", "
{
    \"BackupSummaries\": [
        {
            \"BackupArn\": \"arn:aws:dynamodb:us-east-1:387047610112:table/Forum/backup/01523517555423-69b67bcb\",
            \"BackupCreationDateTime\": 1522926603.688,
            \"BackupName\": \"Forum_backup\",
            \"BackupSizeBytes\": 1,
            \"BackupStatus\": \"AVAILABLE\",
            \"TableArn\": \"arn:aws:dynamodb:us-east-1:387047610112:table/Forum\",
            \"TableId\": \"64d52641-ca33-4d44-8620-c8eccf22ef3d\",
            \"TableName\": \"Forum\"
        }
    ],
    \"LastEvaluatedBackupArn\": \"arn:aws:dynamodb:us-east-1:387047610112:table/Forum/backup/01523517555423-69b66bcb\"
}",
    {ok,
         [#ddb2_backup_summary{
             backup_arn = <<"arn:aws:dynamodb:us-east-1:387047610112:table/Forum/backup/01523517555423-69b67bcb">>,
             backup_creation_date_time = 1522926603.688,
             backup_name = <<"Forum_backup">>,
             backup_size_bytes = 1,
             backup_status = available,
             table_arn = <<"arn:aws:dynamodb:us-east-1:387047610112:table/Forum">>,
             table_id = <<"64d52641-ca33-4d44-8620-c8eccf22ef3d">>,
             table_name = <<"Forum">>
         }]}
   })
  ],

 output_tests(?_f(erlcloud_ddb2:list_backups()), Tests).

%% ListGlobalTables input test:
list_global_tables_input_tests(_) ->
    Tests =
        [?_ddb_test(
            {"ListGlobalTables example request",
             ?_f(erlcloud_ddb2:list_global_tables([{exclusive_start_global_table_name, <<"Forum">>},
                                                   {limit, 3}])), "
{
    \"ExclusiveStartGlobalTableName\": \"Forum\",
    \"Limit\": 3
}"
            }),
         ?_ddb_test(
            {"ListGlobalTables empty request",
             ?_f(erlcloud_ddb2:list_global_tables()),
             "{}"
            })

        ],

    Response = "
{
   \"GlobalTables\": [
      {
         \"GlobalTableName\": \"Forum\",
         \"ReplicationGroup\": [
            {
               \"RegionName\": \"us-west-2\"
            },{
               \"RegionName\": \"us-east-1\"
            }
         ]
      },{
         \"GlobalTableName\": \"Thread\",
         \"ReplicationGroup\": [
            {
               \"RegionName\": \"us-east-1\"
            },{
               \"RegionName\": \"eu-west-1\"
            }
         ]
      }
   ],
    \"LastEvaluatedGlobalTableName\": \"Thread\"
}",
    input_tests(Response, Tests).

%% ListGlobalTables output test:
list_global_tables_output_tests(_) ->
    Tests =
        [?_ddb_test(
            {"ListGlobalTables example response", "
{
   \"GlobalTables\": [
      {
         \"GlobalTableName\": \"Forum\",
         \"ReplicationGroup\": [
            {
               \"RegionName\": \"us-west-2\"
            },{
               \"RegionName\": \"us-east-1\"
            }
         ]
      },{
         \"GlobalTableName\": \"Thread\",
         \"ReplicationGroup\": [
            {
               \"RegionName\": \"us-east-1\"
            },{
               \"RegionName\": \"eu-west-1\"
            }
         ]
      }
   ],
    \"LastEvaluatedGlobalTableName\": \"Thread\"
}",
             {ok, #ddb2_list_global_tables
              {last_evaluated_global_table_name = <<"Thread">>,
               global_tables = [#ddb2_global_table
                                 {global_table_name = <<"Forum">>,
                                  replication_group = [#ddb2_replica{region_name = <<"us-west-2">>},
                                                       #ddb2_replica{region_name = <<"us-east-1">>}]},
                                #ddb2_global_table
                                 {global_table_name = <<"Thread">>,
                                  replication_group = [#ddb2_replica{region_name = <<"us-east-1">>},
                                                       #ddb2_replica{region_name = <<"eu-west-1">>}]}]}}})
        ],

    output_tests(?_f(erlcloud_ddb2:list_global_tables([{out, record}])), Tests).

%% ListTables test based on the API examples:
%% http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_ListTables.html
list_tables_input_tests(_) ->
    Tests =
        [?_ddb_test(
            {"ListTables example request",
             ?_f(erlcloud_ddb2:list_tables([{limit, 3}, {exclusive_start_table_name, <<"Forum">>}])), "
{
    \"ExclusiveStartTableName\": \"Forum\",
    \"Limit\": 3
}"
            }),
         ?_ddb_test(
            {"ListTables empty request",
             ?_f(erlcloud_ddb2:list_tables()),
             "{}"
            })

        ],

    Response = "
{
    \"LastEvaluatedTableName\": \"Thread\",
    \"TableNames\": [\"Forum\",\"Reply\",\"Thread\"]
}",
    input_tests(Response, Tests).

list_tables_output_tests(_) ->
    Tests =
        [?_ddb_test(
            {"ListTables example response", "
{
    \"LastEvaluatedTableName\": \"Thread\",
    \"TableNames\": [\"Forum\",\"Reply\",\"Thread\"]
}",
             {ok, #ddb2_list_tables
              {last_evaluated_table_name = <<"Thread">>,
               table_names = [<<"Forum">>, <<"Reply">>, <<"Thread">>]}}})
        ],

    output_tests(?_f(erlcloud_ddb2:list_tables([{out, record}])), Tests).

%% ListTagsOfResource test based on the API:
%% https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_ListTagsOfResource.html
list_tags_of_resource_input_tests(_) ->
    Tests =
        [?_ddb_test(
            {"ListTagsOfResource example request",
             ?_f(erlcloud_ddb2:list_tags_of_resource(<<"arn:aws:dynamodb:us-east-1:111122223333:table/Forum">>,
                                                     [{next_token, <<"TestToken">>}])), "
{
    \"ResourceArn\": \"arn:aws:dynamodb:us-east-1:111122223333:table/Forum\",
    \"NextToken\": \"TestToken\"
}"
            }),
         ?_ddb_test(
            {"ListTagsOfResource example request (no NextToken)",
             ?_f(erlcloud_ddb2:list_tags_of_resource(<<"arn:aws:dynamodb:us-east-1:111122223333:table/Forum">>)), "
{
    \"ResourceArn\": \"arn:aws:dynamodb:us-east-1:111122223333:table/Forum\"
}"
            })

        ],

    Response = "
{
    \"Tags\": []
}",
    input_tests(Response, Tests).

list_tags_of_resource_output_tests(_) ->
    Tests =
        [?_ddb_test(
            {"ListTagsOfResource example response", "
{
    \"NextToken\": \"TestToken\",
    \"Tags\": [
      {
          \"Key\": \"example_key1\",
          \"Value\": \"example_value1\"
      },
      {
          \"Key\": \"example_key2\",
          \"Value\": \"example_value2\"
      }
    ]
}",
             {ok, #ddb2_list_tags_of_resource
              {next_token = <<"TestToken">>,
               tags = [{<<"example_key1">>, <<"example_value1">>},
                       {<<"example_key2">>, <<"example_value2">>}]}}})
        ],

    output_tests(?_f(erlcloud_ddb2:list_tags_of_resource(<<"arn:aws:dynamodb:us-east-1:111122223333:table/Forum">>,
                                                         [{out, record}])),
                     Tests).

%% PutItem test based on the API examples:
%% http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_PutItem.html
put_item_input_tests(_) ->
    Tests =
        [?_ddb_test(
            {"PutItem example request",
             ?_f(erlcloud_ddb2:put_item(<<"Thread">>,
                                       [{<<"LastPostedBy">>, <<"fred@example.com">>},
                                        {<<"ForumName">>, <<"Amazon DynamoDB">>},
                                        {<<"LastPostDateTime">>, <<"201303190422">>},
                                        {<<"Tags">>, {ss, [<<"Update">>, <<"Multiple Items">>, <<"HelpMe">>]}},
                                        {<<"Subject">>, <<"How do I update multiple items?">>},
                                        {<<"Message">>, <<"I want to update multiple items in a single API call. What's the best way to do that?">>}],
                                       [{expected, [{<<"ForumName">>, null}, {<<"Subject">>, null}]}])), "
{
    \"TableName\": \"Thread\",
    \"Item\": {
        \"LastPostDateTime\": {
            \"S\": \"201303190422\"
        },
        \"Tags\": {
            \"SS\": [\"Update\",\"Multiple Items\",\"HelpMe\"]
        },
        \"ForumName\": {
            \"S\": \"Amazon DynamoDB\"
        },
        \"Message\": {
            \"S\": \"I want to update multiple items in a single API call. What's the best way to do that?\"
        },
        \"Subject\": {
            \"S\": \"How do I update multiple items?\"
        },
        \"LastPostedBy\": {
            \"S\": \"fred@example.com\"
        }
    },
    \"Expected\": {
        \"ForumName\": {
            \"ComparisonOperator\": \"NULL\"
        },
        \"Subject\": {
            \"ComparisonOperator\": \"NULL\"
        }
    }
}"
            }),
         ?_ddb_test(
            {"PutItem float inputs",
             ?_f(erlcloud_ddb2:put_item(<<"Thread">>,
                                       [{<<"typed float">>, {n, 1.2}},
                                        {<<"untyped float">>, 3.456},
                                        {<<"mixed set">>, {ns, [7.8, 9.0, 10]}}],
                                       [])), "
{
    \"TableName\": \"Thread\",
    \"Item\": {
        \"typed float\": {
            \"N\": \"1.2\"
        },
        \"untyped float\": {
            \"N\": \"3.456\"
        },
        \"mixed set\": {
            \"NS\": [\"7.8\", \"9.0\", \"10\"]
        }
    }
}"
            }),
         ?_ddb_test(
            {"PutItem example request with ConditionExpression and ExpressionAttributeValues",
             ?_f(erlcloud_ddb2:put_item(<<"Thread">>,
                                       [{<<"LastPostedBy">>, <<"fred@example.com">>},
                                        {<<"ForumName">>, <<"Amazon DynamoDB">>},
                                        {<<"LastPostDateTime">>, <<"201303190422">>},
                                        {<<"Tags">>, {ss, [<<"Update">>, <<"Multiple Items">>, <<"HelpMe">>]}},
                                        {<<"Subject">>, <<"How do I update multiple items?">>},
                                        {<<"Message">>, <<"I want to update multiple items in a single API call. What's the best way to do that?">>}],
                                       [{condition_expression, <<"ForumName <> :f and Subject <> :s">>},
                                        {expression_attribute_values, [
                                            {<<":f">>, <<"Amazon DynamoDB">>},
                                            {<<":s">>, <<"How do I update multiple items?">>}]}])), "
{
    \"TableName\": \"Thread\",
    \"Item\": {
        \"LastPostDateTime\": {
            \"S\": \"201303190422\"
        },
        \"Tags\": {
            \"SS\": [\"Update\",\"Multiple Items\",\"HelpMe\"]
        },
        \"ForumName\": {
            \"S\": \"Amazon DynamoDB\"
        },
        \"Message\": {
            \"S\": \"I want to update multiple items in a single API call. What's the best way to do that?\"
        },
        \"Subject\": {
            \"S\": \"How do I update multiple items?\"
        },
        \"LastPostedBy\": {
            \"S\": \"fred@example.com\"
        }
    },
    \"ConditionExpression\": \"ForumName <> :f and Subject <> :s\",
    \"ExpressionAttributeValues\": {
        \":f\": {
            \"S\": \"Amazon DynamoDB\"
        },
        \":s\": {
            \"S\": \"How do I update multiple items?\"
        }
    }
}"
            }),
        ?_ddb_test(
            {"PutItem request with complex item",
             ?_f(erlcloud_ddb2:put_item(<<"Table">>,
                                       [{<<"bool_true">>, {bool, true}},
                                        {<<"bool_false">>, {bool, false}},
                                        {<<"null_value">>, {null, true}},
                                        {<<"list_value">>, {l, ["string", {ss, ["string1", "string2"]}]}},
                                        {<<"map_value">>, {m, [
                                            {<<"key1">>, "value1"},
                                            {<<"key2">>, {l, ["list_string1", "list_string2"]}}
                                        ]}},
                                        {<<"empty_map_value">>, {m, []}}
                                       ])), "
{
    \"TableName\": \"Table\",
    \"Item\": {
        \"bool_true\": {\"BOOL\": true},
        \"bool_false\": {\"BOOL\": false},
        \"null_value\": {\"NULL\": true},
        \"list_value\": {\"L\": [
            {\"S\": \"string\"},
            {\"SS\": [
                \"string1\",
                \"string2\"
            ]}
        ]},
        \"map_value\": {\"M\": {
            \"key1\": {\"S\": \"value1\"},
            \"key2\": {\"L\": [
                {\"S\": \"list_string1\"},
                {\"S\": \"list_string2\"}
            ]}
        }},
        \"empty_map_value\": {\"M\": {}}
    }
}"
            }),
        ?_ddb_test(
            {"PutItem request with map",
             ?_f(erlcloud_ddb2:put_item(<<"Table">>,
                                       [{<<"map_value">>, {m, #{ 
                                            <<"key1">> => "value1",
                                            <<"key2">> => {l, ["list_string1", "list_string2"]}
                                        }}},
                                        {<<"empty_map_value">>, {m, #{}}}
                                       ])), "
{
    \"TableName\": \"Table\",
    \"Item\": {
        \"map_value\": {\"M\": {
            \"key1\": {\"S\": \"value1\"},
            \"key2\": {\"L\": [
                {\"S\": \"list_string1\"},
                {\"S\": \"list_string2\"}
            ]}
        }},
        \"empty_map_value\": {\"M\": {}}
    }
}"
            })
        ],

    Response = "
{
}",
    input_tests(Response, Tests).

put_item_output_tests(_) ->
    Tests =
        [?_ddb_test(
            {"PutItem example response", "
{
}",
             {ok, #ddb2_put_item{}}}),
         ?_ddb_test(
            {"PutItem complete response", "
{
    \"Attributes\": {
        \"LastPostedBy\": {
            \"S\": \"fred@example.com\"
        },
        \"ForumName\": {
            \"S\": \"Amazon DynamoDB\"
        },
        \"LastPostDateTime\": {
            \"S\": \"201303201023\"
        },
        \"Tags\": {
            \"SS\": [\"Update\",\"Multiple Items\",\"HelpMe\"]
        },
        \"Subject\": {
            \"S\": \"How do I update multiple items?\"
        },
        \"Message\": {
            \"S\": \"I want to update multiple items in a single API call. What's the best way to do that?\"
        }
    },
    \"ConsumedCapacity\": {
        \"CapacityUnits\": 1,
        \"TableName\": \"Thread\"
    },
    \"ItemCollectionMetrics\": {
        \"ItemCollectionKey\": {
            \"ForumName\": {
                \"S\": \"Amazon DynamoDB\"
            }
        },
        \"SizeEstimateRangeGB\": [1, 2]
    }
}",

             {ok, #ddb2_put_item{
                     attributes = [{<<"LastPostedBy">>, <<"fred@example.com">>},
                                   {<<"ForumName">>, <<"Amazon DynamoDB">>},
                                   {<<"LastPostDateTime">>, <<"201303201023">>},
                                   {<<"Tags">>, [<<"Update">>, <<"Multiple Items">>, <<"HelpMe">>]},
                                   {<<"Subject">>, <<"How do I update multiple items?">>},
                                   {<<"Message">>, <<"I want to update multiple items in a single API call. What's the best way to do that?">>}],
                     consumed_capacity =
                         #ddb2_consumed_capacity{
                            table_name = <<"Thread">>,
                            capacity_units = 1},
                     item_collection_metrics =
                         #ddb2_item_collection_metrics{
                            item_collection_key = <<"Amazon DynamoDB">>,
                            size_estimate_range_gb = {1,2}}
                     }}}),
         ?_ddb_test(
            {"PutItem response with complex item", "
{
    \"Attributes\": {
        \"bool_true\": {\"BOOL\": true},
        \"bool_false\": {\"BOOL\": false},
        \"null_value\": {\"NULL\": true},
        \"list_value\": {\"L\": [
            {\"S\": \"string\"},
            {\"SS\": [
                \"string1\",
                \"string2\"
            ]}
        ]},
        \"map_value\": {\"M\": {
            \"key1\": {\"S\": \"value1\"},
            \"key2\": {\"L\": [
                {\"S\": \"list_string1\"},
                {\"S\": \"list_string2\"}
            ]}
        }},
        \"empty_map_value\": {\"M\": {}}
    }
}",

             {ok, #ddb2_put_item{
                     attributes = [{<<"bool_true">>, true},
                                   {<<"bool_false">>, false},
                                   {<<"null_value">>, undefined},
                                   {<<"list_value">>, [<<"string">>, [<<"string1">>, <<"string2">>]]},
                                   {<<"map_value">>, [
                                       {<<"key1">>, <<"value1">>},
                                       {<<"key2">>, [<<"list_string1">>, <<"list_string2">>]}
                                   ]},
                                   {<<"empty_map_value">>, []}
                                  ]
                     }}})
        ],

    output_tests(?_f(erlcloud_ddb2:put_item(<<"table">>, [], [{out, record}])), Tests).

put_item_output_map_tests(_) ->
    Tests =
        [?_ddb_test(
            {"PutItem example response", "
{
}",
             {ok, #ddb2_put_item{}}}),
         ?_ddb_test(
            {"PutItem complete response", "
{
    \"Attributes\": {
        \"LastPostedBy\": {
            \"S\": \"fred@example.com\"
        },
        \"ForumName\": {
            \"S\": \"Amazon DynamoDB\"
        },
        \"LastPostDateTime\": {
            \"S\": \"201303201023\"
        },
        \"Tags\": {
            \"SS\": [\"Update\",\"Multiple Items\",\"HelpMe\"]
        },
        \"Subject\": {
            \"S\": \"How do I update multiple items?\"
        },
        \"Message\": {
            \"S\": \"I want to update multiple items in a single API call. What's the best way to do that?\"
        }
    },
    \"ConsumedCapacity\": {
        \"CapacityUnits\": 1,
        \"TableName\": \"Thread\"
    },
    \"ItemCollectionMetrics\": {
        \"ItemCollectionKey\": {
            \"ForumName\": {
                \"S\": \"Amazon DynamoDB\"
            }
        },
        \"SizeEstimateRangeGB\": [1, 2]
    }
}",

             {ok, #ddb2_put_item{
                     attributes = [{<<"LastPostedBy">>, <<"fred@example.com">>},
                                   {<<"ForumName">>, <<"Amazon DynamoDB">>},
                                   {<<"LastPostDateTime">>, <<"201303201023">>},
                                   {<<"Tags">>, [<<"Update">>, <<"Multiple Items">>, <<"HelpMe">>]},
                                   {<<"Subject">>, <<"How do I update multiple items?">>},
                                   {<<"Message">>, <<"I want to update multiple items in a single API call. What's the best way to do that?">>}],
                     consumed_capacity =
                         #ddb2_consumed_capacity{
                            table_name = <<"Thread">>,
                            capacity_units = 1},
                     item_collection_metrics =
                         #ddb2_item_collection_metrics{
                            item_collection_key = <<"Amazon DynamoDB">>,
                            size_estimate_range_gb = {1,2}}
                     }}}),
         ?_ddb_test(
            {"PutItem response with complex item", "
{
    \"Attributes\": {
        \"bool_true\": {\"BOOL\": true},
        \"bool_false\": {\"BOOL\": false},
        \"null_value\": {\"NULL\": true},
        \"list_value\": {\"L\": [
            {\"S\": \"string\"},
            {\"SS\": [
                \"string1\",
                \"string2\"
            ]}
        ]},
        \"map_value\": {\"M\": {
            \"key1\": {\"S\": \"value1\"},
            \"key2\": {\"L\": [
                {\"S\": \"list_string1\"},
                {\"S\": \"list_string2\"}
            ]}
        }},
        \"empty_map_value\": {\"M\": {}}
    }
}",

             {ok, #ddb2_put_item{
                     attributes = [{<<"bool_true">>, true},
                                   {<<"bool_false">>, false},
                                   {<<"null_value">>, undefined},
                                   {<<"list_value">>, [<<"string">>, [<<"string1">>, <<"string2">>]]},
                                   {<<"map_value">>, #{ 
                                       <<"key1">> => <<"value1">>,
                                       <<"key2">> => [<<"list_string1">>, <<"list_string2">>]
                                   }},
                                   {<<"empty_map_value">>, #{}}
                                  ]
                     }}}),
         ?_ddb_test(
            {"PutItem response with nested map", "
{
    \"Attributes\": {
        \"bool_true\": {\"BOOL\": true},
        \"bool_false\": {\"BOOL\": false},
        \"null_value\": {\"NULL\": true},
        \"list_value\": {\"L\": [
            {\"S\": \"string\"},
            {\"SS\": [
                \"string1\",
                \"string2\"
            ]}
        ]},
        \"map_value\": {\"M\": {
            \"key1\": {\"M\": {\"inner\": {\"S\": \"value1\"}}},
            \"key2\": {\"L\": [
                {\"S\": \"list_string1\"},
                {\"S\": \"list_string2\"}
            ]}
        }},
        \"empty_map_value\": {\"M\": {}}
    }
}",

             {ok, #ddb2_put_item{
                     attributes = [{<<"bool_true">>, true},
                                   {<<"bool_false">>, false},
                                   {<<"null_value">>, undefined},
                                   {<<"list_value">>, [<<"string">>, [<<"string1">>, <<"string2">>]]},
                                   {<<"map_value">>, #{ 
                                       <<"key1">> => #{<<"inner">> => <<"value1">>},
                                       <<"key2">> => [<<"list_string1">>, <<"list_string2">>]
                                   }},
                                   {<<"empty_map_value">>, #{}}
                                  ]
                     }}})
        ],

    output_tests(?_f(erlcloud_ddb2:put_item(<<"table">>, [], [{out, record}, return_maps])), Tests).

%% Query test based on the API examples:
%% http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_Query.html
q_input_tests(_) ->
    Tests =
        [?_ddb_test(
            {"Query example 1 request",
             ?_f(erlcloud_ddb2:q(<<"Thread">>,
                                [{<<"LastPostDateTime">>, {{s, <<"20130101">>}, {s, <<"20130115">>}}, between},
                                 {<<"ForumName">>, {s, <<"Amazon DynamoDB">>}}],
                                [{index_name, <<"LastPostIndex">>},
                                 {select, all_attributes},
                                 {limit, 3},
                                 {consistent_read, true}])), "
{
    \"TableName\": \"Thread\",
    \"IndexName\": \"LastPostIndex\",
    \"Select\": \"ALL_ATTRIBUTES\",
    \"Limit\":3,
    \"ConsistentRead\": true,
    \"KeyConditions\": {
        \"LastPostDateTime\": {
            \"AttributeValueList\": [
                {
                    \"S\": \"20130101\"
                },
                {
                    \"S\": \"20130115\"
                }
            ],
            \"ComparisonOperator\": \"BETWEEN\"
        },
        \"ForumName\": {
            \"AttributeValueList\": [
                {
                    \"S\": \"Amazon DynamoDB\"
                }
            ],
            \"ComparisonOperator\": \"EQ\"
        }
    }
}"
            }),
         ?_ddb_test(
            {"Query example 2 request",
             ?_f(erlcloud_ddb2:q(<<"Thread">>,
                                {<<"ForumName">>, <<"Amazon DynamoDB">>, eq},
                                [{select, count},
                                 {consistent_read, true}])), "
{
    \"TableName\": \"Thread\",
    \"Select\": \"COUNT\",
    \"ConsistentRead\": true,
    \"KeyConditions\": {
        \"ForumName\": {
            \"AttributeValueList\": [
                {
                    \"S\": \"Amazon DynamoDB\"
                }
            ],
            \"ComparisonOperator\": \"EQ\"
        }
    }
}"
            }),
         ?_ddb_test(
            {"Query exclusive start key",
             ?_f(erlcloud_ddb2:q(<<"Thread">>,
                                [{<<"ForumName">>, <<"Amazon DynamoDB">>, eq}],
                                [{select, count},
                                 {index_name, <<"LastPostIndex">>},
                                 {exclusive_start_key, [{<<"ForumName">>, {s, <<"Amazon DynamoDB">>}},
                                                        {<<"Subject">>, {s, <<"Exclusive key can have 3 parts">>}},
                                                        {<<"LastPostDateTime">>, {s, <<"20130102054211">>}}]}])), "
{
    \"TableName\": \"Thread\",
    \"IndexName\": \"LastPostIndex\",
    \"Select\": \"COUNT\",
    \"ExclusiveStartKey\": {
        \"ForumName\": {
            \"S\": \"Amazon DynamoDB\"
        },
        \"Subject\": {
            \"S\": \"Exclusive key can have 3 parts\"
        },
        \"LastPostDateTime\": {
            \"S\": \"20130102054211\"
        }
    },
    \"KeyConditions\": {
        \"ForumName\": {
            \"AttributeValueList\": [
                {
                    \"S\": \"Amazon DynamoDB\"
                }
            ],
            \"ComparisonOperator\": \"EQ\"
        }
    }
}"
            }),
         ?_ddb_test(
            {"Query example request with KeyConditionExpression, ProjectionExpression and ExpressionAttributeValues",
             ?_f(erlcloud_ddb2:q(<<"Reply">>,
                                <<"Id = :v1 AND PostedBy BETWEEN :v2a AND :v2b">>,
                                [{index_name, <<"PostedBy-Index">>},
                                 {limit, 3},
                                 {consistent_read, true},
                                 {projection_expression, <<"Id, PostedBy, ReplyDateTime">>},
                                 {expression_attribute_values, [
                                     {<<":v1">>, "Amazon DynamoDB#DynamoDB Thread 1"},
                                     {<<":v2a">>, "User A"},
                                     {<<":v2b">>, "User C"}]},
                                 {return_consumed_capacity, total}])), "
{
    \"TableName\": \"Reply\",
    \"IndexName\": \"PostedBy-Index\",
    \"Limit\":3,
    \"ConsistentRead\": true,
    \"ProjectionExpression\": \"Id, PostedBy, ReplyDateTime\",
    \"KeyConditionExpression\": \"Id = :v1 AND PostedBy BETWEEN :v2a AND :v2b\",
    \"ExpressionAttributeValues\": {
        \":v1\": {\"S\": \"Amazon DynamoDB#DynamoDB Thread 1\"},
        \":v2a\": {\"S\": \"User A\"},
        \":v2b\": {\"S\": \"User C\"}
    },
    \"ReturnConsumedCapacity\": \"TOTAL\"
}"
            })
        ],

    Response = "
{
    \"Count\":17
}",
    input_tests(Response, Tests).

q_output_tests(_) ->
    Tests =
        [?_ddb_test(
            {"Query example 1 response", "
{
    \"Count\": 3,
    \"Items\": [
        {
            \"LastPostedBy\": {
                \"S\": \"fred@example.com\"
            },
            \"ForumName\": {
                \"S\": \"Amazon DynamoDB\"
            },
            \"LastPostDateTime\": {
                \"S\": \"20130102054211\"
            },
            \"Tags\": {
                \"SS\": [\"Problem\",\"Question\"]
            }
        },
        {
            \"LastPostedBy\": {
                \"S\": \"alice@example.com\"
            },
            \"ForumName\": {
                \"S\": \"Amazon DynamoDB\"
            },
            \"LastPostDateTime\": {
                    \"S\": \"20130105111307\"
            },
            \"Tags\": {
                \"SS\": [\"Idea\"]
            }
        },
        {
            \"LastPostedBy\": {
                \"S\": \"bob@example.com\"
            },
            \"ForumName\": {
                \"S\": \"Amazon DynamoDB\"
            },
            \"LastPostDateTime\": {
                \"S\": \"20130108094417\"
            },
            \"Tags\": {
                \"SS\": [\"AppDesign\", \"HelpMe\"]
            }
        }
    ],
    \"ConsumedCapacity\": {
        \"CapacityUnits\": 2,
        \"TableName\": \"Thread\"
    },
    \"ScannedCount\": 3
}",
             {ok, #ddb2_q{count = 3,
                          items = [[{<<"LastPostedBy">>, <<"fred@example.com">>},
                                    {<<"ForumName">>, <<"Amazon DynamoDB">>},
                                    {<<"LastPostDateTime">>, <<"20130102054211">>},
                                    {<<"Tags">>, [<<"Problem">>,<<"Question">>]}],
                                   [{<<"LastPostedBy">>, <<"alice@example.com">>},
                                    {<<"ForumName">>, <<"Amazon DynamoDB">>},
                                    {<<"LastPostDateTime">>, <<"20130105111307">>},
                                    {<<"Tags">>, [<<"Idea">>]}],
                                   [{<<"LastPostedBy">>, <<"bob@example.com">>},
                                    {<<"ForumName">>, <<"Amazon DynamoDB">>},
                                    {<<"LastPostDateTime">>, <<"20130108094417">>},
                                    {<<"Tags">>, [<<"AppDesign">>, <<"HelpMe">>]}]],
                          consumed_capacity =
                              #ddb2_consumed_capacity{
                                 capacity_units = 2,
                                 table_name = <<"Thread">>},
                          scanned_count = 3}}}),
         ?_ddb_test(
            {"Query example 2 response", "
{
    \"Count\":17
}",
             {ok, #ddb2_q{count = 17}}}),
         ?_ddb_test(
            {"Query last evaluated key", "
{
    \"Count\":17,
    \"LastEvaluatedKey\": {
        \"ForumName\": {
            \"S\": \"Amazon DynamoDB\"
        },
        \"Subject\": {
            \"S\": \"Exclusive key can have 3 parts\"
        },
        \"LastPostDateTime\": {
            \"S\": \"20130102054211\"
        }
    }
}",
             {ok, #ddb2_q{count = 17,
                         last_evaluated_key =
                             [{<<"ForumName">>, {s, <<"Amazon DynamoDB">>}},
                              {<<"Subject">>, {s, <<"Exclusive key can have 3 parts">>}},                                                        {<<"LastPostDateTime">>, {s, <<"20130102054211">>}}]
                         }}})
        ],

    output_tests(?_f(erlcloud_ddb2:q(<<"table">>, [{<<"k">>, <<"v">>, eq}], [{out, record}])), Tests).

%% RestoreTableFromBackup test based on the API examples:
%% https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_RestoreTableFromBackup.html
restore_table_from_backup_input_tests(_) ->
 Tests =
  [?_ddb_test(
   {"RestoreTableFromBackup example request",
    ?_f(erlcloud_ddb2:restore_table_from_backup(<<"arn:aws:dynamodb:us-east-1:387047610112:table/Forum/backup/01523517555423-69b67bcb">>,<<"Thread">>)), "
    {
        \"BackupArn\": \"arn:aws:dynamodb:us-east-1:387047610112:table/Forum/backup/01523517555423-69b67bcb\",
        \"TargetTableName\": \"Thread\"
    }"
   })
  ],
 Response = "
{
    \"TableDescription\": {
        \"AttributeDefinitions\": [
            {
                \"AttributeName\": \"ForumName\",
                \"AttributeType\": \"S\"
            },
            {
                \"AttributeName\": \"LastPostDateTime\",
                \"AttributeType\": \"S\"
            },
            {
                \"AttributeName\": \"Subject\",
                \"AttributeType\": \"S\"
            }
        ],
        \"CreationDateTime\": 1.36372808007E9,
        \"GlobalSecondaryIndexes\": [
            {
                \"IndexName\": \"SubjectIndex\",
                \"IndexSizeBytes\": 2048,
                \"IndexStatus\": \"CREATING\",
                \"ItemCount\": 47,
                \"KeySchema\": [
                    {
                        \"AttributeName\": \"Subject\",
                        \"KeyType\": \"HASH\"
                    },
                    {
                        \"AttributeName\": \"LastPostDateTime\",
                        \"KeyType\": \"RANGE\"
                    }
                ],
                \"Projection\": {
                    \"ProjectionType\": \"KEYS_ONLY\"
                },
                \"ProvisionedThroughput\": {
                    \"LastDecreaseDateTime\": 0,
                    \"LastIncreaseDateTime\": 1,
                    \"NumberOfDecreasesToday\": 2,
                    \"ReadCapacityUnits\": 3,
                    \"WriteCapacityUnits\": 4
                }
            }
        ],
        \"ItemCount\": 0,
        \"KeySchema\": [
            {
                \"AttributeName\": \"ForumName\",
                \"KeyType\": \"HASH\"
            },
            {
                \"AttributeName\": \"Subject\",
                \"KeyType\": \"RANGE\"
            }
        ],
        \"LocalSecondaryIndexes\": [
            {
                \"IndexName\": \"LastPostIndex\",
                \"IndexSizeBytes\": 0,
                \"ItemCount\": 0,
                \"KeySchema\": [
                    {
                        \"AttributeName\": \"ForumName\",
                        \"KeyType\": \"HASH\"
                    },
                    {
                        \"AttributeName\": \"LastPostDateTime\",
                        \"KeyType\": \"RANGE\"
                    }
                ],
                \"Projection\": {
                    \"ProjectionType\": \"KEYS_ONLY\"
                }
            }
        ],
        \"ProvisionedThroughput\": {
            \"NumberOfDecreasesToday\": 0,
            \"ReadCapacityUnits\": 5,
            \"WriteCapacityUnits\": 5
        },
        \"TableName\": \"Thread\",
        \"TableSizeBytes\": 0,
        \"TableStatus\": \"CREATING\"
    }
}",
 input_tests(Response, Tests).

restore_table_from_backup_output_tests(_) ->
 Tests =
  [?_ddb_test(
   {"RestoreTableFromBackup example response", "{
    \"TableDescription\": {
        \"AttributeDefinitions\": [
            {
                \"AttributeName\": \"ForumName\",
                \"AttributeType\": \"S\"
            },
            {
                \"AttributeName\": \"LastPostDateTime\",
                \"AttributeType\": \"S\"
            },
            {
                \"AttributeName\": \"Subject\",
                \"AttributeType\": \"S\"
            }
        ],
        \"CreationDateTime\": 1.36372808007E9,
        \"GlobalSecondaryIndexes\": [
            {
                \"IndexName\": \"SubjectIndex\",
                \"IndexSizeBytes\": 2048,
                \"IndexStatus\": \"CREATING\",
                \"ItemCount\": 47,
                \"KeySchema\": [
                    {
                        \"AttributeName\": \"Subject\",
                        \"KeyType\": \"HASH\"
                    },
                    {
                        \"AttributeName\": \"LastPostDateTime\",
                        \"KeyType\": \"RANGE\"
                    }
                ],
                \"Projection\": {
                    \"ProjectionType\": \"KEYS_ONLY\"
                },
                \"ProvisionedThroughput\": {
                    \"LastDecreaseDateTime\": 0,
                    \"LastIncreaseDateTime\": 1,
                    \"NumberOfDecreasesToday\": 2,
                    \"ReadCapacityUnits\": 3,
                    \"WriteCapacityUnits\": 4
                }
            }
        ],
        \"ItemCount\": 0,
        \"KeySchema\": [
            {
                \"AttributeName\": \"ForumName\",
                \"KeyType\": \"HASH\"
            },
            {
                \"AttributeName\": \"Subject\",
                \"KeyType\": \"RANGE\"
            }
        ],
        \"LocalSecondaryIndexes\": [
            {
                \"IndexName\": \"LastPostIndex\",
                \"IndexSizeBytes\": 0,
                \"ItemCount\": 0,
                \"KeySchema\": [
                    {
                        \"AttributeName\": \"ForumName\",
                        \"KeyType\": \"HASH\"
                    },
                    {
                        \"AttributeName\": \"LastPostDateTime\",
                        \"KeyType\": \"RANGE\"
                    }
                ],
                \"Projection\": {
                    \"ProjectionType\": \"KEYS_ONLY\"
                }
            }
        ],
        \"ProvisionedThroughput\": {
            \"NumberOfDecreasesToday\": 0,
            \"ReadCapacityUnits\": 5,
            \"WriteCapacityUnits\": 5
        },
         \"RestoreSummary\": {
            \"RestoreDateTime\": 1.36372808007E9,
            \"RestoreInProgress\": false,
            \"SourceBackupArn\": \"arn:aws:dynamodb:us-east-1:387047610112:table/Forum/backup/01523517555423-69b67bcb\",
            \"SourceTableArn\": \"arn:aws:dynamodb:us-east-1:387047610112:table/Forum\"
         },
        \"TableName\": \"Thread\",
        \"TableSizeBytes\": 0,
        \"TableStatus\": \"CREATING\"
    }
}",
    {ok, #ddb2_table_description
        {attribute_definitions = [
            {<<"ForumName">>, s},
            {<<"LastPostDateTime">>, s},
            {<<"Subject">>, s}
        ],
         creation_date_time = 1363728080.07,
         item_count = 0,
         key_schema = {<<"ForumName">>, <<"Subject">>},
         local_secondary_indexes =
             [#ddb2_local_secondary_index_description{
                 index_name = <<"LastPostIndex">>,
                 index_size_bytes = 0,
                 item_count = 0,
                 key_schema = {<<"ForumName">>, <<"LastPostDateTime">>},
                 projection = keys_only}],
         global_secondary_indexes =
             [#ddb2_global_secondary_index_description{
                 index_name = <<"SubjectIndex">>,
                 index_size_bytes = 2048,
                 index_status = creating,
                 item_count = 47,
                 key_schema = {<<"Subject">>, <<"LastPostDateTime">>},
                 projection = keys_only,
                 provisioned_throughput =
                     #ddb2_provisioned_throughput_description{
                      last_decrease_date_time = 0,
                      last_increase_date_time = 1,
                      number_of_decreases_today = 2,
                      read_capacity_units = 3,
                      write_capacity_units = 4}
             }],
         provisioned_throughput =
             #ddb2_provisioned_throughput_description{
              last_decrease_date_time = undefined,
              last_increase_date_time = undefined,
              number_of_decreases_today = 0,
              read_capacity_units = 5,
              write_capacity_units = 5},
         restore_summary =
             #ddb2_restore_summary{
              restore_date_time = 1363728080.07,
              restore_in_progress = false,
              source_backup_arn = <<"arn:aws:dynamodb:us-east-1:387047610112:table/Forum/backup/01523517555423-69b67bcb">>,
              source_table_arn = <<"arn:aws:dynamodb:us-east-1:387047610112:table/Forum">>
             },
         table_name = <<"Thread">>,
         table_size_bytes = 0,
         table_status = creating}
    }})
  ],

 output_tests(?_f(erlcloud_ddb2:restore_table_from_backup(<<"arn:aws:dynamodb:us-east-1:387047610112:table/Forum/backup/01523517555423-69b67bcb">>,<<"Thread">>)), Tests).

%% RestoreTableToPointInTime test based on the API examples:
%% https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_RestoreTableToPointInTime.html
restore_table_to_point_in_time_input_tests(_) ->
 Tests =
  [?_ddb_test(
   {"RestoreTableToPointInTime example request",
    ?_f(erlcloud_ddb2:restore_table_to_point_in_time(<<"Thread">>, <<"ThreadTo">>, [{restore_date_time, 1522926603.688}, {use_latest_restorable_time, false}])), "
    {
       \"SourceTableName\": \"Thread\",
       \"TargetTableName\": \"ThreadTo\",
       \"RestoreDateTime\": 1522926603.688,
       \"UseLatestRestorableTime\": false
    }"
   })
  ],
 Response = "{
    \"TableDescription\": {
        \"AttributeDefinitions\": [
            {
                \"AttributeName\": \"ForumName\",
                \"AttributeType\": \"S\"
            },
            {
                \"AttributeName\": \"LastPostDateTime\",
                \"AttributeType\": \"S\"
            },
            {
                \"AttributeName\": \"Subject\",
                \"AttributeType\": \"S\"
            }
        ],
        \"CreationDateTime\": 1.36372808007E9,
        \"GlobalSecondaryIndexes\": [
            {
                \"IndexName\": \"SubjectIndex\",
                \"IndexSizeBytes\": 2048,
                \"IndexStatus\": \"CREATING\",
                \"ItemCount\": 47,
                \"KeySchema\": [
                    {
                        \"AttributeName\": \"Subject\",
                        \"KeyType\": \"HASH\"
                    },
                    {
                        \"AttributeName\": \"LastPostDateTime\",
                        \"KeyType\": \"RANGE\"
                    }
                ],
                \"Projection\": {
                    \"ProjectionType\": \"KEYS_ONLY\"
                },
                \"ProvisionedThroughput\": {
                    \"LastDecreaseDateTime\": 0,
                    \"LastIncreaseDateTime\": 1,
                    \"NumberOfDecreasesToday\": 2,
                    \"ReadCapacityUnits\": 3,
                    \"WriteCapacityUnits\": 4
                }
            }
        ],
        \"ItemCount\": 0,
        \"KeySchema\": [
            {
                \"AttributeName\": \"ForumName\",
                \"KeyType\": \"HASH\"
            },
            {
                \"AttributeName\": \"Subject\",
                \"KeyType\": \"RANGE\"
            }
        ],
        \"LocalSecondaryIndexes\": [
            {
                \"IndexName\": \"LastPostIndex\",
                \"IndexSizeBytes\": 0,
                \"ItemCount\": 0,
                \"KeySchema\": [
                    {
                        \"AttributeName\": \"ForumName\",
                        \"KeyType\": \"HASH\"
                    },
                    {
                        \"AttributeName\": \"LastPostDateTime\",
                        \"KeyType\": \"RANGE\"
                    }
                ],
                \"Projection\": {
                    \"ProjectionType\": \"KEYS_ONLY\"
                }
            }
        ],
        \"ProvisionedThroughput\": {
            \"NumberOfDecreasesToday\": 0,
            \"ReadCapacityUnits\": 5,
            \"WriteCapacityUnits\": 5
        },
         \"RestoreSummary\": {
            \"RestoreDateTime\": 1.36372808007E9,
            \"RestoreInProgress\": false,
            \"SourceBackupArn\": \"arn:aws:dynamodb:us-east-1:387047610112:table/Forum/backup/01523517555423-69b67bcb\",
            \"SourceTableArn\": \"arn:aws:dynamodb:us-east-1:387047610112:table/Forum\"
         },
        \"TableName\": \"Thread\",
        \"TableSizeBytes\": 0,
        \"TableStatus\": \"CREATING\"
    }
}",
 input_tests(Response, Tests).

restore_table_to_point_in_time_output_tests(_) ->
 Tests =
  [?_ddb_test(
   {"RestoreTableToPointInTime example response", "{
    \"TableDescription\": {
        \"AttributeDefinitions\": [
            {
                \"AttributeName\": \"ForumName\",
                \"AttributeType\": \"S\"
            },
            {
                \"AttributeName\": \"LastPostDateTime\",
                \"AttributeType\": \"S\"
            },
            {
                \"AttributeName\": \"Subject\",
                \"AttributeType\": \"S\"
            }
        ],
        \"CreationDateTime\": 1.36372808007E9,
        \"GlobalSecondaryIndexes\": [
            {
                \"IndexName\": \"SubjectIndex\",
                \"IndexSizeBytes\": 2048,
                \"IndexStatus\": \"CREATING\",
                \"ItemCount\": 47,
                \"KeySchema\": [
                    {
                        \"AttributeName\": \"Subject\",
                        \"KeyType\": \"HASH\"
                    },
                    {
                        \"AttributeName\": \"LastPostDateTime\",
                        \"KeyType\": \"RANGE\"
                    }
                ],
                \"Projection\": {
                    \"ProjectionType\": \"KEYS_ONLY\"
                },
                \"ProvisionedThroughput\": {
                    \"LastDecreaseDateTime\": 0,
                    \"LastIncreaseDateTime\": 1,
                    \"NumberOfDecreasesToday\": 2,
                    \"ReadCapacityUnits\": 3,
                    \"WriteCapacityUnits\": 4
                }
            }
        ],
        \"ItemCount\": 0,
        \"KeySchema\": [
            {
                \"AttributeName\": \"ForumName\",
                \"KeyType\": \"HASH\"
            },
            {
                \"AttributeName\": \"Subject\",
                \"KeyType\": \"RANGE\"
            }
        ],
        \"LocalSecondaryIndexes\": [
            {
                \"IndexName\": \"LastPostIndex\",
                \"IndexSizeBytes\": 0,
                \"ItemCount\": 0,
                \"KeySchema\": [
                    {
                        \"AttributeName\": \"ForumName\",
                        \"KeyType\": \"HASH\"
                    },
                    {
                        \"AttributeName\": \"LastPostDateTime\",
                        \"KeyType\": \"RANGE\"
                    }
                ],
                \"Projection\": {
                    \"ProjectionType\": \"KEYS_ONLY\"
                }
            }
        ],
        \"ProvisionedThroughput\": {
            \"NumberOfDecreasesToday\": 0,
            \"ReadCapacityUnits\": 5,
            \"WriteCapacityUnits\": 5
        },
         \"RestoreSummary\": {
            \"RestoreDateTime\": 1.36372808007E9,
            \"RestoreInProgress\": false,
            \"SourceBackupArn\": \"arn:aws:dynamodb:us-east-1:387047610112:table/Forum/backup/01523517555423-69b67bcb\",
            \"SourceTableArn\": \"arn:aws:dynamodb:us-east-1:387047610112:table/Forum\"
         },
        \"TableName\": \"Thread\",
        \"TableSizeBytes\": 0,
        \"TableStatus\": \"CREATING\"
    }
}",
    {ok, #ddb2_table_description
        {attribute_definitions = [
             {<<"ForumName">>, s},
             {<<"LastPostDateTime">>, s},
             {<<"Subject">>, s}
         ],
        creation_date_time = 1363728080.07,
        item_count = 0,
        key_schema = {<<"ForumName">>, <<"Subject">>},
        local_secondary_indexes =
            [#ddb2_local_secondary_index_description{
                index_name = <<"LastPostIndex">>,
                index_size_bytes = 0,
                item_count = 0,
                key_schema = {<<"ForumName">>, <<"LastPostDateTime">>},
                projection = keys_only}],
        global_secondary_indexes =
            [#ddb2_global_secondary_index_description{
                index_name = <<"SubjectIndex">>,
                index_size_bytes = 2048,
                index_status = creating,
                item_count = 47,
                key_schema = {<<"Subject">>, <<"LastPostDateTime">>},
                projection = keys_only,
                provisioned_throughput = #ddb2_provisioned_throughput_description{
                 last_decrease_date_time = 0,
                 last_increase_date_time = 1,
                 number_of_decreases_today = 2,
                 read_capacity_units = 3,
                 write_capacity_units = 4}
            }],
        provisioned_throughput =
            #ddb2_provisioned_throughput_description{
             last_decrease_date_time = undefined,
             last_increase_date_time = undefined,
             number_of_decreases_today = 0,
             read_capacity_units = 5,
             write_capacity_units = 5},
        restore_summary =
            #ddb2_restore_summary{
             restore_date_time = 1363728080.07,
             restore_in_progress = false,
             source_backup_arn = <<"arn:aws:dynamodb:us-east-1:387047610112:table/Forum/backup/01523517555423-69b67bcb">>,
             source_table_arn = <<"arn:aws:dynamodb:us-east-1:387047610112:table/Forum">>
            },
        table_name = <<"Thread">>,
        table_size_bytes = 0,
        table_status = creating}}})
  ],

 output_tests(?_f(erlcloud_ddb2:restore_table_to_point_in_time(<<"Thread">>, <<"ThreadTo">>, [{restore_date_time, 1522926603.688}, {use_latest_restorable_time, false}])), Tests).

%% Scan test based on the API examples:
%% http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_Scan.html
scan_input_tests(_) ->
    Tests =
        [?_ddb_test(
            {"Scan example 1 request",
             ?_f(erlcloud_ddb2:scan(<<"Reply">>, [{return_consumed_capacity, total}])), "
{
    \"TableName\": \"Reply\",
    \"ReturnConsumedCapacity\": \"TOTAL\"
}"
            }),
         ?_ddb_test(
            {"Scan example 2 request",
             ?_f(erlcloud_ddb2:scan(<<"Reply">>,
                                   [{scan_filter, [{<<"PostedBy">>, <<"joe@example.com">>, eq}]},
                                    {return_consumed_capacity, total}])), "
{
    \"TableName\": \"Reply\",
    \"ScanFilter\": {
        \"PostedBy\": {
            \"AttributeValueList\": [
                {
                    \"S\": \"joe@example.com\"
                }
            ],
            \"ComparisonOperator\": \"EQ\"
        }
    },
    \"ReturnConsumedCapacity\": \"TOTAL\"
}"
            }),
         ?_ddb_test(
            {"Scan consistent read",
             ?_f(erlcloud_ddb2:scan(<<"Reply">>,
                                   [{consistent_read, true}])), "
{
    \"TableName\": \"Reply\",
    \"ConsistentRead\": true
}"
            }),
         ?_ddb_test(
            {"Scan exclusive start key",
             ?_f(erlcloud_ddb2:scan(<<"Reply">>,
                                   [{exclusive_start_key, [{<<"ForumName">>, {s, <<"Amazon DynamoDB">>}},
                                                           {<<"LastPostDateTime">>, {n, 20130102054211}}]}])), "
{
    \"TableName\": \"Reply\",
    \"ExclusiveStartKey\": {
        \"ForumName\": {
            \"S\": \"Amazon DynamoDB\"
        },
        \"LastPostDateTime\": {
            \"N\": \"20130102054211\"
        }
    }
}"
            }),
         ?_ddb_test(
            {"Parallel Scan",
             ?_f(erlcloud_ddb2:scan(<<"Reply">>,
                                    [{segment, 1},
                                     {total_segments, 2}])), "
{
    \"TableName\": \"Reply\",
    \"Segment\": 1,
    \"TotalSegments\": 2
}"
            }),
         ?_ddb_test(
            {"Index Scan",
             ?_f(erlcloud_ddb2:scan(<<"Thread">>,
                                    [{scan_filter, [{<<"ForumType">>, <<"Interests">>, eq},
                                                    {<<"LastPostDateTime">>, {0, 201303201023}, between}]},
                                     {index_name, <<"ForumTypeIdx">>}])), "
{
    \"TableName\": \"Thread\",
    \"IndexName\": \"ForumTypeIdx\",
    \"ScanFilter\": {
        \"ForumType\": {
            \"AttributeValueList\": [
                {
                    \"S\": \"Interests\"
                }
            ],
            \"ComparisonOperator\": \"EQ\"
        },
        \"LastPostDateTime\": {
            \"AttributeValueList\": [
                {
                    \"N\": \"0\"
                },
                {
                    \"N\": \"201303201023\"
                }
            ],
            \"ComparisonOperator\": \"BETWEEN\"
        }
    }
}"
            }),
         ?_ddb_test(
            {"Scan example with FilterExpression",
             ?_f(erlcloud_ddb2:scan(<<"Reply">>,
                                   [{filter_expression, <<"PostedBy = :val">>},
                                    {expression_attribute_values, [
                                        {<<":val">>, {s, <<"joe@example.com">>}}]},
                                    {return_consumed_capacity, total}])), "
{
    \"TableName\": \"Reply\",
    \"FilterExpression\": \"PostedBy = :val\",
    \"ExpressionAttributeValues\": {\":val\": {\"S\": \"joe@example.com\"}},
    \"ReturnConsumedCapacity\": \"TOTAL\"
}"
            })
        ],

    Response = "
{
    \"ConsumedCapacity\": {
        \"CapacityUnits\": 0.5,
        \"TableName\": \"Reply\"
    },
    \"Count\": 4,
    \"Items\": [
        {
            \"PostedBy\": {
                \"S\": \"joe@example.com\"
            },
            \"ReplyDateTime\": {
                \"S\": \"20130320115336\"
            },
            \"Id\": {
                \"S\": \"Amazon DynamoDB#How do I update multiple items?\"
            },
            \"Message\": {
                \"S\": \"Have you looked at the BatchWriteItem API?\"
            }
        },
        {
            \"PostedBy\": {
                \"S\": \"fred@example.com\"
            },
            \"ReplyDateTime\": {
                \"S\": \"20130320115342\"
            },
            \"Id\": {
                \"S\": \"Amazon DynamoDB#How do I update multiple items?\"
            },
            \"Message\": {
                \"S\": \"No, I didn't know about that.  Where can I find more information?\"
            }
        },
        {
            \"PostedBy\": {
                \"S\": \"joe@example.com\"
            },
            \"ReplyDateTime\": {
                \"S\": \"20130320115347\"
            },
            \"Id\": {
                \"S\": \"Amazon DynamoDB#How do I update multiple items?\"
            },
            \"Message\": {
                \"S\": \"BatchWriteItem is documented in the Amazon DynamoDB API Reference.\"
            }
        },
        {
            \"PostedBy\": {
                \"S\": \"fred@example.com\"
            },
            \"ReplyDateTime\": {
                \"S\": \"20130320115352\"
            },
            \"Id\": {
                \"S\": \"Amazon DynamoDB#How do I update multiple items?\"
            },
            \"Message\": {
                \"S\": \"OK, I'll take a look at that.  Thanks!\"
            }
        }
    ],
    \"ScannedCount\": 4
}",
    input_tests(Response, Tests).

scan_output_tests(_) ->
    Tests =
        [?_ddb_test(
            {"Scan example 1 response", "
{
    \"ConsumedCapacity\": {
        \"CapacityUnits\": 0.5,
        \"TableName\": \"Reply\"
    },
    \"Count\": 4,
    \"Items\": [
        {
            \"PostedBy\": {
                \"S\": \"joe@example.com\"
            },
            \"ReplyDateTime\": {
                \"S\": \"20130320115336\"
            },
            \"Id\": {
                \"S\": \"Amazon DynamoDB#How do I update multiple items?\"
            },
            \"Message\": {
                \"S\": \"Have you looked at the BatchWriteItem API?\"
            }
        },
        {
            \"PostedBy\": {
                \"S\": \"fred@example.com\"
            },
            \"ReplyDateTime\": {
                \"S\": \"20130320115342\"
            },
            \"Id\": {
                \"S\": \"Amazon DynamoDB#How do I update multiple items?\"
            },
            \"Message\": {
                \"S\": \"No, I didn't know about that.  Where can I find more information?\"
            }
        },
        {
            \"PostedBy\": {
                \"S\": \"joe@example.com\"
            },
            \"ReplyDateTime\": {
                \"S\": \"20130320115347\"
            },
            \"Id\": {
                \"S\": \"Amazon DynamoDB#How do I update multiple items?\"
            },
            \"Message\": {
                \"S\": \"BatchWriteItem is documented in the Amazon DynamoDB API Reference.\"
            }
        },
        {
            \"PostedBy\": {
                \"S\": \"fred@example.com\"
            },
            \"ReplyDateTime\": {
                \"S\": \"20130320115352\"
            },
            \"Id\": {
                \"S\": \"Amazon DynamoDB#How do I update multiple items?\"
            },
            \"Message\": {
                \"S\": \"OK, I'll take a look at that.  Thanks!\"
            }
        }
    ],
    \"ScannedCount\": 4
}",
             {ok, #ddb2_scan
              {count = 4,
               items = [[{<<"PostedBy">>, <<"joe@example.com">>},
                         {<<"ReplyDateTime">>, <<"20130320115336">>},
                         {<<"Id">>, <<"Amazon DynamoDB#How do I update multiple items?">>},
                         {<<"Message">>, <<"Have you looked at the BatchWriteItem API?">>}],
                        [{<<"PostedBy">>, <<"fred@example.com">>},
                         {<<"ReplyDateTime">>, <<"20130320115342">>},
                         {<<"Id">>, <<"Amazon DynamoDB#How do I update multiple items?">>},
                         {<<"Message">>, <<"No, I didn't know about that.  Where can I find more information?">>}],
                        [{<<"PostedBy">>, <<"joe@example.com">>},
                         {<<"ReplyDateTime">>, <<"20130320115347">>},
                         {<<"Id">>, <<"Amazon DynamoDB#How do I update multiple items?">>},
                         {<<"Message">>, <<"BatchWriteItem is documented in the Amazon DynamoDB API Reference.">>}],
                        [{<<"PostedBy">>, <<"fred@example.com">>},
                         {<<"ReplyDateTime">>, <<"20130320115352">>},
                         {<<"Id">>, <<"Amazon DynamoDB#How do I update multiple items?">>},
                         {<<"Message">>, <<"OK, I'll take a look at that.  Thanks!">>}]],
               scanned_count = 4,
               consumed_capacity = #ddb2_consumed_capacity{table_name = <<"Reply">>,
                                                          capacity_units = 0.5}}}}),
         ?_ddb_test(
            {"Scan example 2 response", "
{
    \"ConsumedCapacity\": {
        \"CapacityUnits\": 0.5,
        \"TableName\": \"Reply\"
    },
    \"Count\": 2,
    \"Items\": [
        {
            \"PostedBy\": {
                \"S\": \"joe@example.com\"
            },
            \"ReplyDateTime\": {
                \"S\": \"20130320115336\"
            },
            \"Id\": {
                \"S\": \"Amazon DynamoDB#How do I update multiple items?\"
            },
            \"Message\": {
                \"S\": \"Have you looked at the BatchWriteItem API?\"
            }
        },
        {
            \"PostedBy\": {
                \"S\": \"joe@example.com\"
            },
            \"ReplyDateTime\": {
                \"S\": \"20130320115347\"
            },
            \"Id\": {
                \"S\": \"Amazon DynamoDB#How do I update multiple items?\"
            },
            \"Message\": {
                \"S\": \"BatchWriteItem is documented in the Amazon DynamoDB API Reference.\"
            }
        }
    ],
    \"ScannedCount\": 4
}",
             {ok, #ddb2_scan
              {count = 2,
               items = [[{<<"PostedBy">>, <<"joe@example.com">>},
                         {<<"ReplyDateTime">>, <<"20130320115336">>},
                         {<<"Id">>, <<"Amazon DynamoDB#How do I update multiple items?">>},
                         {<<"Message">>, <<"Have you looked at the BatchWriteItem API?">>}],
                        [{<<"PostedBy">>, <<"joe@example.com">>},
                         {<<"ReplyDateTime">>, <<"20130320115347">>},
                         {<<"Id">>, <<"Amazon DynamoDB#How do I update multiple items?">>},
                         {<<"Message">>, <<"BatchWriteItem is documented in the Amazon DynamoDB API Reference.">>}]
],
               scanned_count = 4,
               consumed_capacity = #ddb2_consumed_capacity{table_name = <<"Reply">>,
                                                          capacity_units = 0.5}}}}),
         ?_ddb_test(
            {"Scan last evaluated key", "

{
    \"Count\":2,
    \"Items\": [
        {
            \"PostedBy\": {
                \"S\": \"joe@example.com\"
            },
            \"ReplyDateTime\": {
                \"S\": \"20130320115336\"
            },
            \"Id\": {
                \"S\": \"Amazon DynamoDB#How do I update multiple items?\"
            },
            \"Message\": {
                \"S\": \"Have you looked at the BatchWriteItem API?\"
            }
        },
        {
            \"PostedBy\": {
                \"S\": \"joe@example.com\"
            },
            \"ReplyDateTime\": {
                \"S\": \"20130320115347\"
            },
            \"Id\": {
                \"S\": \"Amazon DynamoDB#How do I update multiple items?\"
            },
            \"Message\": {
                \"S\": \"BatchWriteItem is documented in the Amazon DynamoDB API Reference.\"
            }
        }
    ],
    \"LastEvaluatedKey\": {
        \"ForumName\": {
            \"S\": \"Amazon DynamoDB\"
        },
        \"LastPostDateTime\": {
            \"N\": \"20130102054211\"
        }
    },
    \"ScannedCount\":4
}",
             {ok, #ddb2_scan
              {count = 2,
               items = [[{<<"PostedBy">>, <<"joe@example.com">>},
                         {<<"ReplyDateTime">>, <<"20130320115336">>},
                         {<<"Id">>, <<"Amazon DynamoDB#How do I update multiple items?">>},
                         {<<"Message">>, <<"Have you looked at the BatchWriteItem API?">>}],
                        [{<<"PostedBy">>, <<"joe@example.com">>},
                         {<<"ReplyDateTime">>, <<"20130320115347">>},
                         {<<"Id">>, <<"Amazon DynamoDB#How do I update multiple items?">>},
                         {<<"Message">>, <<"BatchWriteItem is documented in the Amazon DynamoDB API Reference.">>}]
],
               last_evaluated_key = [{<<"ForumName">>, {s, <<"Amazon DynamoDB">>}},
                                     {<<"LastPostDateTime">>, {n, 20130102054211}}],
               scanned_count = 4}}})
        ],

    output_tests(?_f(erlcloud_ddb2:scan(<<"name">>, [{out, record}])), Tests).

%% TagResource test based on the API:
%% https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_TagResource.html
tag_resource_input_tests(_) ->
    Tests =
        [?_ddb_test(
            {"ListTagsOfResource example request",
             ?_f(erlcloud_ddb2:tag_resource(<<"arn:aws:dynamodb:us-east-1:111122223333:table/Forum">>,
                                            [{<<"example_key1">>, <<"example_value1">>},
                                             {<<"example_key2">>, <<"example_value2">>}])), "
{
    \"ResourceArn\": \"arn:aws:dynamodb:us-east-1:111122223333:table/Forum\",
    \"Tags\": [
      {
          \"Key\": \"example_key1\",
          \"Value\": \"example_value1\"
      },
      {
          \"Key\": \"example_key2\",
          \"Value\": \"example_value2\"
      }
    ]
}"
            })
        ],
    Response = "",
    input_tests(Response, Tests).

tag_resource_output_tests(_) ->
    Tests =
        [?_ddb_test(
            {"ListTagsOfResource example response", "",
             ok})
        ],
    output_tests(?_f(erlcloud_ddb2:tag_resource(<<"arn:aws:dynamodb:us-east-1:111122223333:table/Forum">>,
                                                [{<<"example_key1">>, <<"example_value1">>},
                                                 {<<"example_key2">>, <<"example_value2">>}])),
                     Tests).

%% TransactGetItem test using synthetic data (there are no AWS provided examples):
%% https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_TransactGetItems.html
transact_get_items_input_tests(_) ->
    Tests =
        [?_ddb_test(
            {"TransactGetItems request",
             ?_f(erlcloud_ddb2:transact_get_items(
                [{get, {<<"PersonalInfo">>, [{<<"Name">>, {s, <<"John Smith">>}},
                                             {<<"DOB">>, {s, <<"11/11/2011">>}}]}},
                 {get, {<<"EmployeeRecord">>, [{<<"Name">>, {s, <<"John Smith">>}},
                                               {<<"DOH">>, {s, <<"11/11/2018">>}}]}}],
                 [{return_consumed_capacity, total}])), "
{
    \"TransactItems\": [
        {\"Get\": {
            \"Key\": {
                \"Name\": {
                    \"S\": \"John Smith\"
                },
                \"DOB\": {
                    \"S\": \"11/11/2011\"
                }
            },
            \"TableName\": \"PersonalInfo\"
        }},
        {\"Get\": {
            \"Key\": {
                \"Name\": {
                    \"S\": \"John Smith\"
                },
                \"DOH\": {
                    \"S\": \"11/11/2018\"
                }
            },
            \"TableName\": \"EmployeeRecord\"
        }}
    ],
    \"ReturnConsumedCapacity\": \"TOTAL\"
}"
            })
        ],

    Response = "
{
    \"ConsumedCapacity\": [
        {
            \"TableName\": \"PersonalInfo\",
            \"CapacityUnits\": 2
        },
        {
            \"TableName\": \"EmployeeRecord\",
            \"CapacityUnits\": 3
        }
    ],
    \"Responses\": [
        {\"Item\": {
            \"Name\":{
                \"S\":\"John Smith\"
            },
            \"DOB\":{
                \"S\":\"11/11/2011\"
            },
            \"Creation_ts\":{
                \"N\":\"1500000000\"
            }
        }},
        {\"Item\": {
            \"Name\":{
                \"S\":\"John Smith\"
            },
            \"DOH\":{
                \"S\":\"11/11/2018\"
            },
            \"Id\":{
                \"N\":\"19\"
            }
        }}
    ]
}",
    input_tests(Response, Tests).

transact_get_items_output_tests(_) ->
    Tests =
        [?_ddb_test(
            {"TransactGetItems response only", "
{
    \"Responses\": [
        {\"Item\": {
            \"Name\":{
                \"S\":\"John Smith\"
            },
            \"DOB\":{
                \"S\":\"11/11/2011\"
            },
            \"Creation_ts\":{
                \"N\":\"1500000000\"
            }
        }},
        {\"Item\": {
            \"Name\":{
                \"S\":\"John Smith\"
            },
            \"DOH\":{
                \"S\":\"11/11/2018\"
            },
            \"Id\":{
                \"N\":\"19\"
            }
        }}
    ]
}",
             {ok, #ddb2_transact_get_items{
                 responses = [
                     #ddb2_item_response{
                        item = [
                            {<<"Name">>, <<"John Smith">>},
                            {<<"DOB">>, <<"11/11/2011">>},
                            {<<"Creation_ts">>, 1500000000}
                        ]
                     },
                     #ddb2_item_response{
                        item = [
                            {<<"Name">>, <<"John Smith">>},
                            {<<"DOH">>, <<"11/11/2018">>},
                            {<<"Id">>, 19}
                        ]
                     }
                 ]
             }}}),
         ?_ddb_test(
            {"TransactGetItems consumed capacity", "
{
    \"ConsumedCapacity\": [
        {
            \"TableName\": \"PersonalInfo\",
            \"CapacityUnits\": 2
        },
        {
            \"TableName\": \"EmployeeRecord\",
            \"CapacityUnits\": 3
        }
    ],
    \"Responses\": [
        {\"Item\": {
            \"Name\":{
                \"S\":\"John Smith\"
            },
            \"DOB\":{
                \"S\":\"11/11/2011\"
            },
            \"Creation_ts\":{
                \"N\":\"1500000000\"
            }
        }},
        {\"Item\": {
            \"Name\":{
                \"S\":\"John Smith\"
            },
            \"DOH\":{
                \"S\":\"11/11/2018\"
            },
            \"Id\":{
                \"N\":\"19\"
            }
        }}
    ]
}",
             {ok, #ddb2_transact_get_items{
                 responses = [
                     #ddb2_item_response{
                        item = [
                            {<<"Name">>, <<"John Smith">>},
                            {<<"DOB">>, <<"11/11/2011">>},
                            {<<"Creation_ts">>, 1500000000}
                        ]
                     },
                     #ddb2_item_response{
                        item = [
                            {<<"Name">>, <<"John Smith">>},
                            {<<"DOH">>, <<"11/11/2018">>},
                            {<<"Id">>, 19}
                        ]
                     }
                 ],
                 consumed_capacity = [
                     #ddb2_consumed_capacity{
                        capacity_units = 2, table_name = <<"PersonalInfo">>
                     },
                     #ddb2_consumed_capacity{
                        capacity_units = 3, table_name = <<"EmployeeRecord">>
                     }
                 ]
             }}})
        ],

    output_tests(?_f(erlcloud_ddb2:transact_get_items([], [{out, record}])),
            Tests).

%% TransactWriteItems test using synthetic data (there are no AWS provided examples):
%% https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_TransactWriteItems.html
transact_write_items_input_tests(_) ->
    Tests =
        [?_ddb_test(
            {"TransactWriteItems request",
             ?_f(erlcloud_ddb2:transact_write_items(
                 [{update, {
                     <<"PersonalInfo">>,
                     [{<<"Name">>, {s, <<"John Smith">>}}, {<<"DOB">>, {s, <<"11/11/2011">>}}],
                     <<"SET eye_color = :c">>,
                     [{expression_attribute_values, [{<<":c">>, <<"brown">>}]}]}},
                  {condition_check, {
                      <<"Scratchpad">>,
                      [{<<"Name">>, {s, <<"John Smith">>}}, {<<"DOB">>, {s, <<"11/11/2011">>}}],
                     [{condition_expression, <<"approved = :a">>},
                      {expression_attribute_values, [{<<":a">>, <<"yes">>}]}]}},
                  {delete, {<<"Scratchpad">>, [{<<"Name">>, {s, <<"John Smith">>}},
                                               {<<"DOB">>, {s, <<"11/11/2011">>}}]}},
                  {put, {<<"EmployeeRecord">>, [{<<"Name">>, {s, <<"John Smith">>}},
                                                {<<"DOH">>, {s, <<"11/11/2018">>}}]}}],
                 [{return_consumed_capacity, total},
                  {return_item_collection_metrics, size}])), "
{
    \"TransactItems\": [
        {\"Update\": {
            \"Key\": {
                \"Name\": {
                    \"S\": \"John Smith\"
                },
                \"DOB\": {
                    \"S\": \"11/11/2011\"
                }
            },
            \"ExpressionAttributeValues\": {
                \":c\": {\"S\": \"brown\"}
            },
            \"UpdateExpression\": \"SET eye_color = :c\",
            \"TableName\": \"PersonalInfo\"
        }},
        {\"ConditionCheck\": {
            \"Key\": {
                \"Name\": {
                    \"S\": \"John Smith\"
                },
                \"DOB\": {
                    \"S\": \"11/11/2011\"
                }
            },
            \"ExpressionAttributeValues\": {
                \":a\": {\"S\": \"yes\"}
            },
            \"ConditionExpression\": \"approved = :a\",
            \"TableName\": \"Scratchpad\"
        }},
        {\"Delete\": {
            \"Key\": {
                \"Name\": {
                    \"S\": \"John Smith\"
                },
                \"DOB\": {
                    \"S\": \"11/11/2011\"
                }
            },
            \"TableName\": \"Scratchpad\"
        }},
        {\"Put\": {
            \"Item\": {
                \"Name\": {
                    \"S\": \"John Smith\"
                },
                \"DOH\": {
                    \"S\": \"11/11/2018\"
                }
            },
            \"TableName\": \"EmployeeRecord\"
        }}
    ],
    \"ReturnConsumedCapacity\": \"TOTAL\",
    \"ReturnItemCollectionMetrics\": \"SIZE\"
}"
            })
        ],

    Response = "
{
    \"ItemCollectionMetrics\": {
        \"PersonalInfo\": [{
            \"ItemCollectionKey\": {
                \"Name\": {
                    \"S\": \"John Smith\"
                }
            },
            \"SizeEstimateRangeGB\": [1, 2]
        }],
        \"Scratchpad\": [{
            \"ItemCollectionKey\": {
                \"Name\": {
                    \"S\": \"John Smith\"
                }
            },
            \"SizeEstimateRangeGB\": [0, 1]
        }],
        \"EmployeeRecord\": [{
            \"ItemCollectionKey\": {
                \"Name\": {
                    \"S\": \"John Smith\"
                }
            },
            \"SizeEstimateRangeGB\": [2, 3]
        }]
    },
    \"ConsumedCapacity\": [
        {
            \"TableName\": \"PersonalInfo\",
            \"CapacityUnits\": 3
        },
        {
            \"TableName\": \"Scratchpad\",
            \"CapacityUnits\": 4
        },
        {
            \"TableName\": \"EmployeeRecord\",
            \"CapacityUnits\": 3
        }
    ]
}",
    input_tests(Response, Tests).

transact_write_items_output_tests(_) ->
    Tests =
        [?_ddb_test(
            {"TransactWriteItems consumed capacity", "
{
    \"ConsumedCapacity\": [
        {
            \"TableName\": \"PersonalInfo\",
            \"CapacityUnits\": 3
        },
        {
            \"TableName\": \"Scratchpad\",
            \"CapacityUnits\": 4
        },
        {
            \"TableName\": \"EmployeeRecord\",
            \"CapacityUnits\": 3
        }
    ]
}",
             {ok, #ddb2_transact_write_items{
                 consumed_capacity = [
                     #ddb2_consumed_capacity{
                        capacity_units = 3, table_name = <<"PersonalInfo">>
                     },
                     #ddb2_consumed_capacity{
                        capacity_units = 4, table_name = <<"Scratchpad">>
                     },
                     #ddb2_consumed_capacity{
                        capacity_units = 3, table_name = <<"EmployeeRecord">>
                     }
                 ]
             }}}),
         ?_ddb_test(
            {"TransactWriteItems item collection metrics", "
{
    \"ItemCollectionMetrics\": {
        \"PersonalInfo\": [{
            \"ItemCollectionKey\": {
                \"Name\": {
                    \"S\": \"John Smith\"
                }
            },
            \"SizeEstimateRangeGB\": [1, 2]
        }],
        \"Scratchpad\": [{
            \"ItemCollectionKey\": {
                \"Name\": {
                    \"S\": \"John Smith\"
                }
            },
            \"SizeEstimateRangeGB\": [0, 1]
        }],
        \"EmployeeRecord\": [{
            \"ItemCollectionKey\": {
                \"Name\": {
                    \"S\": \"John Smith\"
                }
            },
            \"SizeEstimateRangeGB\": [2, 3]
        }]
    }
}",
             {ok, #ddb2_transact_write_items{
                 item_collection_metrics = [
                   {<<"PersonalInfo">>,
                     [#ddb2_item_collection_metrics
                      {item_collection_key = <<"John Smith">>,
                       size_estimate_range_gb = {1, 2}}]},
                   {<<"Scratchpad">>,
                     [#ddb2_item_collection_metrics
                      {item_collection_key = <<"John Smith">>,
                       size_estimate_range_gb = {0, 1}}]},
                   {<<"EmployeeRecord">>,
                     [#ddb2_item_collection_metrics
                      {item_collection_key = <<"John Smith">>,
                       size_estimate_range_gb = {2, 3}}
                     ]}]}}})
        ],

    output_tests(?_f(erlcloud_ddb2:transact_write_items([], [{out, record}])),
            Tests).

%% UntagResource test based on the API:
%% https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_UntagResource.html
untag_resource_input_tests(_) ->
    Tests =
        [?_ddb_test(
            {"ListTagsOfResource example request",
             ?_f(erlcloud_ddb2:untag_resource(<<"arn:aws:dynamodb:us-east-1:111122223333:table/Forum">>,
                                              [<<"example_key1">>, <<"example_key2">>])), "
{
    \"ResourceArn\": \"arn:aws:dynamodb:us-east-1:111122223333:table/Forum\",
    \"TagKeys\": [
        \"example_key1\",
        \"example_key2\"
    ]
}"
            })
        ],
    Response = "",
    input_tests(Response, Tests).

untag_resource_output_tests(_) ->
    Tests =
        [?_ddb_test(
            {"ListTagsOfResource example response", "",
             ok})
        ],
    output_tests(?_f(erlcloud_ddb2:untag_resource(<<"arn:aws:dynamodb:us-east-1:111122223333:table/Forum">>,
                                                  [<<"example_key1">>, <<"example_key2">>])),
                Tests).

%% UpdateContinuousBackups test based on the API examples:
%% https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_UpdateContinuousBackups.html
update_continuous_backups_input_tests(_) ->
 Tests =
  [?_ddb_test(
   {"UpdateContinuousBackups example request",
    ?_f(erlcloud_ddb2:update_continuous_backups(<<"Thread">>,true)), "
    {
      \"PointInTimeRecoverySpecification\": {
          \"PointInTimeRecoveryEnabled\": true
      },
      \"TableName\": \"Thread\"
    }"
   })
  ],
 Response = "{
    \"ContinuousBackupsDescription\": {
        \"ContinuousBackupsStatus\": \"ENABLED\",
        \"PointInTimeRecoveryDescription\": {
           \"EarliestRestorableDateTime\": 1,
           \"LatestRestorableDateTime\": 1,
           \"PointInTimeRecoveryStatus\": \"DISABLED\"
          }
      }
}",
 input_tests(Response, Tests).

update_continuous_backups_output_tests(_) ->
 Tests =
  [?_ddb_test(
   {"UpdateContinuousBackups example response", "{
    \"ContinuousBackupsDescription\": {
        \"ContinuousBackupsStatus\": \"ENABLED\",
        \"PointInTimeRecoveryDescription\": {
           \"EarliestRestorableDateTime\": 1,
           \"LatestRestorableDateTime\": 1,
           \"PointInTimeRecoveryStatus\": \"DISABLED\"
          }
      }
}",
    {ok,#ddb2_continuous_backups_description{
        continuous_backups_status = enabled,
        point_in_time_recovery_description =
            #ddb2_point_in_time_recovery_description{
                earliest_restorable_date_time = 1,
                latest_restorable_date_time = 1,
                point_in_time_recovery_status = disabled}}}
      })
  ],

 output_tests(?_f(erlcloud_ddb2:update_continuous_backups(<<"Thread">>,true)), Tests).

%% UpdateItem test based on the API examples:
%% http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_UpdateItem.html
update_item_input_tests(_) ->
    Tests =
        [?_ddb_test(
            {"UpdateItem example request",
             ?_f(erlcloud_ddb2:update_item(<<"Thread">>,
                                          [{<<"ForumName">>, {s, <<"Amazon DynamoDB">>}},
                                           {<<"Subject">>, {s, <<"How do I update multiple items?">>}}],
                                          [{<<"LastPostedBy">>, {s, <<"alice@example.com">>}, put}],
                                          [{expected, {<<"LastPostedBy">>, {s, <<"fred@example.com">>}}},
                                           {return_values, all_new}])), "
{
    \"TableName\": \"Thread\",
    \"Key\": {
        \"ForumName\": {
            \"S\": \"Amazon DynamoDB\"
        },
        \"Subject\": {
            \"S\": \"How do I update multiple items?\"
        }
    },
    \"AttributeUpdates\": {
        \"LastPostedBy\": {
            \"Value\": {
                \"S\": \"alice@example.com\"
            },
            \"Action\": \"PUT\"
        }
    },
    \"Expected\": {
        \"LastPostedBy\": {
            \"ComparisonOperator\": \"EQ\",
            \"AttributeValueList\": [ { \"S\": \"fred@example.com\" } ]
        }
    },
    \"ReturnValues\": \"ALL_NEW\"
}"
            }),
         ?_ddb_test(
            {"UpdateItem example request 2",
             ?_f(erlcloud_ddb2:update_item(<<"Thread">>,
                                          [{<<"ForumName">>, {s, <<"Amazon DynamoDB">>}},
                                           {<<"Subject">>, {s, <<"A question about updates">>}}],
                                          [{<<"Replies">>, {n, 1}, add}],
                                          [{return_values, none}])), "
{
    \"TableName\": \"Thread\",
    \"Key\": {
        \"ForumName\": {
            \"S\": \"Amazon DynamoDB\"
        },
        \"Subject\": {
            \"S\": \"A question about updates\"
        }
    },
    \"AttributeUpdates\": {
        \"Replies\": {
            \"Action\": \"ADD\",
            \"Value\": {
                \"N\": \"1\"
            }
        }
    },
    \"ReturnValues\" : \"NONE\"
}"
            }),
         ?_ddb_test(
            {"UpdateItem example request with UpdateExpression and ConditionExpression",
             ?_f(erlcloud_ddb2:update_item(<<"Thread">>,
                                          [{<<"ForumName">>, {s, <<"Amazon DynamoDB">>}},
                                           {<<"Subject">>, {s, <<"Maximum number of items?">>}}],
                                          <<"set LastPostedBy = :val1">>,
                                          [{condition_expression, <<"LastPostedBy = :val2">>},
                                           {expression_attribute_values, [
                                               {<<":val1">>, "alice@example.com"},
                                               {<<":val2">>, "fred@example.com"}]},
                                           {return_values, all_new}])), "
{
    \"TableName\": \"Thread\",
    \"Key\": {
        \"ForumName\": {
            \"S\": \"Amazon DynamoDB\"
        },
        \"Subject\": {
            \"S\": \"Maximum number of items?\"
        }
    },
    \"UpdateExpression\": \"set LastPostedBy = :val1\",
    \"ConditionExpression\": \"LastPostedBy = :val2\",
    \"ExpressionAttributeValues\": {
        \":val1\": {\"S\": \"alice@example.com\"},
        \":val2\": {\"S\": \"fred@example.com\"}
    },
    \"ReturnValues\": \"ALL_NEW\"
}"
            }),
         ?_ddb_test(
            {"UpdateItem no attribute updates",
             ?_f(erlcloud_ddb2:update_item(<<"Thread">>,
                                          [{<<"ForumName">>, {s, <<"Amazon DynamoDB">>}},
                                           {<<"Subject">>, {s, <<"A question about updates">>}}],
                                          [])), "
{
    \"TableName\": \"Thread\",
    \"Key\": {
        \"ForumName\": {
            \"S\": \"Amazon DynamoDB\"
        },
        \"Subject\": {
            \"S\": \"A question about updates\"
        }
    }
}"
            })
        ],

    Response = "
{
}",
    input_tests(Response, Tests).

update_item_output_tests(_) ->
    Tests =
        [?_ddb_test(
            {"UpdateItem example response", "
{
    \"Attributes\": {
        \"LastPostedBy\": {
            \"S\": \"alice@example.com\"
        },
        \"ForumName\": {
            \"S\": \"Amazon DynamoDB\"
        },
        \"LastPostDateTime\": {
            \"S\": \"20130320010350\"
        },
        \"Tags\": {
            \"SS\": [\"Update\",\"Multiple Items\",\"HelpMe\"]
        },
        \"Subject\": {
            \"S\": \"Maximum number of items?\"
        },
        \"Views\": {
            \"N\": \"5\"
        },
        \"Message\": {
            \"S\": \"I want to put 10 million data items to an Amazon DynamoDB table.  Is there an upper limit?\"
        }
    }
}",
             {ok, [{<<"LastPostedBy">>, <<"alice@example.com">>},
                   {<<"ForumName">>, <<"Amazon DynamoDB">>},
                   {<<"LastPostDateTime">>, <<"20130320010350">>},
                   {<<"Tags">>, [<<"Update">>,<<"Multiple Items">>,<<"HelpMe">>]},
                   {<<"Subject">>, <<"Maximum number of items?">>},
                   {<<"Views">>, 5},
                   {<<"Message">>, <<"I want to put 10 million data items to an Amazon DynamoDB table.  Is there an upper limit?">>}]}}),
         ?_ddb_test(
            {"UpdateItem example response 2", "
{
}",
             {ok, []}})
        ],

    output_tests(?_f(erlcloud_ddb2:update_item(<<"table">>, {<<"k">>, <<"v">>}, [])), Tests).

%% UpdateGlobalTable input test:
update_global_table_input_tests(_) ->
    Tests =
          [?_ddb_test(
              {"UpdateGlobalTable example request (create)",
               ?_f(erlcloud_ddb2:update_global_table(<<"Thread">>, [{create, {region_name, <<"us-east-1">>}}])), "
{
   \"GlobalTableName\": \"Thread\",
   \"ReplicaUpdates\": [
      {
         \"Create\": {
            \"RegionName\": \"us-east-1\"
         }
      }
  ]
}"
              }),
           ?_ddb_test(
              {"UpdateGlobalTable example request (delete)",
               ?_f(erlcloud_ddb2:update_global_table(<<"Thread">>, [{delete, #ddb2_replica{region_name = <<"us-west-2">>}}])), "
{
   \"GlobalTableName\": \"Thread\",
   \"ReplicaUpdates\": [
      {
         \"Delete\": {
            \"RegionName\": \"us-west-2\"
         }
      }
  ]
}"
              }),
           ?_ddb_test(
              {"UpdateGlobalTable example request (multiple)",
               ?_f(erlcloud_ddb2:update_global_table(<<"Thread">>, [{create, {region_name, <<"us-east-1">>}},
                                                                    {delete, {region_name, <<"eu-west-1">>}}])), "
{
   \"GlobalTableName\": \"Thread\",
   \"ReplicaUpdates\": [
      {
         \"Create\": {
            \"RegionName\": \"us-east-1\"
         }
      },{
         \"Delete\": {
            \"RegionName\": \"eu-west-1\"
         }
      }
  ]
}"
              })],
      Response = "
{
   \"GlobalTableDescription\": {
      \"CreationDateTime\": 1519161181.107,
      \"GlobalTableArn\": \"arn:aws:dynamodb::111122223333:global-table/Thread\",
      \"GlobalTableName\": \"Thread\",
      \"GlobalTableStatus\": \"UPDATING\",
      \"ReplicationGroup\": [
          {
             \"RegionName\": \"us-east-1\"
          }
      ]
   }
}",
      input_tests(Response, Tests).

%% UpdateGlobalTable output test:
update_global_table_output_tests(_) ->
    Tests =
        [?_ddb_test(
            {"UpdateGlobalTable example response with UPDATING status", "
{
   \"GlobalTableDescription\": {
      \"CreationDateTime\": 1519161181.107,
      \"GlobalTableArn\": \"arn:aws:dynamodb::111122223333:global-table/Thread\",
      \"GlobalTableName\": \"Thread\",
      \"GlobalTableStatus\": \"UPDATING\",
      \"ReplicationGroup\": [
          {
             \"RegionName\": \"us-east-1\"
          }
      ]
   }
}",
              {ok, #ddb2_global_table_description{
                creation_date_time = 1519161181.107,
                global_table_arn = <<"arn:aws:dynamodb::111122223333:global-table/Thread">>,
                global_table_name = <<"Thread">>,
                global_table_status = updating,
                replication_group = [#ddb2_replica_description{region_name = <<"us-east-1">>}]}}}),

         ?_ddb_test(
            {"UpdateGlobalTable example response with DELETING status", "
{
   \"GlobalTableDescription\": {
      \"CreationDateTime\": 1519161181.107,
      \"GlobalTableArn\": \"arn:aws:dynamodb::111122223333:global-table/Thread\",
      \"GlobalTableName\": \"Thread\",
      \"GlobalTableStatus\": \"DELETING\",
      \"ReplicationGroup\": [
          {
             \"RegionName\": \"eu-west-1\"
          }
      ]
   }
}",
              {ok, #ddb2_global_table_description{
                creation_date_time = 1519161181.107,
                global_table_arn = <<"arn:aws:dynamodb::111122223333:global-table/Thread">>,
                global_table_name = <<"Thread">>,
                global_table_status = deleting,
                replication_group = [#ddb2_replica_description{region_name = <<"eu-west-1">>}]}}})],
    output_tests(?_f(erlcloud_ddb2:update_global_table(<<"Thread">>, [{create, {region_name, <<"us-east-1">>}}])), Tests).

update_global_table_settings_input_tests(_) ->
    ReadUnits = 10,
    WriteUnits = 10,
    StaticProvisionOpts = [{global_table_billing_mode, provisioned},
                           {global_table_global_secondary_index_settings_update, [[{index_name, <<"id-index">>},
                                                                                   {provisioned_write_capacity_units, WriteUnits}]]},
                           {global_table_provisioned_write_capacity_units, WriteUnits},
                           {replica_settings_update, [[{region_name, <<"us-west-2">>},
                                                       {replica_global_secondary_index_settings_update, [[{index_name, <<"id-index">>},
                                                                                                          {provisioned_read_capacity_units, ReadUnits}]]},
                                                       {replica_provisioned_read_capacity_units, ReadUnits}]]}],
    AutoScalingSettingsUpdate = [{maximum_units, 20},
                                 {minimum_units, 10},
                                 {scaling_policy_update, [{target_tracking_scaling_policy_configuration, [{disable_scale_in, false},
                                                                                                          {scale_in_cooldown, 600},
                                                                                                          {scale_out_cooldown, 600},
                                                                                                          {target_value, 70.0}]}]}],
    AutoScalingProvisionOpts = [{global_table_billing_mode, provisioned},
                                {global_table_global_secondary_index_settings_update, [[{index_name, <<"id-index">>},
                                                                                        {provisioned_write_capacity_auto_scaling_settings_update, AutoScalingSettingsUpdate}]]},
                                {global_table_provisioned_write_capacity_auto_scaling_settings_update, AutoScalingSettingsUpdate},
                                {replica_settings_update, [[{region_name, <<"us-west-2">>},
                                                            {replica_global_secondary_index_settings_update, [[{index_name, <<"id-index">>},
                                                                                                               {provisioned_read_capacity_auto_scaling_settings_update, AutoScalingSettingsUpdate}]]},
                                                            {replica_provisioned_read_capacity_auto_scaling_settings_update, AutoScalingSettingsUpdate}]]}],
    Tests =
        [?_ddb_test(
            {"UpdateGlobalTableSettings example request: update all read/write capacity to static values",
             ?_f(erlcloud_ddb2:update_global_table_settings(<<"Thread">>, StaticProvisionOpts)), "
{
  \"GlobalTableBillingMode\": \"PROVISIONED\",
  \"GlobalTableGlobalSecondaryIndexSettingsUpdate\": [
    {
      \"IndexName\": \"id-index\",
      \"ProvisionedWriteCapacityUnits\": 10
    }
  ],
  \"GlobalTableName\": \"Thread\",
  \"GlobalTableProvisionedWriteCapacityUnits\": 10,
  \"ReplicaSettingsUpdate\": [
    {
      \"RegionName\": \"us-west-2\",
      \"ReplicaGlobalSecondaryIndexSettingsUpdate\": [
        {
          \"IndexName\": \"id-index\",
          \"ProvisionedReadCapacityUnits\": 10
        }
      ],
      \"ReplicaProvisionedReadCapacityUnits\": 10
    }
  ]
}"
             }),
         ?_ddb_test(
             {"UpdateGlobalTableSettings example request: update all read/write capacity to autoscale",
              ?_f(erlcloud_ddb2:update_global_table_settings(<<"Thread">>, AutoScalingProvisionOpts)), "
{
  \"GlobalTableBillingMode\": \"PROVISIONED\",
  \"GlobalTableGlobalSecondaryIndexSettingsUpdate\": [
    {
      \"IndexName\": \"id-index\",
      \"ProvisionedWriteCapacityAutoScalingSettingsUpdate\": {
        \"MaximumUnits\": 20,
        \"MinimumUnits\": 10,
        \"ScalingPolicyUpdate\": {
          \"TargetTrackingScalingPolicyConfiguration\": {
            \"DisableScaleIn\": false,
            \"ScaleInCooldown\": 600,
            \"ScaleOutCooldown\": 600,
            \"TargetValue\": 70.0
          }
        }
      }
    }
  ],
  \"GlobalTableName\": \"Thread\",
  \"GlobalTableProvisionedWriteCapacityAutoScalingSettingsUpdate\": {
    \"MaximumUnits\": 20,
    \"MinimumUnits\": 10,
    \"ScalingPolicyUpdate\": {
      \"TargetTrackingScalingPolicyConfiguration\": {
        \"DisableScaleIn\": false,
        \"ScaleInCooldown\": 600,
        \"ScaleOutCooldown\": 600,
        \"TargetValue\": 70.0
      }
    }
  },
  \"ReplicaSettingsUpdate\": [
    {
      \"RegionName\": \"us-west-2\",
      \"ReplicaGlobalSecondaryIndexSettingsUpdate\": [
        {
          \"IndexName\": \"id-index\",
          \"ProvisionedReadCapacityAutoScalingSettingsUpdate\": {
            \"MaximumUnits\": 20,
            \"MinimumUnits\": 10,
            \"ScalingPolicyUpdate\": {
              \"TargetTrackingScalingPolicyConfiguration\": {
                \"DisableScaleIn\": false,
                \"ScaleInCooldown\": 600,
                \"ScaleOutCooldown\": 600,
                \"TargetValue\": 70.0
              }
            }
          }
        }
      ],
      \"ReplicaProvisionedReadCapacityAutoScalingSettingsUpdate\": {
        \"MaximumUnits\": 20,
        \"MinimumUnits\": 10,
        \"ScalingPolicyUpdate\": {
          \"TargetTrackingScalingPolicyConfiguration\": {
            \"DisableScaleIn\": false,
            \"ScaleInCooldown\": 600,
            \"ScaleOutCooldown\": 600,
            \"TargetValue\": 70.0
          }
        }
      }
    }
  ]
}"
              })],
    Response = "
{
  \"GlobalTableName\": \"Thread\",
  \"ReplicaSettings\": [
    {
      \"RegionName\": \"us-west-2\",
      \"ReplicaBillingModeSummary\": {
        \"BillingMode\": \"PROVISIONED\",
        \"LastUpdateToPayPerRequestDateTime\": 1578092745.455
      },
      \"ReplicaGlobalSecondaryIndexSettings\": [
        {
          \"IndexName\": \"id-index\",
          \"IndexStatus\": \"ACTIVE\",
          \"ProvisionedReadCapacityAutoScalingSettings\": {
            \"AutoScalingDisabled\": false,
            \"AutoScalingRoleArn\": \"arn:test\",
            \"MaximumUnits\": 20,
            \"MinimumUnits\": 10,
            \"ScalingPolicies\": [
              {
                \"PolicyName\": \"PolicyName\",
                \"TargetTrackingScalingPolicyConfiguration\": {
                  \"DisableScaleIn\": false,
                  \"ScaleInCooldown\": 600,
                  \"ScaleOutCooldown\": 600,
                  \"TargetValue\": 70.0
                }
              }
            ]
          },
          \"ProvisionedReadCapacityUnits\": 10,
          \"ProvisionedWriteCapacityAutoScalingSettings\": {
            \"AutoScalingDisabled\": false,
            \"AutoScalingRoleArn\": \"string\",
            \"MaximumUnits\": 20,
            \"MinimumUnits\": 10,
            \"ScalingPolicies\": [
              {
                \"PolicyName\": \"PolicyName\",
                \"TargetTrackingScalingPolicyConfiguration\": {
                  \"DisableScaleIn\": false,
                  \"ScaleInCooldown\": 600,
                  \"ScaleOutCooldown\": 600,
                  \"TargetValue\": 70.0
                }
              }
            ]
          },
          \"ProvisionedWriteCapacityUnits\": 10
        }
      ],
      \"ReplicaProvisionedReadCapacityAutoScalingSettings\": {
        \"AutoScalingDisabled\": false,
        \"AutoScalingRoleArn\": \"string\",
        \"MaximumUnits\": 20,
        \"MinimumUnits\": 10,
        \"ScalingPolicies\": [
          {
            \"PolicyName\": \"PolicyName\",
            \"TargetTrackingScalingPolicyConfiguration\": {
              \"DisableScaleIn\": false,
              \"ScaleInCooldown\": 600,
              \"ScaleOutCooldown\": 600,
              \"TargetValue\": 70.0
            }
          }
        ]
      },
      \"ReplicaProvisionedReadCapacityUnits\": 10,
      \"ReplicaProvisionedWriteCapacityAutoScalingSettings\": {
        \"AutoScalingDisabled\": false,
        \"AutoScalingRoleArn\": \"string\",
        \"MaximumUnits\": 20,
        \"MinimumUnits\": 10,
        \"ScalingPolicies\": [
          {
            \"PolicyName\": \"PolicyName\",
            \"TargetTrackingScalingPolicyConfiguration\": {
              \"DisableScaleIn\": false,
              \"ScaleInCooldown\": 600,
              \"ScaleOutCooldown\": 600,
              \"TargetValue\": 70.0
            }
          }
        ]
      },
      \"ReplicaProvisionedWriteCapacityUnits\": 10,
      \"ReplicaStatus\": \"ACTIVE\"
    }
  ]
}",
    input_tests(Response, Tests).

update_global_table_settings_output_tests(_) ->
    AutoScalingSettings = #ddb2_auto_scaling_settings_description{auto_scaling_disabled = false,
                                                                  auto_scaling_role_arn = <<"arn:test">>,
                                                                  maximum_units = 20,
                                                                  minimum_units = 10,
                                                                  scaling_policies = [#ddb2_auto_scaling_policy_description{policy_name = <<"PolicyName">>,
                                                                                                                            target_tracking_scaling_policy_configuration = #ddb2_auto_scaling_target_tracking_scaling_policy_configuration_description{disable_scale_in = false,
                                                                                                                                                                                                                                                       scale_in_cooldown = 600,
                                                                                                                                                                                                                                                       scale_out_cooldown = 600,
                                                                                                                                                                                                                                                       target_value = 70.0}}]},
    Tests =
        [?_ddb_test(
            {"UpdateGlobalTableSettings example response: update all read/write capacity to static values", "
{
  \"GlobalTableName\": \"Thread\",
  \"ReplicaSettings\": [
    {
      \"RegionName\": \"us-west-2\",
      \"ReplicaBillingModeSummary\": {
        \"BillingMode\": \"PROVISIONED\",
        \"LastUpdateToPayPerRequestDateTime\": 1578092745.455
      },
      \"ReplicaGlobalSecondaryIndexSettings\": [
        {
          \"IndexName\": \"id-index\",
          \"IndexStatus\": \"ACTIVE\",
          \"ProvisionedReadCapacityUnits\": 10,
          \"ProvisionedWriteCapacityUnits\": 10
        }
      ],
      \"ReplicaProvisionedReadCapacityUnits\": 10,
      \"ReplicaProvisionedWriteCapacityUnits\": 10,
      \"ReplicaStatus\": \"ACTIVE\"
    }
  ]
}",
             {ok, [#ddb2_replica_settings_description{region_name = <<"us-west-2">>,
                                                      replica_billing_mode_summary = #ddb2_billing_mode_summary{billing_mode = provisioned,
                                                                                                                last_update_to_pay_per_request_date_time = 1578092745.455},
                                                      replica_global_secondary_index_settings = [#ddb2_replica_global_secondary_index_settings_description{index_name = <<"id-index">>,
                                                                                                                                                           index_status = active,
                                                                                                                                                           provisioned_read_capacity_units = 10,
                                                                                                                                                           provisioned_write_capacity_units = 10}],
                                                      replica_provisioned_read_capacity_units = 10,
                                                      replica_provisioned_write_capacity_units = 10,
                                                      replica_status = active}]}}
        ),
         ?_ddb_test(
             {"UpdateGlobalTableSettings example response: update all read/write capacity to autoscale", "
{
  \"GlobalTableName\": \"Thread\",
  \"ReplicaSettings\": [
    {
      \"RegionName\": \"us-west-2\",
      \"ReplicaBillingModeSummary\": {
        \"BillingMode\": \"PROVISIONED\",
        \"LastUpdateToPayPerRequestDateTime\": 1578092745.455
      },
      \"ReplicaGlobalSecondaryIndexSettings\": [
        {
          \"IndexName\": \"id-index\",
          \"IndexStatus\": \"ACTIVE\",
          \"ProvisionedReadCapacityAutoScalingSettings\": {
            \"AutoScalingDisabled\": false,
            \"AutoScalingRoleArn\": \"arn:test\",
            \"MaximumUnits\": 20,
            \"MinimumUnits\": 10,
            \"ScalingPolicies\": [
              {
                \"PolicyName\": \"PolicyName\",
                \"TargetTrackingScalingPolicyConfiguration\": {
                  \"DisableScaleIn\": false,
                  \"ScaleInCooldown\": 600,
                  \"ScaleOutCooldown\": 600,
                  \"TargetValue\": 70.0
                }
              }
            ]
          },
          \"ProvisionedWriteCapacityAutoScalingSettings\": {
            \"AutoScalingDisabled\": false,
            \"AutoScalingRoleArn\": \"arn:test\",
            \"MaximumUnits\": 20,
            \"MinimumUnits\": 10,
            \"ScalingPolicies\": [
              {
                \"PolicyName\": \"PolicyName\",
                \"TargetTrackingScalingPolicyConfiguration\": {
                  \"DisableScaleIn\": false,
                  \"ScaleInCooldown\": 600,
                  \"ScaleOutCooldown\": 600,
                  \"TargetValue\": 70.0
                }
              }
            ]
          },
        }
      ],
      \"ReplicaProvisionedReadCapacityAutoScalingSettings\": {
        \"AutoScalingDisabled\": false,
        \"AutoScalingRoleArn\": \"arn:test\",
        \"MaximumUnits\": 20,
        \"MinimumUnits\": 10,
        \"ScalingPolicies\": [
          {
            \"PolicyName\": \"PolicyName\",
            \"TargetTrackingScalingPolicyConfiguration\": {
              \"DisableScaleIn\": false,
              \"ScaleInCooldown\": 600,
              \"ScaleOutCooldown\": 600,
              \"TargetValue\": 70.0
            }
          }
        ]
      },
      \"ReplicaProvisionedWriteCapacityAutoScalingSettings\": {
        \"AutoScalingDisabled\": false,
        \"AutoScalingRoleArn\": \"arn:test\",
        \"MaximumUnits\": 20,
        \"MinimumUnits\": 10,
        \"ScalingPolicies\": [
          {
            \"PolicyName\": \"PolicyName\",
            \"TargetTrackingScalingPolicyConfiguration\": {
              \"DisableScaleIn\": false,
              \"ScaleInCooldown\": 600,
              \"ScaleOutCooldown\": 600,
              \"TargetValue\": 70.0
            }
          }
        ]
      },
      \"ReplicaStatus\": \"ACTIVE\"
    }
  ]
}

",
              {ok, [#ddb2_replica_settings_description{region_name = <<"us-west-2">>,
                                                       replica_billing_mode_summary = #ddb2_billing_mode_summary{billing_mode = provisioned,
                                                                                                                 last_update_to_pay_per_request_date_time = 1578092745.455},
                                                       replica_global_secondary_index_settings = [#ddb2_replica_global_secondary_index_settings_description{index_name = <<"id-index">>,
                                                                                                                                                            index_status = active,
                                                                                                                                                            provisioned_read_capacity_auto_scaling_settings = AutoScalingSettings,
                                                                                                                                                            provisioned_write_capacity_auto_scaling_settings = AutoScalingSettings}],
                                                       replica_provisioned_read_capacity_auto_scaling_settings = AutoScalingSettings,
                                                       replica_provisioned_write_capacity_auto_scaling_settings = AutoScalingSettings,
                                                       replica_status = active}]}}
         )],
    output_tests(?_f(erlcloud_ddb2:update_global_table_settings(<<"Thread">>, [])), Tests).

%% UpdateTable test based on the API examples:
%% http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_UpdateTable.html
update_table_input_tests(_) ->
    Tests =
        [?_ddb_test(
            {"UpdateTable example request: update provisioned throughput on table and global secondary index",
             ?_f(erlcloud_ddb2:update_table(<<"Thread">>, 10, 10,
                                            [{global_secondary_index_updates, [{<<"SubjectIdx">>, 30, 40}]}])), "
{
    \"TableName\": \"Thread\",
    \"GlobalSecondaryIndexUpdates\": [
        {
            \"Update\": {
                \"IndexName\": \"SubjectIdx\",
                \"ProvisionedThroughput\": {
                    \"ReadCapacityUnits\": 30,
                    \"WriteCapacityUnits\": 40
                }
            }
        }
    ],
    \"ProvisionedThroughput\": {
        \"ReadCapacityUnits\": 10,
        \"WriteCapacityUnits\": 10
    }
}"
            }),
         ?_ddb_test(
            {"UpdateTable example request: create new global secondary index",
             ?_f(erlcloud_ddb2:update_table(<<"Thread">>,
                                            [{attribute_definitions, [{<<"ForumType">>, s}]},
                                             {provisioned_throughput, {10, 10}},
                                             {global_secondary_index_updates, [{<<"ForumTypeIdx">>, {<<"ForumType">>, <<"LastPostDateTime">>}, keys_only, 60, 90}]}])), "
{
    \"TableName\": \"Thread\",
    \"AttributeDefinitions\": [
        {
            \"AttributeName\": \"ForumType\",
            \"AttributeType\": \"S\"
        }
    ],
    \"GlobalSecondaryIndexUpdates\": [
        {
            \"Create\": {
                \"IndexName\": \"ForumTypeIdx\",
                \"KeySchema\": [
                    {
                        \"AttributeName\": \"ForumType\",
                        \"KeyType\": \"HASH\"
                    },
                    {
                        \"AttributeName\": \"LastPostDateTime\",
                        \"KeyType\": \"RANGE\"
                    }
                ],
                \"Projection\": {
                    \"ProjectionType\": \"KEYS_ONLY\"
                },
                \"ProvisionedThroughput\": {
                    \"ReadCapacityUnits\": 60,
                    \"WriteCapacityUnits\": 90
                }
            }
        }
    ],
    \"ProvisionedThroughput\": {
        \"ReadCapacityUnits\": 10,
        \"WriteCapacityUnits\": 10
    }
}"
            }),
         ?_ddb_test(
            {"UpdateTable example request: delete global secondary index",
             ?_f(erlcloud_ddb2:update_table(<<"Thread">>,
                                            [{global_secondary_index_updates, [{<<"ForumTypeIdx">>, delete}]}])), "
{
    \"TableName\": \"Thread\",
    \"GlobalSecondaryIndexUpdates\": [
        {
            \"Delete\": {
                \"IndexName\": \"ForumTypeIdx\"
            }
        }
    ]
}"
            }),
        ?_ddb_test(
            {"UpdateTable example request with Create and Delete GSI",
             ?_f(erlcloud_ddb2:update_table(<<"Thread">>, 10, 10,
                                            [{attribute_definitions, [{<<"HashKey1">>, s}]},
                                             {global_secondary_index_updates, [
                                                {<<"Index1">>, <<"HashKey1">>, all, 30, 40},
                                                {<<"Index2">>, delete}]}])), "
{
    \"TableName\": \"Thread\",
    \"ProvisionedThroughput\": {
        \"ReadCapacityUnits\": 10,
        \"WriteCapacityUnits\": 10
    },
    \"AttributeDefinitions\": [
        {
            \"AttributeName\": \"HashKey1\",
            \"AttributeType\": \"S\"
        }
    ],
    \"GlobalSecondaryIndexUpdates\": [
        {
            \"Create\": {
                \"IndexName\": \"Index1\",
                \"KeySchema\": [
                    {
                        \"AttributeName\": \"HashKey1\",
                        \"KeyType\": \"HASH\"
                    }
                ],
                \"Projection\": {
                    \"ProjectionType\": \"ALL\"
                },
                \"ProvisionedThroughput\": {
                    \"ReadCapacityUnits\": 30,
                    \"WriteCapacityUnits\": 40
                }
            }
        },
        {
            \"Delete\": {
                \"IndexName\": \"Index2\"
            }
        }
    ]
}"
            }),
        ?_ddb_test(
            {"UpdateTable example request with new provisioned_throughput opt",
             ?_f(erlcloud_ddb2:update_table(<<"Thread">>,
                                            [{provisioned_throughput, {10, 10}}])), "
{
    \"TableName\": \"Thread\",
    \"ProvisionedThroughput\": {
        \"ReadCapacityUnits\": 10,
        \"WriteCapacityUnits\": 10
    }
}"
            }),
        ?_ddb_test(
            {"UpdateTable example request with Create and Delete GSI",
             ?_f(erlcloud_ddb2:update_table(<<"Thread">>,
                                            [{attribute_definitions, [{<<"HashKey1">>, s}]},
                                             {global_secondary_index_updates, [
                                                {<<"Index1">>, <<"HashKey1">>, all, 30, 40},
                                                {<<"Index2">>, delete}]}])), "
{
    \"TableName\": \"Thread\",
    \"AttributeDefinitions\": [
        {
            \"AttributeName\": \"HashKey1\",
            \"AttributeType\": \"S\"
        }
    ],
    \"GlobalSecondaryIndexUpdates\": [
        {
            \"Create\": {
                \"IndexName\": \"Index1\",
                \"KeySchema\": [
                    {
                        \"AttributeName\": \"HashKey1\",
                        \"KeyType\": \"HASH\"
                    }
                ],
                \"Projection\": {
                    \"ProjectionType\": \"ALL\"
                },
                \"ProvisionedThroughput\": {
                    \"ReadCapacityUnits\": 30,
                    \"WriteCapacityUnits\": 40
                }
            }
        },
        {
            \"Delete\": {
                \"IndexName\": \"Index2\"
            }
        }
    ]
}"
            }),
        ?_ddb_test(
            {"UpdateTable example request with Create GSI (pay per request)",
             ?_f(erlcloud_ddb2:update_table(<<"Thread">>,
                                            [{attribute_definitions, [{<<"HashKey1">>, s}]},
                                             {global_secondary_index_updates, [
                                                {<<"Index1">>, <<"HashKey1">>, all}]}])), "
{
    \"TableName\": \"Thread\",
    \"AttributeDefinitions\": [
        {
            \"AttributeName\": \"HashKey1\",
            \"AttributeType\": \"S\"
        }
    ],
    \"GlobalSecondaryIndexUpdates\": [
        {
            \"Create\": {
                \"IndexName\": \"Index1\",
                \"KeySchema\": [
                    {
                        \"AttributeName\": \"HashKey1\",
                        \"KeyType\": \"HASH\"
                    }
                ],
                \"Projection\": {
                    \"ProjectionType\": \"ALL\"
                }
            }
        }
    ]
}"
            }),
        ?_ddb_test(
            {"UpdateTable example request billing_mode = pay_per_request",
             ?_f(erlcloud_ddb2:update_table(<<"Thread">>,
                                            [{billing_mode, pay_per_request}])), "
{
    \"TableName\": \"Thread\",
    \"BillingMode\": \"PAY_PER_REQUEST\"
}"
            }),
        ?_ddb_test(
            {"UpdateTable example request deletion_protection_enabled = false",
             ?_f(erlcloud_ddb2:update_table(<<"Thread">>,
                                            [{deletion_protection_enabled, false}])), "
{
    \"TableName\": \"Thread\",
    \"DeletionProtectionEnabled\": false
}"
            })
        ],

    Response = "
{
    \"TableDescription\": {
        \"AttributeDefinitions\": [
            {
                \"AttributeName\": \"ForumName\",
                \"AttributeType\": \"S\"
            },
            {
                \"AttributeName\": \"LastPostDateTime\",
                \"AttributeType\": \"S\"
            },
            {
                \"AttributeName\": \"Subject\",
                \"AttributeType\": \"S\"
            }
        ],
        \"CreationDateTime\": 1.363801528686E9,
        \"ItemCount\": 0,
        \"KeySchema\": [
            {
                \"AttributeName\": \"ForumName\",
                \"KeyType\": \"HASH\"
            },
            {
                \"AttributeName\": \"Subject\",
                \"KeyType\": \"RANGE\"
            }
        ],
        \"LocalSecondaryIndexes\": [
            {
                \"IndexName\": \"LastPostIndex\",
                \"IndexSizeBytes\": 0,
                \"ItemCount\": 0,
                \"KeySchema\": [
                    {
                        \"AttributeName\": \"ForumName\",
                        \"KeyType\": \"HASH\"
                    },
                    {
                        \"AttributeName\": \"LastPostDateTime\",
                        \"KeyType\": \"RANGE\"
                    }
                ],
                \"Projection\": {
                    \"ProjectionType\": \"KEYS_ONLY\"
                }
            }
        ],
        \"ProvisionedThroughput\": {
            \"LastIncreaseDateTime\": 1.363801701282E9,
            \"NumberOfDecreasesToday\": 0,
            \"ReadCapacityUnits\": 5,
            \"WriteCapacityUnits\": 5
        },
        \"TableName\": \"Thread\",
        \"TableSizeBytes\": 0,
        \"TableStatus\": \"UPDATING\"
    }
}",
    input_tests(Response, Tests).

update_table_output_tests(_) ->
    Tests =
        [?_ddb_test(
            {"UpdateTable example response", "
{
    \"TableDescription\": {
        \"AttributeDefinitions\": [
            {
                \"AttributeName\": \"ForumName\",
                \"AttributeType\": \"S\"
            },
            {
                \"AttributeName\": \"LastPostDateTime\",
                \"AttributeType\": \"S\"
            },
            {
                \"AttributeName\": \"Subject\",
                \"AttributeType\": \"S\"
            }
        ],
        \"GlobalSecondaryIndexes\": [
            {
                \"IndexName\": \"SubjectIndex\",
                \"IndexSizeBytes\": 2048,
                \"IndexStatus\": \"CREATING\",
                \"ItemCount\": 47,
                \"KeySchema\": [
                    {
                        \"AttributeName\": \"Subject\",
                        \"KeyType\": \"HASH\"
                    },
                    {
                        \"AttributeName\": \"LastPostDateTime\",
                        \"KeyType\": \"RANGE\"
                    }
                ],
                \"Projection\": {
                    \"NonKeyAttributes\" : [
                        \"Author\"
                    ],
                    \"ProjectionType\": \"INCLUDE\"
                },
                \"ProvisionedThroughput\": {
                    \"LastDecreaseDateTime\": 0,
                    \"LastIncreaseDateTime\": 1,
                    \"NumberOfDecreasesToday\": 2,
                    \"ReadCapacityUnits\": 3,
                    \"WriteCapacityUnits\": 4
                }
            }
        ],
        \"CreationDateTime\": 1.363801528686E9,
        \"ItemCount\": 0,
        \"KeySchema\": [
            {
                \"AttributeName\": \"ForumName\",
                \"KeyType\": \"HASH\"
            },
            {
                \"AttributeName\": \"Subject\",
                \"KeyType\": \"RANGE\"
            }
        ],
        \"LocalSecondaryIndexes\": [
            {
                \"IndexName\": \"LastPostIndex\",
                \"IndexSizeBytes\": 0,
                \"ItemCount\": 0,
                \"KeySchema\": [
                    {
                        \"AttributeName\": \"ForumName\",
                        \"KeyType\": \"HASH\"
                    },
                    {
                        \"AttributeName\": \"LastPostDateTime\",
                        \"KeyType\": \"RANGE\"
                    }
                ],
                \"Projection\": {
                    \"ProjectionType\": \"KEYS_ONLY\"
                }
            }
        ],
        \"ProvisionedThroughput\": {
            \"LastIncreaseDateTime\": 1.363801701282E9,
            \"NumberOfDecreasesToday\": 0,
            \"ReadCapacityUnits\": 5,
            \"WriteCapacityUnits\": 5
        },
        \"TableName\": \"Thread\",
        \"TableSizeBytes\": 0,
        \"TableStatus\": \"UPDATING\"
    }
}",
             {ok, #ddb2_table_description
              {attribute_definitions = [{<<"ForumName">>, s},
                                        {<<"LastPostDateTime">>, s},
                                        {<<"Subject">>, s}],
               creation_date_time = 1363801528.686,
               item_count = 0,
               key_schema = {<<"ForumName">>, <<"Subject">>},
               local_secondary_indexes =
                   [#ddb2_local_secondary_index_description{
                       index_name = <<"LastPostIndex">>,
                       index_size_bytes = 0,
                       item_count = 0,
                       key_schema = {<<"ForumName">>, <<"LastPostDateTime">>},
                       projection = keys_only}],
               global_secondary_indexes =
                   [#ddb2_global_secondary_index_description{
                       index_name = <<"SubjectIndex">>,
                       index_size_bytes = 2048,
                       index_status = creating,
                       item_count = 47,
                       key_schema = {<<"Subject">>, <<"LastPostDateTime">>},
                       projection = {include, [<<"Author">>]},
                       provisioned_throughput = #ddb2_provisioned_throughput_description{
                          last_decrease_date_time = 0,
                          last_increase_date_time = 1,
                          number_of_decreases_today = 2,
                          read_capacity_units = 3,
                          write_capacity_units = 4}
                    }],
               provisioned_throughput =
                   #ddb2_provisioned_throughput_description{
                      last_decrease_date_time = undefined,
                      last_increase_date_time = 1363801701.282,
                      number_of_decreases_today = 0,
                      read_capacity_units = 5,
                      write_capacity_units = 5},
               table_name = <<"Thread">>,
               table_size_bytes = 0,
               table_status = updating}}})
        ],

    output_tests(?_f(erlcloud_ddb2:update_table(<<"name">>, 5, 15)), Tests).

update_table_replica_auto_scaling_input_tests(_) ->
    AutoScalingSettingsUpdate = [{auto_scaling_disabled, false},
                                 {auto_scaling_role_arn, <<"arn:test">>},
                                 {maximum_units, 20},
                                 {minimum_units, 10},
                                 {scaling_policy_update, [{policy_name, <<"PolicyName">>},
                                                          {target_tracking_scaling_policy_configuration, [{disable_scale_in, false},
                                                                                                         {scale_in_cooldown, 600},
                                                                                                         {scale_out_cooldown, 600},
                                                                                                         {target_value, 70.0}]}]}],
    Opts = [{global_secondary_index_updates, [[{index_name, <<"id-index">>},
                                               {provisioned_write_capacity_auto_scaling_update, AutoScalingSettingsUpdate}]]},
            {provisioned_write_capacity_auto_scaling_update, AutoScalingSettingsUpdate},
            {replica_updates, [[{region_name, <<"us-west-2">>},
                                {replica_global_secondary_index_updates, [[{index_name, <<"id-index">>},
                                                                           {provisioned_read_capacity_auto_scaling_update, AutoScalingSettingsUpdate}]]},
                                {replica_provisioned_read_capacity_auto_scaling_update, AutoScalingSettingsUpdate}]]}],
    Tests =
        [?_ddb_test({"UpdateTableReplicaAutoScaling example request",
                     ?_f(erlcloud_ddb2:update_table_replica_auto_scaling(<<"Thread">>, Opts)),
                     "
{
  \"GlobalSecondaryIndexUpdates\": [
    {
      \"IndexName\": \"id-index\",
      \"ProvisionedWriteCapacityAutoScalingUpdate\": {
        \"AutoScalingDisabled\": false,
        \"AutoScalingRoleArn\": \"arn:test\",
        \"MaximumUnits\": 20,
        \"MinimumUnits\": 10,
        \"ScalingPolicyUpdate\": {
          \"PolicyName\": \"PolicyName\",
          \"TargetTrackingScalingPolicyConfiguration\": {
            \"DisableScaleIn\": false,
            \"ScaleInCooldown\": 600,
            \"ScaleOutCooldown\": 600,
            \"TargetValue\": 70.0
          }
        }
      }
    }
  ],
  \"ProvisionedWriteCapacityAutoScalingUpdate\": {
    \"AutoScalingDisabled\": false,
    \"AutoScalingRoleArn\": \"arn:test\",
    \"MaximumUnits\": 20,
    \"MinimumUnits\": 10,
    \"ScalingPolicyUpdate\": {
      \"PolicyName\": \"PolicyName\",
      \"TargetTrackingScalingPolicyConfiguration\": {
        \"DisableScaleIn\": false,
        \"ScaleInCooldown\": 600,
        \"ScaleOutCooldown\": 600,
        \"TargetValue\": 70.0
      }
    }
  },
  \"ReplicaUpdates\": [
    {
      \"RegionName\": \"us-west-2\",
      \"ReplicaGlobalSecondaryIndexUpdates\": [
        {
          \"IndexName\": \"id-index\",
          \"ProvisionedReadCapacityAutoScalingUpdate\": {
            \"AutoScalingDisabled\": false,
            \"AutoScalingRoleArn\": \"arn:test\",
            \"MaximumUnits\": 20,
            \"MinimumUnits\": 10,
            \"ScalingPolicyUpdate\": {
              \"PolicyName\": \"PolicyName\",
              \"TargetTrackingScalingPolicyConfiguration\": {
                \"DisableScaleIn\": false,
                \"ScaleInCooldown\": 600,
                \"ScaleOutCooldown\": 600,
                \"TargetValue\": 70.0
              }
            }
          }
        }
      ],
      \"ReplicaProvisionedReadCapacityAutoScalingUpdate\": {
        \"AutoScalingDisabled\": false,
        \"AutoScalingRoleArn\": \"arn:test\",
        \"MaximumUnits\": 20,
        \"MinimumUnits\": 10,
        \"ScalingPolicyUpdate\": {
          \"PolicyName\": \"PolicyName\",
          \"TargetTrackingScalingPolicyConfiguration\": {
            \"DisableScaleIn\": false,
            \"ScaleInCooldown\": 600,
            \"ScaleOutCooldown\": 600,
            \"TargetValue\": 70.0
          }
        }
      }
    }
  ],
  \"TableName\": \"Thread\"
}

"})],

    Response = "
{
  \"TableAutoScalingDescription\": {
    \"Replicas\": [
      {
        \"GlobalSecondaryIndexes\": [
          {
            \"IndexName\": \"id-index\",
            \"IndexStatus\": \"ACTIVE\",
            \"ProvisionedReadCapacityAutoScalingSettings\": {
              \"AutoScalingDisabled\": false,
              \"AutoScalingRoleArn\": \"arn:test\",
              \"MaximumUnits\": 20,
              \"MinimumUnits\": 10,
              \"ScalingPolicies\": [
                {
                  \"PolicyName\": \"PolicyName\",
                  \"TargetTrackingScalingPolicyConfiguration\": {
                    \"DisableScaleIn\": false,
                    \"ScaleInCooldown\": 600,
                    \"ScaleOutCooldown\": 600,
                    \"TargetValue\": 70.0
                  }
                }
              ]
            },
            \"ProvisionedWriteCapacityAutoScalingSettings\": {
              \"AutoScalingDisabled\": false,
              \"AutoScalingRoleArn\": \"arn:test\",
              \"MaximumUnits\": 20,
              \"MinimumUnits\": 10,
              \"ScalingPolicies\": [
                {
                  \"PolicyName\": \"PolicyName\",
                  \"TargetTrackingScalingPolicyConfiguration\": {
                    \"DisableScaleIn\": false,
                    \"ScaleInCooldown\": 600,
                    \"ScaleOutCooldown\": 600,
                    \"TargetValue\": 70.0
                  }
                }
              ]
            }
          }
        ],
        \"RegionName\": \"us-west-2\",
        \"ReplicaProvisionedReadCapacityAutoScalingSettings\": {
          \"AutoScalingDisabled\": false,
          \"AutoScalingRoleArn\": \"arn:test\",
          \"MaximumUnits\": 20,
          \"MinimumUnits\": 10,
          \"ScalingPolicies\": [
            {
              \"PolicyName\": \"PolicyName\",
              \"TargetTrackingScalingPolicyConfiguration\": {
                \"DisableScaleIn\": false,
                \"ScaleInCooldown\": 600,
                \"ScaleOutCooldown\": 600,
                \"TargetValue\": 70.0
              }
            }
          ]
        },
        \"ReplicaProvisionedWriteCapacityAutoScalingSettings\": {
          \"AutoScalingDisabled\": false,
          \"AutoScalingRoleArn\": \"arn:test\",
          \"MaximumUnits\": 20,
          \"MinimumUnits\": 10,
          \"ScalingPolicies\": [
            {
              \"PolicyName\": \"PolicyName\",
              \"TargetTrackingScalingPolicyConfiguration\": {
                \"DisableScaleIn\": false,
                \"ScaleInCooldown\": 600,
                \"ScaleOutCooldown\": 600,
                \"TargetValue\": 70.0
              }
            }
          ]
        },
        \"ReplicaStatus\": \"ACTIVE\"
      }
    ],
    \"TableName\": \"Thread\",
    \"TableStatus\": \"ACTIVE\"
  }
}",
    input_tests(Response, Tests).

update_table_replica_auto_scaling_output_tests(_) ->
    AutoScalingSettings = #ddb2_auto_scaling_settings_description{auto_scaling_disabled = false,
                                                                  auto_scaling_role_arn = <<"arn:test">>,
                                                                  maximum_units = 20,
                                                                  minimum_units = 10,
                                                                  scaling_policies = [#ddb2_auto_scaling_policy_description{policy_name = <<"PolicyName">>,
                                                                                                                            target_tracking_scaling_policy_configuration = #ddb2_auto_scaling_target_tracking_scaling_policy_configuration_description{disable_scale_in = false,
                                                                                                                                                                                                                                                       scale_in_cooldown = 600,
                                                                                                                                                                                                                                                       scale_out_cooldown = 600,
                                                                                                                                                                                                                                                       target_value = 70.0}}]},
    Tests =
        [?_ddb_test(
            {"UpdateTableReplicaAutoScaling example", "
{
  \"TableAutoScalingDescription\": {
    \"Replicas\": [
      {
        \"GlobalSecondaryIndexes\": [
          {
            \"IndexName\": \"id-index\",
            \"IndexStatus\": \"ACTIVE\",
            \"ProvisionedReadCapacityAutoScalingSettings\": {
              \"AutoScalingDisabled\": false,
              \"AutoScalingRoleArn\": \"arn:test\",
              \"MaximumUnits\": 20,
              \"MinimumUnits\": 10,
              \"ScalingPolicies\": [
                {
                  \"PolicyName\": \"PolicyName\",
                  \"TargetTrackingScalingPolicyConfiguration\": {
                    \"DisableScaleIn\": false,
                    \"ScaleInCooldown\": 600,
                    \"ScaleOutCooldown\": 600,
                    \"TargetValue\": 70.0
                  }
                }
              ]
            },
            \"ProvisionedWriteCapacityAutoScalingSettings\": {
              \"AutoScalingDisabled\": false,
              \"AutoScalingRoleArn\": \"arn:test\",
              \"MaximumUnits\": 20,
              \"MinimumUnits\": 10,
              \"ScalingPolicies\": [
                {
                  \"PolicyName\": \"PolicyName\",
                  \"TargetTrackingScalingPolicyConfiguration\": {
                    \"DisableScaleIn\": false,
                    \"ScaleInCooldown\": 600,
                    \"ScaleOutCooldown\": 600,
                    \"TargetValue\": 70.0
                  }
                }
              ]
            }
          }
        ],
        \"RegionName\": \"us-west-2\",
        \"ReplicaProvisionedReadCapacityAutoScalingSettings\": {
          \"AutoScalingDisabled\": false,
          \"AutoScalingRoleArn\": \"arn:test\",
          \"MaximumUnits\": 20,
          \"MinimumUnits\": 10,
          \"ScalingPolicies\": [
            {
              \"PolicyName\": \"PolicyName\",
              \"TargetTrackingScalingPolicyConfiguration\": {
                \"DisableScaleIn\": false,
                \"ScaleInCooldown\": 600,
                \"ScaleOutCooldown\": 600,
                \"TargetValue\": 70.0
              }
            }
          ]
        },
        \"ReplicaProvisionedWriteCapacityAutoScalingSettings\": {
          \"AutoScalingDisabled\": false,
          \"AutoScalingRoleArn\": \"arn:test\",
          \"MaximumUnits\": 20,
          \"MinimumUnits\": 10,
          \"ScalingPolicies\": [
            {
              \"PolicyName\": \"PolicyName\",
              \"TargetTrackingScalingPolicyConfiguration\": {
                \"DisableScaleIn\": false,
                \"ScaleInCooldown\": 600,
                \"ScaleOutCooldown\": 600,
                \"TargetValue\": 70.0
              }
            }
          ]
        },
        \"ReplicaStatus\": \"ACTIVE\"
      }
    ],
    \"TableName\": \"Thread\",
    \"TableStatus\": \"ACTIVE\"
  }
}",
             {ok, #ddb2_table_auto_scaling_description{replicas = [#ddb2_replica_auto_scaling_description{global_secondary_indexes = [#ddb2_replica_global_secondary_index_auto_scaling_description{index_name = <<"id-index">>,
                                                                                                                                                                                                    index_status = active,
                                                                                                                                                                                                    provisioned_read_capacity_auto_scaling_settings = AutoScalingSettings,
                                                                                                                                                                                                    provisioned_write_capacity_auto_scaling_settings = AutoScalingSettings}],
                                                                                                          region_name = <<"us-west-2">>,
                                                                                                          replica_provisioned_read_capacity_auto_scaling_settings = AutoScalingSettings,
                                                                                                          replica_provisioned_write_capacity_auto_scaling_settings = AutoScalingSettings,
                                                                                                          replica_status = active}],
                                                       table_name = <<"Thread">>,
                                                       table_status = active}}
})],
    output_tests(?_f(erlcloud_ddb2:update_table_replica_auto_scaling(<<"Thread">>, [])), Tests).

%% UpdateTimeToLive test:
update_time_to_live_input_tests(_) ->
    Tests =
          [?_ddb_test(
              {"UpdateTimeToLive example request: enable TTL for table",
               ?_f(erlcloud_ddb2:update_time_to_live(<<"SessionData">>, [{attribute_name, <<"ExpirationTime">>}, {enabled, true}])), "
{
    \"TableName\": \"SessionData\",
    \"TimeToLiveSpecification\": {
        \"AttributeName\": \"ExpirationTime\",
        \"Enabled\": true
    }
}"
              }),
           ?_ddb_test(
              {"UpdateTimeToLive example request: disable TTL for table",
               ?_f(erlcloud_ddb2:update_time_to_live(<<"SessionData">>, [{attribute_name, <<"ExpirationTime">>}, {enabled, false}])), "
{
    \"TableName\": \"SessionData\",
    \"TimeToLiveSpecification\": {
        \"AttributeName\": \"ExpirationTime\",
        \"Enabled\": false
    }
}"
            })],
      Response = "
{
    \"TimeToLiveSpecification\": {
        \"AttributeName\": \"ExpirationTime\",
        \"Enabled\": true
    }
}",
      input_tests(Response, Tests).

%% UpdateTimeToLive test:
update_time_to_live_output_tests(_) ->
    Tests =
        [?_ddb_test(
            {"UpdateTimeToLive example response", "
{
    \"TimeToLiveSpecification\": {
        \"AttributeName\": \"ExpirationTime\",
        \"Enabled\": true
    }
}",
              {ok, #ddb2_time_to_live_specification{
                attribute_name = <<"ExpirationTime">>,
                enabled = true}}})],
    output_tests(?_f(erlcloud_ddb2:update_time_to_live(<<"SessionData">>,
      [{attribute_name, <<"ExpirationTime">>}, {enabled, true}])), Tests).
