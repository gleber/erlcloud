%% -*- mode: erlang;erlang-indent-level: 4;indent-tabs-mode: nil -*-

%% @author Ransom Richardson <ransom@ransomr.net>
%% @doc
%% An Erlang interface to Amazon's DynamoDB.
%%
%% [http://docs.aws.amazon.com/amazondynamodb/latest/developerguide/operationlist.html]
%%
%% erlcloud_ddb2 implements the entire 20120810 API.
%%
%% Method names match DynamoDB operations converted to
%% lower_case_with_underscores. The one exception is query, which is
%% an Erlang reserved word. The `q' method implements Query.
%%
%% Required parameters are passed as function arguments. In addition
%% all methods take an options proplist argument which can be used to
%% pass optional parameters. See function documentation for examples.
%%
%% Table names, key names, attribute names and any other input strings
%% except attribute values must be binary strings.
%%
%% Attribute values may be either `{Type, Value}' or `Value'. If only
%% `Value' is provided then the type is inferred. Lists (iolists are
%% handled), binaries and atoms are assumed to be strings. The following are
%% equivalent: `{s, <<"value">>}', `<<"value">>', `"value"', `value'. Numbers
%% are assumed to be numbers. The following are equivalent: `{n, 42}',
%% `42'. To specify the AWS binary or set types an explicit `Type'
%% must be provided. For example: `{b, <<1,2,3>>}' or `{ns,
%% [4,5,6]}'. Note that binary values will be base64 encoded and
%% decoded automatically. Since some atoms (such as `true', `false', `not_null',
%% `null', `undefined', `delete', etc) have special meanings in some cases,
%% use them carefully.
%%
%% Output is in the form of `{ok, Value}' or `{error, Reason}'. The
%% format of `Value' is controlled by the `out' option, which defaults
%% to `simple'. The possible values are: 
%%
%% * `simple' - The most interesting part of the output. For example
%% `get_item' will return the item.
%%
%% * `record' - A record containing all the information from the
%% DynamoDB response except field types. This is useful if you need more detailed
%% information than what is returned with `simple'. For example, with
%% `scan' and `query' the record will contain the last evaluated key
%% which can be used to continue the operation.
%%
%% * `typed_record' - A record containing all the information from the
%% DynamoDB response. All field values are returned with type information.
%%
%% * `json' - The output from DynamoDB as processed by `jsx:decode'
%% but with no further manipulation. This would rarely be useful,
%% unless the DynamoDB API is updated to include data that is not yet
%% parsed correctly.
%%
%% Items will be returned as a list of `{Name, Value}'. In most cases
%% the output will have type information removed. For example:
%% `[{<<"String Attribute">>, <<"value">>}, {<<"Number Attribute">>,
%% 42}, {<<"BinaryAttribute">>, <<1,2,3>>}]'. The exception is for
%% output fields that are intended to be passed to a subsequent call,
%% such as `unprocessed_keys' and `last_evaluated_key'. Those will
%% contain typed attribute values so that they may be correctly passed
%% to subsequent calls.
%%
%% DynamoDB errors for most cases are returned in the form
%% `{error, {ErrorCode, Message}}' where `ErrorCode' and `Message' are both binary
%% strings. List of error codes:
%% [http://docs.aws.amazon.com/amazondynamodb/latest/developerguide/ErrorHandling.html]. So
%% to handle conditional check failures, match `{error,
%% {<<"ConditionalCheckFailedException">>, _}}'.
%% Note that in the case of a `TransactionCanceledException' DynamoDB error,
%% the error response has the form `{error, {<<"TransactionCanceledException">>,
%% {Message, CancellationReasons}}}' where `Message' is a binary string and
%% `CancellationReasons' is an ordered list in the form `[{Code, Message}]',
%% where `Code' is the status code of the result and `Message' is the cancellation
%% reason message description.
%%
%% `erlcloud_ddb_util' provides a higher level API that implements common
%% operations that may require multiple DynamoDB API calls.
%%
%% See the unit tests for additional usage examples beyond what are
%% provided for each function.
%%
%% @end

-module(erlcloud_ddb2).

-include("erlcloud.hrl").
-include("erlcloud_aws.hrl").
-include("erlcloud_ddb2.hrl").

%%% Library initialization.
-export([configure/2, configure/3, configure/4, configure/5,
         new/2, new/3, new/4, new/5]).

%%% DynamoDB API
-export([batch_get_item/1, batch_get_item/2, batch_get_item/3,
         batch_write_item/1, batch_write_item/2, batch_write_item/3,
         create_backup/2, create_backup/3, create_backup/4,
         create_global_table/2, create_global_table/3, create_global_table/4,
         create_table/4, create_table/5, create_table/6, create_table/7,
         delete_backup/1, delete_backup/2, delete_backup/3,
         delete_item/2, delete_item/3, delete_item/4,
         delete_table/1, delete_table/2, delete_table/3,
         describe_backup/1, describe_backup/2, describe_backup/3,
         describe_continuous_backups/1, describe_continuous_backups/2, describe_continuous_backups/3,
         describe_global_table/1, describe_global_table/2, describe_global_table/3,
         describe_global_table_settings/1, describe_global_table_settings/2, describe_global_table_settings/3,
         describe_limits/0, describe_limits/1, describe_limits/2,
         describe_table/1, describe_table/2, describe_table/3,
         describe_table_replica_auto_scaling/1, describe_table_replica_auto_scaling/2, describe_table_replica_auto_scaling/3,
         describe_time_to_live/1, describe_time_to_live/2, describe_time_to_live/3,
         get_item/2, get_item/3, get_item/4,
         list_backups/0, list_backups/1, list_backups/2,
         list_global_tables/0, list_global_tables/1, list_global_tables/2,
         list_tables/0, list_tables/1, list_tables/2,
         list_tags_of_resource/1, list_tags_of_resource/2, list_tags_of_resource/3,
         put_item/2, put_item/3, put_item/4,
         %% Note that query is a Erlang reserved word, so we use q instead
         q/2, q/3, q/4,
         restore_table_from_backup/2, restore_table_from_backup/3, restore_table_from_backup/4,
         restore_table_to_point_in_time/2, restore_table_to_point_in_time/3, restore_table_to_point_in_time/4,
         scan/1, scan/2, scan/3,
         tag_resource/2, tag_resource/3,
         transact_get_items/1, transact_get_items/2, transact_get_items/3,
         transact_write_items/1, transact_write_items/2, transact_write_items/3,
         untag_resource/2, untag_resource/3,
         update_continuous_backups/2, update_continuous_backups/3, update_continuous_backups/4,
         update_item/3, update_item/4, update_item/5,
         update_global_table/2, update_global_table/3, update_global_table/4,
         update_global_table_settings/2, update_global_table_settings/3,
         update_table/2, update_table/3, update_table/4, update_table/5,
         update_table_replica_auto_scaling/2, update_table_replica_auto_scaling/3,
         update_time_to_live/2, update_time_to_live/3, update_time_to_live/4
        ]).

-export_type(
   [attr_defs/0,
    attr_name/0,
    attr_type/0,
    attributes_to_get_opt/0,
    batch_get_item_opt/0,
    batch_get_item_opts/0,
    batch_get_item_request_item/0,
    batch_get_item_request_item_opt/0,
    batch_get_item_request_item_opts/0,
    batch_get_item_return/0,
    batch_write_item_delete/0,
    batch_write_item_opt/0,
    batch_write_item_opts/0,
    batch_write_item_put/0,
    batch_write_item_request/0,
    batch_write_item_request_item/0,
    batch_write_item_return/0,
    boolean_opt/1,
    billing_mode/0,
    comparison_op/0,
    condition/0,
    conditional_op/0,
    conditional_op_opt/0,
    conditions/0,
    consistent_read_opt/0,
    create_table_opt/0,
    create_table_opts/0,
    create_table_return/0,
    ddb_opts/0,
    ddb_return/2,
    delete_item_opt/0,
    delete_item_opts/0,
    delete_item_return/0,
    delete_table_return/0,
    deletion_protection_enabled/0,
    describe_global_table_return/0,
    describe_global_table_settings_return/0,
    describe_table_return/0,
    describe_table_replica_auto_scaling_return/0,
    describe_time_to_live_return/0,
    expected_opt/0,
    expression/0,
    expression_attribute_names/0,
    expression_attribute_values/0,
    get_item_opt/0,
    get_item_opts/0,
    get_item_return/0,
    global_secondary_index_def/0,
    global_secondary_index_update/0,
    global_secondary_index_updates/0,
    in_attr/0,
    in_attr_value/0,
    in_expected/0,
    in_expected_item/0,
    in_item/0,
    in_update/0,
    in_updates/0,
    index_name/0,
    key/0,
    key_schema/0,
    list_tables_opt/0,
    list_tables_opts/0,
    list_tables_return/0,
    local_secondary_index_def/0,
    maybe_list/1,
    ok_return/1,
    out_attr/0,
    out_attr_value/0,
    out_item/0,
    out_opt/0,
    return_maps_opt/0,
    out_type/0,
    projection/0,
    put_item_opt/0,
    put_item_opts/0,
    put_item_return/0,
    q_opt/0,
    q_opts/0,
    q_return/0,
    range_key_name/0,
    read_units/0,
    replica/0,
    replica_description/0,
    replica_update/0,
    return_consumed_capacity/0,
    return_consumed_capacity_opt/0,
    return_item_collection_metrics/0,
    return_item_collection_metrics_opt/0,
    return_value/0,
    scan_opt/0,
    scan_opts/0,
    scan_return/0,
    sse_description/0,
    sse_specification/0,
    stream_specification/0,
    stream_view_type/0,
    select/0,
    table_name/0,
    tag_key/0,
    tag_value/0,
    tag/0,
    tags/0,
    time_to_live_status/0,
    update_action/0,
    update_item_opt/0,
    update_item_opts/0,
    update_item_return/0,
    update_global_table_return/0,
    update_global_table_settings_return/0,
    update_table_return/0,
    update_table_replica_auto_scaling_return/0,
    update_time_to_live_return/0,
    write_units/0
   ]).

%%%------------------------------------------------------------------------------
%%% Library initialization.
%%%------------------------------------------------------------------------------

-spec new(string(), string()) -> aws_config().
new(AccessKeyID, SecretAccessKey) ->
    #aws_config{access_key_id=AccessKeyID,
                secret_access_key=SecretAccessKey}.

-spec new(string(), string(), string()) -> aws_config().
new(AccessKeyID, SecretAccessKey, Host) ->
    #aws_config{access_key_id=AccessKeyID,
                secret_access_key=SecretAccessKey,
                ddb_host=Host}.

-spec new(string(), string(), string(), non_neg_integer()) -> aws_config().
new(AccessKeyID, SecretAccessKey, Host, Port) ->
    #aws_config{access_key_id=AccessKeyID,
                secret_access_key=SecretAccessKey,
                ddb_host=Host,
                ddb_port=Port}.

-spec new(string(), string(), string(), non_neg_integer(), string()) -> aws_config().
new(AccessKeyID, SecretAccessKey, Host, Port, Scheme) ->
    #aws_config{access_key_id=AccessKeyID,
                secret_access_key=SecretAccessKey,
                ddb_host=Host,
                ddb_port=Port,
                ddb_scheme=Scheme}.

-spec configure(string(), string()) -> ok.
configure(AccessKeyID, SecretAccessKey) ->
    erlcloud_config:configure(AccessKeyID, SecretAccessKey, fun new/2).

-spec configure(string(), string(), string()) -> ok.
configure(AccessKeyID, SecretAccessKey, Host) ->
    erlcloud_config:configure(AccessKeyID, SecretAccessKey, Host, fun new/3).

-spec configure(string(), string(), string(), non_neg_integer()) -> ok.
configure(AccessKeyID, SecretAccessKey, Host, Port) ->
    erlcloud_config:configure(AccessKeyID, SecretAccessKey, Host, Port, fun new/4).

-spec configure(string(), string(), string(), non_neg_integer(), string()) -> ok.
configure(AccessKeyID, SecretAccessKey, Host, Port, Scheme) ->
    erlcloud_config:configure(AccessKeyID, SecretAccessKey, Host, Port, Scheme, fun new/5).

default_config() -> erlcloud_aws:default_config().

%%%------------------------------------------------------------------------------
%%% Shared Types
%%%------------------------------------------------------------------------------

-type table_name() :: binary().
-type attr_type() :: s | n | b | bool | null | ss | ns | bs | l | m.
-type attr_name() :: binary().
-type maybe_list(T) :: T | [T].

-type in_string_value() :: binary() | iolist() | atom(). %% non-empty
-type in_number_value() :: number().
-type in_binary_value() :: binary() | [byte()]. %% non-empty
-type in_map_value() :: #{attr_name() => in_attr_value()}.
-type in_attr_value() :: in_string_value() |
                         in_number_value() |
                         in_map_value() |
                         {s, in_string_value()} |
                         {n, in_number_value()} |
                         {b, in_binary_value()} |
                         {bool, boolean()} |
                         {null, true} |
                         {ss, [in_string_value(),...]} |
                         {ns, [in_number_value(),...]} |
                         {bs, [in_binary_value(),...]} |
                         {l, [in_attr_value()]} |
                         {m, [in_attr()] | in_map_value()}.
-type in_attr() :: {attr_name(), in_attr_value()}.
-type in_expected_item() :: {attr_name(), false} |
                            {attr_name(), true, in_attr_value()} |
                            condition().
-type in_expected() :: maybe_list(in_expected_item()).
-type in_item() :: [in_attr()].

-type json_pair() :: {binary(), jsx:json_term()}.
-type json_attr_type() :: binary().
-type json_attr_data() :: binary() | boolean() | [binary()] | [[json_attr_value()]] | [json_attr()].
-type json_attr_value() :: {json_attr_type(), json_attr_data()}.
-type json_attr() :: {attr_name(), [json_attr_value()]}.
-type json_item() :: [json_attr()].
-type json_expected() :: [json_pair()].
-type json_key() :: [json_attr(),...].

-type key() :: maybe_list(in_attr()).
-type attr_defs() :: maybe_list({attr_name(), attr_type()}).
-type key_schema() :: hash_key_name() | {hash_key_name(), range_key_name()}.
-type hash_key_name() :: attr_name().
-type range_key_name() :: attr_name().
-type read_units() :: pos_integer().
-type write_units() :: pos_integer().

-type billing_mode() :: provisioned | pay_per_request.

-type index_name() :: binary().
-type projection() :: keys_only |
                      {include, [attr_name()]} |
                      all.

-type global_secondary_index_def() :: {index_name(), key_schema(), projection()} |
                                      {index_name(), key_schema(), projection(), read_units(), write_units()}.

-type sse_description_status() :: enabling | enabled | disabling | disabled.
-type sse_description() :: {status, sse_description_status()}.
-type sse_specification() :: {enabled, boolean()}.

-type stream_view_type() :: keys_only | new_image | old_image | new_and_old_images.
-type stream_specification() :: false | {true, stream_view_type()}.

-type replica() :: {region_name, binary()} | #ddb2_replica{}.
-type replica_update() :: {create | delete, replica()}.
-type replica_description() :: #ddb2_replica_description{}.

-type return_value() :: none | all_old | updated_old | all_new | updated_new.

-type expression() :: binary().
-type expression_attribute_names() :: [{binary(), attr_name()}].
-type expression_attribute_values() :: [{binary(), in_attr_value()}].

-type conditional_op() :: 'and' | 'or'.

-type comparison_op() :: eq | ne | le | lt | ge | gt | not_null | null | contains | not_contains | 
                         begins_with | in | between.

-type condition() :: {attr_name(), not_null | null} |
                     {attr_name(), in_attr_value()} |
                     {attr_name(), in_attr_value(), comparison_op()} |
                     {attr_name(), {in_attr_value(), in_attr_value()}, between} |
                     {attr_name(), [in_attr_value(),...], in}.
-type conditions() :: maybe_list(condition()).

-type deletion_protection_enabled() :: boolean_opt(deletion_protection_enabled).

-type select() :: all_attributes | all_projected_attributes | count | specific_attributes.

-type return_consumed_capacity() :: none | total | indexes.
-type return_item_collection_metrics() :: none | size.

-type tag_key() :: binary().
-type tag_value() :: binary().
-type tag() :: {tag_key(), tag_value()}.
-type tags() :: [tag()].

-type out_map() :: #{attr_name() => out_attr_value()}.
-type out_attr_value() :: binary() | number() | boolean() | undefined |
                          [binary()] | [number()] | [out_attr_value()] | [out_attr()] |
                          out_map().
-type out_attr() :: {attr_name(), out_attr_value()}.
-type out_item() :: [out_attr() | in_attr()] | out_map(). % in_attr in the case of typed_record
-type ok_return(T) :: {ok, T} | {error, term()}.
-type client_request_token() :: binary().

-type auto_scaling_target_tracking_scaling_policy_configuration_update_opt() :: {disable_scale_in, boolean()}|
                                                                                {scale_in_cooldown, pos_integer()}|
                                                                                {scale_out_cooldown, pos_integer()}|
                                                                                {target_value, number()}.
-type auto_scaling_target_tracking_scaling_policy_configuration_update_opts() :: [auto_scaling_target_tracking_scaling_policy_configuration_update_opt()].

-type auto_scaling_policy_opt() :: {policy_name, binary()}|
                                   {target_tracking_scaling_policy_configuration, auto_scaling_target_tracking_scaling_policy_configuration_update_opts()}.

-type auto_scaling_policy_opts() :: [auto_scaling_policy_opt()].

-type auto_scaling_settings_update_opt() :: {auto_scaling_disabled, boolean()}|
                                            {auto_scaling_role_arn, binary()}|
                                            {maximum_units, non_neg_integer()}|
                                            {minimum_units, non_neg_integer()}|
                                            {scaling_policy_update, auto_scaling_policy_opts()}.
-type auto_scaling_settings_update_opts() :: [auto_scaling_settings_update_opt()].

%%%------------------------------------------------------------------------------
%%% Shared Dynamizers
%%%------------------------------------------------------------------------------

%% Convert terms into the form expected by DynamoDB

-spec dynamize_type(attr_type()) -> binary().
dynamize_type(s) ->
    <<"S">>;
dynamize_type(n) ->
    <<"N">>;
dynamize_type(b) ->
    <<"B">>.

-spec dynamize_string(in_string_value()) -> binary().
dynamize_string(Value) when is_binary(Value) ->
    Value;
dynamize_string(Value) when is_list(Value) ->
    list_to_binary(Value);
dynamize_string(Value) when is_atom(Value) ->
    atom_to_binary(Value, utf8).

-spec dynamize_number(number()) -> binary().
dynamize_number(Value) when is_integer(Value) ->
    list_to_binary(integer_to_list(Value));
dynamize_number(Value) when is_float(Value) ->
    %% Note that float_to_list produces overly precise and long string
    [String] = io_lib:format("~p", [Value]),
    list_to_binary(String).

-spec dynamize_value(in_attr_value()) -> json_attr_value().
dynamize_value({s, Value}) when is_binary(Value); is_list(Value); is_atom(Value) ->
    {<<"S">>, dynamize_string(Value)};
dynamize_value({n, Value}) when is_number(Value) ->
    {<<"N">>, dynamize_number(Value)};
dynamize_value({b, Value}) when is_binary(Value); is_list(Value) ->
    {<<"B">>, base64:encode(Value)};
dynamize_value({bool, Value}) when is_boolean(Value) ->
    {<<"BOOL">>, Value};
dynamize_value({null, true}) ->
    {<<"NULL">>, true};

dynamize_value({ss, Value}) when is_list(Value) ->
    {<<"SS">>, [dynamize_string(V) || V <- Value]};
dynamize_value({ns, Value}) when is_list(Value) ->
    {<<"NS">>, [dynamize_number(V) || V <- Value]};
dynamize_value({bs, Value}) when is_list(Value) ->
    {<<"BS">>, [base64:encode(V) || V <- Value]};

dynamize_value({l, Value}) when is_list(Value) ->
    {<<"L">>, [[dynamize_value(V)] || V <- Value]};
dynamize_value({m, []}) ->
    %% jsx represents empty objects as [{}]
    {<<"M">>, [{}]};
dynamize_value({m, Value}) when is_list(Value) ->
    {<<"M">>, [dynamize_attr(Attr) || Attr <- Value]};
dynamize_value({m, Value}) when is_map(Value) andalso map_size(Value) =:= 0 ->
    %% jsx represents empty objects as [{}]
    {<<"M">>, [{}]};
dynamize_value({m, Value}) when is_map(Value) ->
    {<<"M">>, dynamize_map(Value)};

dynamize_value(Value) when is_map(Value) ->
    {<<"M">>, dynamize_map(Value)};
dynamize_value(Value) when is_binary(Value); is_list(Value); is_atom(Value) ->
    {<<"S">>, dynamize_string(Value)};
dynamize_value(Value) when is_number(Value) ->
    {<<"N">>, dynamize_number(Value)};
dynamize_value(Value) ->
    error({erlcloud_ddb, {invalid_attr_value, Value}}).

-spec dynamize_attr(in_attr()) -> json_attr().
dynamize_attr({Name, Value}) when is_binary(Name) ->
    {Name, [dynamize_value(Value)]};
dynamize_attr({Name, _}) ->
    error({erlcloud_ddb, {invalid_attr_name, Name}});
dynamize_attr(Attr) ->
    error({erlcloud_ddb, {invalid_attr, Attr}}).

-spec dynamize_map(in_map_value()) -> json_attr().
dynamize_map(Map) ->
    maps:fold(
      fun(Name, Value, Acc) ->
              [{Name, [dynamize_value(Value)]} | Acc]
      end, [], Map).

-spec dynamize_key(key()) -> jsx:json_term().
dynamize_key(Key) when is_list(Key) ->
    [dynamize_attr(I) || I <- Key];
dynamize_key(Attr) ->
    [dynamize_attr(Attr)].

-spec dynamize_attr_defs(attr_defs()) -> jsx:json_term().
dynamize_attr_defs({Name, Type}) ->
    [[{<<"AttributeName">>, Name},
      {<<"AttributeType">>, dynamize_type(Type)}]];
dynamize_attr_defs(AttrDefs) ->
    [[{<<"AttributeName">>, Name},
      {<<"AttributeType">>, dynamize_type(Type)}]
     || {Name, Type} <- AttrDefs].

-spec dynamize_key_schema(key_schema()) -> jsx:json_term().
dynamize_key_schema({HashKey, RangeKey}) ->
    [[{<<"AttributeName">>, HashKey}, {<<"KeyType">>, <<"HASH">>}],
     [{<<"AttributeName">>, RangeKey}, {<<"KeyType">>, <<"RANGE">>}]];
dynamize_key_schema(HashKey) ->
    [[{<<"AttributeName">>, HashKey}, {<<"KeyType">>, <<"HASH">>}]].

-spec dynamize_maybe_list(fun((A) -> B), maybe_list(A)) -> [B].
dynamize_maybe_list(DynamizeItem, List) when is_list(List) ->
    [DynamizeItem(I) || I <- List];
dynamize_maybe_list(DynamizeItem, Item) ->
    [DynamizeItem(Item)].

-spec dynamize_projection(projection()) -> jsx:json_term().
dynamize_projection(keys_only) ->
    [{<<"ProjectionType">>, <<"KEYS_ONLY">>}];
dynamize_projection(all) ->
    [{<<"ProjectionType">>, <<"ALL">>}];
dynamize_projection({include, AttrNames}) ->
    [{<<"ProjectionType">>, <<"INCLUDE">>},
     {<<"NonKeyAttributes">>, AttrNames}].

-spec dynamize_provisioned_throughput({read_units(), write_units()}) -> jsx:json_term().
dynamize_provisioned_throughput({ReadUnits, WriteUnits}) ->
     [{<<"ReadCapacityUnits">>, ReadUnits},
      {<<"WriteCapacityUnits">>, WriteUnits}].

-spec dynamize_global_secondary_index(global_secondary_index_def()) -> jsx:json_term().
dynamize_global_secondary_index({IndexName, KeySchema, Projection}) ->
    [{<<"IndexName">>, IndexName},
     {<<"KeySchema">>, dynamize_key_schema(KeySchema)},
     {<<"Projection">>, dynamize_projection(Projection)}];
dynamize_global_secondary_index({IndexName, KeySchema, Projection, ReadUnits, WriteUnits}) ->
    [{<<"IndexName">>, IndexName},
     {<<"KeySchema">>, dynamize_key_schema(KeySchema)},
     {<<"Projection">>, dynamize_projection(Projection)},
     {<<"ProvisionedThroughput">>, dynamize_provisioned_throughput({ReadUnits, WriteUnits})}].

-spec dynamize_stream_view_type(stream_view_type()) -> binary().
dynamize_stream_view_type(keys_only) -> <<"KEYS_ONLY">>;
dynamize_stream_view_type(new_image) -> <<"NEW_IMAGE">>;
dynamize_stream_view_type(old_image) -> <<"OLD_IMAGE">>;
dynamize_stream_view_type(new_and_old_images) -> <<"NEW_AND_OLD_IMAGES">>.

-spec dynamize_stream_specification(stream_specification()) -> jsx:json_term().
dynamize_stream_specification(false) ->
    [{<<"StreamEnabled">>, false}];
dynamize_stream_specification({true, StreamViewType}) ->
    [{<<"StreamEnabled">>, true},
     {<<"StreamViewType">>, dynamize_stream_view_type(StreamViewType)}].

-spec dynamize_conditional_op(conditional_op()) -> binary().
dynamize_conditional_op('and') ->
    <<"AND">>;
dynamize_conditional_op('or') ->
    <<"OR">>.

-spec dynamize_expected_item(in_expected_item()) -> json_pair().
dynamize_expected_item({Name, false}) ->
    {Name, [{<<"Exists">>, false}]};
dynamize_expected_item({Name, true, Value}) ->
    {Name, [{<<"Exists">>, true},
            {<<"Value">>, [dynamize_value(Value)]}]};
dynamize_expected_item(Condition) ->
    dynamize_condition(Condition).

-spec dynamize_expected(in_expected()) -> json_expected().
dynamize_expected(Expected) ->
    dynamize_maybe_list(fun dynamize_expected_item/1, Expected).

-spec dynamize_return_value(return_value()) -> binary().
dynamize_return_value(none) ->
    <<"NONE">>;
dynamize_return_value(all_old) ->
    <<"ALL_OLD">>;
dynamize_return_value(updated_old) ->
    <<"UPDATED_OLD">>;
dynamize_return_value(all_new) ->
    <<"ALL_NEW">>;
dynamize_return_value(updated_new) ->
    <<"UPDATED_NEW">>.

-spec dynamize_item(in_item()) -> json_item().
dynamize_item(Item) when is_list(Item) ->
    [dynamize_attr(Attr) || Attr <- Item];
dynamize_item(Item) ->
    error({erlcloud_ddb, {invalid_item, Item}}).

-spec dynamize_expression_attribute_names(expression_attribute_names()) -> [json_pair()].
dynamize_expression_attribute_names(Names) ->
    Names.

-spec dynamize_expression_attribute_values(expression_attribute_values()) -> [json_pair()].
dynamize_expression_attribute_values(Values) ->
    [{P, [dynamize_value(Value)]} || {P, Value} <- Values].

-spec dynamize_comparison(comparison_op()) -> {binary(), binary()}.
dynamize_comparison(eq) ->
    {<<"ComparisonOperator">>, <<"EQ">>};
dynamize_comparison(ne) ->
    {<<"ComparisonOperator">>, <<"NE">>};
dynamize_comparison(le) ->
    {<<"ComparisonOperator">>, <<"LE">>};
dynamize_comparison(lt) ->
    {<<"ComparisonOperator">>, <<"LT">>};
dynamize_comparison(ge) ->
    {<<"ComparisonOperator">>, <<"GE">>};
dynamize_comparison(gt) ->
    {<<"ComparisonOperator">>, <<"GT">>};
dynamize_comparison(not_null) ->
    {<<"ComparisonOperator">>, <<"NOT_NULL">>};
dynamize_comparison(null) ->
    {<<"ComparisonOperator">>, <<"NULL">>};
dynamize_comparison(contains) ->
    {<<"ComparisonOperator">>, <<"CONTAINS">>};
dynamize_comparison(not_contains) ->
    {<<"ComparisonOperator">>, <<"NOT_CONTAINS">>};
dynamize_comparison(begins_with) ->
    {<<"ComparisonOperator">>, <<"BEGINS_WITH">>};
dynamize_comparison(in) ->
    {<<"ComparisonOperator">>, <<"IN">>};
dynamize_comparison(between) ->
    {<<"ComparisonOperator">>, <<"BETWEEN">>}.

-spec dynamize_condition(condition()) -> json_pair().
dynamize_condition({Name, not_null}) ->
    {Name, [dynamize_comparison(not_null)]};
dynamize_condition({Name, null}) ->
    {Name, [dynamize_comparison(null)]};
dynamize_condition({Name, AttrValue}) ->
    %% Default to eq
    {Name, [{<<"AttributeValueList">>, [[dynamize_value(AttrValue)]]},
            dynamize_comparison(eq)]};
dynamize_condition({Name, AttrValueList, in}) ->
    {Name, [{<<"AttributeValueList">>, [[dynamize_value(A)] || A <- AttrValueList]},
            dynamize_comparison(in)]};
dynamize_condition({Name, {AttrValue1, AttrValue2}, between}) ->
    {Name, [{<<"AttributeValueList">>, [[dynamize_value(AttrValue1)], [dynamize_value(AttrValue2)]]},
            dynamize_comparison(between)]};
dynamize_condition({Name, AttrValue, Op}) ->
    {Name, [{<<"AttributeValueList">>, [[dynamize_value(AttrValue)]]},
            dynamize_comparison(Op)]}.

-spec dynamize_conditions(conditions()) -> [json_pair()].
dynamize_conditions(Conditions) ->
    dynamize_maybe_list(fun dynamize_condition/1, Conditions).

-spec dynamize_select(select()) -> binary().
dynamize_select(all_attributes)           -> <<"ALL_ATTRIBUTES">>;
dynamize_select(all_projected_attributes) -> <<"ALL_PROJECTED_ATTRIBUTES">>;
dynamize_select(count)                    -> <<"COUNT">>;
dynamize_select(specific_attributes)      -> <<"SPECIFIC_ATTRIBUTES">>.

-spec dynamize_return_consumed_capacity(return_consumed_capacity()) -> binary().
dynamize_return_consumed_capacity(none) ->
    <<"NONE">>;
dynamize_return_consumed_capacity(total) ->
    <<"TOTAL">>;
dynamize_return_consumed_capacity(indexes) ->
    <<"INDEXES">>.

-spec dynamize_return_item_collection_metrics(return_item_collection_metrics()) -> binary().
dynamize_return_item_collection_metrics(none) ->
    <<"NONE">>;
dynamize_return_item_collection_metrics(size) ->
    <<"SIZE">>.

-spec dynamize_auto_scaling_target_tracking_scaling_policy_configuration_update_opt(auto_scaling_target_tracking_scaling_policy_configuration_update_opt()) -> json_pair().
dynamize_auto_scaling_target_tracking_scaling_policy_configuration_update_opt({target_value, TargetValue}) ->
    {<<"TargetValue">>, TargetValue};
dynamize_auto_scaling_target_tracking_scaling_policy_configuration_update_opt({disable_scale_in, DisableScaleIn}) ->
    {<<"DisableScaleIn">>, DisableScaleIn};
dynamize_auto_scaling_target_tracking_scaling_policy_configuration_update_opt({scale_in_cooldown, ScaleInCooldown}) ->
    {<<"ScaleInCooldown">>, ScaleInCooldown};
dynamize_auto_scaling_target_tracking_scaling_policy_configuration_update_opt({scale_out_cooldown, ScaleOutCooldown}) ->
    {<<"ScaleOutCooldown">>, ScaleOutCooldown}.

-spec dynamize_auto_scaling_target_tracking_scaling_policy_configuration_update_opts(auto_scaling_policy_opts()) -> jsx:json_term().
dynamize_auto_scaling_target_tracking_scaling_policy_configuration_update_opts(Opts) ->
    dynamize_maybe_list(fun dynamize_auto_scaling_target_tracking_scaling_policy_configuration_update_opt/1, Opts).

-spec dynamize_auto_scaling_policy_update_opt(auto_scaling_policy_opt()) -> json_pair().
dynamize_auto_scaling_policy_update_opt({policy_name, PolicyName}) ->
    {<<"PolicyName">>, PolicyName};
dynamize_auto_scaling_policy_update_opt({target_tracking_scaling_policy_configuration, TargetTrackingScalingPolicyConfiguration}) ->
    {<<"TargetTrackingScalingPolicyConfiguration">>, dynamize_auto_scaling_target_tracking_scaling_policy_configuration_update_opts(TargetTrackingScalingPolicyConfiguration)}.

-spec dynamize_auto_scaling_policy_update_opts(auto_scaling_policy_opts()) -> jsx:json_term().
dynamize_auto_scaling_policy_update_opts(Opts) ->
    dynamize_maybe_list(fun dynamize_auto_scaling_policy_update_opt/1, Opts).

-spec dynamize_auto_scaling_settings_update_opt(auto_scaling_settings_update_opt()) -> json_pair().
dynamize_auto_scaling_settings_update_opt({auto_scaling_disabled, AutoScalingDisabled}) ->
    {<<"AutoScalingDisabled">>, AutoScalingDisabled};
dynamize_auto_scaling_settings_update_opt({auto_scaling_role_arn, AutoScalingRoleArn}) ->
    {<<"AutoScalingRoleArn">>, AutoScalingRoleArn};
dynamize_auto_scaling_settings_update_opt({maximum_units, MaximumUnits}) ->
    {<<"MaximumUnits">>, MaximumUnits};
dynamize_auto_scaling_settings_update_opt({minimum_units, MinimumUnits}) ->
    {<<"MinimumUnits">>, MinimumUnits};
dynamize_auto_scaling_settings_update_opt({scaling_policy_update, ScalingPolicyUpdate}) ->
    {<<"ScalingPolicyUpdate">>, dynamize_auto_scaling_policy_update_opts(ScalingPolicyUpdate)}.

-spec dynamize_auto_scaling_settings_update_opts(auto_scaling_settings_update_opts()) -> jsx:json_term().
dynamize_auto_scaling_settings_update_opts(Opts) ->
    dynamize_maybe_list(fun dynamize_auto_scaling_settings_update_opt/1, Opts).

%%%------------------------------------------------------------------------------
%%% Shared Undynamizers
%%%------------------------------------------------------------------------------

-type undynamize_opt() :: {typed, boolean()} | return_maps_opt().
-type undynamize_opts() :: [undynamize_opt()].

-spec id(X, undynamize_opts()) -> X.
id(X, _) -> X.

-spec undynamize_type(json_attr_type(), undynamize_opts()) -> attr_type().
undynamize_type(<<"S">>, _) ->
    s;
undynamize_type(<<"N">>, _) ->
    n;
undynamize_type(<<"B">>, _) ->
    b.

-spec undynamize_number(binary(), undynamize_opts()) -> number().
undynamize_number(Value, _) ->
    String = binary_to_list(Value),
    case lists:member($., String) of
        true ->
            list_to_float(String);
        false ->
            list_to_integer(String)
    end.
            
-spec undynamize_value(json_attr_value(), undynamize_opts()) -> out_attr_value().
undynamize_value({<<"S">>, Value}, _) when is_binary(Value) ->
    Value;
undynamize_value({<<"N">>, Value}, Opts) ->
    undynamize_number(Value, Opts);
undynamize_value({<<"B">>, Value}, _) ->
    base64:decode(Value);
undynamize_value({<<"BOOL">>, Value}, _) when is_boolean(Value) ->
    Value;
undynamize_value({<<"NULL">>, true}, _) ->
    undefined;
undynamize_value({<<"SS">>, Values}, _) when is_list(Values) ->
    Values;
undynamize_value({<<"NS">>, Values}, Opts) ->
    [undynamize_number(Value, Opts) || Value <- Values];
undynamize_value({<<"BS">>, Values}, _) ->
    [base64:decode(Value) || Value <- Values];
undynamize_value({<<"L">>, List}, Opts) ->
    [undynamize_value(Value, Opts) || [Value] <- List];
undynamize_value({<<"M">>, [{}]}, Opts) ->
    %% jsx returns [{}] for empty objects
    case proplists:get_bool(return_maps, Opts) of
        true ->
            #{};
        false ->
            []
    end;
undynamize_value({<<"M">>, Map}, Opts) ->
    case proplists:get_bool(return_maps, Opts) of
        true ->
            undynamize_map(Map, Opts);
        false ->
            [undynamize_attr(Attr, Opts) || Attr <- Map]
    end.

-spec undynamize_map([json_pair()], undynamize_opts()) -> out_map().
undynamize_map(List, Opts) ->
    lists:foldl(
      fun({Name, [ValueJson]}, Acc) ->
              Acc#{Name => undynamize_value(ValueJson, Opts)}
      end, #{}, List).

-spec undynamize_attr(json_attr(), undynamize_opts()) -> out_attr().
undynamize_attr({Name, [ValueJson]}, Opts) ->
    {Name, undynamize_value(ValueJson, Opts)}.

-spec undynamize_object(fun((json_pair(), undynamize_opts()) -> A), 
                        [json_pair()] | [{}], undynamize_opts()) -> [A].
undynamize_object(_, [{}], _) ->
    %% jsx returns [{}] for empty objects
    [];
undynamize_object(PairFun, List, Opts) ->
    [PairFun(I, Opts) || I <- List].

-spec undynamize_item(json_item(), undynamize_opts()) -> out_item().
undynamize_item(Json, Opts) ->
    case lists:keyfind(typed, 1, Opts) of
        {typed, true} ->
            undynamize_object(fun undynamize_attr_typed/2, Json, Opts);
        _ ->
            undynamize_object(fun undynamize_attr/2, Json, Opts)
    end.

-spec undynamize_items([json_item()], undynamize_opts()) -> [out_item()].
undynamize_items(Items, Opts) ->
    [undynamize_item(I, Opts) || I <- Items].

-spec undynamize_value_typed(json_attr_value(), undynamize_opts()) -> in_attr_value().
undynamize_value_typed({<<"S">>, Value}, _) when is_binary(Value) ->
    {s, Value};
undynamize_value_typed({<<"N">>, Value}, Opts) ->
    {n, undynamize_number(Value, Opts)};
undynamize_value_typed({<<"B">>, Value}, _) ->
    {b, base64:decode(Value)};
undynamize_value_typed({<<"BOOL">>, Value}, _) when is_boolean(Value) ->
    {bool, Value};
undynamize_value_typed({<<"NULL">>, true}, _) ->
    {null, true};
undynamize_value_typed({<<"SS">>, Values}, _) when is_list(Values) ->
    {ss, Values};
undynamize_value_typed({<<"NS">>, Values}, Opts) ->
    {ns, [undynamize_number(Value, Opts) || Value <- Values]};
undynamize_value_typed({<<"BS">>, Values}, _) ->
    {bs, [base64:decode(Value) || Value <- Values]};
undynamize_value_typed({<<"L">>, List}, Opts) ->
    {l, [undynamize_value_typed(Value, Opts) || [Value] <- List]};
undynamize_value_typed({<<"M">>, [{}]}, Opts) ->
    %% jsx returns [{}] for empty objects
    case proplists:get_bool(return_maps, Opts) of
        true ->
            {m, #{}};
        false ->
            {m, []}
    end;
undynamize_value_typed({<<"M">>, Map}, Opts) ->
    case proplists:get_bool(return_maps, Opts) of
        true ->
            {m, undynamize_map_typed(Map, Opts)};
        false ->
            {m, [undynamize_attr_typed(Attr, Opts) || Attr <- Map]}
    end.

-spec undynamize_map_typed([json_pair()], undynamize_opts()) -> out_map().
undynamize_map_typed(List, Opts) ->
    lists:foldl(
      fun({Name, [ValueJson]}, Acc) ->
              Acc#{Name => undynamize_value_typed(ValueJson, Opts)}
      end, #{}, List).

-spec undynamize_attr_typed(json_attr(), undynamize_opts()) -> in_attr().
undynamize_attr_typed({Name, [ValueJson]}, Opts) ->
    {Name, undynamize_value_typed(ValueJson, Opts)}.

-spec undynamize_item_typed(json_item(), undynamize_opts()) -> in_item().
undynamize_item_typed(Json, Opts) ->
    undynamize_object(fun undynamize_attr_typed/2, Json, Opts).

-spec undynamize_typed_key(json_key(), undynamize_opts()) -> key().
undynamize_typed_key(Key, Opts) ->
    [undynamize_attr_typed(I, Opts) || I <- Key].

-spec undynamize_attr_defs([json_item()], undynamize_opts()) -> attr_defs().
undynamize_attr_defs(V, Opts) ->
    [{proplists:get_value(<<"AttributeName">>, I),
      undynamize_type(proplists:get_value(<<"AttributeType">>, I), Opts)}
     || I <- V].
    
key_name(Key) ->
    proplists:get_value(<<"AttributeName">>, Key).
    
-spec undynamize_key_schema([json_item()], undynamize_opts()) -> key_schema().
undynamize_key_schema([HashKey], _) ->
    key_name(HashKey);
undynamize_key_schema([Key1, Key2], _) ->
    case proplists:get_value(<<"KeyType">>, Key1) of
        <<"HASH">> ->
            {key_name(Key1), key_name(Key2)};
        <<"RANGE">> ->
            {key_name(Key2), key_name(Key1)}
    end.

-spec undynamize_sse_description_status(binary(), undynamize_opts()) -> sse_description_status().
undynamize_sse_description_status(<<"ENABLING">>, _) -> enabling;
undynamize_sse_description_status(<<"ENABLED">>, _) -> enabled;
undynamize_sse_description_status(<<"DISABLING">>, _) -> disabling;
undynamize_sse_description_status(<<"DISABLED">>, _) -> disabled.

-spec undynamize_sse_description(jsx:json_term(), undynamize_opts()) -> sse_description().
undynamize_sse_description(Json, Opts) ->
    {status, undynamize_sse_description_status(proplists:get_value(<<"Status">>, Json), Opts)}.

-spec undynamize_stream_view_type(binary(), undynamize_opts()) -> stream_view_type().
undynamize_stream_view_type(<<"KEYS_ONLY">>, _) -> keys_only;
undynamize_stream_view_type(<<"NEW_IMAGE">>, _) -> new_image;
undynamize_stream_view_type(<<"OLD_IMAGE">>, _) -> old_image;
undynamize_stream_view_type(<<"NEW_AND_OLD_IMAGES">>, _) -> new_and_old_images.

-spec undynamize_stream_specification(jsx:json_term(), undynamize_opts()) -> stream_specification().
undynamize_stream_specification(Json, Opts) ->
    case proplists:get_value(<<"StreamEnabled">>, Json, false) of
        false ->
            false;
        true ->
            {true, undynamize_stream_view_type(proplists:get_value(<<"StreamViewType">>, Json), Opts)}
    end.

-spec undynamize_expression(binary(), undynamize_opts()) -> expression().
undynamize_expression(Expression, _) ->
    Expression.

-spec undynamize_expression_attribute_names([json_pair()], undynamize_opts()) -> expression_attribute_names().
undynamize_expression_attribute_names(Names, _) ->
    Names.

-spec undynamize_global_table_status(binary(), undynamize_opts()) -> global_table_status().
undynamize_global_table_status(<<"CREATING">>, _) -> creating;
undynamize_global_table_status(<<"UPDATING">>, _) -> updating;
undynamize_global_table_status(<<"DELETING">>, _) -> deleting;
undynamize_global_table_status(<<"ACTIVE">>, _)   -> active.

-spec undynamize_replica_status(binary(), undynamize_opts()) -> replica_status().
undynamize_replica_status(<<"CREATING">>, _) -> creating;
undynamize_replica_status(<<"CREATION_FAILED">>, _) -> creation_failed;
undynamize_replica_status(<<"UPDATING">>, _) -> updating;
undynamize_replica_status(<<"DELETING">>, _) -> deleting;
undynamize_replica_status(<<"ACTIVE">>, _)   -> active.

-spec undynamize_replica_description(jsx:json_term(), undynamize_opts()) -> replica_description().
undynamize_replica_description(ReplicaDescription, _) ->
    #ddb2_replica_description{region_name = proplists:get_value(<<"RegionName">>, ReplicaDescription)}.

-spec undynamize_replica_descriptions(jsx:json_term(), undynamize_opts()) -> [replica_description()].
undynamize_replica_descriptions(ReplicaDescriptions, Opts) ->
    [undynamize_replica_description(ReplicaDescription, Opts)
     || ReplicaDescription <- ReplicaDescriptions].

-spec undynamize_replica(jsx:json_term(), undynamize_opts()) -> replica().
undynamize_replica(Replica, _) ->
    #ddb2_replica{region_name = proplists:get_value(<<"RegionName">>, Replica)}.

-spec undynamize_replicas([jsx:json_term()], undynamize_opts()) -> [replica()].
undynamize_replicas(Replicas, Opts) ->
    [undynamize_replica(Replica, Opts) || Replica <- Replicas].

-spec undynamize_table_status(binary(), undynamize_opts()) -> table_status().
undynamize_table_status(<<"CREATING">>, _) -> creating;
undynamize_table_status(<<"UPDATING">>, _) -> updating;
undynamize_table_status(<<"DELETING">>, _) -> deleting;
undynamize_table_status(<<"ACTIVE">>, _)   -> active.

-spec undynamize_continuous_backups_status(binary(), undynamize_opts()) -> continuous_backups_status().
undynamize_continuous_backups_status(<<"ENABLED">>, _) -> enabled;
undynamize_continuous_backups_status(<<"DISABLED">>, _) -> disabled.

-spec undynamize_point_in_time_recovery_status(binary(), undynamize_opts()) -> point_in_time_recovery_status().
undynamize_point_in_time_recovery_status(<<"ENABLING">>, _) -> enabling;
undynamize_point_in_time_recovery_status(<<"ENABLED">>, _) -> enabled;
undynamize_point_in_time_recovery_status(<<"DISABLED">>, _) -> disabled.

-spec undynamize_backup_status(binary(), undynamize_opts()) -> backup_status().
undynamize_backup_status(<<"CREATING">>, _) -> creating;
undynamize_backup_status(<<"AVAILABLE">>, _) -> available;
undynamize_backup_status(<<"DELETED">>, _) -> deleted.

-type field_table() :: [{binary(), pos_integer(), 
                         fun((jsx:json_term(), undynamize_opts()) -> term())}].

-spec undynamize_folder(field_table(), json_pair(), undynamize_opts(), tuple()) -> tuple().
undynamize_folder(Table, {Key, Value}, Opts, A) ->
    case lists:keyfind(Key, 1, Table) of
        {Key, Index, ValueFun} ->
            setelement(Index, A, ValueFun(Value, Opts));
        false ->
            A
    end.

-type record_desc() :: {tuple(), field_table()}.

-spec undynamize_record(record_desc(), jsx:json_term(), undynamize_opts()) -> tuple().
undynamize_record({Record, _}, [{}], _) ->
    %% jsx returns [{}] for empty objects
    Record;
undynamize_record({Record, Table}, Json, Opts) ->
    lists:foldl(fun(Pair, A) -> undynamize_folder(Table, Pair, Opts, A) end, Record, Json).

%%%------------------------------------------------------------------------------
%%% Shared Options
%%%------------------------------------------------------------------------------

-spec id(X) -> X.
id(X) -> X.

-type out_type() :: json | record | typed_record | simple.
-type out_opt() :: {out, out_type()}.
-type no_request_opt() :: {no_request, boolean()}.
-type return_maps_opt() :: boolean_opt(return_maps).
-type boolean_opt(Name) :: Name | {Name, boolean()}.
-type property() :: proplists:property().

-type aws_opts() :: [json_pair()].
-type ddb_opts() :: [out_opt() | no_request_opt() | return_maps_opt()].
-type opts() :: {aws_opts(), ddb_opts()}.

-spec verify_ddb_opt(atom(), term()) -> ok.
verify_ddb_opt(out, Value) ->
    case lists:member(Value, [json, record, typed_record, simple]) of
        true ->
            ok;
        false ->
            error({erlcloud_ddb, {invalid_opt, {out, Value}}})
    end;
verify_ddb_opt(no_request, Value) ->
    case is_boolean(Value) of
        true ->
            ok;
        false ->
            error({erlcloud_ddb, {invalid_opt, {no_request, Value}}})
    end;
verify_ddb_opt(return_maps, Value) ->
    case is_boolean(Value) of
        true ->
            ok;
        false ->
            error({erlcloud_ddb, {invalid_opt, {return_maps, Value}}})
    end;
verify_ddb_opt(Name, Value) ->
    error({erlcloud_ddb, {invalid_opt, {Name, Value}}}).

-type opt_table_entry() :: {atom(), binary(), fun((_) -> jsx:json_term())}.
-type opt_table() :: [opt_table_entry()].
-spec opt_folder(opt_table(), property(), opts()) -> opts().
opt_folder(_, {_, undefined}, Opts) ->
    %% ignore options set to undefined
    Opts;
opt_folder(Table, {Name, Value}, {AwsOpts, DdbOpts}) ->
    case lists:keyfind(Name, 1, Table) of
        {Name, Key, ValueFun} ->
            {[{Key, ValueFun(Value)} | AwsOpts], DdbOpts};
        false ->
            verify_ddb_opt(Name, Value),
            {AwsOpts, [{Name, Value} | DdbOpts]}
    end.

-spec opts(opt_table(), proplist()) -> opts().
opts(Table, Opts) when is_list(Opts) ->
    %% remove duplicate options
    Opts1 = lists:ukeysort(1, proplists:unfold(Opts)),
    lists:foldl(fun(Opt, A) -> opt_folder(Table, Opt, A) end, {[], []}, Opts1);
opts(_, _) ->
    error({erlcloud_ddb, opts_not_list}).

-type expression_attribute_names_opt() :: {expression_attribute_names, expression_attribute_names()}.

-spec expression_attribute_names_opt() -> opt_table_entry().
expression_attribute_names_opt() ->
    {expression_attribute_names, <<"ExpressionAttributeNames">>, fun dynamize_expression_attribute_names/1}.

-type expression_attribute_values_opt() :: {expression_attribute_values, expression_attribute_values()}.

-spec expression_attribute_values_opt() -> opt_table_entry().
expression_attribute_values_opt() ->
    {expression_attribute_values, <<"ExpressionAttributeValues">>, fun dynamize_expression_attribute_values/1}.

-type projection_expression_opt() :: {projection_expression, expression()}.

-spec projection_expression_opt() -> opt_table_entry().
projection_expression_opt() ->
    {projection_expression, <<"ProjectionExpression">>, fun dynamize_expression/1}.

-type attributes_to_get_opt() :: {attributes_to_get, [attr_name()]}.

-spec attributes_to_get_opt() -> opt_table_entry().
attributes_to_get_opt() ->
    {attributes_to_get, <<"AttributesToGet">>, fun id/1}.

-type consistent_read_opt() :: boolean_opt(consistent_read).

-spec consistent_read_opt() -> opt_table_entry().
consistent_read_opt() ->
    {consistent_read, <<"ConsistentRead">>, fun id/1}.

-type condition_expression_opt() :: {condition_expression, expression()}.

-spec condition_expression_opt() -> opt_table_entry().
condition_expression_opt() ->
    {condition_expression, <<"ConditionExpression">>, fun dynamize_expression/1}.

-type conditional_op_opt() :: {conditional_op, conditional_op()}.

-spec conditional_op_opt() -> opt_table_entry().
conditional_op_opt() ->
    {conditional_op, <<"ConditionalOperator">>, fun dynamize_conditional_op/1}.

-type expected_opt() :: {expected, in_expected()}.

-spec expected_opt() -> opt_table_entry().
expected_opt() ->
    {expected, <<"Expected">>, fun dynamize_expected/1}.

-spec filter_expression_opt() -> opt_table_entry().

filter_expression_opt() ->
    {filter_expression, <<"FilterExpression">>, fun dynamize_expression/1}.

% This matches the Java API, which asks the user to write their own expressions.

-spec dynamize_expression(expression()) -> binary().
dynamize_expression(Expression) when is_binary(Expression) ->
    Expression;
dynamize_expression(Expression) when is_list(Expression) ->
    list_to_binary(Expression);

% Or, some convenience functions for assembling expressions using lists of tuples.

dynamize_expression({A, also, B}) ->
    AA = dynamize_expression(A),
    BB = dynamize_expression(B),
    <<"(", AA/binary, ") AND (", BB/binary, ")">>;
dynamize_expression({{A, B}, eq}) ->
    <<A/binary, " = ", B/binary>>;
dynamize_expression({{A, B}, ne}) ->
    <<A/binary, " <> ", B/binary>>;
dynamize_expression({{A, B}, lt}) ->
    <<A/binary, " < ", B/binary>>;
dynamize_expression({{A, B}, le}) ->
    <<A/binary, " <= ", B/binary>>;
dynamize_expression({{A, B}, gt}) ->
    <<A/binary, " > ", B/binary>>;
dynamize_expression({{A, B}, ge}) ->
    <<A/binary, " >= ", B/binary>>;
dynamize_expression({{A, {Low, High}}, between}) ->
    <<A/binary, " BETWEEN ", Low/binary, " AND ", High/binary>>;
dynamize_expression({{A, B}, in}) when is_binary(B) ->
    <<A/binary, " IN ", B/binary>>;
dynamize_expression({{A, B}, in}) when is_list(B) ->
    % Convert everything to binaries.

    InList = [to_binary(X) || X <- B],

    % Join the list of binaries with commas.

    Join = fun(Elem, Acc) when Acc =:= <<"">> ->
                Elem;
              (Elem, Acc) ->
                <<Acc/binary, ",", Elem/binary>> end,

    In = lists:foldl(Join, <<>>, InList),

    <<A/binary, " IN (", In/binary, ")">>;
dynamize_expression({attribute_exists, Path}) ->
    <<"attribute_exists(", Path/binary, ")">>;
dynamize_expression({attribute_not_exists, Path}) ->
    <<"attribute_not_exists(", Path/binary, ")">>;
dynamize_expression({begins_with, Path, Operand}) ->
    <<"begins_with(", Path/binary, ",", Operand/binary, ")">>;
dynamize_expression({contains, Path, Operand}) ->
    <<"contains(", Path/binary, ",", Operand/binary, ")">>.

-type return_consumed_capacity_opt() :: {return_consumed_capacity, return_consumed_capacity()}.

-spec return_consumed_capacity_opt() -> opt_table_entry().
return_consumed_capacity_opt() ->
    {return_consumed_capacity, <<"ReturnConsumedCapacity">>, fun dynamize_return_consumed_capacity/1}.

-type client_request_token_opt() :: {client_request_token, client_request_token()}.

-spec client_request_token_opt() -> opt_table_entry().
client_request_token_opt() ->
    {client_request_token, <<"ClientRequestToken">>, fun id/1}.

-type return_item_collection_metrics_opt() :: {return_item_collection_metrics, return_item_collection_metrics()}.

-spec return_item_collection_metrics_opt() -> opt_table_entry().
return_item_collection_metrics_opt() ->
    {return_item_collection_metrics, <<"ReturnItemCollectionMetrics">>, 
     fun dynamize_return_item_collection_metrics/1}.

%%%------------------------------------------------------------------------------
%%% Output
%%%------------------------------------------------------------------------------
-type ddb_return(Record, Simple) :: {ok, jsx:json_term() | Record | Simple} | {error, term()}.
-type undynamize_fun() :: fun((jsx:json_term(), undynamize_opts()) -> tuple()).

-spec out(erlcloud_ddb_impl:json_return(), undynamize_fun(), ddb_opts()) 
         -> {ok, jsx:json_term() | tuple() | #ddb2_request{}} |
            {simple, term()} |
            {error, term()}.
out({error, Reason}, _, _) ->
    {error, Reason};
out(ok, _, _) ->
    {error, unexpected_empty_response};
out({ok, #ddb2_request{}} = Request, _Undynamize, _Opts) ->
    Request;
out({ok, Json}, Undynamize, Opts) ->
    Maps = proplists:get_bool(return_maps, Opts),
    case proplists:get_value(out, Opts, simple) of
        json ->
            {ok, Json};
        record ->
            {ok, Undynamize(Json, [{return_maps, Maps}])};
        typed_record ->
            {ok, Undynamize(Json, [{typed, true}, {return_maps, Maps}])};
        simple ->
            {simple, Undynamize(Json, [{return_maps, Maps}])}
    end.

%% Returns specified field of tuple for simple return
-spec out(erlcloud_ddb_impl:json_return(), undynamize_fun(), ddb_opts(), pos_integer()) 
         -> ok_return(term()).
out(Result, Undynamize, Opts, Index) ->
    out(Result, Undynamize, Opts, Index, {error, no_return}).

-spec out(erlcloud_ddb_impl:json_return(), undynamize_fun(), ddb_opts(), pos_integer(), ok_return(term())) 
         -> ok_return(term()).
out(Result, Undynamize, Opts, Index, Default) ->
    case out(Result, Undynamize, Opts) of
        {simple, Record} ->
            case element(Index, Record) of
                undefined ->
                    Default;
                Element ->
                    {ok, Element}
            end;
        Else ->
            Else
    end.

%%%------------------------------------------------------------------------------
%%% Shared Records
%%%------------------------------------------------------------------------------

-spec undynamize_billing_mode(binary(), undynamize_opts()) -> billing_mode().
undynamize_billing_mode(<<"PROVISIONED">>, _) -> provisioned;
undynamize_billing_mode(<<"PAY_PER_REQUEST">>, _) -> pay_per_request.

-spec billing_mode_summary_record() -> record_desc().
billing_mode_summary_record() ->
    {#ddb2_billing_mode_summary{},
     [{<<"BillingMode">>, #ddb2_billing_mode_summary.billing_mode, fun undynamize_billing_mode/2},
      {<<"LastUpdateToPayPerRequestDateTime">>,
       #ddb2_billing_mode_summary.last_update_to_pay_per_request_date_time, fun id/2}]}.

undynamize_billing_mode_summary(V, Opts) ->
    undynamize_record(billing_mode_summary_record(), V, Opts).

undynamize_consumed_capacity_units(V, _Opts) ->
    {_, CapacityUnits} = lists:keyfind(<<"CapacityUnits">>, 1, V),
    CapacityUnits.

-spec consumed_capacity_record() -> record_desc().
consumed_capacity_record() ->
    {#ddb2_consumed_capacity{},
     [{<<"CapacityUnits">>, #ddb2_consumed_capacity.capacity_units, fun id/2},
      {<<"GlobalSecondaryIndexes">>, #ddb2_consumed_capacity.global_secondary_indexes,
       fun(V, Opts) -> undynamize_object(
                         fun({IndexName, Json}, Opts2) ->
                                 {IndexName, undynamize_consumed_capacity_units(Json, Opts2)}
                         end, V, Opts)
       end},
      {<<"LocalSecondaryIndexes">>, #ddb2_consumed_capacity.local_secondary_indexes,
       fun(V, Opts) -> undynamize_object(
                         fun({IndexName, Json}, Opts2) ->
                                 {IndexName, undynamize_consumed_capacity_units(Json, Opts2)}
                         end, V, Opts)
       end},
      {<<"Table">>, #ddb2_consumed_capacity.table, fun undynamize_consumed_capacity_units/2},
      {<<"TableName">>, #ddb2_consumed_capacity.table_name, fun id/2}]}.

undynamize_consumed_capacity(V, Opts) ->
    undynamize_record(consumed_capacity_record(), V, Opts).

undynamize_consumed_capacity_list(V, Opts) ->
    [undynamize_record(consumed_capacity_record(), I, Opts) || I <- V].

-spec item_collection_metrics_record() -> record_desc().
item_collection_metrics_record() ->
    {#ddb2_item_collection_metrics{},
     [{<<"ItemCollectionKey">>, #ddb2_item_collection_metrics.item_collection_key,
       fun([V], Opts) ->
               {_Name, Value} = undynamize_attr(V, Opts),
               Value
       end},
      {<<"SizeEstimateRangeGB">>, #ddb2_item_collection_metrics.size_estimate_range_gb,
       fun([L, H], _) -> {L, H} end}]}.

undynamize_item_collection_metrics(V, Opts) ->
    undynamize_record(item_collection_metrics_record(), V, Opts).

undynamize_item_collection_metric_list(Table, V, Opts) ->
    {Table, [undynamize_item_collection_metrics(I, Opts) || I <- V]}.

undynamize_projection(V, _) ->
    case proplists:get_value(<<"ProjectionType">>, V) of
        <<"KEYS_ONLY">> ->
            keys_only;
        <<"ALL">> ->
            all;
        <<"INCLUDE">> ->
            {include, proplists:get_value(<<"NonKeyAttributes">>, V)}
    end.

-spec undynamize_index_status(binary(), undynamize_opts()) -> index_status().
undynamize_index_status(<<"CREATING">>, _) -> creating;
undynamize_index_status(<<"UPDATING">>, _) -> updating;
undynamize_index_status(<<"DELETING">>, _) -> deleting;
undynamize_index_status(<<"ACTIVE">>, _)   -> active.

-spec global_secondary_index_description_record() -> record_desc().
global_secondary_index_description_record() ->
    {#ddb2_global_secondary_index_description{},
     [{<<"Backfilling">>, #ddb2_global_secondary_index_description.backfilling, fun id/2},
      {<<"IndexArn">>, #ddb2_global_secondary_index_description.index_arn, fun id/2},
      {<<"IndexName">>, #ddb2_global_secondary_index_description.index_name, fun id/2},
      {<<"IndexSizeBytes">>, #ddb2_global_secondary_index_description.index_size_bytes, fun id/2},
      {<<"IndexStatus">>, #ddb2_global_secondary_index_description.index_status, fun undynamize_index_status/2},
      {<<"ItemCount">>, #ddb2_global_secondary_index_description.item_count, fun id/2},
      {<<"KeySchema">>, #ddb2_global_secondary_index_description.key_schema, fun undynamize_key_schema/2},
      {<<"Projection">>, #ddb2_global_secondary_index_description.projection, fun undynamize_projection/2},
      {<<"ProvisionedThroughput">>, #ddb2_global_secondary_index_description.provisioned_throughput,
       fun(V, Opts) -> undynamize_record(provisioned_throughput_description_record(), V, Opts) end}
     ]}.
    
-spec local_secondary_index_description_record() -> record_desc().
local_secondary_index_description_record() ->
    {#ddb2_local_secondary_index_description{},
     [{<<"IndexArn">>, #ddb2_local_secondary_index_description.index_arn, fun id/2},
      {<<"IndexName">>, #ddb2_local_secondary_index_description.index_name, fun id/2},
      {<<"IndexSizeBytes">>, #ddb2_local_secondary_index_description.index_size_bytes, fun id/2},
      {<<"ItemCount">>, #ddb2_local_secondary_index_description.item_count, fun id/2},
      {<<"KeySchema">>, #ddb2_local_secondary_index_description.key_schema, fun undynamize_key_schema/2},
      {<<"Projection">>, #ddb2_local_secondary_index_description.projection, fun undynamize_projection/2}
     ]}.

-spec provisioned_throughput_description_record() -> record_desc().
provisioned_throughput_description_record() ->
    {#ddb2_provisioned_throughput_description{},
     [{<<"LastDecreaseDateTime">>, #ddb2_provisioned_throughput_description.last_decrease_date_time, fun id/2},
      {<<"LastIncreaseDateTime">>, #ddb2_provisioned_throughput_description.last_increase_date_time, fun id/2},
      {<<"NumberOfDecreasesToday">>, #ddb2_provisioned_throughput_description.number_of_decreases_today, fun id/2},
      {<<"ReadCapacityUnits">>, #ddb2_provisioned_throughput_description.read_capacity_units, fun id/2},
      {<<"WriteCapacityUnits">>, #ddb2_provisioned_throughput_description.write_capacity_units, fun id/2}
     ]}.
-spec global_table_description_record() -> record_desc().
global_table_description_record() ->
    {#ddb2_global_table_description{},
     [{<<"CreationDateTime">>, #ddb2_global_table_description.creation_date_time, fun id/2},
      {<<"GlobalTableArn">>, #ddb2_global_table_description.global_table_arn, fun id/2},
      {<<"GlobalTableName">>, #ddb2_global_table_description.global_table_name, fun id/2},
      {<<"GlobalTableStatus">>, #ddb2_global_table_description.global_table_status, fun undynamize_global_table_status/2},
      {<<"ReplicationGroup">>,  #ddb2_global_table_description.replication_group, fun undynamize_replica_descriptions/2}
    ]}.

-spec global_table_record() -> record_desc().
global_table_record() ->
    {#ddb2_global_table{},
     [{<<"GlobalTableName">>, #ddb2_global_table.global_table_name, fun id/2},
      {<<"ReplicationGroup">>,  #ddb2_global_table.replication_group, fun undynamize_replicas/2}
    ]}.

-spec restore_summary_record() -> record_desc().
restore_summary_record() ->
  {#ddb2_restore_summary{},
    [{<<"RestoreDateTime">>, #ddb2_restore_summary.restore_date_time, fun id/2},
      {<<"RestoreInProgress">>,  #ddb2_restore_summary.restore_in_progress, fun id/2},
      {<<"SourceBackupArn">>,  #ddb2_restore_summary.source_backup_arn, fun id/2},
      {<<"SourceTableArn">>,  #ddb2_restore_summary.source_table_arn, fun id/2}
    ]}.

-spec auto_scaling_target_tracking_scaling_policy_configuration_description_record() -> record_desc().
auto_scaling_target_tracking_scaling_policy_configuration_description_record() ->
    {#ddb2_auto_scaling_target_tracking_scaling_policy_configuration_description{},
     [{<<"TargetValue">>, #ddb2_auto_scaling_target_tracking_scaling_policy_configuration_description.target_value, fun id/2},
      {<<"DisableScaleIn">>, #ddb2_auto_scaling_target_tracking_scaling_policy_configuration_description.disable_scale_in, fun id/2},
      {<<"ScaleInCooldown">>, #ddb2_auto_scaling_target_tracking_scaling_policy_configuration_description.scale_in_cooldown, fun id/2},
      {<<"ScaleOutCooldown">>, #ddb2_auto_scaling_target_tracking_scaling_policy_configuration_description.scale_out_cooldown, fun id/2}]}.

-spec auto_scaling_policy_description_record() -> record_desc().
auto_scaling_policy_description_record() ->
    {#ddb2_auto_scaling_policy_description{},
     [{<<"PolicyName">>, #ddb2_auto_scaling_policy_description.policy_name, fun id/2},
      {<<"TargetTrackingScalingPolicyConfiguration">>, #ddb2_auto_scaling_policy_description.target_tracking_scaling_policy_configuration,
       fun(V, Opts) -> undynamize_record(auto_scaling_target_tracking_scaling_policy_configuration_description_record(), V, Opts) end}]}.

-spec auto_scaling_settings_description_record() -> record_desc().
auto_scaling_settings_description_record() ->
    {#ddb2_auto_scaling_settings_description{},
     [{<<"AutoScalingDisabled">>, #ddb2_auto_scaling_settings_description.auto_scaling_disabled, fun id/2},
      {<<"AutoScalingRoleArn">>, #ddb2_auto_scaling_settings_description.auto_scaling_role_arn, fun id/2},
      {<<"MaximumUnits">>, #ddb2_auto_scaling_settings_description.maximum_units, fun id/2},
      {<<"MinimumUnits">>, #ddb2_auto_scaling_settings_description.minimum_units, fun id/2},
      {<<"ScalingPolicies">>, #ddb2_auto_scaling_settings_description.scaling_policies,
       fun(V, Opts) -> [undynamize_record(auto_scaling_policy_description_record(), I, Opts) || I <- V] end}]}.

-spec replica_global_secondary_index_settings_description_record() -> record_desc().
replica_global_secondary_index_settings_description_record() ->
    {#ddb2_replica_global_secondary_index_settings_description{},
     [{<<"IndexName">>, #ddb2_replica_global_secondary_index_settings_description.index_name, fun id/2},
      {<<"IndexStatus">>, #ddb2_replica_global_secondary_index_settings_description.index_status, fun undynamize_index_status/2},
      {<<"ProvisionedReadCapacityAutoScalingSettings">>, #ddb2_replica_global_secondary_index_settings_description.provisioned_read_capacity_auto_scaling_settings,
       fun(V, Opts) -> undynamize_record(auto_scaling_settings_description_record(), V, Opts) end},
      {<<"ProvisionedReadCapacityUnits">>, #ddb2_replica_global_secondary_index_settings_description.provisioned_read_capacity_units, fun id/2},
      {<<"ProvisionedWriteCapacityAutoScalingSettings">>, #ddb2_replica_global_secondary_index_settings_description.provisioned_write_capacity_auto_scaling_settings,
       fun(V, Opts) -> undynamize_record(auto_scaling_settings_description_record(), V, Opts) end},
      {<<"ProvisionedWriteCapacityUnits">>, #ddb2_replica_global_secondary_index_settings_description.provisioned_write_capacity_units, fun id/2}]}.

-spec replica_global_secondary_index_auto_scaling_description_record() -> record_desc().
replica_global_secondary_index_auto_scaling_description_record() ->
    {#ddb2_replica_global_secondary_index_auto_scaling_description{},
     [{<<"IndexName">>, #ddb2_replica_global_secondary_index_auto_scaling_description.index_name, fun id/2},
      {<<"IndexStatus">>, #ddb2_replica_global_secondary_index_auto_scaling_description.index_status, fun undynamize_index_status/2},
      {<<"ProvisionedReadCapacityAutoScalingSettings">>, #ddb2_replica_global_secondary_index_auto_scaling_description.provisioned_read_capacity_auto_scaling_settings,
       fun(V, Opts) -> undynamize_record(auto_scaling_settings_description_record(), V, Opts) end},
      {<<"ProvisionedWriteCapacityAutoScalingSettings">>, #ddb2_replica_global_secondary_index_auto_scaling_description.provisioned_write_capacity_auto_scaling_settings,
       fun(V, Opts) -> undynamize_record(auto_scaling_settings_description_record(), V, Opts) end}]}.

-spec replica_settings_description_record() -> record_desc().
replica_settings_description_record() ->
    {#ddb2_replica_settings_description{},
     [{<<"RegionName">>, #ddb2_replica_settings_description.region_name, fun id/2},
      {<<"ReplicaBillingModeSummary">>, #ddb2_replica_settings_description.replica_billing_mode_summary, fun undynamize_billing_mode_summary/2},
      {<<"ReplicaGlobalSecondaryIndexSettings">>, #ddb2_replica_settings_description.replica_global_secondary_index_settings,
       fun(V, Opts) -> [undynamize_record(replica_global_secondary_index_settings_description_record(), I, Opts) || I <- V] end},
      {<<"ReplicaProvisionedReadCapacityAutoScalingSettings">>, #ddb2_replica_settings_description.replica_provisioned_read_capacity_auto_scaling_settings,
       fun(V, Opts) -> undynamize_record(auto_scaling_settings_description_record(), V, Opts) end},
      {<<"ReplicaProvisionedReadCapacityUnits">>, #ddb2_replica_settings_description.replica_provisioned_read_capacity_units, fun id/2},
      {<<"ReplicaProvisionedWriteCapacityAutoScalingSettings">>, #ddb2_replica_settings_description.replica_provisioned_write_capacity_auto_scaling_settings,
       fun(V, Opts) -> undynamize_record(auto_scaling_settings_description_record(), V, Opts) end},
      {<<"ReplicaProvisionedWriteCapacityUnits">>, #ddb2_replica_settings_description.replica_provisioned_write_capacity_units, fun id/2},
      {<<"ReplicaStatus">>, #ddb2_replica_settings_description.replica_status, fun undynamize_replica_status/2}]}.

-spec provisioned_throughput_override_record() -> record_desc().
provisioned_throughput_override_record() ->
    {#ddb2_provisioned_throughput_override{},
     [{<<"ReadCapacityUnits">>, #ddb2_provisioned_throughput_override.read_capacity_units, fun id/2}]}.

undynamize_provisioned_throughput_override(V, Opts) ->
    undynamize_record(provisioned_throughput_override_record(), V, Opts).

-spec replica_global_secondary_index_description_record() -> record_desc().
replica_global_secondary_index_description_record() ->
    {#ddb2_replica_global_secondary_index_description{},
     [{<<"IndexName">>, #ddb2_replica_global_secondary_index_description.index_name, fun id/2},
      {<<"ProvisionedThroughputOverride">>, #ddb2_replica_global_secondary_index_description.provisioned_throughput_override,
       fun undynamize_provisioned_throughput_override/2}]}.

-spec replica_description_record() -> record_desc().
replica_description_record() ->
    {#ddb2_replica_description{},
     [{<<"GlobalSecondaryIndexes">>, #ddb2_replica_description.global_secondary_indexes,
       fun(V, Opts) -> [undynamize_record(replica_global_secondary_index_description_record(), I, Opts) || I <- V] end},
      {<<"KMSMasterKeyId">>, #ddb2_replica_description.kms_master_key_id, fun id/2},
      {<<"ProvisionedThroughputOverride">>, #ddb2_replica_description.provisioned_throughput_override, fun undynamize_provisioned_throughput_override/2},
      {<<"RegionName">>, #ddb2_replica_description.region_name, fun id/2},
      {<<"ReplicaStatus">>, #ddb2_replica_description.replica_status, fun undynamize_replica_status/2},
      {<<"ReplicaStatusDescription">>, #ddb2_replica_description.replica_status_description, fun id/2},
      {<<"ReplicaStatusPercentProgress">>, #ddb2_replica_description.replica_status_percent_progress, fun id/2}]}.

-spec replica_auto_scaling_description_record() -> record_desc().
replica_auto_scaling_description_record() ->
    {#ddb2_replica_auto_scaling_description{},
     [{<<"GlobalSecondaryIndexes">>, #ddb2_replica_auto_scaling_description.global_secondary_indexes,
       fun(V, Opts) -> [undynamize_record(replica_global_secondary_index_auto_scaling_description_record(), I, Opts) || I <- V] end},
      {<<"RegionName">>, #ddb2_replica_auto_scaling_description.region_name, fun id/2},
      {<<"ReplicaProvisionedReadCapacityAutoScalingSettings">>, #ddb2_replica_auto_scaling_description.replica_provisioned_read_capacity_auto_scaling_settings,
       fun(V, Opts) -> undynamize_record(auto_scaling_settings_description_record(), V, Opts) end},
      {<<"ReplicaProvisionedWriteCapacityAutoScalingSettings">>, #ddb2_replica_auto_scaling_description.replica_provisioned_write_capacity_auto_scaling_settings,
       fun(V, Opts) -> undynamize_record(auto_scaling_settings_description_record(), V, Opts) end},
      {<<"ReplicaStatus">>, #ddb2_replica_auto_scaling_description.replica_status, fun undynamize_replica_status/2}]}.

-spec table_auto_scaling_description_record() -> record_desc().
table_auto_scaling_description_record() ->
    {#ddb2_table_auto_scaling_description{},
     [{<<"Replicas">>, #ddb2_table_auto_scaling_description.replicas,
       fun(V, Opts) -> [undynamize_record(replica_auto_scaling_description_record(), I, Opts) || I <- V] end},
      {<<"TableName">>, #ddb2_table_auto_scaling_description.table_name, fun id/2},
      {<<"TableStatus">>, #ddb2_table_auto_scaling_description.table_status, fun undynamize_table_status/2}]}.

-spec table_description_record() -> record_desc().
table_description_record() ->
    {#ddb2_table_description{},
     [{<<"AttributeDefinitions">>, #ddb2_table_description.attribute_definitions, fun undynamize_attr_defs/2},
      {<<"BillingModeSummary">>, #ddb2_table_description.billing_mode_summary, fun undynamize_billing_mode_summary/2},
      {<<"CreationDateTime">>, #ddb2_table_description.creation_date_time, fun id/2},
      {<<"DeletionProtectionEnabled">>, #ddb2_table_description.deletion_protection_enabled, fun id/2},
      {<<"GlobalSecondaryIndexes">>, #ddb2_table_description.global_secondary_indexes,
       fun(V, Opts) -> [undynamize_record(global_secondary_index_description_record(), I, Opts) || I <- V] end},
      {<<"GlobalTableVersion">>, #ddb2_table_description.global_table_version, fun id/2},
      {<<"ItemCount">>, #ddb2_table_description.item_count, fun id/2},
      {<<"KeySchema">>, #ddb2_table_description.key_schema, fun undynamize_key_schema/2},
      {<<"LatestStreamArn">>, #ddb2_table_description.latest_stream_arn, fun id/2},
      {<<"LatestStreamLabel">>, #ddb2_table_description.latest_stream_label, fun id/2},
      {<<"LocalSecondaryIndexes">>, #ddb2_table_description.local_secondary_indexes,
       fun(V, Opts) -> [undynamize_record(local_secondary_index_description_record(), I, Opts) || I <- V] end},
      {<<"ProvisionedThroughput">>, #ddb2_table_description.provisioned_throughput,
       fun(V, Opts) -> undynamize_record(provisioned_throughput_description_record(), V, Opts) end},
      {<<"Replicas">>, #ddb2_table_description.replicas,
       fun(V, Opts) -> [undynamize_record(replica_description_record(), I, Opts) || I <- V] end},
      {<<"RestoreSummary">>, #ddb2_table_description.restore_summary,
       fun(V, Opts) -> undynamize_record(restore_summary_record(), V, Opts) end},
      {<<"SSEDescription">>, #ddb2_table_description.sse_description, fun undynamize_sse_description/2},
      {<<"StreamSpecification">>, #ddb2_table_description.stream_specification, fun undynamize_stream_specification/2},
      {<<"TableArn">>, #ddb2_table_description.table_arn, fun id/2},
      {<<"TableName">>, #ddb2_table_description.table_name, fun id/2},
      {<<"TableSizeBytes">>, #ddb2_table_description.table_size_bytes, fun id/2},
      {<<"TableStatus">>, #ddb2_table_description.table_status, fun undynamize_table_status/2}
     ]}.

%%%------------------------------------------------------------------------------
%%% BatchGetItem
%%%------------------------------------------------------------------------------

-type batch_get_item_opt() :: return_consumed_capacity_opt() |
                              out_opt() |
                              no_request_opt() |
                              return_maps_opt().
-type batch_get_item_opts() :: [batch_get_item_opt()].

-spec batch_get_item_opts() -> opt_table().
batch_get_item_opts() ->
    [return_consumed_capacity_opt()].

-type batch_get_item_request_item_opt() :: expression_attribute_names_opt() |
                                           projection_expression_opt() |
                                           attributes_to_get_opt() |
                                           consistent_read_opt().
-type batch_get_item_request_item_opts() :: [batch_get_item_request_item_opt()].

-spec batch_get_item_request_item_opts() -> opt_table().
batch_get_item_request_item_opts() ->
    [expression_attribute_names_opt(),
     projection_expression_opt(),
     attributes_to_get_opt(),
     consistent_read_opt()].

-type batch_get_item_request_item() :: {table_name(), [key(),...], batch_get_item_request_item_opts()} |
                                       {table_name(), [key(),...]}.

-spec dynamize_batch_get_item_request_item(batch_get_item_request_item()) 
                                          -> json_pair().
dynamize_batch_get_item_request_item({Table, Keys}) ->
    dynamize_batch_get_item_request_item({Table, Keys, []});
dynamize_batch_get_item_request_item({Table, Keys, Opts}) ->
    {AwsOpts, []} = opts(batch_get_item_request_item_opts(), Opts),
    {Table, [{<<"Keys">>, [dynamize_key(K) || K <- Keys]}] ++ AwsOpts}.

-type batch_get_item_request_items() :: maybe_list(batch_get_item_request_item()).
-spec dynamize_batch_get_item_request_items(batch_get_item_request_items()) -> [json_pair()].
dynamize_batch_get_item_request_items(Request) ->
    dynamize_maybe_list(fun dynamize_batch_get_item_request_item/1, Request).

-spec batch_get_item_request_item_folder({binary(), term()}, batch_get_item_request_item()) 
                                        -> batch_get_item_request_item().
batch_get_item_request_item_folder({<<"Keys">>, Keys}, {Table, _, Opts}) ->
    {Table, [undynamize_typed_key(K, []) || K <- Keys], Opts};
batch_get_item_request_item_folder({<<"ExpressionAttributeNames">>, Value}, {Table, Keys, Opts}) ->
    {Table, Keys, [{expression_attribute_names, undynamize_expression_attribute_names(Value, [])} | Opts]};
batch_get_item_request_item_folder({<<"ProjectionExpression">>, Value}, {Table, Keys, Opts}) ->
    {Table, Keys, [{projection_expression, undynamize_expression(Value, [])} | Opts]};
batch_get_item_request_item_folder({<<"AttributesToGet">>, Value}, {Table, Keys, Opts}) ->
    {Table, Keys, [{attributes_to_get, Value} | Opts]};
batch_get_item_request_item_folder({<<"ConsistentRead">>, Value}, {Table, Keys, Opts}) ->
    {Table, Keys, [{consistent_read, Value} | Opts]}.

-spec undynamize_batch_get_item_request_item(table_name(), jsx:json_term(), undynamize_opts())
                                            -> batch_get_item_request_item().
undynamize_batch_get_item_request_item(Table, Json, _) ->
    lists:foldl(fun batch_get_item_request_item_folder/2, {Table, [], []}, Json).

undynamize_batch_get_item_response({Table, Json}, Opts) ->
    #ddb2_batch_get_item_response{
       table = Table,
       items = undynamize_items(Json, Opts)}.

undynamize_batch_get_item_responses(Response, Opts) ->
    undynamize_object(fun undynamize_batch_get_item_response/2, Response, Opts).

-spec batch_get_item_record() -> record_desc().    
batch_get_item_record() ->
    {#ddb2_batch_get_item{},
     [{<<"ConsumedCapacity">>, #ddb2_batch_get_item.consumed_capacity, fun undynamize_consumed_capacity_list/2},
      {<<"Responses">>, #ddb2_batch_get_item.responses, fun undynamize_batch_get_item_responses/2},
      {<<"UnprocessedKeys">>, #ddb2_batch_get_item.unprocessed_keys,
       fun(V, Opts) -> undynamize_object(fun({Table, Json}, Opts2) ->
                                                 undynamize_batch_get_item_request_item(Table, Json, Opts2)
                                         end, V, Opts)
       end}
     ]}.

-type batch_get_item_return() :: ddb_return(#ddb2_batch_get_item{} | #ddb2_request{}, [out_item()]).

-spec batch_get_item(batch_get_item_request_items()) -> batch_get_item_return().
batch_get_item(RequestItems) ->
    batch_get_item(RequestItems, [], default_config()).

-spec batch_get_item(batch_get_item_request_items(), batch_get_item_opts()) -> batch_get_item_return().
batch_get_item(RequestItems, Opts) ->
    batch_get_item(RequestItems, Opts, default_config()).

%%------------------------------------------------------------------------------
%% @doc 
%% DynamoDB API:
%% [http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_BatchGetItem.html]
%%
%% ===Example===
%%
%% Get 4 items total from 2 tables.
%%
%% `
%% {ok, Record} =
%%     erlcloud_ddb2:batch_get_item(
%%       [{<<"Forum">>, 
%%         [{<<"Name">>, {s, <<"Amazon DynamoDB">>}},
%%          {<<"Name">>, {s, <<"Amazon RDS">>}}, 
%%          {<<"Name">>, {s, <<"Amazon Redshift">>}}],
%%         [{projection_expression, <<"Name, Threads, Messages, Views">>}]},
%%        {<<"Thread">>, 
%%         [[{<<"ForumName">>, {s, <<"Amazon DynamoDB">>}}, 
%%           {<<"Subject">>, {s, <<"Concurrent reads">>}}]],
%%         [{projection_expression, <<"Tags, Message">>}]}],
%%       [{return_consumed_capacity, total},
%%        {out, record}]),
%% '
%%
%% See also erlcloud_ddb_util:get_all which provides retry and parallel batching.
%%
%% @end
%%------------------------------------------------------------------------------
-spec batch_get_item(batch_get_item_request_items(), batch_get_item_opts(), aws_config()) -> 
                            batch_get_item_return().
batch_get_item(RequestItems, Opts, Config) ->
    {AwsOpts, DdbOpts} = opts(batch_get_item_opts(), Opts),
    Return = erlcloud_ddb_impl:request(
               Config,
               "DynamoDB_20120810.BatchGetItem",
               [{<<"RequestItems">>, dynamize_batch_get_item_request_items(RequestItems)}]
                ++ AwsOpts,
                DdbOpts),
    case out(Return, 
             fun(Json, UOpts) -> undynamize_record(batch_get_item_record(), Json, UOpts) end, 
             DdbOpts) of
        {simple, #ddb2_batch_get_item{unprocessed_keys = [_|_]}} ->
            %% Return an error on unprocessed results.
            {error, unprocessed};
        {simple, #ddb2_batch_get_item{unprocessed_keys = [], responses = Responses}} ->
            %% Simple return for batch_get_item is all items from all tables in a single list
            {ok, lists:flatmap(fun(#ddb2_batch_get_item_response{items = I}) -> I end, Responses)};
        {ok, _} = Out -> Out;
        {error, _} = Out -> Out
    end.

%%%------------------------------------------------------------------------------
%%% BatchWriteItem
%%%------------------------------------------------------------------------------

-type batch_write_item_opt() :: return_consumed_capacity_opt() |
                                return_item_collection_metrics_opt() |
                                out_opt() |
                                no_request_opt() |
                                return_maps_opt().
-type batch_write_item_opts() :: [batch_write_item_opt()].

-spec batch_write_item_opts() -> opt_table().
batch_write_item_opts() ->
    [return_consumed_capacity_opt(),
     return_item_collection_metrics_opt()].

-type batch_write_item_put() :: {put, in_item()}.
-type batch_write_item_delete() :: {delete, key()}.
-type batch_write_item_request() :: batch_write_item_put() | batch_write_item_delete().
-type batch_write_item_request_item() :: {table_name(), [batch_write_item_request()]}.

-spec dynamize_batch_write_item_request(batch_write_item_request()) -> jsx:json_term().
dynamize_batch_write_item_request({put, Item}) ->
    [{<<"PutRequest">>, [{<<"Item">>, dynamize_item(Item)}]}];
dynamize_batch_write_item_request({delete, Key}) ->
    [{<<"DeleteRequest">>, [{<<"Key">>, dynamize_key(Key)}]}].

-spec dynamize_batch_write_item_request_item(batch_write_item_request_item()) 
                                          -> json_pair().
dynamize_batch_write_item_request_item({Table, Requests}) ->
    {Table, [dynamize_batch_write_item_request(R) || R <- Requests]}.

-type batch_write_item_request_items() :: maybe_list(batch_write_item_request_item()).
-spec dynamize_batch_write_item_request_items(batch_write_item_request_items()) -> [json_pair()].
dynamize_batch_write_item_request_items(Request) ->
    dynamize_maybe_list(fun dynamize_batch_write_item_request_item/1, Request).

-spec batch_write_item_request_folder([{binary(), term()}], batch_write_item_request_item()) 
                                     -> batch_write_item_request_item().
batch_write_item_request_folder([{<<"PutRequest">>, [{<<"Item">>, Item}]}], {Table, Requests}) ->
    {Table, [{put, undynamize_item_typed(Item, [])} | Requests]};
batch_write_item_request_folder([{<<"DeleteRequest">>, [{<<"Key">>, Key}]}], {Table, Requests}) ->
    {Table, [{delete, undynamize_typed_key(Key, [])} | Requests]}.

-spec undynamize_batch_write_item_request_item(table_name(), jsx:json_term(), undynamize_opts())
                                              -> batch_write_item_request_item().
undynamize_batch_write_item_request_item(Table, Json, _) ->
    {Table, Requests} = lists:foldl(fun batch_write_item_request_folder/2, {Table, []}, Json),
    {Table, lists:reverse(Requests)}.

-spec batch_write_item_record() -> record_desc().
batch_write_item_record() ->
    {#ddb2_batch_write_item{},
     [{<<"ConsumedCapacity">>, #ddb2_batch_write_item.consumed_capacity, fun undynamize_consumed_capacity_list/2},
      {<<"ItemCollectionMetrics">>, #ddb2_batch_write_item.item_collection_metrics,
       fun(V, Opts) -> undynamize_object(
                         fun({Table, Json}, Opts2) ->
                                 undynamize_item_collection_metric_list(Table, Json, Opts2)
                         end, V, Opts)
       end},
      {<<"UnprocessedItems">>, #ddb2_batch_write_item.unprocessed_items,
       fun(V, Opts) -> undynamize_object(
                         fun({Table, Json}, Opts2) ->
                                 undynamize_batch_write_item_request_item(Table, Json, Opts2)
                         end, V, Opts)
       end}
     ]}.

-type batch_write_item_return() :: ddb_return(#ddb2_batch_write_item{} | #ddb2_request{}, #ddb2_batch_write_item{}).

-spec batch_write_item(batch_write_item_request_items()) -> batch_write_item_return().
batch_write_item(RequestItems) ->
    batch_write_item(RequestItems, [], default_config()).

-spec batch_write_item(batch_write_item_request_items(), batch_write_item_opts()) -> batch_write_item_return().
batch_write_item(RequestItems, Opts) ->
    batch_write_item(RequestItems, Opts, default_config()).

%%------------------------------------------------------------------------------
%% @doc 
%% DynamoDB API:
%% [http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_BatchWriteItem.html]
%%
%% ===Example===
%%
%% Put 4 items in the "Forum" table.
%%
%% `
%% {ok, Record} =
%%     erlcloud_ddb2:batch_write_item(
%%       [{<<"Forum">>, 
%%         [{put, [{<<"Name">>, {s, <<"Amazon DynamoDB">>}},
%%                 {<<"Category">>, {s, <<"Amazon Web Services">>}}]},
%%          {put, [{<<"Name">>, {s, <<"Amazon RDS">>}},
%%                 {<<"Category">>, {s, <<"Amazon Web Services">>}}]},
%%          {put, [{<<"Name">>, {s, <<"Amazon Redshift">>}},
%%                 {<<"Category">>, {s, <<"Amazon Web Services">>}}]},
%%          {put, [{<<"Name">>, {s, <<"Amazon ElastiCache">>}},
%%                 {<<"Category">>, {s, <<"Amazon Web Services">>}}]}
%%         ]}],
%%       [{return_consumed_capacity, total},
%%        {out, record}]),
%% '
%% @end
%%------------------------------------------------------------------------------
-spec batch_write_item(batch_write_item_request_items(), batch_write_item_opts(), aws_config()) -> 
                              batch_write_item_return().
batch_write_item(RequestItems, Opts, Config) ->
    {AwsOpts, DdbOpts} = opts(batch_write_item_opts(), Opts),
    Return = erlcloud_ddb_impl:request(
               Config,
               "DynamoDB_20120810.BatchWriteItem",
               [{<<"RequestItems">>, dynamize_batch_write_item_request_items(RequestItems)}]
               ++ AwsOpts,
               DdbOpts),
    case out(Return, 
             fun(Json, UOpts) -> undynamize_record(batch_write_item_record(), Json, UOpts) end, 
             DdbOpts) of
        {simple, #ddb2_batch_write_item{unprocessed_items = [_|_]}} ->
            %% TODO resend unprocessed items automatically (or controlled by option). 
            %% For now return an error - you can handle manually if you don't use simple.
            {error, unprocessed};
        {simple, Record} -> {ok, Record};
        {ok, _} = Out -> Out;
        {error, _} = Out -> Out
    end.

%%%------------------------------------------------------------------------------
%%% CreateBackup
%%%------------------------------------------------------------------------------

-spec undynamize_backup_details() -> record_desc().
undynamize_backup_details() ->
    {#ddb2_backup_details{},
     [{<<"BackupArn">>, #ddb2_backup_details.backup_arn, fun id/2},
      {<<"BackupCreationDateTime">>, #ddb2_backup_details.backup_creation_date_time, fun id/2},
      {<<"BackupName">>, #ddb2_backup_details.backup_name, fun id/2},
      {<<"BackupSizeBytes">>, #ddb2_backup_details.backup_size_Bytes, fun id/2},
      {<<"BackupStatus">>, #ddb2_backup_details.backup_status, fun undynamize_backup_status/2}
     ]}.

-spec undynamize_create_backup(jsx:json_term(), undynamize_opts())  -> record_desc().
undynamize_create_backup(BackupInfo, Opts) ->
    undynamize_record(undynamize_backup_details(), BackupInfo, Opts).

-spec create_backup_record() -> record_desc().
create_backup_record() ->
    {#ddb2_create_backup{},
      [{<<"BackupDetails">>, #ddb2_create_backup.backup_details, fun undynamize_create_backup/2}]}.

-type create_backup_return() :: ddb_return(#ddb2_create_backup{}, #ddb2_backup_details{}).

-spec create_backup(binary(), table_name()) -> create_backup_return().
create_backup(BackupName, TableName)
    when is_binary(BackupName), is_binary(TableName) ->
    create_backup(BackupName, TableName, [], default_config()).

-spec create_backup(binary(), table_name(), ddb_opts()) -> create_backup_return().
create_backup(BackupName, TableName, Opts)
    when is_binary(BackupName), is_binary(TableName) ->
    create_backup(BackupName, TableName, Opts, default_config()).

%%------------------------------------------------------------------------------
%% @doc
%% DynamoDB API:
%% [https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_CreateBackup.html]
%%
%% ===Example===
%%
%% Creates a backup for an existing table.
%%
%% `
%% {ok, BackupDetails} =
%%     erlcloud_ddb2:create_backup(<<"Forum_Backup">>, <<"Forum">>),
%% '
%% @end
%%-------------------------------------------------------------------------------
-spec create_backup(binary(), table_name(), ddb_opts(), aws_config()) -> create_backup_return().
create_backup(BackupName, TableName, Opts, Config)
    when is_binary(BackupName), is_binary(TableName) ->
    {_AwsOpts, DdbOpts} = opts([], Opts),
    Return = erlcloud_ddb_impl:request(
     Config,
     "DynamoDB_20120810.CreateBackup",
     [{<<"TableName">>, TableName},
      {<<"BackupName">>, BackupName}],
      DdbOpts),
    out(Return, fun(Json, UOpts) -> undynamize_record(create_backup_record(), Json, UOpts) end,
        DdbOpts, #ddb2_create_backup.backup_details).

%%%------------------------------------------------------------------------------
%%% CreateGlobalTable
%%%------------------------------------------------------------------------------

-spec dynamize_replica(replica()) -> jsx:json_term().
dynamize_replica(#ddb2_replica{region_name = Region}) ->
    [{<<"RegionName">>, Region}];
dynamize_replica({region_name, Region}) ->
    [{<<"RegionName">>, Region}].

-spec create_global_table_record() -> record_desc().
create_global_table_record() ->
    {#ddb2_create_global_table{},
     [{<<"GlobalTableDescription">>, #ddb2_create_global_table.global_table_description, 
       fun(V, Opts) -> undynamize_record(global_table_description_record(), V, Opts) end}
     ]}. 

-type create_global_table_return() :: ddb_return(#ddb2_create_global_table{}, #ddb2_global_table_description{}).

-spec create_global_table(table_name(), maybe_list(replica()))
                         -> create_global_table_return().
create_global_table(GlobalTableName, ReplicationGroup) ->
    create_global_table(GlobalTableName, ReplicationGroup, [], default_config()).

-spec create_global_table(table_name(), maybe_list(replica()), 
                          ddb_opts() | aws_config())
                         -> create_global_table_return().
create_global_table(GlobalTableName, ReplicationGroup, Opts) when is_list(Opts) ->
    create_global_table(GlobalTableName, ReplicationGroup, Opts, default_config());
create_global_table(GlobalTableName, ReplicationGroup, Config) when is_record(Config, aws_config) ->
    create_global_table(GlobalTableName, ReplicationGroup, [], Config).

%%------------------------------------------------------------------------------
%% @doc 
%% DynamoDB API:
%% [https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_CreateGlobalTable.html]
%%
%% ===Example===
%%
%% Create a global table called "Thread" in us-east-1 and eu-west-1.
%%
%% `
%% {ok, Record} =
%%     erlcloud_ddb2:create_global_table(<<"Thread">>,
%%                                       [{region_name, <<"us-east-1">>},
%%                                        {region_name, <<"eu-west-1">>}]),
%% '
%% @end
%%------------------------------------------------------------------------------

-spec create_global_table(table_name(), [replica()], ddb_opts(),
                          aws_config())
                         -> create_global_table_return().
create_global_table(GlobalTableName, ReplicationGroup, Opts, Config) ->
    {[], DdbOpts} = opts([], Opts),
    Return = erlcloud_ddb_impl:request(
               Config,
               "DynamoDB_20120810.CreateGlobalTable",
               [{<<"GlobalTableName">>, GlobalTableName},
                {<<"ReplicationGroup">>, dynamize_maybe_list(fun dynamize_replica/1, ReplicationGroup)}],
               DdbOpts),
    out(Return, fun(Json, UOpts) -> undynamize_record(create_global_table_record(), Json, UOpts) end, 
        DdbOpts, #ddb2_create_global_table.global_table_description).

%%%------------------------------------------------------------------------------
%%% CreateTable
%%%------------------------------------------------------------------------------

-type local_secondary_index_def() :: {index_name(), range_key_name(), projection()}.
-type local_secondary_indexes() :: maybe_list(local_secondary_index_def()).
-type global_secondary_indexes() :: maybe_list(global_secondary_index_def()).

-spec dynamize_billing_mode(billing_mode()) -> binary().
dynamize_billing_mode(provisioned) -> <<"PROVISIONED">>;
dynamize_billing_mode(pay_per_request) -> <<"PAY_PER_REQUEST">>.

-spec dynamize_local_secondary_index(hash_key_name(), local_secondary_index_def()) -> jsx:json_term().
dynamize_local_secondary_index(HashKey, {IndexName, RangeKey, Projection}) ->
    [{<<"IndexName">>, IndexName},
     {<<"KeySchema">>, dynamize_key_schema({HashKey, RangeKey})},
     {<<"Projection">>, dynamize_projection(Projection)}].

-spec dynamize_local_secondary_indexes(key_schema(), local_secondary_indexes()) -> jsx:json_term().
dynamize_local_secondary_indexes({HashKey, _RangeKey}, Value) ->
    dynamize_maybe_list(fun(I) -> dynamize_local_secondary_index(HashKey, I) end, Value).

-spec dynamize_global_secondary_indexes(global_secondary_indexes()) -> jsx:json_term().
dynamize_global_secondary_indexes(Value) ->
    dynamize_maybe_list(fun dynamize_global_secondary_index/1, Value).

-spec dynamize_sse_specification(sse_specification()) -> jsx:json_term().
dynamize_sse_specification({enabled, Enabled}) when is_boolean(Enabled) ->
    [{<<"Enabled">>, Enabled}].

-type create_table_opt() :: {billing_mode, billing_mode()} |
                            {local_secondary_indexes, local_secondary_indexes()} |
                            {global_secondary_indexes, global_secondary_indexes()} |
                            {provisioned_throughput, {read_units(), write_units()}} |
                            {sse_specification, sse_specification()} |
                            {stream_specification, stream_specification()} |
                            boolean_opt(deletion_protection_enabled).
-type create_table_opts() :: [create_table_opt()].

-spec create_table_opts(key_schema()) -> opt_table().
create_table_opts(KeySchema) ->
    [{billing_mode, <<"BillingMode">>, fun dynamize_billing_mode/1},
     {local_secondary_indexes, <<"LocalSecondaryIndexes">>,
      fun(V) -> dynamize_local_secondary_indexes(KeySchema, V) end},
     {global_secondary_indexes, <<"GlobalSecondaryIndexes">>,
      fun dynamize_global_secondary_indexes/1},
     {provisioned_throughput, <<"ProvisionedThroughput">>, fun dynamize_provisioned_throughput/1},
     {sse_specification, <<"SSESpecification">>, fun dynamize_sse_specification/1},
     {stream_specification, <<"StreamSpecification">>, fun dynamize_stream_specification/1},
     {deletion_protection_enabled, <<"DeletionProtectionEnabled">>, fun id/1}].

-spec create_table_record() -> record_desc().
create_table_record() ->
    {#ddb2_create_table{},
     [{<<"TableDescription">>, #ddb2_create_table.table_description, 
       fun(V, Opts) -> undynamize_record(table_description_record(), V, Opts) end}
     ]}. 

-type create_table_return() :: ddb_return(#ddb2_create_table{}, #ddb2_table_description{}).

-spec create_table(table_name(), attr_defs(), key_schema(), create_table_opts())
                  -> create_table_return().
create_table(Table, AttrDefs, KeySchema, Opts) ->
    create_table(Table, AttrDefs, KeySchema, Opts, default_config()).

%%------------------------------------------------------------------------------
%% @doc
%% DynamoDB API:
%% [http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_CreateTable.html]
%%
%% ===Example===
%%
%% Create a table with hash key "ForumName" and range key "Subject"
%% with a local secondary index on "LastPostDateTime"
%% and a global secondary index on "Subject" as hash key and "LastPostDateTime"
%% as range key, read and write capacity 10, projecting all fields
%%
%% `
%% {ok, Description} =
%%     erlcloud_ddb2:create_table(
%%       <<"Thread">>,
%%       [{<<"ForumName">>, s},
%%        {<<"Subject">>, s},
%%        {<<"LastPostDateTime">>, s}],
%%       {<<"ForumName">>, <<"Subject">>},
%%       [{provisioned_throughput, {5, 5}},
%%        {local_secondary_indexes,
%%         [{<<"LastPostIndex">>, <<"LastPostDateTime">>, keys_only}]},
%%        {global_secondary_indexes, [
%%          {<<"SubjectTimeIndex">>, {<<"Subject">>, <<"LastPostDateTime">>}, all, 10, 10}
%%         ]}
%%       ]),
%% '
%% @end
%%------------------------------------------------------------------------------
-spec create_table(table_name(), attr_defs(), key_schema(), read_units(), write_units())
                  -> create_table_return();
                  (table_name(), attr_defs(), key_schema(), create_table_opts(), aws_config())
                  -> create_table_return().
create_table(Table, AttrDefs, KeySchema, ReadUnits, WriteUnits)
    when is_integer(ReadUnits), is_integer(WriteUnits) ->
    create_table(Table, AttrDefs, KeySchema, ReadUnits, WriteUnits, [], default_config());
create_table(Table, AttrDefs, KeySchema, Opts, Config) ->
    {AwsOpts, DdbOpts} = opts(create_table_opts(KeySchema), Opts),
    Return = erlcloud_ddb_impl:request(
        Config,
        "DynamoDB_20120810.CreateTable",
        [{<<"TableName">>, Table},
         {<<"AttributeDefinitions">>, dynamize_attr_defs(AttrDefs)},
         {<<"KeySchema">>, dynamize_key_schema(KeySchema)}]
        ++ AwsOpts,
        DdbOpts),
    out(Return, fun(Json, UOpts) -> undynamize_record(create_table_record(), Json, UOpts) end,
        DdbOpts, #ddb2_create_table.table_description).

-spec create_table(table_name(), attr_defs(), key_schema(), read_units(), write_units(),
                   create_table_opts())
                  -> create_table_return().
create_table(Table, AttrDefs, KeySchema, ReadUnits, WriteUnits, Opts) ->
    create_table(Table, AttrDefs, KeySchema, ReadUnits, WriteUnits, Opts, default_config()).

-spec create_table(table_name(), attr_defs(), key_schema(), read_units(), write_units(),
                   create_table_opts(), aws_config())
                  -> create_table_return().
create_table(Table, AttrDefs, KeySchema, ReadUnits, WriteUnits, Opts0, Config) ->
    Opts = [{provisioned_throughput, {ReadUnits, WriteUnits}} | Opts0],
    create_table(Table, AttrDefs, KeySchema, Opts, Config).

%%%------------------------------------------------------------------------------
%%% DeleteBackup
%%%------------------------------------------------------------------------------

-spec provisioned_throughput_description() -> record_desc().
provisioned_throughput_description() ->
    {#ddb2_provisioned_throughput{},
     [
      {<<"ReadCapacityUnits">>, #ddb2_provisioned_throughput.read_capacity_units, fun id/2},
      {<<"WriteCapacityUnits">>, #ddb2_provisioned_throughput.write_capacity_units, fun id/2}
     ]}.

-spec undynamize_source_table_details() -> record_desc().
undynamize_source_table_details() ->
    {#ddb2_source_table_details{},
     [{<<"ItemCount">>, #ddb2_source_table_details.item_count, fun id/2},
      {<<"KeySchema">>, #ddb2_source_table_details.key_schema, fun undynamize_key_schema/2},
      {<<"ProvisionedThroughput">>, #ddb2_source_table_details.provisioned_throughput,
       fun(V, Opts) -> undynamize_record(provisioned_throughput_description(), V, Opts) end},
      {<<"TableId">>, #ddb2_source_table_details.table_id, fun id/2},
      {<<"TableCreationDateTime">>, #ddb2_source_table_details.table_creation_date_time, fun id/2},
      {<<"TableArn">>, #ddb2_source_table_details.table_arn, fun id/2},
      {<<"TableName">>, #ddb2_source_table_details.table_name, fun id/2},
      {<<"TableSizeBytes">>, #ddb2_source_table_details.table_size_bytes, fun id/2}
     ]}.

-spec undynamize_global_secondary_index_info() -> record_desc().
undynamize_global_secondary_index_info() ->
 {#ddb2_global_secondary_index_info{},
  [{<<"IndexName">>, #ddb2_global_secondary_index_info.index_name, fun id/2},
   {<<"KeySchema">>, #ddb2_global_secondary_index_info.key_schema, fun undynamize_key_schema/2},
   {<<"Projection">>, #ddb2_global_secondary_index_info.projection, fun undynamize_projection/2},
   {<<"ProvisionedThroughput">>, #ddb2_global_secondary_index_info.provisioned_throughput,
    fun(V, Opts) -> undynamize_record(provisioned_throughput_description(), V, Opts) end}
  ]}.

-spec undynamize_local_secondary_index_info() -> record_desc().
undynamize_local_secondary_index_info() ->
    {#ddb2_local_secondary_index_info{},
     [{<<"IndexName">>, #ddb2_local_secondary_index_info.index_name, fun id/2},
      {<<"KeySchema">>, #ddb2_local_secondary_index_info.key_schema, fun undynamize_key_schema/2},
      {<<"Projection">>, #ddb2_local_secondary_index_info.projection, fun undynamize_projection/2}
     ]}.

-spec undynamize_source_table_feature_details() -> record_desc().
undynamize_source_table_feature_details() ->
    {#ddb2_source_table_feature_details{},
     [{<<"GlobalSecondaryIndexes">>, #ddb2_source_table_feature_details.global_secondary_indexes,
      fun(V, Opts) -> [undynamize_record(undynamize_global_secondary_index_info(), I, Opts) || I <- V] end},
      {<<"LocalSecondaryIndexes">>, #ddb2_source_table_feature_details.local_secondary_indexes,
       fun(V, Opts) -> [undynamize_record(undynamize_local_secondary_index_info(), I, Opts) || I <- V] end},
      {<<"SSEDescription">>, #ddb2_source_table_feature_details.sse_description, fun undynamize_sse_description/2},
      {<<"StreamDescription">>, #ddb2_source_table_feature_details.stream_description,
       fun undynamize_stream_specification/2},
      {<<"TimeToLiveDescription">>, #ddb2_source_table_feature_details.time_to_live_description,
       fun(V, Opts) -> undynamize_record(time_to_live_description_record(), V, Opts) end}
     ]}.

-spec undynamize_backup_description() -> record_desc().
undynamize_backup_description() ->
    {#ddb2_backup_description{},
     [{<<"BackupDetails">>, #ddb2_backup_description.backup_details,
      fun(V, Opts) -> undynamize_record(undynamize_backup_details(), V, Opts) end},
      {<<"SourceTableDetails">>, #ddb2_backup_description.source_table_details,
       fun(V, Opts) -> undynamize_record(undynamize_source_table_details(), V, Opts) end},
      {<<"SourceTableFeatureDetails">>, #ddb2_backup_description.source_table_feature_details,
       fun(V, Opts) -> undynamize_record(undynamize_source_table_feature_details(), V, Opts) end}
     ]}.

-spec delete_backup_record() -> record_desc().
delete_backup_record() ->
    {#ddb2_delete_backup{},
     [{<<"BackupDescription">>, #ddb2_delete_backup.backup_description,
      fun(V, Opts) -> undynamize_record(undynamize_backup_description(), V, Opts) end}
     ]}.

-type delete_backup_return() :: ddb_return(#ddb2_delete_backup{}, #ddb2_backup_description{}).

-spec delete_backup(binary()) -> delete_backup_return().
delete_backup(BackupArn)
    when is_binary(BackupArn) ->
    delete_backup(BackupArn, [], default_config()).

-spec delete_backup(binary(), ddb_opts()) -> delete_backup_return().
delete_backup(BackupArn, Opts)
    when is_binary(BackupArn) ->
    delete_backup(BackupArn, Opts, default_config()).

%%------------------------------------------------------------------------------
%% @doc
%% DynamoDB API:
%% [https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_DeleteBackup.html]
%%
%% ===Example===
%%
%% Deletes an existing backup of a table.
%%
%% `
%% {ok, BackupDescription} =
%%     erlcloud_ddb2:delete_backup(<<"BackupArn">>),
%% '
%% @end
%%-------------------------------------------------------------------------------
-spec delete_backup(binary(), ddb_opts(), aws_config()) -> delete_backup_return().
delete_backup(BackupArn, Opts, Config)
    when is_binary(BackupArn) ->
    {_AwsOpts, DdbOpts} = opts([], Opts),
    Return = erlcloud_ddb_impl:request(
     Config,
     "DynamoDB_20120810.DeleteBackup",
     [{<<"BackupArn">>, BackupArn}],
     DdbOpts),
    out(Return, fun(Json, UOpts) -> undynamize_record(delete_backup_record(), Json, UOpts) end,
        DdbOpts, #ddb2_delete_backup.backup_description).

%%%------------------------------------------------------------------------------
%%% DeleteItem
%%%------------------------------------------------------------------------------

-type delete_item_opt() :: expression_attribute_names_opt() |
                           expression_attribute_values_opt() |
                           condition_expression_opt() |
                           conditional_op_opt() |
                           expected_opt() | 
                           {return_values, none | all_old} |
                           return_consumed_capacity_opt() |
                           return_item_collection_metrics_opt() |
                           out_opt() |
                           no_request_opt() |
                           return_maps_opt().
-type delete_item_opts() :: [delete_item_opt()].

-spec delete_item_opts() -> opt_table().
delete_item_opts() ->
    [expression_attribute_names_opt(),
     expression_attribute_values_opt(),
     condition_expression_opt(),
     conditional_op_opt(),
     expected_opt(),
     {return_values, <<"ReturnValues">>, fun dynamize_return_value/1},
     return_consumed_capacity_opt(),
     return_item_collection_metrics_opt()].

-spec delete_item_record() -> record_desc().
delete_item_record() ->
    {#ddb2_delete_item{},
     [{<<"Attributes">>, #ddb2_delete_item.attributes, fun undynamize_item/2},
      {<<"ConsumedCapacity">>, #ddb2_delete_item.consumed_capacity, fun undynamize_consumed_capacity/2},
      {<<"ItemCollectionMetrics">>, #ddb2_delete_item.item_collection_metrics, 
       fun undynamize_item_collection_metrics/2}
     ]}.

-type delete_item_return() :: ddb_return(#ddb2_delete_item{} | #ddb2_request{}, out_item()).

-spec delete_item(table_name(), key()) -> delete_item_return().
delete_item(Table, Key) ->
    delete_item(Table, Key, [], default_config()).

-spec delete_item(table_name(), key(), delete_item_opts()) -> delete_item_return().
delete_item(Table, Key, Opts) ->
    delete_item(Table, Key, Opts, default_config()).

%%------------------------------------------------------------------------------
%% @doc 
%% DynamoDB API:
%% [http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_DeleteItem.html]
%%
%% ===Example===
%%
%% Delete an item from the "Thread" table if it doesn't have a
%% "Replies" attribute.
%%
%% `
%% {ok, Item} = 
%%     erlcloud_ddb2:delete_item(
%%       <<"Thread">>, 
%%       [{<<"ForumName">>, {s, <<"Amazon DynamoDB">>}},
%%        {<<"Subject">>, {s, <<"How do I update multiple items?">>}}],
%%       [{return_values, all_old},
%%        {condition_expression, <<"attribute_not_exists(Replies)">>}]),
%% '
%%
%% The ConditionExpression option can also be used in place of the legacy
%% ConditionalOperator or Expected parameters.
%%
%% `
%% {ok, Item} = 
%%     erlcloud_ddb2:delete_item(
%%       <<"Thread">>, 
%%       [{<<"ForumName">>, {s, <<"Amazon DynamoDB">>}},
%%        {<<"Subject">>, {s, <<"How do I update multiple items?">>}}],
%%       [{return_values, all_old},
%%        {condition_expression, <<"attribute_not_exists(#replies)">>},
%%        {expression_attribute_names, [{<<"#replies">>, <<"Replies">>}]}]),
%% '
%%
%% @end
%%------------------------------------------------------------------------------
-spec delete_item(table_name(), key(), delete_item_opts(), aws_config()) -> delete_item_return().
delete_item(Table, Key, Opts, Config) ->
    {AwsOpts, DdbOpts} = opts(delete_item_opts(), Opts),
    Return = erlcloud_ddb_impl:request(
               Config,
               "DynamoDB_20120810.DeleteItem",
               [{<<"TableName">>, Table},
                {<<"Key">>, dynamize_key(Key)}]
               ++ AwsOpts,
               DdbOpts),
    out(Return, fun(Json, UOpts) -> undynamize_record(delete_item_record(), Json, UOpts) end, DdbOpts, 
        #ddb2_delete_item.attributes, {ok, []}).

%%%------------------------------------------------------------------------------
%%% DeleteTable
%%%------------------------------------------------------------------------------

-spec delete_table_record() -> record_desc().
delete_table_record() ->
    {#ddb2_delete_table{},
     [{<<"TableDescription">>, #ddb2_delete_table.table_description,
       fun(V, Opts) -> undynamize_record(table_description_record(), V, Opts) end}
     ]}. 

-type delete_table_return() :: ddb_return(#ddb2_delete_table{}, #ddb2_table_description{}).

-spec delete_table(table_name()) -> delete_table_return().
delete_table(Table) ->
    delete_table(Table, [], default_config()).

-spec delete_table(table_name(), ddb_opts()) -> delete_table_return().
delete_table(Table, Opts) ->
    delete_table(Table, Opts, default_config()).

%%------------------------------------------------------------------------------
%% @doc 
%% DynamoDB API:
%% [http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_DeleteTable.html]
%%
%% ===Example===
%%
%% Delete "Reply" table.
%%
%% `
%% {ok, Description} =
%%     erlcloud_ddb2:delete_table(<<"Reply">>),
%% '
%% @end
%%------------------------------------------------------------------------------
-spec delete_table(table_name(), ddb_opts(), aws_config()) -> delete_table_return().
delete_table(Table, Opts, Config) ->
    {[], DdbOpts} = opts([], Opts),
    Return = erlcloud_ddb_impl:request(
               Config,
               "DynamoDB_20120810.DeleteTable",
               [{<<"TableName">>, Table}],
               DdbOpts),
    out(Return, fun(Json, UOpts) -> undynamize_record(delete_table_record(), Json, UOpts) end, 
        DdbOpts, #ddb2_delete_table.table_description).

%%%------------------------------------------------------------------------------
%%% DescribeBackup
%%%------------------------------------------------------------------------------

-type describe_backup_return() :: ddb_return(#ddb2_describe_backup{}, #ddb2_backup_description{}).

-spec describe_backup_record() -> record_desc().
describe_backup_record() ->
  {#ddb2_describe_backup{},
    [{<<"BackupDescription">>, #ddb2_describe_backup.backup_description,
      fun(V, Opts) -> undynamize_record(undynamize_backup_description(), V, Opts) end}
    ]}.

-spec describe_backup(binary()) -> describe_backup_return().
describe_backup(BackupArn)
    when is_binary(BackupArn) ->
    describe_backup(BackupArn, [], default_config()).

-spec describe_backup(binary(), ddb_opts()) -> describe_backup_return().
describe_backup(BackupArn, Opts)
    when is_binary(BackupArn) ->
    describe_backup(BackupArn, Opts, default_config()).

%%------------------------------------------------------------------------------
%% @doc
%% DynamoDB API:
%% [https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_DescribeBackup.html]
%%
%% ===Example===
%%
%% Describes an existing backup of a table.
%%
%% `
%% {ok, BackupDescription} =
%%     erlcloud_ddb2:describe_backup(<<"BackupArn">>),
%% '
%% @end
%%-------------------------------------------------------------------------------
-spec describe_backup(binary(), ddb_opts(), aws_config()) -> describe_backup_return().
describe_backup(BackupArn, Opts, Config)
    when is_binary(BackupArn) ->
    {_AwsOpts, DdbOpts} = opts([], Opts),
    Return = erlcloud_ddb_impl:request(
     Config,
     "DynamoDB_20120810.DescribeBackup",
     [{<<"BackupArn">>, BackupArn}],
     DdbOpts),
    out(Return, fun(Json, UOpts) -> undynamize_record(describe_backup_record(), Json, UOpts) end,
        DdbOpts, #ddb2_describe_backup.backup_description).

%%%------------------------------------------------------------------------------
%%% DescribeContinuousBackups
%%%------------------------------------------------------------------------------

-spec  ddb2_point_in_time_recovery_description() -> record_desc().
ddb2_point_in_time_recovery_description() ->
    {#ddb2_point_in_time_recovery_description{},
     [{<<"EarliestRestorableDateTime">>, #ddb2_point_in_time_recovery_description.earliest_restorable_date_time, fun id/2},
      {<<"LatestRestorableDateTime">>, #ddb2_point_in_time_recovery_description.latest_restorable_date_time, fun id/2},
      {<<"PointInTimeRecoveryStatus">>, #ddb2_point_in_time_recovery_description.point_in_time_recovery_status, fun undynamize_point_in_time_recovery_status/2}
     ]}.

-spec ddb2_continuous_backups_description() -> record_desc().
ddb2_continuous_backups_description() ->
    {#ddb2_continuous_backups_description{},
     [{<<"ContinuousBackupsStatus">>, #ddb2_continuous_backups_description.continuous_backups_status, fun undynamize_continuous_backups_status/2},
      {<<"PointInTimeRecoveryDescription">>, #ddb2_continuous_backups_description.point_in_time_recovery_description,
       fun(V, Opts) -> undynamize_record(ddb2_point_in_time_recovery_description(), V, Opts) end}
     ]}.

-spec continuous_backups_record() -> record_desc().
continuous_backups_record() ->
    {#ddb2_describe_continuous_backups{},
     [{<<"ContinuousBackupsDescription">>, #ddb2_describe_continuous_backups.continuous_backups_description,
      fun(V, Opts) -> undynamize_record(ddb2_continuous_backups_description(), V, Opts) end}
     ]}.

-type  describe_continuous_backup_return() :: ddb_return(#ddb2_describe_continuous_backups{}, #ddb2_continuous_backups_description{}).

-spec  describe_continuous_backups(table_name()) -> describe_continuous_backup_return().
describe_continuous_backups(TableName)
    when is_binary(TableName) ->
    describe_continuous_backups(TableName, [], default_config()).

-spec  describe_continuous_backups(table_name(), ddb_opts()) -> describe_continuous_backup_return().
describe_continuous_backups(TableName, Opts)
    when is_binary(TableName) ->
    describe_continuous_backups(TableName, Opts, default_config()).

%%------------------------------------------------------------------------------
%% @doc
%% DynamoDB API:
%% [https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_DescribeContinuousBackups.html]
%%
%% ===Example===
%%
%% Checks the status of continuous backups and point in time recovery on the specified table.
%%
%% `
%% {ok, ContinuousBackupDescription} =
%%     erlcloud_ddb2:describe_continuous_backups(<<"Forum">>),
%% '
%% @end
%%-------------------------------------------------------------------------------
-spec  describe_continuous_backups(table_name(), ddb_opts(), aws_config()) -> describe_continuous_backup_return().
describe_continuous_backups(TableName, Opts, Config)
    when is_binary(TableName) ->
    {_AwsOpts, DdbOpts} = opts([], Opts),
    Return = erlcloud_ddb_impl:request(
     Config,
     "DynamoDB_20120810.DescribeContinuousBackups",
     [{<<"TableName">>, TableName}],
     DdbOpts),
    out(Return, fun(Json, UOpts) -> undynamize_record(continuous_backups_record(), Json, UOpts) end,
        DdbOpts, #ddb2_describe_continuous_backups.continuous_backups_description).

%%%------------------------------------------------------------------------------
%%% DescribeGlobalTable
%%%------------------------------------------------------------------------------

-spec describe_global_table_record() -> record_desc().
describe_global_table_record() ->
    {#ddb2_describe_global_table{},
     [{<<"GlobalTableDescription">>, #ddb2_describe_global_table.global_table_description, 
       fun(V, Opts) -> undynamize_record(global_table_description_record(), V, Opts) end}
     ]}. 

-type describe_global_table_return() :: ddb_return(#ddb2_describe_global_table{}, #ddb2_global_table_description{}).

-spec describe_global_table(table_name()) -> describe_global_table_return().
describe_global_table(GlobalTableName) ->
    describe_global_table(GlobalTableName, [], default_config()).

-spec describe_global_table(table_name(), ddb_opts() | aws_config())
                           -> describe_global_table_return().
describe_global_table(GlobalTableName, Opts) when is_list(Opts) ->
    describe_global_table(GlobalTableName, Opts, default_config());
describe_global_table(GlobalTableName, Config) when is_record(Config, aws_config) ->
    describe_global_table(GlobalTableName, [], Config).

%%------------------------------------------------------------------------------
%% @doc 
%% DynamoDB API:
%% [https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_DescribeGlobalTable.html]
%%
%% ===Example===
%%
%% Describe "Thread" global table.
%%
%% `
%% {ok, Description} =
%%     erlcloud_ddb2:describe_table(<<"Thread">>),
%% '
%% @end
%%------------------------------------------------------------------------------
-spec describe_global_table(table_name(), ddb_opts(), aws_config())
                           -> describe_global_table_return().
describe_global_table(GlobalTableName, Opts, Config) ->
    {[], DdbOpts} = opts([], Opts),
    Return = erlcloud_ddb_impl:request(
               Config,
               "DynamoDB_20120810.DescribeGlobalTable",
               [{<<"GlobalTableName">>, GlobalTableName}],
               DdbOpts),
    out(Return, fun(Json, UOpts) -> undynamize_record(describe_global_table_record(), Json, UOpts) end, 
        DdbOpts, #ddb2_describe_table.table).

%%%------------------------------------------------------------------------------
%%% DescribeGlobalTableSettings
%%%------------------------------------------------------------------------------

-type describe_global_table_settings_return() :: ddb_return(#ddb2_describe_global_table_settings{}, #ddb2_replica_settings_description{}).

-spec describe_global_table_settings_record() -> record_desc().
describe_global_table_settings_record() ->
    {#ddb2_describe_global_table_settings{},
     [{<<"GlobalTableName">>, #ddb2_describe_global_table_settings.global_table_name, fun id/2},
      {<<"ReplicaSettings">>, #ddb2_describe_global_table_settings.replica_settings,
       fun(V, Opts) -> [undynamize_record(replica_settings_description_record(), I, Opts) || I <- V] end}]}.

-spec describe_global_table_settings(table_name()) -> describe_global_table_settings_return().
describe_global_table_settings(GlobalTableName) ->
    describe_global_table_settings(GlobalTableName, []).

-spec describe_global_table_settings(table_name(), ddb_opts()) -> describe_global_table_settings_return().
describe_global_table_settings(GlobalTableName, Opts) ->
    describe_global_table_settings(GlobalTableName, Opts, default_config()).

%%------------------------------------------------------------------------------
%% @doc
%% DynamoDB API:
%% [https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_DescribeGlobalTableSettings.html]
%%
%% Note: This method only applies to Version 2017.11.29 of global tables.
%%
%% ===Example===
%%
%% Describes Region-specific settings for "Thread" global table.
%%
%% `
%% {ok, GlobalTableSettings} =
%%     erlcloud_ddb2:describe_global_table_settings(<<"Thread">>),
%% '
%% @end
%%------------------------------------------------------------------------------
-spec describe_global_table_settings(table_name(), ddb_opts(), aws_config()) -> describe_global_table_settings_return().
describe_global_table_settings(GlobalTableName, Opts, Config) ->
    {[], DdbOpts} = opts([], Opts),
    Return = erlcloud_ddb_impl:request(
        Config,
        "DynamoDB_20120810.DescribeGlobalTableSettings",
        [{<<"GlobalTableName">>, GlobalTableName}],
        DdbOpts),
    out(Return, fun(Json, UOpts) -> undynamize_record(describe_global_table_settings_record(), Json, UOpts) end,
        DdbOpts, #ddb2_describe_global_table_settings.replica_settings).

%%%------------------------------------------------------------------------------
%%% DescribeLimits
%%%------------------------------------------------------------------------------

-spec describe_limits_record() -> record_desc().
describe_limits_record() ->
    {#ddb2_describe_limits{},
     [{<<"AccountMaxReadCapacityUnits">>, #ddb2_describe_limits.account_max_read_capacity_units, fun id/2},
      {<<"AccountMaxWriteCapacityUnits">>, #ddb2_describe_limits.account_max_write_capacity_units, fun id/2},
      {<<"TableMaxReadCapacityUnits">>, #ddb2_describe_limits.table_max_read_capacity_units, fun id/2},
      {<<"TableMaxWriteCapacityUnits">>, #ddb2_describe_limits.table_max_write_capacity_units, fun id/2}
     ]}.

-type describe_limits_return() :: ddb_return(#ddb2_describe_limits{}, #ddb2_describe_limits{}).

-spec describe_limits() -> describe_limits_return().
describe_limits() ->
    describe_limits([], default_config()).

-spec describe_limits(ddb_opts()) -> describe_limits_return().
describe_limits(Opts) ->
    describe_limits(Opts, default_config()).

%%------------------------------------------------------------------------------
%% @doc
%% DynamoDB API:
%% [http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_DescribeLimits.html]
%%
%% ===Example===
%%
%% Describe the current provisioned-capacity limits for your AWS account.
%%
%% `
%% {ok, Limits} =
%%     erlcloud_ddb2:describe_limits(),
%% '
%% @end
%%------------------------------------------------------------------------------
-spec describe_limits(ddb_opts(), aws_config()) -> describe_limits_return().
describe_limits(Opts, Config) ->
    {[], DdbOpts} = opts([], Opts),
    Return = erlcloud_ddb_impl:request(
               Config,
               "DynamoDB_20120810.DescribeLimits",
               [],
               DdbOpts),
    case out(Return, fun(Json, UOpts) -> undynamize_record(describe_limits_record(), Json, UOpts) end,
             DdbOpts) of
        {simple, Record} -> {ok, Record};
        {ok, _} = Out -> Out;
        {error, _} = Out -> Out
    end.

%%%------------------------------------------------------------------------------
%%% DescribeTable
%%%------------------------------------------------------------------------------

-spec describe_table_record() -> record_desc().
describe_table_record() ->
    {#ddb2_describe_table{},
     [{<<"Table">>, #ddb2_describe_table.table, 
       fun(V, Opts) -> undynamize_record(table_description_record(), V, Opts) end}
     ]}. 

-type describe_table_return() :: ddb_return(#ddb2_describe_table{}, #ddb2_table_description{}).

-spec describe_table(table_name()) -> describe_table_return().
describe_table(Table) ->
    describe_table(Table, [], default_config()).

-spec describe_table(table_name(), ddb_opts()) -> describe_table_return().
describe_table(Table, Opts) ->
    describe_table(Table, Opts, default_config()).

%%------------------------------------------------------------------------------
%% @doc 
%% DynamoDB API:
%% [http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_DescribeTable.html]
%%
%% ===Example===
%%
%% Describe "Thread" table.
%%
%% `
%% {ok, Description} =
%%     erlcloud_ddb2:describe_table(<<"Thread">>),
%% '
%% @end
%%------------------------------------------------------------------------------
-spec describe_table(table_name(), ddb_opts(), aws_config()) -> describe_table_return().
describe_table(Table, Opts, Config) ->
    {[], DdbOpts} = opts([], Opts),
    Return = erlcloud_ddb_impl:request(
               Config,
               "DynamoDB_20120810.DescribeTable",
               [{<<"TableName">>, Table}],
               DdbOpts),
    out(Return, fun(Json, UOpts) -> undynamize_record(describe_table_record(), Json, UOpts) end, 
        DdbOpts, #ddb2_describe_table.table).

%%%------------------------------------------------------------------------------
%%% DescribeTableReplicaAutoScaling
%%%------------------------------------------------------------------------------

-type describe_table_replica_auto_scaling_return() :: ddb_return(#ddb2_describe_table_replica_auto_scaling{}, #ddb2_table_auto_scaling_description{}).

-spec describe_table_replica_auto_scaling_record() -> record_desc().
describe_table_replica_auto_scaling_record() ->
    {#ddb2_describe_table_replica_auto_scaling{},
     [{<<"TableAutoScalingDescription">>, #ddb2_describe_table_replica_auto_scaling.table_auto_scaling_description,
       fun(V, Opts) -> undynamize_record(table_auto_scaling_description_record(), V, Opts) end}
     ]}.

-spec describe_table_replica_auto_scaling(table_name()) -> describe_table_replica_auto_scaling_return().
describe_table_replica_auto_scaling(Table) ->
    describe_table_replica_auto_scaling(Table, [], default_config()).

-spec describe_table_replica_auto_scaling(table_name(), ddb_opts()) -> describe_table_replica_auto_scaling_return().
describe_table_replica_auto_scaling(Table, Opts) ->
    describe_table_replica_auto_scaling(Table, Opts, default_config()).

%%------------------------------------------------------------------------------
%% @doc
%% DynamoDB API:
%% [http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_DescribeTableReplicaAutoScaling.html]
%% Note: This method only applies to Version 2019.11.21 of global tables.
%%
%% ===Example===
%%
%% Describes auto scaling settings across replicas of the global table called "Thread" at once.
%%
%% `
%% {ok, Description} =
%%     erlcloud_ddb2:describe_table_replica_auto_scaling(<<"Thread">>),
%% '
%% @end
%%------------------------------------------------------------------------------
-spec describe_table_replica_auto_scaling(table_name(), ddb_opts(), aws_config()) -> describe_table_replica_auto_scaling_return().
describe_table_replica_auto_scaling(Table, Opts, Config) ->
    {[], DdbOpts} = opts([], Opts),
    Return = erlcloud_ddb_impl:request(
        Config,
        "DynamoDB_20120810.DescribeTableReplicaAutoScaling",
        [{<<"TableName">>, Table}],
        DdbOpts),
    out(Return, fun(Json, UOpts) -> undynamize_record(describe_table_replica_auto_scaling_record(), Json, UOpts) end,
        DdbOpts, #ddb2_describe_table_replica_auto_scaling.table_auto_scaling_description).

%%%------------------------------------------------------------------------------
%%% DescribeTimeToLive
%%%------------------------------------------------------------------------------
-type time_to_live_status() :: enabled | disabled | enabling | disabling.

-spec undynamize_time_to_live_status(binary(), undynamize_opts()) -> time_to_live_status().
undynamize_time_to_live_status(Value, _) ->
    case Value of
      <<"ENABLED">> -> enabled;
      <<"ENABLING">> -> enabling;
      <<"DISABLED">> -> disabled;
      <<"DISABLING">> -> disabling
    end.

-spec time_to_live_description_record() -> record_desc().
time_to_live_description_record() ->
    {#ddb2_time_to_live_description{},
     [{<<"AttributeName">>, #ddb2_time_to_live_description.attribute_name, fun id/2},
      {<<"TimeToLiveStatus">>, #ddb2_time_to_live_description.time_to_live_status, fun undynamize_time_to_live_status/2}
    ]}.

-spec describe_time_to_live_record() -> record_desc().
describe_time_to_live_record() ->
    {#ddb2_describe_time_to_live{},
     [{<<"TimeToLiveDescription">>, #ddb2_describe_time_to_live.time_to_live_description,
       fun(V, Opts) -> undynamize_record(time_to_live_description_record(), V, Opts) end}
    ]}.

-type describe_time_to_live_return() :: ddb_return(#ddb2_describe_time_to_live{}, #ddb2_time_to_live_description{}).

-spec describe_time_to_live(table_name()) -> describe_time_to_live_return().
describe_time_to_live(Table) ->
    describe_time_to_live(Table, []).

-spec describe_time_to_live(table_name(), ddb_opts()) -> describe_time_to_live_return().
describe_time_to_live(Table, DbOpts) ->
    describe_time_to_live(Table, DbOpts, default_config()).
%%------------------------------------------------------------------------------
%% @doc 
%% DynamoDB API:
%% [http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_DescribeTimeToLive.html]
%%
%% ===Example===
%%
%% Describe TimeToLive for table "SessionData".
%% `
%% {ok, Description} = erlcloud_ddb2:describe_time_to_live(<<"SessionData">>),
%% '
%% @end
%%------------------------------------------------------------------------------
-spec describe_time_to_live(table_name(), ddb_opts(), aws_config()) -> describe_time_to_live_return().
describe_time_to_live(Table, DbOpts, Config) ->
    Return = erlcloud_ddb_impl:request(
               Config,
               "DynamoDB_20120810.DescribeTimeToLive",
               [{<<"TableName">>, Table}],
               DbOpts),
    out(Return, fun(Json, UOpts) -> undynamize_record(describe_time_to_live_record(), Json, UOpts) end, 
        DbOpts, #ddb2_describe_time_to_live.time_to_live_description).

%%%------------------------------------------------------------------------------
%%% GetItem
%%%------------------------------------------------------------------------------

-type get_item_opt() :: expression_attribute_names_opt() |
                        projection_expression_opt() |
                        attributes_to_get_opt() |
                        consistent_read_opt() |
                        return_consumed_capacity_opt() |
                        out_opt() |
                        no_request_opt() |
                        return_maps_opt().
-type get_item_opts() :: [get_item_opt()].

-spec get_item_opts() -> opt_table().
get_item_opts() ->
    [expression_attribute_names_opt(),
     projection_expression_opt(),
     attributes_to_get_opt(),
     consistent_read_opt(),
     return_consumed_capacity_opt()].

-spec get_item_record() -> record_desc().
get_item_record() ->
    {#ddb2_get_item{},
     [{<<"Item">>, #ddb2_get_item.item, fun undynamize_item/2},
      {<<"ConsumedCapacity">>, #ddb2_get_item.consumed_capacity, fun undynamize_consumed_capacity/2}
     ]}.

-type get_item_return() :: ddb_return(#ddb2_get_item{} | #ddb2_request{}, out_item()).

-spec get_item(table_name(), key()) -> get_item_return().
get_item(Table, Key) ->
    get_item(Table, Key, [], default_config()).

-spec get_item(table_name(), key(), get_item_opts()) -> get_item_return().
get_item(Table, Key, Opts) ->
    get_item(Table, Key, Opts, default_config()).

%%------------------------------------------------------------------------------
%% @doc 
%% DynamoDB API:
%% [http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_GetItem.html]
%%
%% ===Example===
%%
%% Get selected attributes from an item in the "Thread" table.
%%
%% `
%% {ok, Item} = 
%%     erlcloud_ddb2:get_item(
%%       <<"Thread">>,
%%       [{<<"ForumName">>, {s, <<"Amazon DynamoDB">>}}, 
%%        {<<"Subject">>, {s, <<"How do I update multiple items?">>}}],
%%       [{projection_expression, <<"LastPostDateTime, Message, Tags">>},
%%        consistent_read,
%%        {return_consumed_capacity, total}]),
%% '
%% @end
%%------------------------------------------------------------------------------
-spec get_item(table_name(), key(), get_item_opts(), aws_config()) -> get_item_return().
get_item(Table, Key, Opts, Config) ->
    {AwsOpts, DdbOpts} = opts(get_item_opts(), Opts),
    Return = erlcloud_ddb_impl:request(
               Config,
               "DynamoDB_20120810.GetItem",
               [{<<"TableName">>, Table},
                {<<"Key">>, dynamize_key(Key)}]
               ++ AwsOpts,
               DdbOpts),
    out(Return, fun(Json, UOpts) -> undynamize_record(get_item_record(), Json, UOpts) end, DdbOpts, 
        #ddb2_get_item.item, {ok, []}).

%%%------------------------------------------------------------------------------
%%% ListBackups
%%%------------------------------------------------------------------------------

-type list_backups_opt() :: {limit, pos_integer()} |
                            {exclusive_start_backup_arn, binary()} |
                            {table_name, table_name()} |
                            {time_range_lower_bound,  number()} |
                            {time_range_upper_bound,  number()}.

-spec list_backups_opts() -> opt_table().
list_backups_opts() ->
    [{limit, <<"Limit">>, fun id/1},
     {exclusive_start_backup_arn, <<"ExclusiveStartBackupArn">>, fun id/1},
     {table_name, <<"TableName">>, fun id/1},
     {time_range_lower_bound, <<"TimeRangeLowerBound">>, fun id/1},
     {time_range_upper_bound, <<"TimeRangeUpperBound">>, fun id/1}
    ].

-spec backup_record() -> record_desc().
backup_record() ->
    {#ddb2_backup_summary{},
     [{<<"BackupArn">>, #ddb2_backup_summary.backup_arn, fun id/2},
      {<<"BackupCreationDateTime">>, #ddb2_backup_summary.backup_creation_date_time, fun id/2},
      {<<"BackupName">>, #ddb2_backup_summary.backup_name, fun id/2},
      {<<"BackupSizeBytes">>, #ddb2_backup_summary.backup_size_bytes, fun id/2},
      {<<"BackupStatus">>, #ddb2_backup_summary.backup_status, fun undynamize_backup_status/2},
      {<<"TableArn">>, #ddb2_backup_summary.table_arn, fun id/2},
      {<<"TableId">>, #ddb2_backup_summary.table_id, fun id/2},
      {<<"TableName">>, #ddb2_backup_summary.table_name, fun id/2}
     ]}.

-spec undynamize_list_backups(jsx:json_term(), undynamize_opts()) -> [#ddb2_list_backups{}].
undynamize_list_backups(BackupSummaries, Opts) ->
    [undynamize_record(backup_record(), T, Opts) || T <- BackupSummaries].

-spec list_backups_record() -> record_desc().
list_backups_record() ->
    {#ddb2_list_backups{},
     [{<<"BackupSummaries">>, #ddb2_list_backups.backup_summaries, fun undynamize_list_backups/2},
      {<<"LastEvaluatedBackupArn">>, #ddb2_list_backups.last_evaluated_backup_arn, fun id/2}
     ]}.

-type list_backups_return() :: ddb_return(#ddb2_list_backups{}, #ddb2_backup_summary{}).

-spec list_backups() -> list_backups_return().
list_backups() ->
    list_backups([], default_config()).

-spec list_backups([list_backups_opt()]) -> list_backups_return().
list_backups(Opts) ->
    list_backups(Opts, default_config()).

%%------------------------------------------------------------------------------
%% @doc
%% DynamoDB API:
%% [https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_ListBackups.html]
%%
%% ===Example===
%%
%% Get the table backups.
%% `
%% {ok, Tables} =
%%     erlcloud_ddb2:list_backups(),
%% '
%% Get the last 4 table backups for "Forum" table between April 5, 2018 and April 6, 2018.
%% `
%% {ok, Tables} =
%%     erlcloud_ddb2:list_backups(
%%       [{limit, 4},
%%        {table_name, <<"Forum">>},
%%        {time_range_lower_bound, 1522926603.688},
%%        {time_range_upper_bound, 1523022454.098}]),
%% '
%% @end
%%------------------------------------------------------------------------------
-spec list_backups([list_backups_opt()], aws_config()) -> list_backups_return().
list_backups(Opts, Config) ->
    {AwsOpts, DdbOpts} = opts(list_backups_opts(), Opts),
    Return = erlcloud_ddb_impl:request(
     Config,
     "DynamoDB_20120810.ListBackups",
     AwsOpts,
     DdbOpts),
    out(Return, fun(Json, UOpts) -> undynamize_record(list_backups_record(), Json, UOpts) end,
        DdbOpts, #ddb2_list_backups.backup_summaries).

%%%------------------------------------------------------------------------------
%%% ListGlobalTables
%%%------------------------------------------------------------------------------

-type list_global_tables_opt() :: {limit, pos_integer()} | 
                                  {exclusive_start_global_table_name, table_name() | undefined} |
                                  out_opt().
-type list_global_tables_opts() :: [list_global_tables_opt()].

-spec list_global_tables_opts() -> opt_table().
list_global_tables_opts() ->
    [{limit, <<"Limit">>, fun id/1},
     {exclusive_start_global_table_name, <<"ExclusiveStartGlobalTableName">>, fun id/1}].

-spec undynamize_global_tables(jsx:json_term(), undynamize_opts()) -> [#ddb2_global_table{}].
undynamize_global_tables(Tables, Opts) ->
    [undynamize_record(global_table_record(), T, Opts) || T <- Tables].

-spec list_global_tables_record() -> record_desc().
list_global_tables_record() ->
    {#ddb2_list_global_tables{},
     [{<<"GlobalTables">>, #ddb2_list_global_tables.global_tables, fun undynamize_global_tables/2},
      {<<"LastEvaluatedGlobalTableName">>, #ddb2_list_global_tables.last_evaluated_global_table_name, fun id/2}
     ]}.

-type list_global_tables_return() :: ddb_return(#ddb2_list_global_tables{}, [#ddb2_global_table{}]).

-spec list_global_tables() -> list_global_tables_return().
list_global_tables() ->
    list_global_tables([], default_config()).

-spec list_global_tables(list_global_tables_opts() | aws_config())
                        -> list_global_tables_return().
list_global_tables(Opts) when is_list(Opts) ->
    list_global_tables(Opts, default_config());
list_global_tables(Config) when is_record(Config, aws_config) ->
    list_global_tables([], Config).

%%------------------------------------------------------------------------------
%% @doc 
%% DynamoDB API:
%% [https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_ListGlobalTables.html]
%%
%% ===Example===
%%
%% Get the next 3 global table names after "Thread".
%%
%% `
%% {ok, Tables} = 
%%     erlcloud_ddb2:list_global_tables(
%%       [{limit, 3}, 
%%        {exclusive_start_global_table_name, <<"Thread">>}]),
%% '
%% @end
%%------------------------------------------------------------------------------
-spec list_global_tables(list_global_tables_opts(), aws_config())
                        -> list_global_tables_return().
list_global_tables(Opts, Config) ->
    {AwsOpts, DdbOpts} = opts(list_global_tables_opts(), Opts),
    Return = erlcloud_ddb_impl:request(
               Config,
               "DynamoDB_20120810.ListGlobalTables",
               AwsOpts,
               DdbOpts),
    out(Return, fun(Json, UOpts) -> undynamize_record(list_global_tables_record(), Json, UOpts) end, 
        DdbOpts, #ddb2_list_global_tables.global_tables, {ok, []}).

%%%------------------------------------------------------------------------------
%%% ListTables
%%%------------------------------------------------------------------------------

-type list_tables_opt() :: {limit, pos_integer()} | 
                           {exclusive_start_table_name, table_name() | undefined} |
                           out_opt().
-type list_tables_opts() :: [list_tables_opt()].

-spec list_tables_opts() -> opt_table().
list_tables_opts() ->
    [{limit, <<"Limit">>, fun id/1},
     {exclusive_start_table_name, <<"ExclusiveStartTableName">>, fun id/1}].

-spec list_tables_record() -> record_desc().
list_tables_record() ->
    {#ddb2_list_tables{},
     [{<<"TableNames">>, #ddb2_list_tables.table_names, fun id/2},
      {<<"LastEvaluatedTableName">>, #ddb2_list_tables.last_evaluated_table_name, fun id/2}
     ]}.

-type list_tables_return() :: ddb_return(#ddb2_list_tables{}, [table_name()]).

-spec list_tables() -> list_tables_return().
list_tables() ->
    list_tables([], default_config()).

-spec list_tables(list_tables_opts()) -> list_tables_return().
list_tables(Opts) ->
    list_tables(Opts, default_config()).

%%------------------------------------------------------------------------------
%% @doc 
%% DynamoDB API:
%% [http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_ListTables.html]
%%
%% ===Example===
%%
%% Get the next 3 table names after "Forum".
%%
%% `
%% {ok, Tables} = 
%%     erlcloud_ddb2:list_tables(
%%       [{limit, 3}, 
%%        {exclusive_start_table_name, <<"Forum">>}]),
%% '
%% @end
%%------------------------------------------------------------------------------
-spec list_tables(list_tables_opts(), aws_config()) -> list_tables_return().
list_tables(Opts, Config) ->
    {AwsOpts, DdbOpts} = opts(list_tables_opts(), Opts),
    Return = erlcloud_ddb_impl:request(
               Config,
               "DynamoDB_20120810.ListTables",
               AwsOpts,
               DdbOpts),
    out(Return, fun(Json, UOpts) -> undynamize_record(list_tables_record(), Json, UOpts) end, 
        DdbOpts, #ddb2_list_tables.table_names, {ok, []}).

%%%------------------------------------------------------------------------------
%%% ListTagsOfResource
%%%------------------------------------------------------------------------------

-type list_tags_of_resource_opt() :: {next_token, binary()} | out_opt().
-type list_tags_of_resource_opts() :: [list_tags_of_resource_opt()].

-spec list_tags_of_resource_opts() -> opt_table().
list_tags_of_resource_opts() ->
    [{next_token, <<"NextToken">>, fun id/1}].

-spec undynamize_tag(jsx:json_term(), undynamize_opts()) -> tag().
undynamize_tag(Tag, _) ->
    {proplists:get_value(<<"Key">>, Tag),
     proplists:get_value(<<"Value">>, Tag)}.

-spec undynamize_tags([jsx:json_term()], undynamize_opts()) -> tags().
undynamize_tags(Tags, Opts) ->
    [undynamize_tag(Tag, Opts) || Tag <- Tags].

-spec list_tags_of_resource_record() -> record_desc().
list_tags_of_resource_record() ->
    {#ddb2_list_tags_of_resource{},
     [{<<"NextToken">>, #ddb2_list_tags_of_resource.next_token, fun id/2},
      {<<"Tags">>, #ddb2_list_tags_of_resource.tags, fun undynamize_tags/2}
     ]}.

-type list_tags_of_resource_return() :: ddb_return(#ddb2_list_tags_of_resource{}, tags()).

-spec list_tags_of_resource(binary()) -> list_tags_of_resource_return().
list_tags_of_resource(ResourceArn) ->
    list_tags_of_resource(ResourceArn, [], default_config()).

-spec list_tags_of_resource(binary(), list_tags_of_resource_opts())
                           -> list_tags_of_resource_return().
list_tags_of_resource(ResourceArn, Opts) ->
    list_tags_of_resource(ResourceArn, Opts, default_config()).

%%------------------------------------------------------------------------------
%% @doc 
%% DynamoDB API:
%% [https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_ListTagsOfResource.html]
%%
%% ===Example===
%%
%% List the tags for "Forum".
%%
%% `
%% {ok, Tags} = 
%%     erlcloud_ddb2:list_tags_of_resource(
%%       <<"arn:aws:dynamodb:us-west-2:111122223333:table/Forum">>,
%%       [{next_token, <<"TestToken">>}]),
%% '
%% @end
%%------------------------------------------------------------------------------
-spec list_tags_of_resource(binary(), list_tags_of_resource_opts(), aws_config())
                           -> list_tags_of_resource_return().
list_tags_of_resource(ResourceArn, Opts, Config) ->
    {AwsOpts, DdbOpts} = opts(list_tags_of_resource_opts(), Opts),
    Return = erlcloud_ddb_impl:request(
               Config,
               "DynamoDB_20120810.ListTagsOfResource",
               [{<<"ResourceArn">>, ResourceArn} | AwsOpts],
               DdbOpts),
    out(Return, fun(Json, UOpts) -> undynamize_record(list_tags_of_resource_record(), Json, UOpts) end, 
        DdbOpts, #ddb2_list_tags_of_resource.tags, {ok, []}).

%%%------------------------------------------------------------------------------
%%% PutItem
%%%------------------------------------------------------------------------------

-type put_item_opt() :: expression_attribute_names_opt() |
                        expression_attribute_values_opt() |
                        condition_expression_opt() |
                        conditional_op_opt() |
                        expected_opt() | 
                        {return_values, none | all_old} |
                        return_consumed_capacity_opt() |
                        return_item_collection_metrics_opt() |
                        out_opt() |
                        no_request_opt() |
                        return_maps_opt().
-type put_item_opts() :: [put_item_opt()].

-spec put_item_opts() -> opt_table().
put_item_opts() ->
    [expression_attribute_names_opt(),
     expression_attribute_values_opt(),
     condition_expression_opt(),
     conditional_op_opt(),
     expected_opt(),
     {return_values, <<"ReturnValues">>, fun dynamize_return_value/1},
     return_consumed_capacity_opt(),
     return_item_collection_metrics_opt()].

-spec put_item_record() -> record_desc().
put_item_record() ->
    {#ddb2_put_item{},
     [{<<"Attributes">>, #ddb2_put_item.attributes, fun undynamize_item/2},
      {<<"ConsumedCapacity">>, #ddb2_put_item.consumed_capacity, fun undynamize_consumed_capacity/2},
      {<<"ItemCollectionMetrics">>, #ddb2_put_item.item_collection_metrics, 
       fun undynamize_item_collection_metrics/2}
     ]}.

-type put_item_return() :: ddb_return(#ddb2_put_item{} | #ddb2_request{}, out_item()).

-spec put_item(table_name(), in_item()) -> put_item_return().
put_item(Table, Item) ->
    put_item(Table, Item, [], default_config()).

-spec put_item(table_name(), in_item(), put_item_opts()) -> put_item_return().
put_item(Table, Item, Opts) ->
    put_item(Table, Item, Opts, default_config()).

%%------------------------------------------------------------------------------
%% @doc 
%% DynamoDB API:
%% [http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_PutItem.html]
%%
%% ===Example===
%%
%% Put an item in the "Thread" table if it does not already exist.
%%
%% `
%% {ok, []} = 
%%     erlcloud_ddb2:put_item(
%%       <<"Thread">>, 
%%       [{<<"LastPostedBy">>, <<"fred@example.com">>},
%%        {<<"ForumName">>, <<"Amazon DynamoDB">>},
%%        {<<"LastPostDateTime">>, <<"201303190422">>},
%%        {<<"Tags">>, {ss, [<<"Update">>, <<"Multiple Items">>, <<"HelpMe">>]}},
%%        {<<"Subject">>, <<"How do I update multiple items?">>},
%%        {<<"Message">>, 
%%         <<"I want to update multiple items in a single API call. What is the best way to do that?">>}],
%%       [{condition_expression, <<"ForumName <> :f and Subject <> :s">>},
%%        {expression_attribute_values,
%%         [{<<":f">>, <<"Amazon DynamoDB">>},
%%          {<<":s">>, <<"How do I update multiple items?">>}]}]),
%% '
%%
%% The ConditionExpression option can be used in place of the legacy Expected parameter.
%%
%% `
%% {ok, []} = 
%%     erlcloud_ddb2:put_item(
%%       <<"Thread">>, 
%%       [{<<"LastPostedBy">>, <<"fred@example.com">>},
%%        {<<"ForumName">>, <<"Amazon DynamoDB">>},
%%        {<<"LastPostDateTime">>, <<"201303190422">>},
%%        {<<"Tags">>, {ss, [<<"Update">>, <<"Multiple Items">>, <<"HelpMe">>]}},
%%        {<<"Subject">>, <<"How do I update multiple items?">>},
%%        {<<"Message">>, 
%%         <<"I want to update multiple items in a single API call. What is the best way to do that?">>}],
%%       [{condition_expression, <<"#forum <> :forum AND attribute_not_exists(#subject)">>},
%%        {expression_attribute_names, [{<<"#forum">>, <<"ForumName">>}, {<<"#subject">>, <<"Subject">>}]},
%%        {expression_attribute_values, [{<<":forum">>, <<"Amazon DynamoDB">>}]}]),
%% '
%%
%% @end
%%------------------------------------------------------------------------------
-spec put_item(table_name(), in_item(), put_item_opts(), aws_config()) -> put_item_return().
put_item(Table, Item, Opts, Config) ->
    {AwsOpts, DdbOpts} = opts(put_item_opts(), Opts),
    Return = erlcloud_ddb_impl:request(
               Config,
               "DynamoDB_20120810.PutItem",
               [{<<"TableName">>, Table},
                {<<"Item">>, dynamize_item(Item)}]
               ++ AwsOpts,
               DdbOpts),
    out(Return, fun(Json, UOpts) -> undynamize_record(put_item_record(), Json, UOpts) end, DdbOpts, 
        #ddb2_put_item.attributes, {ok, []}).

%%%------------------------------------------------------------------------------
%%% Query
%%%------------------------------------------------------------------------------

-type q_opt() :: expression_attribute_names_opt() |
                 expression_attribute_values_opt() |
                 projection_expression_opt() |
                 attributes_to_get_opt() |
                 consistent_read_opt() |
                 {filter_expression, expression()} |
                 conditional_op_opt() |
                 {query_filter, conditions()} |
                 {limit, pos_integer()} |
                 {exclusive_start_key, key() | undefined} |
                 boolean_opt(scan_index_forward) |
                 {index_name, index_name()} |
                 {select, select()} |
                 return_consumed_capacity_opt() |
                 out_opt() |
                 return_maps_opt().
-type q_opts() :: [q_opt()].

-spec q_opts() -> opt_table().
q_opts() ->
    [expression_attribute_names_opt(),
     expression_attribute_values_opt(),
     projection_expression_opt(),
     attributes_to_get_opt(),
     consistent_read_opt(),
     filter_expression_opt(),
     conditional_op_opt(),
     {query_filter, <<"QueryFilter">>, fun dynamize_conditions/1},
     {limit, <<"Limit">>, fun id/1},
     {exclusive_start_key, <<"ExclusiveStartKey">>, fun dynamize_key/1},
     {scan_index_forward, <<"ScanIndexForward">>, fun id/1},
     {index_name, <<"IndexName">>, fun id/1},
     {select, <<"Select">>, fun dynamize_select/1},
     return_consumed_capacity_opt()
    ].

-spec dynamize_q_key_conditions_or_expression(conditions() | expression()) -> json_pair().
dynamize_q_key_conditions_or_expression(KeyConditionExpression) when is_binary(KeyConditionExpression) ->
    {<<"KeyConditionExpression">>, dynamize_expression(KeyConditionExpression)};
dynamize_q_key_conditions_or_expression(KeyConditions) ->
    {<<"KeyConditions">>, dynamize_conditions(KeyConditions)}.

-spec q_record() -> record_desc().
q_record() ->
    {#ddb2_q{},
     [{<<"ConsumedCapacity">>, #ddb2_q.consumed_capacity, fun undynamize_consumed_capacity/2},
      {<<"Count">>, #ddb2_q.count, fun id/2},
      {<<"Items">>, #ddb2_q.items, fun(V, Opts) -> [undynamize_item(I, Opts) || I <- V] end},
      {<<"LastEvaluatedKey">>, #ddb2_q.last_evaluated_key, fun undynamize_typed_key/2},
      {<<"ScannedCount">>, #ddb2_q.scanned_count, fun id/2}
     ]}.

-type q_return() :: ddb_return(#ddb2_q{} | #ddb2_request{}, [out_item()]).

-spec q(table_name(), conditions() | expression()) -> q_return().
q(Table, KeyConditionsOrExpression) ->
    q(Table, KeyConditionsOrExpression, [], default_config()).

-spec q(table_name(), conditions() | expression(), q_opts()) -> q_return().
q(Table, KeyConditionsOrExpression, Opts) ->
    q(Table, KeyConditionsOrExpression, Opts, default_config()).

%%------------------------------------------------------------------------------
%% @doc 
%% DynamoDB API:
%% [http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_Query.html]
%%
%% KeyConditions are treated as a required parameter, which appears to
%% be the case despite what the documentation says.
%%
%% ===Example===
%%
%% Get up to 3 items from the "Thread" table with "ForumName" of
%% "Amazon DynamoDB" and "LastPostDateTime" between specified
%% value. Use the "LastPostIndex".
%%
%% `
%% {ok, Items} =
%%     erlcloud_ddb2:q(
%%       <<"Thread">>,
%%       <<"ForumName = :n AND LastPostDateTime BETWEEN :t1 AND :t2">>,
%%       [{expression_attribute_values,
%%         [{<<":n">>, <<"Amazon DynamoDB">>},
%%          {<<":t1">>, <<"20130101">>},
%%          {<<":t2">>, <<"20130115">>}]},
%%        {index_name, <<"LastPostIndex">>},
%%        {select, all_attributes},
%%        {limit, 3},
%%        {consistent_read, true},
%%        {filter_expression, <<"#user = :user">>},
%%        {expression_attribute_names, [{<<"#user">>, <<"User">>}]},
%%        {expression_attribute_values, [{<<":user">>, <<"User A">>}]}]),
%% '
%%
%% @end
%%------------------------------------------------------------------------------
-spec q(table_name(), conditions() | expression(), q_opts(), aws_config()) -> q_return().
q(Table, KeyConditionsOrExpression, Opts, Config) ->
    {AwsOpts, DdbOpts} = opts(q_opts(), Opts),
    Return = erlcloud_ddb_impl:request(
               Config,
               "DynamoDB_20120810.Query",
               [{<<"TableName">>, Table},
                dynamize_q_key_conditions_or_expression(KeyConditionsOrExpression)]
               ++ AwsOpts,
               DdbOpts),
    out(Return, fun(Json, UOpts) -> undynamize_record(q_record(), Json, UOpts) end, DdbOpts, 
        #ddb2_q.items, {ok, []}).

%%%------------------------------------------------------------------------------
%%% RestoreTableFromBackup
%%%------------------------------------------------------------------------------

-type restore_table_from_backup_return() :: ddb_return(#ddb2_restore_table_from_backup{}, #ddb2_table_description{}).

-spec restore_table_from_backup_record() -> record_desc().
restore_table_from_backup_record() ->
    {#ddb2_restore_table_from_backup{},
      [{<<"TableDescription">>, #ddb2_restore_table_from_backup.table_description,
        fun(V, Opts) -> undynamize_record(table_description_record(), V, Opts) end}
      ]}.

-spec restore_table_from_backup(binary(), table_name()) -> restore_table_from_backup_return().
restore_table_from_backup(BackupArn, TargetTableName)
    when is_binary(BackupArn), is_binary(TargetTableName) ->
    restore_table_from_backup(BackupArn, TargetTableName, [], default_config()).

-spec restore_table_from_backup(binary(), table_name(), ddb_opts()) -> restore_table_from_backup_return().
restore_table_from_backup(BackupArn, TargetTableName, Opts)
    when is_binary(BackupArn), is_binary(TargetTableName) ->
    restore_table_from_backup(BackupArn, TargetTableName, Opts, default_config()).

%%------------------------------------------------------------------------------
%% @doc
%% DynamoDB API:
%% [https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_RestoreTableFromBackup.html]
%%
%% ===Example===
%%
%% Creates a new table from an existing backup.
%%
%% `
%% {ok, Table} =
%%     erlcloud_ddb2:restore_table_from_backup(<<"BackupArn">>, <<"Forum">>),
%% '
%% @end
%%-------------------------------------------------------------------------------
-spec restore_table_from_backup(binary(), table_name(), ddb_opts(), aws_config()) -> restore_table_from_backup_return().
restore_table_from_backup(BackupArn, TargetTableName, Opts, Config)
    when is_binary(BackupArn), is_binary(TargetTableName) ->
    {_AwsOpts, DdbOpts} = opts([], Opts),
    Return = erlcloud_ddb_impl:request(
     Config,
     "DynamoDB_20120810.RestoreTableFromBackup",
     [{<<"BackupArn">>, BackupArn},
      {<<"TargetTableName">>, TargetTableName}],
     DdbOpts),
    out(Return, fun(Json, UOpts) -> undynamize_record(restore_table_from_backup_record(), Json, UOpts) end,
        DdbOpts, #ddb2_restore_table_from_backup.table_description).

%%%------------------------------------------------------------------------------
%%% RestoreTableToPointInTime
%%%------------------------------------------------------------------------------

-type restore_table_to_point_in_time_opt() :: {restore_date_time, date_time()} |
                                              {use_latest_restorable_time, boolean()}.

-spec restore_table_to_point_in_time_opts() -> opt_table().
restore_table_to_point_in_time_opts() ->
    [{restore_date_time, <<"RestoreDateTime">>, fun id/1},
     {use_latest_restorable_time, <<"UseLatestRestorableTime">>, fun id/1}
    ].

-type restore_table_to_point_in_time_return() :: ddb_return(#ddb2_restore_table_to_point_in_time{}, #ddb2_table_description{}).

-spec restore_table_to_point_in_time() -> record_desc().
restore_table_to_point_in_time() ->
    {#ddb2_restore_table_to_point_in_time{},
      [{<<"TableDescription">>, #ddb2_restore_table_to_point_in_time.table_description,
        fun(V, Opts) -> undynamize_record(table_description_record(), V, Opts) end}
      ]}.

-spec restore_table_to_point_in_time(table_name(), table_name()) -> restore_table_to_point_in_time_return().
restore_table_to_point_in_time(SourceTableName, TargetTableName)
    when is_binary(SourceTableName), is_binary(TargetTableName) ->
    restore_table_to_point_in_time(SourceTableName, TargetTableName, [], default_config()).

-spec restore_table_to_point_in_time(table_name(), table_name(), [restore_table_to_point_in_time_opt()]) -> restore_table_to_point_in_time_return().
restore_table_to_point_in_time(SourceTableName, TargetTableName, Opts)
    when is_binary(SourceTableName), is_binary(TargetTableName) ->
    restore_table_to_point_in_time(SourceTableName, TargetTableName, Opts, default_config()).

%%------------------------------------------------------------------------------
%% @doc
%% DynamoDB API:
%% [https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_RestoreTableToPointInTime.html]
%%
%% ===Example===
%%
%% Restores the specified table to the specified point in time within EarliestRestorableDateTime and LatestRestorableDateTime.
%%
%% `
%% {ok, Table} =
%%     erlcloud_ddb2:restore_table_to_point_in_time(<<"Thread">>, <<"ThreadTo">>, [{restore_date_time, 1522926603.688}, {use_latest_restorable_time, false}]),
%% '
%% @end
%%-------------------------------------------------------------------------------
-spec restore_table_to_point_in_time(table_name(), table_name(), [restore_table_to_point_in_time_opt()], aws_config()) -> restore_table_to_point_in_time_return().
restore_table_to_point_in_time(SourceTableName, TargetTableName, Opts, Config)
    when is_binary(SourceTableName), is_binary(TargetTableName) ->
    {AwsOpts, DdbOpts} = opts(restore_table_to_point_in_time_opts(), Opts),
    Return = erlcloud_ddb_impl:request(
      Config,
      "DynamoDB_20120810.RestoreTableToPointInTime",
      [{<<"SourceTableName">>, SourceTableName},
        {<<"TargetTableName">>, TargetTableName}] ++ AwsOpts,
        DdbOpts),
    out(Return, fun(Json, UOpts) -> undynamize_record(restore_table_to_point_in_time(), Json, UOpts) end,
        DdbOpts, #ddb2_restore_table_to_point_in_time.table_description).

%%%------------------------------------------------------------------------------
%%% Scan
%%%------------------------------------------------------------------------------

-type scan_opt() :: expression_attribute_names_opt() |
                    expression_attribute_values_opt() |
                    projection_expression_opt() |
                    attributes_to_get_opt() |
                    consistent_read_opt() |
                    {filter_expression, expression()} |
                    conditional_op_opt() |
                    {scan_filter, conditions()} |
                    {limit, pos_integer()} |
                    {exclusive_start_key, key() | undefined} |
                    {segment, non_neg_integer()} |
                    {total_segments, pos_integer()} |
                    {index_name, index_name()} |
                    {select, select()} |
                    return_consumed_capacity_opt() |
                    out_opt() |
                    no_request_opt() |
                    return_maps_opt().
-type scan_opts() :: [scan_opt()].

-spec scan_opts() -> opt_table().
scan_opts() ->
    [expression_attribute_names_opt(),
     expression_attribute_values_opt(),
     projection_expression_opt(),
     attributes_to_get_opt(),
     consistent_read_opt(),
     filter_expression_opt(),
     conditional_op_opt(),
     {scan_filter, <<"ScanFilter">>, fun dynamize_conditions/1},
     {limit, <<"Limit">>, fun id/1},
     {exclusive_start_key, <<"ExclusiveStartKey">>, fun dynamize_key/1},
     {segment, <<"Segment">>, fun id/1},
     {total_segments, <<"TotalSegments">>, fun id/1},
     {index_name, <<"IndexName">>, fun id/1},
     {select, <<"Select">>, fun dynamize_select/1},
     return_consumed_capacity_opt()
    ].

-spec scan_record() -> record_desc().
scan_record() ->
    {#ddb2_scan{},
     [{<<"ConsumedCapacity">>, #ddb2_scan.consumed_capacity, fun undynamize_consumed_capacity/2},
      {<<"Count">>, #ddb2_scan.count, fun id/2},
      {<<"Items">>, #ddb2_scan.items, fun(V, Opts) -> [undynamize_item(I, Opts) || I <- V] end},
      {<<"LastEvaluatedKey">>, #ddb2_scan.last_evaluated_key, fun undynamize_typed_key/2},
      {<<"ScannedCount">>, #ddb2_scan.scanned_count, fun id/2}
     ]}.

-type scan_return() :: ddb_return(#ddb2_scan{} | #ddb2_request{}, [out_item()]).

-spec scan(table_name()) -> scan_return().
scan(Table) ->
    scan(Table, [], default_config()).

-spec scan(table_name(), scan_opts()) -> scan_return().
scan(Table, Opts) ->
    scan(Table, Opts, default_config()).

%%------------------------------------------------------------------------------
%% @doc 
%% DynamoDB API:
%% [http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_Scan.html]
%%
%% ===Example===
%%
%% Return all items in the "Reply" table.
%%
%% `
%% {ok, Record} = 
%%     erlcloud_ddb2:scan(
%%       <<"Reply">>, 
%%       [{return_consumed_capacity, total}, 
%%        {out, record}]),
%% '
%% @end
%%------------------------------------------------------------------------------
-spec scan(table_name(), scan_opts(), aws_config()) -> scan_return().
scan(Table, Opts, Config) ->
    {AwsOpts, DdbOpts} = opts(scan_opts(), Opts),
    Return = erlcloud_ddb_impl:request(
               Config,
               "DynamoDB_20120810.Scan",
               [{<<"TableName">>, Table}]
               ++ AwsOpts,
               DdbOpts),
    out(Return, fun(Json, UOpts) -> undynamize_record(scan_record(), Json, UOpts) end, DdbOpts, 
        #ddb2_scan.items, {ok, []}).

%%%------------------------------------------------------------------------------
%%% TagResource
%%%------------------------------------------------------------------------------

-type tag_resource_return() :: ok | {error, term()}.

-spec dynamize_tag(tag()) -> jsx:json_term().
dynamize_tag({Key, Value}) when is_binary(Key), is_binary(Value) ->
    [{<<"Key">>, Key},
     {<<"Value">>, Value}].

-spec dynamize_tags(tags()) -> [jsx:json_term()].
dynamize_tags(Tags) ->
    [dynamize_tag(Tag) || Tag <- Tags]. 

-spec tag_resource(binary(), tags()) -> tag_resource_return().
tag_resource(ResourceArn, Tags) ->
    tag_resource(ResourceArn, Tags, default_config()).

%%------------------------------------------------------------------------------
%% @doc 
%% DynamoDB API:
%% [https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_TagResource.html]
%%
%% ===Example===
%%
%% Tag the Forum table with example keys.
%%
%% `
%% ok = erlcloud_ddb2:tag_resource(
%%        <<"arn:aws:dynamodb:us-west-2:111122223333:table/Forum">>, 
%%        [{<<"example_key1">>, <<"example_value1">>},
%%         {<<"example_key2">>, <<"example_value2">>}]),
%% '
%% @end
%%------------------------------------------------------------------------------
-spec tag_resource(binary(), tags(), aws_config())
                  -> tag_resource_return().
tag_resource(ResourceArn, Tags, Config) ->
    erlcloud_ddb_impl:request(
      Config,
      "DynamoDB_20120810.TagResource",
      [{<<"ResourceArn">>, ResourceArn},
       {<<"Tags">>, dynamize_tags(Tags)}]).

%%%-----------------------------------------------------------------------------
%%% TransactGetItems
%%%-----------------------------------------------------------------------------

-type transact_get_items_transact_item_opts() :: expression_attribute_names_opt() |
                           projection_expression_opt() |
                           return_consumed_capacity_opt() |
                           out_opt() |
                           no_request_opt() |
                           return_maps_opt().
-type transact_get_items_opts() :: [transact_get_items_transact_item_opts()].

-type transact_get_items_get_item() :: {table_name(), key()}
                                     | {table_name(), key(), transact_get_items_opts()}.

-type transact_get_items_get() :: {get, transact_get_items_get_item()}.

-type transact_get_items_transact_item() :: transact_get_items_get().
-type transact_get_items_transact_items() :: maybe_list(transact_get_items_transact_item()).

-type transact_get_items_return() :: ddb_return(#ddb2_transact_get_items{} | #ddb2_request{}, out_item()).

-spec dynamize_transact_get_items_transact_items(transact_get_items_transact_items())
                                          -> [jsx:json_term()].
dynamize_transact_get_items_transact_items(TransactItems) ->
    dynamize_maybe_list(fun dynamize_transact_get_items_transact_item/1, TransactItems).

-spec transact_get_items_transact_item_opts() -> opt_table().
transact_get_items_transact_item_opts() ->
    [expression_attribute_names_opt(),
     projection_expression_opt()].

-spec dynamize_transact_get_items_transact_item(transact_get_items_transact_item()) -> jsx:json_term().
dynamize_transact_get_items_transact_item({get, {TableName, Key}}) ->
    dynamize_transact_get_items_transact_item({get, {TableName, Key, []}});
dynamize_transact_get_items_transact_item({get, {TableName, Key, Opts}}) ->
    {AwsOpts, _DdbOpts} = opts(transact_get_items_transact_item_opts(), Opts),
    [{<<"Get">>, [{<<"TableName">>, TableName}, {<<"Key">>, dynamize_key(Key)} | AwsOpts]}].

undynamize_transact_get_items_responses(Response, Opts) ->
    lists:map(fun(R) ->
        Item = proplists:get_value(<<"Item">>, R),
        #ddb2_item_response{item = undynamize_item(Item, Opts)}
    end, Response).

-spec transact_get_items_record() -> record_desc().
transact_get_items_record() ->
    {#ddb2_transact_get_items{},
     [{<<"ConsumedCapacity">>, #ddb2_transact_get_items.consumed_capacity, fun undynamize_consumed_capacity_list/2},
      {<<"Responses">>, #ddb2_transact_get_items.responses, fun undynamize_transact_get_items_responses/2}
     ]}.

-spec transact_get_items_opts() -> opt_table().
transact_get_items_opts() ->
    [return_consumed_capacity_opt()].

-spec transact_get_items(transact_get_items_transact_items()) -> transact_get_items_return().
transact_get_items(RequestItems) ->
    transact_get_items(RequestItems, [], default_config()).

-spec transact_get_items(transact_get_items_transact_items(), transact_get_items_opts()) -> transact_get_items_return().
transact_get_items(RequestItems, Opts) ->
    transact_get_items(RequestItems, Opts, default_config()).

%%------------------------------------------------------------------------------
%% @doc
%% DynamoDB API:
%% [https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_TransactGetItems.html]
%%
%% Note that in the case of a `TransactionCanceledException' DynamoDB error, the error
%% response has the form `{error, {<<"TransactionCanceledException">>, {Message, CancellationReasons}}}'
%% where `Message' is a binary string and `CancellationReasons' is an ordered list in the form
%% `[{Code, Message}]', where `Code' is the status code of the result and `Message' is the cancellation
%% reason message description.
%%
%% ===Example===
%%
%% Get two items in a transaction.
%%
%% `
%% {ok, Record} =
%%     erlcloud_ddb2:transact_get_items(
%%         [{get, {<<"PersonalInfo">>, [{<<"Name">>, {s, <<"John Smith">>}},
%%                                      {<<"DOB">>, {s, <<"11/11/2011">>}}]}},
%%          {get, {<<"EmployeeRecord">>, [{<<"Name">>, {s, <<"John Smith">>}},
%%                                        {<<"DOH">>, {s, <<"11/11/2018">>}}]}}],
%%         [{return_consumed_capacity, total},
%%          {out, record}]),
%% '
%% @end
%%------------------------------------------------------------------------------
-spec transact_get_items(transact_get_items_transact_items(), transact_get_items_opts(), aws_config()) ->
                              transact_get_items_return().
transact_get_items(TransactItems, Opts, Config) ->
    {AwsOpts, DdbOpts} = opts(transact_get_items_opts(), Opts),
    Return = erlcloud_ddb_impl:request(
               Config,
               "DynamoDB_20120810.TransactGetItems",
               [{<<"TransactItems">>, dynamize_transact_get_items_transact_items(TransactItems)}]
               ++ AwsOpts,
               DdbOpts),
    case out(Return,
             fun(Json, UOpts) -> undynamize_record(transact_get_items_record(), Json, UOpts) end, DdbOpts) of
        {simple, #ddb2_transact_get_items{responses = Responses}} ->
            %% Simple return for transact_get_items is all items from all tables in a single list
            {ok, lists:map(fun(#ddb2_item_response{item = I}) -> I end, Responses)};
        {ok, _} = Out -> Out;
        {error, _} = Out -> Out
    end.

%%%------------------------------------------------------------------------------
%%% TransactWriteItem
%%%------------------------------------------------------------------------------

-type transact_write_items_opt() :: client_request_token_opt() |
                                return_consumed_capacity_opt() |
                                return_item_collection_metrics_opt() |
                                out_opt() |
                                no_request_opt() |
                                return_maps_opt().
-type transact_write_items_opts() :: [transact_write_items_opt()].

-type return_value_on_condition_check_failure_opt() :: {return_values_on_condition_check_failure, return_value()}.

-spec return_value_on_condition_check_failure_opt() -> opt_table_entry().
return_value_on_condition_check_failure_opt() ->
    {return_values_on_condition_check_failure, <<"ReturnValuesOnConditionCheckFailure">>, fun dynamize_return_value/1}.

-type transact_write_items_transact_item_opt() :: expression_attribute_names_opt() |
                           expression_attribute_values_opt() |
                           condition_expression_opt() |
                           return_value_on_condition_check_failure_opt().
-type transact_write_items_condition_check_item() :: {table_name(), key(), transact_write_items_transact_item_opts()}
                                                   | {table_name(), key(), binary(), transact_write_items_transact_item_opts()}.
-type transact_write_items_delete_item() :: {table_name(), key()}
                                       | {table_name(), key(), transact_write_items_transact_item_opts()}.
-type transact_write_items_put_item() :: {table_name(), in_item()}
                                       | {table_name(), in_item(), transact_write_items_transact_item_opts()}.
-type transact_write_items_update_item() :: {table_name(), key(), expression(), transact_write_items_transact_item_opts()}.

-type transact_write_items_condition_check() :: {condition_check, transact_write_items_condition_check_item()}.
-type transact_write_items_delete() :: {delete, transact_write_items_delete_item()}.
-type transact_write_items_put() :: {put, transact_write_items_put_item()}.
-type transact_write_items_update() :: {update, transact_write_items_update_item()}.

-type transact_write_items_transact_item() :: transact_write_items_condition_check() | transact_write_items_delete() | transact_write_items_put() | transact_write_items_update().
-type transact_write_items_transact_items() :: maybe_list(transact_write_items_transact_item()).

-type transact_write_items_transact_item_opts() :: [transact_write_items_transact_item_opt()].

-spec transact_write_items_transact_item_opts() -> opt_table().
transact_write_items_transact_item_opts() ->
    [expression_attribute_names_opt(),
     expression_attribute_values_opt(),
     condition_expression_opt(),
     return_value_on_condition_check_failure_opt()].

-spec dynamize_transact_write_items_transact_item(transact_write_items_transact_item()) -> jsx:json_term().
dynamize_transact_write_items_transact_item({condition_check, {TableName, Key, Opts}}) ->
    {AwsOpts, _DdbOpts} = opts(transact_write_items_transact_item_opts(), Opts),
    [{<<"ConditionCheck">>, [{<<"TableName">>, TableName}, {<<"Key">>, dynamize_key(Key)} | AwsOpts]}];
dynamize_transact_write_items_transact_item({delete, {TableName, Key}}) ->
    dynamize_transact_write_items_transact_item({delete, {TableName, Key, []}});
dynamize_transact_write_items_transact_item({delete, {TableName, Key, Opts}}) ->
    {AwsOpts, _DdbOpts} = opts(transact_write_items_transact_item_opts(), Opts),
    [{<<"Delete">>, [{<<"TableName">>, TableName}, {<<"Key">>, dynamize_key(Key)} | AwsOpts]}];
dynamize_transact_write_items_transact_item({put, {TableName, Item}}) ->
    dynamize_transact_write_items_transact_item({put, {TableName, Item, []}});
dynamize_transact_write_items_transact_item({put, {TableName, Item, Opts}}) ->
    {AwsOpts, _DdbOpts} = opts(transact_write_items_transact_item_opts(), Opts),
    [{<<"Put">>, [{<<"TableName">>, TableName}, {<<"Item">>, dynamize_item(Item)} | AwsOpts]}];
dynamize_transact_write_items_transact_item({update, {TableName, Key, UpdateExpression}}) ->
    dynamize_transact_write_items_transact_item({update, {TableName, Key, UpdateExpression, []}});
dynamize_transact_write_items_transact_item({update, {TableName, Key, UpdateExpression, Opts}}) ->
    {AwsOpts, _DdbOpts} = opts(transact_write_items_transact_item_opts(), Opts),
    [{<<"Update">>, [{<<"TableName">>, TableName}, {<<"Key">>, dynamize_key(Key)}, {<<"UpdateExpression">>, dynamize_expression(UpdateExpression)} | AwsOpts]}].

-spec dynamize_transact_write_items_transact_items(transact_write_items_transact_items())
                                          -> [jsx:json_term()].
dynamize_transact_write_items_transact_items(TransactItems) ->
    dynamize_maybe_list(fun dynamize_transact_write_items_transact_item/1, TransactItems).

-spec transact_write_items_opts() -> opt_table().
transact_write_items_opts() ->
    [client_request_token_opt(),
     return_consumed_capacity_opt(),
     return_item_collection_metrics_opt()].


-spec transact_write_items_record() -> record_desc().
transact_write_items_record() ->
    {#ddb2_transact_write_items{},
     [{<<"ConsumedCapacity">>, #ddb2_transact_write_items.consumed_capacity, fun undynamize_consumed_capacity_list/2},
      {<<"ItemCollectionMetrics">>, #ddb2_transact_write_items.item_collection_metrics,
       fun(V, Opts) -> undynamize_object(
                         fun({Table, Json}, Opts2) ->
                                 undynamize_item_collection_metric_list(Table, Json, Opts2)
                         end, V, Opts)
       end}
     ]}.

-type transact_write_items_return() :: ddb_return(#ddb2_transact_write_items{} | #ddb2_request{}, out_item()).

-spec transact_write_items(transact_write_items_transact_items()) -> transact_write_items_return().
transact_write_items(RequestItems) ->
    transact_write_items(RequestItems, [], default_config()).

-spec transact_write_items(transact_write_items_transact_items(), transact_write_items_opts()) -> transact_write_items_return().
transact_write_items(RequestItems, Opts) ->
    transact_write_items(RequestItems, Opts, default_config()).

%%------------------------------------------------------------------------------
%% @doc
%% DynamoDB API:
%% [https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_TransactWriteItems.html]
%%
%% Note that in the case of a `TransactionCanceledException' DynamoDB error, the error
%% response has the form `{error, {<<"TransactionCanceledException">>, {Message, CancellationReasons}}}'
%% where `Message' is a binary string and `CancellationReasons' is an ordered list in the form
%% `[{Code, Message}]', where `Code' is the status code of the result and `Message' is the cancellation
%% reason message description.
%%
%% ===Example===
%%
%% Put two items in a transaction.
%%
%% `
%% {ok, Record} =
%%     erlcloud_ddb2:transact_write_items(
%%         [{put, {<<"PersonalInfo">>, [{<<"Name">>, {s, <<"John Smith">>}},
%%                                      {<<"DOB">>, {s, <<"11/11/2011">>}}]}},
%%          {put, {<<"EmployeeRecord">>, [{<<"Name">>, {s, <<"John Smith">>}},
%%                                        {<<"DOH">>, {s, <<"11/11/2018">>}}]}}],
%%         [{return_consumed_capacity, total},
%%          {out, record}]),
%% '
%% @end
%%------------------------------------------------------------------------------
-spec transact_write_items(transact_write_items_transact_items(), transact_write_items_opts(), aws_config()) ->
                              transact_write_items_return().
transact_write_items(TransactItems, Opts, Config) ->
    {AwsOpts, DdbOpts} = opts(transact_write_items_opts(), Opts),
    Return = erlcloud_ddb_impl:request(
               Config,
               "DynamoDB_20120810.TransactWriteItems",
               [{<<"TransactItems">>, dynamize_transact_write_items_transact_items(TransactItems)}]
               ++ AwsOpts,
               DdbOpts),
    case out(Return,
             fun(Json, UOpts) -> undynamize_record(transact_write_items_record(), Json, UOpts) end, DdbOpts,
             #ddb2_transact_write_items.attributes, {ok, []}) of
        {ok, _} = Out -> Out;
        {error, _} = Out -> Out
    end.

%%%------------------------------------------------------------------------------
%%% UntagResource
%%%------------------------------------------------------------------------------

-type untag_resource_return() :: ok | {error, term()}.

-spec untag_resource(binary(), [tag_key()]) -> untag_resource_return().
untag_resource(ResourceArn, TagKeys) ->
    untag_resource(ResourceArn, TagKeys, default_config()).

%%------------------------------------------------------------------------------
%% @doc 
%% DynamoDB API:
%% [https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_UntagResource.html]
%%
%% ===Example===
%%
%% Untag the example keys of the Forum table.
%%
%% `
%% ok = erlcloud_ddb2:untag_resource(
%%        <<"arn:aws:dynamodb:us-west-2:111122223333:table/Forum">>, 
%%        [<<"example_key1">>, <<"example_key2">>]),
%% '
%% @end
%%------------------------------------------------------------------------------
-spec untag_resource(binary(), [tag_key()], aws_config())
                  -> untag_resource_return().
untag_resource(ResourceArn, TagKeys, Config) ->
    erlcloud_ddb_impl:request(
      Config,
      "DynamoDB_20120810.UntagResource",
      [{<<"ResourceArn">>, ResourceArn},
       {<<"TagKeys">>, TagKeys}]).

%%%------------------------------------------------------------------------------
%%% UpdateContinuousBackups
%%%------------------------------------------------------------------------------

-spec dynamize_point_in_time_recovery_enabled(boolean()) -> jsx:json_term().
dynamize_point_in_time_recovery_enabled(Value) ->
    [{<<"PointInTimeRecoveryEnabled">>, Value}].

-type update_continuous_backups_return() :: ddb_return(#ddb2_describe_continuous_backups{}, #ddb2_continuous_backups_description{}).

-spec update_continuous_backups(table_name(), boolean()) -> update_continuous_backups_return().
update_continuous_backups(TableName, PointInTimeRecoveryEnabled)
    when is_binary(TableName), is_boolean(PointInTimeRecoveryEnabled) ->
    update_continuous_backups(TableName, PointInTimeRecoveryEnabled, [], default_config()).

-spec update_continuous_backups(table_name(), boolean(), ddb_opts()) -> update_continuous_backups_return().
update_continuous_backups(TableName, PointInTimeRecoveryEnabled, Opts)
    when is_binary(TableName), is_boolean(PointInTimeRecoveryEnabled) ->
    update_continuous_backups(TableName, PointInTimeRecoveryEnabled, Opts, default_config()).

%%------------------------------------------------------------------------------
%% @doc
%% DynamoDB API:
%% [https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_UpdateContinuousBackups.html]
%%
%% ===Example===
%%
%% Enables or disables point in time recovery for the specified table.
%%
%% `
%% {ok, Record} =
%%     erlcloud_ddb2:update_continuous_backups(<<"Thread">>, true),
%% '
%% @end
%%------------------------------------------------------------------------------
-spec update_continuous_backups(table_name(), boolean(), ddb_opts(), aws_config()) -> update_continuous_backups_return().
update_continuous_backups(TableName, PointInTimeRecoveryEnabled, Opts, Config)
    when is_binary(TableName), is_boolean(PointInTimeRecoveryEnabled) ->
    {_AwsOpts, DdbOpts} = opts([], Opts),
    Return = erlcloud_ddb_impl:request(
     Config,
     "DynamoDB_20120810.UpdateContinuousBackups",
     [{<<"TableName">>, TableName},
      {<<"PointInTimeRecoverySpecification">>, dynamize_point_in_time_recovery_enabled(PointInTimeRecoveryEnabled)}],
     DdbOpts),
    out(Return, fun(Json, UOpts) -> undynamize_record(continuous_backups_record(), Json, UOpts) end,
        DdbOpts, #ddb2_describe_continuous_backups.continuous_backups_description).

%%%------------------------------------------------------------------------------
%%% UpdateItem
%%%------------------------------------------------------------------------------

-type update_action() :: put | add | delete.
-type in_update() :: {attr_name(), in_attr_value(), update_action()} | in_attr() | {attr_name(), delete}.
-type in_updates() :: maybe_list(in_update()).
-type json_update_action() :: {binary(), binary()}.
-type json_update() :: {attr_name(), [{binary(), [json_attr_value()]} | json_update_action()]}.
-spec dynamize_action(update_action()) -> json_update_action().
dynamize_action(put) ->
    {<<"Action">>, <<"PUT">>};
dynamize_action(add) ->
    {<<"Action">>, <<"ADD">>};
dynamize_action(delete) ->
    {<<"Action">>, <<"DELETE">>}.

-spec dynamize_update(in_update()) -> json_update().
dynamize_update({Name, Value, Action}) ->
    {Name, [{<<"Value">>, [dynamize_value(Value)]}, dynamize_action(Action)]};
dynamize_update({Name, delete}) ->
    {Name, [dynamize_action(delete)]};
dynamize_update({Name, Value}) ->
    %% Uses the default action of put
    dynamize_update({Name, Value, put}).

-spec dynamize_updates(in_updates()) -> [json_update()].
dynamize_updates(Updates) ->
    dynamize_maybe_list(fun dynamize_update/1, Updates).

-spec dynamize_update_item_updates_or_expression(in_updates() | expression()) -> [json_pair()].
dynamize_update_item_updates_or_expression(UpdateExpression) when is_binary(UpdateExpression) ->
    [{<<"UpdateExpression">>, dynamize_expression(UpdateExpression)}];
dynamize_update_item_updates_or_expression(Updates) ->
    case Updates of
        [] -> [];
        _  -> [{<<"AttributeUpdates">>, dynamize_updates(Updates)}]
    end.

-type update_item_opt() :: expression_attribute_names_opt() |
                           expression_attribute_values_opt() |
                           condition_expression_opt() |
                           conditional_op_opt() |
                           expected_opt() | 
                           {return_values, return_value()} |
                           return_consumed_capacity_opt() |
                           return_item_collection_metrics_opt() |
                           out_opt() |
                           no_request_opt() |
                           return_maps_opt().
-type update_item_opts() :: [update_item_opt()].

-spec update_item_opts() -> opt_table().
update_item_opts() ->
    [expression_attribute_names_opt(),
     expression_attribute_values_opt(),
     condition_expression_opt(),
     conditional_op_opt(),
     expected_opt(),
     {return_values, <<"ReturnValues">>, fun dynamize_return_value/1},
     return_consumed_capacity_opt(),
     return_item_collection_metrics_opt()].

-spec update_item_record() -> record_desc().
update_item_record() ->
    {#ddb2_update_item{},
     [{<<"Attributes">>, #ddb2_update_item.attributes, fun undynamize_item/2},
      {<<"ConsumedCapacity">>, #ddb2_update_item.consumed_capacity, fun undynamize_consumed_capacity/2},
      {<<"ItemCollectionMetrics">>, #ddb2_update_item.item_collection_metrics, 
       fun undynamize_item_collection_metrics/2}
     ]}.

-type update_item_return() :: ddb_return(#ddb2_update_item{} | #ddb2_request{}, out_item()).

-spec update_item(table_name(), key(), in_updates() | expression()) -> update_item_return().
update_item(Table, Key, UpdatesOrExpression) ->
    update_item(Table, Key, UpdatesOrExpression, [], default_config()).

-spec update_item(table_name(), key(), in_updates() | expression(), update_item_opts()) -> update_item_return().
update_item(Table, Key, UpdatesOrExpression, Opts) ->
    update_item(Table, Key, UpdatesOrExpression, Opts, default_config()).

%%------------------------------------------------------------------------------
%% @doc 
%% DynamoDB API:
%% [http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_UpdateItem.html]
%%
%% AttributeUpdates is treated as a required parameter because callers
%% will almost always provide it. If no updates are desired, You can
%% pass [] for that argument.
%%
%% ===Example===
%%
%% Update specific item in the "Thread" table by setting "LastPostBy"
%% if it has the expected previous value.
%%
%% `
%% {ok, Item} = 
%%     erlcloud_ddb2:update_item(
%%       <<"Thread">>, 
%%       [{<<"ForumName">>, {s, <<"Amazon DynamoDB">>}},
%%        {<<"Subject">>, {s, <<"How do I update multiple items?">>}}],
%%       <<"set LastPostedBy = :val1">>,
%%       [{condition_expression, <<"LastPostedBy = :val2">>},
%%        {expression_attribute_values,
%%         [{<<":val1">>, <<"alice@example.com">>},
%%          {<<":val2">>, <<"fred@example.com">>}]},
%%        {return_values, all_new}]),
%% '
%% @end
%%------------------------------------------------------------------------------
-spec update_item(table_name(), key(), in_updates() | expression(), update_item_opts(), aws_config())
                 -> update_item_return().
update_item(Table, Key, UpdatesOrExpression, Opts, Config) ->
    {AwsOpts, DdbOpts} = opts(update_item_opts(), Opts),
    Return = erlcloud_ddb_impl:request(
               Config,
               "DynamoDB_20120810.UpdateItem",
               [{<<"TableName">>, Table},
                {<<"Key">>, dynamize_key(Key)}]
               ++ dynamize_update_item_updates_or_expression(UpdatesOrExpression)
               ++ AwsOpts,
               DdbOpts),
    out(Return, fun(Json, UOpts) -> undynamize_record(update_item_record(), Json, UOpts) end, DdbOpts, 
        #ddb2_update_item.attributes, {ok, []}).

%%%------------------------------------------------------------------------------
%%% UpdateGlobalTable
%%%------------------------------------------------------------------------------

-spec dynamize_replica_update(replica_update()) -> jsx:json_term().
dynamize_replica_update({create, Replica}) ->
    [{<<"Create">>, dynamize_replica(Replica)}];
dynamize_replica_update({delete, Replica}) ->
    [{<<"Delete">>, dynamize_replica(Replica)}].

-spec update_global_table_record() -> record_desc().
update_global_table_record() ->
    {#ddb2_update_global_table{},
     [{<<"GlobalTableDescription">>, #ddb2_update_global_table.global_table_description, 
       fun(V, Opts) -> undynamize_record(global_table_description_record(), V, Opts) end}
     ]}. 

-type update_global_table_return() :: ddb_return(#ddb2_update_global_table{}, #ddb2_global_table_description{}).

-spec update_global_table(table_name(), maybe_list(replica_update()))
                         -> update_global_table_return().
update_global_table(GlobalTableName, ReplicaUpdates) ->
    update_global_table(GlobalTableName, ReplicaUpdates, [], default_config()).

-spec update_global_table(table_name(), maybe_list(replica_update()),
                          ddb_opts() | aws_config())
                         -> update_global_table_return().
update_global_table(GlobalTableName, ReplicaUpdates, Opts) when is_list(Opts) ->
    update_global_table(GlobalTableName, ReplicaUpdates, Opts, default_config());
update_global_table(GlobalTableName, ReplicaUpdates, Config) when is_record(Config, aws_config) ->
    update_global_table(GlobalTableName, ReplicaUpdates, [], Config).

%%------------------------------------------------------------------------------
%% @doc 
%% DynamoDB API:
%% [https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_UpdateGlobalTable.html]
%%
%% ===Example===
%%
%% Update a global table called "Thread" in us-east-1 and eu-west-1.
%%
%% `
%% {ok, Record} =
%%     erlcloud_ddb2:update_global_table(<<"Thread">>,
%%                                       [{create, {region_name, <<"us-east-1">>}},
%%                                        {delete, {region_name, <<"eu-west-1">>}}]),
%% '
%% @end
%%------------------------------------------------------------------------------

-spec update_global_table(table_name(), [replica_update()], ddb_opts(),
                          aws_config())
                         -> update_global_table_return().
update_global_table(GlobalTableName, ReplicaUpdates, Opts, Config) ->
    {[], DdbOpts} = opts([], Opts),
    Return = erlcloud_ddb_impl:request(
               Config,
               "DynamoDB_20120810.UpdateGlobalTable",
               [{<<"GlobalTableName">>, GlobalTableName},
                {<<"ReplicaUpdates">>, dynamize_maybe_list(fun dynamize_replica_update/1, ReplicaUpdates)}],
               DdbOpts),
    out(Return, fun(Json, UOpts) -> undynamize_record(update_global_table_record(), Json, UOpts) end, 
        DdbOpts, #ddb2_update_global_table.global_table_description).

%%%------------------------------------------------------------------------------
%%% UpdateGlobalTableSettings
%%%------------------------------------------------------------------------------

-type update_global_table_settings_return() :: ddb_return(#ddb2_update_global_table_settings{}, [#ddb2_replica_settings_description{}]).

-type global_table_global_secondary_index_settings_update_opt() :: {index_name, binary()}|
                                                                   {provisioned_write_capacity_auto_scaling_settings_update, auto_scaling_settings_update_opts()}|
                                                                   {provisioned_read_capacity_units, read_units()}|
                                                                   {provisioned_write_capacity_units, write_units()}.

-type global_table_global_secondary_index_settings_update_opts() :: [global_table_global_secondary_index_settings_update_opt()].

-type replica_global_secondary_index_settings_update_opt() :: {index_name, binary()}|
                                                              {provisioned_read_capacity_auto_scaling_settings_update, auto_scaling_settings_update_opts()}|
                                                              {provisioned_read_capacity_units, read_units()}.

-type replica_global_secondary_index_settings_update_opts() :: [replica_global_secondary_index_settings_update_opt()].

-type replica_settings_update_opt() :: {region_name, binary()}|
                                       {replica_global_secondary_index_settings_update, [global_table_global_secondary_index_settings_update_opts()]}|
                                       {replica_provisioned_read_capacity_auto_scaling_settings_update, auto_scaling_settings_update_opts()}|
                                       {replica_provisioned_read_capacity_units, read_units()}.

-type replica_settings_update_opts() :: [replica_settings_update_opts()].

-spec dynamize_global_table_global_secondary_index_settings_update_opt(global_table_global_secondary_index_settings_update_opt()) -> json_pair().
dynamize_global_table_global_secondary_index_settings_update_opt({index_name, IndexName}) ->
    {<<"IndexName">>, IndexName};
dynamize_global_table_global_secondary_index_settings_update_opt({provisioned_write_capacity_auto_scaling_settings_update, Update}) ->
    {<<"ProvisionedWriteCapacityAutoScalingSettingsUpdate">>, dynamize_auto_scaling_settings_update_opts(Update)};
dynamize_global_table_global_secondary_index_settings_update_opt({provisioned_read_capacity_units, ProvisionedReadCapacityUnits}) ->
    {<<"ProvisionedReadCapacityUnits">>, ProvisionedReadCapacityUnits};
dynamize_global_table_global_secondary_index_settings_update_opt({provisioned_write_capacity_units, ProvisionedWriteCapacityUnits}) ->
    {<<"ProvisionedWriteCapacityUnits">>, ProvisionedWriteCapacityUnits}.

-spec dynamize_global_table_global_secondary_index_settings_update_opts(global_table_global_secondary_index_settings_update_opts()) -> jsx:json_term().
dynamize_global_table_global_secondary_index_settings_update_opts(Opts) ->
    dynamize_maybe_list(fun dynamize_global_table_global_secondary_index_settings_update_opt/1, Opts).

-spec dynamize_global_table_global_secondary_index_settings_update([global_table_global_secondary_index_settings_update_opts()]) -> jsx:json_term().
dynamize_global_table_global_secondary_index_settings_update(Updates) ->
    [dynamize_global_table_global_secondary_index_settings_update_opts(Update) || Update <- Updates].

-spec dynamize_replica_global_secondary_index_settings_update_opt(replica_global_secondary_index_settings_update_opt()) -> json_pair().
dynamize_replica_global_secondary_index_settings_update_opt({index_name, IndexName}) ->
    {<<"IndexName">>, IndexName};
dynamize_replica_global_secondary_index_settings_update_opt({provisioned_read_capacity_auto_scaling_settings_update, Update}) ->
    {<<"ProvisionedReadCapacityAutoScalingSettingsUpdate">>, dynamize_auto_scaling_settings_update_opts(Update)};
dynamize_replica_global_secondary_index_settings_update_opt({provisioned_read_capacity_units, Units}) ->
    {<<"ProvisionedReadCapacityUnits">>, Units}.

-spec dynamize_replica_global_secondary_index_settings_update_opts(replica_global_secondary_index_settings_update_opts()) -> jsx:json_term().
dynamize_replica_global_secondary_index_settings_update_opts(Opts) ->
    dynamize_maybe_list(fun dynamize_replica_global_secondary_index_settings_update_opt/1, Opts).

-spec dynamize_replica_global_secondary_index_settings_update([replica_global_secondary_index_settings_update_opts()]) -> jsx:json_term().
dynamize_replica_global_secondary_index_settings_update(Updates) ->
    [dynamize_replica_global_secondary_index_settings_update_opts(Update) || Update <- Updates].

-spec dynamize_replica_settings_update_opt(replica_settings_update_opt()) -> json_pair().
dynamize_replica_settings_update_opt({region_name, RegionName}) ->
    {<<"RegionName">>, RegionName};
dynamize_replica_settings_update_opt({replica_global_secondary_index_settings_update, Update}) ->
    {<<"ReplicaGlobalSecondaryIndexSettingsUpdate">>, dynamize_replica_global_secondary_index_settings_update(Update)};
dynamize_replica_settings_update_opt({replica_provisioned_read_capacity_auto_scaling_settings_update, Update}) ->
    {<<"ReplicaProvisionedReadCapacityAutoScalingSettingsUpdate">>, dynamize_auto_scaling_settings_update_opts(Update)};
dynamize_replica_settings_update_opt({replica_provisioned_read_capacity_units, Units}) ->
    {<<"ReplicaProvisionedReadCapacityUnits">>, Units}.

-spec dynamize_replica_settings_update_opts(replica_settings_update_opts()) -> jsx:json_term().
dynamize_replica_settings_update_opts(Opts) ->
    dynamize_maybe_list(fun dynamize_replica_settings_update_opt/1, Opts).

-spec dynamize_replica_settings_updates([replica_settings_update_opts()]) -> jsx:json_term().
dynamize_replica_settings_updates(Updates) ->
    [dynamize_replica_settings_update_opts(Update) || Update <- Updates].

-type update_global_table_settings_opt() :: {global_table_billing_mode, billing_mode()}|
                                            {global_table_global_secondary_index_settings_update, [global_table_global_secondary_index_settings_update_opts()]}|
                                            {global_table_provisioned_write_capacity_auto_scaling_settings_update, auto_scaling_settings_update_opts()}|
                                            {global_table_provisioned_write_capacity_units, write_units()}|
                                            {replica_settings_update, [replica_settings_update_opts()]}|
                                            out_opt().

-type update_global_table_settings_opts() :: [update_global_table_settings_opt()].

-spec update_global_table_settings_opts() -> opt_table().
update_global_table_settings_opts() ->
    [{global_table_billing_mode, <<"GlobalTableBillingMode">>, fun dynamize_billing_mode/1},
     {global_table_global_secondary_index_settings_update, <<"GlobalTableGlobalSecondaryIndexSettingsUpdate">>, fun dynamize_global_table_global_secondary_index_settings_update/1},
     {global_table_provisioned_write_capacity_auto_scaling_settings_update, <<"GlobalTableProvisionedWriteCapacityAutoScalingSettingsUpdate">>, fun dynamize_auto_scaling_settings_update_opts/1},
     {global_table_provisioned_write_capacity_units, <<"GlobalTableProvisionedWriteCapacityUnits">>, fun id/1},
     {replica_settings_update, <<"ReplicaSettingsUpdate">>, fun dynamize_replica_settings_updates/1}].

-spec update_global_table_settings_record() -> record_desc().
update_global_table_settings_record() ->
    {#ddb2_update_global_table_settings{},
     [{<<"GlobalTableName">>, #ddb2_update_global_table_settings.global_table_name, fun id/2},
      {<<"ReplicaSettings">>, #ddb2_update_global_table_settings.replica_settings,
       fun(V, Opts) -> [undynamize_record(replica_settings_description_record(), I, Opts) || I <- V] end}]}.


-spec update_global_table_settings(table_name(), update_global_table_settings_opts()) -> update_global_table_settings_return().
update_global_table_settings(GlobalTableName, Opts) ->
    update_global_table_settings(GlobalTableName, Opts, default_config()).

%%------------------------------------------------------------------------------
%% @doc
%% DynamoDB API:
%% [https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_UpdateGlobalTableSettings.html]
%%
%% ===Example===
%%
%% Update global table settings for a table called "Thread" in us-west-2 and eu-west-2.
%%
%% `
%% ReadUnits = 10,
%% WriteUnits = 10,
%% erlcloud_ddb2:update_global_table_settings(
%%   <<"Thread">>,
%%   [{global_table_billing_mode, provisioned},
%%    {global_table_global_secondary_index_settings_update, [[{index_name, <<"id-index">>},
%%                                                            {provisioned_write_capacity_units, WriteUnits}]]},
%%    {global_table_provisioned_write_capacity_units, WriteUnits},
%%    {replica_settings_update, [[{region_name, <<"us-west-2">>},
%%                                {replica_global_secondary_index_settings_update, [[{index_name, <<"id-index">>},
%%                                                                                   {provisioned_read_capacity_units, ReadUnits}]]},
%%                                {replica_provisioned_read_capacity_units, ReadUnits}],
%%                               [{region_name, <<"eu-west-2">>},
%%                                {replica_global_secondary_index_settings_update, [[{index_name, <<"id-index">>},
%%                                                                                   {provisioned_read_capacity_units, ReadUnits}]]},
%%                                {replica_provisioned_read_capacity_units, ReadUnits}]]}])
%% '
%% @end
%%------------------------------------------------------------------------------

-spec update_global_table_settings(table_name(), update_global_table_settings_opts(), aws_config()) -> update_global_table_settings_return().
update_global_table_settings(GlobalTableName, Opts, Config) ->
    {AwsOpts, DdbOpts} = opts(update_global_table_settings_opts(), Opts),
    Return = erlcloud_ddb_impl:request(
        Config,
        "DynamoDB_20120810.UpdateGlobalTableSettings",
        [{<<"GlobalTableName">>, GlobalTableName} | AwsOpts],
        DdbOpts),
    out(Return, fun(Json, UOpts) -> undynamize_record(update_global_table_settings_record(), Json, UOpts) end,
        DdbOpts, #ddb2_update_global_table_settings.replica_settings).


%%%------------------------------------------------------------------------------
%%% UpdateTable
%%%------------------------------------------------------------------------------

-type update_table_return() :: ddb_return(#ddb2_update_table{}, #ddb2_table_description{}).

-type global_secondary_index_update() :: {index_name(), read_units(), write_units()} |
                                         {index_name(), delete} |
                                         global_secondary_index_def().
-type global_secondary_index_updates() :: maybe_list(global_secondary_index_update()).

-type provisioned_throughput_override_opt() :: {read_capacity_units, non_neg_integer()}.
-type provisioned_throughput_override_opts() :: [provisioned_throughput_override_opt()].

-type create_replication_group_member_action_opt() :: {global_secondary_indexes, binary()}|
                                                      {kms_master_key_id, binary()}|
                                                      {provisioned_throughput_override, provisioned_throughput_override_opts()}|
                                                      {region_name, binary()}.

-type create_replication_group_member_action_opts() :: [create_replication_group_member_action_opt()].

-type delete_replication_group_member_action_opt() :: {region_name, binary()}.

-type delete_replication_group_member_action_opts() :: [create_replication_group_member_action_opt()].

-type update_replication_group_member_action_opt() :: {global_secondary_indexes, binary()}|
                                                      {kms_master_key_id, binary()}|
                                                      {provisioned_throughput_override, provisioned_throughput_override_opts()}|
                                                      {region_name, binary()}.

-type update_replication_group_member_action_opts() :: [update_replication_group_member_action_opt()].

-type replication_group_update_opt() :: {create, create_replication_group_member_action_opts()}|
                                        {delete, delete_replication_group_member_action_opts()}|
                                        {update, update_replication_group_member_action_opts()}.
-type replication_group_update_opts() :: [replication_group_update_opt()].

-spec dynamize_global_secondary_index_update(global_secondary_index_update()) -> jsx:json_term().
dynamize_global_secondary_index_update({IndexName, ReadUnits, WriteUnits})
    when is_integer(ReadUnits), is_integer(WriteUnits) ->
    [{<<"Update">>, [
        {<<"IndexName">>, IndexName},
        {<<"ProvisionedThroughput">>, dynamize_provisioned_throughput({ReadUnits, WriteUnits})}
    ]}];
dynamize_global_secondary_index_update({IndexName, delete}) ->
    [{<<"Delete">>, [
        {<<"IndexName">>, IndexName}
    ]}];
dynamize_global_secondary_index_update(Index) ->
    [{<<"Create">>, dynamize_global_secondary_index(Index)}].

-spec dynamize_global_secondary_index_updates(global_secondary_index_updates()) -> jsx:json_term().
dynamize_global_secondary_index_updates(Updates) ->
    dynamize_maybe_list(fun dynamize_global_secondary_index_update/1, Updates).

-spec dynamize_provisioned_throughput_override_opt(provisioned_throughput_override_opt()) -> json_pair().
dynamize_provisioned_throughput_override_opt({read_capacity_units, ReadCapacityUnits}) ->
    {<<"ReadCapacityUnits">>, ReadCapacityUnits}.

-spec dynamize_provisioned_throughput_override_opts(provisioned_throughput_override_opts()) -> jsx:json_term().
dynamize_provisioned_throughput_override_opts(Opts) ->
    dynamize_maybe_list(fun dynamize_provisioned_throughput_override_opt/1, Opts).

-spec dynamize_create_replication_group_member_action_opt(create_replication_group_member_action_opt()) -> json_pair().
dynamize_create_replication_group_member_action_opt({global_secondary_indexes, GlobalSecondaryIndexes}) ->
    {<<"GlobalSecondaryIndexes">>, GlobalSecondaryIndexes};
dynamize_create_replication_group_member_action_opt({kms_master_key_id, KMSMasterKeyId}) ->
    {<<"KMSMasterKeyId">>, KMSMasterKeyId};
dynamize_create_replication_group_member_action_opt({provisioned_throughput_override, ProvisionedThroughputOverride}) ->
    {<<"ProvisionedThroughputOverride">>, dynamize_provisioned_throughput_override_opts(ProvisionedThroughputOverride)};
dynamize_create_replication_group_member_action_opt({region_name, RegionName}) ->
    {<<"RegionName">>, RegionName}.

-spec dynamize_create_replication_group_member_action_opts(create_replication_group_member_action_opts()) -> jsx:json_term().
dynamize_create_replication_group_member_action_opts(Opts) ->
    dynamize_maybe_list(fun dynamize_create_replication_group_member_action_opt/1, Opts).

-spec dynamize_delete_replication_group_member_action_opt(delete_replication_group_member_action_opt()) -> json_pair().
dynamize_delete_replication_group_member_action_opt({region_name, RegionName}) ->
    {<<"RegionName">>, RegionName}.

-spec dynamize_delete_replication_group_member_action_opts(delete_replication_group_member_action_opts()) -> jsx:json_term().
dynamize_delete_replication_group_member_action_opts(Opts) ->
    dynamize_maybe_list(fun dynamize_delete_replication_group_member_action_opt/1, Opts).

-spec dynamize_update_replication_group_member_action_opt(update_replication_group_member_action_opt()) -> json_pair().
dynamize_update_replication_group_member_action_opt({global_secondary_indexes, GlobalSecondaryIndexes}) ->
    {<<"GlobalSecondaryIndexes">>, GlobalSecondaryIndexes};
dynamize_update_replication_group_member_action_opt({kms_master_key_id, KMSMasterKeyId}) ->
    {<<"KMSMasterKeyId">>, KMSMasterKeyId};
dynamize_update_replication_group_member_action_opt({provisioned_throughput_override, ProvisionedThroughputOverride}) ->
    {<<"ProvisionedThroughputOverride">>, ProvisionedThroughputOverride};
dynamize_update_replication_group_member_action_opt({region_name, RegionName}) ->
    {<<"RegionName">>, RegionName}.

-spec dynamize_update_replication_group_member_action_opts(update_replication_group_member_action_opts()) -> jsx:json_term().
dynamize_update_replication_group_member_action_opts(Opts) ->
    dynamize_maybe_list(fun dynamize_update_replication_group_member_action_opt/1, Opts).

-spec dynamize_replication_group_update(replication_group_update_opt()) -> json_pair().
dynamize_replication_group_update({create, Create}) ->
    {<<"Create">>, dynamize_create_replication_group_member_action_opts(Create)};
dynamize_replication_group_update({delete, Delete}) ->
    {<<"Delete">>, dynamize_delete_replication_group_member_action_opts(Delete)};
dynamize_replication_group_update({update, Update}) ->
    {<<"Update">>, dynamize_update_replication_group_member_action_opts(Update)}.

-spec dynamize_replication_group_updates(replication_group_update_opts()) -> jsx:json_term().
dynamize_replication_group_updates(Updates) ->
    [dynamize_maybe_list(fun dynamize_replication_group_update/1, Update) || Update <- Updates].

-type update_table_opt() :: {billing_mode, billing_mode()} |
                            {provisioned_throughput, {read_units(), write_units()}} |
                            {attribute_definitions, attr_defs()} |
                            {global_secondary_index_updates, global_secondary_index_updates()} |
                            {stream_specification, stream_specification()} |
                            boolean_opt(deletion_protection_enabled) |
                            out_opt().
-type update_table_opts() :: [update_table_opt()].

-spec update_table_opts() -> opt_table().
update_table_opts() ->
    [{billing_mode, <<"BillingMode">>, fun dynamize_billing_mode/1},
     {provisioned_throughput, <<"ProvisionedThroughput">>, fun dynamize_provisioned_throughput/1},
     {attribute_definitions, <<"AttributeDefinitions">>, fun dynamize_attr_defs/1},
     {global_secondary_index_updates, <<"GlobalSecondaryIndexUpdates">>,
      fun dynamize_global_secondary_index_updates/1},
     {stream_specification, <<"StreamSpecification">>, fun dynamize_stream_specification/1},
     {replica_updates, <<"ReplicaUpdates">>, fun dynamize_replication_group_updates/1},
     {deletion_protection_enabled, <<"DeletionProtectionEnabled">>, fun id/1}].

-spec update_table_record() -> record_desc().
update_table_record() ->
    {#ddb2_update_table{},
     [{<<"TableDescription">>, #ddb2_update_table.table_description,
       fun(V, Opts) -> undynamize_record(table_description_record(), V, Opts) end}
     ]}.

-spec update_table(table_name(), update_table_opts()) -> update_table_return().
update_table(Table, Opts) ->
    update_table(Table, Opts, default_config()).

%%------------------------------------------------------------------------------
%% @doc 
%% DynamoDB API:
%% [http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_UpdateTable.html]
%%
%% ===Example===
%%
%% Update table "Thread" to have 10 units of read and write capacity.
%% Update secondary index `<<"SubjectIdx">>' to have 10 units of read write capacity
%% ```
%% erlcloud_ddb2:update_table(
%%   <<"Thread">>,
%%   [{provisioned_throughput, {10, 10}},
%%    {global_secondary_index_updates, [{<<"SubjectIdx">>, 10, 10}]}])
%% '''
%% @end
%%------------------------------------------------------------------------------
-spec update_table(table_name(), update_table_opts(), aws_config()) -> update_table_return();
                  (table_name(), read_units(), write_units()) -> update_table_return().
update_table(Table, Opts, Config) when is_list(Opts) ->
    {AwsOpts, DdbOpts} = opts(update_table_opts(), Opts),
    Return = erlcloud_ddb_impl:request(
               Config,
               "DynamoDB_20120810.UpdateTable",
               [{<<"TableName">>, Table} | AwsOpts],
               DdbOpts),
    out(Return, fun(Json, UOpts) -> undynamize_record(update_table_record(), Json, UOpts) end, 
        DdbOpts, #ddb2_update_table.table_description);
update_table(Table, ReadUnits, WriteUnits) ->
    update_table(Table, ReadUnits, WriteUnits, [], default_config()).

-spec update_table(table_name(), read_units(), write_units(), update_table_opts()) 
                  -> update_table_return().
update_table(Table, ReadUnits, WriteUnits, Opts) ->
    update_table(Table, ReadUnits, WriteUnits, Opts, default_config()).

-spec update_table(table_name(), non_neg_integer(), non_neg_integer(), update_table_opts(), 
                   aws_config()) 
                  -> update_table_return().
update_table(Table, ReadUnits, WriteUnits, Opts, Config) ->
    update_table(Table, [{provisioned_throughput, {ReadUnits, WriteUnits}} | Opts], Config).


%%%------------------------------------------------------------------------------
%%% UpdateTableReplicaAutoScaling
%%%------------------------------------------------------------------------------

-type update_table_replica_auto_scaling_return() :: ddb_return(#ddb2_update_table_replica_auto_scaling{}, #ddb2_table_auto_scaling_description{}).

-type global_secondary_index_auto_scaling_update_opt() :: {index_name, binary()}|
                                                          {provisioned_read_capacity_auto_scaling_update, auto_scaling_settings_update_opts()}.

-type global_secondary_index_auto_scaling_update_opts() :: [global_secondary_index_auto_scaling_update_opt()].

-type replica_global_secondary_index_auto_scaling_opt() :: {index_name, binary()}|
                                                           {provisioned_read_capacity_auto_scaling_update, auto_scaling_settings_update_opts()}.

-type replica_global_secondary_index_auto_scaling_opts() :: [replica_global_secondary_index_auto_scaling_opt()].

-type replica_auto_scaling_update_opt() :: {region_name, binary()}|
                                           {replica_global_secondary_index_updates, [replica_global_secondary_index_auto_scaling_opts()]}|
                                           {replica_provisioned_read_capacity_auto_scaling_update, auto_scaling_settings_update_opts()}.
-type replica_auto_scaling_update_opts() :: [replica_auto_scaling_update_opt()].

-spec dynamize_global_secondary_index_auto_scaling_update_opt(global_secondary_index_auto_scaling_update_opt()) -> json_pair().
dynamize_global_secondary_index_auto_scaling_update_opt({index_name, IndexName}) ->
    {<<"IndexName">>, IndexName};
dynamize_global_secondary_index_auto_scaling_update_opt({provisioned_write_capacity_auto_scaling_update, ProvisionedWriteCapacityAutoScalingUpdate}) ->
    {<<"ProvisionedWriteCapacityAutoScalingUpdate">>, dynamize_maybe_list(fun dynamize_auto_scaling_settings_update_opt/1,
                                                                          ProvisionedWriteCapacityAutoScalingUpdate)}.

-spec dynamize_global_secondary_index_auto_scaling_update_opts([replica_global_secondary_index_auto_scaling_opts()]) -> jsx:json_term().
dynamize_global_secondary_index_auto_scaling_update_opts(GlobalSecondaryIndexUpdates) ->
    [dynamize_maybe_list(fun dynamize_global_secondary_index_auto_scaling_update_opt/1,
                         Update) || Update <- GlobalSecondaryIndexUpdates].

-spec dynamize_replica_global_secondary_index_auto_scaling_update_opt(replica_global_secondary_index_auto_scaling_opt()) -> json_pair().
dynamize_replica_global_secondary_index_auto_scaling_update_opt({index_name, IndexName}) ->
    {<<"IndexName">>, IndexName};
dynamize_replica_global_secondary_index_auto_scaling_update_opt({provisioned_read_capacity_auto_scaling_update, ProvisionedReadCapacityAutoScalingUpdate}) ->
    {<<"ProvisionedReadCapacityAutoScalingUpdate">>, dynamize_auto_scaling_settings_update_opts(ProvisionedReadCapacityAutoScalingUpdate)}.

-spec dynamize_replica_global_secondary_index_auto_scaling_update_opts(replica_global_secondary_index_auto_scaling_opts()) -> jsx:json_term().
dynamize_replica_global_secondary_index_auto_scaling_update_opts(Opts) ->
    dynamize_maybe_list(fun dynamize_replica_global_secondary_index_auto_scaling_update_opt/1,
                        Opts).

-spec dynamize_replica_auto_scaling_update(replica_auto_scaling_update_opt()) -> json_pair().
dynamize_replica_auto_scaling_update({region_name, RegionName}) ->
    {<<"RegionName">>, RegionName};
dynamize_replica_auto_scaling_update({replica_global_secondary_index_updates, ReplicaGlobalSecondaryIndexUpdates}) ->
    {<<"ReplicaGlobalSecondaryIndexUpdates">>, [dynamize_replica_global_secondary_index_auto_scaling_update_opts(Update) || Update <- ReplicaGlobalSecondaryIndexUpdates]};
dynamize_replica_auto_scaling_update({replica_provisioned_read_capacity_auto_scaling_update, ReplicaProvisionedReadCapacityAutoScalingUpdate}) ->
    {<<"ReplicaProvisionedReadCapacityAutoScalingUpdate">>, dynamize_auto_scaling_settings_update_opts(ReplicaProvisionedReadCapacityAutoScalingUpdate)}.

-spec dynamize_replica_auto_scaling_updates([replica_auto_scaling_update_opts()]) -> jsx:json_term().
dynamize_replica_auto_scaling_updates(ReplicaUpdates) ->
    [dynamize_maybe_list(fun dynamize_replica_auto_scaling_update/1,
                         Update) || Update <- ReplicaUpdates].

-spec maybe_update_config_timeout(aws_config(), MinDesiredTimeout :: pos_integer()) -> aws_config().
maybe_update_config_timeout(Config, _MinDesiredTimeout) ->
    UpdatedTimeout = erlcloud_aws:get_timeout(Config),
    Config#aws_config{timeout = UpdatedTimeout}.

-type update_table_replica_auto_scaling_opt() :: {global_secondary_index_updates, [global_secondary_index_auto_scaling_update_opts()]}|
                                                 {provisioned_write_capacity_auto_scaling_update, auto_scaling_settings_update_opts()}|
                                                 {replica_updates, [replica_auto_scaling_update_opts()]}|
                                                 out_opt().
-type update_table_replica_auto_scaling_opts() :: [update_table_replica_auto_scaling_opt()].

-spec update_table_replica_auto_scaling_opts() -> opt_table().
update_table_replica_auto_scaling_opts() ->
    [{global_secondary_index_updates, <<"GlobalSecondaryIndexUpdates">>,
      fun dynamize_global_secondary_index_auto_scaling_update_opts/1},
     {provisioned_write_capacity_auto_scaling_update, <<"ProvisionedWriteCapacityAutoScalingUpdate">>,
      fun dynamize_auto_scaling_settings_update_opts/1},
     {replica_updates, <<"ReplicaUpdates">>,
      fun dynamize_replica_auto_scaling_updates/1}].

-spec update_table_replica_auto_scaling_record() -> record_desc().
update_table_replica_auto_scaling_record() ->
    {#ddb2_update_table_replica_auto_scaling{},
     [{<<"TableAutoScalingDescription">>, #ddb2_update_table_replica_auto_scaling.table_auto_scaling_description,
       fun(V, Opts) -> undynamize_record(table_auto_scaling_description_record(), V, Opts) end}]}.

-spec update_table_replica_auto_scaling(table_name(), update_table_replica_auto_scaling_opts()) -> update_table_replica_auto_scaling_return().
update_table_replica_auto_scaling(Table, Opts) ->
    update_table_replica_auto_scaling(Table, Opts, default_config()).

%%------------------------------------------------------------------------------
%% @doc
%% DynamoDB API:
%% [http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_UpdateTableReplicaAutoScaling.html]
%%
%% Note: This method only applies to Version 2019.11.21 of global tables.
%% Note:
%%
%% ===Example===
%%
%% Update table "Thread" to scale between 10 and 20 provisioned read and write units uniformly across replica regions.
%% ```
%% AutoScalingSettingsUpdate = [{maximum_units, 20},
%%                              {minimum_units, 10},
%%                              {scaling_policy_update, [{target_tracking_scaling_policy_configuration, [{target_value, 60.0}]}]}],
%% erlcloud_ddb2:update_table_replica_auto_scaling(
%%   <<"Thread">>,
%%   [{global_secondary_index_updates, [[{index_name, <<"id-index">>},
%%                                       {provisioned_write_capacity_auto_scaling_update, AutoScalingSettingsUpdate}]]},
%%    {provisioned_write_capacity_auto_scaling_update, AutoScalingSettingsUpdate},
%%    {replica_updates, [[{region_name, <<"us-west-2">>},
%%                        {replica_global_secondary_index_updates, [[{index_name, <<"id-index">>},
%%                                                                   {provisioned_read_capacity_auto_scaling_update, AutoScalingSettingsUpdate}]]},
%%                        {replica_provisioned_read_capacity_auto_scaling_update, AutoScalingSettingsUpdate}],
%%                       [{region_name, <<"eu-west-2">>},
%%                        {replica_global_secondary_index_updates, [[{index_name, <<"id-index">>},
%%                                                                   {provisioned_read_capacity_auto_scaling_update, AutoScalingSettingsUpdate}]]},
%%                        {replica_provisioned_read_capacity_auto_scaling_update, AutoScalingSettingsUpdate}]]}]).
%% '''
%% @end
%%------------------------------------------------------------------------------
-spec update_table_replica_auto_scaling(table_name(), update_table_replica_auto_scaling_opts(), aws_config()) -> update_table_replica_auto_scaling_return().
update_table_replica_auto_scaling(Table, Opts, Config) when is_list(Opts) ->
    % The default timeout for this endpoint is updated to 25 seconds below due to the endpoint
    % regularly taking around 20 seconds during testing.
    % Any non-default timeout already written to the config will not be overridden.
    UpdatedConfig = maybe_update_config_timeout(Config, 25000),
    {AwsOpts, DdbOpts} = opts(update_table_replica_auto_scaling_opts(), Opts),
    Return = erlcloud_ddb_impl:request(
        UpdatedConfig,
        "DynamoDB_20120810.UpdateTableReplicaAutoScaling",
        [{<<"TableName">>, Table} | AwsOpts],
        DdbOpts),
    out(Return, fun(Json, UOpts) -> undynamize_record(update_table_replica_auto_scaling_record(), Json, UOpts) end,
        DdbOpts, #ddb2_update_table_replica_auto_scaling.table_auto_scaling_description).

%%%------------------------------------------------------------------------------
%%% UpdateTimeToLive
%%%------------------------------------------------------------------------------
-type update_time_to_live_opt() ::  {attribute_name, attr_name()} | 
                                    {enabled, boolean()}.
-type update_time_to_live_opts() :: [update_time_to_live_opt()].

-spec dynamize_attribute_name(binary()) -> jsx:json_term().
dynamize_attribute_name(Name) when is_binary(Name) -> 
    Name.

-spec dynamize_enable(boolean()) -> jsx:json_term().
dynamize_enable(Value) when is_boolean(Value) ->
    Value.

-spec update_time_to_live_opts() -> opt_table().
update_time_to_live_opts() ->
    [{attribute_name, <<"AttributeName">>, fun dynamize_attribute_name/1},
     {enabled, <<"Enabled">>, fun dynamize_enable/1}].

-spec time_to_live_specification_record() -> record_desc().
time_to_live_specification_record() ->
    {#ddb2_time_to_live_specification{},
     [{<<"AttributeName">>, #ddb2_time_to_live_specification.attribute_name, fun id/2},
      {<<"Enabled">>, #ddb2_time_to_live_specification.enabled, fun id/2}
    ]}.

-spec update_time_to_live_record() -> record_desc().
update_time_to_live_record() ->
    {#ddb2_update_time_to_live{},
     [{<<"TimeToLiveSpecification">>, #ddb2_update_time_to_live.time_to_live_specification,
       fun(V, Opts) -> undynamize_record(time_to_live_specification_record(), V, Opts) end}
     ]}.

-type update_time_to_live_return() :: ddb_return(#ddb2_update_time_to_live{}, #ddb2_time_to_live_specification{}).

-spec update_time_to_live(table_name(), update_time_to_live_opts()) -> update_time_to_live_return().
update_time_to_live(Table, Opts) ->
    update_time_to_live(Table, Opts, default_config()).

-spec update_time_to_live(table_name(), attr_name(), boolean(), aws_config()) -> update_time_to_live_return().
update_time_to_live(Table, AttributeName, Enabled, Config) ->
    update_time_to_live(Table, [{attribute_name, AttributeName}, {enabled, Enabled}], Config).

%%------------------------------------------------------------------------------
%% @doc 
%% DynamoDB API:
%% [http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_UpdateTimeToLive.html]
%%
%% ===Example===
%%
%% Enable TTL for table "SessionData" by setting attribute "ExpirationTime" as expiration date.
%% ```
%% erlcloud_ddb2:update_time_to_live(
%%   <<"SessionData">>,
%%   [{attribute_name, <<"ExpirationTime">>},
%%    {enabled, true}])
%% '''
%% @end
%%------------------------------------------------------------------------------
-spec update_time_to_live(table_name(), update_time_to_live_opts(), aws_config()) -> update_time_to_live_return();
                         (table_name(), attr_name(), boolean()) -> update_time_to_live_return().
update_time_to_live(Table, Opts, Config) when is_list(Opts) ->
    {AwsOpts, DdbOpts} = opts(update_time_to_live_opts(), Opts),
    Body = [{<<"TableName">>, Table}, {<<"TimeToLiveSpecification">>, AwsOpts}],
    Return = erlcloud_ddb_impl:request(
               Config,
               "DynamoDB_20120810.UpdateTimeToLive",
               Body,
               DdbOpts),
    out(Return, fun(Json, UOpts) -> undynamize_record(update_time_to_live_record(), Json, UOpts) end, 
        DdbOpts, #ddb2_update_time_to_live.time_to_live_specification);

update_time_to_live(Table, AttributeName, Enabled) ->
    update_time_to_live(Table, [{attribute_name, AttributeName}, {enabled, Enabled}]).

to_binary(X) when is_binary(X) ->
    X;
to_binary(X) when is_list(X) ->
    list_to_binary(X);
to_binary(X) when is_integer(X) ->
    integer_to_binary(X).
