%% Amazon Simple Storage Service (S3)

-module(erlcloud_s3).

-export([new/2, new/3, new/4,
         configure/2, configure/3, configure/4, configure/5,
         create_bucket/1, create_bucket/2, create_bucket/3, create_bucket/4,
         check_bucket_access/1, check_bucket_access/2,
         delete_bucket/1, delete_bucket/2,
         get_bucket_attribute/2, get_bucket_attribute/3,
         list_buckets/0, list_buckets/1,
         set_bucket_attribute/3, set_bucket_attribute/4,
         get_bucket_policy/1, get_bucket_policy/2,
         put_bucket_policy/2, put_bucket_policy/3,
         get_bucket_lifecycle/1, get_bucket_lifecycle/2,
         put_bucket_lifecycle/2, put_bucket_lifecycle/3,
         delete_bucket_lifecycle/1, delete_bucket_lifecycle/2,
         list_objects/1, list_objects/2, list_objects/3,
         list_object_versions/1, list_object_versions/2, list_object_versions/3,
         copy_object/4, copy_object/5, copy_object/6,
         delete_objects_batch/2, delete_objects_batch/3,
         explore_dirstructure/3, explore_dirstructure/4,
         delete_object/2, delete_object/3,
         delete_object_version/3, delete_object_version/4,
         head_object/2, head_object/3, head_object/4,
         get_object/2, get_object/3, get_object/4,
         get_object_acl/2, get_object_acl/3, get_object_acl/4,
         get_object_torrent/2, get_object_torrent/3,
         get_object_metadata/2, get_object_metadata/3, get_object_metadata/4,
         put_object/3, put_object/4, put_object/5, put_object/6,
         set_object_acl/3, set_object_acl/4,
         make_link/3, make_link/4,
         make_get_url/3, make_get_url/4,
         make_presigned_v4_url/5,
         make_presigned_v4_url/6,
         start_multipart/2, start_multipart/5,
         upload_part/5, upload_part/7,
         complete_multipart/4, complete_multipart/6,
         abort_multipart/3, abort_multipart/6,
         list_multipart_uploads/1, list_multipart_uploads/2, list_multipart_uploads/4,
         get_object_url/2, get_object_url/3,
         get_bucket_and_key/1,
         list_bucket_inventory/1, list_bucket_inventory/2, list_bucket_inventory/3,
         get_bucket_inventory/2, get_bucket_inventory/3,
         put_bucket_inventory/2, put_bucket_inventory/3,
         delete_bucket_inventory/2, delete_bucket_inventory/3,
         put_bucket_encryption/2, put_bucket_encryption/3, put_bucket_encryption/4,
         get_bucket_encryption/1, get_bucket_encryption/2,
         delete_bucket_encryption/1, delete_bucket_encryption/2,
         put_object_tagging/3, put_object_tagging/4,
         delete_object_tagging/2, delete_object_tagging/3,
         get_object_tagging/2, get_object_tagging/3,
         put_bucket_tagging/2, put_bucket_tagging/3,
         delete_bucket_tagging/1, delete_bucket_tagging/2,
         get_bucket_tagging/1, get_bucket_tagging/2,
         get_public_access_block/1, get_public_access_block/2,
         put_public_access_block/2, put_public_access_block/3
    ]).

-ifdef(TEST).
-export([encode_lifecycle/1]).
-export([get_bucket_notification/1]).
-export([create_notification_xml/1]).
-export([create_notification_param_xml/2]).
-export([encode_inventory/1]).
-endif.

-include("erlcloud.hrl").
-include("erlcloud_aws.hrl").
-include_lib("xmerl/include/xmerl.hrl").

%%% Note that get_bucket_and_key/1 may be used to obtain the Bucket and Key to pass to various
%%%   functions here, from a URL such as https://s3.amazonaws.com/some_bucket/path_to_file

-spec new(string(), string()) -> aws_config().

new(AccessKeyID, SecretAccessKey) ->
    #aws_config{
       access_key_id=AccessKeyID,
       secret_access_key=SecretAccessKey
      }.

-spec new(string(), string(), string()) -> aws_config().

new(AccessKeyID, SecretAccessKey, Host) ->
    #aws_config{
       access_key_id=AccessKeyID,
       secret_access_key=SecretAccessKey,
       s3_host=Host
      }.


-spec new(string(), string(), string(), non_neg_integer()) -> aws_config().

new(AccessKeyID, SecretAccessKey, Host, Port) ->
    #aws_config{
       access_key_id=AccessKeyID,
       secret_access_key=SecretAccessKey,
       s3_host=Host,
       s3_port=Port
      }.

-spec new(string(), string(), string(), non_neg_integer(), string()) -> aws_config().

new(AccessKeyID, SecretAccessKey, Host, Port, Scheme) ->
    #aws_config{
       access_key_id=AccessKeyID,
       secret_access_key=SecretAccessKey,
       s3_host=Host,
       s3_port=Port,
       s3_scheme=Scheme
      }.

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

-type s3_bucket_attribute_name() :: acl
                                  | location
                                  | logging
                                  | mfa_delete
                                  | request_payment
                                  | versioning
                                  | notification.

-type s3_bucket_acl() :: private
                       | public_read
                       | public_read_write
                       | authenticated_read
                       | bucket_owner_read
                       | bucket_owner_full_control.

-type s3_location_constraint() :: none
                                | us_west_1
                                | eu
                                | 'us-east-1'
                                | 'us-east-2'
                                | 'us-west-1'
                                | 'us-west-2'
                                | 'ca-central-1'
                                | 'eu-west-1'
                                | 'eu-west-2'
                                | 'eu-west-3'
                                | 'eu-north-1'
                                | 'eu-central-1'
                                | 'ap-south-1'
                                | 'ap-southeast-1'
                                | 'ap-southeast-2'
                                | 'ap-northeast-1'
                                | 'ap-northeast-2'
                                | 'ap-northeast-3'
                                | 'ap-east-1'
                                | 'me-south-1'
                                | 'sa-east-1'.

-type public_access_block_attrib() :: block_public_policy
                                    | ignore_public_acls
                                    | block_public_policy
                                    | restrict_public_buckets.

-type public_access_block_param() :: {public_access_block_attrib(), boolean()}.

-type public_access_block_configuration() :: [public_access_block_param()].

-define(XMLNS_S3, "http://s3.amazonaws.com/doc/2006-03-01/").
-define(XMLNS_SCHEMA_INSTANCE, "http://www.w3.org/2001/XMLSchema-instance").

-spec copy_object(string(), string(), string(), string()) -> proplist().

copy_object(DestBucketName, DestKeyName, SrcBucketName, SrcKeyName) ->
    copy_object(DestBucketName, DestKeyName, SrcBucketName, SrcKeyName, []).

-spec copy_object(string(), string(), string(), string(), proplist() | aws_config()) -> proplist().

copy_object(DestBucketName, DestKeyName, SrcBucketName, SrcKeyName, Config)
  when is_record(Config, aws_config) ->
    copy_object(DestBucketName, DestKeyName, SrcBucketName, SrcKeyName, [], Config);

copy_object(DestBucketName, DestKeyName, SrcBucketName, SrcKeyName, Options) ->
    copy_object(DestBucketName, DestKeyName, SrcBucketName, SrcKeyName,
                Options, default_config()).

-spec copy_object(string(), string(), string(), string(), proplist(), aws_config()) -> proplist().
copy_object(DestBucketName, DestKeyName, SrcBucketName, SrcKeyName, Options, Config) ->
    SrcVersion = case proplists:get_value(version_id, Options) of
                     undefined -> "";
                     VersionID -> ["?versionId=", VersionID]
                 end,
    RequestHeaders =
        [{"x-amz-copy-source", [SrcBucketName, $/, SrcKeyName, SrcVersion]},
         {"x-amz-metadata-directive", proplists:get_value(metadata_directive, Options)},
         {"x-amz-copy-source-if-match", proplists:get_value(if_match, Options)},
         {"x-amz-copy-source-if-none-match", proplists:get_value(if_none_match, Options)},
         {"x-amz-copy-source-if-unmodified-since", proplists:get_value(if_unmodified_since, Options)},
         {"x-amz-copy-source-if-modified-since", proplists:get_value(if_modified_since, Options)},
         {"x-amz-acl", encode_acl(proplists:get_value(acl, Options))}],
    {Headers, _Body} = s3_request(Config, put, DestBucketName, [$/|DestKeyName],
                                  "", [], <<>>, RequestHeaders),
    [{copy_source_version_id, proplists:get_value("x-amz-copy-source-version-id", Headers, "false")},
     {version_id, proplists:get_value("x-amz-version-id", Headers, "null")}].

-spec create_bucket(string()) -> ok.

create_bucket(BucketName) ->
    create_bucket(BucketName, private).

-spec create_bucket(string(), s3_bucket_acl() | aws_config()) -> ok.

create_bucket(BucketName, Config)
  when is_record(Config, aws_config) ->
    create_bucket(BucketName, private, Config);

create_bucket(BucketName, ACL) ->
    create_bucket(BucketName, ACL, none).

-spec create_bucket(string(), s3_bucket_acl(), s3_location_constraint() | aws_config()) -> ok.

create_bucket(BucketName, ACL, Config)
  when is_record(Config, aws_config) ->
    create_bucket(BucketName, ACL, none, Config);

create_bucket(BucketName, ACL, LocationConstraint) ->
    create_bucket(BucketName, ACL, LocationConstraint, default_config()).

-spec create_bucket(string(), s3_bucket_acl(), s3_location_constraint(), aws_config()) -> ok.

create_bucket(BucketName, ACL, LocationConstraint, Config)
  when is_list(BucketName), is_atom(ACL), is_atom(LocationConstraint) ->
    Headers = case ACL of
                  private -> [];  %% private is the default
                  _       -> [{"x-amz-acl", encode_acl(ACL)}]
              end,
    POSTData = case encode_location_constraint(LocationConstraint) of
                   undefined -> <<>>;
                   LocationName ->
                       XML = {'CreateBucketConfiguration', [{xmlns, ?XMLNS_S3}],
                              [{'LocationConstraint', [LocationName]}]},
                       list_to_binary(xmerl:export_simple([XML], xmerl_xml))
               end,
    s3_simple_request(Config, put, BucketName, "/", "", [], POSTData, Headers).

encode_location_constraint(eu) -> "EU";
encode_location_constraint(us_west_1) -> "us-west-1";
encode_location_constraint('us-east-1') -> undefined;
encode_location_constraint('us-east-2') -> "us-east-2";
encode_location_constraint('us-west-1') -> "us-west-1";
encode_location_constraint('us-west-2') -> "us-west-2";
encode_location_constraint('ca-central-1') -> "ca-central-1";
encode_location_constraint('eu-west-1') -> "eu-west-1";
encode_location_constraint('eu-west-2') -> "eu-west-2";
encode_location_constraint('eu-west-3') -> "eu-west-3";
encode_location_constraint('eu-north-1') -> "eu-north-1";
encode_location_constraint('eu-central-1') -> "eu-central-1";
encode_location_constraint('ap-south-1') -> "ap-south-1";
encode_location_constraint('ap-southeast-1') -> "ap-southeast-1";
encode_location_constraint('ap-southeast-2') -> "ap-southeast-2";
encode_location_constraint('ap-northeast-1') -> "ap-northeast-1";
encode_location_constraint('ap-northeast-2') -> "ap-northeast-2";
encode_location_constraint('ap-northeast-3') -> "ap-northeast-3";
encode_location_constraint('ap-east-1') -> "ap-east-1";
encode_location_constraint('me-south-1') -> "me-south-1";
encode_location_constraint('sa-east-1') -> "sa-east-1";
encode_location_constraint(_) -> undefined.

encode_acl(undefined)                 -> undefined;
encode_acl(private)                   -> "private";
encode_acl(public_read)               -> "public-read";
encode_acl(public_read_write)         -> "public-read-write";
encode_acl(authenticated_read)        -> "authenticated-read";
encode_acl(bucket_owner_read)         -> "bucket-owner-read";
encode_acl(bucket_owner_full_control) -> "bucket-owner-full-control".

-spec delete_bucket(string()) -> ok.

delete_bucket(BucketName) ->
    delete_bucket(BucketName, default_config()).

-spec delete_bucket(string(), aws_config()) -> ok.

delete_bucket(BucketName, Config)
  when is_list(BucketName) ->
    s3_simple_request(Config, delete, BucketName, "/", "", [], <<>>, []).

-spec check_bucket_access(string()) -> ok | {error, any()}.

check_bucket_access(BucketName)
  when is_list(BucketName) ->
    check_bucket_access(BucketName, default_config()).

-spec check_bucket_access(string(), aws_config()) -> ok | {error, any()}.

check_bucket_access(BucketName, Config)
  when is_list(BucketName), is_record(Config, aws_config) ->
    case s3_request2(Config, head, BucketName, "/", "", [], <<>>, []) of
        {ok, {_Headers, _Body}} ->
            ok;
        Error ->
            Error
    end.


-spec delete_objects_batch(string(), list()) -> proplist().
delete_objects_batch(BucketName, KeyList) ->
    delete_objects_batch(BucketName, KeyList, default_config()).

