%% -*- mode: erlang;erlang-indent-level: 4;indent-tabs-mode: nil -*-
-module(erlcloud_ec2_tests).
-include_lib("eunit/include/eunit.hrl").
-include("erlcloud.hrl").
-include("erlcloud_ec2.hrl").

%% Unit tests for ec2.
%% These tests work by using meck to mock erlcloud_httpc. There are two classes of test: input and output.
%%
%% Input tests verify that different function args produce the desired query parameters.
%% An input test list provides a list of funs and the parameters that are expected to result.
%%
%% Output tests verify that the http response produces the correct return from the fun.
%% An output test lists provides a list of response bodies and the expected return.

%% The _ec2_test macro provides line number annotation to a test, similar to _test, but doesn't wrap in a fun
-define(_ec2_test(T), {?LINE, T}).
%% The _f macro is a terse way to wrap code in a fun. Similar to _test but doesn't annotate with a line number
-define(_f(F), fun() -> F end).

%% helper funs
-export([
    generate_one_instance/1, generate_instances_response/3,
    generate_one_snapshot/1, generate_snapshots_response/3,
    generate_one_tag/1, generate_tags_response/3,
    generate_one_spot_price/1, generate_spot_price_history_response/3,
    generate_one_instance_status/1, generate_instance_status_response/3,
    generate_one_reserved_instance_offering/1, generate_reserved_instances_offerings_response/3,
    test_pagination/3
]).

%%%===================================================================
%%% Test entry points
%%%===================================================================

describe_test_() ->
    {foreach,
     fun start/0,
     fun stop/1,
     [
      fun describe_route_tables_tests/0,
      fun describe_vpcs_tests/1,
      fun describe_regions_input_tests/1,
      fun describe_regions_output_tests/1,
      fun describe_tags_input_tests/1,
      fun describe_tags_output_tests/1,
      fun request_spot_fleet_input_tests/1,
      fun request_spot_fleet_output_tests/1,
      fun cancel_spot_fleet_requests_input_tests/1,
      fun cancel_spot_fleet_requests_output_tests/1,
      fun modify_spot_fleet_request_input_tests/1,
      fun modify_spot_fleet_request_output_tests/1,
      fun describe_spot_fleet_request_input_tests/1,
      fun describe_spot_fleet_request_output_tests/1,
      fun describe_images_tests/1,
      fun describe_vpn_gateways_tests/1,
      fun describe_customer_gateways_tests/1,
      fun describe_vpn_connections_tests/1,
      fun create_flow_logs_input_tests/1,
      fun create_flow_logs_output_tests/1,
      fun delete_flow_logs_input_tests/1,
      fun delete_flow_logs_output_tests/1,
      fun describe_flow_logs_input_tests/1,
      fun describe_flow_logs_output_tests/1,
      fun describe_launch_template_versions_input_tests/1,
      fun describe_launch_template_versions_output_tests/1,
      fun describe_security_groups_input_tests/1,
      fun describe_security_groups_output_tests/1,
      fun describe_instances_output_tests/1
     ]}.

start() ->
    meck:new(erlcloud_httpc),
    ok.

stop(_) ->
    meck:unload(erlcloud_httpc).

%%%===================================================================
%%% Input test helpers
%%%===================================================================

%% common_params returns the list of parameters that are not validated by these tests.
%% They should be checked by lower level unit tests.
-spec common_params() -> [string()].
common_params() ->
    ["AWSAccessKeyId",
     "SignatureMethod",
     "SignatureVersion",
     "Timestamp",
     "Version",
     "Signature"].

%% validate_param checks that the query parameter is either a common param or expected
%% by the test case. If expected, returns expected with the param deleted to be used in
%% subsequent calls.
-type expected_param() :: {string(), string()}.
-spec validate_param(string(), [expected_param()]) -> [expected_param()].
validate_param(Param, Expected) ->
    {Key, Value} = case string:tokens(Param, "=") of
        [K, V] -> {K, V};
        [K] -> {K, ""}
    end,
    case lists:member(Key, common_params()) of
        true ->
            Expected;
        false ->
            Expected1 = lists:delete({Key, Value}, Expected),
            %?debugFmt("EXPECTED ~p~nEXPECTED1 ~p", [Expected, Expected1]),
            case length(Expected) - 1 =:= length(Expected1) of
                true -> ok;
                false ->
                    ?debugFmt("Parameter not expected: ~p", [{Key, Value}])
            end,
            ?assertEqual(length(Expected) - 1, length(Expected1)),
            Expected1
    end.

%% verifies that the parameters in the body match the expected parameters
-spec validate_params(binary(), [expected_param()]) -> ok.
validate_params(Body, Expected) ->
    ParamList = string:tokens(binary_to_list(Body), "&"),
    Remain = lists:foldl(fun validate_param/2, Expected, ParamList),
    ?assertEqual([], Remain).

%% returns the mock of the erlcloud_httpc function input tests expect to be called.
%% Validates the query body and responds with the provided response.
-spec input_expect(string(), [expected_param()]) -> fun().
input_expect(Response, Expected) ->
    fun(_Url, post, _Headers, Body, _Timeout, _Config) ->
            validate_params(Body, Expected),
            {ok, {{200, "OK"}, [], list_to_binary(Response)}}
    end.

%% input_test converts an input_test specifier into an eunit test generator
-type input_test_spec() :: {pos_integer(), {fun(), [expected_param()]} | {string(), fun(), [expected_param()]}}.
-spec input_test(string(), input_test_spec()) -> tuple().
input_test(Response, {Line, {Description, Fun, Params}}) when
      is_list(Description) ->
    {Description,
     {Line,
      fun() ->
              meck:expect(erlcloud_httpc, request, input_expect(Response, Params)),
              %% Configure to make sure there is a key. Would like to do this in start, but
              %% that isn't called in the same process
              erlcloud_ec2:configure(string:copies("A", 20), string:copies("a", 40)),
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
              erlcloud_ec2:configure(string:copies("A", 20), string:copies("a", 40)),
              Actual = Fun(),
              ?assertEqual(Result, Actual)
      end}}.
%% output_test(Fun, {Line, {Response, Result}}) ->
%%     output_test(Fun, {Line, {"", Response, Result}}).

%% output_tests converts a list of output_test specifiers into an eunit test generator
-spec output_tests(fun(), [output_test_spec()]) -> [term()].
output_tests(Fun, Tests) ->
    [output_test(Fun, Test) || Test <- Tests].


%%%===================================================================
%%% Actual test specifiers
%%%===================================================================

describe_vpcs_tests(_) ->
    Tests = [
        ?_ec2_test({
            "Describe all the vpcs",
            "<DescribeVpcsResponse xmlns=\"http://ec2.amazonaws.com/doc/2016-11-15/\">
                <requestId>9a0571b9-6e91-47e7-b75f-785125322853</requestId>
                <vpcSet>
                    <item>
                        <vpcId>vpc-00000000000000001</vpcId>
                        <ownerId>000000000001</ownerId>
                        <state>available</state>
                        <cidrBlock>10.0.0.0/16</cidrBlock>
                        <dhcpOptionsId>dopt-00000001</dhcpOptionsId>
                        <cidrBlockAssociationSet>
                            <item>
                                <cidrBlock>10.0.0.0/16</cidrBlock>
                                <associationId>vpc-cidr-assoc-00000000000000001</associationId>
                                <cidrBlockState>
                                    <state>associated</state>
                                </cidrBlockState>
                            </item>
                            <item>
                                <cidrBlock>10.1.0.0/16</cidrBlock>
                                <associationId>vpc-cidr-assoc-00000000000000002</associationId>
                                <cidrBlockState>
                                    <state>test state</state>
                                    <statusMessage>test status message</statusMessage>
                                </cidrBlockState>
                            </item>
                        </cidrBlockAssociationSet>
                        <tagSet>
                            <item>
                                <key>Key</key>
                                <value>Value</value>
                            </item>
                        </tagSet>
                        <instanceTenancy>default</instanceTenancy>
                        <isDefault>false</isDefault>
                    </item>
                </vpcSet>
            </DescribeVpcsResponse>",
            {ok, [
                [
                    {vpc_id, "vpc-00000000000000001"},
                    {state, "available"},
                    {cidr_block, "10.0.0.0/16"},
                    {dhcp_options_id, "dopt-00000001"},
                    {instance_tenancy, "default"},
                    {is_default, false},
                    {cidr_block_association_set, [
                        [
                           {cidr_block, "10.0.0.0/16"},
                           {association_id, "vpc-cidr-assoc-00000000000000001"},
                           {cidr_block_state, [{state, "associated"}]}
                        ],
                        [
                           {cidr_block, "10.1.0.0/16"},
                           {association_id, "vpc-cidr-assoc-00000000000000002"},
                           {cidr_block_state, [{state, "test state"}, {status_message, "test status message"}]}
                        ]
                    ]},
                    {tag_set, [
                        [{key, "Key"}, {value, "Value"}]
                    ]}
                ]
            ]}
        })
    ],
    output_tests(?_f(erlcloud_ec2:describe_vpcs()), Tests).

describe_regions_input_tests(_) ->
    Tests =
        [?_ec2_test(
            {"This example describes all regions.",
                ?_f(erlcloud_ec2:describe_regions([], [{"opt-in-status", "opted-in"}], erlcloud_aws:default_config())),
                [{"Action", "DescribeRegions"},
                 {"Filter.1.Name","opt-in-status"},
                 {"Filter.1.Value.1","opted-in"},
                 {"AllRegions","false"}]}),
        ?_ec2_test(
            {"This example describes all regions.",
                ?_f(erlcloud_ec2:describe_regions([], [], true, erlcloud_aws:default_config())),
                [{"Action", "DescribeRegions"},
                 {"AllRegions","true"}]})],
    Response = "
<DescribeRegionsResponse xmlns=\"http://ec2.amazonaws.com/doc/2012-12-01/\">
   <requestId>7a62c49f-347e-4fc4-9331-6e8eEXAMPLE</requestId>
   <tagSet/>
</DescribeRegionsResponse>",
    input_tests(Response, Tests).

describe_regions_output_tests(_) ->
    Tests = [
        ?_ec2_test({
            "Describe all the regions",
            "<DescribeRegionsResponse xmlns=\"http://ec2.amazonaws.com/doc/2016-11-15/\">
               <requestId>59dbff89-35bd-4eac-99ed-be587EXAMPLE</requestId>
               <regionInfo>
                  <item>
                     <regionName>af-south-1</regionName>
                     <regionEndpoint>ec2.af-south-1.amazonaws.com</regionEndpoint>
                     <optInStatus>opted-in</optInStatus>
                  </item>
                  <item>
                     <regionName>ap-northeast-3</regionName>
                     <regionEndpoint>ec2.ap-northeast-3.amazonaws.com</regionEndpoint>
                     <optInStatus>opted-in</optInStatus>
                  </item>
               </regionInfo>
            </DescribeRegionsResponse>",
            {ok, [
              [
                {region_name,"af-south-1"},
                {region_endpoint,"ec2.af-south-1.amazonaws.com"},
                {opt_in_status,"opted-in"}
              ],
              [
                {region_name,"ap-northeast-3"},
                {region_endpoint,"ec2.ap-northeast-3.amazonaws.com"},
                {opt_in_status,"opted-in"}
              ]
            ]}
        })
    ],
    output_tests(?_f(erlcloud_ec2:describe_regions([], [{"opt-in-status", "opted-in"}], erlcloud_aws:default_config())), Tests).

%% DescribeTags test based on the API examples:
%% http://docs.aws.amazon.com/AWSEC2/latest/APIReference/ApiReference-query-DescribeTags.html
describe_tags_input_tests(_) ->
    Tests =
        [?_ec2_test(
            {"This example describes all the tags in your account.",
             ?_f(erlcloud_ec2:describe_tags()),
             [{"Action", "DescribeTags"}]}),
         ?_ec2_test(
            {"This example describes only the tags for the AMI with ID ami-1a2b3c4d.",
             ?_f(erlcloud_ec2:describe_tags([{resource_id, ["ami-1a2b3c4d"]}])),
             [{"Action", "DescribeTags"},
              {"Filter.1.Name", "resource-id"},
              {"Filter.1.Value.1", "ami-1a2b3c4d"}]}),
         ?_ec2_test(
            {"This example describes the tags for all your instances.",
             ?_f(erlcloud_ec2:describe_tags([{resource_type, ["instance"]}])),
             [{"Action", "DescribeTags"},
              {"Filter.1.Name", "resource-type"},
              {"Filter.1.Value.1", "instance"}]}),
         ?_ec2_test(
            {"This example describes the tags for all your instances tagged with the key webserver.",
             ?_f(erlcloud_ec2:describe_tags([{key, ["webserver"]}])),
             [{"Action", "DescribeTags"},
              {"Filter.1.Name", "key"},
              {"Filter.1.Value.1", "webserver"}]}),
         ?_ec2_test(
            {"This example describes the tags for all your instances tagged with either stack=Test or stack=Production.",
             ?_f(erlcloud_ec2:describe_tags([{resource_type, ["instance"]}, {key, ["stack"]}, {value, ["Test", "Production"]}])),
             [{"Action", "DescribeTags"},
              {"Filter.1.Name", "resource-type"},
              {"Filter.1.Value.1", "instance"},
              {"Filter.2.Name", "key"},
              {"Filter.2.Value.1", "stack"},
              {"Filter.3.Name", "value"},
              {"Filter.3.Value.1", "Test"},
              {"Filter.3.Value.2", "Production"}]}),
         ?_ec2_test(
            {"This example describes the tags for all your instances tagged with Purpose=[empty string].",
             ?_f(erlcloud_ec2:describe_tags([{resource_type, ["instance"]}, {key, ["Purpose"]}, {value, [""]}])),
             [{"Action", "DescribeTags"},
              {"Filter.1.Name", "resource-type"},
              {"Filter.1.Value.1", "instance"},
              {"Filter.2.Name", "key"},
              {"Filter.2.Value.1", "Purpose"},
              {"Filter.3.Name", "value"},
              {"Filter.3.Value.1", ""}]})],

    Response = "
