%% -*- mode: erlang;erlang-indent-level: 4;indent-tabs-mode: nil -*-
-module(erlcloud_sts).

-include("erlcloud.hrl").
-include("erlcloud_aws.hrl").

-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").
-endif.

-export([assume_role/4, assume_role/5,
         assume_role/2,
         get_caller_identity/1,
         get_federation_token/3,
         get_federation_token/4]).

-define(API_VERSION, "2011-06-15").
-define(UTC_TO_GREGORIAN, 62167219200).
-define(EXTERNAL_ID_MAX_LEN, 1224).

% See http://docs.aws.amazon.com/STS/latest/APIReference/API_AssumeRole.html
% Options version of the API allowing MFA and etc access
%% {"RoleArn", RoleArn},
%% {"RoleSessionName", RoleSessionName},
%% {"DurationSeconds", DurationSeconds},
%% {"ExternalId", ExternalId},
%% {"TokenCode", Code},
%% {"SerialNumber", MFASerial}

assume_role(AwsConfig, Options) ->
    Xml = sts_query(AwsConfig, "AssumeRole", Options),
    process_assume_response(AwsConfig, Xml).

assume_role(AwsConfig, RoleArn, RoleSessionName, DurationSeconds) ->
    assume_role(AwsConfig, RoleArn, RoleSessionName, DurationSeconds, undefined).


% See http://docs.aws.amazon.com/STS/latest/APIReference/API_AssumeRole.html
-spec assume_role(#aws_config{}, string(), string(), 900..43200, undefined | string()) -> {#aws_config{}, proplist()}.
assume_role(AwsConfig, RoleArn, RoleSessionName, DurationSeconds, ExternalId)
    when length(RoleArn) >= 20,
         length(RoleSessionName) >= 2, length(RoleSessionName) =< 64,
         DurationSeconds >= 900, DurationSeconds =< 43200 ->

    Params =
        [
            {"RoleArn", RoleArn},
            {"RoleSessionName", RoleSessionName},
            {"DurationSeconds", DurationSeconds}
        ],
    ExternalIdPart =
        case ExternalId of
            undefined -> [];
            _ when length(ExternalId) >= 2, length(ExternalId) =< ?EXTERNAL_ID_MAX_LEN -> [{"ExternalId", ExternalId}]
        end,

    Xml = sts_query(AwsConfig, "AssumeRole", Params ++ ExternalIdPart),
    process_assume_response(AwsConfig, Xml).

process_assume_response(AwsConfig, Xml) ->
    Creds = erlcloud_xml:decode(
        [
            {access_key_id    , "AssumeRoleResult/Credentials/AccessKeyId"    , text},
            {secret_access_key, "AssumeRoleResult/Credentials/SecretAccessKey", text},
            {session_token    , "AssumeRoleResult/Credentials/SessionToken"   , text},
            {expiration       , "AssumeRoleResult/Credentials/Expiration"     , time}
        ],
        Xml),
    ExpireTS = expiration_tosecs( proplists:get_value(expiration, Creds) ),
    AssumedConfig =
        AwsConfig#aws_config {
            access_key_id     = proplists:get_value(access_key_id, Creds),
            secret_access_key = proplists:get_value(secret_access_key, Creds),
            security_token    = proplists:get_value(session_token, Creds),
            expiration        = ExpireTS
        },
    {AssumedConfig, Creds}.

%% @doc Retrieve identity information
%%
%% @see http://docs.aws.amazon.com/STS/latest/APIReference/API_GetCallerIdentity.html
-type caller_identity_prop() :: {account, string()}
                              | {arn, string()}
                              | {userId, string()}.
-spec get_caller_identity(#aws_config{}) -> {ok, [caller_identity_prop()]}.
get_caller_identity(AwsConfig) ->
    Xml = sts_query(AwsConfig, "GetCallerIdentity", []),
    Proplists = erlcloud_xml:decode(
        [
         {account, "GetCallerIdentityResult/Account", text},
         {arn, "GetCallerIdentityResult/Arn", text},
         {userId, "GetCallerIdentityResult/UserId", text}
        ], Xml),
    {ok, Proplists}.


get_federation_token(AwsConfig, DurationSeconds, Name) ->
        get_federation_token(AwsConfig, DurationSeconds, Name, undefined).

% See http://docs.aws.amazon.com/STS/latest/APIReference/API_GetFederationToken.html
-spec get_federation_token(#aws_config{}, 900..129600, string(), undefined | string()) -> {#aws_config{}, proplist()}.
get_federation_token(AwsConfig, DurationSeconds, Name, Policy)
  when length(Name) >= 2, length(Name) =< 32,
       DurationSeconds >= 900, DurationSeconds =< 129600 ->

    Params =
        [
         {"DurationSeconds", DurationSeconds},
         {"Name", Name}
        ],

    PolicyList =
        case Policy of
            undefined -> [];
            _ -> [{"Policy", Policy}]
        end,
    Xml = sts_query(AwsConfig, "GetFederationToken", Params ++ PolicyList),

    Creds = erlcloud_xml:decode(
              [
               {access_key_id       , "GetFederationTokenResult/Credentials/AccessKeyId", text},
               {secret_access_key   , "GetFederationTokenResult/Credentials/SecretAccessKey", text},
               {session_token       , "GetFederationTokenResult/Credentials/SessionToken"   , text},
               {expiration          , "GetFederationTokenResult/Credentials/Expiration", time},
               {federated_user_arn  , "GetFederationTokenResult/FederatedUser/Arn", text},
               {federated_user_id   , "GetFederationTokenResult/FederatedUser/FederatedUserId", text}
              ],
              Xml),
    ExpireTS = expiration_tosecs( proplists:get_value(expiration, Creds) ),
    FederatedConfig =
        AwsConfig#aws_config {
          access_key_id     = proplists:get_value(access_key_id, Creds),
          secret_access_key = proplists:get_value(secret_access_key, Creds),
          security_token    = proplists:get_value(session_token, Creds),
          expiration        = ExpireTS
         },

    {FederatedConfig, Creds}.

sts_query(AwsConfig, Action, Params) ->
    sts_query(AwsConfig, Action, Params, ?API_VERSION).


sts_query(AwsConfig, Action, Params, ApiVersion) ->
    case erlcloud_aws:aws_request_xml4(post,
        AwsConfig#aws_config.sts_host,
        "/",
        [{"Action", Action}, {"Version", ApiVersion} | Params],
        "sts", AwsConfig)
    of
        {ok, Body} ->
            Body;
        {error, Reason} ->
            erlang:error({aws_error, Reason})
    end.

expiration_tosecs( Datetime ) when is_tuple(Datetime) ->
    GregorianSeconds = calendar:datetime_to_gregorian_seconds( Datetime ),
    (GregorianSeconds - ?UTC_TO_GREGORIAN);
expiration_tosecs( Timestamp ) ->
    {ok, [Year,Month,Day,Hour,Min,Sec,_Ms],[]} =
        io_lib:fread( "~4d-~2d-~2dT~2d:~2d:~2d.~3dZ", Timestamp ),
    expiration_tosecs( {{Year,Month,Day},{Hour,Min,Sec}} ).


-ifdef(TEST).

expiration_tosecs_test() ->
    Timestamp = "2011-07-15T23:28:33.359Z",
    ?assertEqual( 1310772513, expiration_tosecs( Timestamp ) ).


-endif.