-spec delete_objects_batch(string(), list(), aws_config()) -> proplist().
delete_objects_batch(BucketName, KeyList, Config)
    when is_list(BucketName), is_list(KeyList) ->
    Data = lists:map(fun(Item) ->
      lists:concat(["<Object><Key>", Item, "</Key></Object>"]) end,
      KeyList),
    Payload = unicode:characters_to_list(
      "<?xml version=\"1.0\" encoding=\"UTF-8\"?><Delete>" ++ Data ++ "</Delete>",
      utf8),
    Headers = [{"content-md5", base64:encode(erlcloud_util:md5(Payload))},
      {"content-length", integer_to_list(string:len(Payload))},
      {"content-type", "application/xml"}],
    Doc =  s3_xml_request(Config, post, BucketName, [$/], "delete", [], Payload, Headers),
    Attributes = [{deleted, "Deleted", fun extract_delete_objects_batch_key_contents/1},
      {error, "Error", fun extract_delete_objects_batch_err_contents/1}],
    erlcloud_xml:decode(Attributes, Doc).


extract_delete_objects_batch_key_contents(Nodes) ->
    Attributes = [{key, "Key", text}],
    [Key || X <- [erlcloud_xml:decode(Attributes, Node) || Node <- Nodes], {_,Key} <- X].

extract_delete_objects_batch_err_contents(Nodes) ->
    Attributes = [
      {key, "Key", text},
      {code, "Code", text},
      {message, "Message", text}],
    [to_flat_format(erlcloud_xml:decode(Attributes, Node)) || Node <- Nodes].

to_flat_format([{key,Key},{code,Code},{message,Message}]) ->
    {Key,Code,Message}.

%% returns paths list from AWS S3 root directory, used as input to
%% delete_objects_batch
%% example :
%%    25> rp(erlcloud_s3:explore_dirstructure("xmppfiledev",
%%                                            ["sailfish/deleteme"], [])).
%%    ["sailfish/deleteme/deep/deep1/deep4/ZZZ_1.txt",
%%     "sailfish/deleteme/deep/deep1/deep4/ZZZ_0.txt",
%%     "sailfish/deleteme/deep/deep1/ZZZ_0.txt",
%%     "sailfish/deleteme/deep/ZZZ_0.txt"]
%%    ok
%%
-spec explore_dirstructure(string(), list(), list()) -> list().
explore_dirstructure(Bucketname, Branches, Accum) ->
    explore_dirstructure(Bucketname, Branches, Accum, default_config()).

-spec explore_dirstructure(string(), list(), list(), aws_config()) ->
                                  list().
explore_dirstructure(Bucketname, [Branch|Tail], Accum, Config) ->
    explore_dirstructure(Bucketname, [Branch|Tail], Accum, Config, []).


explore_dirstructure(_, [], Result, _Config, _Marker) ->
    lists:append(Result);
explore_dirstructure(Bucketname, [Branch|Tail], Accum, Config, Marker)
    when is_record(Config, aws_config) ->
    ProcessContent = fun(Data)->
            Content = proplists:get_value(contents, Data),
            lists:foldl(fun(I,Acc)-> R = proplists:get_value(key, I),
                                     [R|Acc] end, [], Content)
            end,

    Data = list_objects(Bucketname, [{prefix, Branch},
                                     {delimiter, "/"},
                                     {marker, Marker}], Config),
    Files = ProcessContent(Data),
    Sub = proplists:get_value(common_prefixes, Data),
    SubDirs = lists:foldl(fun(I,Acc)-> R = proplists:get_value(prefix, I),
                                       [R|Acc] end, [], Sub),
    SubFiles = explore_dirstructure(Bucketname, SubDirs, [], Config, []),
    TruncFiles =
        case proplists:get_value(is_truncated, Data) of
            false ->
                [];
            true ->
                NextMarker = proplists:get_value(next_marker, Data),
                explore_dirstructure(Bucketname, [Branch], [], Config,
                                     NextMarker)
        end,
    explore_dirstructure(Bucketname, Tail,
                         [SubFiles, TruncFiles, Files|Accum], Config, []).

-spec delete_object(string(), string()) -> proplist().

delete_object(BucketName, Key) ->
    delete_object(BucketName, Key, default_config()).

-spec delete_object(string(), string(), aws_config()) -> proplist().

delete_object(BucketName, Key, Config)
  when is_list(BucketName), is_list(Key) ->
    {Headers, _Body} = s3_request(Config, delete, BucketName, [$/|Key], "", [], <<>>, []),
    Marker = proplists:get_value("x-amz-delete-marker", Headers, "false"),
    Id = proplists:get_value("x-amz-version-id", Headers, "null"),
    [{delete_marker, list_to_existing_atom(Marker)},
     {version_id, Id}].

-spec delete_object_version(string(), string(), string()) -> proplist().

delete_object_version(BucketName, Key, Version) ->
    delete_object_version(BucketName, Key, Version, default_config()).

-spec delete_object_version(string(), string(), string(), aws_config()) -> proplist().

delete_object_version(BucketName, Key, Version, Config)
  when is_list(BucketName),
       is_list(Key),
       is_list(Version)->
    {Headers, _Body} = s3_request(Config, delete, BucketName, [$/|Key],
                                  ["versionId=", Version], [], <<>>, []),
    Marker = proplists:get_value("x-amz-delete-marker", Headers, "false"),
    Id = proplists:get_value("x-amz-version-id", Headers, "null"),
    [{delete_marker, list_to_existing_atom(Marker)},
     {version_id, Id}].

-spec list_buckets() -> proplist().

list_buckets() ->
    list_buckets(default_config()).

-spec list_buckets(aws_config()) -> proplist().

list_buckets(Config) ->
    Doc = s3_xml_request(Config, get, "", "/", "", [], <<>>, []),
    Owner = extract_user(xmerl_xpath:string("/*/Owner", Doc)),
    Buckets = [extract_bucket(Node) || Node <- xmerl_xpath:string("/*/Buckets/Bucket", Doc)],
    [{owner, Owner}, {buckets, Buckets}].

%
% @doc Get S3 bucket policy JSON object
% API Document: http://docs.aws.amazon.com/AmazonS3/latest/API/RESTBucketGETacl.html
%
-spec get_bucket_policy(BucketName::string()) -> ok | {error, Reason::term()}.
get_bucket_policy(BucketName) ->
    get_bucket_policy(BucketName, default_config()).