<DescribeTagsResponse xmlns=\"http://ec2.amazonaws.com/doc/2012-12-01/\">
   <requestId>7a62c49f-347e-4fc4-9331-6e8eEXAMPLE</requestId>
   <tagSet/>
</DescribeTagsResponse>",
    input_tests(Response, Tests).

describe_tags_output_tests(_) ->
    Tests =
        [?_ec2_test(
            {"This example describes all the tags in your account.", "
<DescribeTagsResponse xmlns=\"http://ec2.amazonaws.com/doc/2012-12-01/\">
   <requestId>7a62c49f-347e-4fc4-9331-6e8eEXAMPLE</requestId>
   <tagSet>
      <item>
         <resourceId>ami-1a2b3c4d</resourceId>
         <resourceType>image</resourceType>
         <key>webserver</key>
         <value/>
      </item>
       <item>
         <resourceId>ami-1a2b3c4d</resourceId>
         <resourceType>image</resourceType>
         <key>stack</key>
         <value>Production</value>
      </item>
      <item>
         <resourceId>i-5f4e3d2a</resourceId>
         <resourceType>instance</resourceType>
         <key>webserver</key>
         <value/>
      </item>
       <item>
         <resourceId>i-5f4e3d2a</resourceId>
         <resourceType>instance</resourceType>
         <key>stack</key>
         <value>Production</value>
      </item>
      <item>
         <resourceId>i-12345678</resourceId>
         <resourceType>instance</resourceType>
         <key>database_server</key>
         <value/>
      </item>
       <item>
         <resourceId>i-12345678</resourceId>
         <resourceType>instance</resourceType>
         <key>stack</key>
         <value>Test</value>
      </item>
    </tagSet>
</DescribeTagsResponse>",
             {ok, [#ec2_tag{resource_id="ami-1a2b3c4d", resource_type="image", key="webserver", value=""},
                   #ec2_tag{resource_id="ami-1a2b3c4d", resource_type="image", key="stack", value="Production"},
                   #ec2_tag{resource_id="i-5f4e3d2a", resource_type="instance", key="webserver", value=""},
                   #ec2_tag{resource_id="i-5f4e3d2a", resource_type="instance", key="stack", value="Production"},
                   #ec2_tag{resource_id="i-12345678", resource_type="instance", key="database_server", value=""},
                   #ec2_tag{resource_id="i-12345678", resource_type="instance", key="stack", value="Test"}]}}),
         ?_ec2_test(
            {"This example describes only the tags for the AMI with ID ami-1a2b3c4d.", "
<DescribeTagsResponse xmlns=\"http://ec2.amazonaws.com/doc/2012-12-01/\">
   <requestId>7a62c49f-347e-4fc4-9331-6e8eEXAMPLE</requestId>
   <tagSet>
      <item>
         <resourceId>ami-1a2b3c4d</resourceId>
         <resourceType>image</resourceType>
         <key>webserver</key>
         <value/>
      </item>
      <item>
         <resourceId>ami-1a2b3c4d</resourceId>
         <resourceType>image</resourceType>
         <key>stack</key>
         <value>Production</value>
      </item>
    </tagSet>
</DescribeTagsResponse>",
             {ok, [#ec2_tag{resource_id="ami-1a2b3c4d", resource_type="image", key="webserver", value=""},
                   #ec2_tag{resource_id="ami-1a2b3c4d", resource_type="image", key="stack", value="Production"}]}})],

    %% Remaining AWS API examples return subsets of the same data
    output_tests(?_f(erlcloud_ec2:describe_tags()), Tests).

describe_vpn_gateways_tests(_) ->
    Tests = 
        [?_ec2_test(
            {"This example describes VPN gateways.", "
<DescribeVpnGatewaysResponse xmlns=\"http://ec2.amazonaws.com/doc/2015-04-15/\">
  <requestId>7a62c49f-347e-4fc4-9331-6e8eEXAMPLE</requestId>
  <vpnGatewaySet>   
    <item>
      <vpnGatewayId>vgw-8db04f81</vpnGatewayId>
      <state>available</state>
      <type>ipsec.1</type>
      <availabilityZone>us-east-1a</availabilityZone> 
      <attachments>
        <item>
          <vpcId>vpc-1a2b3c4d</vpcId>
          <state>attached</state>
        </item>
      </attachments>
      <tagSet/>
    </item>
    <item>
      <vpnGatewayId>vgw-8db04f82</vpnGatewayId>
      <state>available</state>
      <type>ipsec.1</type>
      <availabilityZone>us-east-1a</availabilityZone> 
      <attachments>
        <item>
          <vpcId>vpc-1a2b3c4d</vpcId>
          <state>attached</state>
        </item>
      </attachments>
      <tagSet/>
    </item>
  </vpnGatewaySet>
</DescribeVpnGatewaysResponse>",
             {ok, [[{vpn_gateway_id, "vgw-8db04f81"},
                    {vpn_gateway_type, "ipsec.1"},
                    {vpn_gateway_state, "available"},
                    {vpn_az, "us-east-1a"},
                    {vpc_attachment_set, [[{vpc_id, "vpc-1a2b3c4d"}, {state, "attached"}]]},
                    {tag_set, []}],
                   [{vpn_gateway_id, "vgw-8db04f82"},
                    {vpn_gateway_type, "ipsec.1"},
                    {vpn_gateway_state, "available"},
                    {vpn_az, "us-east-1a"},
                    {vpc_attachment_set, [[{vpc_id, "vpc-1a2b3c4d"}, {state, "attached"}]]},
                    {tag_set, []}]]}})],
    
    %% Remaining AWS API examples return subsets of the same data
    output_tests(?_f(erlcloud_ec2:describe_vpn_gateways()), Tests).

describe_customer_gateways_tests(_) ->
    Tests = 
        [?_ec2_test(
            {"This example describes customer gateways.", "
<DescribeCustomerGatewaysResponse xmlns=\"http://ec2.amazonaws.com/doc/2015-04-15/\">
  <requestId>7a62c49f-347e-4fc4-9331-6e8eEXAMPLE</requestId>
  <customerGatewaySet>
    <item>
       <customerGatewayId>cgw-b4dc3961</customerGatewayId>
       <state>available</state>
       <type>ipsec.1</type>
       <ipAddress>12.1.2.3</ipAddress> 
       <bgpAsn>65534</bgpAsn>   
       <tagSet/>
    </item>
    <item>
       <customerGatewayId>cgw-b4dc3962</customerGatewayId>
       <state>available</state>
       <type>ipsec.1</type>
       <ipAddress>12.1.2.3</ipAddress> 
       <bgpAsn>65534</bgpAsn>   
       <tagSet/>
    </item>
  </customerGatewaySet>
</DescribeCustomerGatewaysResponse>",
             {ok, [[{customer_gateway_id, "cgw-b4dc3961"},
                    {customer_gateway_state, "available"},
                    {customer_gateway_type, "ipsec.1"},
                    {customer_gateway_ip, "12.1.2.3"},
                    {customer_gateway_bgpasn, "65534"},
                    {tag_set, []}],
                   [{customer_gateway_id, "cgw-b4dc3962"},
                    {customer_gateway_state, "available"},
                    {customer_gateway_type, "ipsec.1"},
                    {customer_gateway_ip, "12.1.2.3"},
                    {customer_gateway_bgpasn, "65534"},
                    {tag_set, []}]]}})],
    
    %% Remaining AWS API examples return subsets of the same data
    output_tests(?_f(erlcloud_ec2:describe_customer_gateways()), Tests).

describe_vpn_connections_tests(_) ->
    Tests = 
        [?_ec2_test(
            {"This example describes VPN connections.", "
<DescribeVpnConnectionsResponse xmlns=\"http://ec2.amazonaws.com/doc/2015-04-15/\">
  <requestId>7a62c49f-347e-4fc4-9331-6e8eEXAMPLE</requestId>
  <vpnConnectionSet>
    <item>
      <vpnConnectionId>vpn-44a8938f</vpnConnectionId>
      <state>available</state>
      <customerGatewayConfiguration>config1</customerGatewayConfiguration>     
      <type>ipsec.1</type>
      <customerGatewayId>cgw-b4dc3961</customerGatewayId>
      <vpnGatewayId>vgw-8db04f81</vpnGatewayId>
      <tagSet/>
    </item>
    <item>
      <vpnConnectionId>vpn-54a8938f</vpnConnectionId>
      <state>available</state>
      <customerGatewayConfiguration>config2</customerGatewayConfiguration>     
      <type>ipsec.1</type>
      <customerGatewayId>cgw-b4dc3962</customerGatewayId>
      <vpnGatewayId>vgw-8db04f82</vpnGatewayId>
      <tagSet/>
    </item>
  </vpnConnectionSet>
</DescribeVpnConnectionsResponse>",
             {ok, [[{vpn_connection_id, "vpn-44a8938f"},
                    {vpn_connection_state, "available"},
                    {customer_gateway_configuration, "config1"},
                    {vpn_connection_type, "ipsec.1"},
                    {customer_gateway_id, "cgw-b4dc3961"},
                    {vpn_gateway_id, "vgw-8db04f81"},
                    {tag_set, []}],
                   [{vpn_connection_id, "vpn-54a8938f"},
                    {vpn_connection_state, "available"},
                    {customer_gateway_configuration, "config2"},
                    {vpn_connection_type, "ipsec.1"},
                    {customer_gateway_id, "cgw-b4dc3962"},
                    {vpn_gateway_id, "vgw-8db04f82"},
                    {tag_set, []}]]}})],
    
    %% Remaining AWS API examples return subsets of the same data
    output_tests(?_f(erlcloud_ec2:describe_vpn_connections()), Tests).

%% RequestSpotFleet test based on the API examples:
%% http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_RequestSpotFleet.html
request_spot_fleet_input_tests(_) ->
    Tests =
        [?_ec2_test(
            {"This example creates a Spot fleet request with 2 launch specifications.",
             ?_f(erlcloud_ec2:request_spot_fleet(
                #ec2_spot_fleet_request{
                  spot_fleet_request_config = #spot_fleet_request_config_spec {
                    iam_fleet_role = "arn:aws:iam::123456789011:role/spot-fleet-role",
                    spot_price = "0.0153",
                    target_capacity = 5,
                    launch_specification = [
                      #ec2_instance_spec {
                        image_id = "ami-1ecae776",
                        instance_type = "m4.large",
                        subnet_id = "subnet-1a2b3c4d"
                      },
                      #ec2_instance_spec {
                        image_id = "ami-1ecae776",
                        instance_type = "m4.medium",
                        subnet_id = "subnet-1a2b3c4d"
                      }
                    ]
                  }
                }
              )),
             [{"Action", "RequestSpotFleet"},
              {"SpotFleetRequestConfig.IamFleetRole", "arn%3Aaws%3Aiam%3A%3A123456789011%3Arole%2Fspot-fleet-role"},
              {"SpotFleetRequestConfig.SpotPrice", "0.0153"},
              {"SpotFleetRequestConfig.TargetCapacity", "5"},
              {"SpotFleetRequestConfig.LaunchSpecifications.1.ImageId", "ami-1ecae776"},
              {"SpotFleetRequestConfig.LaunchSpecifications.1.InstanceType", "m4.large"},
              {"SpotFleetRequestConfig.LaunchSpecifications.1.SubnetId", "subnet-1a2b3c4d"},
              {"SpotFleetRequestConfig.LaunchSpecifications.1.Monitoring.Enabled", "false"},
              {"SpotFleetRequestConfig.LaunchSpecifications.1.EbsOptimized", "false"},
              {"SpotFleetRequestConfig.LaunchSpecifications.1.SecurityGroup.1", "default"},
              {"SpotFleetRequestConfig.LaunchSpecifications.2.ImageId", "ami-1ecae776"},
              {"SpotFleetRequestConfig.LaunchSpecifications.2.InstanceType", "m4.medium"},
              {"SpotFleetRequestConfig.LaunchSpecifications.2.SubnetId", "subnet-1a2b3c4d"},
              {"SpotFleetRequestConfig.LaunchSpecifications.2.Monitoring.Enabled", "false"},
              {"SpotFleetRequestConfig.LaunchSpecifications.2.EbsOptimized", "false"},
              {"SpotFleetRequestConfig.LaunchSpecifications.2.SecurityGroup.1", "default"}
             ]})],

    Response = "
<RequestSpotFleetResponse xmlns=\"http://ec2.amazonaws.com/doc/2015-10-01/\">
    <requestId>60262cc5-2bd4-4c8d-98ed-example</requestId>
    <spotFleetRequestId>sfr-123f8fc2-cb31-425e-abcd-example2710</spotFleetRequestId>
</RequestSpotFleetResponse>",
    input_tests(Response, Tests).

request_spot_fleet_output_tests(_) ->
    Tests =
        [?_ec2_test(
            {"This example creates a Spot fleet request with 2 launch specifications.", "
<RequestSpotFleetResponse xmlns=\"http://ec2.amazonaws.com/doc/2015-10-01/\">
    <requestId>60262cc5-2bd4-4c8d-98ed-example</requestId>
    <spotFleetRequestId>sfr-123f8fc2-cb31-425e-abcd-example2710</spotFleetRequestId>
</RequestSpotFleetResponse>",
             {ok, "sfr-123f8fc2-cb31-425e-abcd-example2710"}})],

    output_tests(?_f(erlcloud_ec2:request_spot_fleet(
                #ec2_spot_fleet_request{
                  spot_fleet_request_config = #spot_fleet_request_config_spec {
                    iam_fleet_role = "arn:aws:iam::123456789011:role/spot-fleet-role",
                    spot_price = "0.0153",
                    target_capacity = 5,
                    launch_specification = [
                      #ec2_instance_spec {
                        image_id = "ami-1ecae776",
                        instance_type = "m4.large",
                        subnet_id = "subnet-1a2b3c4d"
                      },
                      #ec2_instance_spec {
                        image_id = "ami-1ecae776",
                        instance_type = "m4.medium",
                        subnet_id = "subnet-1a2b3c4d"
                      }
                    ]
                  }
                }
              )), Tests).

%% CancelSpotFleetRequests test based on the API examples:
%% http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_CancelSpotFleetRequests.html
cancel_spot_fleet_requests_input_tests(_) ->
    Tests =
        [?_ec2_test(
            {"This example cancels Spot fleet request sfr-123f8fc2-cb31-425e-abcd-example2710 and terminates all instances that were launched by the request.",
             ?_f(erlcloud_ec2:cancel_spot_fleet_requests(["sfr-123f8fc2-cb31-425e-abcd-example2710"], true)),
             [{"Action", "CancelSpotFleetRequests"},
              {"SpotFleetRequestId.1", "sfr-123f8fc2-cb31-425e-abcd-example2710"},
              {"TerminateInstances", "true"}
             ]})],

    Response = "
<CancelSpotFleetRequestsResponse xmlns=\"http://ec2.amazonaws.com/doc/2015-10-01/\">
    <requestId>e12d2fe5-6503-4b4b-911c-example</requestId>
    <unsuccessfulFleetRequestSet/>
    <successfulFleetRequestSet>
        <item>
            <spotFleetRequestId>sfr-123f8fc2-cb31-425e-abcd-example2710</spotFleetRequestId>
            <currentSpotFleetRequestState>cancelled_terminating</currentSpotFleetRequestState>
            <previousSpotFleetRequestState>active</previousSpotFleetRequestState>
        </item>
    </successfulFleetRequestSet>
</CancelSpotFleetRequestsResponse>",
    input_tests(Response, Tests).


cancel_spot_fleet_requests_output_tests(_) ->
    Tests =
        [?_ec2_test(
            {"This example cancels Spot fleet request sfr-123f8fc2-cb31-425e-abcd-example2710 and terminates all instances that were launched by the request.", "
<CancelSpotFleetRequestsResponse xmlns=\"http://ec2.amazonaws.com/doc/2015-10-01/\">
    <requestId>e12d2fe5-6503-4b4b-911c-example</requestId>
    <unsuccessfulFleetRequestSet/>
    <successfulFleetRequestSet>
        <item>
            <spotFleetRequestId>sfr-123f8fc2-cb31-425e-abcd-example2710</spotFleetRequestId>
            <currentSpotFleetRequestState>cancelled_terminating</currentSpotFleetRequestState>
            <previousSpotFleetRequestState>active</previousSpotFleetRequestState>
        </item>
    </successfulFleetRequestSet>
</CancelSpotFleetRequestsResponse>",
               {ok, [
                      {unsuccessful_fleet_request_set,[]},
                      {successful_fleet_request_set,[
                        [
                          {spot_fleet_request_id,"sfr-123f8fc2-cb31-425e-abcd-example2710"},
                          {current_spot_fleet_request_state, "cancelled_terminating"},
                          {previous_spot_fleet_request_state, "active"}
                        ]
                      ]}
                    ]
                }
                })],
    output_tests(?_f(erlcloud_ec2:cancel_spot_fleet_requests(["sfr-123f8fc2-cb31-425e-abcd-example2710"], true)), Tests).

%% ModifySpotFleetRequest test based on the API examples:
%% http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_ModifySpotFleetRequest.html
modify_spot_fleet_request_input_tests(_) ->
    Tests =
        [?_ec2_test(
            {"This example modifies the fleet request capacity.",
             ?_f(erlcloud_ec2:modify_spot_fleet_request("sfr-123f8fc2-cb31-425e-abcd-example2710", 10, default)),
             [{"Action", "ModifySpotFleetRequest"},
              {"SpotFleetRequestId", "sfr-123f8fc2-cb31-425e-abcd-example2710"},
              {"ExcessCapacityTerminationPolicy", "Default"},
              {"TargetCapacity", "10"}
             ]})],

    Response = "
<ModifySpotFleetRequestResponse xmlns=\"http://ec2.amazonaws.com/doc/2015-10-01/\">
    <requestId>e12d2fe5-6503-4b4b-911c-example</requestId>
    <return>true</return>
</ModifySpotFleetRequestResponse>",
    input_tests(Response, Tests).

modify_spot_fleet_request_output_tests(_) ->
    Tests =
        [?_ec2_test(
            {"This example modifies the fleet request capacity.", "
<ModifySpotFleetRequestResponse xmlns=\"http://ec2.amazonaws.com/doc/2015-10-01/\">
    <requestId>e12d2fe5-6503-4b4b-911c-example</requestId>
    <return>true</return>
</ModifySpotFleetRequestResponse>", ok})],
    output_tests(?_f(erlcloud_ec2:modify_spot_fleet_request("sfr-123f8fc2-cb31-425e-abcd-example2710", 10, default)), Tests).

%% DescribeSpotFleetInstances test based on the API examples:
%% http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DescribeSpotFleetInstances.html
describe_spot_fleet_request_input_tests(_) ->
    Tests =
        [?_ec2_test(
            {"This example describes the spot fleet.",
             ?_f(erlcloud_ec2:describe_spot_fleet_instances("sfr-123f8fc2-cb31-425e-abcd-example2710")),
             [{"Action", "DescribeSpotFleetInstances"},
              {"SpotFleetRequestId", "sfr-123f8fc2-cb31-425e-abcd-example2710"}
             ]})],

    Response = "
<DescribeSpotFleetInstancesResponse xmlns=\"http://ec2.amazonaws.com/doc/2015-10-01/\">
    <requestId>cfb09950-45e2-472d-a6a9-example</requestId>
    <spotFleetRequestId>sfr-123f8fc2-cb31-425e-abcd-example2710</spotFleetRequestId>
    <activeInstanceSet>
        <item>
            <instanceId>i-1a1a1a1a</instanceId>
            <spotInstanceRequestId>sir-1a1a1a1a</spotInstanceRequestId>
            <instanceType>m3.medium</instanceType>
        </item>
        <item>
            <instanceId>i-2b2b2b2b</instanceId>
            <spotInstanceRequestId>sir-2b2b2b2b</spotInstanceRequestId>
            <instanceType>m3.medium</instanceType>
        </item>
    </activeInstanceSet>
</DescribeSpotFleetInstancesResponse>",
    input_tests(Response, Tests).

describe_spot_fleet_request_output_tests(_) ->
    Tests =
        [?_ec2_test(
            {"This example describes the spot fleet.", "
<DescribeSpotFleetInstancesResponse xmlns=\"http://ec2.amazonaws.com/doc/2015-10-01/\">
    <requestId>cfb09950-45e2-472d-a6a9-example</requestId>
    <spotFleetRequestId>sfr-123f8fc2-cb31-425e-abcd-example2710</spotFleetRequestId>
    <activeInstanceSet>
        <item>
            <instanceId>i-1a1a1a1a</instanceId>
            <spotInstanceRequestId>sir-1a1a1a1a</spotInstanceRequestId>
            <instanceType>m3.medium</instanceType>
        </item>
        <item>
            <instanceId>i-2b2b2b2b</instanceId>
            <spotInstanceRequestId>sir-2b2b2b2b</spotInstanceRequestId>
            <instanceType>m3.medium</instanceType>
        </item>
    </activeInstanceSet>
</DescribeSpotFleetInstancesResponse>",
      {ok,[
        {instances,[
          [
            {instance_id,"i-1a1a1a1a"},
            {spot_instance_request_id,"sir-1a1a1a1a"},
            {instance_type,"m3.medium"}
          ],
          [
            {instance_id,"i-2b2b2b2b"},
            {spot_instance_request_id,"sir-2b2b2b2b"},
            {instance_type,"m3.medium"}
          ]
        ]},
        {next_token, undefined}
      ]}

    })],
    output_tests(?_f(erlcloud_ec2:describe_spot_fleet_instances("sfr-123f8fc2-cb31-425e-abcd-example2710")), Tests).

describe_images_tests(_) ->
  Tests =
    [?_ec2_test(
      {"This example describes AMIs.", "
<DescribeImagesResponse xmlns=\"http://ec2.amazonaws.com/doc/2015-04-15/\">
   <requestId>59dbff89-35bd-4eac-99ed-be587EXAMPLE</requestId>
   <imagesSet>
      <item>
         <imageId>ami-1a2b3c4d</imageId>
         <kernelId/>
         <ramdiskId/>
         <imageLocation>ec2-public-windows-images/Server2003r2-x86_64-Win-v1.07.manifest.xml</imageLocation>
         <imageState>available</imageState>
         <imageOwnerId>123456789012</imageOwnerId>
         <isPublic>true</isPublic>
         <architecture>x86_64</architecture>
         <imageType>machine</imageType>
         <platform>windows</platform>
         <imageOwnerAlias>amazon</imageOwnerAlias>
         <rootDeviceName>/dev/sda1</rootDeviceName>
         <rootDeviceType>instance-store</rootDeviceType>
         <creationDate>2016-03-26T12:00:13Z</creationDate>
         <blockDeviceMapping/>
         <virtualizationType>hvm</virtualizationType>
         <tagSet>
                <item>
                    <key>Key</key>
                    <value>Value</value>
                </item>
         </tagSet>
         <hypervisor>xen</hypervisor>
      </item>
   </imagesSet>
</DescribeImagesResponse>",
        {ok, [[ {image_id, "ami-1a2b3c4d"},
          {image_location, "ec2-public-windows-images/Server2003r2-x86_64-Win-v1.07.manifest.xml"},
          {image_state, "available"},
          {image_owner_id, "123456789012"},
          {is_public, true},
          {architecture, "x86_64"},
          {image_type, "machine"},
          {kernel_id, []},
          {ramdisk_id, []},
          {image_owner_alias, "amazon"},
          {name, []},
          {description, []},
          {root_device_type, "instance-store"},
          {root_device_name, "/dev/sda1"},
          {creation_date, {{2016,3,26},{12,0,13}}},
          {platform, "windows"},
          {block_device_mapping, []},
          {product_codes, []},
          {tag_set, [[{key,"Key"},{value, "Value"}]]}
        ]]}})],

  %% Remaining AWS API examples return subsets of the same data
  output_tests(?_f(erlcloud_ec2:describe_images()), Tests).

describe_account_attributes_test() ->
    XML = "<DescribeAccountAttributesResponse>
               <requestId>12345</requestId>
               <accountAttributeSet>
                   <item>
                       <attributeName>attribute123</attributeName>
                       <attributeValueSet>
                           <item>
                               <attributeValue>123</attributeValue>
                           </item>
                       </attributeValueSet>
                   </item>
                   <item>
                       <attributeName>attribute456</attributeName>
                       <attributeValueSet>
                           <item>
                               <attributeValue>456</attributeValue>
                           </item>
                       </attributeValueSet>
                   </item>
                   <item>
                       <attributeName>attribute789</attributeName>
                       <attributeValueSet>
                           <item>
                               <attributeValue>789</attributeValue>
                           </item>
                       </attributeValueSet>
                   </item>
               </accountAttributeSet>
           </DescribeAccountAttributesResponse>",
    XMERL = {ok, element(1, xmerl_scan:string(XML))},
    ExpectedResult =
        {ok,[
                [{attribute_name,"attribute123"},
                    {attribute_value_set,[[{attribute_value,"123"}]]}],
                [{attribute_name,"attribute456"},
                    {attribute_value_set,[[{attribute_value,"456"}]]}],
                [{attribute_name,"attribute789"},
                    {attribute_value_set,[[{attribute_value,"789"}]]}]
            ]},
    meck:new(erlcloud_aws, [passthrough]),
    meck:expect(erlcloud_aws, aws_request_xml4,
        fun(_,_,_,_,_,_,_,_) ->
            XMERL
        end),
    Result = erlcloud_ec2:describe_account_attributes(),
    meck:unload(erlcloud_aws),
    ?assertEqual(ExpectedResult, Result).

describe_route_tables_tests() ->
    XML = "<DescribeRouteTablesResponse xmlns=\"http://ec2.amazonaws.com/doc/2016-11-15/\">
    <requestId>03c84dd4-bc36-48aa-8ac3-1d1fbaec96b5</requestId>
    <routeTableSet>
        <item>
            <routeTableId>rtb-0b70ded185be2a2e4</routeTableId>
            <vpcId>vpc-012ff464df6bbf762</vpcId>
            <ownerId>352283894008</ownerId>
            <routeSet>
                <item>
                    <destinationCidrBlock>10.0.0.0/26</destinationCidrBlock>
                    <gatewayId>local</gatewayId>
                    <state>active</state>
                    <origin>CreateRouteTable</origin>
                </item>
                <item>
                    <destinationCidrBlock>0.0.0.0/8</destinationCidrBlock>
                    <natGatewayId>nat-06e45944bb42d3ba2</natGatewayId>
                    <state>active</state>
                    <origin>CreateRoute</origin>
                </item>
                <item>
                    <destinationCidrBlock>0.0.0.0/0</destinationCidrBlock>
                    <gatewayId>vgw-09fea3ed190b9ea1e</gatewayId>
                    <state>active</state>
                    <origin>CreateRoute</origin>
                </item>
                <item>
                    <destinationIpv6CidrBlock>::/64</destinationIpv6CidrBlock>
                    <gatewayId>igw-1456db71</gatewayId>
                    <state>active</state>
                    <origin>CreateRoute</origin>
                </item>
            </routeSet>
            <associationSet>
                <item>
                    <routeTableAssociationId>rtbassoc-123</routeTableAssociationId>
                    <routeTableId>rtb-567</routeTableId>
                    <subnetId>subnet-0bdf348a667f86262</subnetId>
                    <main>false</main>
                    <associationState>
                        <state>associated</state>
                    </associationState>
                </item>
                <item>
                    <routeTableAssociationId>rtbassoc-789</routeTableAssociationId>
                    <routeTableId>rtb-345</routeTableId>
                    <main>true</main>
                    <associationState>
                        <state>associated</state>
                    </associationState>
                </item>
            </associationSet>
            <propagatingVgwSet/>
            <tagSet>
                <item>
                    <key>Name</key>
                    <value>PublicRT</value>
                </item>
            </tagSet>
        </item>
    </routeTableSet>
</DescribeRouteTablesResponse>",
    XMERL = {ok, element(1, xmerl_scan:string(XML))},
    ExpectedResult =
        {ok,[[{route_table_id,"rtb-0b70ded185be2a2e4"},
            {vpc_id,"vpc-012ff464df6bbf762"},
            {route_set,
                [[{destination_cidr_block,"10.0.0.0/26"},
                    {destination_ipv6_cidr_block,[]},
                    {gateway_id,"local"},
                    {nat_gateway_id,[]},
                    {instance_id,[]},
                    {vpc_peering_conn_id,[]},
                    {network_interface_id,[]},
                    {state,"active"},
                    {origin,"CreateRouteTable"}],
                    [{destination_cidr_block,"0.0.0.0/8"},
                        {destination_ipv6_cidr_block,[]},
                        {gateway_id,[]},
                        {nat_gateway_id,"nat-06e45944bb42d3ba2"},
                        {instance_id,[]},
                        {vpc_peering_conn_id,[]},
                        {network_interface_id,[]},
                        {state,"active"},
                        {origin,"CreateRoute"}],
                    [{destination_cidr_block,"0.0.0.0/0"},
                        {destination_ipv6_cidr_block,[]},
                        {gateway_id,"vgw-09fea3ed190b9ea1e"},
                        {nat_gateway_id,[]},
                        {instance_id,[]},
                        {vpc_peering_conn_id,[]},
                        {network_interface_id,[]},
                        {state,"active"},
                        {origin,"CreateRoute"}],
                    [{destination_cidr_block,[]},
                    {destination_ipv6_cidr_block,"::/64"},
                    {gateway_id,"igw-1456db71"},
                    {nat_gateway_id,[]},
                    {instance_id,[]},
                    {vpc_peering_conn_id,[]},
                    {network_interface_id,[]},
                    {state,"active"},
                    {origin,"CreateRoute"}]]},
            {association_set,
                [[{route_table_association_id,"rtbassoc-123"},
                    {route_table_id,"rtb-567"},
                    {main,"false"},
                    {subnet_id,"subnet-0bdf348a667f86262"}],
                    [{route_table_association_id,"rtbassoc-789"},
                        {route_table_id,"rtb-345"},
                        {main,"true"},
                        {subnet_id,[]}]]},
            {tag_set,[[{key,"Name"},{value,"PublicRT"}]]}]]},
    meck:new(erlcloud_aws, [passthrough]),
    meck:expect(erlcloud_aws, aws_request_xml4,
        fun(_,_,_,_,_,_,_,_) ->
            XMERL
        end),
    Result = erlcloud_ec2:describe_route_tables(),
    meck:unload(erlcloud_aws),
    ?assertEqual(ExpectedResult, Result).
    
describe_nat_gateways_test() ->
    XML = "<DescribeNatGatewaysResponse>
               <requestId>bfed02c6-dae9-47c0-86a2-example</requestId>
               <natGatewaySet>
                   <item>
                       <createTime>2017-01-02T15:49:34.999Z</createTime>
                       <deleteTime>2017-01-02T15:49:34.999Z</deleteTime>
                       <failureCode>1234</failureCode>
                       <failureMessage>boom</failureMessage>
                       <natGatewayAddressSet>
                           <item>
                               <allocationId>allocid-123</allocationId>
                               <networkInterfaceId>ni-56789</networkInterfaceId>
                               <privateIp>10.0.0.0</privateIp>
                               <publicIp>123.12.123.12</publicIp>
                           </item>
                       </natGatewayAddressSet>
                       <natGatewayId>nat-04e77a5e9c34432f9</natGatewayId>
                       <state>available</state>
                       <subnetId>subnet-1a2a3a4a</subnetId>
                       <vpcId>vpc-4e20d42b</vpcId>
                   </item>
               </natGatewaySet>
           </DescribeNatGatewaysResponse>",
    XMERL = {ok, element(1, xmerl_scan:string(XML))},
    ExpectedResult =
        {ok,
            [
                [
                    {create_time, "2017-01-02T15:49:34.999Z"},
                    {delete_time, "2017-01-02T15:49:34.999Z"},
                    {failure_code, "1234"},
                    {failure_message, "boom"},
                    {nat_gateway_address_set,
                        [
                            [
                                {allocation_id, "allocid-123"},
                                {network_interface_id, "ni-56789"},
                                {private_ip, "10.0.0.0"},
                                {public_ip, "123.12.123.12"}
                            ]
                        ]
                    },
                    {nat_gateway_id, "nat-04e77a5e9c34432f9"},
                    {state, "available"},
                    {subnet_id, "subnet-1a2a3a4a"},
                    {vpc_id, "vpc-4e20d42b"}
                ]
            ]
        },
    meck:new(erlcloud_aws, [passthrough]),
    meck:expect(erlcloud_aws, aws_request_xml4,
        fun(_,_,_,_,_,_,_,_) ->
            XMERL
        end),
    Result = erlcloud_ec2:describe_nat_gateways(),
    meck:unload(erlcloud_aws),
    ?assertEqual(ExpectedResult, Result).

describe_vpc_peering_connections_test() ->
    XML = "<DescribeVpcPeeringConnectionsResponse>
       	       <requestId>lnwadt7-8adia7r-aadu8-EXAMPLE</requestId>
       	       <vpcPeeringConnectionSet>
                   <item>
                       <requesterVpcInfo>
                           <ownerId>777788889999</ownerId>
                           <vpcId>vpc-1a2b3c4d</vpcId>
                           <cidrBlock>172.31.0.0/16</cidrBlock>
                       </requesterVpcInfo>
       	               <expirationTime>2017.01.02 09:54:15</expirationTime>
       	               <tagSet>
                           <item>
       	                       <key>key1</key>
       	                       <value>value1</value>
       	                   </item>
                           <item>
       	                       <key>key2</key>
       	                       <value>value2</value>
       	                   </item>
       	                   <item>
       	                       <key>key3</key>
       	                       <value>value3</value>
       	                   </item>
       	               </tagSet>
       	               <vpcPeeringConnectionId>pcx-123abc69</vpcPeeringConnectionId>
       	           </item>
               </vpcPeeringConnectionSet>
           </DescribeVpcPeeringConnectionsResponse>",
    XMERL = {ok, element(1, xmerl_scan:string(XML))},
    ExpectedResult =
        {ok,
            [
                [
                    {expiration_time, "2017.01.02 09:54:15"},
                    {tag_set,
                        [
                            [
                                {key, "key1"},
                                {value, "value1"}
                            ],
                            [
                                {key, "key2"},
                                {value, "value2"}
                            ],
                            [
                                {key, "key3"},
                                {value, "value3"}
                            ]
                        ]
                    },
                    {vpc_peering_connection_id, "pcx-123abc69"},
                    {requester_vpc_info,
                        [
                            [
                                {cidr_block, "172.31.0.0/16"},
                                {owner_id, "777788889999"},
                                {vpc_id, "vpc-1a2b3c4d"}
                            ]
                        ]
                    }
                ]
            ]
        },
    meck:new(erlcloud_aws, [passthrough]),
    meck:expect(erlcloud_aws, aws_request_xml4,
        fun(_,_,_,_,_,_,_,_) ->
            XMERL
        end),
    Result = erlcloud_ec2:describe_vpc_peering_connections(),
    meck:unload(erlcloud_aws),
    ?assertEqual(ExpectedResult, Result).

create_flow_logs_input_tests(_) ->
    Tests = [
        ?_ec2_test({"This example creates flow log.",
             ?_f(erlcloud_ec2:create_flow_logs(
                    "TestLogGroup", network_interface, ["eni-aa22bb33", "eni-22aabb33"], reject,
                     "arn:aws:iam::123456789101:role/flowlogsrole")),
             [{"Action", "CreateFlowLogs"},
              {"LogGroupName", "TestLogGroup"},
              {"ResourceType", "NetworkInterface"},
              {"ResourceId.1", "eni-aa22bb33"},
              {"ResourceId.2", "eni-22aabb33"},
              {"TrafficType", "REJECT"},
              {"DeliverLogsPermissionArn", "arn%3Aaws%3Aiam%3A%3A123456789101%3Arole%2Fflowlogsrole"}]
        }),
        ?_ec2_test({"This example creates flow log with ClientToken.",
             ?_f(erlcloud_ec2:create_flow_logs(
                    "TestLogGroup", network_interface, ["eni-aa22bb33", "eni-22aabb33"], reject,
                     "arn:aws:iam::123456789101:role/flowlogsrole", "TestClientTokenValue")),
             [{"Action", "CreateFlowLogs"},
              {"LogGroupName", "TestLogGroup"},
              {"ResourceType", "NetworkInterface"},
              {"ResourceId.1", "eni-aa22bb33"},
              {"ResourceId.2", "eni-22aabb33"},
              {"TrafficType", "REJECT"},
              {"DeliverLogsPermissionArn", "arn%3Aaws%3Aiam%3A%3A123456789101%3Arole%2Fflowlogsrole"},
              {"ClientToken", "TestClientTokenValue"}]
        })
    ],
    Response = "
        <CreateFlowLogsResponse xmlns=\"http://ec2.amazonaws.com/doc/2016-11-15/\">
            <requestId>2d96dae3-504b-4fc4-bf50-266EXAMPLE</requestId>
            <unsuccessful/>
            <clientToken>L3rV9xpxjqioMR0mCYQFUV2PB0abfsU1WRAk</clientToken>
            <flowLogIdSet>
                <item>fl-1a2b3c4d</item>
            </flowLogIdSet>
        </CreateFlowLogsResponse>
    ",
    input_tests(Response, Tests).

create_flow_logs_output_tests(_) ->
    Tests = [
        ?_ec2_test(
            {"This example creates flow logs", "
            <CreateFlowLogsResponse xmlns=\"http://ec2.amazonaws.com/doc/2016-11-15/\">
                <requestId>2d96dae3-504b-4fc4-bf50-266EXAMPLE</requestId>
                <unsuccessful/>
                <clientToken>L3rV9xpxjqioMR0mCYQFUV2PB0abfsU1WRAk</clientToken>
                <flowLogIdSet>
                    <item>fl-1a2b3c4d</item>
                </flowLogIdSet>
            </CreateFlowLogsResponse>",
            {ok, [{flow_log_id_set, ["fl-1a2b3c4d"]},
                  {client_token, "L3rV9xpxjqioMR0mCYQFUV2PB0abfsU1WRAk"},
                  {unsuccessful,[[{resource_id,[]},
                     {error,[{code,[]},{message,[]}]}]]}]}}
        )
    ],
    output_tests(?_f(erlcloud_ec2:create_flow_logs(
                        "TestLogGroup", network_interface, ["eni-aa22bb33", "eni-22aabb33"], reject,
                        "arn:aws:iam::123456789101:role/flowlogsrole")), Tests).

delete_flow_logs_input_tests(_) ->
    Tests = [
        ?_ec2_test({"This example deletes flow logs.",
             ?_f(erlcloud_ec2:delete_flow_logs(["fl-ab12cd34", "fl-123abc45"])),
            [{"Action", "DeleteFlowLogs"},
             {"FlowLogId.1", "fl-ab12cd34"},
             {"FlowLogId.2", "fl-123abc45"}]
        })
    ],
    Response = "
        <DeleteFlowLogsResponse xmlns=\"http://ec2.amazonaws.com/doc/2016-11-15/\">
            <requestId>c5c4f51f-f4e9-42bc-8700-EXAMPLE</requestId>
            <unsuccessful/>
        </DeleteFlowLogsResponse>
    ",
    input_tests(Response, Tests).

delete_flow_logs_output_tests(_) ->
    Tests = [
        ?_ec2_test(
            {"This example deletes flow log", "
            <DeleteFlowLogsResponse xmlns=\"http://ec2.amazonaws.com/doc/2016-11-15/\">
                <requestId>c5c4f51f-f4e9-42bc-8700-EXAMPLE</requestId>
                <unsuccessful/>
            </DeleteFlowLogsResponse>",
            {ok, [{unsuccessful,[[{resource_id,[]},
                     {error,[{code,[]},{message,[]}]}]]}]}})
    ],
    output_tests(?_f(erlcloud_ec2:delete_flow_logs(["fl-ab12cd34"])), Tests).

describe_flow_logs_input_tests(_) ->
    Tests =
        [?_ec2_test(
            {"This example describes all flow logs in a region.",
             ?_f(erlcloud_ec2:describe_flow_logs()),
             [{"Action", "DescribeFlowLogs"}]}),
         ?_ec2_test({"This example describes fl-ab12cd34 flow log.",
             ?_f(erlcloud_ec2:describe_flow_logs(["fl-ab12cd34"], [])),
             [{"Action", "DescribeFlowLogs"},
              {"FlowLogId.1", "fl-ab12cd34"}]}),
         ?_ec2_test({"This example describes fl-ab12cd34 and fl-123abc45 flow logs.",
             ?_f(erlcloud_ec2:describe_flow_logs(["fl-ab12cd34", "fl-123abc45"], [])),
             [{"Action", "DescribeFlowLogs"},
              {"FlowLogId.1", "fl-ab12cd34"},
              {"FlowLogId.2", "fl-123abc45"}]}),
         ?_ec2_test({"This example retrieves 10 flow logs.",
             ?_f(erlcloud_ec2:describe_flow_logs([{'traffic-type', "ALL"}])),
             [{"Action", "DescribeFlowLogs"},
              {"Filter.1.Name", "traffic-type"},
              {"Filter.1.Value.1", "ALL"}]}),
         ?_ec2_test({"This example retrieves 10 flow logs using NextToken argument.",
             ?_f(erlcloud_ec2:describe_flow_logs(10, "eyJ2IjoiMSIsInMiOjEsImMiOiI3WmlqMWVFbEM4cHdzZnRlcHVlc3pCQWNSdlZGbFBMVWZaNzZkcEpCcmdQOExlSWVjUUdIQnlCTVJmODVWWlZ6N1JpLUVXbTJrYXpSMGVVU05IclZUM3RXd3hGY3UzQTZhSkhPR3pvMnJPN1htclpjYk40T2VIMUIifQ")),
             [{"Action", "DescribeFlowLogs"},
              {"MaxResults", "10"},
              {"NextToken", "eyJ2IjoiMSIsInMiOjEsImMiOiI3WmlqMWVFbEM4cHdzZnRlcHVlc3pCQWNSdlZGbFBMVWZaNzZkcEpCcmdQOExlSWVjUUdIQnlCTVJmODVWWlZ6N1JpLUVXbTJrYXpSMGVVU05IclZUM3RXd3hGY3UzQTZhSkhPR3pvMnJPN1htclpjYk40T2VIMUIifQ"}]})
        ],
    Response = "
        <DescribeFlowLogsResponse xmlns=\"http://ec2.amazonaws.com/doc/2016-11-15/\">
            <requestId>3cb46f23-099e-4bf0-891c-EXAMPLE</requestId>
            <flowLogSet>
                <item>
                    <deliverLogsErrorMessage>Access error</deliverLogsErrorMessage>
                    <resourceId>vpc-1a2b3c4d</resourceId>
                    <deliverLogsPermissionArn>arn:aws:iam::123456789101:role/flowlogsrole</deliverLogsPermissionArn>
                    <flowLogStatus>ACTIVE</flowLogStatus>
                    <creationTime>2015-05-19T08:48:59Z</creationTime>
                    <logGroupName>FlowLogsForSubnetA</logGroupName>
                    <trafficType>ALL</trafficType>
                    <flowLogId>fl-ab12cd34</flowLogId>
                </item>
                <item>
                    <resourceId>vpc-1122bbcc</resourceId>
                    <deliverLogsPermissionArn>arn:aws:iam::123456789101:role/flowlogsrole</deliverLogsPermissionArn>
                    <flowLogStatus>ACTIVE</flowLogStatus>
                    <creationTime>2015-05-19T10:42:32Z</creationTime>
                    <logGroupName>FlowLogsForSubnetB</logGroupName>
                    <trafficType>ALL</trafficType>
                    <flowLogId>fl-123abc45</flowLogId>
                </item>
            </flowLogSet>
        </DescribeFlowLogsResponse>
    ",
    input_tests(Response, Tests).

describe_flow_logs_output_tests(_) ->
    Tests =
        [?_ec2_test(
            {"This example descirbes all flow logs", "
                <DescribeFlowLogsResponse xmlns=\"http://ec2.amazonaws.com/doc/2016-11-15/\">
                    <requestId>3cb46f23-099e-4bf0-891c-EXAMPLE</requestId>
                    <flowLogSet>
                        <item>
                            <deliverLogsErrorMessage>Access error</deliverLogsErrorMessage>
                            <resourceId>vpc-1a2b3c4d</resourceId>
                            <deliverLogsPermissionArn>arn:aws:iam::123456789101:role/flowlogsrole</deliverLogsPermissionArn>
                            <flowLogStatus>ACTIVE</flowLogStatus>
                            <creationTime>2015-05-19T08:48:59Z</creationTime>
                            <logGroupName>FlowLogsForSubnetA</logGroupName>
                            <trafficType>ALL</trafficType>
                            <flowLogId>fl-ab12cd34</flowLogId>
                        </item>
                        <item>
                            <resourceId>vpc-1122bbcc</resourceId>
                            <deliverLogsPermissionArn>arn:aws:iam::123456789101:role/flowlogsrole</deliverLogsPermissionArn>
                            <flowLogStatus>ACTIVE</flowLogStatus>
                            <creationTime>2015-05-19T10:42:32Z</creationTime>
                            <logGroupName>FlowLogsForSubnetB</logGroupName>
                            <trafficType>ALL</trafficType>
                            <flowLogId>fl-123abc45</flowLogId>
                        </item>
                    </flowLogSet>
                </DescribeFlowLogsResponse>",
                {ok, [[{deliver_logs_error_message, "Access error"},
                      {resource_id,"vpc-1a2b3c4d"},
                      {deliver_logs_permission_arn,"arn:aws:iam::123456789101:role/flowlogsrole"},
                      {flow_log_status,"ACTIVE"},
                      {creation_time,{{2015,05,19},{8,48,59}}},
                      {log_group_name,"FlowLogsForSubnetA"},
                      {traffic_type,"ALL"},
                      {flow_log_id,"fl-ab12cd34"}],
                     [{deliver_logs_error_message,[]},
                      {resource_id,"vpc-1122bbcc"},
                      {deliver_logs_permission_arn,"arn:aws:iam::123456789101:role/flowlogsrole"},
                      {flow_log_status,"ACTIVE"},
                      {creation_time,{{2015,05,19},{10,42,32}}},
                      {log_group_name,"FlowLogsForSubnetB"},
                      {traffic_type,"ALL"},
                      {flow_log_id,"fl-123abc45"}]]}}
         )
    ],
    output_tests(?_f(erlcloud_ec2:describe_flow_logs()), Tests).

describe_instances_test_() ->
    Tests = [{30,6},{22,5},{3,7},{10,10},{0,10},{0,5},{0,1000}],
    {timeout, 60, fun () -> test_pagination(Tests, generate_instances_response, describe_instances, [], [[]]) end}
.

describe_instances_output_tests(_) ->
    Tests =
        [?_ec2_test(
            {"This example describes all instances", "
                <DescribeInstancesResponse xmlns=\"http://ec2.amazonaws.com/doc/2016-11-15/\">
                    <requestId>95bd274e-560d-46c8-82da-bf41da8f2caf</requestId>
                    <reservationSet>
                        <item>
                            <reservationId>r-000001</reservationId>
                            <ownerId>123456789012</ownerId>
                            <groupSet/>
                            <instancesSet>
                                <item>
                                    <instanceId>i-000001</instanceId>
                                    <imageId>ami-000001</imageId>
                                    <instanceState>
                                        <code>16</code>
                                        <name>running</name>
                                    </instanceState>
                                    <privateDnsName>ip-10-0-1-1.ec2.internal</privateDnsName>
                                    <dnsName/>
                                    <reason/>
                                    <keyName>key</keyName>
                                    <amiLaunchIndex>0</amiLaunchIndex>
                                    <productCodes/>
                                    <operator>
                                        <managed>false</managed>
                                    </operator>
                                    <instanceType>m3.medium</instanceType>
                                    <launchTime>2025-01-31T09:01:15.000Z</launchTime>
                                    <placement>
                                        <availabilityZone>us-east-1a</availabilityZone>
                                        <groupName/>
                                        <tenancy>default</tenancy>
                                    </placement>
                                    <monitoring>
                                        <state>disabled</state>
                                    </monitoring>
                                    <subnetId>subnet-00001</subnetId>
                                    <vpcId>vpc-00001</vpcId>
                                    <privateIpAddress>10.0.1.1</privateIpAddress>
                                    <ipAddress>12.1.2.3</ipAddress>
                                    <sourceDestCheck>true</sourceDestCheck>
                                    <groupSet>
                                        <item>
                                            <groupId>sg-00001</groupId>
                                            <groupName>security-group-01</groupName>
                                        </item>
                                    </groupSet>
                                    <architecture>x86_64</architecture>
                                    <rootDeviceType>ebs</rootDeviceType>
                                    <rootDeviceName>/dev/sda1</rootDeviceName>
                                    <blockDeviceMapping>
                                        <item>
                                            <deviceName>/dev/sda1</deviceName>
                                            <ebs>
                                                <volumeId>vol-00001</volumeId>
                                                <status>attached</status>
                                                <attachTime>2025-01-31T09:00:34.000Z</attachTime>
                                                <deleteOnTermination>true</deleteOnTermination>
                                            </ebs>
                                        </item>
                                    </blockDeviceMapping>
                                    <virtualizationType>hvm</virtualizationType>
                                    <clientToken/>
                                    <tagSet>
                                        <item>
                                            <key>Name</key>
                                            <value>test-instance</value>
                                        </item>
                                    </tagSet>
                                    <hypervisor>xen</hypervisor>
                                    <networkInterfaceSet>
                                        <item>
                                            <networkInterfaceId>eni-00001</networkInterfaceId>
                                            <subnetId>subnet-00001</subnetId>
                                            <vpcId>vpc-00001</vpcId>
                                            <description>Primary network interface</description>
                                            <ownerId>123456789012</ownerId>
                                            <status>in-use</status>
                                            <macAddress>02:bb:10:1a:1a:1a</macAddress>
                                            <privateIpAddress>10.0.1.1</privateIpAddress>
                                            <sourceDestCheck>true</sourceDestCheck>
                                            <groupSet>
                                                <item>
                                                    <groupId>sg-00001</groupId>
                                                    <groupName>security-group-01</groupName>
                                                </item>
                                            </groupSet>
                                            <attachment>
                                                <attachmentId>eni-attach-00001</attachmentId>
                                                <deviceIndex>0</deviceIndex>
                                                <status>attached</status>
                                                <attachTime>2025-01-31T09:00:34.000Z</attachTime>
                                                <deleteOnTermination>true</deleteOnTermination>
                                                <networkCardIndex>0</networkCardIndex>
                                            </attachment>
                                            <association>
                                                <publicIp>123.12.123.12</publicIp>
                                                <publicDnsName/>
                                                <ipOwnerId>amazon</ipOwnerId>
                                            </association>
                                            <privateIpAddressesSet>
                                                <item>
                                                    <privateIpAddress>10.0.1.1</privateIpAddress>
                                                    <primary>true</primary>
                                                    <association>
                                                        <publicIp>123.12.123.12</publicIp>
                                                        <publicDnsName/>
                                                        <ipOwnerId>amazon</ipOwnerId>
                                                    </association>
                                                </item>
                                            </privateIpAddressesSet>
                                            <ipv6AddressesSet/>
                                            <interfaceType>interface</interfaceType>
                                            <operator>
                                                <managed>false</managed>
                                            </operator>
                                        </item>
                                    </networkInterfaceSet>
                                    <ebsOptimized>false</ebsOptimized>
                                    <enaSupport>true</enaSupport>
                                    <cpuOptions>
                                        <coreCount>1</coreCount>
                                        <threadsPerCore>1</threadsPerCore>
                                    </cpuOptions>
                                    <capacityReservationSpecification>
                                        <capacityReservationPreference>open</capacityReservationPreference>
                                    </capacityReservationSpecification>
                                    <hibernationOptions>
                                        <configured>false</configured>
                                    </hibernationOptions>
                                    <enclaveOptions>
                                        <enabled>false</enabled>
                                    </enclaveOptions>
                                    <metadataOptions>
                                        <state>applied</state>
                                        <httpTokens>optional</httpTokens>
                                        <httpPutResponseHopLimit>1</httpPutResponseHopLimit>
                                        <httpEndpoint>enabled</httpEndpoint>
                                        <httpProtocolIpv6>disabled</httpProtocolIpv6>
                                        <instanceMetadataTags>disabled</instanceMetadataTags>
                                    </metadataOptions>
                                    <maintenanceOptions>
                                        <autoRecovery>default</autoRecovery>
                                        <rebootMigration>default</rebootMigration>
                                    </maintenanceOptions>
                                    <networkPerformanceOptions>
                                        <bandwidthWeighting>default</bandwidthWeighting>
                                    </networkPerformanceOptions>
                                    <platformDetails>Linux/UNIX</platformDetails>
                                    <usageOperation>RunInstances</usageOperation>
                                    <usageOperationUpdateTime>2025-01-31T09:00:34.000Z</usageOperationUpdateTime>
                                    <privateDnsNameOptions/>
                                </item>
                            </instancesSet>
                        </item>
                    </reservationSet>
                </DescribeInstancesResponse>
            ",
            {ok, [[
                {reservation_id, "r-000001"},
                {owner_id, "123456789012"},
                {instances_set, [[
                    {instance_id, "i-000001"},
                    {group_set, [[
                        {group_id, "sg-00001"},
                        {group_name, "security-group-01"}
                    ]]},
                    {image_id, "ami-000001"},
                    {instance_state, [{code, 16}, {name, "running"}]},
                    {private_dns_name, "ip-10-0-1-1.ec2.internal"},
                    {dns_name, []},
                    {reason, none},
                    {key_name, "key"},
                    {metadata_options, [[
                        {http_endpoint, "enabled"},
                        {http_protocol_ipv6, "disabled"},
                        {http_put_response_hop_limit, 1},
                        {http_tokens, "optional"},
                        {instance_metadata_tags, "disabled"},
                        {state, "applied"}
                    ]]},
                    {ami_launch_index, 0},
                    {product_codes, []},
                    {instance_type, "m3.medium"},
                    {launch_time, {{2025, 1, 31}, {9, 1, 15}}},
                    {platform, []},
                    {placement, [{availability_zone, "us-east-1a"}]},
                    {kernel_id, []},
                    {ramdisk_id, []},
                    {monitoring, [{enabled, false}, {state, "disabled"}]},
                    {subnet_id, "subnet-00001"},
                    {vpc_id, "vpc-00001"},
                    {private_ip_address, "10.0.1.1"},
                    {ip_address, "12.1.2.3"},
                    {state_reason, [{code, []}, {message, []}]},
                    {architecture, "x86_64"},
                    {root_device_type, "ebs"},
                    {root_device_name, "/dev/sda1"},
                    {block_device_mapping, [[
                        {device_name, "/dev/sda1"},
                        {volume_id, "vol-00001"},
                        {status, "attached"},
                        {attach_time, {{2025, 1, 31}, {9, 0, 34}}},
                        {delete_on_termination, true}
                    ]]},
                    {instance_lifecycle, none},
                    {spot_instance_request_id, none},
                    {iam_instance_profile, [{arn, []}, {id, []}]},
                    {tag_set, [[{key, "Name"}, {value, "test-instance"}]]},
                    {network_interface_set, [[
                        {network_interface_id, "eni-00001"},
                        {subnet_id, "subnet-00001"},
                        {vpc_id, "vpc-00001"},
                        {availability_zone, []},
                        {description, "Primary network interface"},
                        {owner_id, "123456789012"},
                        {requester_managed, false},
                        {status, "in-use"},
                        {mac_address, "02:bb:10:1a:1a:1a"},
                        {private_ip_address, "10.0.1.1"},
                        {source_dest_check, true},
                        {groups_set, [[
                            {group_id, "sg-00001"},
                            {group_name, "security-group-01"}
                        ]]},
                        {attachment, [
                            {attachment_id, "eni-attach-00001"},
                            {instance_id, []},
                            {instance_owner_id, []},
                            {device_index, "0"},
                            {status, "attached"},
                            {attach_time, {{2025, 1, 31}, {9, 0, 34}}},
                            {delete_on_termination, true}
                        ]},
                        {association, [
                            {public_ip, "123.12.123.12"},
                            {public_dns_name, []},
                            {ip_owner_id, "amazon"},
                            {allocation_id, []},
                            {association_id, []}
                        ]},
                        {tag_set, []},
                        {private_ip_addresses_set, [[
                            {private_ip_address, "10.0.1.1"},
                            {primary, true}
                        ]]}
                    ]]}
                ]]}
            ]]}}
        )
    ],
    output_tests(?_f(erlcloud_ec2:describe_instances()), Tests)
.

describe_instances_boundaries_test_() ->
    [
        ?_assertException(error, function_clause, erlcloud_ec2:describe_instances([], 4, undefined)),
        ?_assertException(error, function_clause, erlcloud_ec2:describe_instances([], 1001, undefined))
    ].

describe_snapshots_test_() ->
    Tests = [{30,6},{22,5},{3,7},{10,10},{0,10},{0,5},{0,1000}],
    {timeout, 60, fun () -> test_pagination(Tests, generate_snapshots_response, describe_snapshots, [], ["self", []]) end}
.

describe_snapshots_boundaries_test_() ->
    [
        ?_assertException(error, function_clause, erlcloud_ec2:describe_snapshots("self", [], 4, undefined)),
        ?_assertException(error, function_clause, erlcloud_ec2:describe_snapshots("self", [], 1001, undefined))
    ].

describe_tags_test_() ->
    Tests = [{30,6},{22,5},{3,7},{10,10},{0,10},{0,5},{0,1000}],
    {timeout, 60, fun () -> test_pagination(Tests, generate_tags_response, describe_tags, [], [[]]) end}
.

describe_tags_boundaries_test_() ->
    [
        ?_assertException(error, function_clause, erlcloud_ec2:describe_tags([], 4, undefined)),
        ?_assertException(error, function_clause, erlcloud_ec2:describe_tags([], 1001, undefined))
    ].
describe_spot_price_history_test_() ->
    Tests = [{30,6},{22,5},{3,7},{10,10},{0,10},{0,5},{0,1000}],
    {timeout, 60, fun () -> test_pagination(Tests, generate_spot_price_history_response, describe_spot_price_history, [], ["", "", [], ""]) end}
.

-dialyzer({nowarn_function, describe_spot_price_history_boundaries_test_/0}).
describe_spot_price_history_boundaries_test_() ->
    [
        ?_assertException(error, function_clause, erlcloud_ec2:describe_spot_price_history(["", "", [], ""], 4, undefined)),
        ?_assertException(error, function_clause, erlcloud_ec2:describe_spot_price_history(["", "", [], ""], 1001, undefined))
    ].

describe_instance_status_test_() ->
    Tests = [{30,6},{22,5},{3,7},{10,10},{0,10},{0,5},{0,1000}],
    {timeout, 60, fun () -> test_pagination(Tests, generate_instance_status_response, describe_instance_status, [[], []], [[], []]) end}
.

describe_instance_status_boundaries_test_() ->
    [
        ?_assertException(error, function_clause, erlcloud_ec2:describe_instance_status([], [], 4, undefined)),
        ?_assertException(error, function_clause, erlcloud_ec2:describe_instance_status([], [], 1001, undefined))
    ].

describe_reserved_instances_offerings_test_() ->
    Tests = [{30,6},{22,5},{3,7},{10,10},{0,10},{0,5},{0,1000}],
    {timeout, 60, fun () -> test_pagination(Tests, generate_reserved_instances_offerings_response, describe_reserved_instances_offerings, [], [[]]) end}
.

describe_reserved_instances_offerings_boundaries_test_() ->
    [
        ?_assertException(error, function_clause, erlcloud_ec2:describe_reserved_instances_offerings([], 4, undefined)),
        ?_assertException(error, function_clause, erlcloud_ec2:describe_reserved_instances_offerings([], 1001, undefined))
    ].

describe_launch_templates_test() ->
    XML = "<DescribeLaunchTemplatesResponse xmlns=\"http://ec2.amazonaws.com/doc/2016-11-15/\">
    <requestId>1afa6e44-eb38-4229-8db6-d5eaexample</requestId>
    <launchTemplates>
        <item>
            <createTime>2017-10-31T11:38:52.000Z</createTime>
            <createdBy>arn:aws:iam::123456789012:root</createdBy>
            <defaultVersionNumber>1</defaultVersionNumber>
            <latestVersionNumber>1</latestVersionNumber>
            <launchTemplateId>lt-0a20c965061f64abc</launchTemplateId>
            <launchTemplateName>MyLaunchTemplate</launchTemplateName>
        </item>
    </launchTemplates>
    </DescribeLaunchTemplatesResponse>",
    XMERL = {ok, element(1, xmerl_scan:string(XML))},
    ExpectedResult =
        {ok,
            [[
                {created_by,"arn:aws:iam::123456789012:root"},
                {create_time,{{2017,10,31},{11,38,52}}},
                {default_version_number,1},
                {launch_template_id,"lt-0a20c965061f64abc"},
                {launch_template_name,"MyLaunchTemplate"},
                {tag_set,[]}
            ]]
        },
    meck:new(erlcloud_aws, [passthrough]),
    meck:expect(erlcloud_aws, aws_request_xml4,
        fun(_,_,_,_,_,_,_,_) ->
            XMERL
        end),
    Result = erlcloud_ec2:describe_launch_templates(),
    meck:unload(erlcloud_aws),
    ?assertEqual(ExpectedResult, Result).

describe_launch_template_versions_input_tests(_) ->
    Tests = 
        [?_ec2_test({
            "This example describes a set of launch template versions for template with matching ID",
            ?_f(erlcloud_ec2:describe_launch_template_versions("lt-0a20c965061f64abc")),
            [{"Action", "DescribeLaunchTemplateVersions"},
             {"LaunchTemplateId", "lt-0a20c965061f64abc"}]}),
        ?_ec2_test({
            "This example describes a set of launch template versions for template with matching name",
            ?_f(erlcloud_ec2:describe_launch_template_versions(none, "Test-LT-foo", [])),
            [{"Action", "DescribeLaunchTemplateVersions"},
             {"LaunchTemplateName", "Test-LT-foo"}]}),
        ?_ec2_test({
            "This example describes launch template versions with matching version(s)",
            ?_f(erlcloud_ec2:describe_launch_template_versions("lt-0f1b5e0ff43b7f2ad", none, [{launch_template_version, ["1"]}])),
            [{"Action", "DescribeLaunchTemplateVersions"},
             {"LaunchTemplateId", "lt-0f1b5e0ff43b7f2ad"},
             {"LaunchTemplateVersion.1", "1"}]}),
        ?_ec2_test({
            "This example describes launch template versions with minimum version number",
            ?_f(erlcloud_ec2:describe_launch_template_versions("lt-0a20c965061f64abc", none, [{min_version, 1}])),
            [{"Action", "DescribeLaunchTemplateVersions"},
             {"LaunchTemplateId", "lt-0a20c965061f64abc"},
             {"MinVersion", "1"}]}),
        ?_ec2_test({
            "This example describes launch template versions with maximum version number",
            ?_f(erlcloud_ec2:describe_launch_template_versions("lt-0a20c965061f64abc", none, [{max_version, 10}])),
            [{"Action", "DescribeLaunchTemplateVersions"},
             {"LaunchTemplateId", "lt-0a20c965061f64abc"},
             {"MaxVersion", "10"}]}),
        ?_ec2_test({
            "This example describes launch template versions with max results count configured",
            ?_f(erlcloud_ec2:describe_launch_template_versions("lt-0a20c965061f64abc", none, [], none, 10, undefined)),
            [{"Action", "DescribeLaunchTemplateVersions"},
             {"LaunchTemplateId", "lt-0a20c965061f64abc"},
             {"MaxResults", "10"}]}),
        ?_ec2_test({
            "This example describes retrieval of subsequent launch template version result page",
            ?_f(erlcloud_ec2:describe_launch_template_versions("lt-0a20c965061f64abc", none, [], none, 10, "next-token")),
            [{"Action", "DescribeLaunchTemplateVersions"},
             {"LaunchTemplateId", "lt-0a20c965061f64abc"},
             {"NextToken", "next-token"},
             {"MaxResults", "10"}]}),
        ?_ec2_test({
            "This example describes launch template versions with max results count configured selected by template name",
            ?_f(erlcloud_ec2:describe_launch_template_versions(none, "SomeNameHere", [], none, 10, undefined)),
            [{"Action", "DescribeLaunchTemplateVersions"},
             {"LaunchTemplateName", "SomeNameHere"},
             {"MaxResults", "10"}]}),
        ?_ec2_test({
            "This example describes retrieval of subsequent launch template version result page selected by template name",
            ?_f(erlcloud_ec2:describe_launch_template_versions(none, "SomeNameHere", [], none, 10, "next-token")),
            [{"Action", "DescribeLaunchTemplateVersions"},
             {"LaunchTemplateName", "SomeNameHere"},
             {"NextToken", "next-token"},
             {"MaxResults", "10"}]})
        ],
    Response = "
    <DescribeLaunchTemplateVersionsResponse xmlns=\"http://ec2.amazonaws.com/doc/2016-11-15/\">
        <requestId>65cadec1-b364-4354-8ca8-4176dexample</requestId>
        <launchTemplateVersionSet>
            <item>
                <createTime>2017-10-31T11:38:52.000Z</createTime>
                <createdBy>arn:aws:iam::123456789012:root</createdBy>
                <defaultVersion>true</defaultVersion>
                <launchTemplateData>
                    <imageId>ami-8c1be5f6</imageId>
                    <instanceType>t2.micro</instanceType>
                </launchTemplateData>
                <launchTemplateId>lt-0a20c965061f64abc</launchTemplateId>
                <launchTemplateName>MyLaunchTemplate</launchTemplateName>
                <versionDescription>FirstVersion</versionDescription>
                <versionNumber>1</versionNumber>
            </item>
            <item>
                <createTime>2017-10-31T11:52:03.000Z</createTime>
                <createdBy>arn:aws:iam::123456789012:root</createdBy>
                <defaultVersion>false</defaultVersion>
                <launchTemplateData>
                    <imageId>ami-12345678</imageId>
                </launchTemplateData>
                <launchTemplateId>lt-0a20c965061f64abc</launchTemplateId>
                <launchTemplateName>MyLaunchTemplate</launchTemplateName>
                <versionDescription>AMIOnlyv1</versionDescription>
                <versionNumber>2</versionNumber>
            </item>
            <item>
                <createTime>2017-10-31T11:55:15.000Z</createTime>
                <createdBy>arn:aws:iam::123456789012:root</createdBy>
                <defaultVersion>false</defaultVersion>
                <launchTemplateData>
                    <imageId>ami-aabbccdd</imageId>
                </launchTemplateData>
                <launchTemplateId>lt-0a20c965061f64abc</launchTemplateId>
                <launchTemplateName>MyLaunchTemplate</launchTemplateName>
                <versionDescription>AMIOnlyv2</versionDescription>
                <versionNumber>3</versionNumber>
            </item>
        </launchTemplateVersionSet>
    </DescribeLaunchTemplateVersionsResponse>
    ",
    input_tests(Response, Tests).

describe_launch_template_versions_output_tests(_) ->
    Tests =
        [?_ec2_test(
            {"This example describes all launch template versions for given template",
            "<?xml version= \"1.0\" encoding= \"UTF-8\"?>
            <DescribeLaunchTemplateVersionsResponse xmlns= \"http://ec2.amazonaws.com/doc/2016-11-15/\">
                <requestId>c68f69e1-48fd-42c9-83cf-6b36cb07475b</requestId>
                <launchTemplateVersionSet>
                    <item>
                        <createTime>2022-10-21T08:51:54.000Z</createTime>
                        <createdBy>arn:aws:sts::123483894321:assumed-role/centralized-users/john.doe</createdBy>
                        <defaultVersion>true</defaultVersion>
                        <launchTemplateData>
                            <creditSpecification>
                                <cpuCredits>standard</cpuCredits>
                            </creditSpecification>
                            <cpuOptions>
                                <coreCount>1</coreCount>
                                <threadsPerCore>2</threadsPerCore>
                            </cpuOptions>
                            <disableApiStop>false</disableApiStop>
                            <disableApiTermination>false</disableApiTermination>
                            <ebsOptimized>true</ebsOptimized>
                            <hibernationOptions>
                                <configured>true</configured>
                            </hibernationOptions>
                            <iamInstanceProfile>
                                <arn>arn:aws:iam::123483894321:instance-profile/ecsInstanceRole</arn>
                            </iamInstanceProfile>
                            <imageId>ami-5934df24</imageId>
                            <instanceInitiatedShutdownBehavior>stop</instanceInitiatedShutdownBehavior>
                            <instanceType>c5.large</instanceType>
                            <maintenanceOptions>
                                <autoRecovery>default</autoRecovery>
                            </maintenanceOptions>
                            <metadataOptions>
                                <httpEndpoint>enabled</httpEndpoint>
                                <httpTokens>optional</httpTokens>
                            </metadataOptions>
                            <monitoring>
                                <enabled>true</enabled>
                            </monitoring>
                            <networkInterfaceSet>
                                <item>
                                    <deviceIndex>0</deviceIndex>
                                    <networkInterfaceId>eni-060ceeb735813d39d</networkInterfaceId>
                                </item>
                            </networkInterfaceSet>
                            <placement>
                                <tenancy>default</tenancy>
                            </placement>
                            <privateDnsNameOptions>
                                <enableResourceNameDnsARecord>true</enableResourceNameDnsARecord>
                                <hostnameType>ip-name</hostnameType>
                            </privateDnsNameOptions>
                            <tagSpecificationSet>
                                <item>
                                    <resourceType>instance</resourceType>
                                    <tagSet>
                                        <item>
                                            <key>tag1</key>
                                            <value>134274125</value>
                                        </item>
                                    </tagSet>
                                </item>
                                <item>
                                    <resourceType>volume</resourceType>
                                    <tagSet>
                                        <item>
                                            <key>tag1</key>
                                            <value>134274125</value>
                                        </item>
                                    </tagSet>
                                </item>
                            </tagSpecificationSet>
                        </launchTemplateData>
                        <launchTemplateId>lt-08ccaba0746110123</launchTemplateId>
                        <launchTemplateName>nb-ec-test-1</launchTemplateName>
                        <versionDescription>Test template foo</versionDescription>
                        <versionNumber>1</versionNumber>
                    </item>
                </launchTemplateVersionSet>
            </DescribeLaunchTemplateVersionsResponse>",
                {ok, [[{created_by, "arn:aws:sts::123483894321:assumed-role/centralized-users/john.doe"},
                       {create_time,{{2022,10,21},{8,51,54}}},
                       {default_version,true},
                       {launch_template_data,
                           [[{block_device_mapping_set,[]},
                             {capacity_reservation_specification,[]},
                             {cpu_options,
                                 [[{core_count,1},{threads_per_core,2}]]},
                             {credit_specification,[
                                 [{cpu_credits, "standard"}]]},
                             {disable_api_stop,false},
                             {disable_api_termination,false},
                             {ebs_optimized,true},
                             {elastic_gpu_specification_set,[]},
                             {elastic_inference_accelerator_set,[]},
                             {enclave_options,[{enabled,false}]},
                             {hibernation_options,[{configured,true}]},
                             {iam_instance_profile,
                                 [[{arn,
                                       "arn:aws:iam::123483894321:instance-profile/ecsInstanceRole"},
                                   {id,[]}]]},
                             {image_id,"ami-5934df24"},
                             {instance_initiated_shutdown_behavior,"stop"},
                             {instance_market_options,[]},
                             {instance_requirements,[]},
                             {instance_type,"c5.large"},
                             {kernel_id,[]},
                             {key_name,[]},
                             {license_set,[]},
                             {maintenance_options,
                                 [[{auto_recovery,"default"}]]},
                             {metadata_options,
                                 [[{http_endpoint,"enabled"},
                                   {http_protocol_ipv6,[]},
                                   {http_put_response_hop_limit,0},
                                   {http_tokens,"optional"},
                                   {instance_metadata_tags,[]},
                                   {state,[]}]]},
                             {monitoring,[{enabled,true}]},
                             {network_interface_set,
                                 [[{associate_carrier_ip_address,false},
                                   {associate_public_ip_address,false},
                                   {delete_on_termination,false},
                                   {description,[]},
                                   {device_index,0},
                                   {group_set,[]},
                                   {interface_type,[]},
                                   {ipv4_prefix_count,0},
                                   {ipv4_prefix_set,[]},
                                   {ipv6_address_count,0},
                                   {ipv6_addresses_set,[]},
                                   {ipv6_prefix_count,0},
                                   {ipv6_prefix_set,[]},
                                   {network_card_index,0},
                                   {network_interface_id, "eni-060ceeb735813d39d"},
                                   {private_ip_address,[]},
                                   {private_ip_addresses_set,[]},
                                   {secondary_private_ip_address_count,0},
                                   {subnet_id,[]}]]},
                             {placement,
                                 [[{affinity,[]},
                                   {availability_zone,[]},
                                   {group_name,[]},
                                   {host_id,[]},
                                   {host_resource_group_arn,[]},
                                   {partition_number,0},
                                   {spread_domain,[]},
                                   {tenancy,"default"}]]},
                             {private_dns_name_options,
                                 [[{enable_resource_name_dns_aaaa_record, false},
                                   {enable_resource_name_dns_a_record,true},
                                   {hostname_type,"ip-name"}]]},
                             {ram_disk_id,[]},
                             {security_group_id_set,[]},
                             {security_group_set,[]},
                             {tag_specification_set,
                                 [[{resource_type,"instance"},
                                   {tag_set,
                                       [[{key,"tag1"},{value,"134274125"}]]}],
                                  [{resource_type,"volume"},
                                   {tag_set,
                                       [[{key,"tag1"},
                                         {value,"134274125"}]]}]]},
                             {user_data,[]}]]},
                       {launch_template_id,"lt-08ccaba0746110123"},
                       {launch_template_name,"nb-ec-test-1"},
                       {version_description,
                           "Test template foo"},
                       {version_number,1}]]}}
         )
    ],
    output_tests(?_f(erlcloud_ec2:describe_launch_template_versions("lt-08ccaba0746110123")), Tests).

generate_security_group_response() ->
    "<DescribeSecurityGroupsResponse xmlns=\"http://ec2.amazonaws.com/doc/2016-11-15/\">
            <requestId>1d62eae0-acdd-481d-88c9-example</requestId>
            <securityGroupInfo>
                <item>
                    <ownerId>123456789012</ownerId>
                    <groupId>sg-9bf6ceff</groupId>
                    <groupName>SSHAccess</groupName>
                    <groupDescription>Security group for SSH access</groupDescription>
                    <vpcId>vpc-31896b55</vpcId>
                    <ipPermissions>
                        <item>
                            <ipProtocol>tcp</ipProtocol>
                            <fromPort>22</fromPort>
                            <toPort>22</toPort>
                            <groups/>
                            <ipRanges>
                                <item>
                                    <cidrIp>0.0.0.0/0</cidrIp>
                                </item>
                            </ipRanges>
                            <ipv6Ranges>
                                <item>
                                    <cidrIpv6>::/0</cidrIpv6>
                                </item>
                            </ipv6Ranges>
                            <prefixListIds/>
                        </item>
                    </ipPermissions>
                    <ipPermissionsEgress>
                        <item>
                            <ipProtocol>-1</ipProtocol>
                            <groups/>
                            <ipRanges>
                                <item>
                                    <cidrIp>0.0.0.0/0</cidrIp>
                                </item>
                            </ipRanges>
                            <ipv6Ranges>
                                <item>
                                    <cidrIpv6>::/0</cidrIpv6>
                                </item>
                            </ipv6Ranges>
                            <prefixListIds/>
                        </item>
                    </ipPermissionsEgress>
                </item>
            </securityGroupInfo>
        </DescribeSecurityGroupsResponse>".

describe_security_groups_input_tests(_) ->
    Tests =
        [?_ec2_test({
            "Describe security group(s), default call with no additional parameters",
            ?_f(erlcloud_ec2:describe_security_groups()),
            [{"Action", "DescribeSecurityGroups"}]}),
        ?_ec2_test({
            "Describe security group(s) matching the given group name",
            ?_f(erlcloud_ec2:describe_security_groups(["SSHAccess"])),
            [{"Action", "DescribeSecurityGroups"},
             {"GroupName.1", "SSHAccess"}]}),
        ?_ec2_test({
            "Describe security group(s) matching the given group ID(s)",
            ?_f(erlcloud_ec2:describe_security_groups(["sg-9bf6ceff"], [], none, erlcloud_aws:default_config())),
            [{"Action", "DescribeSecurityGroups"},
             {"GroupId.1", "sg-9bf6ceff"}]}),
        ?_ec2_test({
            "Describe security group(s) matching the given set of filters",
            ?_f(erlcloud_ec2:describe_security_groups([], [], [{
                "ip-permission-ipv6-cidr", ["::/0"]}], erlcloud_aws:default_config())),
            [{"Action", "DescribeSecurityGroups"},
             {"Filter.1.Name" ,"ip-permission-ipv6-cidr"},
             {"Filter.1.Value.1", "%3A%3A%2F0"}]})
        ],
    Response = generate_security_group_response(),
    input_tests(Response, Tests).

describe_security_groups_output_tests(_) ->
    Tests = [
        ?_ec2_test({
                "Coverage for DescribeSecurityGroup API Request",
                generate_security_group_response(),
            {ok, [[
                {owner_id, "123456789012"},
                {group_id, "sg-9bf6ceff"},
                {group_name, "SSHAccess"},
                {group_description, "Security group for SSH access"},
                {vpc_id, "vpc-31896b55"},
                {ip_permissions, [[
                    {ip_protocol, tcp},
                    {from_port, 22},
                    {to_port, 22},
                    {users, []},
                    {groups, []},
                    {ip_ranges, ["0.0.0.0/0"]},
                    {ipv6_ranges, ["::/0"]}]
                ]},
                {ip_permissions_egress, [[
                    {ip_protocol, '-1'},
                    {from_port, 0},
                    {to_port, 0},
                    {users, []},
                    {groups, []},
                    {ip_ranges, ["0.0.0.0/0"]},
                    {ipv6_ranges, ["::/0"]}]
                ]},
                {tag_set, []}]]}
        })
    ],
    output_tests(?_f(erlcloud_ec2:describe_security_groups()), Tests).

generate_one_instance(N) ->
    "<item>
        <reservationId>r-69</reservationId>
        <ownerId>12345</ownerId>
        <groupSet/>
        <instancesSet>
            <item>
                <instanceId>i-" ++ integer_to_list(N) ++ "f</instanceId>
                <imageId>ami-123</imageId>
                <instanceState>
                    <code>48</code>
                    <name>terminated</name>
                </instanceState>
                <privateDnsName/>
                <dnsName/>
                <reason>Because</reason>
                <keyName>Key</keyName>
                <amiLaunchIndex>123</amiLaunchIndex>
                <productCodes/>
                <instanceType>t2.small</instanceType>
                <launchTime>2016-09-26T10:35:00.000Z</launchTime>
                <platform/>
                <placement>
                    <availabilityZone>us-east-1a</availabilityZone>
                    <groupName/>
                    <tenancy>default</tenancy>
                </placement>
                <monitoring>
                    <state>disabled</state>
                </monitoring>
                <groupSet/>
                <stateReason>
                    <code>code</code>
                    <message>message</message>
                </stateReason>
                <architecture>x86_64</architecture>
                <rootDeviceType>ebs</rootDeviceType>
                <rootDeviceName>/dev/null</rootDeviceName>
                <blockDeviceMapping/>
                <virtualizationType>hvm</virtualizationType>
                <clientToken>123-123-12345</clientToken>
                <tagSet/>
                <hypervisor>xen</hypervisor>
                <networkInterfaceSet/>
                <ebsOptimized>false</ebsOptimized>
                <metadataOptions>
                    <state>applied</state>
                    <httpTokens>optional</httpTokens>
                    <httpPutResponseHopLimit>1</httpPutResponseHopLimit>
                    <httpEndpoint>enabled</httpEndpoint>
                    <httpProtocolIpv6>disabled</httpProtocolIpv6>
                    <instanceMetadataTags>disabled</instanceMetadataTags>
                </metadataOptions>
            </item>
        </instancesSet>
    </item>".

generate_instances_response(Start, End, NT) ->
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
     <DescribeInstancesResponse
         xmlns=\"http://ec2.amazonaws.com/doc/2014-10-01/\">
         <requestId>abcdef-12345</requestId>
         <reservationSet>" ++
        generate_items(generate_one_instance, Start, End) ++
        "</reservationSet>" ++
        generate_next_token_xml(NT) ++
        "</DescribeInstancesResponse>".

generate_one_snapshot(N) ->
    "<item>
        <snapshotId>snap-" ++ integer_to_list(N) ++ "</snapshotId>
        <volumeId>vol-123</volumeId>
        <status>completed</status>
        <startTime>2016-10-04T17:02:55.000Z</startTime>
        <progress>100%</progress>
        <ownerId>12345</ownerId>
        <volumeSize>123</volumeSize>
        <description>bla</description>
        <encrypted>false</encrypted>
    </item>".

generate_snapshots_response(Start, End, NT) ->
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
     <DescribeSnapshotsResponse
         xmlns=\"http://ec2.amazonaws.com/doc/2014-10-01/\">
         <requestId>12345</requestId>
         <snapshotSet>" ++
        generate_items(generate_one_snapshot, Start, End) ++
        "</snapshotSet>" ++
        generate_next_token_xml(NT) ++
        "</DescribeSnapshotsResponse>".

generate_one_tag(N) ->
    "<item>
        <resourceId>ami-" ++ integer_to_list(N) ++ "</resourceId>
        <resourceType>type</resourceType>
        <key>key</key>
        <value>value</value>
     </item>".

generate_tags_response(Start, End, NT) ->
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
     <DescribeTagsResponse
         xmlns=\"http://ec2.amazonaws.com/doc/2014-10-01/\">
         <requestId>e64e4387-5542-4765-bd0b-12b7e7ba902d</requestId>
         <tagSet>" ++
        generate_items(generate_one_tag, Start, End) ++
        "</tagSet>" ++
        generate_next_token_xml(NT) ++
        "</DescribeTagsResponse>".

generate_one_spot_price(N) ->
    "<item>
        <instanceType>m8.xlarge</instanceType>
        <productDescription>Product</productDescription>
        <spotPrice>0." ++ integer_to_list(N) ++"</spotPrice>
        <timestamp>2016-10-12T16:22:33.000Z</timestamp>
        <availabilityZone>us-west-1d</availabilityZone>
     </item>".

generate_spot_price_history_response(Start, End, NT) ->
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
     <DescribeSpotPriceHistoryResponse
         xmlns=\"http://ec2.amazonaws.com/doc/2014-10-01/\">
         <requestId>12345678 </requestId>
         <spotPriceHistorySet>" ++
        generate_items(generate_one_spot_price, Start, End) ++
        "</spotPriceHistorySet>" ++
        generate_next_token_xml(NT) ++
        "</DescribeSpotPriceHistoryResponse>".

generate_one_instance_status(N) ->
    "<item>
        <instanceId>i-" ++ integer_to_list(N) ++ "</instanceId>
        <availabilityZone>us-east-1d</availabilityZone>
        <instanceState>
            <code>16</code>
            <name>running</name>
        </instanceState>
        <systemStatus>
            <status>ok</status>
            <details/>
        </systemStatus>
        <instanceStatus>
            <status>ok</status>
            <details/>
        </instanceStatus>
     </item>".

generate_instance_status_response(Start, End, NT) ->
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
     <DescribeInstanceStatusResponse
         xmlns=\"http://ec2.amazonaws.com/doc/2014-10-01/\">
         <requestId>12345</requestId>
         <instanceStatusSet>" ++
             generate_items(generate_one_instance_status, Start, End) ++
        "</instanceStatusSet>" ++
         generate_next_token_xml(NT) ++
        "</DescribeInstanceStatusResponse>".

generate_one_reserved_instance_offering(N) ->
    "<item>
           <reservedInstancesListingId>" ++ integer_to_list(N) ++ "</reservedInstancesListingId>
           <reservedInstancesId>12345</reservedInstancesId>
           <createDate>2016-10-13T17:38:57.000Z</createDate>
           <updateDate>2016-10-13T17:38:58.000Z</updateDate>
           <status>active</status>
           <statusMessage>ACTIVE</statusMessage>
           <instanceCounts/>
           <priceSchedules/>
           <tagSet/>
           <clientToken>myclienttoken1</clientToken>
    </item>".

generate_reserved_instances_offerings_response(Start, End, NT) ->
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
     <DescribeReservedInstancesOfferingsResponse
         xmlns=\"http://ec2.amazonaws.com/doc/2014-10-01/\">
          <requestId>12345</requestId>
          <reservedInstancesOfferingsSet>" ++
        generate_items(generate_one_reserved_instance_offering, Start, End) ++
        "</reservedInstancesOfferingsSet>" ++
        generate_next_token_xml(NT) ++
        "</DescribeReservedInstancesOfferingsResponse>".

generate_items(GenerateFunction, K, N) ->
    generate_items(GenerateFunction, K, N, []).

generate_items(_GenerateFunction, K, N, Acc) when K > N ->
    Acc;
generate_items(GenerateFunction, K, N, Acc) ->
    generate_items(GenerateFunction, K+1, N, Acc ++ apply(?MODULE, GenerateFunction, [K])).

generate_next_token_xml(undefined) ->
    "";
generate_next_token_xml(NT) ->
    NTString = integer_to_list(NT),
    "<nextToken>" ++ NTString ++ "</nextToken>".

test_pagination(TestCases, ResponseGenerator, OriginalFunction) ->
    test_pagination(TestCases, ResponseGenerator, OriginalFunction, [], []).

test_pagination([], _, _, _, _) -> ok;
test_pagination([{TotalResults, ResultsPerPage} | Rest], ResponseGenerator, OriginalFunction, NormalParams, PagedParams) ->
    meck:new(erlcloud_aws, [passthrough]),
    meck:expect(erlcloud_aws, aws_request_xml4,
        fun(_,_,_,_,_,Params,_,_) ->
            NextTokenString = proplists:get_value("NextToken", Params),
            MaxResults = proplists:get_value("MaxResults", Params),
            {Start, End, NT} =
                case {NextTokenString, MaxResults} of
                    {undefined, undefined} ->
                        {1, TotalResults, undefined};
                    {undefined, MaxResults} ->
                        case MaxResults >= TotalResults of
                            true ->
                                {1, TotalResults, undefined};
                            false ->
                                {1, MaxResults, MaxResults + 1}
                        end;
                    {NextTokenString, MaxResults} ->
                        NextToken = list_to_integer(NextTokenString),
                        case NextToken + MaxResults - 1 >= TotalResults of
                            true ->
                                {NextToken, TotalResults, undefined};
                            false ->
                                {NextToken, NextToken + MaxResults - 1,  NextToken + MaxResults}
                        end
                end,
            Response = apply(?MODULE, ResponseGenerator, [Start, End, NT]),
            {ok, element(1, xmerl_scan:string(Response))}
        end),
    {ok, AllResults} = apply(erlcloud_ec2, OriginalFunction, NormalParams),
    {ok, PagedResults} = describe_all(OriginalFunction, PagedParams, ResultsPerPage),
    meck:unload(erlcloud_aws),
    ?assertEqual(length(AllResults), TotalResults),
    ?assertEqual(length(AllResults), length(PagedResults)),
    ?assert(lists_are_the_same(AllResults, PagedResults)),
    test_pagination(Rest, ResponseGenerator, OriginalFunction, NormalParams, PagedParams).

describe_all(DescribeFunction, Params, MaxResults) ->
    describe_all(DescribeFunction, Params, MaxResults, undefined, []).

describe_all(DescribeFunction, Params, MaxResults, NextToken, Acc) ->
    AllParams = Params ++ [MaxResults, NextToken],
    case apply(erlcloud_ec2, DescribeFunction, AllParams) of
        {ok, Res, undefined} ->
            {ok, Acc ++ Res};
        {ok, Res, NewNextToken} ->
            describe_all(DescribeFunction, Params, MaxResults, NewNextToken, Acc ++ Res)
    end.

lists_are_the_same(List1, List2) ->
    lists:sort(List1) =:= lists:sort(List2).