%
% Example request: erlcloud_s3:get_bucket_policy("bucket1234", Config).
% Example success response: {ok, "{\"Version\":\"2012-10-17\",\"Statement\": ..........}
% Example error response: {error,{http_error,404,"Not Found",
%                               "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n
%                               <Error>
%                                   <Code>NoSuchBucket</Code>
%                                   <Message>The specified bucket does not exist</Message>
%                                   <BucketName>bucket1234</BucketName>
%                                   <RequestId>DC1EA9456B266EF5</RequestId>
%                                   <HostId>DRtkAB80cAeom+4ffSGU3PFCxS7QvtiW+wxLnPF0dM2nxoaRqQk1SK/z62ZJVHAD</HostId>
%                               </Error>"}}
-spec get_bucket_policy(BucketName::string(), Config::aws_config()) -> {ok, Policy::string()} | {error, Reason::term()}.
get_bucket_policy(BucketName, Config)
    when is_record(Config, aws_config) ->
        case s3_request2(Config, get, BucketName, "/", "policy", [], <<>>, []) of
            {ok, {_Headers, Body}} ->
                {ok, binary_to_list(Body)};
            Error ->
                Error
        end.

-spec put_bucket_policy(string(), binary()) -> ok.
put_bucket_policy(BucketName, Policy) ->
    put_bucket_policy(BucketName, Policy, default_config()).

-spec put_bucket_policy(string(), binary(), aws_config()) -> ok.
put_bucket_policy(BucketName, Policy, Config)
  when is_list(BucketName), is_binary(Policy), is_record(Config, aws_config) ->
    s3_simple_request(Config, put, BucketName, "/", "policy", [], Policy, []).

-spec get_bucket_lifecycle(BucketName::string()) -> {ok, list(proplist())} | {error, Reason::term()}.
get_bucket_lifecycle(BucketName) ->
    get_bucket_lifecycle(BucketName, default_config()).

-spec get_bucket_lifecycle(BucketName::string(), Config::aws_config()) -> {ok, list(proplist())} | {error, Reason::term()}.
get_bucket_lifecycle(BucketName, Config)
    when is_record(Config, aws_config) ->
        case s3_request2(Config, get, BucketName, "/", "lifecycle", [], <<>>, []) of
            {ok, {_Headers, Body}} ->
                {ok, parse_lifecycle(element(1, xmerl_scan:string(binary_to_list(Body))))};
            Error ->
                Error
        end.

-spec put_bucket_lifecycle(string(), list() | binary()) -> ok | {error, Reason::term()}.
put_bucket_lifecycle(BucketName, Policy) ->
    put_bucket_lifecycle(BucketName, Policy, default_config()).

-spec put_bucket_lifecycle(string(), list() | binary(), aws_config()) -> ok | {error, Reason::term()}.
put_bucket_lifecycle(BucketName, Policy, Config)
  when is_list(BucketName), is_list(Policy), is_record(Config, aws_config) ->
    XmlPolicy = encode_lifecycle(Policy),
    put_bucket_lifecycle(BucketName, list_to_binary(XmlPolicy), Config);
put_bucket_lifecycle(BucketName, XmlPolicy, Config)
  when is_list(BucketName), is_binary(XmlPolicy), is_record(Config, aws_config) ->
    Md5 = base64:encode(crypto:hash(md5, XmlPolicy)),
    s3_simple_request(Config, put, BucketName, "/", "lifecycle",
                      [], XmlPolicy, [{"Content-MD5", Md5}]).

-spec delete_bucket_lifecycle(string()) -> ok | {error, Reason::term()}.
delete_bucket_lifecycle(BucketName) ->
delete_bucket_lifecycle(BucketName, default_config()).

-spec delete_bucket_lifecycle(string(), #aws_config{})
    -> ok | {error, Reason::term()}.
delete_bucket_lifecycle(BucketName, AwsConfig) ->
    s3_simple_request(AwsConfig, delete, BucketName,
                      "/", "lifecycle", [], <<>>, []).

-spec list_objects(string()) -> proplist().

list_objects(BucketName) ->
    list_objects(BucketName, []).
-spec list_objects(string(), proplist() | aws_config()) -> proplist().

list_objects(BucketName, Config)
  when is_record(Config, aws_config) ->
    list_objects(BucketName, [], Config);

list_objects(BucketName, Options) ->
    list_objects(BucketName, Options, default_config()).

-spec list_objects(string(), proplist(), aws_config()) -> proplist().

list_objects(BucketName, Options, Config)
  when is_list(BucketName),
       is_list(Options) ->
    Params = [{"delimiter", proplists:get_value(delimiter, Options)},
              {"marker", proplists:get_value(marker, Options)},
              {"max-keys", proplists:get_value(max_keys, Options)},
              {"encoding-type", proplists:get_value(encoding_type, Options)},
              {"prefix", proplists:get_value(prefix, Options)}],
    Doc = s3_xml_request(Config, get, BucketName, "/", "", Params, <<>>, []),
    Attributes = [{name, "Name", text},
                  {prefix, "Prefix", text},
                  {marker, "Marker", text},
                  {next_marker, "NextMarker", text},
                  {delimiter, "Delimiter", text},
                  {max_keys, "MaxKeys", integer},
                  {is_truncated, "IsTruncated", boolean},
                  {common_prefixes, "CommonPrefixes", fun extract_prefixes/1},
                  {contents, "Contents", fun extract_contents/1}],
    erlcloud_xml:decode(Attributes, Doc).

extract_prefixes(Nodes) ->
    Attributes = [{prefix, "Prefix", text}],
    [erlcloud_xml:decode(Attributes, Node) || Node <- Nodes].

extract_contents(Nodes) ->
    Attributes = [{key, "Key", text},
                  {last_modified, "LastModified", time},
                  {etag, "ETag", text},
                  {size, "Size", integer},
                  {storage_class, "StorageClass", text},
                  {owner, "Owner", fun extract_user/1}],
    [erlcloud_xml:decode(Attributes, Node) || Node <- Nodes].

extract_user([]) ->
    [];
extract_user([Node]) ->
    Attributes = [{id, "ID", optional_text},
                  {display_name, "DisplayName", optional_text},
                  {uri, "URI", optional_text}
                 ],
    erlcloud_xml:decode(Attributes, Node).

-spec get_bucket_attribute(string(), s3_bucket_attribute_name()) -> term().

get_bucket_attribute(BucketName, AttributeName) ->
    get_bucket_attribute(BucketName, AttributeName, default_config()).

-spec get_bucket_attribute(string(), s3_bucket_attribute_name(), aws_config()) -> term().

get_bucket_attribute(BucketName, AttributeName, Config)
  when is_list(BucketName), is_atom(AttributeName) ->
    Attr = case AttributeName of
               acl             -> "acl";
               location        -> "location";
               logging         -> "logging";
               mfa_delete      -> "versioning"; %% https://docs.aws.amazon.com/AmazonS3/latest/API/API_GetBucketVersioning.html#API_GetBucketVersioning_ResponseElements
               request_payment -> "requestPayment";
               versioning      -> "versioning";
               notification    -> "notification"
           end,
    Doc = s3_xml_request(Config, get, BucketName, "/", Attr, [], <<>>, []),
    case AttributeName of
        acl ->
            Attributes = [{owner, "Owner", fun extract_user/1},
                          {access_control_list, "AccessControlList/Grant", fun extract_acl/1}],
            erlcloud_xml:decode(Attributes, Doc);
        location ->
            case erlcloud_xml:get_text("/LocationConstraint", Doc) of
                %% logic according to http://s3tools.org/s3cmd
                %% s3cmd-1.5.2/S3/S3.py : line 342 (function get_bucket_location)
                "" -> "us-east-1";
                "US" -> "us-east-1";
                "EU" -> "eu-west-1";
                Loc -> Loc
            end;
        logging ->
            case xmerl_xpath:string("/BucketLoggingStatus/LoggingEnabled", Doc) of
                [] ->
                    {enabled, false};
                [LoggingEnabled] ->
                    Attributes = [{target_bucket, "TargetBucket", text},
                                  {target_prefix, "TargetPrefix", text},
                                  {target_trants, "TargetGrants/Grant", fun extract_acl/1}],
                    [{enabled, true}|erlcloud_xml:decode(Attributes, LoggingEnabled)]
            end;
        mfa_delete ->
            case erlcloud_xml:get_text("/VersioningConfiguration/MfaDelete", Doc) of
                "Enabled"   -> enabled;
                _           -> disabled
            end;
        request_payment ->
            case erlcloud_xml:get_text("/RequestPaymentConfiguration/Payer", Doc) of
                "Requester" -> requester;
                _           -> bucket_owner
            end;
        versioning ->
            case erlcloud_xml:get_text("/VersioningConfiguration/Status", Doc) of
                "Enabled"   -> enabled;
                "Suspended" -> suspended;
                _           -> disabled
            end;
        notification ->
            get_bucket_notification(Doc)
    end.

%% gets the notifications configuration of an S3 bucket.
%% for an example of the returned data, see tests.
-spec get_bucket_notification(#xmlElement{}) -> [proplist()].
get_bucket_notification(Doc) ->
    SNSNotifications =
        get_notifications_config(topic_configuration, topic,
                                 "Topic", "TopicConfiguration", Doc),
    SQSNotifications =
        get_notifications_config(queue_configuration, queue,
                                 "Queue", "QueueConfiguration", Doc),
    LambdaNotifications =
        get_notifications_config(cloud_function_configuration, cloud_function,
                                 "CloudFunction", "CloudFunctionConfiguration", Doc),
    SNSNotifications ++ SQSNotifications ++ LambdaNotifications.

get_notifications_config(ConfType, AttributeName, Attr, Path, Doc) ->
    case xmerl_xpath:string("/NotificationConfiguration/" ++ Path, Doc) of
        [] -> [];
        Configs when is_list(Configs) ->
            [decode_notification_config(ConfType, AttributeName, Attr, Path, Config)
                || Config <- Configs]
    end.

decode_notification_config(ConfType, AttributeName, Attr, Path, Config) ->
    Attributes = s3_notification_attrs(AttributeName, Attr),
    Configurations = [get_notification_filter(Path, Config) |
                      erlcloud_xml:decode(Attributes, Config)],
    [{ConfType, Configurations}].

get_notification_filter(Path, Config) ->
    get_notification_filter_do(xmerl_xpath:string("/" ++ Path ++ "/Filter/S3Key", Config)).

get_notification_filter_do([]) -> [];
get_notification_filter_do(S3Key) ->
    #xmlElement{content = Content} = hd(S3Key),
    GV = fun(Key, PL) -> proplists:get_value(Key, PL) end,
    Filter0 = [erlcloud_xml:decode([{name, "Name", text}, {value, "Value", text}], C) || C <- Content],
    Filter = [{list_to_atom(string:to_lower(GV(name, E))), GV(value, E)} || E <- Filter0],
    {filter, Filter}.

s3_notification_attrs(AttributeName, Attr) ->
    [ {AttributeName, Attr,    text} |
     [{id,            "Id",    optional_text},
      {event,         "Event", list}]].

parse_lifecycle(Xml) ->
    Rules = xmerl_xpath:string("/LifecycleConfiguration/Rule", Xml),
    [extract_rule(X) || X <- Rules].

extract_rule(Xml) ->
    erlcloud_xml:decode(
      [
       {expiration, "Expiration", {single, fun extract_expiration/1}},
       {id, "ID", text},
       {noncurrent_version_expiration, "NoncurrentVersionExpiration",
        {optional_map, fun extract_noncurrent_version_expiration/1}},
       {noncurrent_version_transition, "NoncurrentVersionTransition",
        {optional_map, fun extract_noncurrent_version_transition/1}},
       {prefix, "Prefix", text},
       {status, "Status", text},
       {transition, "Transition", {optional_map, fun extract_transition/1}}
      ], Xml).

encode_lifecycle(Lifecycle) ->
    lists:flatten(xmerl:export_simple(
                    [{'LifecycleConfiguration',
                      lists:map(fun(Rule) ->
                                        {'Rule', encode_rule(Rule)}
                                end, Lifecycle)}], xmerl_xml)).

encode_rule(Rule) ->
    lists:flatten(lists:map(
                    fun({Key, [{_, _} | _] = Proplist}) ->
                            {key_to_name(Key), encode_subtype(Proplist)};
                       ({Key, [[{_, _} | _], _] = ListOfProplist}) ->
                            lists:map(fun(List) ->
                                              {key_to_name(Key),
                                               encode_subtype(List)}
                                      end, ListOfProplist);
                       ({Key, [[{_, _}, _] = List]}) ->
                               {key_to_name(Key), encode_subtype(List)};
                       ({Key, Value}) ->
                               {key_to_name(Key), encode_subtype(Value)}
                       end, Rule)).

encode_subtype(List) ->
    case List of
        [{_, _} | _] ->
            lists:map(fun({Key, Value}) ->
                              {key_to_name(Key),
                               [erlcloud_util:to_string(Value)]}
                      end, List);
        Value ->
            [erlcloud_util:to_string(Value)]
    end.

extract_transition(Xml) ->
    erlcloud_xml:decode(
      [
       {date, "Date", optional_text},
       {days, "Days", optional_integer},
       {storage_class, "StorageClass", text}
       ], Xml).

extract_noncurrent_version_transition(Xml) ->
    erlcloud_xml:decode(
      [{noncurrent_days, "NoncurrentDays", integer},
       {storage_class, "StorageClass", text}], Xml).

extract_noncurrent_version_expiration(Xml) ->
    erlcloud_xml:decode([{noncurrent_days, "NoncurrentDays", integer}], Xml).

extract_expiration(Xml) ->
    erlcloud_xml:decode(
      [{date, "Date", optional_text},
       {days, "Days", optional_integer}], Xml).

key_to_name(expiration) -> 'Expiration';
key_to_name(id)         -> 'ID';
key_to_name(prefix) -> 'Prefix';
key_to_name(status) -> 'Status';
key_to_name(transition) -> 'Transition';
key_to_name(date) -> 'Date';
key_to_name(days) -> 'Days';
key_to_name('noncurrent_version_expiration') -> 'NoncurrentVersionExpiration';
key_to_name('noncurrent_version_transition') -> 'NoncurrentVersionTransition';
key_to_name('storage_class') -> 'StorageClass';
key_to_name('noncurrent_days') -> 'NoncurrentDays'.

extract_acl(ACL) ->
    [extract_grant(Item) || Item <- ACL].

extract_grant(GrantNode) ->
    [GranteeNode] = xmerl_xpath:string("Grantee", GrantNode),
    [{grantee, extract_grantee(GranteeNode)},
     {permission, decode_permission(erlcloud_xml:get_text("Permission", GrantNode))}].

extract_grantee(Node) ->
    erlcloud_xml:decode([
        {type, {".", "xsi:type"}, text},
        {id, "ID", optional_text},
        {display_name, "DisplayName", optional_text},
        {uri, "URI", optional_text}
    ], Node).

encode_permission(full_control) -> "FULL_CONTROL";
encode_permission(write)        -> "WRITE";
encode_permission(write_acp)    -> "WRITE_ACP";
encode_permission(read)         -> "READ";
encode_permission(read_acp) -> "READ_ACP".

decode_permission("FULL_CONTROL") -> full_control;
decode_permission("WRITE")        -> write;
decode_permission("WRITE_ACP")    -> write_acp;
decode_permission("READ")         -> read;
decode_permission("READ_ACP")     -> read_acp.

-spec head_object(string(), string()) -> proplist().

head_object(BucketName, Key) ->
    head_object(BucketName, Key, []).

-spec head_object(string(), string(), proplist() | aws_config()) -> proplist().

head_object(BucketName, Key, Config)
  when is_record(Config, aws_config) ->
    head_object(BucketName, Key, [], Config);
head_object(BucketName, Key, Options) ->
    head_object(BucketName, Key, Options, default_config()).

-spec head_object(string(), string(), proplist(), aws_config()) -> proplist().

head_object(BucketName, Key, Options, Config) ->
    get_or_head(head, BucketName, Key, Options, Config).

-spec get_object(string(), string()) -> proplist().

get_object(BucketName, Key) ->
    get_object(BucketName, Key, []).

-spec get_object(string(), string(), proplist() | aws_config()) -> proplist().

get_object(BucketName, Key, Config)
  when is_record(Config, aws_config) ->
    get_object(BucketName, Key, [], Config);

get_object(BucketName, Key, Options) ->
    get_object(BucketName, Key, Options, default_config()).

-spec get_object(string(), string(), proplist(), aws_config()) -> proplist().

get_object(BucketName, Key, Options, Config) ->
    get_or_head(get, BucketName, Key, Options, Config).

get_or_head(Method, BucketName, Key, Options, Config) ->
    RequestHeaders = [{"Range", proplists:get_value(range, Options)},
                      {"If-Modified-Since", proplists:get_value(if_modified_since, Options)},
                      {"If-Unmodified-Since", proplists:get_value(if_unmodified_since, Options)},
                      {"If-Match", proplists:get_value(if_match, Options)},
                      {"If-None-Match", proplists:get_value(if_none_match, Options)},
                      {"x-amz-server-side-encryption-customer-algorithm", proplists:get_value(server_side_encryption_customer_algorithm, Options)},
                      {"x-amz-server-side-encryption-customer-key", proplists:get_value(server_side_encryption_customer_key, Options)},
                      {"x-amz-server-side-encryption-customer-key-md5", proplists:get_value(server_side_encryption_customer_key_md5, Options)}],
    Subresource = case proplists:get_value(version_id, Options) of
                      undefined -> "";
                      Version   -> ["versionId=", Version]
                  end,
    {Headers, Body} = s3_request(Config, Method, BucketName, [$/|Key], Subresource, [], <<>>, RequestHeaders),
    [{last_modified, proplists:get_value("last-modified", Headers)},
     {etag, proplists:get_value("etag", Headers)},
     {content_length, proplists:get_value("content-length", Headers)},
     {content_type, proplists:get_value("content-type", Headers)},
     {content_encoding, proplists:get_value("content-encoding", Headers)},
     {delete_marker, list_to_existing_atom(proplists:get_value("x-amz-delete-marker", Headers, "false"))},
     {version_id, proplists:get_value("x-amz-version-id", Headers, "null")},
     {tag_count, proplists:get_value("x-amz-tagging-count", Headers, "null")},
     {content, Body}|
     extract_metadata(Headers)].

-spec get_object_acl(string(), string()) -> proplist().

get_object_acl(BucketName, Key) ->
    get_object_acl(BucketName, Key, default_config()).

-spec get_object_acl(string(), string(), proplist() | aws_config()) -> proplist().

get_object_acl(BucketName, Key, Config)
  when is_record(Config, aws_config) ->
    get_object_acl(BucketName, Key, [], Config);

get_object_acl(BucketName, Key, Options) ->
    get_object_acl(BucketName, Key, Options, default_config()).

-spec get_object_acl(string(), string(), proplist(), aws_config()) -> proplist().

get_object_acl(BucketName, Key, Options, Config)
  when is_list(BucketName), is_list(Key), is_list(Options) ->
    Subresource = case proplists:get_value(version_id, Options) of
                      undefined -> "";
                      Version   -> ["&versionId=", Version]
                  end,
    Doc = s3_xml_request(Config, get, BucketName, [$/|Key], "acl" ++ Subresource, [], <<>>, []),
    Attributes = [{owner, "Owner", fun extract_user/1},
                  {access_control_list, "AccessControlList/Grant", fun extract_acl/1}],
    erlcloud_xml:decode(Attributes, Doc).

-spec get_object_metadata(string(), string()) -> proplist().

get_object_metadata(BucketName, Key) ->
    get_object_metadata(BucketName, Key, []).

-spec get_object_metadata(string(), string(), proplist() | aws_config()) -> proplist().

get_object_metadata(BucketName, Key, Config)
  when is_record(Config, aws_config) ->
    get_object_metadata(BucketName, Key, [], Config);

get_object_metadata(BucketName, Key, Options) ->
    get_object_metadata(BucketName, Key, Options, default_config()).

-spec get_object_metadata(string(), string(), proplist(), proplist() | aws_config()) -> proplist().

get_object_metadata(BucketName, Key, Options, Config) ->
    RequestHeaders = [{"If-Modified-Since", proplists:get_value(if_modified_since, Options)},
                      {"If-Unmodified-Since", proplists:get_value(if_unmodified_since, Options)},
                      {"If-Match", proplists:get_value(if_match, Options)},
                      {"If-None-Match", proplists:get_value(if_none_match, Options)}],
    Subresource = case proplists:get_value(version_id, Options) of
                      undefined -> "";
                      Version   -> ["versionId=", Version]
                  end,
    {Headers, _Body} = s3_request(Config, head, BucketName, [$/|Key], Subresource, [], <<>>, RequestHeaders),

    [{last_modified, proplists:get_value("last-modified", Headers)},
     {etag, proplists:get_value("etag", Headers)},
     {content_length, proplists:get_value("content-length", Headers)},
     {content_type, proplists:get_value("content-type", Headers)},
     {content_encoding, proplists:get_value("content-encoding", Headers)},
     {delete_marker, list_to_existing_atom(proplists:get_value("x-amz-delete-marker", Headers, "false"))},
     {replication_status, decode_replication_status(proplists:get_value("x-amz-replication-status", Headers))},
     {version_id, proplists:get_value("x-amz-version-id", Headers, "false")}|extract_metadata(Headers)].

extract_metadata(Headers) ->
    [{Key, Value} || {Key = "x-amz-meta-" ++ _, Value} <- Headers].

decode_replication_status(undefined) -> undefined;
decode_replication_status("PENDING") -> pending;
decode_replication_status("COMPLETED") -> completed;
decode_replication_status("FAILED") -> failed;
decode_replication_status("REPLICA") -> replica.

-spec get_object_torrent(string(), string()) -> proplist().

get_object_torrent(BucketName, Key) ->
    get_object_torrent(BucketName, Key, default_config()).

-spec get_object_torrent(string(), string(), aws_config()) -> proplist().

get_object_torrent(BucketName, Key, Config) ->
    {Headers, Body} = s3_request(Config, get, BucketName, [$/|Key], "torrent", [], <<>>, []),
    [{delete_marker, list_to_existing_atom(proplists:get_value("x-amz-delete-marker", Headers, "false"))},
     {version_id, proplists:get_value("x-amz-version-id", Headers, "null")},
     {torrent, Body}].

-spec list_object_versions(string()) -> proplist().

list_object_versions(BucketName) ->
    list_object_versions(BucketName, []).

-spec list_object_versions(string(), proplist() | aws_config()) -> proplist().

list_object_versions(BucketName, Config)
  when is_record(Config, aws_config) ->
    list_object_versions(BucketName, [], Config);

list_object_versions(BucketName, Options) ->
    list_object_versions(BucketName, Options, default_config()).

-spec list_object_versions(string(), proplist(), aws_config()) -> proplist().

list_object_versions(BucketName, Options, Config)
  when is_list(BucketName), is_list(Options) ->
    Params = [{"delimiter", proplists:get_value(delimiter, Options)},
              {"key-marker", proplists:get_value(key_marker, Options)},
              {"max-keys", proplists:get_value(max_keys, Options)},
              {"prefix", proplists:get_value(prefix, Options)},
              {"version-id-marker", proplists:get_value(version_id_marker, Options)}],
    Doc = s3_xml_request(Config, get, BucketName, "/", "versions", Params, <<>>, []),
    Attributes = [{name, "Name", text},
                  {prefix, "Prefix", text},
                  {key_marker, "KeyMarker", text},
                  {next_key_marker, "NextKeyMarker", optional_text},
                  {version_id_marker, "VersionIdMarker", text},
                  {next_version_id_marker, "NextVersionIdMarker", optional_text},
                  {max_keys, "MaxKeys", integer},
                  {is_truncated, "Istruncated", boolean},
                  {versions, "Version", fun extract_versions/1},
                  {delete_markers, "DeleteMarker", fun extract_delete_markers/1}],
    erlcloud_xml:decode(Attributes, Doc).

extract_versions(Nodes) ->
    [extract_version(Node) || Node <- Nodes].

extract_version(Node) ->
    Attributes = [{key, "Key", text},
                  {version_id, "VersionId", text},
                  {is_latest, "IsLatest", boolean},
                  {etag, "ETag", text},
                  {size, "Size", integer},
                  {owner, "Owner", fun extract_user/1},
                  {storage_class, "StorageClass", text},
                  {last_modified, "LastModified", time}],
    erlcloud_xml:decode(Attributes, Node).

extract_delete_markers(Nodes) ->
    [extract_delete_marker(Node) || Node <- Nodes].

extract_delete_marker(Node) ->
    Attributes = [{key, "Key", text},
                  {version_id, "VersionId", text},
                  {is_latest, "IsLatest", boolean},
                  {owner, "Owner", fun extract_user/1}],
    erlcloud_xml:decode(Attributes, Node).

extract_bucket(Node) ->
    erlcloud_xml:decode([{name, "Name", text},
                         {creation_date, "CreationDate", time}],
                        Node).

-spec put_object(string(), string(), iodata()) -> proplist().

put_object(BucketName, Key, Value) ->
    put_object(BucketName, Key, Value, []).

-spec put_object(string(), string(), iodata(), proplist() | aws_config()) -> proplist().

put_object(BucketName, Key, Value, Config)
  when is_record(Config, aws_config) ->
    put_object(BucketName, Key, Value, [], Config);

put_object(BucketName, Key, Value, Options) ->
    put_object(BucketName, Key, Value, Options, default_config()).

-spec put_object(string(), string(), iodata(), proplist(), [{string(), string()}] | aws_config()) -> proplist().

put_object(BucketName, Key, Value, Options, Config)
  when is_record(Config, aws_config) ->
    put_object(BucketName, Key, Value, Options, [], Config);

put_object(BucketName, Key, Value, Options, HTTPHeaders) ->
    put_object(BucketName, Key, Value, Options, HTTPHeaders, default_config()).

-spec put_object(string(), string(), iodata(), proplist(), [{string(), string()}], aws_config()) -> proplist().

put_object(BucketName, Key, Value, Options, HTTPHeaders, Config)
  when is_list(BucketName), is_list(Key), is_list(Value) orelse is_binary(Value),
       is_list(Options) ->
    RequestHeaders = [{"x-amz-acl", encode_acl(proplists:get_value(acl, Options))}|HTTPHeaders]
        ++ [{"x-amz-meta-" ++ string:to_lower(MKey), MValue} ||
               {MKey, MValue} <- proplists:get_value(meta, Options, [])]
        ++ [{"x-amz-tagging-" ++ MKey, MValue} ||
               {MKey, MValue} <- proplists:get_value(tags, Options, [])],
    POSTData = iolist_to_binary(Value),
    {Headers, _Body} = s3_request(Config, put, BucketName, [$/|Key], "", [],
                                  POSTData, RequestHeaders),
    [{version_id, proplists:get_value("x-amz-version-id", Headers, "null")} | Headers].

-spec set_object_acl(string(), string(), proplist()) -> ok.

set_object_acl(BucketName, Key, ACL) ->
    set_object_acl(BucketName, Key, ACL, default_config()).

-spec set_object_acl(string(), string(), proplist(), aws_config()) -> ok.

set_object_acl(BucketName, Key, ACL, Config)
  when is_list(BucketName), is_list(Key), is_list(ACL) ->
    Id = proplists:get_value(id, proplists:get_value(owner, ACL)),
    DisplayName = proplists:get_value(display_name, proplists:get_value(owner, ACL)),
    ACL1 = proplists:get_value(access_control_list, ACL),
    XML = {'AccessControlPolicy', [{'xmlns', ?XMLNS_S3}],
           [{'Owner', [{'ID', [Id]}, {'DisplayName', [DisplayName]}]},
            {'AccessControlList', encode_grants(ACL1)}]},
    XMLText = list_to_binary(xmerl:export_simple([XML], xmerl_xml, [{prolog, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"}])),
    s3_simple_request(Config, put, BucketName, [$/|Key], "acl", [], XMLText, [{"content-type", "application/xml"}]).

-spec sign_get(integer(), string(), string(), aws_config()) -> {binary(), string()}.
sign_get(Expire_time, BucketName, Key, Config)
  when is_integer(Expire_time), is_list(BucketName), is_list(Key) ->
    {Mega, Sec, _Micro} = os:timestamp(),
    Datetime = (Mega * 1000000) + Sec,
    Expires = integer_to_list(Expire_time + Datetime),
    SecurityTokenToSign = case Config#aws_config.security_token of
        undefined -> "";
        SecurityToken -> "x-amz-security-token:" ++ SecurityToken ++ "\n"
    end,
    To_sign = lists:flatten(["GET\n\n\n", Expires, "\n", SecurityTokenToSign, "/", BucketName, "/", Key]),
    Sig = base64:encode(erlcloud_util:sha256_mac(Config#aws_config.secret_access_key, To_sign)),
    {Sig, Expires}.

-spec make_link(integer(), string(), string()) -> {integer(), string(), string()}.

make_link(Expire_time, BucketName, Key) ->
    make_link(Expire_time, BucketName, Key, default_config()).

-spec make_link(integer(), string(), string(), aws_config()) -> {integer(), string(), string()}.

make_link(Expire_time, BucketName, Key, Config) ->
    EncodedKey = erlcloud_http:url_encode_loose(Key),
    {Sig, Expires} = sign_get(Expire_time, BucketName, EncodedKey, Config),
    Host = lists:flatten([Config#aws_config.s3_scheme, BucketName, ".", Config#aws_config.s3_host, port_spec(Config)]),
    SecurityTokenQS = case Config#aws_config.security_token of
        undefined -> "";
        SecurityToken -> "&x-amz-security-token=" ++ erlcloud_http:url_encode(SecurityToken)
    end,
    URI = lists:flatten(["/", EncodedKey, "?AWSAccessKeyId=", erlcloud_http:url_encode(Config#aws_config.access_key_id), "&Signature=", erlcloud_http:url_encode(Sig), "&Expires=", Expires, SecurityTokenQS]),
    {list_to_integer(Expires),
     binary_to_list(erlang:iolist_to_binary(Host)),
     binary_to_list(erlang:iolist_to_binary(URI))}.

-spec get_object_url(string(), string()) -> string().

get_object_url(BucketName, Key) ->
  get_object_url(BucketName, Key, default_config()).

-spec get_object_url(string(), string(), aws_config()) -> string().

get_object_url(BucketName, Key, Config) ->
  case Config#aws_config.s3_bucket_after_host of
      false -> lists:flatten([Config#aws_config.s3_scheme, BucketName, ".", Config#aws_config.s3_host, port_spec(Config), "/", Key]);
      true  -> lists:flatten([Config#aws_config.s3_scheme, Config#aws_config.s3_host, port_spec(Config), "/", BucketName, "/", Key])
  end.

-spec get_object_url_elements(string(), string(), aws_config()) -> {Host::string(), Path::string(), URL::string()}.
get_object_url_elements(BucketName, Key, Config) ->
    Key0 = case lists:prefix("/", Key) of
               true -> Key;
               false -> "/" ++ Key
           end,

    case Config#aws_config.s3_bucket_after_host of
        false ->
            Host = BucketName ++ "." ++ Config#aws_config.s3_host,
            {Host, Key0, lists:flatten([Config#aws_config.s3_scheme, Host, port_spec(Config), Key0])};
        true  ->
            Host = Config#aws_config.s3_host,
            Path = lists:flatten(["/", BucketName, Key0]),
            {Host, Path, lists:flatten([Config#aws_config.s3_scheme, Host, port_spec(Config), Path])}
    end.

-spec signature(aws_config(), string(), string(), string(), atom(), proplist(), proplist(), string()) -> string().
signature(Config, Path, Date, Region, Method, QueryParams, Headers, Payload) ->
  Service = "s3",
  CredentialScope = erlcloud_aws:credential_scope(Date, Region, Service),
  {CanonicalRequest, _} = erlcloud_aws:canonical_request(Method, Path, QueryParams, Headers, Payload),
  ToSign = erlcloud_aws:to_sign(Date, CredentialScope, CanonicalRequest),
  SigningKey = erlcloud_aws:signing_key(Config, Date, Region, Service),
  [Result] = erlcloud_aws:base16(erlcloud_util:sha256_mac( SigningKey, ToSign)),
  Result.

-spec make_presigned_v4_url(integer(), string(), atom(), string(), proplist()) -> {ok, string()} | {error, term()}.
make_presigned_v4_url(ExpireTime, BucketName, Method, Key, Params) ->
  make_presigned_v4_url(ExpireTime, BucketName, Method, Key, Params, default_config()).

%% Authenticating Requests: Using Query Parameters
%% https://docs.aws.amazon.com/AmazonS3/latest/API/sigv4-query-string-auth.html
%% Example:
%%   test() ->
%%       application:ensure_all_started(erlcloud),
%%       {ok, DefaultCfg} = erlcloud_aws:profile(),
%%       AWSCfg = DefaultCfg#aws_config{s3_host = "s3.your_region.amazonaws.com"},
%%       BucketName = "your_bucket_name",
%%       Key = "your_object_key",
%%       URL = erlcloud_s3:make_presigned_v4_url(604800, BucketName, put, Key, [{"X-User", "12333333"}], AWSCfg),
%%       io:format("~s~n", [URL]).
-spec make_presigned_v4_url(integer(), string(), atom(), string(), proplist(), aws_config()) -> string().
make_presigned_v4_url(ExpireTime, BucketName, Method, Key, QueryParams, Config) when is_integer(ExpireTime) ->
    {Host, Path, URL} = get_object_url_elements(BucketName, Key, Config),
    Region = erlcloud_aws:aws_region_from_host(Config#aws_config.s3_host),
    Date = erlcloud_aws:iso_8601_basic_time(),

     Credential = erlcloud_aws:credential(Config, Date, Region, "s3"),

     QP1 = [{"X-Amz-Algorithm", "AWS4-HMAC-SHA256"},
           {"X-Amz-Credential", Credential},
           {"X-Amz-Date", Date},
           {"X-Amz-Expires", integer_to_list(ExpireTime)},
           {"X-Amz-SignedHeaders", "host"}] ++ QueryParams,
    Headers = [{"host", Host}],
    Payload = "UNSIGNED-PAYLOAD",
    Signature = signature(Config, Path, Date, Region, Method, QP1, Headers, Payload),
    QueryStr = erlcloud_http:make_query_string(QP1 ++ [{"X-Amz-Signature", Signature}], no_assignment),
    lists:flatten([URL, "?", QueryStr]).

-spec make_get_url(integer(), string(), string()) -> iolist().

make_get_url(Expire_time, BucketName, Key) ->
    make_get_url(Expire_time, BucketName, Key, default_config()).

-spec make_get_url(integer(), string(), string(), aws_config()) -> iolist().

make_get_url(Expire_time, BucketName, Key, Config) ->
    {Sig, Expires} = sign_get(Expire_time, BucketName, erlcloud_http:url_encode_loose(Key), Config),
    SecurityTokenQS = case Config#aws_config.security_token of
        undefined -> "";
        SecurityToken -> "&x-amz-security-token=" ++ erlcloud_http:url_encode(SecurityToken)
    end,
    lists:flatten([get_object_url(BucketName, Key, Config),
     "?AWSAccessKeyId=", erlcloud_http:url_encode(Config#aws_config.access_key_id),
     "&Signature=", erlcloud_http:url_encode(Sig),
     "&Expires=", Expires,
     SecurityTokenQS]).

-spec start_multipart(string(), string()) -> {ok, proplist()} | {error, any()}.
start_multipart(BucketName, Key)
  when is_list(BucketName), is_list(Key) ->
    start_multipart(BucketName, Key, [], [], default_config()).

-spec start_multipart(string(), string(), proplist(), [{string(), string()}], aws_config()) -> {ok, proplist()} | {error, any()}.
start_multipart(BucketName, Key, Options, HTTPHeaders, Config)
  when is_list(BucketName), is_list(Key), is_list(Options), is_list(HTTPHeaders), is_record(Config, aws_config) ->

    RequestHeaders = [{"x-amz-acl", encode_acl(proplists:get_value(acl, Options))}|HTTPHeaders]
        ++ [{"x-amz-meta-" ++ string:to_lower(MKey), MValue} ||
               {MKey, MValue} <- proplists:get_value(meta, Options, [])]
        ++ [{"x-amz-tagging-" ++ MKey, MValue} ||
               {MKey, MValue} <- proplists:get_value(tags, Options, [])],
    POSTData = <<>>,
    case s3_xml_request2(Config, post, BucketName, [$/|Key], "uploads", [],
                         POSTData, RequestHeaders) of
        {ok, Doc} ->
            Attributes = [{uploadId, "UploadId", text}],
            {ok, erlcloud_xml:decode(Attributes, Doc)};

        Error ->
            Error
    end.

-spec upload_part(string(), string(), string(), integer(), iodata()) -> {ok, proplist()} | {error, any()}.
upload_part(BucketName, Key, UploadId, PartNumber, Value) ->
    upload_part(BucketName, Key, UploadId, PartNumber, Value, [], default_config()).

-spec upload_part(string(), string(), string(), integer(), iodata(), [{string(), string()}], aws_config()) -> {ok, proplist()} | {error, any()}.
upload_part(BucketName, Key, UploadId, PartNumber, Value, HTTPHeaders, Config)
  when is_list(BucketName), is_list(Key), is_list(UploadId), is_integer(PartNumber),
       is_list(Value) orelse is_binary(Value),
       is_list(HTTPHeaders), is_record(Config, aws_config) ->

    POSTData = iolist_to_binary(Value),
    case s3_request2(Config, put, BucketName, [$/|Key], [], [{"uploadId", UploadId},
                                                             {"partNumber", integer_to_list(PartNumber)}],
                     POSTData, HTTPHeaders) of
        {ok, {Headers, _Body}} ->
            {ok, [{etag, proplists:get_value("etag", Headers)}]};
        Error ->
            Error
    end.

-spec complete_multipart(string(), string(), string(), [{integer(), string()}]) -> ok | {error, any()}.
complete_multipart(BucketName, Key, UploadId, ETags)
  when is_list(BucketName), is_list(Key), is_list(UploadId), is_list(ETags) ->
    complete_multipart(BucketName, Key, UploadId, ETags, [], default_config()).

-spec complete_multipart(string(), string(), string(), [{integer(), string()}], [{string(), string()}], aws_config()) -> ok | {error, any()}.
complete_multipart(BucketName, Key, UploadId, ETags, HTTPHeaders, Config)
  when is_list(BucketName), is_list(Key), is_list(UploadId), is_list(ETags), is_list(HTTPHeaders), is_record(Config, aws_config) ->
    POSTData = list_to_binary(xmerl:export_simple([{'CompleteMultipartUpload',
                                                    [{'Part',
                                                      [{'PartNumber', [integer_to_list(Num)]},
                                                       {'ETag', [ETag]}] } || {Num, ETag} <- ETags]}], xmerl_xml)),

    case s3_request2(Config, post, BucketName, [$/|Key], [], [{"uploadId", UploadId}],
                     POSTData, HTTPHeaders) of
        {ok, {_Headers, _Body}} ->
            ok;
        Error ->
            Error
    end.

-spec abort_multipart(string(), string(), string()) -> ok | {error, any()}.
abort_multipart(BucketName, Key, UploadId)
  when is_list(BucketName), is_list(Key), is_list(UploadId) ->
    abort_multipart(BucketName, Key, UploadId, [], [], default_config()).

-spec abort_multipart(string(), string(), string(), proplist(), [{string(), string()}], aws_config()) -> ok | {error, any()}.
abort_multipart(BucketName, Key, UploadId, Options, HTTPHeaders, Config)
  when is_list(BucketName), is_list(Key), is_list(UploadId), is_list(Options),
       is_list(HTTPHeaders), is_record(Config, aws_config) ->

    case s3_request2(Config, delete, BucketName, [$/|Key], [], [{"uploadId", UploadId}],
                     <<>>, HTTPHeaders) of
        {ok, _} ->
            ok;
        Error ->
            Error
    end.

-spec list_multipart_uploads(string()) -> {ok, proplist()} | {error, any()}.
list_multipart_uploads(BucketName)
  when is_list(BucketName) ->

    list_multipart_uploads(BucketName, [], [], default_config()).

-spec list_multipart_uploads(string(), proplist()) -> {ok, proplist()} | {error, any()}.
list_multipart_uploads(BucketName, Options)
  when is_list(BucketName), is_list(Options) ->

    list_multipart_uploads(BucketName, Options, [], default_config()).

-spec list_multipart_uploads(string(), proplist(), [{string(), string()}], aws_config()) -> {ok, proplist()} | {error, any()}.
list_multipart_uploads(BucketName, Options, HTTPHeaders, Config)
  when is_list(BucketName), is_list(Options),
       is_list(HTTPHeaders), is_record(Config, aws_config) ->

    Params = [
              {"uploads", ""},
              {"delimiter", proplists:get_value(delimiter, Options)},
              {"prefix", proplists:get_value(prefix, Options)},
              {"max-uploads", proplists:get_value(max_uploads, Options)},
              {"key-marker", proplists:get_value(key_marker, Options)},
              {"upload-id-marker", proplists:get_value(upload_id_marker, Options)}
             ],

    case s3_xml_request2(Config, get, BucketName, "/", "", Params, <<>>, HTTPHeaders) of
        {ok, Xml} ->
            Uploads = [erlcloud_xml:decode([{key, "Key", text},
                                            {uploadId, "UploadId", text}], Node) || Node <- xmerl_xpath:string("/ListMultipartUploadsResult/Upload", Xml)],

            CommonPrefixes = [erlcloud_xml:get_text("Prefix", Node) || Node <- xmerl_xpath:string("/ListMultipartUploadsResult/CommonPrefixes", Xml)],

            {ok, [{uploads, Uploads},
                  {common_prefixes, CommonPrefixes}]};
        Error ->
            Error
    end.

-spec set_bucket_attribute(string(), atom(), term()) -> ok.

set_bucket_attribute(BucketName, AttributeName, Value) ->
    set_bucket_attribute(BucketName, AttributeName, Value, default_config()).

-spec set_bucket_attribute(string(), atom(), term(), aws_config()) -> ok.

set_bucket_attribute(BucketName, AttributeName, Value, Config)
  when is_list(BucketName) ->
    {Subresource, XML} =
        case AttributeName of
            acl ->
                ACLXML = {'AccessControlPolicy',
                          [{'Owner',
                            [{'ID', [proplists:get_value(id, proplists:get_value(owner, Value))]},
                             {'DisplayName', [proplists:get_value(display_name, proplists:get_value(owner, Value))]}]},
                           {'AccessControlList', encode_grants(proplists:get_value(access_control_list, Value))}]},
                {"acl", ACLXML};
            logging ->
                LoggingXML = {'BucketLoggingStatus',
                              [{'xmlns:xsi', ?XMLNS_S3}],
                              case proplists:get_bool(enabled, Value) of
                                  true ->
                                      [{'LoggingEnabled',
                                        [
                                         {'TargetBucket', [proplists:get_value(target_bucket, Value)]},
                                         {'TargetPrefix', [proplists:get_value(target_prefix, Value)]},
                                         {'TargetGrants', encode_grants(proplists:get_value(target_grants, Value, []))}
                                        ]
                                       }];
                                  false ->
                                      []
                              end},
                {"logging", LoggingXML};
            request_payment ->
                PayerName = case Value of
                                requester -> "Requester";
                                bucket_owner -> "BucketOwner"
                            end,
                RPXML = {'RequestPaymentConfiguration', [{'xmlns:xsi', ?XMLNS_S3}],
                         [
                          {'Payer', [PayerName]}
                         ]
                        },
                {"requestPayment", RPXML};
            Versioning when Versioning =:= versioning;
                            Versioning =:= mfa_delete ->
                Status = case proplists:get_value(status, Value) of
                             suspended -> "Suspended";
                             enabled -> "Enabled"
                         end,
                MFADelete = case proplists:get_value(mfa_delete, Value, disabled) of
                                enabled -> "Enabled";
                                disabled -> "Disabled"
                            end,
                VersioningXML = {'VersioningConfiguration', [{'xmlns:xsi', ?XMLNS_S3}],
                                 [{'Status', [Status]},
                                  {'MfaDelete', [MFADelete]}]},
                {"versioning", VersioningXML};
            notification ->
                {"notification", create_notification_xml(Value)}
        end,
    POSTData = list_to_binary(xmerl:export_simple([XML], xmerl_xml)),
    Headers = [{"content-type", "application/xml"}],
    s3_simple_request(Config, put, BucketName, "/", Subresource, [], POSTData, Headers).

-spec put_object_tagging(string(), string(), list({string(), string()})) -> ok.
put_object_tagging(BucketName, Key, TagList) when is_list(BucketName) ->
    put_object_tagging(BucketName, Key, TagList, default_config()).

-spec put_object_tagging(string(), string(), list({string(), string()}), aws_config()) -> ok.
put_object_tagging(BucketName, Key, TagList, #aws_config{} = Config) when is_list(BucketName) ->
    TaggingXML = {'Tagging',
      [{'TagSet', encode_tags(TagList)}]},
    POSTData = unicode:characters_to_binary(xmerl:export_simple([TaggingXML], xmerl_xml)),
    Md5 = base64:encode(crypto:hash(md5, POSTData)),
    Headers = [{"content-md5", Md5}, {"content-type", "application/xml"}],
    s3_simple_request(Config, put, BucketName, [$/|Key], "tagging", [], POSTData, Headers).

-spec delete_object_tagging(string(), string()) -> ok.
delete_object_tagging(BucketName, Key) when is_list(BucketName) ->
    delete_object_tagging(BucketName, Key, default_config()).

-spec delete_object_tagging(string(), string(), aws_config()) -> ok.
delete_object_tagging(BucketName, Key, #aws_config{} = Config) when is_list(BucketName) ->
    s3_simple_request(Config, delete, BucketName, [$/|Key], "tagging", [], <<>>, []).

-spec get_object_tagging(string(), string()) -> {ok, list({string(), string()})}.
get_object_tagging(BucketName, Key) when is_list(BucketName) ->
    get_object_tagging(BucketName, Key, default_config()).

-spec get_object_tagging(string(), string(), aws_config()) -> {ok, list({string(), string()})}.
get_object_tagging(BucketName, Key, #aws_config{} = Config) when is_list(BucketName) ->
    Doc = s3_xml_request(Config, get, BucketName, [$/|Key], "tagging", [], <<>>, []),
    {ok,
     [extract_tag(Node) || Node <- xmerl_xpath:string("/Tagging/TagSet/Tag", Doc)]}.

-spec put_bucket_tagging(string(), list({string(), string()})) -> ok.
put_bucket_tagging(BucketName, TagList) when is_list(BucketName) ->
    put_bucket_tagging(BucketName, TagList, default_config()).

-spec put_bucket_tagging(string(), list({string(), string()}), aws_config()) -> ok.
put_bucket_tagging(BucketName, TagList, #aws_config{} = Config) when is_list(BucketName) ->
    TaggingXML = {'Tagging',
		  [{'TagSet', encode_tags(TagList)}]},
    POSTData = list_to_binary(xmerl:export_simple([TaggingXML], xmerl_xml)),
    Md5 = base64:encode(crypto:hash(md5, POSTData)),
    Headers = [{"content-md5", Md5}, {"content-type", "application/xml"}],
    s3_simple_request(Config, put, BucketName, "/", "tagging", [], POSTData, Headers).

-spec delete_bucket_tagging(string()) -> ok.
delete_bucket_tagging(BucketName) when is_list(BucketName) ->
    delete_bucket_tagging(BucketName, default_config()).

-spec delete_bucket_tagging(string(), aws_config()) -> ok.
delete_bucket_tagging(BucketName, #aws_config{} = Config) when is_list(BucketName) ->
    s3_simple_request(Config, delete, BucketName, "/", "tagging", [], <<>>, []).

-spec get_bucket_tagging(string()) -> {ok, list({string(), string()})}.
get_bucket_tagging(BucketName) when is_list(BucketName) ->
    get_bucket_tagging(BucketName, default_config()).

-spec get_bucket_tagging(string(), aws_config()) -> {ok, list({string(), string()})}.
get_bucket_tagging(BucketName, #aws_config{} = Config) when is_list(BucketName) ->
    Doc = s3_xml_request(Config, get, BucketName, "/", "tagging", [], <<>>, []),
    {ok,
     [extract_tag(Node) || Node <- xmerl_xpath:string("/Tagging/TagSet/Tag", Doc)]}.

extract_tag(Node) ->
    List = erlcloud_xml:decode([{key, "Key", text}, {value, "Value", text}], Node),
    {proplists:get_value(key, List), proplists:get_value(value, List)}.

encode_tags(Taglist) ->
    lists:map(fun encode_one_tag/1, Taglist).

encode_one_tag({Key, Value}) ->
    {'Tag',
     [
      {'Key', [Key]},
      {'Value', [Value]}
     ]
    }.

-spec list_bucket_inventory(string()) ->
    {ok, Result:: list(term())} | {error, Reason::term()}.
list_bucket_inventory(BucketName) when is_list(BucketName) ->
    list_bucket_inventory(BucketName, default_config()).

-spec list_bucket_inventory(string(), string() | aws_config()) ->
    {ok, Result:: list(term())} | {error, Reason::term()}.
list_bucket_inventory(BucketName, #aws_config{} = Config) when is_list(BucketName) ->
    list_bucket_inventory(BucketName, undefined, Config);
list_bucket_inventory(BucketName, Token) when is_list(BucketName), is_list(Token) ->
    list_bucket_inventory(BucketName, Token,  default_config()).

-spec list_bucket_inventory(string(), undefined | string(), aws_config()) ->
    {ok, Result:: list(term())} | {error, Reason::term()}.
list_bucket_inventory(BucketName, Token, #aws_config{} = Config) when is_list(BucketName) ->
    Params = [{"continuation-token", Token}],
    case s3_request2(Config, get, BucketName, "/", "inventory", Params, <<>>, []) of
        {ok, {_Headers, Body}} ->
            list_inventory_result(element(1, xmerl_scan:string(binary_to_list(Body))));
        Error ->
            Error
    end.

list_inventory_result(Response) ->
    ParsedResponse = extract_list_inventory_result(Response),
    Truncated = proplists:get_value(is_truncated, ParsedResponse, false),
    ContinuationToken = proplists:get_value(continuation_token, ParsedResponse, []),
    NextContinuationToken = proplists:get_value(next_continuation_token, ParsedResponse, []),
    UpdatedResponse = lists:keydelete(
        is_truncated,
        1,
        lists:keydelete(
            continuation_token,
            1,
            lists:keydelete(next_continuation_token, 1, ParsedResponse)
        )
    ),
    make_list_inventory_result(
        Truncated,
        ContinuationToken,
        NextContinuationToken,
        UpdatedResponse
    ).

make_list_inventory_result(false, _, _, Result)->
    {ok, Result};
make_list_inventory_result(_, [], NextContinuationToken, Result)->
    {ok, Result, NextContinuationToken};
make_list_inventory_result(_, ContinuationToken, [], Result)->
    {ok, Result, ContinuationToken}.


extract_list_inventory_result(Result) ->
    [Content] = xmerl_xpath:string("/ListInventoryConfigurationsResult", Result),
    extract_list_inventory_result_content(Content).

extract_list_inventory_result_content(Content) ->
    Attributes = [
        {
            inventory_configuration,
            "InventoryConfiguration",
            fun extract_inventory_configuration_content/1
        },
        {is_truncated, "IsTruncated", boolean},
        {continuation_token, "ContinuationToken", text},
        {next_continuation_token, "NextContinuationToken", text}
    ],
    erlcloud_xml:decode(Attributes, Content).

extract_inventory_configuration(Configuration) ->
    [Content] = xmerl_xpath:string("/InventoryConfiguration", Configuration),
    extract_inventory_configuration_content(Content).

extract_inventory_configuration_content(Contents) when is_list(Contents)->
    [extract_inventory_configuration_content(Content) || Content <- Contents];
extract_inventory_configuration_content(Content) ->
    Attributes = [
        {id, "Id", text},
        {is_enabled, "IsEnabled", text},
        {filter, "Filter", fun extract_filter/1},
        {destination, "Destination", fun extract_destination/1},
        {schedule, "Schedule", fun extract_schedule/1},
        {included_object_versions, "IncludedObjectVersions", text},
        {optional_fields, "OptionalFields", fun extract_optional_fields/1}
    ],
    erlcloud_xml:decode(Attributes, Content).

extract_destination([Destination]) ->
    Attributes = [{s3_bucket_destination, "S3BucketDestination", fun extract_s3_bucket_destination/1}],
    erlcloud_xml:decode(Attributes, Destination).

extract_s3_bucket_destination([S3BucketDestination]) ->
    Attributes = [
        {format, "Format", text},
        {account_id, "AccountId", text},
        {bucket, "Bucket", text},
        {prefix, "Prefix", text}
    ],
    erlcloud_xml:decode(Attributes, S3BucketDestination).

extract_schedule([Schedule]) ->
    Attributes = [{frequency, "Frequency", text}],
    erlcloud_xml:decode(Attributes, Schedule).

extract_filter([]) ->
    [{prefix, ""}];
extract_filter([Filter]) ->
    Attributes = [{prefix, "Prefix", text}],
    erlcloud_xml:decode(Attributes, Filter).


extract_optional_fields([OptionalFields]) ->
    Attributes = [{field, "Field", list}],
    erlcloud_xml:decode(Attributes, OptionalFields).

-spec get_bucket_inventory(string(), string()) ->
    {ok, Result:: list(term())} | {error, Reason::term()}.
get_bucket_inventory(BucketName, InventoryId) when is_list(BucketName), is_list(InventoryId) ->
    get_bucket_inventory(BucketName, InventoryId, default_config()).

-spec get_bucket_inventory(string(), string(), aws_config()) ->
    {ok, Result:: list(term())} | {error, Reason::term()}.
get_bucket_inventory(BucketName, InventoryId, #aws_config{} = Config)
    when is_list(BucketName), is_list(InventoryId) ->

    Params = [{"id", InventoryId}],
    case s3_request2(Config, get, BucketName, "/", "inventory", Params, <<>>, []) of
        {ok, {_Headers, Body}} ->
            {ok, extract_inventory_configuration(element(1, xmerl_scan:string(binary_to_list(Body))))};
        Error ->
            Error
    end.

-spec put_bucket_inventory(string(), list()) -> ok | {error, Reason::term()}.
put_bucket_inventory(BucketName, Inventory)
    when is_list(BucketName), is_list(Inventory) ->

    put_bucket_inventory(BucketName, Inventory, default_config()).

-spec put_bucket_inventory(string(), list(), aws_config())
        -> ok | {error, Reason::term()}.
put_bucket_inventory(BucketName, Inventory, #aws_config{} = Config)
    when is_list(BucketName), is_list(Inventory) ->

    InventoryId = proplists:get_value(id, Inventory),
    XmlInventory = encode_inventory(Inventory),
    put_bucket_inventory(BucketName, InventoryId, list_to_binary(XmlInventory), Config).

-spec put_bucket_inventory(string(), string(), binary(), aws_config())
        -> ok | {error, Reason::term()}.
put_bucket_inventory(BucketName, InventoryId, XmlInventory, #aws_config{} = Config)
    when is_list(BucketName), is_list(InventoryId), is_binary(XmlInventory) ->
    Md5 = base64:encode(crypto:hash(md5, XmlInventory)),
    Params = [{"id", InventoryId}],
    Headers = [{"Content-MD5", Md5}, {"content-type", "application/xml"}],
    s3_simple_request(Config, put, BucketName, "/", "inventory", Params, XmlInventory, Headers).

-spec delete_bucket_inventory(string(), string()) -> ok | {error, Reason::term()}.
delete_bucket_inventory(BucketName, InventoryId) when is_list(BucketName), is_list(InventoryId) ->
    delete_bucket_inventory(BucketName, InventoryId, default_config()).

-spec delete_bucket_inventory(string(), string(), aws_config()) -> ok | {error, Reason::term()}.
delete_bucket_inventory(BucketName, InventoryId, #aws_config{} = Config)
    when is_list(BucketName), is_list(InventoryId) ->

    Params = [{"id", InventoryId}],
    s3_simple_request(Config, delete, BucketName, "/", "inventory", Params, <<>>, []).

encode_inventory(Inventory) ->
    lists:flatten(
        xmerl:export_simple(
            [{
                'InventoryConfiguration',
                [{xmlns, "http://s3.amazonaws.com/doc/2006-03-01/"}],
                inv_encode_subtype(Inventory)
            }],
            xmerl_xml
        )
    ).

inv_encode_subtype([{_, _} | _] = Proplist) ->
    lists:flatten(lists:map(
        fun(Elem) ->
            inv_encode_subtype(Elem)
        end,
        Proplist
    ));
inv_encode_subtype({Key, [{_, _} | _] = Proplist}) ->
    {inv_key_to_name(Key), inv_encode_subtype(Proplist)};
inv_encode_subtype({Key, [[{_, _} | _], _] = ListOfProplist}) ->
    lists:map(
        fun(List) ->
            {inv_key_to_name(Key), inv_encode_subtype(List)}
        end,
        ListOfProplist
    );
inv_encode_subtype({Key, [Val | _] = ListOfValues}) when is_list(Val) ->
    lists:map(
        fun(Value) ->
            {inv_key_to_name(Key), inv_encode_subtype(Value)}
        end,
        ListOfValues
    );
inv_encode_subtype({Key, Value}) ->
    {inv_key_to_name(Key), inv_encode_subtype(Value)};
inv_encode_subtype(Value) ->
    [erlcloud_util:to_string(Value)].

inv_key_to_name(inventory_configuration) ->  'InventoryConfiguration';
inv_key_to_name(id) ->                       'Id';
inv_key_to_name(is_enabled) ->               'IsEnabled';
inv_key_to_name(included_object_versions) -> 'IncludedObjectVersions';
inv_key_to_name(destination) ->              'Destination';
inv_key_to_name(schedule) ->                 'Schedule';
inv_key_to_name(frequency) ->                'Frequency';
inv_key_to_name(filter) ->                   'Filter';
inv_key_to_name(optional_fields) ->          'OptionalFields';
inv_key_to_name(s3_bucket_destination) ->    'S3BucketDestination';
inv_key_to_name(format) ->                   'Format';
inv_key_to_name(account_id) ->               'AccountId';
inv_key_to_name(bucket) ->                   'Bucket';
inv_key_to_name(prefix) ->                   'Prefix';
inv_key_to_name(field) ->                    'Field'.

%% @doc
%% S3 API:
%% https://docs.aws.amazon.com/AmazonS3/latest/API/RESTBucketPUTencryption.html
%%
%% `
%% ok = erlcloud_s3:put_bucket_encryption("bucket-name",
%%                                        "aws:kms",
%%                                        "arn:aws:kms:us-east-1:1234/example").
%% '
%%
-spec put_bucket_encryption(string(), string()) -> ok | {error, any()}.
put_bucket_encryption(BucketName, SSEAlgorithm) ->
    put_bucket_encryption(BucketName, SSEAlgorithm, undefined, default_config()).

-spec put_bucket_encryption(string(), string(), string() | aws_config()) ->
    ok | {error, any()}.
put_bucket_encryption(BucketName, SSEAlgorithm, KMSMasterKeyId)
  when is_list(KMSMasterKeyId) ->
    Config = default_config(),
    put_bucket_encryption(BucketName, SSEAlgorithm, KMSMasterKeyId, Config);
put_bucket_encryption(BucketName, SSEAlgorithm, Config)
  when is_record(Config, aws_config) ->
    put_bucket_encryption(BucketName, SSEAlgorithm, undefined, Config).

-spec put_bucket_encryption(string(), string(), string() | undefined,
                            aws_config()) ->
    ok | {error, any()}.
put_bucket_encryption(BucketName, SSEAlgorithm, KMSMasterKeyId, Config) ->
    ApplySSEOPts = build_apply_sse_opts(SSEAlgorithm, KMSMasterKeyId),
    XML = {
        'ApplyServerSideEncryptionByDefault',
        [{'xmlns', ?XMLNS_S3}],
        [{'Rule', [
            {'ApplyServerSideEncryptionByDefault', ApplySSEOPts}
        ]}]
    },
    Attrs = [{prolog, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"}],
    Data  = list_to_binary(xmerl:export_simple([XML], xmerl_xml, Attrs)),
    s3_xml_request2(Config, put, BucketName, "/", "encryption", [], Data, []).

build_apply_sse_opts(SSEAlgorithm, undefined) ->
    [{'SSEAlgorithm', [SSEAlgorithm]}];
build_apply_sse_opts(SSEAlgorithm, KMSMasterKeyId) ->
    [{'SSEAlgorithm',   [SSEAlgorithm]},
     {'KMSMasterKeyID', [KMSMasterKeyId]}].

%% @doc
%% S3 API:
%% https://docs.aws.amazon.com/AmazonS3/latest/API/RESTBucketGETencryption.html
%%
%% `
%% {ok, [{sse_algorithm,     "AES256"},
%%       {kms_master_key_id, undefined}]} = erlcloud_s3:get_bucket_encryption("bucket-name").
%% '
%%
-spec get_bucket_encryption(string()) ->
    {ok, proplists:proplist()} | {error, any()}.
get_bucket_encryption(BucketName) ->
    get_bucket_encryption(BucketName, default_config()).

-spec get_bucket_encryption(string(), aws_config()) ->
    {ok, proplists:proplist()} | {error, any()}.
get_bucket_encryption(BucketName, Config) ->
    case s3_xml_request2(Config, get, BucketName, "/", "encryption", [], <<>>, []) of
        {ok, XML} ->
            XPath = "/ServerSideEncryptionConfiguration"
                    "/Rule"
                    "/ApplyServerSideEncryptionByDefault",
            Algorithm = XPath ++ "/SSEAlgorithm",
            KMSKey    = XPath ++ "/KMSMasterKeyID",
            {ok, [
                {sse_algorithm,     erlcloud_xml:get_text(Algorithm, XML)},
                {kms_master_key_id, erlcloud_xml:get_text(KMSKey, XML, undefined)}
            ]};
        Error ->
            Error
    end.

%% @doc
%% S3 API:
%% https://docs.aws.amazon.com/AmazonS3/latest/API/API_GetPublicAccessBlock.html
%%
%% `
%% {ok, [{block_public_acls, true},
%%       {ignore_public_acls, true},
%%       {block_public_policy, true},
%%       {restrict_public_buckets, true}]} = erlcloud_s3:get_public_access_block("bucket-name").
%% '
%%
-spec get_public_access_block(string()) ->
    {ok, public_access_block_configuration()} | {error, any()}.
get_public_access_block(BucketName) ->
    get_public_access_block(BucketName, default_config()).

-spec get_public_access_block(string(), aws_config()) ->
    {ok, public_access_block_configuration()} | {error, any()}.
get_public_access_block(BucketName, Config) ->
    case s3_xml_request2(Config, get, BucketName, "/", "publicAccessBlock", [], <<>>, []) of
        {ok, XML} ->
            XPath = "/PublicAccessBlockConfiguration",
            BlockPublicAcls = XPath ++ "/BlockPublicAcls",
            IgnorePublicAcls = XPath ++ "/IgnorePublicAcls",
            BlockPublicPolicy = XPath ++ "/BlockPublicPolicy",
            RestrictPublicBuckets = XPath ++ "/RestrictPublicBuckets",
            {ok, [
                {block_public_acls,       erlcloud_xml:get_bool(BlockPublicAcls, XML)},
                {ignore_public_acls,      erlcloud_xml:get_bool(IgnorePublicAcls, XML)},
                {block_public_policy,     erlcloud_xml:get_bool(BlockPublicPolicy, XML)},
                {restrict_public_buckets, erlcloud_xml:get_bool(RestrictPublicBuckets, XML)}
            ]};
        Error ->
            Error
    end.

%% @doc
%% S3 API:
%% https://docs.aws.amazon.com/AmazonS3/latest/API/API_PutPublicAccessBlock.html
%%
%% `
%% PublicAccessBlock = [{block_public_acls, true},
%%                      {ignore_public_acls, true},
%%                      {block_public_policy, true},
%%                      {restrict_public_buckets, true}],
%% ok = erlcloud_s3:put_public_access_block("bucket-name", PublicAccessBlock).
%% '
%%
-spec put_public_access_block(string(), public_access_block_configuration()) ->
    ok | {error, any()}.
put_public_access_block(BucketName, PublicAccessBlock) ->
    put_public_access_block(BucketName, PublicAccessBlock, default_config()).

-spec put_public_access_block(string(), public_access_block_configuration(), aws_config()) ->
    ok | {error, any()}.
put_public_access_block(BucketName, PublicAccessBlock, Config) ->
    PublicAccessBlockXML = {'PublicAccessBlockConfiguration', [{xmlns, ?XMLNS_S3}],
                            encode_public_access_block(PublicAccessBlock)},
    POSTData = list_to_binary(xmerl:export_simple([PublicAccessBlockXML], xmerl_xml)),
    Md5 = base64:encode(crypto:hash(md5, POSTData)),
    Headers = [{"content-md5", Md5}, {"content-type", "application/xml"}],
    s3_simple_request(Config, put, BucketName, "/", "publicAccessBlock", [], POSTData, Headers).

%% @doc
%% S3 API:
%% https://docs.aws.amazon.com/AmazonS3/latest/API/RESTBucketDELETEencryption.html
%%
%% `
%% ok = erlcloud_s3:delete_bucket_encryption("bucket-name").
%% '
%%
-spec delete_bucket_encryption(string()) -> ok | {error, any()}.
delete_bucket_encryption(BucketName) ->
    delete_bucket_encryption(BucketName, default_config()).

-spec delete_bucket_encryption(string(), aws_config()) -> ok | {error, any()}.
delete_bucket_encryption(BucketName, Config) ->
    s3_xml_request2(Config, delete, BucketName, "/", "encryption", [], <<>>, []).

%% takes an S3 bucket notification configuration and creates an xmerl simple
%% form out of it.
%% for the examples of input / output of this function, see tests.
-spec create_notification_xml(list(proplist())) -> tuple().
create_notification_xml(Confs) ->
    {'NotificationConfiguration', [create_notification_xml(ConfName, Params)
        || [{ConfName, Params}] <- Confs]}.
-spec create_notification_xml(atom(), proplist()) -> tuple().
create_notification_xml(ConfName, Params) ->
    {conf_name_in_xml(ConfName),
        lists:foldr(fun create_notification_param_xml/2, [], Params)}.

conf_name_in_xml(queue_configuration) -> 'QueueConfiguration';
conf_name_in_xml(topic_configuration) -> 'TopicConfiguration';
conf_name_in_xml(cloud_function_configuration) -> 'CloudFunctionConfiguration'.

filter_rule_tuple(Name, Value) -> {'FilterRule', [{'Name', [Name]}, {'Value', [Value]}]}.

filter_rule({prefix, Value}) -> filter_rule_tuple("Prefix", Value);
filter_rule({suffix, Value}) -> filter_rule_tuple("Suffix", Value).

-spec create_notification_param_xml({atom(), term()}, proplist()) -> proplist().
%% Filter example: [{prefix, "images/"}, {suffix, "jpg"}]
%% both prefix and suffix are optional
create_notification_param_xml({filter, Filter}, Acc) ->
    FilterRules = [filter_rule({Name, Value}) || {Name, Value} <- Filter],
    [{'Filter', [{'S3Key', FilterRules}]} | Acc];
create_notification_param_xml({event, Events}, Acc) ->
    [{'Event', [Event]} || Event <- Events] ++ Acc;
create_notification_param_xml({queue, Queue}, Acc) -> [{'Queue', [Queue]} | Acc];
create_notification_param_xml({topic, Topic}, Acc) -> [{'Topic', [Topic]} | Acc];
create_notification_param_xml({id, Id}, Acc) -> [{'Id', [Id]} | Acc];
create_notification_param_xml({cloud_function, CF}, Acc) -> [{'CloudFunction', [CF]} | Acc].

%%% See http://docs.aws.amazon.com/AmazonS3/latest/dev/UsingBucket.html and
%%%   http://docs.aws.amazon.com/AmazonS3/latest/dev/RESTAPI.html for info on
%%%   addressing
-spec get_bucket_and_key(string()) -> {string(), string()}.

get_bucket_and_key(Uri) ->
  {ok, Parsed} = erlcloud_util:uri_parse(Uri),
  {Host, Path} = extract_host_and_path(Parsed),
  extract_location_fields(Host, Path).

extract_host_and_path({_Scheme, _UserInfo, Host, _Port, Path, _Query}) ->
  {Host, Path}.

extract_location_fields(Host, Path) ->
  HostTokens = string:tokens(Host, "."),
  extract_bucket_and_key(HostTokens, Path).

extract_bucket_and_key([Bucket, _S3, _AmazonAWS, _Com], [$/ | Key]) ->
  %% Virtual-hosted-style URL
  %% For example: bucket_name.s3.amazonaws.com/path/to/key
  {Bucket, Key};
extract_bucket_and_key([_S3, _AmazonAWS, _Com], [$/ | BucketAndKey]) ->
  %% Path-style URL
  %% For example: s3.amazonaws.com/bucket_name/path/to/key
  [Bucket, Key] = re:split(BucketAndKey, "/", [{return, list}, {parts, 2}]),
  {Bucket, Key}.

encode_grants(Grants) ->
    [encode_grant(Grant) || Grant <- Grants].

encode_grant(Grant) ->
    Grantee = proplists:get_value(grantee, Grant),
    {'Grant',
     [encode_grantee(Grantee),
      {'Permission', [encode_permission(proplists:get_value(permission, Grant))]}]}.

encode_grantee(Grantee) ->
  case proplists:get_value(id, Grantee) of
    undefined ->
      {'Grantee', [{'xmlns:xsi', ?XMLNS_SCHEMA_INSTANCE}, {'xsi:type', "Group"}],
      [{'URI', [proplists:get_value(uri, Grantee)]}]};
    Id ->
      {'Grantee', [{'xmlns:xsi', ?XMLNS_SCHEMA_INSTANCE}, {'xsi:type', "CanonicalUser"}],
      [{'ID', [Id]},
       {'DisplayName', [proplists:get_value(display_name, Grantee)]}]}
  end.

s3_simple_request(Config, Method, Host, Path, Subresource, Params, POSTData, Headers) ->
    case s3_request(Config, Method, Host, Path, Subresource, Params, POSTData, Headers) of
        {_Headers, <<>>} -> ok;
        {_Headers, Body} ->
            XML = element(1,xmerl_scan:string(binary_to_list(Body))),
            case XML of
                #xmlElement{name='Error'} ->
                    ErrCode = erlcloud_xml:get_text("/Error/Code", XML),
                    ErrMsg = erlcloud_xml:get_text("/Error/Message", XML),
                    erlang:error({s3_error, ErrCode, ErrMsg});
                _ ->
                    ok
            end
    end.

s3_xml_request(Config, Method, Host, Path, Subresource, Params, POSTData, Headers) ->
    {_Headers, Body} = s3_request(Config, Method, Host, Path, Subresource, Params, POSTData, Headers),
    XML = element(1,xmerl_scan:string(binary_to_list(Body))),
    case XML of
        #xmlElement{name='Error'} ->
            ErrCode = erlcloud_xml:get_text("/Error/Code", XML),
            ErrMsg = erlcloud_xml:get_text("/Error/Message", XML),
            erlang:error({s3_error, ErrCode, ErrMsg});
        _ ->
            XML
    end.

s3_request(Config, Method, Host, Path, Subreasource, Params, POSTData, Headers) ->
    case s3_request2(Config, Method, Host, Path, Subreasource, Params, POSTData, Headers) of
        {ok, Result} ->
            Result;
        {error, Reason} ->
            erlang:error({aws_error, Reason})
    end.

%% s3_request2 returns {ok, Body} or {error, Reason} instead of throwing as s3_request does
%% This is the preferred pattern for new APIs
s3_request2(Config, Method, Bucket, Path, Subresource, Params, POSTData, Headers) ->
    case erlcloud_aws:update_config(Config) of
        {ok, Config1} ->
            case s3_request4_no_update(Config1, Method, Bucket, Path,
                   Subresource, Params, POSTData, Headers)
            of
                {error, {http_error, StatusCode, _, _, _}} = RedirectResponse
                    when StatusCode >= 301 andalso StatusCode < 400 ->
                    s3_follow_redirect(RedirectResponse, Config1, Method, Bucket, Path,
                        Subresource, Params, POSTData, Headers);
                {error, {http_error, StatusCode, StatusLine, Body, _Headers}} ->
                    {error, {http_error, StatusCode, StatusLine, Body}};
                Response ->
                    Response
            end;
        {error, Reason} ->
            {error, Reason}
    end.

s3_xml_request2(Config, Method, Host, Path, Subresource, Params, POSTData, Headers) ->
    case s3_request2(Config, Method, Host, Path, Subresource, Params, POSTData, Headers) of
        {ok, {_Headers, <<>>}} -> ok;
        {ok, {_Headers, Body}} ->
            XML = element(1,xmerl_scan:string(binary_to_list(Body))),
            case XML of
                #xmlElement{name='Error'} ->
                    ErrCode = erlcloud_xml:get_text("/Error/Code", XML),
                    ErrMsg = erlcloud_xml:get_text("/Error/Message", XML),
                    {error, {s3_error, ErrCode, ErrMsg}};
                _ ->
                    {ok, XML}
            end;
        Error ->
            Error
    end.

%% http://docs.aws.amazon.com/AmazonS3/latest/dev/UsingBucket.html#create-bucket-intro
%% AccessMethod can be either 'vhost' - virtual-hosted–style or
%% 'path' - older path-style URLs to access a bucket.
s3_request4_no_update(Config, Method, Bucket, Path, Subresource, Params, Body,
                      Headers) ->
    ContentType = proplists:get_value("content-type", Headers, ""),
    FParams = [Param || {_, Value} = Param <- Params, Value =/= undefined],
    FHeaders = [Header || {_, Val} = Header <- Headers, Val =/= undefined],

    QueryParams = case Subresource of
        "" ->
            FParams;
        _ ->
            [{Subresource, ""} | FParams]
    end,

    S3Host = Config#aws_config.s3_host,
    AccessMethod = case Config#aws_config.s3_bucket_access_method of
        auto ->
            case erlcloud_util:is_dns_compliant_name(Bucket) orelse
                 Bucket == [] of
                true -> vhost;
                _ -> path
            end;
        ManualMethod ->
            ManualMethod
    end,
    {EscapedPath, HostName} =  case AccessMethod of
        vhost ->
            %% Add bucket name to the front of hostname,
            %% i.e. https://bucket.name.s3.amazonaws.com/<path>
            VHostPath = erlcloud_http:url_encode_loose(Path),
            VHostName = lists:flatten(
                [case Bucket of "" -> ""; _ -> [Bucket, $.] end,
                 S3Host]),
            {VHostPath, VHostName};
        path ->
            %% Add bucket name into a URL path
            %% i.e. https://s3.amazonaws.com/bucket/<path>
            PathStyleUrl = erlcloud_http:url_encode_loose(
                    lists:flatten(
                        [case Bucket of "" -> ""; _ -> ["/", Bucket] end,
                         Path])),
            {PathStyleUrl, S3Host}
    end,

    RequestHeaders = erlcloud_aws:sign_v4(
        Method, EscapedPath, Config,
        [{"host", HostName} | FHeaders ],
        Body,
        aws_region_from_host(S3Host),
        "s3", QueryParams),

    RequestURI = lists:flatten([
        Config#aws_config.s3_scheme,
        S3Host, port_spec(Config),
        EscapedPath,
        case Subresource of "" -> ""; _ -> [$?, Subresource] end,
        if
            FParams =:= [] -> "";
            Subresource =:= "" ->
              [$?, erlcloud_http:make_query_string(FParams, no_assignment)];
            true ->
              [$&, erlcloud_http:make_query_string(FParams, no_assignment)]
        end]),

    {RequestHeaders2, RequestBody} = case Method of
                                         M when M =:= get orelse M =:= head orelse M =:= delete ->
                                             {RequestHeaders, <<>>};
                                         _ ->
                                             Headers2 = case lists:keyfind("content-type", 1, RequestHeaders) of
                                                            false ->
                                                                [{"content-type", ContentType} | RequestHeaders];
                                                            _ ->
                                                                RequestHeaders
                                                        end,
                                             {Headers2, Body}
                                     end,
    Request = #aws_request{service = s3, uri = RequestURI, method = Method, request_headers = RequestHeaders2, request_body = RequestBody},
    Request2 = erlcloud_retry:request(Config, Request, fun s3_result_fun/1),
    erlcloud_aws:request_to_return(Request2).


s3_result_fun(#aws_request{response_type = ok} = Request) ->
    Request;
s3_result_fun(#aws_request{response_type = error,
                           error_type = aws,
                           response_status = Status} = Request) when
%% Retry conflicting operations 409,Conflict and 500s
%% including 503, SlowDown, Reduce your request rate.
      Status =:= 409; Status >= 500 ->
    Request#aws_request{should_retry = true};
s3_result_fun(#aws_request{response_type = error, error_type = aws} = Request) ->
    Request#aws_request{should_retry = false}.

default_config() -> erlcloud_aws:default_config().

port_spec(#aws_config{s3_port=80}) ->
    "";
port_spec(#aws_config{s3_port=Port}) ->
    [":", erlang:integer_to_list(Port)].

%% Extract region form s3 endpoint names.
%% http://docs.aws.amazon.com/general/latest/gr/rande.html#s3_region
aws_region_from_host(Host) ->
    case string:tokens(Host, ".") of
        %% s3.cn-north-1.amazonaws.com.cn
        ["s3", Value, _, _, _] ->
            Value;
        %% s3.eu-central-1.amazonaws.com
        ["s3", Value, _, _] ->
            Value;
        %% s3.amazonaws.com
        ["s3", _, _] ->
            "us-east-1";
        %% s3-external-1.amazonaws.com
        ["s3-external-1", _, _] ->
            "us-east-1";
        %% For example: s3-us-east-1.amazonaws.com
        [Value, _, _] ->
            %% Skip "s3-" prefix
            string:substr(Value, 4);
        _ ->
            "us-east-1"
    end.

%%
%% http://docs.aws.amazon.com/AmazonS3/latest/dev/VirtualHosting.html
%% http://docs.aws.amazon.com/AmazonS3/latest/dev/Redirects.html
%% http://docs.aws.amazon.com/AmazonS3/latest/dev/RESTAPI.html
%% Note: Redirects are sequentially handled '#aws_config.s3_follow_redirect_count' times.
%% This is needed for attempts to access a bucket in non-defaut region using
%% the path-style method. Such request is redirected to virtual-hosted bucket
%% endpointand then - to region specific one.
%% For example: trying to get acl of "bucket-frankfurt" in eu-central-1
%%  region using path-style access method.
%%
%%  The 1st request ("https://s3.amazonaws.com/bucket-frankfurt/?acl) is
%%  redirected to "bucket-frankfurt.s3.amazonaws.com" endpoint.
%%
%%  The 2nd ("https://s3.amazonaws.com/?acl" with
%%  {"host","bucket-frankfurt.s3.amazonaws.com"} header) is redirected
%%  to "bucket-frankfurt.s3.eu-central-1.amazonaws.com".
%%
%%  And finally the 3rd request succeeds -
%%  ("https://s3.eu-central-1.amazonaws.com/?acl" with
%%   {"host","bucket-frankfurt.s3.eu-central-1.amazonaws.com""} header)
s3_follow_redirect(
    {error, {http_error, StatusCode, StatusLine, ErrBody, _ErrHeaders}} = Response,
    Config, Method, Bucket, Path, Subresource, Params, POSTData, Headers) ->
    case Config#aws_config.s3_follow_redirect of
        true ->
            s3_follow_redirect_impl(Response, Config, Method, Bucket, Path,
                Subresource, Params, POSTData, Headers,
                Config#aws_config.s3_follow_redirect_count);
        _ ->
            {error, {http_error, StatusCode, StatusLine, ErrBody}}
    end.

s3_follow_redirect_impl(
    {error, {http_error, StatusCode, StatusLine, ErrBody, _ErrHeaders}} = _Response,
    _Config, _Method, _Bucket, _Path, _Subresource, _Params, _POSTData, _Headers, 0) ->
    {error, {http_error, StatusCode, StatusLine, ErrBody}};

s3_follow_redirect_impl(Response, Config, Method, Bucket, Path,
        Subresource, Params, POSTData, Headers, RedirectCount) ->
    {S3RegionEndpoint, AccessMethod} = s3_endpoint_from_response(Config, Bucket, Response),
    case s3_request4_no_update(
        Config#aws_config{s3_host = S3RegionEndpoint, s3_bucket_access_method = AccessMethod},
        Method, Bucket, Path, Subresource, Params, POSTData, Headers)
    of
        {error, {http_error, RedirectCode, _, _, _}} = RedirectResponse
            when RedirectCode >= 301 andalso RedirectCode < 400 ->
                s3_follow_redirect_impl(RedirectResponse, Config, Method, Bucket, Path,
                    Subresource, Params, POSTData, Headers, RedirectCount - 1);
        {error, {http_error, ErrorCode, ErrorLine, ErrorBody, _ErrorHeaders}} ->
            {error, {http_error, ErrorCode, ErrorLine, ErrorBody}};
        FinalResponse ->
            FinalResponse
    end.

s3_endpoint_from_response(Config, Bucket,
        {error, {http_error, _Code, _Msg, ErrBody, ErrHeaders}} = _Response) ->
    case {proplists:get_value("x-amz-bucket-region", ErrHeaders),
          proplists:get_value("location", ErrHeaders)}
    of
        {undefined, undefined} ->
            %% Try to get redirect location from error message.
            XML = element(1,xmerl_scan:string(binary_to_list(ErrBody))),
            case erlcloud_xml:get_text("/Error/Endpoint", XML) of
                [] ->
                    {Config#aws_config.s3_host,
                     Config#aws_config.s3_bucket_access_method};
                Name ->
                    s3_endpoint_from_hostname(Name, Bucket)
            end;
        {undefined, RedirectUrl} ->
            %% Use "location" header value if there is no "x-amz-bucket-region" one.
            [_Scheme, HostName | _] =  string:tokens(RedirectUrl, "/"),
            s3_endpoint_from_hostname(HostName, Bucket);
        {BucketRegion, _} ->
            %% Use "x-amz-bucket-region" header value if present.
            {s3_endpoint_for_region(BucketRegion),
             Config#aws_config.s3_bucket_access_method}
    end.

%% If bucket name is a part of the input hostname then virtual hosted-style access
%% should be used to access this bucket and bucket name should be subtracted
%% from the hostname. Otherwise send requests to provided endpoint as is
%% using path-style method.
%% Examples:
%%      s3_endpoint_from_hostname(
%%              "test.bucket.s3.eu-central-1.amazonaws.com",
%%              "test.bucket") -> {"s3.eu-central-1.amazonaws.com", vhost}
%%      s3_endpoint_from_hostname(
%%              "s3.amazonaws.com",
%%              "test.bucket") -> {"s3.amazonaws.com", path}
s3_endpoint_from_hostname(HostName, Bucket) ->
    case lists:prefix(Bucket, HostName) of
        true ->
            {HostName -- lists:flatten([Bucket, $.]), vhost};
        false ->
            {HostName, path}
    end.

s3_endpoint_for_region(RegionName) ->
    case RegionName of
        "us-east-1" ->
            "s3-external-1.amazonaws.com";
	"cn-northwest-1" ->
	    "s3.cn-northwest-1.amazonaws.com.cn";
	"cn-north-1" ->
	    "s3.cn-north-1.amazonaws.com.cn";
        _ ->
            lists:flatten(["s3-", RegionName, ".amazonaws.com"])
    end.

encode_public_access_block(PublicAccessBlockConfiguration) ->
    [encode_public_access_block_param(Param)
        || {_Attrib, Value} = Param <- PublicAccessBlockConfiguration,
                                       Value =:= true orelse Value =:= false].

encode_public_access_block_param({block_public_acls, Value}) ->
    {'BlockPublicAcls', [atom_to_list(Value)]};
encode_public_access_block_param({ignore_public_acls, Value}) ->
    {'IgnorePublicAcls', [atom_to_list(Value)]};
encode_public_access_block_param({block_public_policy, Value}) ->
    {'BlockPublicPolicy', [atom_to_list(Value)]};
encode_public_access_block_param({restrict_public_buckets, Value}) ->
    {'RestrictPublicBuckets', [atom_to_list(Value)]};
encode_public_access_block_param(_) ->
    throw(unknown_public_access_block_param).
