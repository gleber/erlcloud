-module(erlcloud_ec2).

-include("erlcloud_xmerl.hrl").

%% Library initialization.
-export([configure/2, configure/3, new/2, new/3]).

%% EC2 API Functions
-export([
         %% Amazon DevPay
         confirm_product_instance/2, confirm_product_instance/3,

         %% AMIs
         create_image/2, create_image/3, create_image/4, create_image/5,
         deregister_image/1, deregister_image/2,
         describe_image_attribute/2, describe_image_attribute/3,
         describe_images/0, describe_images/1, describe_images/2,
         describe_images/3, describe_images/4, describe_images/5,
         modify_image_attribute/3, modify_image_attribute/4,

         %% Availability Zones and Regions
         describe_availability_zones/0, describe_availability_zones/1,
         describe_availability_zones/2,
         describe_regions/0, describe_regions/1, describe_regions/2, describe_regions/3, describe_regions/4,

         %% Elastic Block Store
         attach_volume/3, attach_volume/4,
         create_snapshot/1, create_snapshot/2, create_snapshot/3, create_snapshot/4,
         create_volume/3, create_volume/4, create_volume/5, create_volume/6,
         delete_snapshot/1, delete_snapshot/2,
         delete_volume/1, delete_volume/2,
         describe_snapshot_attribute/2, describe_snapshot_attribute/3,
         describe_snapshots/0, describe_snapshots/1, describe_snapshots/2,
         describe_snapshots/3, describe_snapshots/4, describe_snapshots/5,
         describe_volumes/0, describe_volumes/1, describe_volumes/2,
         detach_volume/1, detach_volume/2,
         modify_snapshot_attribute/3, modify_snapshot_attribute/4,
         reset_snapshot_attribute/2, reset_snapshot_attribute/3,

         %% Elastic IP addresses.
         allocate_address/0, allocate_address/1,
         associate_address/2, associate_address/3,
         describe_addresses/0, describe_addresses/1,
         describe_addresses/2, describe_addresses/3,
         disassociate_address/1, disassociate_address/2,
         release_address/1, release_address/2,

         %% General
         get_console_output/1, get_console_output/2,

         %% Images
         register_image/1, register_image/2,
         reset_image_attribute/2, reset_image_attribute/3,

         %% Instances
         describe_instance_attribute/2, describe_instance_attribute/3,
         describe_instances/0, describe_instances/1, describe_instances/2,
         describe_instances/3, describe_instances/4,
         modify_instance_attribute/3, modify_instance_attribute/4,
         modify_instance_attribute/5,
         reboot_instances/1, reboot_instances/2,
         reset_instance_attribute/2, reset_instance_attribute/3,
         run_instances/1, run_instances/2,
         start_instances/1, start_instances/2,
         stop_instances/1, stop_instances/2, stop_instances/3,
         terminate_instances/1, terminate_instances/2,
         describe_instance_status/1, describe_instance_status/2,
         describe_instance_status/3, describe_instance_status/4,
         describe_instance_status/5,

         %% Key Pairs
         create_key_pair/1, create_key_pair/2,
         import_key_pair/2, import_key_pair/3,
         delete_key_pair/1, delete_key_pair/2,
         describe_key_pairs/0, describe_key_pairs/1, describe_key_pairs/2,

         %% Monitoring
         monitor_instances/1, monitor_instances/2,
         unmonitor_instances/1, unmonitor_instances/2,

         %% Network Interfaces
         describe_network_interfaces/0, describe_network_interfaces/1,
         describe_network_interfaces/2,
         describe_network_interfaces_filtered/3,

         %% Reserved Instances
         describe_reserved_instances/0, describe_reserved_instances/1,
         describe_reserved_instances/2,
         describe_reserved_instances_offerings/0,
         describe_reserved_instances_offerings/1,
         describe_reserved_instances_offerings/2,
         describe_reserved_instances_offerings/3,
         describe_reserved_instances_offerings/4,
         describe_reserved_instances_offerings_all/0,
         describe_reserved_instances_offerings_all/1,
         describe_reserved_instances_offerings_all/2,
         purchase_reserved_instances_offering/1,
         purchase_reserved_instances_offering/2,

         %% Security Groups
         authorize_security_group_ingress/2, authorize_security_group_ingress/3,
         authorize_security_group_egress/2, authorize_security_group_egress/3,
         create_security_group/2, create_security_group/3, create_security_group/4,
         delete_security_group/1, delete_security_group/2, delete_security_group/3,
         describe_security_groups/0, describe_security_groups/1, describe_security_groups/2,
         describe_security_groups_filtered/1, describe_security_groups_filtered/2,
         describe_security_groups/4,
         revoke_security_group_ingress/2, revoke_security_group_ingress/3,
         revoke_security_group_egress/2, revoke_security_group_egress/3,

         %% Spot Instances
         cancel_spot_instance_requests/1, cancel_spot_instance_requests/2,
         cancel_spot_fleet_requests/2, cancel_spot_fleet_requests/3,
         create_spot_datafeed_subscription/1, create_spot_datafeed_subscription/2,
         create_spot_datafeed_subscription/3,
         delete_spot_datafeed_subscription/0, delete_spot_datafeed_subscription/1,
         describe_spot_datafeed_subscription/0, describe_spot_datafeed_subscription/1,
         describe_spot_fleet_instances/1, describe_spot_fleet_instances/2,
         describe_spot_fleet_instances/3, describe_spot_fleet_instances/4,
         describe_spot_fleet_instances_all/1, describe_spot_fleet_instances_all/2,
         describe_spot_instance_requests/0, describe_spot_instance_requests/1,
         describe_spot_instance_requests/2,
         describe_spot_price_history/0, describe_spot_price_history/1,
         describe_spot_price_history/2, describe_spot_price_history/3,
         describe_spot_price_history/4, describe_spot_price_history/5,
         describe_spot_price_history/6, describe_spot_price_history/7,
         modify_spot_fleet_request/3, modify_spot_fleet_request/4,
         request_spot_instances/1, request_spot_instances/2,
         request_spot_fleet/1, request_spot_fleet/2,

         %% Windows
         bundle_instance/6, bundle_instance/7,
         cancel_bundle_task/1, cancel_bundle_task/2,
         describe_bundle_tasks/0, describe_bundle_tasks/1, describe_bundle_tasks/2,
         get_password_data/1, get_password_data/2,

         %% VPC
         describe_subnets/0, describe_subnets/1, describe_subnets/2, describe_subnets/3,
         create_subnet/2, create_subnet/3, create_subnet/4,
         delete_subnet/1, delete_subnet/2,
         describe_vpcs/0, describe_vpcs/1, describe_vpcs/2, describe_vpcs/3,
         create_vpc/1, create_vpc/2, create_vpc/3,
         delete_vpc/1, delete_vpc/2,
         describe_dhcp_options/0, describe_dhcp_options/1, describe_dhcp_options/2,
         associate_dhcp_options/2, associate_dhcp_options/3,
         describe_internet_gateways/0, describe_internet_gateways/1,
         describe_internet_gateways/2, describe_internet_gateways/3,
         create_internet_gateway/0, create_internet_gateway/1,
         attach_internet_gateway/2, attach_internet_gateway/3,
         delete_internet_gateway/1, delete_internet_gateway/2,
         detach_internet_gateway/2, detach_internet_gateway/3,
         describe_route_tables/0, describe_route_tables/1, 
         describe_route_tables/2, describe_route_tables/3,
         create_route_table/1, create_route_table/2,
         delete_route_table/1, delete_route_table/2,
         create_route/4, create_route/5, delete_route/2, delete_route/3,
         associate_route_table/2, associate_route_table/3,

         %% VPC/Network ACLs
         create_network_acl/1, create_network_acl/2,
         delete_network_acl/1, delete_network_acl/2,
         describe_network_acls/0, describe_network_acls/1, 
         describe_network_acls/2, describe_network_acls/3,
         create_network_acl_entry/1, create_network_acl_entry/2,
         replace_network_acl_entry/1, replace_network_acl_entry/2,
         delete_network_acl_entry/2, delete_network_acl_entry/3,
         delete_network_acl_entry/4,
         replace_network_acl_association/2, replace_network_acl_association/3,

         %% Flow Logs
         create_flow_logs/5, create_flow_logs/6, create_flow_logs/7,
         delete_flow_logs/1, delete_flow_logs/2,
         describe_flow_logs/0, describe_flow_logs/1, describe_flow_logs/2, describe_flow_logs/3, describe_flow_logs/4,

         %% Tagging. Uses different version of AWS API
         create_tags/2, create_tags/3,
         describe_tags/0, describe_tags/1, describe_tags/2, describe_tags/3, describe_tags/4,
         delete_tags/2, delete_tags/3,
        
         %% VPN gateways
         describe_vpn_gateways/0, describe_vpn_gateways/1, describe_vpn_gateways/2, describe_vpn_gateways/3,
         describe_vpn_connections/0, describe_vpn_connections/1, describe_vpn_connections/2, describe_vpn_connections/3,
        
         %% Customer gateways
         describe_customer_gateways/0, describe_customer_gateways/1, describe_customer_gateways/2, describe_customer_gateways/3,
        
         %% Account attributes
         describe_account_attributes/0, describe_account_attributes/1, describe_account_attributes/2,
         
         %% Nat gateways
         describe_nat_gateways/0, describe_nat_gateways/1, describe_nat_gateways/2,
         describe_nat_gateways/3, describe_nat_gateways/4, describe_nat_gateways/5,
         
         % VPC peering connections
         describe_vpc_peering_connections/0, describe_vpc_peering_connections/1,
         describe_vpc_peering_connections/2, describe_vpc_peering_connections/3,

         % Launch templates
         describe_launch_templates/0, describe_launch_templates/1,
         describe_launch_templates/2, describe_launch_templates/3,
         describe_launch_templates/4, describe_launch_templates/5,

         describe_launch_templates_all/0, describe_launch_templates_all/1,
         describe_launch_templates_all/2, describe_launch_templates_all/3,

         describe_launch_template_versions/1, describe_launch_template_versions/3,
         describe_launch_template_versions/4, describe_launch_template_versions/5,
         describe_launch_template_versions/6, describe_launch_template_versions/7,

         describe_launch_template_versions_all/2, describe_launch_template_versions_all/3
    ]).

-import(erlcloud_xml, [get_text/1, get_text/2, get_text/3, get_bool/2, get_list/2, get_integer/2]).

-define(API_VERSION, "2009-11-30").
% -define(NEW_API_VERSION, "2012-10-01").
% -define(NEW_API_VERSION, "2013-10-15").
% -define(NEW_API_VERSION, "2014-02-01").
% -define(NEW_API_VERSION, "2014-06-15").
% -define(NEW_API_VERSION, "2015-10-01").
-define(NEW_API_VERSION, "2016-11-15").
-include("erlcloud.hrl").
-include("erlcloud_aws.hrl").
-include("erlcloud_ec2.hrl").

-define(INSTANCES_MR_MIN, 5).
-define(INSTANCES_MR_MAX, 1000).
-define(SPOT_INSTANCE_STATUS_MR_MIN, 5).
-define(SPOT_INSTANCE_STATUS_MR_MAX, 1000).
-define(SNAPSHOTS_MR_MIN, 5).
-define(SNAPSHOTS_MR_MAX, 1000).
-define(SPOT_PRICE_MR_MIN, 5).
-define(SPOT_PRICE_MR_MAX, 1000).
-define(TAGS_MR_MIN, 5).
-define(TAGS_MR_MAX, 1000).
-define(SPOT_FLEET_INSTANCES_MR_MIN, 1).
-define(SPOT_FLEET_INSTANCES_MR_MAX, 1000).
-define(RESERVED_INSTANCES_OFFERINGS_MR_MIN, 5).
-define(RESERVED_INSTANCES_OFFERINGS_MR_MAX, 1000).
-define(NAT_GATEWAYS_MR_MIN, 1).
-define(NAT_GATEWAYS_MR_MAX, 1000).
-define(FLOWS_MR_MIN, 1).
-define(FLOWS_MR_MAX, 1000).
-define(LAUNCH_TEMPLATES_MR_MIN, 1).
-define(LAUNCH_TEMPLATES_MR_MAX, 200).

-type filter_list() :: [{string() | atom(),[string()] | string()}] | none.
-type ec2_param_list() :: [{string(),string()}].
-type ec2_selector() :: proplist().
-type ec2_token() :: string() | undefined.
-type ec2_max_result() :: pos_integer() | undefined.
-type ok_error() :: ok | {error, term()}.
-type ok_error(Ok) :: {ok, Ok} | {error, term()}.
-type ok_error(Ok1, Ok2) :: {ok, Ok1, Ok2} | {error, term()}.
-type instance_id() :: string().
-type ec2_instances_ids() :: [instance_id()].
-type ec2_snapshot_ids() :: [string()].
-type ec2_snapshot_owner() :: string().
-type ec2_snapshot_restorable_by() :: string() | none.
-type ec2_spot_price_time() :: string() | none.
-type ec2_instance_types() :: [string()].
-type ec2_product_description() :: string() | none.
-type describe_spot_fleet_instances_return() ::
    {ok, [{instances, [proplist()]} | {next_token, string()}]} | {error, term()}.
-type spot_fleet_instance_id() :: string().
-type account_attribute_names() :: [string()].
-type nat_gateway_ids() :: [string()].
-type vpc_peering_connection_ids() :: [string()].
-type flow_id() :: string().
-type ec2_flow_ids() :: [flow_id()].
-type launch_template_ids() :: [string()].


-spec new(string(), string()) -> aws_config().
new(AccessKeyID, SecretAccessKey) ->
    #aws_config{access_key_id=AccessKeyID,
                secret_access_key=SecretAccessKey}.

-spec new(string(), string(), string()) -> aws_config().
new(AccessKeyID, SecretAccessKey, Host) ->
    #aws_config{access_key_id=AccessKeyID,
                secret_access_key=SecretAccessKey,
                ec2_host=Host}.

-spec configure(string(), string()) -> ok.
configure(AccessKeyID, SecretAccessKey) ->
    put(aws_config, new(AccessKeyID, SecretAccessKey)),
    ok.

-spec configure(string(), string(), string()) -> ok.
configure(AccessKeyID, SecretAccessKey, Host) ->
    put(aws_config, new(AccessKeyID, SecretAccessKey, Host)),
    ok.

-spec allocate_address() -> ok_error(string()).
allocate_address() -> allocate_address(none, default_config()).

-spec allocate_address(aws_config()) -> ok_error(string()).
allocate_address(Config) when is_record(Config, aws_config) ->
    allocate_address(none, Config);
allocate_address(Domain) when is_atom(Domain) ->
    allocate_address(Domain, default_config()).

-spec allocate_address(none | vpc, aws_config()) -> ok_error(string() | {string(), string()}).
allocate_address(Domain, Config) ->
    Params = case Domain of
                 vpc -> [{"Domain", "vpc"}];
                 none -> []
             end,
    case ec2_query(Config, "AllocateAddress", Params, ?NEW_API_VERSION) of
        {ok, Doc} ->
            case Domain of
                vpc ->
                    {ok, {get_text("/AllocateAddressResponse/publicIp", Doc),
                          get_text("/AllocateAddressResponse/allocationId", Doc)}};
                none ->
                    {ok, get_text("/AllocateAddressResponse/publicIp", Doc)}
            end;
        {error, _} = Error ->
            Error
    end.

-spec associate_address(string(), string()) -> ok_error().
associate_address(PublicIP, InstanceID) ->
    associate_address(PublicIP, InstanceID, default_config()).

-spec associate_address(string(), string(), string() | aws_config()) -> ok_error().
associate_address(PublicIP, InstanceID, Config)
  when is_list(PublicIP), is_list(InstanceID), is_record(Config, aws_config) ->
    associate_address(PublicIP, InstanceID, none, Config);
associate_address(PublicIP, InstanceID, AllocationID)
  when is_list(PublicIP), is_list(InstanceID), is_list(AllocationID) ->
    associate_address(PublicIP, InstanceID, AllocationID, default_config()).

-spec associate_address(string(), string(), string() | none, aws_config()) -> ok_error().
associate_address(PublicIP, InstanceID, AllocationID, Config) ->
    AllocationParam = case AllocationID of
                          none -> [{ "PublicIp", PublicIP} ];
                          ID -> [{ "AllocationId", ID }]
                      end,
    ec2_simple_query(Config, "AssociateAddress",
                     [{"InstanceId", InstanceID} | AllocationParam],
                     ?NEW_API_VERSION).

-spec associate_dhcp_options(string(), string()) -> ok_error().
associate_dhcp_options(OptionsID, VpcID) ->
    associate_dhcp_options(OptionsID, VpcID, default_config()).

-spec associate_dhcp_options(string(), string(), aws_config()) -> ok_error().
associate_dhcp_options(OptionsID, VpcID, Config) ->
    ec2_simple_query(Config, "AssociateDhcpOptions",
                     [{"DhcpOptionsId", OptionsID}, {"VpcId", VpcID}]).

-spec associate_route_table(string(), string()) -> ok_error(string()).
associate_route_table(RouteTableID, SubnetID) ->
    associate_route_table(RouteTableID, SubnetID, default_config()).

-spec associate_route_table(string(), string(), aws_config()) -> ok_error(string()).
associate_route_table(RouteTableID, SubnetID, Config) ->
    Params = [{"RouteTableId", RouteTableID}, {"SubnetId", SubnetID}],
    case ec2_query(Config, "AssociateRouteTable", Params, ?NEW_API_VERSION) of
        {ok, Doc} ->
            {ok, get_text("/AssociateRouteTableResponse/associationId", Doc)};
        {error, _} = Error ->
            Error
    end.

-spec attach_internet_gateway(string(), string()) -> ok_error().
attach_internet_gateway(GatewayID, VpcID) ->
    attach_internet_gateway(GatewayID, VpcID, default_config()).

-spec attach_internet_gateway(string(), string(), aws_config()) -> ok_error().
attach_internet_gateway(GatewayID, VpcID, Config) ->
    ec2_simple_query(Config, "AttachInternetGateway",
                     [{"InternetGatewayId", GatewayID},
                      {"VpcId", VpcID}], ?NEW_API_VERSION).

-spec attach_volume(string(), string(), string()) -> ok_error(proplist()).
attach_volume(VolumeID, InstanceID, Device) ->
    attach_volume(VolumeID, InstanceID, Device, default_config()).

-spec attach_volume(string(), string(), string(), aws_config()) -> ok_error(proplist()).
attach_volume(VolumeID, InstanceID, Device, Config)
  when is_list(VolumeID), is_list(InstanceID), is_list(Device) ->
    case ec2_query(Config, "AttachVolume", [{"InstanceId", InstanceID}, {"Device", Device}, {"VolumeId", VolumeID}]) of
        {ok, Doc} ->
            {ok, extract_volume_status(hd(xmerl_xpath:string("/AttachVolumeResponse", Doc)))};
        {error, _} = Error ->
            Error
    end.

extract_volume_status(Node) ->
    erlcloud_xml:decode(
      [
       {volume_id, "volumeId", text},
       {instance_id, "instanceId", text},
       {device, "device", text},
       {status, "status", text},
       {attach_time, "attachTime", time}
      ],
      Node
     ).

-spec authorize_security_group_egress(string(), [vpc_egress_spec()]) -> ok_error().
authorize_security_group_egress(GroupName, EgressSpec) ->
    authorize_security_group_egress(GroupName, EgressSpec, default_config()).

-spec authorize_security_group_egress(string(), [vpc_egress_spec()], aws_config()) -> ok_error().
authorize_security_group_egress(GroupID, VPCEgressSpec, Config)
    when is_list(GroupID), is_list(VPCEgressSpec) ->
    Params = [{"GroupId", GroupID} | vpc_egress_spec_to_params(VPCEgressSpec)],
    ec2_simple_query(Config, "AuthorizeSecurityGroupEgress", Params, ?NEW_API_VERSION).

-spec authorize_security_group_ingress(string(), ec2_ingress_spec()) -> ok_error().
authorize_security_group_ingress(GroupName, IngressSpec) ->
    authorize_security_group_ingress(GroupName, IngressSpec, default_config()).

-spec authorize_security_group_ingress(string(), ec2_ingress_spec() | [vpc_ingress_spec()], aws_config()) -> ok_error().
authorize_security_group_ingress(GroupName, IngressSpec, Config)
  when is_list(GroupName), is_record(IngressSpec, ec2_ingress_spec) ->
    Params = [{"GroupName", GroupName}|ingress_spec_params(IngressSpec)],
    ec2_simple_query(Config, "AuthorizeSecurityGroupIngress", Params);
authorize_security_group_ingress(GroupID, VPCIngressSpec, Config)
  when is_list(GroupID), is_list(VPCIngressSpec) ->
    Params = [{"GroupId", GroupID} | vpc_ingress_spec_to_params(VPCIngressSpec)],
    ec2_simple_query(Config, "AuthorizeSecurityGroupIngress", Params, ?NEW_API_VERSION).

ingress_spec_params(Spec) ->
    [
     {"IpProtocol", Spec#ec2_ingress_spec.ip_protocol},
     {"FromPort", Spec#ec2_ingress_spec.from_port},
     {"ToPort", Spec#ec2_ingress_spec.to_port},
     {"SourceSecurityGroupOwnerId", Spec#ec2_ingress_spec.source_security_group_owner_id},
     {"SourceSecurityGroupName", Spec#ec2_ingress_spec.source_security_group_name},
     {"CidrIp", Spec#ec2_ingress_spec.cidr_ip}
    ].

vpc_ingress_spec_to_params(Spec) ->
    XgressSpec = lists:map(fun vpc_ingress_to_xgress/1, Spec),
    vpc_xgress_spec_to_params(XgressSpec, 1, []).

vpc_egress_spec_to_params(Spec) ->
    XgressSpec = lists:map(fun vpc_egress_to_xgress/1, Spec),
    vpc_xgress_spec_to_params(XgressSpec, 1, []).

vpc_xgress_spec_to_params([], _, Res) -> Res;
vpc_xgress_spec_to_params([H|T], Count, Res) ->
    Prefix = lists:flatten(["IpPermissions", $., integer_to_list(Count), $.]),
    P1 = [ {lists:flatten([Prefix, "IpProtocol"]),
            H#vpc_xgress_internal_spec.ip_protocol},
           {lists:flatten([Prefix, "FromPort"]), H#vpc_xgress_internal_spec.from_port},
           {lists:flatten([Prefix, "ToPort"]), H#vpc_xgress_internal_spec.to_port}
         ],
    UserP = vpc_xgress_details_to_params(
        H#vpc_xgress_internal_spec.user_id, Count, "Groups", "UserId"),
    GNameP = vpc_xgress_details_to_params(
        H#vpc_xgress_internal_spec.group_name, Count, "Groups", "GroupName"),
    GIdP = vpc_xgress_details_to_params(
        H#vpc_xgress_internal_spec.group_id, Count, "Groups", "GroupId"),
    CidrP = vpc_xgress_details_to_params(
        H#vpc_xgress_internal_spec.cidr_ip, Count, "IpRanges", "CidrIp"),
    vpc_xgress_spec_to_params(T, Count + 1, lists:flatten([P1, UserP, GNameP,
                                                            GIdP, CidrP, Res])).

vpc_xgress_details_to_params(Values, Count, Prefix, Suffix) ->
    vpc_xgress_details_to_params(Values, Count, Prefix, Suffix, 1, []).

vpc_xgress_details_to_params(undefined, _, _, _, _, _) -> [];
vpc_xgress_details_to_params([], _, _, _, _, Res) -> lists:flatten(Res);
vpc_xgress_details_to_params([H|T], Count, Prefix, Suffix, DetailCount, Res) ->
    Key = lists:flatten(["IpPermissions", $., integer_to_list(Count), $.,
                         Prefix, $., integer_to_list(DetailCount), $., Suffix]),
    Param = { Key, H },
    vpc_xgress_details_to_params(T, Count, Prefix, Suffix, DetailCount + 1,
                                  [ Param | Res ]).

vpc_ingress_to_xgress(#vpc_ingress_spec{user_id = UserP,
                                       group_name = GNameP,
                                       group_id = GIdP,
                                       cidr_ip = CidrP,
                                       ip_protocol = IpProtocol,
                                       from_port = FromPort,
                                       to_port = ToPort}) ->
    #vpc_xgress_internal_spec{user_id     = UserP,
                              group_name  = GNameP,
                              group_id    = GIdP,
                              cidr_ip     = CidrP,
                              ip_protocol = IpProtocol,
                              from_port   = FromPort,
                              to_port     = ToPort}.

vpc_egress_to_xgress(#vpc_egress_spec{user_id = UserP,
                                       group_name = GNameP,
                                       group_id = GIdP,
                                       cidr_ip = CidrP,
                                       ip_protocol = IpProtocol,
                                       from_port = FromPort,
                                       to_port = ToPort}) ->
    #vpc_xgress_internal_spec{user_id     = UserP,
                              group_name  = GNameP,
                              group_id    = GIdP,
                              cidr_ip     = CidrP,
                              ip_protocol = IpProtocol,
                              from_port   = FromPort,
                              to_port     = ToPort}.

-spec bundle_instance(string(), string(), string(), string(), string(), string()) -> ok_error(proplist()).
bundle_instance(InstanceID, Bucket, Prefix, AccessKeyID, UploadPolicy,
                UploadPolicySignature) ->
    bundle_instance(InstanceID, Bucket, Prefix, AccessKeyID, UploadPolicy,
                    UploadPolicySignature, default_config()).

-spec bundle_instance(string(), string(), string(), string(), string(), string(), aws_config()) -> ok_error(proplist()).
bundle_instance(InstanceID, Bucket, Prefix, AccessKeyID, UploadPolicy,
                UploadPolicySignature, Config) ->
    case ec2_query(Config, "BundleInstance",
                    [{"InstanceId", InstanceID}, {"Storage.S3.Bucket", Bucket},
                     {"Storage.S3.Prefix", Prefix}, {"Storage.S3.AWSAccessKeyId", AccessKeyID},
                     {"Storage.S3.UploadPolicy", UploadPolicy},
                     {"Storage.S3.UploadPolicySignature", UploadPolicySignature}]) of
        {ok, Doc} ->
            {ok, extract_bundle_task(xmerl_xpath:string("/BundleInstanceResponse/bundleInstanceTask", Doc))};
        {error, _} = Error ->
            Error
    end.

-spec extract_bundle_task(Nodes :: [xmerl_xpath_doc_nodes()]) -> proplist();
                         (Node :: xmerl_xpath_doc_nodes()) -> proplist().
extract_bundle_task([Node]) ->
    extract_bundle_task(Node);
extract_bundle_task(Node) ->
    [
     {instance_id, get_text("instanceId", Node)},
     {bundle_id, get_text("bundleId", Node)},
     {state, get_text("state", Node)},
     {start_time, erlcloud_xml:get_time("startTime", Node)},
     {update_time, erlcloud_xml:get_time("updateTime", Node)},
     {progress, get_text("progress", Node)},
     {bucket, get_text("storage/S3/bucket", Node)},
     {prefix, get_text("storage/S3/prefix", Node)}
    ].

-spec cancel_bundle_task(string()) -> ok_error(proplist()).
cancel_bundle_task(BundleID) ->
    cancel_bundle_task(BundleID, default_config()).

-spec cancel_bundle_task(string(), aws_config()) -> ok_error(proplist()).
cancel_bundle_task(BundleID, Config)
  when is_list(BundleID) ->
    case ec2_query(Config, "CancelBundleTask", [{"BundleId", BundleID}]) of
        {ok, Doc} ->
            {ok, extract_bundle_task(xmerl_xpath:string("/CancelBundleTaskResponse/bundleInstanceTask", Doc))};
        {error, _} = Error ->
            Error
    end.

-spec cancel_spot_instance_requests([string()]) -> ok_error([proplist()]).
cancel_spot_instance_requests(SpotInstanceRequestIDs) ->
    cancel_spot_instance_requests(SpotInstanceRequestIDs, default_config()).

-spec cancel_spot_instance_requests([string()], aws_config()) -> ok_error([proplist()]).
cancel_spot_instance_requests(SpotInstanceRequestIDs, Config)
  when is_list(SpotInstanceRequestIDs) ->
    case ec2_query(Config, "CancelSpotInstanceRequests",
                    erlcloud_aws:param_list(SpotInstanceRequestIDs, "SpotInstanceRequestId")) of
        {ok, Doc} ->
            {ok, [extract_spot_instance_state(Item) ||
                Item <- xmerl_xpath:string("/CancelSpotInstanceRequestsResponse/spotInstanceRequestSet/item", Doc)]};
        {error, _} = Error ->
            Error
    end.

extract_spot_instance_state(Node) ->
    [
     {spot_instance_request_id, get_text("spotInstanceRequestId", Node)},
     {state, get_text("state", Node)}
    ].

-spec confirm_product_instance(string(), string()) -> ok_error(proplist()).
confirm_product_instance(ProductCode, InstanceID) ->
    confirm_product_instance(ProductCode, InstanceID, default_config()).

-spec confirm_product_instance(string(), string(), aws_config()) -> ok_error(proplist()).
confirm_product_instance(ProductCode, InstanceID, Config)
  when is_list(ProductCode), is_list(InstanceID) ->
    Params = [{"ProductCode", ProductCode}, {"InstanceId", InstanceID}],
    case ec2_query(Config, "ConfirmProductInstance", Params) of
        {ok, Doc} ->
            {ok, [
                {return, get_bool("/ConfirmProductInstanceResponse/return", Doc)},
                {owner_id, get_text("/ConfirmProductInstanceResponse/ownerId", Doc)}
            ]};
        {error, _} = Error ->
            Error
    end.

-spec create_key_pair(string()) -> ok_error(proplist()).
create_key_pair(KeyName) -> create_key_pair(KeyName, default_config()).

-spec create_key_pair(string(), aws_config()) -> ok_error(proplist()).
create_key_pair(KeyName, Config)
  when is_list(KeyName) ->
    case ec2_query(Config, "CreateKeyPair", [{"KeyName", KeyName}]) of
        {ok, Doc} ->
            {ok, [
                {key_name, get_text("/CreateKeyPairResponse/keyName", Doc)},
                {key_fingerprint, get_text("/CreateKeyPairResponse/keyFingerprint", Doc)},
                {key_material, get_text("/CreateKeyPairResponse/keyMaterial", Doc)}
            ]};
        {error, _} = Error ->
            Error
    end.

-spec import_key_pair(string(), string()) -> ok_error(proplist()).
import_key_pair(KeyName, PublicKeyMaterial) -> import_key_pair(KeyName, PublicKeyMaterial, default_config()).

-spec import_key_pair(string(), string(), aws_config()) -> ok_error(proplist()).
import_key_pair(KeyName, PublicKeyMaterial, Config)
  when is_record(Config, aws_config) ->
    Params = [{"KeyName", KeyName}, {"PublicKeyMaterial", base64:encode_to_string(PublicKeyMaterial)}],
    case ec2_query(Config, "ImportKeyPair", Params, ?NEW_API_VERSION) of
        {ok, Doc} ->
            {ok, [
                {key_fingerprint, get_text("/ImportKeyPairResponse/keyFingerprint", Doc)},
                {key_name, get_text("/ImportKeyPairResponse/keyName", Doc)}
            ]};
        {error, _} = Error ->
            Error
    end.

-spec create_image(string(), string()) -> ok_error(proplist()).
create_image(InstanceID, Name) -> create_image(InstanceID, Name, default_config()).

-spec create_image(string(), string(), string() | aws_config()) -> ok_error(proplist()).
create_image(InstanceID, Name, Config)
  when is_record(Config, aws_config) ->
    create_image(InstanceID, Name, none, Config);
create_image(InstanceID, Name, Description) ->
    create_image(InstanceID, Name, Description, default_config()).

-spec create_image(string(), string(), string() | none, boolean() | aws_config()) -> ok_error(proplist()).
create_image(InstanceID, Name, Description, Config)
  when is_record(Config, aws_config) ->
    create_image(InstanceID, Name, Description, false, Config);
create_image(InstanceID, Name, Description, NoReboot) ->
    create_image(InstanceID, Name, Description, NoReboot, default_config()).

-spec create_image(string(), string(), string() | none, boolean(), aws_config()) -> ok_error(proplist()).
create_image(InstanceID, Name, Description, NoReboot, Config)
  when is_list(InstanceID), is_list(Name),
       is_list(Description) orelse Description =:= none,
       is_boolean(NoReboot) ->
    Params = [{"InstanceId", InstanceID}, {"Name", Name},
              {"Description", Description}, {"NoReboot", NoReboot}],
    case ec2_query(Config, "CreateImage", Params) of
        {ok, Doc} ->
            {ok, [{image_id, get_text("/CreateImageResponse/imageId", Doc)}]};
        {error, _} = Error ->
            Error
    end.

-spec create_internet_gateway() -> ok_error(proplist()).
create_internet_gateway() ->
    create_internet_gateway(default_config()).

-spec create_internet_gateway(aws_config()) -> ok_error(proplist()).
create_internet_gateway(Config) ->
    case ec2_query(Config, "CreateInternetGateway", [], ?NEW_API_VERSION) of
        {ok, Doc} ->
            Path = "/CreateInternetGatewayResponse/internetGateway/internetGatewayId",
            {ok, [{internet_gateway_id, get_text(Path, Doc)}]};
        {error, _} = Error ->
            Error
    end.

-spec create_network_acl(string()) -> ok_error(proplist()).
create_network_acl(VpcID) ->
    create_network_acl(VpcID, default_config()).

-spec create_network_acl(string(), aws_config()) -> ok_error(proplist()).
create_network_acl(VpcID, Config) ->
    case ec2_query(Config, "CreateNetworkAcl", [{"VpcId", VpcID}], ?NEW_API_VERSION) of
        {ok, Doc} ->
            Path = "/CreateNetworkAclResponse/networkAcl",
            [Node] = xmerl_xpath:string(Path, Doc),
            {ok, extract_acl_response(Node)};
        {error, _} = Error ->
            Error
    end.

extract_acl_response(Node) ->
    [{network_acl_id, get_text("networkAclId", Node)},
     {vpc_id, get_text("vpcId", Node)},
     {default, get_text("default", Node)},
     {association_set, [ extract_acl_association_item(Item)
                         || Item <- xmerl_xpath:string("associationSet/item", Node)]},
     {entry_set, [ extract_acl_entry_item(Item)
                   || Item <- xmerl_xpath:string("entrySet/item", Node)]},
     {tag_set,
      [extract_tag_item(Item)
       || Item <- xmerl_xpath:string("tagSet/item", Node)]}
].

extract_acl_association_item(Node) ->
    [{network_acl_association_id, get_text("networkAclAssociationId", Node)},
     {network_acl_id, get_text("networkAclId", Node)},
     {subnet_id, get_text("subnetId", Node)}].

extract_acl_entry_item(Node) ->
    [{rule_number, get_text("ruleNumber", Node)},
     {protocol, get_text("protocol", Node)},
     {rule_action, get_text("ruleAction", Node)},
     {egress, get_text("egress", Node)},
     {cidr_block, get_text("cidrBlock", Node)},
     {port_range, extract_port_range(xmerl_xpath:string("portRange", Node))}
    ].

extract_port_range([]) ->
    [];

extract_port_range([Node]) ->
    [{from, get_text("from", Node)},
     {to, get_text("to", Node)}
].

-spec create_network_acl_entry(ec2_network_acl_spec()) -> ok_error().
create_network_acl_entry(Spec) ->
    create_network_acl_entry(Spec, default_config()).

-spec create_network_acl_entry(ec2_network_acl_spec(), aws_config()) -> ok_error().
create_network_acl_entry(Spec, Config) ->
    Params = network_acl_spec_to_params(Spec),
    ec2_simple_query(Config, "CreateNetworkAclEntry", Params, ?NEW_API_VERSION).

network_acl_spec_to_params(Spec) ->
    [{ "NetworkAclId", Spec#ec2_network_acl_spec.network_acl_id },
     { "RuleNumber", Spec#ec2_network_acl_spec.rule_number },
     { "Protocol", Spec#ec2_network_acl_spec.protocol },
     { "RuleAction", Spec#ec2_network_acl_spec.rule_action },
     { "Egress", Spec#ec2_network_acl_spec.egress },
     { "CidrBlock", Spec#ec2_network_acl_spec.cidr_block },
     { "Icmp.Code", Spec#ec2_network_acl_spec.icmp_code },
     { "Icmp.Type", Spec#ec2_network_acl_spec.icmp_type },
     { "PortRange.From", Spec#ec2_network_acl_spec.port_range_from },
     { "PortRange.To", Spec#ec2_network_acl_spec.port_range_to }].

-spec create_route(string(), string(), gateway_id | instance_id | network_interface_id, string()) -> ok_error().
create_route(RouteTableID, DestCidrBl, Attachment, Val) ->
    create_route(RouteTableID, DestCidrBl, Attachment, Val, default_config()).

-spec create_route(string(), string(), gateway_id | instance_id | network_interface_id, string(), aws_config()) -> ok_error().
create_route(RouteTableID, DestCidrBl, Attachment, Val, Config) ->
    ASpec= case Attachment of
               gateway_id -> {"GatewayId", Val};
               instance_id -> {"InstanceId", Val};
               network_interface_id -> {"NetworkInterfaceId", Val};
               _ -> {}
           end,
    Params = [ASpec, {"RouteTableId", RouteTableID},
              {"DestinationCidrBlock", DestCidrBl}],
    ec2_simple_query(Config, "CreateRoute", Params, ?NEW_API_VERSION).

-spec create_route_table(string()) -> ok_error([proplist()]).
create_route_table(VpcID) ->
    create_route_table(VpcID, default_config()).

-spec create_route_table(string(), aws_config()) -> ok_error([proplist()]).
create_route_table(VpcID, Config) ->
    case ec2_query(Config, "CreateRouteTable", [{"VpcId", VpcID}], ?NEW_API_VERSION) of
        {ok, Doc} ->
            Path = "/CreateRouteTableResponse/routeTable",
            {ok, [extract_route(RT) || RT <- xmerl_xpath:string(Path, Doc)]};
        {error, _} = Error ->
            Error
    end.

-spec create_subnet(string(), string()) -> ok_error(proplist()).
create_subnet(VpcID, CIDR) when is_list(VpcID), is_list(CIDR) ->
    create_subnet(VpcID, CIDR, none, default_config()).

-spec create_subnet(string(), string(), string() | aws_config()) -> ok_error(proplist()).
create_subnet(VpcID, CIDR, Config) when is_record(Config, aws_config) ->
    create_subnet(VpcID, CIDR, none, Config);
create_subnet(VpcID, CIDR, Zone) when is_list(Zone) ->
    create_subnet(VpcID, CIDR, Zone, default_config()).

-spec create_subnet(string(), string(), string() | none, aws_config()) -> ok_error(proplist()).
create_subnet(VpcID, CIDR, Zone, Config) when
      is_list(VpcID), is_list(CIDR), is_list(Zone) orelse Zone =:= none ->
    Params = [{"VpcId", VpcID}, {"CidrBlock", CIDR},
              {"AvailabilityZone", Zone}],
    case ec2_query(Config, "CreateSubnet", Params) of
        {ok, Doc} ->
            Node = hd(xmerl_xpath:string("/CreateSubnetResponse/subnet", Doc)),
            {ok, [extract_subnet(Node)]};
        {error, _} = Error ->
            Error
    end.

-spec create_security_group(string(), string()) -> ok_error().
create_security_group(GroupName, GroupDescription) ->
    create_security_group(GroupName, GroupDescription, none, default_config()).

-spec create_security_group(string(), string(), aws_config() | string() | none) -> ok_error().
create_security_group(GroupName, GroupDescription, Config)
  when is_record(Config, aws_config) ->
    create_security_group(GroupName, GroupDescription, none, Config);
create_security_group(GroupName, GroupDescription, VpcID) ->
    create_security_group(GroupName, GroupDescription, VpcID, default_config()).

-spec create_security_group(string(), string(), string() | none, aws_config()) -> ok_error().
create_security_group(GroupName, GroupDescription, VpcID, Config)
  when is_list(GroupName), is_list(GroupDescription) ->
    case ec2_query(Config, "CreateSecurityGroup",
                    [{"GroupName", GroupName}, {"GroupDescription", GroupDescription},
                     {"VpcId", VpcID}], ?NEW_API_VERSION) of
        {ok, Doc} ->
            case VpcID of
                none -> ok;
                _    -> {ok, get_text("/CreateSecurityGroupResponse/groupId", Doc)}
            end;
        {error, _} = Error ->
            Error
    end.

-spec create_snapshot(string()) -> ok_error(proplist()).
create_snapshot(VolumeID) ->
    create_snapshot(VolumeID, "", default_config()).

-spec create_snapshot(string(), string()) -> proplist() ; (string(), aws_config()) -> ok_error(proplist()).
create_snapshot(VolumeID, Config)
  when is_record(Config, aws_config) ->
    create_snapshot(VolumeID, "", Config);
create_snapshot(VolumeID, Description) ->
    create_snapshot(VolumeID, Description, default_config()).

-spec create_snapshot(string(), string(), aws_config()) -> ok_error(proplist());
                     (string(), string(), [{string(), string()}]) -> ok_error(proplist()).
create_snapshot(VolumeID, Description, Config)
  when is_record(Config, aws_config) ->
    create_snapshot(VolumeID, Description, [], Config);
create_snapshot(VolumeID, Description, TagList)
  when is_list(TagList) ->
    create_snapshot(VolumeID, Description, TagList, default_config()).

-spec create_snapshot(string(), string(), [{string(), string()}], aws_config()) -> ok_error(proplist()).
create_snapshot(VolumeID, Description, TagList, Config)
  when is_list(VolumeID), is_list(Description), is_list(TagList), is_record(Config, aws_config) ->
    DefaultParams = [{"VolumeId", VolumeID}, {"Description", Description}],
    TagParams = tags_parameters("snapshot", TagList),
    Params = DefaultParams ++ TagParams,
    case ec2_query(Config, "CreateSnapshot", Params, ?NEW_API_VERSION) of
        {ok, Doc} ->
            {ok, [
                 {snapshot_id, get_text("/CreateSnapshotResponse/snapshotId", Doc)},
                 {volume_id, get_text("/CreateSnapshotResponse/volumeId", Doc)},
                 {volume_size, get_integer("/CreateSnapshotResponse/volumeSize", Doc)},
                 {status, get_text("/CreateSnapshotResponse/status", Doc)},
                 {start_time, erlcloud_xml:get_time("/CreateSnapshotResponse/attachTime", Doc)},
                 {progress, get_text("/CreateSnapshotResponse/progress", Doc)},
                 {owner_id, get_text("/CreateSnapshotResponse/ownerId", Doc)},
                 {description, get_text("/CreateSnapshotResponse/description", Doc)},
                 {tag_set, [extract_tag_item(Item) || Item <- xmerl_xpath:string("tagSet/item", Doc, [])]}
            ]};
        {error, _} = Error ->
            Error
    end.

-spec create_spot_datafeed_subscription(string()) -> ok_error(proplist()).
create_spot_datafeed_subscription(Bucket) ->
    create_spot_datafeed_subscription(Bucket, none).

-spec create_spot_datafeed_subscription(string(), string() | none | aws_config()) -> ok_error(proplist()).
create_spot_datafeed_subscription(Bucket, Config)
  when is_record(Config, aws_config) ->
    create_spot_datafeed_subscription(Bucket, none, Config);
create_spot_datafeed_subscription(Bucket, Prefix) ->
    create_spot_datafeed_subscription(Bucket, Prefix, default_config()).

-spec create_spot_datafeed_subscription(string(), string() | none, aws_config()) -> ok_error(proplist()).
create_spot_datafeed_subscription(Bucket, Prefix, Config)
  when is_list(Bucket),
       is_list(Prefix) orelse Prefix =:= none ->
    case ec2_query(Config, "CreateSpotDatafeedSubscription", [{"Bucket", Bucket}, {Prefix, Prefix}]) of
        {ok, Doc} ->
            {ok, extract_spot_datafeed_subscription(xmerl_xpath:string("/CreateSpotDatafeedSubscriptionResponse/spotDatafeedSubscription", Doc))};
        {error, _} = Error ->
            Error
    end.

extract_spot_datafeed_subscription([Node]) ->
    [
     {owner_id, get_text("ownerId", Node)},
     {bucket, get_text("bucket", Node)},
     {prefix, get_text("prefix", Node)},
     {state, get_text("state", Node)},
     {fault, [{code, get_text("fault/code", Node)},
              {message, get_text("fault/message", Node)}
             ]}
    ].

-spec create_volume(ec2_volume_size(), string(), string()) -> ok_error(proplist()).
create_volume(Size, SnapshotID, AvailabilityZone) ->
    create_volume(Size, SnapshotID, AvailabilityZone,"standard", default_config()).

-spec create_volume(ec2_volume_size(), string(), string(), string()) -> ok_error(proplist()).
create_volume(Size, SnapshotID, AvailabilityZone, VolumeType) ->
    create_volume(Size, SnapshotID, AvailabilityZone,VolumeType, default_config()).

-spec create_volume(ec2_volume_size(), string(), string(), string(), aws_config()) -> ok_error(proplist());
                   (ec2_volume_size(), string(), string(), string(), [{string(), string()}]) -> ok_error(proplist()).
create_volume(Size, SnapshotID, AvailabilityZone, VolumeType, Config)
  when is_record(Config, aws_config) ->
    create_volume(Size, SnapshotID, AvailabilityZone, VolumeType, [], Config);
create_volume(Size, SnapshtID, AvailabilityZone, VolumeType, Tags)
  when is_list(Tags) ->
    create_volume(Size, SnapshtID, AvailabilityZone, VolumeType, Tags, default_config()).

-spec create_volume(ec2_volume_size(), string(), string(), string(), [{string(), string()}], aws_config()) -> ok_error(proplist()).
create_volume(Size, SnapshotID, AvailabilityZone, VolumeType, Tags, Config)
  when ((VolumeType == "standard" andalso Size >= 1 andalso Size =< 1024) orelse
        (VolumeType == "gp2" andalso Size >= 1 andalso Size =< 16384) orelse
        (VolumeType == "io1" andalso Size >= 4 andalso Size =< 16384)),
       is_list(SnapshotID) orelse SnapshotID =:= none,
       is_list(AvailabilityZone),
       is_list(Tags) ->
    DefaultParams = [
              {"Size", integer_to_list(Size)},
              {"AvailabilityZone", AvailabilityZone},
              {"SnapshotId", SnapshotID},
              {"VolumeType",VolumeType}
             ],
    TagsParams = tags_parameters("volume", Tags),
    Params = DefaultParams ++ TagsParams,
    case ec2_query(Config, "CreateVolume", Params,?NEW_API_VERSION) of
        {ok, Doc} ->
            {ok, [
                {volume_id, get_text("volumeId", Doc)},
                {size, get_integer("size", Doc)},
                {snapshot_id, get_text("snapshotId", Doc, none)},
                {availability_zone, get_text("availabilityZone", Doc, none)},
                {status, get_text("status", Doc, none)},
                {create_time, erlcloud_xml:get_time("createTime", Doc)},
                {volumeType, get_text("volumeType", Doc, none)},
                {tag_set, [extract_tag_item(Item) || Item <- xmerl_xpath:string("tagSet/item", Doc, [])]}
            ]};
        {error, _} = Error ->
            Error
    end.

-spec create_vpc(string()) -> ok_error(proplist()).
create_vpc(CIDR) ->
    create_vpc(CIDR, none, default_config()).

-spec create_vpc(string(), string() | none | aws_config()) -> ok_error(proplist()).
create_vpc(CIDR, InsTen) when is_list(InsTen) ->
    create_vpc(CIDR, InsTen, default_config());
create_vpc(CIDR, Config) when is_record(Config, aws_config) ->
    create_vpc(CIDR, none, Config).

-spec create_vpc(string(), string() | none, aws_config()) -> ok_error(proplist()).
create_vpc(CIDR, InsTen, Config) when
      is_list(CIDR), is_list(InsTen) orelse InsTen =:= none ->
    case ec2_query(Config, "CreateVpc", [{"CidrBlock", CIDR}, {"instanceTenancy", InsTen}]) of
        {ok, Doc} ->
            {ok, [
                {vpc_id, get_text("/CreateVpcResponse/vpc/vpcId", Doc)},
                {state, get_text("/CreateVpcResponse/vpc/state", Doc)},
                {cidr_block, get_text("/CreateVpcResponse/vpc/cidrBlock", Doc)},
                {dhcp_options_id, get_text("/CreateVpcResponse/vpc/dhcpOptionsId", Doc)}
            ]};
        {error, _} = Error ->
            Error
    end.

-spec delete_internet_gateway(string()) -> ok_error().
delete_internet_gateway(GatewayID) ->
    delete_internet_gateway(GatewayID, default_config()).

-spec delete_internet_gateway(string(), aws_config()) -> ok_error().
delete_internet_gateway(GatewayID, Config) ->
    ec2_simple_query(Config, "DeleteInternetGateway",
                     [{"InternetGatewayId", GatewayID}], ?NEW_API_VERSION).

-spec delete_key_pair(string()) -> ok_error().
delete_key_pair(KeyName) -> delete_key_pair(KeyName, default_config()).

-spec delete_key_pair(string(), aws_config()) -> ok_error().
delete_key_pair(KeyName, Config)
  when is_list(KeyName) ->
    ec2_simple_query(Config, "DeleteKeyPair", [{"KeyName", KeyName}]).

-spec delete_network_acl(string()) -> ok_error().
delete_network_acl(NetworkAclId) ->
    delete_network_acl(NetworkAclId, default_config()).

-spec delete_network_acl(string(), aws_config()) -> ok_error().
delete_network_acl(NetworkAclId, Config) ->
    ec2_simple_query(Config, "DeleteNetworkAcl",
                     [{"NetworkAclId", NetworkAclId}], ?NEW_API_VERSION).

-spec delete_network_acl_entry(string(), string()) -> ok_error().
delete_network_acl_entry(NetworkAclID, RuleNumber) ->
    delete_network_acl_entry(NetworkAclID, RuleNumber, false, default_config()).

-spec delete_network_acl_entry(string(), string(), boolean() | aws_config()) -> ok_error().
delete_network_acl_entry(NetworkAclID, RuleNumber, Config)
  when is_record(Config, aws_config) ->
    delete_network_acl_entry(NetworkAclID, RuleNumber, false, Config);
delete_network_acl_entry(NetworkAclID, RuleNumber, Egress) ->
    delete_network_acl_entry(NetworkAclID, RuleNumber, Egress, default_config()).

-spec delete_network_acl_entry(string(), string(), boolean(), aws_config()) -> ok_error().
delete_network_acl_entry(NetworkAclID, RuleNumber, Egress, Config) ->
    Params = [{"NetworkAclId", NetworkAclID},
              {"RuleNumber", RuleNumber},
              {"Egress", Egress}],
    ec2_simple_query(Config, "DeleteNetworkAclEntry", Params, ?NEW_API_VERSION).

-spec delete_route(string(), string()) -> ok_error().
delete_route(RouteTableID, DestCidrBlock) ->
    delete_route(RouteTableID, DestCidrBlock, default_config()).

-spec delete_route(string(), string(), aws_config()) -> ok_error().
delete_route(RouteTableID, DestCidrBlock, Config) ->
    Params = [{"RouteTableId", RouteTableID},
              {"DestinationCidrBlock", DestCidrBlock}],
    ec2_simple_query(Config, "DeleteRoute", Params, ?NEW_API_VERSION).

-spec delete_route_table(string()) -> ok_error().
delete_route_table(RouteTableID) ->
    delete_route_table(RouteTableID, default_config()).

-spec delete_route_table(string(), aws_config()) -> ok_error().
delete_route_table(RouteTableID, Config) ->
    ec2_simple_query(Config, "DeleteRouteTable",
                     [{"RouteTableId", RouteTableID}], ?NEW_API_VERSION).

-spec delete_security_group(string()) -> ok_error().
delete_security_group(GroupName) ->
    delete_security_group(groupName, GroupName, default_config()).

-spec delete_security_group(groupId | groupName | string(), string() | aws_config()) -> ok_error().
delete_security_group(GroupName, Config)
  when is_list(GroupName), is_record(Config, aws_config) ->
    delete_security_group(groupName, GroupName, Config);
delete_security_group(Param, GroupName)
  when is_atom(Param), is_list(GroupName) ->
    delete_security_group(Param, GroupName, default_config()).

-spec delete_security_group(groupId | groupName, string(), aws_config()) -> ok_error().
delete_security_group(Param, GroupName, Config) ->
    ParamStr = atom_to_list(Param),
    Key = [string:to_upper(hd(ParamStr)) | tl(ParamStr)],
    ec2_simple_query(Config, "DeleteSecurityGroup", [{Key, GroupName}], ?NEW_API_VERSION).

-spec delete_snapshot(string()) -> ok_error().
delete_snapshot(SnapshotID) -> delete_snapshot(SnapshotID, default_config()).

-spec delete_snapshot(string(), aws_config()) -> ok_error().
delete_snapshot(SnapshotID, Config)
  when is_list(SnapshotID) ->
    ec2_simple_query(Config, "DeleteSnapshot", [{"SnapshotId", SnapshotID}]).

-spec delete_spot_datafeed_subscription() -> ok_error().
delete_spot_datafeed_subscription() -> delete_spot_datafeed_subscription(default_config()).

-spec delete_spot_datafeed_subscription(aws_config()) -> ok_error().
delete_spot_datafeed_subscription(Config) ->
    ec2_simple_query(Config, "DeleteSpotDatafeedSubscription", []).

-spec delete_subnet(string()) -> ok_error().
delete_subnet(SubnetID) when is_list(SubnetID) ->
    delete_subnet(SubnetID, default_config()).

-spec delete_subnet(string(), aws_config()) -> ok_error().
delete_subnet(SubnetID, Config) when is_list(SubnetID) ->
    ec2_simple_query(Config, "DeleteSubnet", [{"SubnetId", SubnetID}]).

-spec delete_volume(string()) -> ok_error().
delete_volume(VolumeID) -> delete_volume(VolumeID, default_config()).

-spec delete_volume(string(), aws_config()) -> ok_error().
delete_volume(VolumeID, Config)
  when is_list(VolumeID) ->
    ec2_simple_query(Config, "DeleteVolume", [{"VolumeId", VolumeID}]).

-spec delete_vpc(string()) -> ok_error().
delete_vpc(ID) ->
    delete_vpc(ID, default_config()).

-spec delete_vpc(string(), aws_config()) -> ok_error().
delete_vpc(ID, Config) ->
    ec2_simple_query(Config, "DeleteVpc", [{"VpcId", ID}]).

-spec deregister_image(string()) -> ok_error().
deregister_image(ImageID) -> deregister_image(ImageID, default_config()).

-spec deregister_image(string(), aws_config()) -> ok_error().
deregister_image(ImageID, Config)
  when is_list(ImageID) ->
    ec2_simple_query(Config, "DeregisterImage", [{"ImageId", ImageID}]).

-spec describe_addresses() -> ok_error(proplist()).
describe_addresses() -> describe_addresses([]).

-spec describe_addresses([string()] | aws_config()) -> ok_error(proplist()).
describe_addresses(Config) when is_record(Config, aws_config) ->
    describe_addresses([], Config);
describe_addresses(PublicIPs) when is_list(PublicIPs) ->
    describe_addresses(PublicIPs, default_config()).

-spec describe_addresses([string()], aws_config()) -> ok_error(proplist()).
describe_addresses(PublicIPs, Config) ->
    describe_addresses(PublicIPs, none, Config).

-spec describe_addresses([string()], filter_list(), aws_config()) -> ok_error(proplist()).
describe_addresses(PublicIPs, Filters, Config) ->
    Params = lists:append(
        erlcloud_aws:param_list(PublicIPs, "PublicIp"),
        list_to_ec2_filter(Filters)
    ),
    case ec2_query(Config, "DescribeAddresses", Params, ?NEW_API_VERSION) of
        {ok, Doc} ->
            Items = xmerl_xpath:string("/DescribeAddressesResponse/addressesSet/item", Doc),
            {ok, [extract_address(Item) || Item <- Items]};
        {error, _} = Error ->
            Error
    end.

extract_address(Node) ->
    [{public_ip, get_text("publicIp", Node)},
     {allocation_id, get_text("allocationId", Node)},
     {domain, get_text("domain", Node)},
     {instance_id, get_text("instanceId", Node, none)},
     {association_id, get_text("associationId", Node, none)},
     {network_interface_id, get_text("networkInterfaceId", Node, none)},
     {network_interface_owner_id, get_text("networkInterfaceOwnerId", Node, none)},
     {private_ip_address, get_text("privateIpAddress", Node, none)}].

-spec describe_availability_zones() -> ok_error(proplist()).
describe_availability_zones() -> describe_availability_zones([]).
-spec describe_availability_zones([string()] | aws_config()) -> ok_error(proplist()).
describe_availability_zones(Config)
  when is_record(Config, aws_config) ->
    describe_availability_zones([], Config);
describe_availability_zones(ZoneNames) ->
    describe_availability_zones(ZoneNames, default_config()).

-spec describe_availability_zones([string()], aws_config()) -> ok_error(proplist()).
describe_availability_zones(ZoneNames, Config)
  when is_list(ZoneNames) ->
    case ec2_query(Config, "DescribeAvailabilityZones", erlcloud_aws:param_list(ZoneNames, "ZoneName")) of
        {ok, Doc} ->
            Items = xmerl_xpath:string("/DescribeAvailabilityZonesResponse/availabilityZoneInfo/item", Doc),
            {ok, [[{zone_name, get_text("zoneName", Item)},
              {zone_state, get_text("zoneState", Item)},
              {region_name, get_text("regionName", Item)},
              {messages, get_list("messageSet/item/message", Item)}
             ] || Item <- Items]};
        {error, _} = Error ->
            Error
    end.

-spec describe_bundle_tasks() -> ok_error(proplist()).
describe_bundle_tasks() ->
    describe_bundle_tasks([]).

-spec describe_bundle_tasks([string()] | aws_config()) -> ok_error(proplist()).
describe_bundle_tasks(Config)
  when is_record(Config, aws_config) ->
    describe_bundle_tasks([], Config);
describe_bundle_tasks(BundleIDs) ->
    describe_bundle_tasks(BundleIDs, default_config()).

-spec describe_bundle_tasks([string()], aws_config()) -> ok_error(proplist()).
describe_bundle_tasks(BundleIDs, Config) ->
    case ec2_query(Config, "DescribeBundleTasks", erlcloud_aws:param_list(BundleIDs, "BundleId")) of
        {ok, Doc} ->
            {ok, [extract_bundle_task(Item) || Item <- xmerl_xpath:string("/DescribeBundleTasksResponse/bundleInstanceTasksSet/item", Doc)]};
        {error, _} = Error ->
            Error
    end.

-spec describe_dhcp_options() -> ok_error(proplist()).
describe_dhcp_options() ->
    describe_dhcp_options(none, default_config()).

-spec describe_dhcp_options(aws_config() | filter_list() | none) -> ok_error(proplist()).
describe_dhcp_options(Config) when is_record(Config, aws_config) ->
    describe_dhcp_options(none, Config);
describe_dhcp_options(Filter) when is_list(Filter) orelse Filter =:= none ->
    describe_dhcp_options(Filter, default_config()).

-spec describe_dhcp_options(none | filter_list(), aws_config()) -> ok_error(proplist()).
describe_dhcp_options(Filter, Config) ->
    Params = list_to_ec2_filter(Filter),
    case ec2_query(Config, "DescribeDhcpOptions", Params, ?NEW_API_VERSION) of
        {ok,  Doc} ->
            Path = "/DescribeDhcpOptionsResponse/dhcpOptionsSet/item",
            {ok, [ extract_dhcp_opts(Item) || Item <- xmerl_xpath:string(Path, Doc) ]};
        {error, _} = Error ->
            Error
    end.

extract_dhcp_opts(Node) ->
    Path = "dhcpConfigurationSet/item",
    [ {dhcp_options_id, get_text("dhcpOptionsId", Node)},
      {configuration_set, [ extract_dhcp_opt_kv(Item) ||
                              Item <- xmerl_xpath:string(Path, Node) ]} ].
extract_dhcp_opt_kv(Node) ->
    [ {key, get_text("key", Node)},
      {value, get_text("valueSet/item/value", Node)} ].

-spec describe_image_attribute(string(), atom()) -> ok_error(proplist()).
describe_image_attribute(ImageID, Attribute) ->
    describe_image_attribute(ImageID, Attribute, default_config()).

-spec describe_image_attribute(string(), atom(), aws_config()) -> ok_error(proplist()).
describe_image_attribute(ImageID, Attribute, Config)
  when is_list(ImageID), is_atom(Attribute) ->
    AttributeName = case Attribute of
                        launch_permission -> "launchPermission";
                        product_codes -> "productCodes";
                        block_device_mapping -> "blockDeviceMapping"
                    end,
    case ec2_query(Config, "DescribeImageAttribute", [{"ImageId", ImageID}, {"Attribute", AttributeName}]) of
        {ok, Doc} ->
            case Attribute of
                launch_permission ->
                    {ok, extract_permissions(xmerl_xpath:string("/DescribeImageAttributeResponse/launchPermission/item", Doc))};
                product_codes ->
                    {ok, get_list("/DescribeImageAttributeResponse/productCodes/item/productCode", Doc)};
                block_device_mapping ->
                    {ok, [extract_block_device_mapping(Node) || Node <- xmerl_xpath:string("/DescribeImageAttributeResponse/blockDeviceMapping/item", Doc)]}
            end;
        {error, _} = Error ->
            Error
    end.

extract_permissions(Nodes) ->
    extract_permissions(Nodes, []).

extract_permissions([], Accum) ->
    lists:reverse(Accum);
extract_permissions([Node|Nodes], Accum) ->
    case {erlcloud_xml:get_text("userId", Node), erlcloud_xml:get_text("groupId", Node)} of
        {[], []} -> extract_permissions(Nodes, Accum);
        {UserId, []} -> extract_permissions(Nodes, [{user_id, UserId}|Accum]);
        {[], GroupId} -> extract_permissions(Nodes, [{groupId, GroupId}|Accum])
    end.

%%
%% Returns a list of all images Executable by the current user.
%% Responses in the form:
%% [[
%%    image_id: 'ami-001af160',
%%    image_location: '<accountid>/<image-name>',
%%    image_state: 'available',
%%    image_owner_id: '<accountid>',
%%    is_public: false, architecture: 'x86_64',
%%    image_type: 'machine',
%%    kernel_id: [],
%%    ramdisk_id: [],
%%    image_owner_alias: :none,
%%    name: '<image-name>',
%%    description: [],
%%    root_device_type: 'ebs', root_device_name: '/dev/sda1',
%%    creation_date: {{2016, 3, 26}, {12, 14, 20}},
%%    platform: [],
%%    block_device_mapping: [
%%      {:ec2_block_device_mapping, '/dev/sda1', [], 'snap-1a1a1a1a', 16, true},
%%      {:ec2_block_device_mapping, '/dev/sdg', [], 'snap-1b1b1b1b', 1000, false},
%%      {:ec2_block_device_mapping, '/dev/sdb', 'ephemeral0', :none, 0, false},
%%      {:ec2_block_device_mapping, '/dev/sdc', 'ephemeral1', :none, 0, false}
%%    ],
%%    product_codes: []
%% ]]
%%
-spec describe_images() -> ok_error(proplist()).
describe_images() -> describe_images([], "self").

%% Uses an config other than the one set for the current process.
%% See describe_images/0 for return term
-spec describe_images([string()] | aws_config()) -> ok_error(proplist()).
describe_images(Config)
  when is_record(Config, aws_config) ->
    describe_images([], "self", none, Config);

%% Describes images with ImageIDs owned by the current user using a "self"s Config.
%% See describe_images/0 for return term
describe_images(ImageIDs) ->
    describe_images(ImageIDs, none, none, default_config()).

%% Describes images with ImageIDs if owned by current user using an alternate Config.
%% See describe_images/0 for return term
-spec describe_images([string()], aws_config() | string() | none) -> ok_error(proplist()).
describe_images(ImageIDs, Config)
  when is_record(Config, aws_config) ->
    describe_images(ImageIDs, none, none, Config);

%% Describes images with ImageIDs if owned by Owner (useful for corporate accounts) using "self"s Config.
%% use [] for all images owned by Owner
%% Owner is a numeric id. It can be found on the AMIs page of the web console
%% See describe_images/0 for return term
describe_images(ImageIDs, Owner) ->
    describe_images(ImageIDs, Owner, none, default_config()).

-spec describe_images([string()], string() | none, aws_config() | string() | none) -> ok_error(proplist()).

%% Describes images with ImageIDs if Owned by Owner (useful for corporate accounts) using an alternate Config.
%% See describe_images/0 for return term
describe_images(ImageIDs, Owner, Config)
  when is_record(Config, aws_config) ->
    describe_images(ImageIDs, Owner, none, Config);

%% Describes images with ImageIDs if owned by Owner and executable by ExecutableBy
%% See describe_images/0 for return term
describe_images(ImageIDs, Owner, ExecutableBy) ->
    describe_images(ImageIDs, Owner, ExecutableBy, default_config()).

%% Describes images with ImageIDs if owned by Owner and executable by ExecutableBy using an alternate Config
%% See describe_images/0 for return term

-spec describe_images([string()],
                       string() | none, string() | none, aws_config()) -> ok_error(proplist()).
describe_images(ImageIDs, Owner, ExecutableBy, Config) 
  when is_list(ImageIDs),
       is_list(Owner) orelse Owner =:= none,
       is_list(ExecutableBy) orelse ExecutableBy =:= none,
       is_record(Config, aws_config) ->
    describe_images(ImageIDs, Owner, ExecutableBy, none, Config).

-spec describe_images([string()],
                       string() | none,
                       string() | none,
                       filter_list(),
                       aws_config()) -> ok_error(proplist()).
describe_images(ImageIDs, Owner, ExecutableBy, Filters, Config)
  when is_list(ImageIDs),
       is_list(Owner) orelse Owner =:= none,
       is_list(ExecutableBy) orelse ExecutableBy =:= none,
       is_list(Filters) orelse Filters =:= none,
       is_record(Config, aws_config)->
    Params = [
              {"ExecutableBy", ExecutableBy}, {"Owner", Owner} |
              erlcloud_aws:param_list(ImageIDs, "ImageId")
             ] ++ list_to_ec2_filter(Filters),
    case ec2_query(Config, "DescribeImages", Params, ?NEW_API_VERSION) of
        {ok, Doc} ->
            {ok, [extract_image(Item) || Item <- xmerl_xpath:string("/DescribeImagesResponse/imagesSet/item", Doc)]};
        {error, _} = Error ->
            Error
    end.

extract_image(Node) ->
    [{image_id, get_text("imageId", Node)},
     {image_location, get_text("imageLocation", Node)},
     {image_state, get_text("imageState", Node)},
     {image_owner_id, get_text("imageOwnerId", Node)},
     {is_public, get_bool("isPublic", Node)},
     {architecture, get_text("architecture", Node)},
     {image_type, get_text("imageType", Node)},
     {kernel_id, get_text("kernelId", Node)},
     {ramdisk_id, get_text("ramdiskId", Node)},
     {image_owner_alias, get_text("imageOwnerAlias", Node, none)},
     {name, get_text("name", Node)},
     {description, get_text("description", Node)},
     {root_device_type, get_text("rootDeviceType", Node)},
     {root_device_name, get_text("rootDeviceName", Node)},
     {creation_date, erlcloud_xml:get_time("creationDate", Node)},
     {platform, get_text("platform", Node)},
     {block_device_mapping, [extract_block_device_mapping(Item) || Item <- xmerl_xpath:string("blockDeviceMapping/item", Node)]},
     {product_codes, [extract_product_code(Item) || Item <- xmerl_xpath:string("productCodes/item", Node)]},
     {tag_set, [extract_tag_item(Item) || Item <- xmerl_xpath:string("tagSet/item", Node, [])]}
    ].

extract_block_device_mapping(Node) ->
    #ec2_block_device_mapping{
                              device_name=get_text("deviceName", Node),
                              virtual_name=get_text("virtualName", Node),
                              snapshot_id=get_text("ebs/snapshotId", Node, none),
                              volume_size=list_to_integer(get_text("ebs/volumeSize", Node, "0")),
                              delete_on_termination=get_bool("ebs/deleteOnTermination", Node),
                              encrypted=get_bool("ebs/encrypted", Node)
                             }.

extract_product_code(Node) ->
    [
        {product_code, get_text("productCode", Node)},
        {type, get_text("type", Node)}
    ].

-spec describe_instance_attribute(string(), atom()) -> proplist().
describe_instance_attribute(InstanceID, Attribute) ->
    describe_instance_attribute(InstanceID, Attribute, default_config()).

-spec describe_instance_attribute(string(), atom(), aws_config()) -> term().
describe_instance_attribute(InstanceID, Attribute, Config)
  when is_list(InstanceID), is_atom(Attribute) ->
    AttributeName = case Attribute of
                        instance_type -> "instanceType";
                        kernel -> "kernel";
                        ramdisk -> "ramdisk";
                        user_data -> "userData";
                        disable_api_termination -> "disableApiTermination";
                        instance_initiated_shutdown_behavior -> "instanceInitiatedShutdownBehavior";
                        root_device_name -> "rootDeviceName";
                        block_device_mapping -> "blockDeviceMapping"
                    end,
    case ec2_query(Config, "DescribeInstanceAttribute", [{"InstanceId", InstanceID}, {"Attribute", AttributeName}]) of
        {ok, Doc} ->
            case xmerl_xpath:string(attribute_xpath(Attribute, AttributeName), Doc) of
                                                        % attribute might not be defined
                [] ->
                    undefined;
                [Node | _] ->
                    case Attribute of
                        user_data -> base64:decode(get_text(Node));
                        disable_api_termination -> list_to_existing_atom(get_text(Node));
                        instance_initiated_shutdown_behavior -> list_to_existing_atom(get_text(Node));
                        block_device_mapping ->
                            [extract_block_device_mapping_status(Item) || Item <- xmerl_xpath:string("item", Node)];
                        _ -> get_text(Node)
                    end
            end;
        {error, _} = Error ->
            Error
    end.

attribute_xpath(block_device_mapping, AttributeName) ->
    "/DescribeInstanceAttributeResponse/" ++ AttributeName;
attribute_xpath(_, AttributeName) ->
    "/DescribeInstanceAttributeResponse/" ++ AttributeName ++ "/value".

%%
%% Function for making calls to DescribeInstances action
%% DescribeInstances Documentation: docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DescribeInstances.html
%%
-spec describe_instances() -> ok_error([proplist()]).
describe_instances() ->
    describe_instances([],[],default_config()).

-spec describe_instances(aws_config()) -> ok_error([proplist()]);
                        (ec2_instances_ids()) -> ok_error([proplist()]).
describe_instances(Config)
    when is_record(Config, aws_config) ->
    describe_instances([], Config);
describe_instances(InstanceIDs) ->
    describe_instances(InstanceIDs, [], default_config()).

-spec describe_instances(ec2_instances_ids(), filter_list()) -> ok_error([proplist()]);
                        (ec2_instances_ids(), aws_config()) -> ok_error([proplist()]);
                        (ec2_max_result(), ec2_token()) -> ok_error([proplist()], ec2_token()).
describe_instances(InstanceIDs, Filter)
    when is_list(InstanceIDs), is_list(Filter) orelse Filter =:= none ->
    describe_instances(InstanceIDs, Filter, default_config());
describe_instances(InstanceIDs, Config)
    when is_list(InstanceIDs), is_record(Config, aws_config) ->
    describe_instances(InstanceIDs, [], Config).

-spec describe_instances(ec2_instances_ids(), filter_list(), aws_config()) -> ok_error([proplist()]);
                        (filter_list(), ec2_max_result(), ec2_token()) -> ok_error([proplist()], ec2_token()).
describe_instances(InstanceIDs, Filter, Config)
    when is_list(InstanceIDs), is_list(Filter) orelse Filter =:= none , is_record(Config, aws_config) ->
    Params = erlcloud_aws:param_list(InstanceIDs, "InstanceId") ++ list_to_ec2_filter(Filter),
    case ec2_query(Config, "DescribeInstances", Params, ?NEW_API_VERSION) of
        {ok, Doc} ->
            Results = extract_results("DescribeInstancesResponse", "reservationSet", fun extract_reservation/1, Doc),
            {ok, Results};
        {error, _} = E -> E
    end;
describe_instances(Filter, MaxResults, NextToken)
    when is_list(Filter) orelse Filter =:= none,
         is_integer(MaxResults),
         is_list(NextToken) orelse NextToken =:= undefined ->
    describe_instances(Filter, MaxResults, NextToken, default_config()).

-spec describe_instances(filter_list(), ec2_max_result(), ec2_token(), aws_config())
    -> ok_error([proplist()], ec2_token()).
describe_instances(Filter, MaxResults, NextToken, Config)
    when is_list(Filter) orelse Filter =:= none,
         is_integer(MaxResults) andalso MaxResults >= ?INSTANCES_MR_MIN andalso MaxResults =< ?INSTANCES_MR_MAX,
         is_list(NextToken) orelse NextToken =:= undefined,
         is_record(Config, aws_config) ->
    Params = [{"MaxResults", MaxResults}, {"NextToken", NextToken}] ++
             list_to_ec2_filter(Filter),
    case ec2_query(Config, "DescribeInstances", Params, ?NEW_API_VERSION) of
        {ok, Doc} ->
            Reservations = extract_results("DescribeInstancesResponse", "reservationSet", fun extract_reservation/1, Doc),
            NewNextToken = extract_next_token("DescribeInstancesResponse", Doc),
            {ok, Reservations, NewNextToken};
        {error,  _} = E -> E
    end.
    
extract_reservation(Node) ->
    [{reservation_id, get_text("reservationId", Node)},
     {owner_id, get_text("ownerId", Node)},
     %% {group_set, get_list("groupSet/item/groupId", Node)},
     {instances_set, [extract_instance(Item) || Item <- xmerl_xpath:string("instancesSet/item", Node)]}
    ].

extract_instance(Node) ->
    [{instance_id, get_text("instanceId", Node)},
     {group_set, [extract_group(Item) || Item <- xmerl_xpath:string("groupSet/item", Node)]},
     {image_id, get_text("imageId", Node)},
     {instance_state, [
                       {code, list_to_integer(get_text("instanceState/code", Node, "0"))},
                       {name, get_text("instanceState/name", Node)}
                      ]},
     {private_dns_name, get_text("privateDnsName", Node)},
     {dns_name, get_text("dnsName", Node)},
     {reason, get_text("reason", Node, none)},
     {key_name, get_text("keyName", Node, none)},
     {metadata_options, transform_item_list(Node, "metadataOptions", fun extract_metadata_options/1)},
     {ami_launch_index, list_to_integer(get_text("amiLaunchIndex", Node, "0"))},
     {product_codes, get_list("productCodes/item/productCode", Node)},
     {instance_type, get_text("instanceType", Node)},
     {launch_time, erlcloud_xml:get_time("launchTime", Node)},
     {platform, get_text("platform", Node)},
     {placement, [{availability_zone, get_text("placement/availabilityZone", Node)}]},
     {kernel_id, get_text("kernelId", Node)},
     {ramdisk_id, get_text("ramdiskId", Node)},
     {monitoring, [{enabled, get_bool("monitoring/enabled", Node)}, {state, get_text("monitoring/state", Node)}]},
     {subnet_id, get_text("subnetId", Node)},
     {vpc_id, get_text("vpcId", Node)},
     {private_ip_address, get_text("privateIpAddress", Node)},
     {ip_address, get_text("ipAddress", Node)},
     {state_reason, [{code, get_text("stateReason/code", Node)}, {message, get_text("stateReason/message", Node)}]},
     {architecture, get_text("architecture", Node)},
     {root_device_type, get_text("rootDeviceType", Node)},
     {root_device_name, get_text("rootDeviceName", Node)},
     {block_device_mapping, [extract_block_device_mapping_status(Item) || Item <- xmerl_xpath:string("blockDeviceMapping/item", Node)]},
     {instance_lifecycle, get_text("instanceLifecycle", Node, none)},
     {spot_instance_request_id, get_text("spotInstanceRequestId", Node, none)},
     {iam_instance_profile, [
                             {arn, get_text("iamInstanceProfile/arn", Node)},
                             {id, get_text("iamInstanceProfile/id", Node)}
                            ]},
     {tag_set,
      [extract_tag_item(Item)
       || Item <- xmerl_xpath:string("tagSet/item", Node)]},
     {network_interface_set, [extract_network_interface(Item) || Item <- xmerl_xpath:string("networkInterfaceSet/item", Node)]}
    ].

extract_group(Node) ->
     [{group_id, get_text("groupId", Node)},
      {group_name, get_text("groupName", Node)}
     ].

extract_block_device_mapping_status(Node) ->
    [
     {device_name, get_text("deviceName", Node)},
     {volume_id, get_text("ebs/volumeId", Node)},
     {status, get_text("ebs/status", Node)},
     {attach_time, erlcloud_xml:get_time("ebs/attachTime", Node)},
     {delete_on_termination, get_bool("ebs/deleteOnTermination", Node)}
    ].

-spec describe_instance_status(instance_id()) -> ok_error([proplist()]).
describe_instance_status(InstanceID)
    when is_list(InstanceID) ->
    describe_instance_status([{"InstanceId", InstanceID}], [], default_config()).

-spec describe_instance_status(ec2_param_list(), filter_list()) -> ok_error([proplist()]);
                              (ec2_max_result(), ec2_token()) -> ok_error([proplist()], ec2_token()).
describe_instance_status(Params, Filter)
    when is_list(Params), is_list(Filter) orelse Filter =:= none ->
    describe_instance_status(Params, Filter, default_config()).

-spec describe_instance_status(ec2_param_list(), filter_list(), aws_config()) -> ok_error([proplist()]).
describe_instance_status(Params, Filter, Config)
    when is_list(Params), is_list(Filter) orelse Filter =:= none, is_record(Config, aws_config) ->
    AllParams = Params ++ list_to_ec2_filter(Filter),
    case ec2_query(Config, "DescribeInstanceStatus", AllParams, ?NEW_API_VERSION) of
        {ok, Doc} ->
            Statuses = extract_results("DescribeInstanceStatusResponse", "instanceStatusSet", fun extract_instance_status/1, Doc),
            {ok, Statuses};
        {error, _} = E -> E
    end.

-spec describe_instance_status(ec2_param_list(), filter_list(), ec2_max_result(), ec2_token())
    -> ok_error([proplist()], ec2_token()).
describe_instance_status(Params, Filter, MaxResults, NextToken)
    when is_list(Params),
         is_list(Filter) orelse Filter =:= none,
         is_integer(MaxResults),
         is_list(NextToken) orelse NextToken =:= undefined ->
    describe_instance_status(Params, Filter, MaxResults, NextToken, default_config()).

-spec describe_instance_status(ec2_param_list(), filter_list(), ec2_max_result(), ec2_token(), aws_config())
    -> ok_error([proplist()], ec2_token()).
describe_instance_status(Params, Filter, MaxResults, NextToken, Config)
    when is_list(Params),
         is_list(Filter) orelse Filter =:= none,
         is_integer(MaxResults), MaxResults >= ?SPOT_INSTANCE_STATUS_MR_MIN, MaxResults =< ?SPOT_INSTANCE_STATUS_MR_MAX,
         is_list(NextToken) orelse NextToken =:= undefined,
         is_record(Config, aws_config) ->
    AllParams = Params ++
                [{"MaxResults", MaxResults}, {"NextToken", NextToken}] ++
                list_to_ec2_filter(Filter),
    case ec2_query(Config, "DescribeInstanceStatus", AllParams, ?NEW_API_VERSION) of
        {ok, Doc} ->
            Statuses = extract_results(
                "DescribeInstanceStatusResponse", "instanceStatusSet", fun extract_instance_status/1, Doc),
            NewNextToken = extract_next_token("DescribeInstanceStatusResponse", Doc),
            {ok, Statuses, NewNextToken};
        {error, _} = E -> E
    end.

extract_instance_status(Node) ->
    %% XXX: abbreviated.
    [ { instance_id, get_text("instanceId", Node) },
      { availability_zone, get_text("availabilityZone", Node) },
      { instance_state_code, get_text("instanceState/code", Node) },
      { instance_state_name, get_text("instanceState/name", Node) } ].

-spec describe_internet_gateways() -> ok_error(proplist()).
describe_internet_gateways() ->
    describe_internet_gateways(none, default_config()).

-spec describe_internet_gateways(filter_list | aws_config()) -> ok_error(proplist()).
describe_internet_gateways(Config) when is_record(Config, aws_config) ->
    describe_internet_gateways(none, Config);
describe_internet_gateways(Filter) ->
    describe_internet_gateways(Filter, default_config()).

-spec describe_internet_gateways(none | filter_list(), aws_config()) -> ok_error(proplist()).
describe_internet_gateways(Filter, Config) ->
    describe_internet_gateways([], Filter, Config).

-spec describe_internet_gateways(list(), none | filter_list(), aws_config()) -> ok_error(proplist()).
describe_internet_gateways(IGWIds, Filter, Config) ->
    Params = erlcloud_aws:param_list(IGWIds, "InternetGatewayId") ++ list_to_ec2_filter(Filter), %
    case ec2_query(Config, "DescribeInternetGateways", Params, ?NEW_API_VERSION) of
        {ok, Doc} ->
            ResultPath = "/DescribeInternetGatewaysResponse/internetGatewaySet/item",
            {ok, [ extract_igw(Item) || Item <- xmerl_xpath:string(ResultPath, Doc) ]};
        {error, _} = Error ->
            Error
    end.

extract_igw(Node) ->
    Items = xmerl_xpath:string("attachmentSet/item", Node),
    [ {internet_gateway_id, get_text("internetGatewayId", Node)},
      {attachment_set, [ extract_igw_attachments(Item) || Item <- Items]},
      {tag_set,
       [extract_tag_item(Item)
        || Item <- xmerl_xpath:string("tagSet/item", Node)]}
 ].

extract_igw_attachments(Node) ->
    [ {vpc_id, get_text("vpcId", Node)},
      {state, get_text("state", Node)} ].

-spec describe_key_pairs() -> ok_error(proplist()).
describe_key_pairs() -> describe_key_pairs([]).

-spec describe_key_pairs([string()] | aws_config()) -> ok_error(proplist()).
describe_key_pairs(Config)
  when is_record(Config, aws_config) ->
    describe_key_pairs([], Config);
describe_key_pairs(KeyNames) -> describe_key_pairs(KeyNames, default_config()).

-spec describe_key_pairs([string()], aws_config()) -> ok_error(proplist()).
describe_key_pairs(KeyNames, Config)
  when is_list(KeyNames) ->
    case ec2_query(Config, "DescribeKeyPairs", erlcloud_aws:param_list(KeyNames, "KeyName")) of
        {ok, Doc} ->
            Items = xmerl_xpath:string("/DescribeKeyPairsResponse/keySet/item", Doc),
            {ok, [
             [
              {key_name, get_text("keyName", Item)},
              {key_fingerprint, get_text("keyFingerprint", Item)}
             ] || Item <- Items
            ]};
        {error, _} = Error ->
            Error
    end.

-spec describe_network_acls() -> ok_error(proplist()).
describe_network_acls() ->
    describe_network_acls([], none, default_config()).

-spec describe_network_acls(filter_list() | aws_config()) -> ok_error(proplist()).
describe_network_acls(Config) when is_record(Config, aws_config) ->
    describe_network_acls([], none, Config);
describe_network_acls(Filter) ->
    describe_network_acls([], Filter, default_config()).

-spec describe_network_acls(filter_list(), aws_config()) -> ok_error(proplist()).
describe_network_acls(Filter, Config) when is_record(Config, aws_config) ->
    describe_network_acls([], Filter, Config).

-spec describe_network_acls([string()], filter_list(), aws_config()) -> ok_error(proplist()).
describe_network_acls(AclIds, Filter, Config) ->
    Params = erlcloud_aws:param_list(AclIds, "NetworkAclId") ++ list_to_ec2_filter(Filter),
    case ec2_query(Config, "DescribeNetworkAcls", Params, ?NEW_API_VERSION) of
        {ok, Doc} ->
            Path = "/DescribeNetworkAclsResponse/networkAclSet/item",
            {ok, [extract_acl_response(Item) || Item <- xmerl_xpath:string(Path, Doc)]};
        {error, _} = Error ->
            Error
    end.

-spec describe_regions() -> ok_error(proplist()).
describe_regions() -> describe_regions([]).
-spec describe_regions([string()] | aws_config()) -> ok_error(proplist()).
describe_regions(Config)
  when is_record(Config, aws_config) ->
    describe_regions([], Config);
describe_regions(RegionNames) ->
    describe_regions(RegionNames, default_config()).

-spec describe_regions([string()], aws_config()) -> ok_error(proplist()).
describe_regions(RegionNames, Config)
  when is_record(Config, aws_config) ->
    describe_regions(RegionNames, none, Config).

-spec describe_regions([string()], none | filter_list(), aws_config()) -> ok_error(proplist()).
describe_regions(RegionNames, Filter, Config)
  when is_list(RegionNames), is_record(Config, aws_config) ->
    describe_regions(RegionNames, Filter, false, Config).

-spec describe_regions([string()], none | filter_list(), boolean(), aws_config()) -> ok_error(proplist()).
describe_regions(RegionNames, Filter, AllRegions, Config)
  when is_list(RegionNames), is_boolean(AllRegions), is_record(Config, aws_config) ->
    Params = erlcloud_aws:param_list(RegionNames, "RegionName") ++
        list_to_ec2_filter(Filter) ++
        [{"AllRegions", AllRegions}],
    case ec2_query(Config, "DescribeRegions", Params, ?NEW_API_VERSION) of
        {ok, Doc} ->
            Items = xmerl_xpath:string("/DescribeRegionsResponse/regionInfo/item", Doc),
            {ok, [[{region_name, get_text("regionName", Item)},
                {region_endpoint, get_text("regionEndpoint", Item)},
                {opt_in_status, get_text("optInStatus", Item)}
             ] || Item <- Items]};
        {error, _} = Error ->
            Error
    end.

%
% Network Interfaces API
%
-spec describe_network_interfaces() -> ok_error(proplist()).
describe_network_interfaces() ->
    describe_network_interfaces([]).

-spec describe_network_interfaces(list() | aws_config()) -> ok_error(proplist()).
describe_network_interfaces(Config)
    when is_record(Config, aws_config) ->
      describe_network_interfaces([], Config);
describe_network_interfaces(NetworkInterfacesIds) ->
    describe_network_interfaces(NetworkInterfacesIds, default_config()).

-spec describe_network_interfaces(list(), aws_config()) -> ok_error(proplist()).
%% Example: describe_network_interfaces(["eni-1c111111", "eni-222e2222"], Config).
describe_network_interfaces(NetworkInterfacesIds, Config)
    when is_record(Config, aws_config) ->
        describe_network_interfaces_filtered(NetworkInterfacesIds, none, Config).

-spec describe_network_interfaces_filtered(list(), filter_list() | node, aws_config()) -> ok_error(proplist()).
%%
%% Example: describe_network_interfaces_filtered([], [{"subnet-id", ["subnet-e11e11e1"]}], Config)
%%
describe_network_interfaces_filtered(NetworkInterfacesIds, Filter, Config)
    when is_record(Config, aws_config) ->
       Params = lists:append(erlcloud_aws:param_list(NetworkInterfacesIds, "NetworkInterfaceId") ,
                              list_to_ec2_filter(Filter)),
       case ec2_query(Config, "DescribeNetworkInterfaces", Params, ?NEW_API_VERSION) of
          {ok, Doc} ->
              NetworkInterfaces = xmerl_xpath:string("/DescribeNetworkInterfacesResponse/networkInterfaceSet/item", Doc),
              {ok, [extract_network_interface(Item) || Item <- NetworkInterfaces]};
          {error, _} = Error ->
              Error
       end.

-spec extract_network_interface(Node::xmerl_xpath_doc_nodes()) -> proplist().
extract_network_interface(Node) ->
    [
     {network_interface_id, get_text("networkInterfaceId", Node)},
     {subnet_id, get_text("subnetId", Node)},
     {vpc_id, get_text("vpcId", Node)},
     {availability_zone, get_text("availabilityZone", Node)},
     {description, get_text("description", Node)},
     {owner_id, get_text("ownerId", Node)},
     {requester_managed, get_bool("requesterManaged", Node)},
     {status, get_text("status", Node)},
     {mac_address, get_text("macAddress", Node)},
     {private_ip_address, get_text("privateIpAddress", Node)},
     {source_dest_check, get_bool("sourceDestCheck", Node)},
     {groups_set, [extract_group(Item) || Item <- xmerl_xpath:string("groupSet/item", Node)]},
     {attachment, extract_attachment(Node)},
     {association, extract_association(Node)},
     {tag_set, [extract_tag_item(Item) || Item <- xmerl_xpath:string("tagSet/item", Node)]},
     {private_ip_addresses_set,
            [extract_private_ip_address(Item) || Item <- xmerl_xpath:string("privateIpAddressesSet/item", Node)]}
    ].

-spec extract_attachment(Node::xmerl_xpath_doc_nodes()) -> proplist().
extract_attachment(Node) ->
    [
     {attachment_id, get_text("attachment/attachmentId", Node)},
     {instance_id, get_text("attachment/instanceId", Node)},
     {instance_owner_id, get_text("attachment/instanceOwnerId", Node)},
     {device_index, get_text("attachment/deviceIndex", Node)},
     {status, get_text("attachment/status", Node)},
     {attach_time, erlcloud_xml:get_time("attachment/attachTime", Node)},
     {delete_on_termination, get_bool("attachment/deleteOnTermination", Node)}
    ].

-spec extract_private_ip_address(Node::xmerl_xpath_doc_nodes()) -> proplist().
extract_private_ip_address(Node) ->
    [
     {private_ip_address, get_text("privateIpAddress", Node)},
     {primary, get_bool("primary", Node)}
    ].

-spec extract_association(Node::xmerl_xpath_doc_nodes()) -> proplist().
extract_association(Node) ->
    [
     {public_ip, get_text("association/publicIp", Node)},
     {public_dns_name, get_text("association/publicDnsName", Node)},
     {ip_owner_id, get_text("association/ipOwnerId", Node)},
     {allocation_id, get_text("association/allocationId", Node)},
     {association_id, get_text("association/associationId", Node)}
    ].

-spec describe_reserved_instances() -> ok_error(proplist()).
describe_reserved_instances() -> describe_reserved_instances([]).

-spec describe_reserved_instances([string()] | aws_config()) -> ok_error(proplist()).
describe_reserved_instances(Config)
  when is_record(Config, aws_config) ->
    describe_reserved_instances([], Config);
describe_reserved_instances(ReservedInstanceIDs) ->
    describe_reserved_instances(ReservedInstanceIDs, default_config()).

-spec describe_reserved_instances([string()], aws_config()) -> ok_error(proplist()).
describe_reserved_instances(ReservedInstanceIDs, Config)
  when is_list(ReservedInstanceIDs) ->
    case ec2_query(Config, "DescribeReservedInstances", erlcloud_aws:param_list(ReservedInstanceIDs, "ReservedInstanceId")) of
        {ok, Doc} ->
            ReservedInstances = xmerl_xpath:string("/DescribeReservedInstancesResponse/reservedInstancesSet/item", Doc),
            {ok, [extract_reserved_instance(Item) || Item <- ReservedInstances]};
        {error, _} = Error ->
            Error
    end.

extract_reserved_instance(Node) ->
    [
     {reserved_instance_id, get_text("reservedInstanceId", Node)},
     {instance_type, get_text("instanceType", Node)},
     {availability_zone, get_text("availabilityZone", Node)},
     {start, erlcloud_xml:get_time("start", Node)},
     {duration, get_integer("duration", Node)},
     {fixed_price, get_text("fixedPrice", Node)},
     {usage_price, get_text("usagePrice", Node)},
     {instance_count, get_integer("instanceCount", Node)},
     {product_description, get_text("productDescription", Node)},
     {state, get_text("state", Node)}
    ].

-spec describe_reserved_instances_offerings() -> ok_error([proplist()]).
describe_reserved_instances_offerings() ->
    describe_reserved_instances_offerings([], default_config()).

-spec describe_reserved_instances_offerings(ec2_selector()) -> ok_error([proplist()]);
(aws_config()) -> ok_error(proplist()).
describe_reserved_instances_offerings(Selector)
    when is_list(Selector) ->
    describe_reserved_instances_offerings(Selector, default_config());
describe_reserved_instances_offerings(Config)
    when is_record(Config, aws_config) ->
    describe_reserved_instances_offerings([], Config).

-spec describe_reserved_instances_offerings(ec2_selector(), aws_config())
    -> ok_error([proplist()]) | ok_error([proplist()], ec2_token()).
describe_reserved_instances_offerings(Selector, Config)
    when is_list(Selector), is_record(Config, aws_config) ->
    InstanceTypes = proplists:get_all_values(instance_type, Selector),
    AvailabilityZones = proplists:get_all_values(availability_zone, Selector),
    Descs = proplists:get_all_values(product_description, Selector),
    Token = proplists:get_all_values(token, Selector),
    Params = erlcloud_aws:param_list(InstanceTypes, "InstanceType") ++
             erlcloud_aws:param_list(AvailabilityZones, "AvailabilityZone") ++
             erlcloud_aws:param_list(Descs, "ProductDescription") ++
             erlcloud_aws:param_list(Token, "NextToken"),
    case ec2_query(Config, "DescribeReservedInstancesOfferings", Params, ?NEW_API_VERSION) of
        {ok, Doc} ->
            Offerings = extract_results("DescribeReservedInstancesOfferingsResponse", "reservedInstancesOfferingsSet",
                fun extract_reserved_instances_offering/1, Doc),
            NewNextToken = extract_next_token("DescribeReservedInstancesOfferingsResponse", Doc),
            case NewNextToken of
                undefined ->
                    {ok, Offerings};
                NewNextToken ->
                    {ok, Offerings, NewNextToken}
            end;
        {error, _} = Error ->
            Error
    end.

-spec describe_reserved_instances_offerings(ec2_selector(), ec2_max_result(), ec2_token())
    -> ok_error([proplist()], ec2_token()).
describe_reserved_instances_offerings(Selector, MaxResults, NextToken)
    when is_list(Selector), is_integer(MaxResults), is_list(NextToken) orelse NextToken =:= undefined ->
    describe_reserved_instances_offerings(Selector, MaxResults, NextToken, default_config()).

-spec describe_reserved_instances_offerings(ec2_selector(), ec2_max_result(), ec2_token(), aws_config())
    -> ok_error([proplist()], ec2_token()).
describe_reserved_instances_offerings(Selector, MaxResults, NextToken, Config)
    when is_list(Selector), is_integer(MaxResults),
         MaxResults >= ?RESERVED_INSTANCES_OFFERINGS_MR_MIN,
         MaxResults =< ?RESERVED_INSTANCES_OFFERINGS_MR_MAX,
         is_list(NextToken) orelse NextToken =:= undefined,
         is_record(Config, aws_config) ->
    InstanceTypes = proplists:get_all_values(instance_type, Selector),
    AvailabilityZones = proplists:get_all_values(availability_zone, Selector),
    Descs = proplists:get_all_values(product_description, Selector),
    Params = erlcloud_aws:param_list(InstanceTypes, "InstanceType") ++
             erlcloud_aws:param_list(AvailabilityZones, "AvailabilityZone") ++
             erlcloud_aws:param_list(Descs, "ProductDescription") ++
             [{"MaxResults", MaxResults}, {"NextToken", NextToken}],
    case ec2_query(Config, "DescribeReservedInstancesOfferings", Params, ?NEW_API_VERSION) of
        {ok, Doc} ->
            Offerings = extract_results("DescribeReservedInstancesOfferingsResponse", "reservedInstancesOfferingsSet",
                fun extract_reserved_instances_offering/1, Doc),
            NewNextToken = extract_next_token("DescribeReservedInstancesOfferingsResponse", Doc),
            {ok, Offerings, NewNextToken};
        {error, _} = E -> E
    end.

-spec describe_reserved_instances_offerings_all() -> ok_error([proplist()]).
describe_reserved_instances_offerings_all() -> describe_reserved_instances_offerings_all([]).

-spec describe_reserved_instances_offerings_all([{atom(), string()}] | aws_config()) -> ok_error([proplist()]).
describe_reserved_instances_offerings_all(Config)
  when is_record(Config, aws_config) ->
    describe_reserved_instances_offerings_all([], Config);
describe_reserved_instances_offerings_all(Selector) ->
    describe_reserved_instances_offerings_all(Selector, default_config()).

-spec describe_reserved_instances_offerings_all([{atom(), string()}], aws_config()) -> ok_error([proplist()]).
describe_reserved_instances_offerings_all(Selector, Config) ->
    describe_reserved_instances_offerings_all(Selector, Config, []).

describe_reserved_instances_offerings_all(Selector, Config, Acc)
  when is_list(Selector) ->
    case describe_reserved_instances_offerings(Selector, Config) of
        {ok, Res} ->
            {ok, Acc ++ Res};
        {ok, Res, NewNextToken} ->
            NewSelector = [{token, NewNextToken} | proplists:delete(token, Selector)],
            describe_reserved_instances_offerings_all(NewSelector, Config, Acc ++ Res);
        {error, _} = Error ->
            Error
    end.

extract_reserved_instances_offering(Node) ->
    [
     {reserved_instances_offering_id, get_text("reservedInstancesOfferingId", Node)},
     {instance_type, get_text("instanceType", Node)},
     {availability_zone, get_text("availabilityZone", Node)},
     {duration, get_integer("duration", Node)},
     {fixed_price, get_text("fixedPrice", Node)},
     {usage_price, get_text("usagePrice", Node)},
     {product_description, get_text("productDescription", Node)}
    ].

-spec describe_route_tables() -> ok_error([proplist()]).
describe_route_tables() ->
    describe_route_tables([], none, default_config()).

-spec describe_route_tables(filter_list() | none | aws_config()) -> ok_error([proplist()]).
describe_route_tables(Config) when is_record(Config, aws_config) ->
    describe_route_tables([], none, Config);
describe_route_tables(Filter) ->
    describe_route_tables([], Filter, default_config()).

-spec describe_route_tables(filter_list() | none, aws_config()) -> ok_error([proplist()]).
describe_route_tables(Filter, Config) ->
    describe_route_tables([], Filter, Config).

-spec describe_route_tables([string()], filter_list() | none, aws_config()) -> ok_error([proplist()]).
describe_route_tables(RouteTableIds, Filter, Config) ->
    Params = erlcloud_aws:param_list(RouteTableIds, "RouteTableId") ++ list_to_ec2_filter(Filter),
    case ec2_query(Config, "DescribeRouteTables", Params, ?NEW_API_VERSION) of
        {ok, Doc} ->
            Path = "/DescribeRouteTablesResponse/routeTableSet/item",
            {ok, [extract_route(Item) || Item <- xmerl_xpath:string(Path, Doc)]};
        {error, _} = Error ->
            Error
    end.

extract_route(Node) ->
    [
     {route_table_id, get_text("routeTableId", Node)},
     {vpc_id, get_text("vpcId", Node)},
     {route_set, [extract_route_set(Item) ||
                     Item <- xmerl_xpath:string("routeSet/item", Node)]},
     {association_set,
      [extract_route_assn(Item)
       || Item <-xmerl_xpath:string("associationSet/item", Node)]},
     {tag_set,
      [extract_tag_item(Item)
       || Item <- xmerl_xpath:string("tagSet/item", Node)]}
    ].

extract_route_set(Node) ->
    [
     {destination_cidr_block, get_text("destinationCidrBlock", Node)},
     {destination_ipv6_cidr_block, get_text("destinationIpv6CidrBlock", Node)},
     {gateway_id, get_text("gatewayId", Node)},
     {nat_gateway_id, get_text("natGatewayId", Node)},
     {instance_id, get_text("instanceId", Node)},
     {vpc_peering_conn_id, get_text("vpcPeeringConnectionId", Node)},
     {network_interface_id, get_text("networkInterfaceId", Node)},
     {state, get_text("state", Node)},
     {origin, get_text("origin", Node)}
    ].

extract_route_assn(Node) ->
    [
     {route_table_association_id, get_text("routeTableAssociationId", Node)},
     {route_table_id, get_text("routeTableId", Node)},
     {main, get_text("main", Node)},
     {subnet_id, get_text("subnetId", Node)}
    ].

-spec describe_security_groups() -> ok_error(proplist()).
describe_security_groups() ->
    describe_security_groups([]).

-spec describe_security_groups([string()] | aws_config()) -> ok_error(proplist()).
describe_security_groups(Config)
  when is_record(Config, aws_config) ->
    describe_security_groups([], Config);
describe_security_groups(GroupNames) ->
    describe_security_groups(GroupNames, default_config()).

-spec describe_security_groups([string()], aws_config()) -> ok_error(proplist()).
describe_security_groups(GroupNames, Config)
  when is_list(GroupNames) ->
    describe_security_groups([], GroupNames, [], Config).

-spec describe_security_groups_filtered(filter_list()) -> ok_error(proplist()).
describe_security_groups_filtered(Filter) ->
    describe_security_groups_filtered(Filter, default_config()).

-spec describe_security_groups_filtered(filter_list(), aws_config()) -> ok_error(proplist()).
describe_security_groups_filtered(Filter, Config)->
    describe_security_groups([], [], Filter, Config).

%
% describe_security_groups functions above are left for interface backward compatibility.
-spec describe_security_groups(list(), list(), filter_list(), aws_config()) -> ok_error(proplist()).
describe_security_groups(GroupIds, GroupNames, Filters, Config)
  when is_list(GroupIds),
       is_list(GroupNames),
       is_list(Filters) orelse Filters =:= none ->
    Params = erlcloud_aws:param_list(GroupIds, "GroupId") ++
        erlcloud_aws:param_list(GroupNames, "GroupName") ++
        list_to_ec2_filter(Filters),
    case ec2_query(Config, "DescribeSecurityGroups", Params, ?NEW_API_VERSION) of
        {ok, Doc} ->
            {ok, [extract_security_group(Node) ||
                Node <- xmerl_xpath:string("/DescribeSecurityGroupsResponse/securityGroupInfo/item", Doc)]};
        {error, _} = Error ->
            Error
    end.

extract_security_group(Node) ->
    [
     {owner_id, get_text("ownerId", Node)},
     {group_id, get_text("groupId", Node)},
     {group_name, get_text("groupName", Node)},
     {group_description, get_text("groupDescription", Node)},
     {vpc_id, get_text("vpcId", Node)},
     {ip_permissions,
      [extract_ip_permissions(Item) || Item <- xmerl_xpath:string("ipPermissions/item", Node)]},
     {ip_permissions_egress,
      [extract_ip_permissions(Item) || Item <- xmerl_xpath:string("ipPermissionsEgress/item", Node)]},
     {tag_set,
      [extract_tag_item(Item)
       || Item <- xmerl_xpath:string("tagSet/item", Node)]}
    ].

extract_ip_permissions(Node) ->
    [
     {ip_protocol, list_to_atom(get_text("ipProtocol", Node))},
     {from_port, get_integer("fromPort", Node)},
     {to_port, get_integer("toPort", Node)},
     {users, get_list("groups/item/userId", Node)},
     {groups,
      [extract_user_id_group_pair(Item) || Item <- xmerl_xpath:string("groups/item", Node)]},
     {ip_ranges, get_list("ipRanges/item/cidrIp", Node)},
     {ipv6_ranges, get_list("ipv6Ranges/item/cidrIpv6", Node)}
    ].

extract_user_id_group_pair(Node) ->
    [
      {user_id, get_text("userId", Node)},
      {group_id, get_text("groupId", Node)},
      {group_name, get_text("groupName", Node)}
    ].

-spec describe_snapshot_attribute(string(), atom()) -> ok_error(proplist()).
describe_snapshot_attribute(SnapshotID, Attribute) ->
    describe_snapshot_attribute(SnapshotID, Attribute, default_config()).

-spec describe_snapshot_attribute(string(), atom(), aws_config()) -> ok_error(proplist()).
describe_snapshot_attribute(SnapshotID, create_volume_permission, Config)
  when is_list(SnapshotID) ->
    case ec2_query(Config, "DescribeSnapshotAttribute", [{"snapshotId", SnapshotID}, {"Attribute", "createVolumePermission"}]) of
        {ok, Doc} ->
            {ok, extract_permissions(xmerl_xpath:string("/DescribeSnapshotAttributeResponse/createVolumePermission/item", Doc))};
        {error, _} = Error ->
            Error
    end.

-spec describe_snapshots() -> ok_error([proplist()]).
describe_snapshots() -> describe_snapshots([], "self", none, default_config()).

-spec describe_snapshots(ec2_snapshot_ids()) -> ok_error([proplist()]);
                        (aws_config()) -> ok_error([proplist()]).
describe_snapshots(SnapshotIDs)
    when is_list(SnapshotIDs) ->
    describe_snapshots(SnapshotIDs, "self", none, default_config());
describe_snapshots(Config)
    when is_record(Config, aws_config) ->
    describe_snapshots([], "self", none, Config).

-spec describe_snapshots(ec2_snapshot_ids(), ec2_snapshot_owner()) -> ok_error([proplist()]);
                        (ec2_snapshot_ids(), aws_config()) -> ok_error([proplist()]).
describe_snapshots(SnapshotIDs, Owner)
    when is_list(SnapshotIDs), is_list(Owner) ->
    describe_snapshots(SnapshotIDs, Owner, none, default_config());
describe_snapshots(SnapshotIDs, Config)
    when is_list(SnapshotIDs), is_record(Config, aws_config) ->
    describe_snapshots(SnapshotIDs, "self", none, Config).

-spec describe_snapshots(ec2_snapshot_ids(), ec2_snapshot_owner(), ec2_snapshot_restorable_by())
                            -> ok_error([proplist()]);
                        (ec2_snapshot_ids(), ec2_snapshot_owner(), aws_config())
                            -> ok_error([proplist()]).
describe_snapshots(SnapshotIDs, Owner, RestorableBy)
    when is_list(SnapshotIDs), is_list(Owner), is_list(RestorableBy) ->
    describe_snapshots(SnapshotIDs, Owner, RestorableBy, default_config());
describe_snapshots(SnapshotIDs, Owner, Config)
    when is_list(SnapshotIDs), is_list(Owner), is_record(Config, aws_config) ->
    describe_snapshots(SnapshotIDs, Owner, none, Config).

-spec describe_snapshots(ec2_snapshot_ids(), ec2_snapshot_owner(), ec2_snapshot_restorable_by(), aws_config())
                            -> ok_error([proplist()]);
                        (ec2_snapshot_owner(), ec2_snapshot_restorable_by(), ec2_max_result(), ec2_token())
                            -> ok_error([proplist()], ec2_token()).
describe_snapshots(SnapshotIDs, Owner, RestorableBy, Config)
    when is_list(SnapshotIDs),
         is_list(Owner) orelse Owner =:= none,
         is_list(RestorableBy) orelse RestorableBy =:= none ->
    Params = erlcloud_aws:param_list(SnapshotIDs, "SnapshotId") ++
             [{"Owner", Owner}, {"RestorableBy", RestorableBy}],
    case ec2_query(Config, "DescribeSnapshots", Params, ?NEW_API_VERSION) of
        {ok, Doc} ->
            Snapshots = extract_results("DescribeSnapshotsResponse", "snapshotSet", fun extract_snapshot/1, Doc),
            {ok, Snapshots};
        {error, _} = E -> E
    end;
describe_snapshots(Owner, RestorableBy, MaxResults, NextToken)
    when is_list(Owner) orelse Owner =:= none,
         is_list(RestorableBy) orelse RestorableBy =:= none,
         is_integer(MaxResults),
         is_list(NextToken) orelse NextToken =:= undefined ->
    describe_snapshots(Owner, RestorableBy, MaxResults, NextToken, default_config()).

-spec describe_snapshots(ec2_snapshot_owner(),
                         ec2_snapshot_restorable_by(),
                         ec2_max_result(),
                         ec2_token(),
                         aws_config()
                        ) -> ok_error([proplist()], ec2_token()).
describe_snapshots(Owner, RestorableBy, MaxResults, NextToken, Config)
    when is_list(Owner) orelse Owner =:= none,
         is_list(RestorableBy) orelse RestorableBy =:= none,
         is_integer(MaxResults), MaxResults >= ?SNAPSHOTS_MR_MIN, MaxResults =< ?SNAPSHOTS_MR_MAX,
         is_list(NextToken) orelse NextToken =:= undefined,
         is_record(Config, aws_config) ->
    Params = [{"Owner", Owner}, {"RestorableBy", RestorableBy}, {"MaxResults", MaxResults}, {"NextToken", NextToken}],
    case ec2_query(Config, "DescribeSnapshots", Params, ?NEW_API_VERSION) of
        {ok, Doc} ->
            Snapshots = extract_results("DescribeSnapshotsResponse", "snapshotSet", fun extract_snapshot/1, Doc),
            NewNextToken = extract_next_token("DescribeSnapshotsResponse", Doc),
            {ok, Snapshots, NewNextToken};
        {error, _} = E -> E
    end.

extract_snapshot(Node) ->
    [{snapshot_id, get_text("snapshotId", Node)},
     {volume_id, get_text("volumeId", Node)},
     {status, get_text("status", Node)},
     {start_time, erlcloud_xml:get_time("startTime", Node)},
     {progress, get_text("progress", Node, none)},
     {owner_id, get_text("ownerId", Node)},
     {volume_size, get_integer("volumeSize", Node)},
     {description, get_text("description", Node)},
     {owner_alias, get_text("ownerAlias", Node, none)},
     {encrypted, get_bool("encrypted", Node)}
    ].

-spec describe_spot_datafeed_subscription() -> ok_error(proplist()).
describe_spot_datafeed_subscription() ->
    describe_spot_datafeed_subscription(default_config()).

-spec describe_spot_datafeed_subscription(aws_config()) -> ok_error(proplist()).
describe_spot_datafeed_subscription(Config) ->
    case ec2_query(Config, "DescribeSpotDatafeedSubscription", []) of
        {ok, Doc} ->
            {ok, extract_spot_datafeed_subscription(xmerl_xpath:string("/DescribeSpotDatafeedSubscriptionResponse/spotDatafeedSubscription", Doc))};
        {error, _} = Error ->
            Error
    end.

-spec describe_spot_instance_requests() -> ok_error(proplist()).
describe_spot_instance_requests() ->
    describe_spot_instance_requests([]).

-spec describe_spot_instance_requests([string()] | aws_config()) -> ok_error(proplist()).
describe_spot_instance_requests(Config)
  when is_record(Config, aws_config) ->
    describe_spot_instance_requests([], Config);
describe_spot_instance_requests(SpotInstanceRequestIDs) ->
    describe_spot_instance_requests(SpotInstanceRequestIDs, default_config()).

-spec describe_spot_instance_requests([string()], aws_config()) -> ok_error(proplist()).
describe_spot_instance_requests(SpotInstanceRequestIDs, Config)
  when is_list(SpotInstanceRequestIDs) ->
    case ec2_query(Config, "DescribeSpotInstanceRequests", erlcloud_aws:param_list(SpotInstanceRequestIDs, "SpotInstanceRequestId"), ?NEW_API_VERSION) of
        {ok, Doc} ->
            {ok, [extract_spot_instance_request(Item) ||
                    Item <- xmerl_xpath:string("/DescribeSpotInstanceRequestsResponse/spotInstanceRequestSet/item", Doc)]};
        {error, Reason} ->
            {error, Reason}
    end.

extract_spot_instance_request(Node) ->
    [
        {spot_instance_request_id, get_text("spotInstanceRequestId", Node)},
        {spot_price, get_text("spotPrice", Node)},
        {type, extract_spot_instance_request_type(get_text("type", Node))},
        {state, get_text("state", Node)},
        {status, get_text("status/code", Node)},
        {fault, [
            {code, get_text("fault/code", Node)},
            {message, get_text("fault/message", Node)}
        ]},
        {valid_from, erlcloud_xml:get_time("validFrom", Node)},
        {valid_until, erlcloud_xml:get_time("validUntil", Node)},
        {launch_group, get_text("launchGroup", Node, none)},
        {availability_zone_group, get_text("availabilityZoneGroup", Node, none)},
        {create_time, erlcloud_xml:get_time("createTime", Node)},
        {product_description, get_text("productDescription", Node)},
        {launch_specification, extract_launch_specification(hd(xmerl_xpath:string("launchSpecification", Node)))},
        {instance_id, get_text("instanceId", Node, none)}
    ].

extract_spot_instance_request_type("one-time") -> one_time;
extract_spot_instance_request_type("persistent") -> persistent.

extract_launch_specification(Node) ->
    [
     {image_id, get_text("imageId", Node)},
     {key_name, get_text("keyName", Node, none)},
     {group_set, get_list("groupSet/item/groupId", Node)},
     {user_data, base64:decode(get_text("userData/data", Node))},
     {instance_type, get_text("instanceType", Node)},
     {availability_zone, get_text("placement/availabilityZone", Node)},
     {kernel_id, get_text("kernelId", Node)},
     {ramdisk_id, get_text("ramdiskId", Node)},
     {subnet_id, get_text("subnetId", Node)}
    ].

-spec describe_spot_price_history() -> ok_error([proplist()]).
describe_spot_price_history() ->
    describe_spot_price_history(none).

-spec describe_spot_price_history(aws_config()) -> ok_error([proplist()]);
                                 (ec2_spot_price_time()) -> ok_error([proplist()]).
describe_spot_price_history(Config)
    when is_record(Config, aws_config) ->
    describe_spot_price_history(none, Config);
describe_spot_price_history(StartTime) ->
    describe_spot_price_history(StartTime, none).

-spec describe_spot_price_history(ec2_spot_price_time(), aws_config()) -> ok_error([proplist()]);
                                 (ec2_spot_price_time(), ec2_spot_price_time()) -> ok_error([proplist()]).
describe_spot_price_history(StartTime, Config)
    when is_record(Config, aws_config) ->
    describe_spot_price_history(StartTime, none, Config);
describe_spot_price_history(StartTime, EndTime) ->
    describe_spot_price_history(StartTime, EndTime, []).


-spec describe_spot_price_history(ec2_spot_price_time(), ec2_spot_price_time(), aws_config())
                                     -> ok_error([proplist()]);
                                 (ec2_spot_price_time(), ec2_spot_price_time(), ec2_instance_types())
                                     -> ok_error([proplist()]).
describe_spot_price_history(StartTime, EndTime, Config)
    when is_record(Config, aws_config) ->
    describe_spot_price_history(StartTime, EndTime, [], Config);
describe_spot_price_history(StartTime, EndTime, InstanceTypes) ->
    describe_spot_price_history(StartTime, EndTime, InstanceTypes, none).

-spec describe_spot_price_history
                         (ec2_spot_price_time(), ec2_spot_price_time(), ec2_instance_types(), aws_config())
                             -> ok_error([proplist()]);
                         (ec2_spot_price_time(), ec2_spot_price_time(), ec2_instance_types(), ec2_product_description())
                             -> ok_error([proplist()]).
describe_spot_price_history(StartTime, EndTime, InstanceTypes, Config)
    when is_record(Config, aws_config) ->
    describe_spot_price_history(StartTime, EndTime, InstanceTypes, none, Config);
describe_spot_price_history(StartTime, EndTime, InstanceTypes, ProductDescription) ->
    describe_spot_price_history(StartTime, EndTime, InstanceTypes, ProductDescription, default_config()).

-spec describe_spot_price_history
    (ec2_spot_price_time(), ec2_spot_price_time(), ec2_instance_types(), ec2_product_description(), aws_config())
        -> ok_error([proplist()]).
describe_spot_price_history(StartTime, EndTime, InstanceTypes, ProductDescription, Config)
    when is_list(InstanceTypes),
         is_list(ProductDescription) orelse ProductDescription =:= none,
         is_record(Config, aws_config) ->
    Params = [{"StartTime", StartTime}, {"EndTime", EndTime}, {"ProductDescription", ProductDescription}] ++
             erlcloud_aws:param_list(InstanceTypes, "InstanceType"),
    case ec2_query(Config, "DescribeSpotPriceHistory", Params, ?NEW_API_VERSION) of
        {ok, Doc} ->
            History = extract_results(
                "DescribeSpotPriceHistoryResponse", "spotPriceHistorySet", fun extract_spot_price_history/1, Doc),
            {ok, History};
        {error, _} = E -> E
    end.

-spec describe_spot_price_history(ec2_spot_price_time(),
                                  ec2_spot_price_time(),
                                  ec2_instance_types(),
                                  ec2_product_description(),
                                  ec2_max_result(),
                                  ec2_token()
                                 )  -> ok_error([proplist()], ec2_token()).
describe_spot_price_history(StartTime, EndTime, InstanceTypes, ProductDescription, MaxResults, NextToken)
    when is_integer(MaxResults), is_list(NextToken) orelse NextToken =:= undefined ->
    describe_spot_price_history(StartTime, EndTime, InstanceTypes, ProductDescription, MaxResults, NextToken, default_config()).

-spec describe_spot_price_history(ec2_spot_price_time(),
                                  ec2_spot_price_time(),
                                  ec2_instance_types(),
                                  ec2_product_description(),
                                  ec2_max_result(),
                                  ec2_token(),
                                  aws_config()
                                 )  -> ok_error([proplist()], ec2_token()).
describe_spot_price_history(StartTime, EndTime, InstanceTypes, ProductDescription, MaxResults, NextToken, Config)
    when is_list(InstanceTypes),
         is_list(ProductDescription) orelse ProductDescription =:= none,
         is_integer(MaxResults), MaxResults >= ?SPOT_PRICE_MR_MIN, MaxResults =< ?SPOT_PRICE_MR_MAX,
         is_list(NextToken) orelse NextToken =:= undefined,
         is_record(Config, aws_config) ->
    Params = [{"StartTime", StartTime}, {"EndTime", EndTime}, {"ProductDescription", ProductDescription}] ++
             erlcloud_aws:param_list(InstanceTypes, "InstanceType") ++
             [{"MaxResults", MaxResults}, {"NextToken", NextToken}],
    case ec2_query(Config, "DescribeSpotPriceHistory", Params, ?NEW_API_VERSION) of
        {ok, Doc} ->
            History = extract_results("DescribeSpotPriceHistoryResponse", "spotPriceHistorySet",
                fun extract_spot_price_history/1, Doc),
            NewNextToken = extract_next_token("DescribeSpotPriceHistoryResponse", Doc),
            {ok, History, NewNextToken};
        {error, _} = E -> E
    end.

extract_spot_price_history(Node) ->
    [
     {instance_type, get_text("instanceType", Node)},
     {product_description, get_text("productDescription", Node)},
     {spot_price, get_text("spotPrice", Node)},
     {timestamp, erlcloud_xml:get_time("timestamp", Node)},
     {availability_zone, get_text("availabilityZone", Node)}
    ].

-spec describe_subnets() -> ok_error(proplist()).
describe_subnets() ->
    describe_subnets(none, default_config()).

-spec describe_subnets(filter_list() | aws_config()) -> ok_error(proplist()).
describe_subnets(Config) when is_record(Config, aws_config) ->
    describe_subnets(none, Config);
describe_subnets(Filter) when is_list(Filter) orelse Filter =:= none ->
    describe_subnets(Filter, default_config()).

-spec describe_subnets(none | filter_list(), aws_config()) -> ok_error(proplist()).
describe_subnets(Filter, Config) ->
    describe_subnets([], Filter, Config).

-spec describe_subnets(list(), filter_list(), aws_config()) -> ok_error(proplist()).
describe_subnets(SubnetIds, Filter, Config)
        when is_list(SubnetIds) ->
    Params = erlcloud_aws:param_list(SubnetIds, "SubnetId") ++ list_to_ec2_filter(Filter),
    case ec2_query(Config, "DescribeSubnets", Params, ?NEW_API_VERSION) of
        {ok, Doc} ->
            Subnets = xmerl_xpath:string("/DescribeSubnetsResponse/subnetSet/item", Doc),
            {ok, [extract_subnet(Item) || Item <- Subnets]};
        {error, _} = Error ->
            Error
    end.

extract_subnet(Node) ->
    [{subnet_id, get_text("subnetId", Node)},
     {state, get_text("state", Node)},
     {vpc_id, get_text("vpcId", Node)},
     {available_ip_address_count, get_text("availableIpAddressCount", Node)},
     {availability_zone, get_text("availabilityZone", Node)},
     {cidr_block, get_text("cidrBlock", Node)},
     {tag_set,
      [extract_tag_item(Item)
       || Item <- xmerl_xpath:string("tagSet/item", Node)]}
].

-spec describe_volumes() -> ok_error(proplist()).
describe_volumes() -> describe_volumes([]).

-spec describe_volumes([string()] | aws_config()) -> ok_error(proplist()).
describe_volumes(Config)
  when is_record(Config, aws_config) ->
    describe_volumes([], Config);
describe_volumes(VolumeIDs) ->
    describe_volumes(VolumeIDs, default_config()).

-spec describe_volumes([string()], aws_config()) -> ok_error(proplist()).
describe_volumes(VolumeIDs, Config)
  when is_list(VolumeIDs) ->
    case ec2_query(Config, "DescribeVolumes", erlcloud_aws:param_list(VolumeIDs, "VolumeId"), ?NEW_API_VERSION) of
        {ok, Doc} ->
            {ok, [extract_volume(Item) || Item <- xmerl_xpath:string("/DescribeVolumesResponse/volumeSet/item", Doc)]};
        {error, Reason} ->
            {error, Reason}
    end.

extract_volume(Node) ->
    [{volume_id, get_text("volumeId", Node)},
     {size, get_integer("size", Node)},
     {snapshot_id, get_text("snapshotId", Node, none)},
     {availability_zone, get_text("availabilityZone", Node, none)},
     {status, get_text("status", Node, none)},
     {create_time, erlcloud_xml:get_time("createTime", Node)},
     {volumeType, get_text("volumeType", Node)},
     {iops, get_integer("iops", Node)},
     {encrypted, get_bool("encrypted", Node)},
     {kms_key_id, get_text("kmsKeyId", Node, none)},
     {attachment_set,
      [[{volume_id, get_text("volumeId", Item)},
        {instance_id, get_text("instanceId",Item)},
        {device, get_text("device", Item)},
        {status, get_text("status", Item)},
        {attach_time, erlcloud_xml:get_time("attachTime", Item)}
       ] ||
          Item <- xmerl_xpath:string("attachmentSet/item", Node)
      ]
     },
     {tag_set, [extract_tag_item(Item) || Item <- xmerl_xpath:string("tagSet/item", Node)]}
    ].

-spec describe_vpcs() -> ok_error(proplist()).
describe_vpcs() ->
    describe_vpcs(default_config()).

-spec describe_vpcs(filter_list() | aws_config()) -> ok_error(proplist()).
describe_vpcs(Config) when is_record(Config, aws_config) ->
    describe_vpcs(none, Config);
describe_vpcs(Filter) ->
    describe_vpcs(Filter, default_config()).

-spec describe_vpcs(filter_list() | none, aws_config()) -> ok_error(proplist()).
describe_vpcs(Filter, Config) ->
    describe_vpcs([], Filter, Config).

-spec describe_vpcs(list(), filter_list() | none, aws_config()) -> ok_error(proplist()).
describe_vpcs(VpcIds, Filter, Config) ->
    Params = erlcloud_aws:param_list(VpcIds, "VpcId") ++ list_to_ec2_filter(Filter),
    case ec2_query(Config, "DescribeVpcs", Params, ?NEW_API_VERSION) of
        {ok, Doc} ->
            Items = xmerl_xpath:string("/DescribeVpcsResponse/vpcSet/item", Doc),
            {ok, [ extract_vpc(Item) || Item <- Items ]};
        {error, _} = Error ->
            Error
    end.

extract_vpc(Node) ->
    [ {vpc_id, get_text("vpcId", Node)},
      {state, get_text("state", Node)},
      {cidr_block, get_text("cidrBlock", Node)},
      {dhcp_options_id, get_text("dhcpOptionsId", Node)},
      {instance_tenancy, get_text("instanceTenancy", Node)},
      {is_default, get_bool("isDefault", Node)},
      {cidr_block_association_set, extract_cidr_block_association_set(Node)},
      {tag_set,
        [extract_tag_item(Item)
         || Item <- xmerl_xpath:string("tagSet/item", Node)]}
    ].

extract_cidr_block_association_set(Node) ->
    Items = xmerl_xpath:string("cidrBlockAssociationSet/item", Node),
    [extract_cidr_block_association_item(Item) || Item <- Items].

extract_cidr_block_association_item(Node) ->
    [
         {cidr_block, get_text("cidrBlock", Node)},
         {association_id, get_text("associationId", Node)},
         {cidr_block_state,
            [{state, get_text("cidrBlockState/state", Node)}] ++
            case get_text("cidrBlockState/statusMessage", Node, undefined) of
                undefined ->
                    [];
                StatusMessage ->
                    [{status_message, StatusMessage}]
            end
         }
    ].

-spec detach_internet_gateway(string(), string()) -> ok.
detach_internet_gateway(GatewayID, VpcID) ->
    detach_internet_gateway(GatewayID, VpcID, default_config()).

-spec detach_internet_gateway(string(), string(), aws_config()) -> ok.
detach_internet_gateway(GatewayID, VpcID, Config) ->
    ec2_simple_query(Config, "DetachInternetGateway",
                     [{"InternetGatewayId", GatewayID}, {"VpcId", VpcID}],
                     ?NEW_API_VERSION).

-spec detach_volume(string()) -> ok_error(proplist()).
detach_volume(VolumeID) -> detach_volume(VolumeID, default_config()).

-spec detach_volume(string(), aws_config()) -> ok_error(proplist()).
detach_volume(VolumeID, Config)
  when is_list(VolumeID) ->
    Params = [{"VolumeId", VolumeID}],
    case ec2_query(Config, "DetachVolume", Params) of
        {ok, Doc} ->
            {ok, extract_volume_status(hd(xmerl_xpath:string("/DetachVolumeResponse", Doc)))};
        {error, _} = Error ->
            Error
    end.

-spec disassociate_address(string()) -> ok.
disassociate_address(PublicIP) ->
    disassociate_address(PublicIP, default_config()).

-spec disassociate_address(string(), aws_config()) -> ok.
disassociate_address(PublicIP, Config)
  when is_list(PublicIP) ->
    ec2_simple_query(Config, "DisassociateAddress", [{"PublicIp", PublicIP}]).

-spec get_console_output(string()) -> ok_error(proplist()).
get_console_output(InstanceID) -> get_console_output(InstanceID, default_config()).

-spec get_console_output(string(), aws_config()) -> ok_error(proplist()).
get_console_output(InstanceID, Config)
  when is_list(InstanceID) ->
    case ec2_query(Config, "GetConsoleOutput", [{"InstanceId", InstanceID}]) of
        {ok, Doc} ->
            {ok, [
                {instance_id, get_text("/GetConsoleOutputResponse/instanceId", Doc)},
                {timestamp, erlcloud_xml:get_time("/GetConsoleOutputResponse/timestamp", Doc)},
                {output, base64:decode(get_text("/GetConsoleOutputResponse/output", Doc))}
            ]};
        {error, _} = Error ->
            Error
    end.

-spec get_password_data(string()) -> ok_error(proplist()).
get_password_data(InstanceID) -> get_password_data(InstanceID, default_config()).

-spec get_password_data(string(), aws_config()) -> ok_error(proplist()).
get_password_data(InstanceID, Config)
  when is_list(InstanceID) ->
    case ec2_query(Config, "GetPasswordData", [{"InstanceId", InstanceID}]) of
        {ok, Doc} ->
            {ok, [
                {instance_id, get_text("/GetPasswordDataResponse/instanceId", Doc)},
                {timestamp, erlcloud_xml:get_time("/GetPasswordDataResponse/timestamp", Doc)},
                {password_data, get_text("/GetPasswordDataResponse/passwordData", Doc)}
            ]};
        {error, _} = Error ->
            Error
    end.

-spec modify_image_attribute(string(), atom(), term()) -> ok.
modify_image_attribute(ImageID, Attribute, Value) ->
    modify_image_attribute(ImageID, Attribute, Value, default_config()).

-spec modify_image_attribute(string(), atom(), term(), aws_config()) -> ok.
modify_image_attribute(ImageID, Attribute, Value, Config) ->
    {AttributeName, OperationType, Values} = case {Attribute, Value} of
                                                 {launch_permission, {Operation, Permissions}}
                                                   when Operation =:= add orelse Operation =:= remove,
                                                        is_list(Permissions) ->
                                                     {"launchPermission", Operation, permission_list(Permissions)};
                                                 {description, Desc} ->
                                                     {"description", none, [{"Description", Desc}]};
                                                 {product_codes, ProductCodes} ->
                                                     {"productCodes", none, erlcloud_aws:param_list(ProductCodes, "ProductCode")}
                                             end,

    Params = [{"ImageId", ImageID},
              {"Attribute", AttributeName},
              {"OperationType", OperationType}|
              Values
             ],
    ec2_simple_query(Config, "ModifyImageAttribute", Params).

-spec modify_instance_attribute(string(), atom(), term()) -> ok.
modify_instance_attribute(InstanceID, Attribute, Value) ->
    modify_instance_attribute(InstanceID, Attribute, Value, default_config()).

-spec modify_instance_attribute(newstyle | string(), string()|atom(), string()|atom()|term(), string()|aws_config()) -> ok. %%FIXME
modify_instance_attribute(newstyle, InstanceID, Attribute, Value) ->
    modify_instance_attribute(newstyle, InstanceID, Attribute, Value, default_config());
modify_instance_attribute(InstanceID, Attribute, Value, Config) ->
    {AttributeName, AParams} =
        case Attribute of
            instance_type when is_list(Value) -> {"instanceType", [{"Value", Value}]};
            kernel when is_list(Value) -> {"kernel", [{"Value", Value}]};
            ramdisk when is_list(Value) -> {"ramdisk", [{"Value", Value}]};
            user_data when is_list(Value); is_binary(Value) -> {"userData", [{"Value", base64:encode(Value)}]};
            disable_api_termination when is_boolean(Value) ->
                {"disableApiTermination", [{"Value", Value}]};
            instance_initiated_shutdown_behavior
              when Value =:= stop; Value =:= terminate ->
                {"instanceInitiatedShutdownBehavior", [{"Value", Value}]};
            root_device_name when is_list(Value) -> {"rootDeviceName", Value};
            block_device_mapping when is_list(Value) ->
                {"blockDeviceMapping", block_device_params(Value)}
        end,
    Params = [{"InstanceID", InstanceID}, {"Attribute", AttributeName}|AParams],
    ec2_simple_query(Config, "ModifyInstanceAttribute", Params).

-spec modify_instance_attribute(newstyle, string(), string(), string(), aws_config()) -> ok.
modify_instance_attribute(newstyle, InstanceID, Attribute, Value, Config) -> %%FIXME
    ec2_simple_query(Config, "ModifyInstanceAttribute",
                     [{"InstanceId", InstanceID}, {Attribute, Value}], ?NEW_API_VERSION).

permission_list(Permissions) ->
    UserIDs = [UserID || {user_id, UserID} <- Permissions],
    Groups = [Group || {group, Group} <- Permissions],
    erlcloud_aws:param_list(UserIDs, "UserId") ++ erlcloud_aws:param_list(Groups, "Group").

-spec modify_snapshot_attribute(string(), atom(), term()) -> ok.
modify_snapshot_attribute(SnapshotID, Attribute, Value) ->
    modify_snapshot_attribute(SnapshotID, Attribute, Value, default_config()).

-spec modify_snapshot_attribute(string(), atom(), term(), aws_config()) -> ok.
modify_snapshot_attribute(SnapshotID, create_volume_permission,
                          {Operation, Permissions}, Config)
  when Operation =:= add orelse Operation =:= remove,
       is_list(Permissions) ->
    Params = [{"SnapshotId", SnapshotID},
              {"Attribute", "createVolumePermission"},
              {"OperationType", Operation}|
              permission_list(Permissions)
             ],
    ec2_simple_query(Config, "ModifySnapshotAttribute", Params).

-spec monitor_instances([string()]) -> ok_error(proplist()).
monitor_instances(InstanceIDs) ->
    monitor_instances(InstanceIDs, default_config()).

-spec monitor_instances([string()], aws_config()) -> ok_error(proplist()).
monitor_instances(InstanceIDs, Config) ->
    case ec2_query(Config, "MonitorInstances", erlcloud_aws:param_list(InstanceIDs, "InstanceId")) of
        {ok, Doc} ->
            {ok, [extract_monitor_state(Node) || Node <- xmerl_xpath:string("/MonitorInstancesResponse/instancesSet/item", Doc)]};
        {error, _} = Error ->
            Error
    end.

extract_monitor_state(Node) ->
    [
     {instance_id, get_text("instanceId", Node)},
     {monitoring_state, get_text("monitoring/state", Node)}
    ].

-spec purchase_reserved_instances_offering([string() | {string(), pos_integer()}]) -> ok_error([string()]).
purchase_reserved_instances_offering(ReservedInstancesOfferings) ->
    purchase_reserved_instances_offering(ReservedInstancesOfferings, default_config()).

-spec purchase_reserved_instances_offering([string() | {string(), pos_integer()}], aws_config()) -> ok_error([string()]).
purchase_reserved_instances_offering(ReservedInstancesOfferings, Config)
  when is_list(ReservedInstancesOfferings), length(ReservedInstancesOfferings) > 0 ->
    Params = lists:flatten(
               [case Offering of
                    {OfferingID, Count} ->
                        [
                         {"ReservedInstancesOfferingId." ++ integer_to_list(I), OfferingID},
                         {"InstanceCount." ++ integer_to_list(I), Count}
                        ];
                    OfferingID when is_list(OfferingID) ->
                        [{"ReservedInstancesOfferingId." ++ integer_to_list(I), OfferingID}]
                end || {I, Offering} <- lists:zip(lists:seq(0, length(ReservedInstancesOfferings) - 1),
                                                  ReservedInstancesOfferings)]),
    case ec2_query(Config, "PurchaseReservedInstancesOffering", Params) of
        {ok, Doc} ->
            {ok, get_list("/PurchaseReservedInstancesOfferingResponse/reservedInstancesId", Doc)};
        {error, _} = Error ->
            Error
    end.

-spec reboot_instances([string()]) -> ok.
reboot_instances(InstanceIDs) -> reboot_instances(InstanceIDs, default_config()).

-spec reboot_instances([string()], aws_config()) -> ok.
reboot_instances(InstanceIDs, Config)
  when is_list(InstanceIDs) ->
    ec2_simple_query(Config, "RebootInstances", erlcloud_aws:param_list(InstanceIDs, "InstanceId")).

-spec register_image(ec2_image_spec()) -> ok_error(proplist()).
register_image(ImageSpec) -> register_image(ImageSpec, default_config()).

-spec register_image(ec2_image_spec(), aws_config()) -> ok_error(proplist()).
register_image(ImageSpec, Config) ->
    Params = [
              {"ImageLocation", ImageSpec#ec2_image_spec.image_location},
              {"Name", ImageSpec#ec2_image_spec.name},
              {"Description", ImageSpec#ec2_image_spec.description},
              {"Architecture", ImageSpec#ec2_image_spec.architecture},
              {"KernelId", ImageSpec#ec2_image_spec.kernel_id},
              {"RamdiskId", ImageSpec#ec2_image_spec.ramdisk_id},
              {"RootDeviceName", ImageSpec#ec2_image_spec.root_device_name}
             ],
    BDParams = block_device_params(ImageSpec#ec2_image_spec.block_device_mapping),
    case ec2_query(Config, "RegisterImage", Params ++ BDParams) of
        {ok, Doc} ->
            {ok, [{image_id, get_text("/RegisterImageResponse/imageId", Doc)}]};
        {error, _} = Error ->
            Error
    end.

-spec release_address(string()) -> ok.
release_address(PublicIP) -> release_address(PublicIP, default_config()).

-spec replace_network_acl_association(string(), string()) -> ok_error(string()).
replace_network_acl_association(AssociationID, NetworkAclID) ->
    replace_network_acl_association(AssociationID, NetworkAclID, default_config()).

-spec replace_network_acl_association(string(), string(), aws_config()) -> ok_error(string()).
replace_network_acl_association(AssociationID, NetworkAclID, Config) ->
    Params = [{"AssociationId", AssociationID},
              {"NetworkAclId", NetworkAclID}],
    case ec2_query(Config, "ReplaceNetworkAclAssociation", Params, ?NEW_API_VERSION) of
        {ok, Doc} ->
            Path = "/ReplaceNetworkAclAssociationResponse/newAssociationId",
            {ok, get_text(Path, Doc)};
        {error, _} = Error ->
            Error
    end.

-spec replace_network_acl_entry(ec2_network_acl_spec()) -> ok.
replace_network_acl_entry(Spec) ->
    replace_network_acl_entry(Spec, default_config()).

-spec replace_network_acl_entry(ec2_network_acl_spec(), aws_config()) -> ok.
replace_network_acl_entry(Spec, Config) ->
    Params = network_acl_spec_to_params(Spec),
    ec2_simple_query(Config, "ReplaceNetworkAclEntry", Params, ?NEW_API_VERSION).

-spec request_spot_instances(ec2_spot_instance_request()) -> ok_error(proplist()).
request_spot_instances(Request) ->
    request_spot_instances(Request, default_config()).

-spec request_spot_instances(ec2_spot_instance_request(), aws_config()) -> ok_error(proplist()).
request_spot_instances(Request, Config) ->
    InstanceSpec = Request#ec2_spot_instance_request.launch_specification,
    Params = [
              {"SpotPrice", Request#ec2_spot_instance_request.spot_price},
              {"InstanceCount", Request#ec2_spot_instance_request.instance_count},
              {"Type", case Request#ec2_spot_instance_request.type of one_time -> "one-time" ; persistent -> "persistent" end},
              {"ValidFrom", Request#ec2_spot_instance_request.valid_from},
              {"ValidUntil", Request#ec2_spot_instance_request.valid_until},
              {"LaunchGroup", Request#ec2_spot_instance_request.launch_group},
              {"AvailabilityZoneGroup", Request#ec2_spot_instance_request.availability_zone_group},
              {"LaunchSpecification.ImageId", InstanceSpec#ec2_instance_spec.image_id},
              {"LaunchSpecification.KeyName", InstanceSpec#ec2_instance_spec.key_name},
              {"LaunchSpecification.UserData",
               case InstanceSpec#ec2_instance_spec.user_data of
                   undefined -> undefined;
                   Data -> base64:encode(Data)
               end},
              {"LaunchSpecification.InstanceType", InstanceSpec#ec2_instance_spec.instance_type},
              {"LaunchSpecification.KernelId", InstanceSpec#ec2_instance_spec.kernel_id},
              {"LaunchSpecification.RamdiskId", InstanceSpec#ec2_instance_spec.ramdisk_id},
              {"LaunchSpecification.Monitoring.Enabled", InstanceSpec#ec2_instance_spec.monitoring_enabled},
              {"LaunchSpecification.Placement.AvailabilityZone", InstanceSpec#ec2_instance_spec.availability_zone},
              {"LaunchSpecification.Placement.GroupName", InstanceSpec#ec2_instance_spec.placement_group},
              {"LaunchSpecification.EbsOptimized", InstanceSpec#ec2_instance_spec.ebs_optimized},
              {"LaunchSpecification.IamInstanceProfile.Name", InstanceSpec#ec2_instance_spec.iam_instance_profile_name}
             ],
    NetParams = case InstanceSpec#ec2_instance_spec.net_if of
        [] ->
            [
                {"LaunchSpecification.SubnetId", InstanceSpec#ec2_instance_spec.subnet_id}
            ] ++ erlcloud_aws:param_list(InstanceSpec#ec2_instance_spec.group_set, "LaunchSpecification.SecurityGroup");
        List      ->
            net_if_params(List, "LaunchSpecification.NetworkInterface")
    end,
    BDParams = [
                {"LaunchSpecification." ++ Key, Value} ||
                   {Key, Value} <- block_device_params(InstanceSpec#ec2_instance_spec.block_device_mapping)],

    case ec2_query(Config, "RequestSpotInstances", Params ++ BDParams ++ NetParams, ?NEW_API_VERSION) of
        {ok, Doc} ->
            {ok, [extract_spot_instance_request(Item) ||
                    Item <- xmerl_xpath:string("/RequestSpotInstancesResponse/spotInstanceRequestSet/item", Doc)]};
        {error, Reason} ->
            {error, Reason}
    end.

encode_termination_policy(default) -> "Default";
encode_termination_policy(no_termination) -> "noTermination";
encode_termination_policy(undefined) -> undefined.

encode_allocation_strategy(lowest_price) -> "lowestPrice";
encode_allocation_strategy(diversified) -> "diversified";
encode_allocation_strategy(undefined) -> undefined.

extract_describe_spot_fleet_request(Doc) ->
    [
     {instance_id, get_text("instanceId", Doc)},
     {spot_instance_request_id, get_text("spotInstanceRequestId", Doc)},
     {instance_type, get_text("instanceType", Doc)}
    ].

-spec describe_spot_fleet_instances_all(string()) -> ok_error([{instances, [proplist()]}]).
describe_spot_fleet_instances_all(SpotFleetRequestId) ->
    describe_spot_fleet_instances_all(SpotFleetRequestId, default_config()).

-spec describe_spot_fleet_instances_all(string(), aws_config()) -> ok_error([{instances, [proplist()]}]).
describe_spot_fleet_instances_all(SpotFleetRequestId, Config) ->
    ListAll = fun(Fun, NextToken, Acc) ->
        case describe_spot_fleet_instances(SpotFleetRequestId, NextToken, undefined, Config) of
            {ok, Res} ->
                List = proplists:get_value(instances, Res),
                case proplists:get_value(next_token, Res) of
                    undefined -> {ok, lists:foldl(fun erlang:'++'/2, [], [List | Acc])};
                    NT -> Fun(Fun, NT, [List | Acc])
                end;
            {error, _} = E -> E
        end
    end,
    ListAll(ListAll, undefined, []).

-spec describe_spot_fleet_instances(spot_fleet_instance_id()) -> describe_spot_fleet_instances_return().
describe_spot_fleet_instances(SpotFleetRequestId) ->
    describe_spot_fleet_instances(SpotFleetRequestId, undefined, undefined, default_config()).

-spec describe_spot_fleet_instances(spot_fleet_instance_id(), ec2_token()) -> describe_spot_fleet_instances_return().
describe_spot_fleet_instances(SpotFleetRequestId, NextToken)
    when is_list(NextToken) orelse NextToken =:= undefined ->
    describe_spot_fleet_instances(SpotFleetRequestId, NextToken, undefined).

-spec describe_spot_fleet_instances(spot_fleet_instance_id(), ec2_token(), ec2_max_result())
    -> describe_spot_fleet_instances_return().
describe_spot_fleet_instances(SpotFleetRequestId, NextToken, MaxResults)
    when is_list(NextToken),
         is_list(NextToken) orelse NextToken =:= undefined,
         is_integer(MaxResults) orelse MaxResults =:= undefined ->
    describe_spot_fleet_instances(SpotFleetRequestId, NextToken, MaxResults, default_config()).

-spec describe_spot_fleet_instances(spot_fleet_instance_id(), ec2_token(), ec2_max_result(), aws_config())
    -> describe_spot_fleet_instances_return().
describe_spot_fleet_instances(SpotFleetRequestId, NextToken, MaxResults, Config)
    when is_list(NextToken) orelse NextToken =:= undefined,
         is_integer(MaxResults) andalso
         MaxResults >= ?SPOT_FLEET_INSTANCES_MR_MIN andalso MaxResults =< ?SPOT_FLEET_INSTANCES_MR_MAX orelse
         MaxResults =:= undefined,
         is_record(Config, aws_config) ->
    Params = [{"SpotFleetRequestId", SpotFleetRequestId}, {"MaxResults", MaxResults}, {"NextToken", NextToken}],
    case ec2_query(Config, "DescribeSpotFleetInstances", Params, ?NEW_API_VERSION) of
        {ok, Doc} ->
            Instances = extract_results("DescribeSpotFleetInstancesResponse", "activeInstanceSet",
                fun extract_describe_spot_fleet_request/1, Doc),
            NewNextToken = extract_next_token("DescribeSpotFleetInstances", Doc),
            {ok, [{instances, Instances}, {next_token, NewNextToken}]};
        {error, _} = E -> E
    end.

-spec modify_spot_fleet_request(string(), non_neg_integer(), default | no_termination) -> ok_error().
modify_spot_fleet_request(SpotFleetRequestId, TargetCapacity, ExcessCapacityTerminationPolicy) ->
    modify_spot_fleet_request(SpotFleetRequestId, TargetCapacity,
        ExcessCapacityTerminationPolicy, default_config()).

-spec modify_spot_fleet_request(string(), non_neg_integer(), default | no_termination, aws_config()) -> ok_error().
modify_spot_fleet_request(SpotFleetRequestId, TargetCapacity, ExcessCapacityTerminationPolicy, Config) ->
    Params = [
        {"ExcessCapacityTerminationPolicy", encode_termination_policy(ExcessCapacityTerminationPolicy)},
        {"SpotFleetRequestId", SpotFleetRequestId},
        {"TargetCapacity", TargetCapacity}],

    case ec2_query(Config, "ModifySpotFleetRequest", Params, ?NEW_API_VERSION) of
        {ok, _Doc} -> ok;
        {error, _} = E -> E
    end.

extract_unsuccessful_fleet_request(Doc) ->
    [
     {spot_fleet_request_id, get_text("spotFleetRequestId", Doc)},
     {error_code, get_text("error/code", Doc)},
     {error_message, get_text("error/message", Doc)}
    ].
extract_successful_fleet_request(Doc) ->
    [
     {spot_fleet_request_id, get_text("spotFleetRequestId", Doc)},
     {current_spot_fleet_request_state, get_text("currentSpotFleetRequestState", Doc)},
     {previous_spot_fleet_request_state, get_text("previousSpotFleetRequestState", Doc)}
    ].
extract_cancel_spot_fleet_response(Doc) ->
    [
     {unsuccessful_fleet_request_set, [ extract_unsuccessful_fleet_request(Item) ||
         Item <- xmerl_xpath:string("/CancelSpotFleetRequestsResponse/unsuccessfulFleetRequestSet/item", Doc)]},
     {successful_fleet_request_set, [ extract_successful_fleet_request(Item) ||
         Item <- xmerl_xpath:string("/CancelSpotFleetRequestsResponse/successfulFleetRequestSet/item", Doc)]}
    ].

-spec cancel_spot_fleet_requests([string()], boolean()) -> ok_error(proplist()).
cancel_spot_fleet_requests(SpotFleetRequestIds, TerminateInstances) ->
    cancel_spot_fleet_requests(SpotFleetRequestIds, TerminateInstances, default_config()).

-spec cancel_spot_fleet_requests([string()], boolean(), aws_config()) -> ok_error(proplist()).
cancel_spot_fleet_requests(SpotFleetRequestIds, TerminateInstances, Config) ->
    Params = [
        {"TerminateInstances", TerminateInstances} |
        lists:foldl(
            fun(Req, Acc) ->
                [{"SpotFleetRequestId." ++ integer_to_list(length(Acc) + 1), Req} | Acc]
            end, [],
            SpotFleetRequestIds)
    ],
    case ec2_query(Config, "CancelSpotFleetRequests", Params, ?NEW_API_VERSION) of
        {ok, Doc} ->
            {ok, extract_cancel_spot_fleet_response(Doc)};
        {error, _} = E -> E
    end.

-spec request_spot_fleet(ec2_spot_fleet_request()) -> ok_error(string()).
request_spot_fleet(Request) ->
    request_spot_fleet(Request, default_config()).

-spec request_spot_fleet(ec2_spot_fleet_request(), aws_config()) -> ok_error(string()).
request_spot_fleet(Request, Config) ->
    LConf = Request#ec2_spot_fleet_request.spot_fleet_request_config,
    {LSpecs, _} = lists:foldl(
        fun(InstanceSpec, {Acc, Idx}) ->
            Prefix = "SpotFleetRequestConfig.LaunchSpecifications." ++ integer_to_list(Idx) ++ ".",

            NetParams = case InstanceSpec#ec2_instance_spec.net_if of
                [] ->
                    [
                        {Prefix ++ "SubnetId", InstanceSpec#ec2_instance_spec.subnet_id}
                    ] ++ erlcloud_aws:param_list(InstanceSpec#ec2_instance_spec.group_set, Prefix ++ "SecurityGroup");
                List      ->
                    net_if_params(List, Prefix ++ "NetworkInterface")
            end,
            BDParams = [
                {Prefix ++ Key, Value} ||
                   {Key, Value} <- block_device_params(InstanceSpec#ec2_instance_spec.block_device_mapping)],
            {[
                {Prefix ++ "ImageId", InstanceSpec#ec2_instance_spec.image_id},
                {Prefix ++ "KeyName", InstanceSpec#ec2_instance_spec.key_name},
                {Prefix ++ "UserData",
                    case InstanceSpec#ec2_instance_spec.user_data of
                        undefined -> undefined;
                        Data -> base64:encode(Data)
                    end},
                {Prefix ++ "InstanceType", InstanceSpec#ec2_instance_spec.instance_type},
                {Prefix ++ "KernelId", InstanceSpec#ec2_instance_spec.kernel_id},
                {Prefix ++ "RamdiskId", InstanceSpec#ec2_instance_spec.ramdisk_id},
                {Prefix ++ "Monitoring.Enabled", InstanceSpec#ec2_instance_spec.monitoring_enabled},
                {Prefix ++ "Placement.AvailabilityZone", InstanceSpec#ec2_instance_spec.availability_zone},
                {Prefix ++ "Placement.GroupName", InstanceSpec#ec2_instance_spec.placement_group},
                {Prefix ++ "EbsOptimized", InstanceSpec#ec2_instance_spec.ebs_optimized},
                {Prefix ++ "IamInstanceProfile.Name", InstanceSpec#ec2_instance_spec.iam_instance_profile_name},
                {Prefix ++ "WeightedCapacity", InstanceSpec#ec2_instance_spec.weighted_capacity},
                {Prefix ++ "SportPrice", InstanceSpec#ec2_instance_spec.spot_price}
            ] ++ NetParams ++ BDParams ++ Acc, Idx + 1}
        end,
        {[], 1},
        Request#ec2_spot_fleet_request.spot_fleet_request_config#spot_fleet_request_config_spec.launch_specification),
    Params = [
        {"SpotFleetRequestConfig.AllocationStrategy",
            encode_allocation_strategy(LConf#spot_fleet_request_config_spec.allocation_strategy)},
        {"SpotFleetRequestConfig.ClientToken", LConf#spot_fleet_request_config_spec.client_token},
        {"SpotFleetRequestConfig.ExcessCapacityTerminationPolicy",
            encode_termination_policy(LConf#spot_fleet_request_config_spec.excess_capacity_termination_policy)},
        {"SpotFleetRequestConfig.IamFleetRole", LConf#spot_fleet_request_config_spec.iam_fleet_role},
        {"SpotFleetRequestConfig.SpotPrice", LConf#spot_fleet_request_config_spec.spot_price},
        {"SpotFleetRequestConfig.TargetCapacity", LConf#spot_fleet_request_config_spec.target_capacity},
        {"SpotFleetRequestConfig.TerminateInstancesWithExpiration",
            LConf#spot_fleet_request_config_spec.terminate_instances_with_expiration},
        {"SpotFleetRequestConfig.ValidFrom", LConf#spot_fleet_request_config_spec.valid_from},
        {"SpotFleetRequestConfig.ValidUntil", LConf#spot_fleet_request_config_spec.valid_until}
    ] ++ LSpecs,

    case ec2_query(Config, "RequestSpotFleet", Params, ?NEW_API_VERSION) of
        {ok, Doc} ->
            {ok, get_text("/RequestSpotFleetResponse/spotFleetRequestId", Doc)};
        {error, _} = E -> E
    end.

-spec release_address(string(), aws_config()) -> ok.
release_address(PublicIP, Config)
  when is_list(PublicIP) ->
    ec2_simple_query(Config, "ReleaseAddress", [{"PublicIp", PublicIP}]).

-spec reset_image_attribute(string(), atom()) -> ok.
reset_image_attribute(ImageID, Attribute) ->
    reset_image_attribute(ImageID, Attribute, default_config()).

-spec reset_image_attribute(string(), atom(), aws_config()) -> ok.
reset_image_attribute(ImageID, launch_permission, Config) ->
    ec2_simple_query(Config, "ResetImageAttribute",
                     [{"ImageId", ImageID}, {"Attribute", "launchPermission"}]).

-spec reset_instance_attribute(string(), atom()) -> ok.
reset_instance_attribute(InstanceID, Attribute) ->
    reset_instance_attribute(InstanceID, Attribute, default_config()).

-spec reset_instance_attribute(string(), atom(), aws_config()) -> ok.
reset_instance_attribute(InstanceID, Attribute, Config)
  when is_list(InstanceID),
       Attribute =:= kernel orelse Attribute =:= ramdisk ->
    ec2_simple_query(Config, "ResetInstanceAttribute",
                     [{"InstanceId", InstanceID}, {"Attribute", Attribute}]).

-spec reset_snapshot_attribute(string(), atom()) -> ok.
reset_snapshot_attribute(SnapshotID, Attribute) ->
    reset_snapshot_attribute(SnapshotID, Attribute, default_config()).

-spec reset_snapshot_attribute(string(), atom(), aws_config()) -> ok.
reset_snapshot_attribute(SnapshotID, create_volume_permission, Config)
  when is_list(SnapshotID) ->
    ec2_simple_query(Config, "ResetSnapshotAttribute",
                     [{"snapshotId", SnapshotID}, {"Attribute", "createVolumePermission"}]).

-spec revoke_security_group_ingress(string(), ec2_ingress_spec()) -> ok.
revoke_security_group_ingress(GroupName, IngressSpec) ->
    revoke_security_group_ingress(GroupName, IngressSpec, default_config()).

-spec revoke_security_group_ingress(string(), ec2_ingress_spec() | [vpc_ingress_spec()], aws_config()) -> ok.
revoke_security_group_ingress(GroupName, IngressSpec, Config)
  when is_list(GroupName), is_record(IngressSpec, ec2_ingress_spec) ->
    Params = [{"GroupName", GroupName}|ingress_spec_params(IngressSpec)],
    ec2_simple_query(Config, "RevokeSecurityGroupIngress", Params);

revoke_security_group_ingress(GroupId, VpcIngressSpec, Config)
  when is_list(GroupId), is_list(VpcIngressSpec) ->
    Params = [{"GroupId", GroupId} |vpc_ingress_spec_to_params(VpcIngressSpec)],
    ec2_simple_query(Config, "RevokeSecurityGroupIngress", Params, ?NEW_API_VERSION).

-spec revoke_security_group_egress(string(), [vpc_egress_spec()]) -> ok.
revoke_security_group_egress(GroupName, VpcEgressSpec) ->
    revoke_security_group_egress(GroupName, VpcEgressSpec, default_config()).

-spec revoke_security_group_egress(string(), [vpc_egress_spec()], aws_config()) -> ok.
revoke_security_group_egress(GroupId, VpcEgressSpec, Config)
  when is_list(GroupId), is_list(VpcEgressSpec) ->
    Params = [{"GroupId", GroupId} |vpc_egress_spec_to_params(VpcEgressSpec)],
    ec2_simple_query(Config, "RevokeSecurityGroupEgress", Params, ?NEW_API_VERSION).

-spec run_instances(ec2_instance_spec()) -> ok_error(proplist()).
run_instances(InstanceSpec) -> run_instances(InstanceSpec, default_config()).

-spec run_instances(ec2_instance_spec(), aws_config()) -> ok_error(proplist()).
run_instances(InstanceSpec, Config)
  when is_record(InstanceSpec, ec2_instance_spec) ->
    Params = [
              {"ImageId", InstanceSpec#ec2_instance_spec.image_id},
              {"MaxCount", InstanceSpec#ec2_instance_spec.max_count},
              {"MinCount", InstanceSpec#ec2_instance_spec.min_count},
              {"KeyName", InstanceSpec#ec2_instance_spec.key_name},
              {"UserData",
               case InstanceSpec#ec2_instance_spec.user_data of
                   undefined -> undefined;
                   Data -> base64:encode(Data)
               end},
              {"InstanceType", InstanceSpec#ec2_instance_spec.instance_type},
              {"KernelId", InstanceSpec#ec2_instance_spec.kernel_id},
              {"RamdiskId", InstanceSpec#ec2_instance_spec.ramdisk_id},
              {"Monitoring.Enabled", InstanceSpec#ec2_instance_spec.monitoring_enabled},
              {"Placement.AvailabilityZone", InstanceSpec#ec2_instance_spec.availability_zone},
              {"Placement.GroupName", InstanceSpec#ec2_instance_spec.placement_group},
              {"DisableApiTermination", InstanceSpec#ec2_instance_spec.disable_api_termination},
              {"InstanceInitiatedShutdownBehavior", InstanceSpec#ec2_instance_spec.instance_initiated_shutdown_behavior},
              {"EbsOptimized", InstanceSpec#ec2_instance_spec.ebs_optimized},
              {"IamInstanceProfile.Name", InstanceSpec#ec2_instance_spec.iam_instance_profile_name}
             ],
    NetParams = case InstanceSpec#ec2_instance_spec.net_if of
        [] ->
            [
                {"SubnetId", InstanceSpec#ec2_instance_spec.subnet_id}
            ] ++ erlcloud_aws:param_list(InstanceSpec#ec2_instance_spec.group_set, "SecurityGroupId");
        List      ->
            net_if_params(List, "NetworkInterface")
    end,
    BDParams  = block_device_params(InstanceSpec#ec2_instance_spec.block_device_mapping),
    case ec2_query(Config, "RunInstances", Params ++ NetParams ++ BDParams, ?NEW_API_VERSION) of
        {ok, Doc} ->
            {ok, extract_reservation(hd(xmerl_xpath:string("/RunInstancesResponse", Doc)))};
        {error, _} = Error ->
            Error
    end.

private_ip_params([]) -> [];
private_ip_params([HeadIP|TailIPs]) ->
    [{"PrivateIpAddress", HeadIP}|
      erlcloud_aws:param_list(
        [[{"PrivateIpAddress", IP}] || IP <- TailIPs], "PrivateIpAddresses")].

public_ip_params(undefined) -> [];
public_ip_params(Bool) -> [{"AssociatePublicIpAddress", Bool}].

net_if_params(#ec2_net_if{}=X) ->
    [
        {"DeviceIndex", X#ec2_net_if.device_index},
        {"SubnetId",    X#ec2_net_if.subnet_id}
    ]
    ++ public_ip_params(X#ec2_net_if.associate_public_ip)
    ++ private_ip_params(X#ec2_net_if.private_ip)
    ++ erlcloud_aws:param_list(X#ec2_net_if.security_group, "SecurityGroupId").
net_if_params(List, Prefix) ->
    erlcloud_aws:param_list([net_if_params(X) || X <- List], Prefix).

%%
%% Function for making calls to CreateFlowLogs action
%% DescribeFlowLogs Documentation: http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_CreateFlowLogs.html
%%
-spec create_flow_logs(
        string(),
        vpc | subnet | network_interface,
        [string()],
        accept | reject | all,
        string()) -> ok_error(string()).
create_flow_logs(LogGroupName, ResourceType, ResourceIDs, TrafficType, DeliverLogsPermissionArn) ->
    create_flow_logs(LogGroupName, ResourceType, ResourceIDs, TrafficType, DeliverLogsPermissionArn, none, default_config()).

-spec create_flow_logs(
        string(),
        vpc | subnet | network_interface,
        [string()],
        accept | reject | all,
        string() | none,
        string() | aws_config()) -> ok_error(string()).
create_flow_logs(LogGroupName, ResourceType, ResourceIDs, TrafficType, DeliverLogsPermissionArn, Config)
    when is_record(Config, aws_config) ->
    create_flow_logs(LogGroupName, ResourceType, ResourceIDs, TrafficType, DeliverLogsPermissionArn, none, Config);
create_flow_logs(LogGroupName, ResourceType, ResourceIDs, TrafficType, DeliverLogsPermissionArn, ClientToken) ->
    create_flow_logs(LogGroupName, ResourceType, ResourceIDs, TrafficType, DeliverLogsPermissionArn, ClientToken, default_config()).

-spec create_flow_logs(
        string(),
        vpc | subnet | network_interface,
        [string()],
        accept | reject | all,
        string(),
        string() | none,
        aws_config()) -> ok_error(string()).
create_flow_logs(LogGroupName, ResourceType, ResourceIDs, TrafficType, DeliverLogsPermissionArn, ClientToken, Config)
    when is_record(Config, aws_config) ->
    {Resources, _} = lists:foldl(fun(ID, {Acc, Index}) ->
                                    I = integer_to_list(Index),
                                    ResourceID = "ResourceId."++I,
                                    {[{ResourceID, ID} | Acc], Index+1}
                            end, {[], 1}, ResourceIDs),
    RT = case ResourceType of
            vpc -> "VPC";
            subnet -> "Subnet";
            network_interface -> "NetworkInterface"
        end,
    TT = case TrafficType of
            accept -> "ACCEPT";
            reject -> "REJECT";
            all -> "ALL"
        end,
    P = [
        {"LogGroupName", LogGroupName},
        {"ResourceType", RT},
        {"TrafficType", TT},
        {"DeliverLogsPermissionArn", DeliverLogsPermissionArn}
    ] ++ Resources,
    Params = case ClientToken of
                none -> P;
                _ -> P ++ [{"ClientToken", ClientToken}]
            end,
    case ec2_query(Config, "CreateFlowLogs", Params, ?NEW_API_VERSION) of
        {ok, Doc} ->
            {ok, [
                    {flow_log_id_set, [get_text(Item) || Item <- xmerl_xpath:string("/CreateFlowLogsResponse/flowLogIdSet/item", Doc)]},
                    {client_token, get_text("/CreateFlowLogsResponse/clientToken", Doc)},
                    {unsuccessful, [extract_unsuccesful_item(Item) || Item <- xmerl_xpath:string("/CreateFlowLogsResponse/unsuccessful", Doc)]}
                 ]};
        {error, _} = Error ->
            Error
    end.

%%
%% Function for making calls to DeleteFlowLogs action
%% DescribeFlowLogs Documentation: http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DeleteFlowLogs.html
%%
-spec delete_flow_logs([string()]) -> ok_error(proplist()).
delete_flow_logs(FlowIDs) ->
    delete_flow_logs(FlowIDs, default_config()).

-spec delete_flow_logs([string()], aws_config()) -> ok_error(proplist()).
delete_flow_logs(FlowIDs, Config) when is_record(Config, aws_config) ->
    {Resources, _} = lists:foldl(fun(ID, {Acc, Index}) ->
                                    I = integer_to_list(Index),
                                    FlowID = "FlowLogId."++I,
                                    {[{FlowID, ID} | Acc], Index+1}
                            end, {[], 1}, FlowIDs),

    case ec2_query(Config, "DeleteFlowLogs", Resources, ?NEW_API_VERSION) of
        {ok, Doc} ->
            {ok, [
                    {unsuccessful, [extract_unsuccesful_item(Item) || Item <- xmerl_xpath:string("/DeleteFlowLogsResponse/unsuccessful", Doc)]}
                 ]
            };
        {error, _} = Error ->
            Error
    end.

%%
%% Function for making calls to DescribeFlowLogs action
%% DescribeFlowLogs Documentation: http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DescribeFlowLogs.html
%%
-spec describe_flow_logs() -> ok_error([proplist()]).
describe_flow_logs() ->
    describe_flow_logs([]).

-spec describe_flow_logs(aws_config()) -> ok_error([proplist()]);
                        (filter_list()) -> ok_error([proplist()]);
                        (ec2_max_result()) -> ok_error([proplist()], ec2_token()).
describe_flow_logs(Config)
    when is_record(Config, aws_config) ->
    describe_flow_logs([], Config);
describe_flow_logs(Filter)
    when is_list(Filter) orelse Filter =:= none ->
    describe_flow_logs([], Filter);
describe_flow_logs(MaxResults)
    when is_integer(MaxResults) ->
    describe_flow_logs([], MaxResults).

-spec describe_flow_logs(ec2_flow_ids(), filter_list()) -> ok_error([proplist()]);
                        (filter_list(), aws_config()) -> ok_error([proplist()]);
                        (filter_list(), ec2_max_result()) -> ok_error([proplist()], ec2_token());
                        (ec2_max_result(), aws_config()) -> ok_error([proplist()], ec2_token());
                        (ec2_max_result(), ec2_token()) -> ok_error([proplist()], ec2_token()).
describe_flow_logs(FlowIDs, Filter)
    when is_list(FlowIDs),
         is_list(Filter) orelse Filter =:= none ->
    describe_flow_logs(FlowIDs, Filter, default_config());
describe_flow_logs(Filter, Config)
    when is_list(Filter) orelse Filter =:= none,
         is_record(Config, aws_config) ->
    describe_flow_logs([], Filter, Config);
describe_flow_logs(Filter, MaxResults)
    when is_list(Filter) orelse Filter =:= none,
         is_integer(MaxResults) andalso MaxResults >= ?FLOWS_MR_MIN andalso MaxResults =< ?FLOWS_MR_MAX ->
    describe_flow_logs(Filter, MaxResults, undefined);
describe_flow_logs(MaxResults, Config)
    when is_integer(MaxResults) andalso MaxResults >= ?FLOWS_MR_MIN andalso MaxResults =< ?FLOWS_MR_MAX,
         is_record(Config, aws_config) ->
    describe_flow_logs([], MaxResults, Config);
describe_flow_logs(MaxResults, NextToken)
    when is_integer(MaxResults) andalso MaxResults >= ?FLOWS_MR_MIN andalso MaxResults =< ?FLOWS_MR_MAX,
         is_list(NextToken) ->
    describe_flow_logs([], MaxResults, NextToken).

-spec describe_flow_logs(ec2_flow_ids(), filter_list(), aws_config()) -> ok_error([proplist()]);
                        (filter_list(), ec2_max_result(), aws_config()) -> ok_error([proplist()], ec2_token());
                        (filter_list(), ec2_max_result(), ec2_token()) -> ok_error([proplist()], ec2_token());
                        (ec2_max_result(), ec2_token(), aws_config()) -> ok_error([proplist()], ec2_token()).
describe_flow_logs(FlowIDs, Filter, Config)
    when is_list(FlowIDs),
         is_list(Filter) orelse Filter =:= none,
         is_record(Config, aws_config) ->
    Params = erlcloud_aws:param_list(FlowIDs, "FlowLogId") ++ list_to_ec2_filter(Filter),
    case ec2_query(Config, "DescribeFlowLogs", Params, ?NEW_API_VERSION) of
        {ok, Doc} ->
            Flows = extract_results("DescribeFlowLogsResponse", "flowLogSet", fun extract_flow/1, Doc),
            {ok, Flows};
        {error, _} = E -> E
    end;
describe_flow_logs(Filter, MaxResults, Config)
    when is_list(Filter) orelse Filter =:= none,
         is_integer(MaxResults) andalso MaxResults >= ?FLOWS_MR_MIN andalso MaxResults =< ?FLOWS_MR_MAX,
         is_record(Config, aws_config) ->
    describe_flow_logs(Filter, MaxResults, undefined, Config);
describe_flow_logs(Filter, MaxResults, NextToken)
    when is_list(Filter) orelse Filter =:= none,
         is_integer(MaxResults) andalso MaxResults >= ?FLOWS_MR_MIN andalso MaxResults =< ?FLOWS_MR_MAX,
         is_list(NextToken) orelse NextToken =:= undefined ->
    describe_flow_logs(Filter, MaxResults, NextToken, default_config());
describe_flow_logs(MaxResults, NextToken, Config)
    when is_integer(MaxResults) andalso MaxResults >= ?FLOWS_MR_MIN andalso MaxResults =< ?FLOWS_MR_MAX,
         is_list(NextToken) orelse NextToken =:= undefined,
         is_record(Config, aws_config) ->
    describe_flow_logs([], MaxResults, NextToken, Config).

-spec describe_flow_logs(filter_list(), ec2_max_result(), ec2_token(), aws_config()) -> ok_error([proplist()], ec2_token()).
describe_flow_logs(Filter, MaxResults, NextToken, Config)
    when is_list(Filter) orelse Filter =:= none,
         is_integer(MaxResults) andalso MaxResults >= ?FLOWS_MR_MIN andalso MaxResults =< ?FLOWS_MR_MAX,
         is_list(NextToken) orelse NextToken =:= undefined,
         is_record(Config, aws_config) ->
    Params = list_to_ec2_filter(Filter) ++ [{"MaxResults", MaxResults}, {"NextToken", NextToken}],
    case ec2_query(Config, "DescribeFlowLogs", Params, ?NEW_API_VERSION) of
        {ok, Doc} ->
            Flows = extract_results("DescribeFlowLogsResponse", "flowLogSet", fun extract_flow/1, Doc),
            NewNextToken = extract_next_token("DescribeFlowLogsResponse", Doc),
            {ok, Flows, NewNextToken};
        {error,  _} = E -> E
    end.

extract_flow(Node) ->
    [
        {deliver_logs_error_message, get_text("deliverLogsErrorMessage", Node)},
        {resource_id, get_text("resourceId", Node)},
        {deliver_logs_permission_arn, get_text("deliverLogsPermissionArn", Node)},
        {flow_log_status, get_text("flowLogStatus", Node)},
        {creation_time, erlcloud_xml:get_time("creationTime", Node)},
        {log_group_name, get_text("logGroupName", Node)},
        {traffic_type, get_text("trafficType", Node)},
        {flow_log_id, get_text("flowLogId", Node)}
    ].

-spec create_tags([string()], [{string(), string()}]) -> ok_error(proplist()).
create_tags(ResourceIds, TagsList) when is_list(ResourceIds) ->
    create_tags(ResourceIds, TagsList, default_config()).

-spec create_tags([string()], [{string(), string()}], aws_config()) -> ok_error(proplist()).
create_tags(ResourceIds, TagsList, Config) when is_list(ResourceIds)->
    Tags = tags_parameters(TagsList),
    {Resources, _} = lists:foldl(fun(ResourceId, {Acc, Index}) ->
                                         I = integer_to_list(Index),
                                         TKey = "ResourceId."++I,
                                         {[{TKey, ResourceId} | Acc], Index+1}
                                 end, {[], 1}, ResourceIds),
    case ec2_query(Config, "CreateTags", Resources ++ Tags, ?NEW_API_VERSION) of
        {ok, Doc} ->
            {ok, [{return, get_text("/CreateTagsResponse/return", Doc)}]};
        {error, _} = Error ->
            Error
    end.

%% Tags are sent as individually indexed keys and values in parameters.
-spec tags_parameters([{string(), string()}]) ->
    [{string(), string()}].
tags_parameters(TagsList) when is_list(TagsList) ->
    {Tags, _} = lists:foldl(fun({Key, Value}, {Acc, Index}) ->
                                    I = integer_to_list(Index),
                                    TKKey = "Tag."++I++".Key",
                                    TVKey = "Tag."++I++".Value",
                                    {[{TKKey, Key}, {TVKey, Value} | Acc], Index+1}
                            end, {[], 1}, TagsList),
    Tags.

%% When passing tags as part of a CreateVolume, CreateSnapshot etc request,
%% they must be nested inside a TagSpecification.N structure, but if the
%% taglist is empty we should return an equally empty list.
-spec tags_parameters(string(), [{string(), string()}]) ->
    [{string(), string()}].
tags_parameters(_, []) ->
    [];
tags_parameters(ResourceType, TagsList)
  when is_list(TagsList) ->
    TagSpecResourceType = {"TagSpecification.1.ResourceType", ResourceType},
    RawTagsParams = tags_parameters(TagsList),
    TagSpecTagsParams = [ {"TagSpecification.1."++Key, Value}
                          || {Key, Value} <- RawTagsParams ],
    [ TagSpecResourceType | TagSpecTagsParams ].

-spec delete_tags([string()], [{string(), string()}]) -> ok_error(proplist()).
delete_tags(ResourceIds, TagsList) when is_list(ResourceIds) ->
    delete_tags(ResourceIds, TagsList, default_config()).

-spec delete_tags([string()], [{string(), string()}], aws_config()) -> ok_error(proplist()).
delete_tags(ResourceIds, TagsList, Config) when is_list(ResourceIds)->
    Tags = tags_parameters(TagsList),
    {Resources, _} = lists:foldl(fun(ResourceId, {Acc, Index}) ->
                                         I = integer_to_list(Index),
                                         TKey = "ResourceId."++I,
                                         {[{TKey, ResourceId} | Acc], Index+1}
                                 end, {[], 1}, ResourceIds),
    case ec2_query(Config, "DeleteTags", Resources ++ Tags, ?NEW_API_VERSION) of
        {ok, Doc} ->
            {ok, [{return, get_text("/DeleteTagsResponse/return", Doc)}]};
        {error, _} = Error ->
            Error
    end.

-spec describe_tags() -> ok_error([#ec2_tag{}]).
describe_tags() ->
    describe_tags([]).

-spec describe_tags(filter_list()) -> ok_error([#ec2_tag{}]);
(aws_config()) -> ok_error(proplist()).
describe_tags(Filters)
    when is_list(Filters) orelse Filters =:= none ->
    describe_tags(Filters, default_config());
describe_tags(Config)
    when is_record(Config, aws_config) ->
    describe_tags([], Config)     .

-spec describe_tags(filter_list(), aws_config()) -> ok_error([#ec2_tag{}]).
describe_tags(Filters, Config)
    when is_list(Filters) orelse Filters =:= none, is_record(Config, aws_config) ->
    Params = list_to_ec2_filter(Filters),
    case ec2_query(Config, "DescribeTags", Params, ?NEW_API_VERSION) of
        {ok, Doc} ->
            Tags = extract_results("DescribeTagsResponse", "tagSet", fun extract_tag/1, Doc),
            {ok, Tags};
        {error, _} = E -> E
    end.

-spec describe_tags(filter_list(), ec2_max_result(), ec2_token()) -> ok_error([#ec2_tag{}], ec2_token()).
describe_tags(Filters, MaxResults, NextToken)
    when is_list(Filters) orelse Filters =:= none, is_integer(MaxResults), is_list(NextToken)  orelse NextToken =:= undefined ->
    describe_tags(Filters, MaxResults, NextToken, default_config()).

-spec describe_tags(filter_list(), ec2_max_result(), ec2_token(), aws_config())
    -> ok_error([#ec2_tag{}], ec2_token()).
describe_tags(Filters, MaxResults, NextToken, Config)
    when is_list(Filters) orelse Filters =:= none,
         is_integer(MaxResults), MaxResults >= ?TAGS_MR_MIN, MaxResults =< ?TAGS_MR_MAX,
         is_list(NextToken) orelse NextToken =:= undefined,
         is_record(Config, aws_config) ->
    Params = [{"MaxResults", MaxResults}, {"NextToken", NextToken}] ++
             list_to_ec2_filter(Filters),
    case ec2_query(Config, "DescribeTags", Params, ?NEW_API_VERSION) of
        {ok, Doc} ->
            Tags = extract_results("DescribeTagsResponse", "tagSet", fun extract_tag/1, Doc),
            NewNextToken = extract_next_token("DescribeTagsResponse", Doc),
            {ok, Tags, NewNextToken};
        {error, _} = E -> E
    end.

-spec extract_tag(term()) -> #ec2_tag{}.
extract_tag(Node) ->
    #ec2_tag{
             resource_id = get_text("resourceId", Node),
             resource_type = get_text("resourceType", Node),
             key = get_text("key", Node),
             value = get_text("value", Node)}.

extract_tag_item(Node) ->
    [
     {key, get_text("key", Node)},
     {value, get_text("value", Node)}
    ].

block_device_params(Mappings) ->
    erlcloud_aws:param_list(
      [[{"DeviceName", Mapping#ec2_block_device_mapping.device_name},
        {"VirtualName", Mapping#ec2_block_device_mapping.virtual_name}] ++
           if Mapping#ec2_block_device_mapping.snapshot_id =/= none,
              Mapping#ec2_block_device_mapping.snapshot_id =/= undefined ->
                   [{"Ebs.SnapshotId", Mapping#ec2_block_device_mapping.snapshot_id},
                    {"Ebs.DeleteOnTermination", Mapping#ec2_block_device_mapping.delete_on_termination}];
              is_integer(Mapping#ec2_block_device_mapping.volume_size) ->
                   [{"Ebs.VolumeSize", Mapping#ec2_block_device_mapping.volume_size},
                    {"Ebs.DeleteOnTermination", Mapping#ec2_block_device_mapping.delete_on_termination}];
              true ->
                   []
           end ||
          Mapping <- Mappings], "BlockDeviceMapping").

-spec start_instances([string()]) -> ok_error(proplist()).
start_instances(InstanceIDs) -> start_instances(InstanceIDs, default_config()).

-spec start_instances([string()], aws_config()) -> ok_error(proplist()).
start_instances(InstanceIDs, Config)
  when is_list(InstanceIDs) ->
    case ec2_query(Config, "StartInstances", erlcloud_aws:param_list(InstanceIDs, "InstanceId")) of
        {ok, Doc} ->
            {ok, [extract_instance_state_change(Node) || Node <- xmerl_xpath:string("/StartInstancesResponse/instancesSet/item", Doc)]};
        {error, _} = Error ->
            Error
    end.

-spec stop_instances([string()]) -> ok_error(proplist()).
stop_instances(InstanceIDs) -> stop_instances(InstanceIDs, default_config()).

-spec stop_instances([string()], boolean() | aws_config()) -> ok_error(proplist()).
stop_instances(InstanceIDs, Config)
  when is_record(Config, aws_config) ->
    stop_instances(InstanceIDs, false, Config);
stop_instances(InstanceIDs, Force) ->
    stop_instances(InstanceIDs, Force, default_config()).

-spec stop_instances([string()], boolean(), aws_config()) -> ok_error(proplist()).
stop_instances(InstanceIDs, Force, Config)
  when is_list(InstanceIDs), is_boolean(Force) ->
    case ec2_query(Config, "StopInstances",
                    [{"Force", atom_to_list(Force)}|erlcloud_aws:param_list(InstanceIDs, "InstanceId")]) of
        {ok, Doc} ->
            {ok, [extract_instance_state_change(Node) || Node <- xmerl_xpath:string("/StopInstancesResponse/instancesSet/item", Doc)]};
        {error, _} = Error ->
            Error
    end.

-spec terminate_instances([string()]) -> ok_error(proplist()).
terminate_instances(InstanceIDs) -> terminate_instances(InstanceIDs, default_config()).

-spec terminate_instances([string()], aws_config()) -> ok_error(proplist()).
terminate_instances(InstanceIDs, Config)
  when is_list(InstanceIDs) ->
    case ec2_query(Config, "TerminateInstances", erlcloud_aws:param_list(InstanceIDs, "InstanceId")) of
        {ok,  Doc} ->
            {ok, [extract_instance_state_change(Node) || Node <- xmerl_xpath:string("/TerminateInstancesResponse/instancesSet/item", Doc)]};
        {error, _} = Error ->
            Error
    end.

extract_instance_state_change(Node) ->
    [
     {instance_id, get_text("instanceId", Node)},
     {current_state,
      {code, list_to_integer(get_text("currentState/code", Node, "0"))},
      {name, get_text("currentState/name", Node)}
     },
     {previous_state,
      {code, list_to_integer(get_text("previousState/code", Node, "0"))},
      {name, get_text("previousState/name", Node)}
     }
    ].

-spec unmonitor_instances([string()]) -> ok_error(proplist()).
unmonitor_instances(InstanceIDs) ->
    unmonitor_instances(InstanceIDs, default_config()).

-spec unmonitor_instances([string()], aws_config()) -> ok_error(proplist()).
unmonitor_instances(InstanceIDs, Config) ->
    case ec2_query(Config, "UnmonitorInstances", erlcloud_aws:param_list(InstanceIDs, "InstanceId")) of
        {ok, Doc} ->
            {ok, [extract_monitor_state(Node) || Node <- xmerl_xpath:string("/UnmonitorInstancesResponse/instancesSet/item", Doc)]};
        {error, _} = Error ->
            Error
    end.

-spec ec2_simple_query(aws_config(), string(), list()) -> ok_error().
ec2_simple_query(Config, Action, Params) ->
    case ec2_query(Config, Action, Params) of
        {ok, _} ->
            ok;
        {error, _} = Error ->
            Error
    end.

-spec ec2_simple_query(aws_config(), string(), list(), string()) -> ok_error().
ec2_simple_query(Config, Action, Params, ApiVersion) ->
    case ec2_query(Config, Action, Params, ApiVersion) of
        {ok, _} ->
            ok;
        {error, _} = Error ->
            Error
    end.

ec2_query(Config, Action, Params) ->
    ec2_query(Config, Action, Params, ?API_VERSION).

ec2_query(Config, Action, Params, ApiVersion) ->
    QParams = [{"Action", Action}, {"Version", ApiVersion}|Params],
    erlcloud_aws:aws_request_xml4(post, Config#aws_config.ec2_protocol,
                                  Config#aws_config.ec2_host,
                                  Config#aws_config.ec2_port,
                                  "/", QParams, "ec2", Config).

default_config() -> erlcloud_aws:default_config().

list_to_ec2_filter(none) ->
    [];
list_to_ec2_filter(List) ->
    list_to_ec2_filter(List, 1, []).

list_to_ec2_filter([], _Count, Res) ->
    Res;
list_to_ec2_filter([{N, V}|T], Count, Res)
    when is_atom(N) ->
    NewName = [case Char of $_ -> $-; _ -> Char end || Char <- atom_to_list(N)],
    list_to_ec2_filter([{NewName, V}|T], Count, Res);
list_to_ec2_filter([{N, V}|T], Count, Res) ->
    Tup = {io_lib:format("Filter.~p.Name", [Count]), N},
    Vals = list_to_ec2_values(V, Count, 1, []),
    list_to_ec2_filter(T, Count + 1, lists:flatten([Tup, Vals, Res])).

list_to_ec2_values([], _Count, _VCount, Res) ->
    Res;
list_to_ec2_values([H|T], Count, VCount, Res) when is_list(H) ->
    Tup = {io_lib:format("Filter.~p.Value.~p", [Count, VCount]), H},
    list_to_ec2_values(T, Count, VCount + 1, [Tup|Res]);
list_to_ec2_values(V, Count, VCount, _Res) ->
    {io_lib:format("Filter.~p.Value.~p", [Count, VCount]), V}.

-spec describe_vpn_gateways() -> ok_error([proplist()]).
describe_vpn_gateways() ->
    describe_vpn_gateways(none, default_config()).

-spec describe_vpn_gateways(filter_list | aws_config()) -> ok_error([proplist()]).
describe_vpn_gateways(Config) when is_record(Config, aws_config) ->
    describe_vpn_gateways(none, Config);
describe_vpn_gateways(Filter) ->
    describe_vpn_gateways(Filter, default_config()).

-spec describe_vpn_gateways(none | filter_list(), aws_config()) -> ok_error([proplist()]).
describe_vpn_gateways(Filter, Config) ->
    describe_vpn_gateways([], Filter, Config).

-spec describe_vpn_gateways(list(), none | filter_list(), aws_config()) -> ok_error([proplist()]).
describe_vpn_gateways(VGWIds, Filter, Config) ->
    Params = erlcloud_aws:param_list(VGWIds, "VpnGatewayId") ++ list_to_ec2_filter(Filter),
    case ec2_query(Config, "DescribeVpnGateways", Params, ?NEW_API_VERSION) of
        {ok, Doc} ->
            ResultPath = "/DescribeVpnGatewaysResponse/vpnGatewaySet/item",
            {ok, [ extract_vgw(Item) || Item <- xmerl_xpath:string(ResultPath, Doc) ]};
        {error, _} = Error ->
            Error
    end.

extract_vgw(Node) ->
    Items = xmerl_xpath:string("attachments/item", Node),
    [ {vpn_gateway_id, get_text("vpnGatewayId", Node)},
      {vpn_gateway_type, get_text("type", Node)},
      {vpn_gateway_state, get_text("state", Node)},
      {vpn_az, get_text("availabilityZone", Node)},
      {vpc_attachment_set, [ extract_vgw_attachments(Item) || Item <- Items]},
      {tag_set, 
       [extract_tag_item(Item)
        || Item <- xmerl_xpath:string("tagSet/item", Node)]}
 ].

extract_vgw_attachments(Node) ->
    [ {vpc_id, get_text("vpcId", Node)},
      {state, get_text("state", Node)} ].

-spec describe_vpn_connections() -> ok_error([proplist()]).
describe_vpn_connections() ->
    describe_vpn_connections(none, default_config()).

-spec describe_vpn_connections(filter_list | aws_config()) -> ok_error([proplist()]).
describe_vpn_connections(Config) when is_record(Config, aws_config) ->
    describe_vpn_connections(none, Config);
describe_vpn_connections(Filter) ->
    describe_vpn_connections(Filter, default_config()).

-spec describe_vpn_connections(none | filter_list(), aws_config()) -> ok_error([proplist()]).
describe_vpn_connections(Filter, Config) ->
    describe_vpn_connections([], Filter, Config).

-spec describe_vpn_connections(list(), none | filter_list(), aws_config()) -> ok_error([proplist()]).
describe_vpn_connections(VpnConnIds, Filter, Config) ->
    Params = erlcloud_aws:param_list(VpnConnIds, "VpnConnectionId") ++ list_to_ec2_filter(Filter),
    case ec2_query(Config, "DescribeVpnConnections", Params, ?NEW_API_VERSION) of
        {ok, Doc} ->
            ResultPath = "/DescribeVpnConnectionsResponse/vpnConnectionSet/item",
            {ok, [ extract_vpn_connection(Item) || Item <- xmerl_xpath:string(ResultPath, Doc) ]};
        {error, _} = Error ->
            Error
    end.

extract_vpn_connection(Node) ->
    [ {vpn_connection_id, get_text("vpnConnectionId", Node)},
      {vpn_connection_state, get_text("state", Node)},
      {customer_gateway_configuration, get_text("customerGatewayConfiguration", Node)},
      {vpn_connection_type, get_text("type", Node)},
      {customer_gateway_id, get_text("customerGatewayId", Node)},
      {vpn_gateway_id, get_text("vpnGatewayId", Node)},
      {tag_set, 
       [extract_tag_item(Item)
        || Item <- xmerl_xpath:string("tagSet/item", Node)]}
 ].

-spec describe_customer_gateways() -> ok_error([proplist()]).
describe_customer_gateways() ->
    describe_customer_gateways(none, default_config()).

-spec describe_customer_gateways(filter_list | aws_config()) -> ok_error([proplist()]).
describe_customer_gateways(Config) when is_record(Config, aws_config) ->
    describe_customer_gateways(none, Config);
describe_customer_gateways(Filter) ->
    describe_customer_gateways(Filter, default_config()).

-spec describe_customer_gateways(none | filter_list(), aws_config()) -> ok_error([proplist()]).
describe_customer_gateways(Filter, Config) ->
    describe_customer_gateways([], Filter, Config).

-spec describe_customer_gateways(list(), none | filter_list(), aws_config()) -> ok_error([proplist()]).
describe_customer_gateways(CGWIds, Filter, Config) ->
    Params = erlcloud_aws:param_list(CGWIds, "CustomerGatewayId") ++ list_to_ec2_filter(Filter),
    case ec2_query(Config, "DescribeCustomerGateways", Params, ?NEW_API_VERSION) of
        {ok, Doc} ->
            ResultPath = "/DescribeCustomerGatewaysResponse/customerGatewaySet/item",
            {ok, [ extract_cgw(Item) || Item <- xmerl_xpath:string(ResultPath, Doc) ]};
        {error, _} = Error ->
            Error
    end.

extract_cgw(Node) ->
    [ {customer_gateway_id, get_text("customerGatewayId", Node)},
      {customer_gateway_state, get_text("state", Node)},
      {customer_gateway_type, get_text("type", Node)},
      {customer_gateway_ip, get_text("ipAddress", Node)},
      {customer_gateway_bgpasn, get_text("bgpAsn", Node)},
      {tag_set, 
       [extract_tag_item(Item)
        || Item <- xmerl_xpath:string("tagSet/item", Node)]}
 ].

%%
%% See API for documentation on this action:
%% http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DescribeAccountAttributes.html
%%
-spec describe_account_attributes() -> ok_error([proplist()]).
describe_account_attributes() ->
    describe_account_attributes([]).

-spec describe_account_attributes(account_attribute_names()) -> ok_error([proplist()]);
                                 (aws_config()) -> ok_error([proplist()]).
describe_account_attributes(AttributeName)
    when is_list(AttributeName) ->
    describe_account_attributes(AttributeName, default_config());
describe_account_attributes(Config)
    when is_record(Config, aws_config) ->
    describe_account_attributes([], Config).

-spec describe_account_attributes(account_attribute_names(), aws_config()) -> ok_error([proplist()]).
describe_account_attributes(AttributeName, Config)
    when is_list(AttributeName), is_record(Config, aws_config) ->
    Params = erlcloud_aws:param_list(AttributeName, "AttributeName"),
    case ec2_query(Config, "DescribeAccountAttributes", Params, ?NEW_API_VERSION) of
        {ok, Doc} ->
            AccountAttributes = extract_results("DescribeAccountAttributesResponse", "accountAttributeSet", fun extract_account_attributes/1, Doc),
            {ok, AccountAttributes};
        {error,  _} = E -> E
    end.

extract_account_attributes(Node) ->
    [
        {attribute_name, get_text("attributeName", Node)},
        {attribute_value_set,
            [extract_attribute_values(Item) || Item <- xmerl_xpath:string("attributeValueSet/item", Node)]}
    ].

extract_attribute_values(Node) ->
    [
        {attribute_value, get_text("attributeValue", Node)}
    ].


%%
%% See API for documentation on this action:
%% http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DescribeNatGateways.html
%%
-spec describe_nat_gateways() -> ok_error([proplist()]).
describe_nat_gateways() ->
    describe_nat_gateways([]).

-spec describe_nat_gateways(nat_gateway_ids()) -> ok_error([proplist()]);
                           (aws_config()) -> ok_error([proplist()]).
describe_nat_gateways(NatGatewayIds)
    when is_list(NatGatewayIds) ->
    describe_nat_gateways(NatGatewayIds, []);
describe_nat_gateways(Config)
    when is_record(Config, aws_config) ->
    describe_nat_gateways([], Config).

-spec describe_nat_gateways(nat_gateway_ids(), filter_list()) -> ok_error([proplist()]);
                           (nat_gateway_ids(), aws_config()) -> ok_error([proplist()]).
describe_nat_gateways(NatGatewayIds, Filter)
    when is_list(NatGatewayIds), is_list(Filter) ->
    describe_nat_gateways(NatGatewayIds, Filter, default_config());
describe_nat_gateways(NatGatewayIds, Config)
    when is_list(NatGatewayIds), is_record(Config, aws_config) ->
    describe_nat_gateways(NatGatewayIds, [], Config).

-spec describe_nat_gateways(nat_gateway_ids(), filter_list(), aws_config()) -> ok_error([proplist()]).
describe_nat_gateways(NatGatewayIds, Filter, Config)
    when is_list(NatGatewayIds), is_list(Filter), is_record(Config, aws_config) ->
    Params = erlcloud_aws:param_list(NatGatewayIds, "NatGatewayId") ++ list_to_ec2_filter(Filter),
    case ec2_query(Config, "DescribeNatGateways", Params, ?NEW_API_VERSION) of
        {ok, Doc} ->
            NatGateways = extract_results("DescribeNatGatewaysResponse", "natGatewaySet", fun extract_nat_gateway/1, Doc),
            {ok, NatGateways};
        {error,  _} = E -> E
    end.

-spec describe_nat_gateways(nat_gateway_ids(), filter_list(), ec2_max_result(), ec2_token()) -> ok_error([proplist()]);
                           (filter_list(), ec2_max_result(), ec2_token(), aws_config()) -> ok_error([proplist()]).
describe_nat_gateways(NatGatewayIds, Filter, MaxResults, NextToken)
    when is_list(NatGatewayIds), is_list(Filter), is_integer(MaxResults),
         is_list(NextToken) orelse NextToken =:= undefined ->
    describe_nat_gateways(NatGatewayIds, Filter, MaxResults, NextToken, default_config());
describe_nat_gateways(Filter, MaxResults, NextToken, Config)
    when is_list(Filter) orelse Filter =:= none, is_integer(MaxResults),
         is_list(NextToken) orelse NextToken =:= undefined, is_record(Config, aws_config) ->
    describe_nat_gateways([], Filter, MaxResults, NextToken, Config).

-spec describe_nat_gateways(nat_gateway_ids(), filter_list(), ec2_max_result(), ec2_token(), aws_config())
        -> ok_error([proplist()]).
describe_nat_gateways(NatGatewayIds, Filter, MaxResults, NextToken, Config)
    when is_list(NatGatewayIds), is_list(Filter) orelse Filter =:= none,
         is_integer(MaxResults) andalso MaxResults >= ?NAT_GATEWAYS_MR_MIN andalso MaxResults =< ?NAT_GATEWAYS_MR_MAX,
         is_list(NextToken) orelse NextToken =:= undefined,
         is_record(Config, aws_config) ->
    Params = erlcloud_aws:param_list(NatGatewayIds, "NatGatewayId") ++ list_to_ec2_filter(Filter) ++
             [{"MaxResults", MaxResults}, {"NextToken", NextToken}],
    case ec2_query(Config, "DescribeNatGateways", Params, ?NEW_API_VERSION) of
        {ok, Doc} ->
            NatGateways = extract_results("DescribeNatGatewaysResponse", "natGatewaySet", fun extract_nat_gateway/1, Doc),
            NewNextToken = extract_next_token("DescribeNatGatewaysResponse", Doc),
            {ok, NatGateways, NewNextToken};
        {error,  _} = E -> E
    end.
    
extract_nat_gateway(Node) ->
    [
        {create_time, get_text("createTime", Node)},
        {delete_time, get_text("deleteTime", Node)},
        {failure_code, get_text("failureCode", Node)},
        {failure_message, get_text("failureMessage", Node)},
        {nat_gateway_address_set,
            [extract_nat_gateway_address(Item) || Item <- xmerl_xpath:string("natGatewayAddressSet/item", Node)]},
        {nat_gateway_id, get_text("natGatewayId", Node)},
        {state, get_text("state", Node)},
        {subnet_id, get_text("subnetId", Node)},
        {vpc_id, get_text("vpcId", Node)}
    ].
    
extract_nat_gateway_address(Node) ->
    [
        {allocation_id, get_text("allocationId", Node)},
        {network_interface_id, get_text("networkInterfaceId", Node)},
        {private_ip, get_text("privateIp", Node)},
        {public_ip, get_text("publicIp", Node)}
    ].

%%
%% See API for documentation on this action:
%% http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DescribeVpcPeeringConnections.html
%%
-spec describe_vpc_peering_connections() -> ok_error([proplist()]).
describe_vpc_peering_connections() ->
    describe_vpc_peering_connections([]).

-spec describe_vpc_peering_connections(vpc_peering_connection_ids()) -> ok_error([proplist()]);
                                      (aws_config()) -> ok_error([proplist()]).
describe_vpc_peering_connections(VpcPeeringConnectionIds)
    when is_list(VpcPeeringConnectionIds) ->
    describe_vpc_peering_connections(VpcPeeringConnectionIds, []);
describe_vpc_peering_connections(Config)
    when is_record(Config, aws_config) ->
    describe_vpc_peering_connections([], Config).

-spec describe_vpc_peering_connections(vpc_peering_connection_ids(), filter_list()) -> ok_error([proplist()]);
                                      (vpc_peering_connection_ids(), aws_config()) -> ok_error([proplist()]).
describe_vpc_peering_connections(VpcPeeringConnectionIds, Filter)
    when is_list(VpcPeeringConnectionIds), is_list(Filter) orelse Filter =:= none ->
    describe_vpc_peering_connections(VpcPeeringConnectionIds, Filter, default_config());
describe_vpc_peering_connections(VpcPeeringConnectionIds, Config)
    when is_list(VpcPeeringConnectionIds), is_record(Config, aws_config) ->
    describe_vpc_peering_connections(VpcPeeringConnectionIds, [], Config).


-spec describe_vpc_peering_connections(vpc_peering_connection_ids(), filter_list(), aws_config()) ->
            ok_error([proplist()]).
describe_vpc_peering_connections(VpcPeeringConnectionIds, Filter, Config)
    when is_list(VpcPeeringConnectionIds),
         is_list(Filter) orelse Filter =:= none,
         is_record(Config, aws_config) ->
    Params = erlcloud_aws:param_list(VpcPeeringConnectionIds, "VpcPeeringConnectionId") ++ list_to_ec2_filter(Filter),
    case ec2_query(Config, "DescribeVpcPeeringConnections", Params, ?NEW_API_VERSION) of
        {ok, Doc} ->
            AccountAttributes = extract_results("DescribeVpcPeeringConnectionsResponse", "vpcPeeringConnectionSet", fun extract_vpc_peering_connection/1, Doc),
            {ok, AccountAttributes};
        {error,  _} = E -> E
    end.
    
extract_vpc_peering_connection(Node) ->
    [
        {expiration_time, get_text("expirationTime", Node)},
        {tag_set, [extract_tag_item(Item) || Item <- xmerl_xpath:string("tagSet/item", Node)]},
        {vpc_peering_connection_id, get_text("vpcPeeringConnectionId", Node)},
        {requester_vpc_info, [extract_vpc_peering_connection_info(Item) || Item <- xmerl_xpath:string("requesterVpcInfo", Node)]}
    ].

extract_vpc_peering_connection_info(Node) ->
    [
        {cidr_block, get_text("cidrBlock", Node)},
        {owner_id, get_text("ownerId", Node)},
        {vpc_id, get_text("vpcId", Node)}
    ].

-spec extract_results(string(), string(), function(), any()) -> list().
extract_results(ResponseName, SetName, ExtractFunction, Doc)
    when is_list(ResponseName), is_list(SetName), is_function(ExtractFunction), is_record(Doc, xmlElement)->
    Results = xmerl_xpath:string("/" ++ ResponseName ++ "/" ++ SetName ++ "/item", Doc),
    ExtractedResults = [apply(ExtractFunction, [Item]) || Item <- Results],
    ExtractedResults.

-spec extract_next_token(string(), tuple()) -> ec2_token().
extract_next_token(ResponseName, Doc)
    when is_list(ResponseName), is_record(Doc, xmlElement) ->
    erlcloud_xml:get_text("/" ++ ResponseName ++ "/nextToken", Doc, undefined).

extract_unsuccesful_item(Node) ->
    [ {resource_id, get_text("resourceId", Node)},
      {error, [ {code, get_text("error/code", Node)},
                {message, get_text("error/message", Node)}]}
    ].

%%%------------------------------------------------------------------------------
%% @doc
%% Launch Templates API - DescribeLaunchTemplates
%% [https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DescribeLaunchTemplates.html]
%%
%% ===Example===
%%
%% Describe launch templates with matching launch template IDs.
%%
%% `
%% {ok, Results} = erlcloud_ec2:describe_launch_templates(["lt-0a20c965061f64abc", "lt-32415965061f007aa"])
%% '
%% @end
%%%------------------------------------------------------------------------------
-spec describe_launch_templates() -> ok_error([proplist()]).
describe_launch_templates() ->
    describe_launch_templates([]).

-spec describe_launch_templates(launch_template_ids()) -> ok_error([proplist()]);
                               (aws_config()) -> ok_error([proplist()]).
describe_launch_templates(LaunchTemplateIds)
    when is_list(LaunchTemplateIds) ->
    describe_launch_templates(LaunchTemplateIds, []);
describe_launch_templates(Config)
    when is_record(Config, aws_config) ->
    describe_launch_templates([], Config).

-spec describe_launch_templates(launch_template_ids(), filter_list()) -> ok_error([proplist()]);
                               (launch_template_ids(), aws_config()) -> ok_error([proplist()]).
describe_launch_templates(LaunchTemplateIds, Filter)
    when is_list(LaunchTemplateIds), is_list(Filter) ->
    describe_launch_templates(LaunchTemplateIds, Filter, default_config());
describe_launch_templates(LaunchTemplateIds, Config)
    when is_list(LaunchTemplateIds), is_record(Config, aws_config) ->
    describe_launch_templates(LaunchTemplateIds, [], Config).

-spec describe_launch_templates(launch_template_ids(), filter_list(), aws_config()) -> ok_error([proplist()]).
describe_launch_templates(LaunchTemplateIds, Filter, Config)
    when is_list(LaunchTemplateIds), is_list(Filter), is_record(Config, aws_config) ->
    Params = erlcloud_aws:param_list(LaunchTemplateIds, "LaunchTemplateId") ++ list_to_ec2_filter(Filter),
    case ec2_query(Config, "DescribeLaunchTemplates", Params, ?NEW_API_VERSION) of
        {ok, Doc} ->
            LaunchTemplates = extract_results("DescribeLaunchTemplatesResponse", "launchTemplates", fun extract_launch_template/1, Doc),
            {ok, LaunchTemplates};
        {error, _} = E -> E
    end.

-spec describe_launch_templates(launch_template_ids(), filter_list(), ec2_max_result(), ec2_token()) -> ok_error([proplist()]);
                               (filter_list(), ec2_max_result(), ec2_token(), aws_config()) -> ok_error([proplist()]).
describe_launch_templates(LaunchTemplateIds, Filter, MaxResults, NextToken)
    when is_list(LaunchTemplateIds), is_list(Filter) orelse Filter =:= none, is_integer(MaxResults),
         is_list(NextToken) orelse NextToken =:= undefined ->
    describe_launch_templates(LaunchTemplateIds, Filter, MaxResults, NextToken, default_config());
describe_launch_templates(Filter, MaxResults, NextToken, Config)
    when is_list(Filter) orelse Filter =:= none, is_integer(MaxResults),
         is_list(NextToken) orelse NextToken =:= undefined, is_record(Config, aws_config) ->
    describe_launch_templates([], Filter, MaxResults, NextToken, Config).

-spec describe_launch_templates(launch_template_ids(), filter_list(), ec2_max_result(), ec2_token(), aws_config()) -> ok_error([proplist()], ec2_token()).
describe_launch_templates(LaunchTemplateIds, Filter, MaxResults, NextToken, Config)
    when is_list(LaunchTemplateIds), is_list(Filter) orelse Filter =:= none,
         is_integer(MaxResults) andalso MaxResults >= ?LAUNCH_TEMPLATES_MR_MIN andalso MaxResults =< ?LAUNCH_TEMPLATES_MR_MAX,
         is_list(NextToken) orelse NextToken =:= undefined,
         is_record(Config, aws_config) ->
    Params = erlcloud_aws:param_list(LaunchTemplateIds, "LaunchTemplateId") ++ list_to_ec2_filter(Filter) ++
             [{"MaxResults", MaxResults}, {"NextToken", NextToken}],
    case ec2_query(Config, "DescribeLaunchTemplates", Params, ?NEW_API_VERSION) of
        {ok, Doc} ->
            LaunchTemplates = extract_results("DescribeLaunchTemplatesResponse", "launchTemplates", fun extract_launch_template/1, Doc),
            NewNextToken = extract_next_token("DescribeLaunchTemplatesResponse", Doc),
            {ok, LaunchTemplates, NewNextToken};
        {error, _} = E -> E
    end.

-spec describe_launch_templates_all() -> ok_error([proplist()]).
describe_launch_templates_all() ->
    describe_launch_templates_all(default_config()).

-spec describe_launch_templates_all(aws_config() | launch_template_ids()) -> ok_error([proplist()]).
describe_launch_templates_all(Ids)
    when is_list(Ids) ->
    describe_launch_templates_all(Ids, none, default_config(), undefined, []);
describe_launch_templates_all(Config)
    when is_record(Config, aws_config) ->
    describe_launch_templates_all([], none, Config, undefined, []).

-spec describe_launch_templates_all(launch_template_ids(), filter_list()) -> ok_error([proplist()]).
describe_launch_templates_all(LaunchTemplateIds, FilterOpts)
    when is_list(LaunchTemplateIds), is_list(FilterOpts) orelse FilterOpts =:= none ->
    describe_launch_templates_all(LaunchTemplateIds, FilterOpts, default_config()).

-spec describe_launch_templates_all(launch_template_ids(), filter_list(), aws_config()) -> ok_error([proplist()]).
describe_launch_templates_all(LaunchTemplateIds, FilterOpts, Config)
    when is_list(LaunchTemplateIds), is_list(FilterOpts) orelse FilterOpts =:= none,
         is_record(Config, aws_config) ->
    describe_launch_templates_all(LaunchTemplateIds, FilterOpts, Config, undefined, []).

describe_launch_templates_all(LaunchTemplateIds, FilterOpts, Config, Token, Acc)
    when is_list(LaunchTemplateIds), is_list(FilterOpts) orelse FilterOpts =:= none,
         is_list(Token) orelse Token =:= undefined, is_record(Config, aws_config) ->
    case describe_launch_templates(LaunchTemplateIds, FilterOpts, ?LAUNCH_TEMPLATES_MR_MAX, Token, Config) of
        {ok, Results, undefined} -> {ok, Results ++ Acc};
        {ok, Results, Next} -> describe_launch_templates_all(LaunchTemplateIds, FilterOpts, Config, Next, Results ++ Acc);
        {error, _} = Error -> Error
    end.

launch_template_version_opts() ->
    [
        {launch_template_version, "LaunchTemplateVersion"},
        {max_version, "MaxVersion"},
        {min_version, "MinVersion"}
    ].

set_launch_template_optional_selector({_, none}, Acc) -> Acc;
set_launch_template_optional_selector({_, []}, Acc) -> Acc;
set_launch_template_optional_selector({Key, Value}, Acc) ->
    [{Key, Value} | Acc].

set_launch_template_selectors(LaunchTemplateId, LaunchTemplateName) ->
    ArgList = [{"LaunchTemplateId", LaunchTemplateId}, {"LaunchTemplateName", LaunchTemplateName}],
    lists:foldl(fun set_launch_template_optional_selector/2, [], ArgList).

set_launch_template_version_opts(Opts) ->
    OptTable = launch_template_version_opts(),
    Sorted = lists:ukeysort(1, Opts),
    FnFolder = fun({K, Val}, Acc) ->
        case lists:keyfind(K, 1, OptTable) of
            {launch_template_version, ApiArg} -> erlcloud_aws:param_list(Val, ApiArg) ++ Acc;
            {_, ApiArg} -> [{ApiArg, Val} | Acc];
            false -> Acc
        end
    end,
    lists:foldl(FnFolder, [], Sorted).

%%%------------------------------------------------------------------------------
%% @doc
%% Launch Templates API - DescribeLaunchTemplateVersions
%% [https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DescribeLaunchTemplateVersions.html]
%%
%% ===Example===
%%
%% Describe launch template versions for the template described by ID.
%%
%% `
%% {ok, Results} = erlcloud_ec2:describe_launch_template_versions("lt-0a20c965061f64abc")
%% '
%%
%% Describe launch template versions for the template with the given name.
%%
%% `
%% {ok, Results} = erlcloud_ec2:describe_launch_template_versions(none, "MyTemplateName")
%% '
%%
%% Describe most recent launch template version for the template with the given ID.
%%
%% `
%% {ok, Results} = erlcloud_ec2:describe_launch_template_versions("lt-0a20c965061f64abc", none, [{launch_template_version, ["$Latest"]}])
%% '
%%
%% @end
%%%------------------------------------------------------------------------------
-spec describe_launch_template_versions(string()) -> ok_error([proplist()]).
describe_launch_template_versions(LaunchTemplateId) ->
    describe_launch_template_versions(LaunchTemplateId, none, []).

-spec describe_launch_template_versions(string() | none, string() | none, list()) -> ok_error([proplist()]);
                                       (string() | none, string() | none, aws_config()) -> ok_error([proplist()]).
describe_launch_template_versions(LaunchTemplateId, LaunchTemplateName, Opts)
    when is_list(LaunchTemplateId) orelse LaunchTemplateId =:= none,
         is_list(LaunchTemplateName) orelse LaunchTemplateName =:= none,
         is_list(Opts) ->
    describe_launch_template_versions(LaunchTemplateId, LaunchTemplateName, Opts, default_config());
describe_launch_template_versions(LaunchTemplateId, LaunchTemplateName, Config)
    when is_list(LaunchTemplateId) orelse LaunchTemplateId =:= none,
         is_list(LaunchTemplateName) orelse LaunchTemplateName =:= none,
         is_record(Config, aws_config) ->
    describe_launch_template_versions(LaunchTemplateId, LaunchTemplateName, [], Config).

-spec describe_launch_template_versions(string() | none, string() | none, list(), filter_list()) -> ok_error([proplist()]);
                                       (string() | none, string() | none, list(), aws_config()) -> ok_error([proplist()]).
describe_launch_template_versions(LaunchTemplateId, LaunchTemplateName, Opts, Filter)
    when is_list(LaunchTemplateId) orelse LaunchTemplateId =:= none,
         is_list(LaunchTemplateName) orelse LaunchTemplateName =:= none,
         is_list(Opts), is_list(Filter) ->
    describe_launch_template_versions(LaunchTemplateId, LaunchTemplateName, Opts, Filter, default_config());
describe_launch_template_versions(LaunchTemplateId, LaunchTemplateName, Opts, Config)
    when is_list(LaunchTemplateId) orelse LaunchTemplateId =:= none,
         is_list(LaunchTemplateName) orelse LaunchTemplateName =:= none,
         is_list(Opts), is_record(Config, aws_config) ->
    describe_launch_template_versions(LaunchTemplateId, LaunchTemplateName, Opts, [], Config).

-spec describe_launch_template_versions(string() | none, string() | none, list(), filter_list(), aws_config()) -> ok_error([proplist()]).
describe_launch_template_versions(LaunchTemplateId, LaunchTemplateName, Opts, Filter, Config)
    when is_list(LaunchTemplateId) orelse LaunchTemplateId =:= none,
         is_list(LaunchTemplateName) orelse LaunchTemplateName =:= none,
         is_list(Opts), is_list(Filter), is_record(Config, aws_config) ->
    Params = set_launch_template_selectors(LaunchTemplateId, LaunchTemplateName) ++
             set_launch_template_version_opts(Opts) ++ list_to_ec2_filter(Filter),
    case ec2_query(Config, "DescribeLaunchTemplateVersions", Params, ?NEW_API_VERSION) of
        {ok, Doc} ->
            LaunchTemplateVersions = extract_results("DescribeLaunchTemplateVersionsResponse", "launchTemplateVersionSet", fun extract_launch_template_version/1, Doc),
            {ok, LaunchTemplateVersions};
        {error, _} = E -> E
    end.

-spec describe_launch_template_versions(string() | none, string() | none, list(), filter_list(), ec2_max_result(), ec2_token()) -> ok_error([proplist()]).
describe_launch_template_versions(LaunchTemplateId, LaunchTemplateName, Opts, Filter, MaxResults, NextToken)
    when is_list(LaunchTemplateId) orelse LaunchTemplateId =:= none,
         is_list(LaunchTemplateName) orelse LaunchTemplateName =:= none, is_list(Opts), is_list(Filter) orelse Filter =:= none,
         is_integer(MaxResults) andalso MaxResults >= ?LAUNCH_TEMPLATES_MR_MIN andalso MaxResults =< ?LAUNCH_TEMPLATES_MR_MAX,
         is_list(NextToken) orelse NextToken =:= undefined ->
    describe_launch_template_versions(LaunchTemplateId, LaunchTemplateName, Opts, Filter, MaxResults, NextToken, default_config()).

-spec describe_launch_template_versions(string() | none, string() | none, list(), filter_list(), ec2_max_result(), ec2_token(), aws_config())
    -> ok_error([proplist()], ec2_token()).
describe_launch_template_versions(LaunchTemplateId, LaunchTemplateName, Opts, Filter, MaxResults, NextToken, Config)
    when is_list(LaunchTemplateId) orelse LaunchTemplateId =:= none,
         is_list(LaunchTemplateName) orelse LaunchTemplateName =:= none, is_list(Opts), is_list(Filter) orelse Filter =:= none,
         is_list(NextToken) orelse NextToken =:= undefined,
         is_integer(MaxResults) andalso MaxResults >= ?LAUNCH_TEMPLATES_MR_MIN andalso MaxResults =< ?LAUNCH_TEMPLATES_MR_MAX,
         is_record(Config, aws_config) ->
    Params = set_launch_template_version_opts(Opts) ++ list_to_ec2_filter(Filter) ++
             set_launch_template_selectors(LaunchTemplateId, LaunchTemplateName) ++
             [{"NextToken", NextToken}, {"MaxResults", MaxResults}],
    case ec2_query(Config, "DescribeLaunchTemplateVersions", Params, ?NEW_API_VERSION) of
        {ok, Doc} ->
            LaunchTemplateVersions = extract_results("DescribeLaunchTemplateVersionsResponse", "launchTemplateVersionSet", fun extract_launch_template_version/1, Doc),
            NewNextToken = extract_next_token("DescribeLaunchTemplateVersionsResponse", Doc),
            {ok, LaunchTemplateVersions, NewNextToken};
        {error, _} = E -> E
    end.

-spec describe_launch_template_versions_all(string() | none, string() | none) -> ok_error([proplist()]).
describe_launch_template_versions_all(LaunchTemplateId, LaunchTemplateName)
    when is_list(LaunchTemplateId) orelse LaunchTemplateId =:= none,
         is_list(LaunchTemplateName) orelse LaunchTemplateName =:= none ->
    describe_launch_template_versions_all(LaunchTemplateId, LaunchTemplateName, default_config()).

-spec describe_launch_template_versions_all(string() | none, string() | none, aws_config()) -> ok_error([proplist()]).
describe_launch_template_versions_all(LaunchTemplateId, LaunchTemplateName, Config)
    when is_list(LaunchTemplateId) orelse LaunchTemplateId =:= none,
         is_list(LaunchTemplateName) orelse LaunchTemplateName =:= none,
         is_record(Config, aws_config) ->
    describe_launch_template_versions_all(LaunchTemplateId, LaunchTemplateName, Config, undefined, []).

describe_launch_template_versions_all(LaunchTemplateId, LaunchTemplateName, Config, Token, Acc) ->
    case describe_launch_template_versions(LaunchTemplateId, LaunchTemplateName, [], none, ?LAUNCH_TEMPLATES_MR_MAX, Token, Config) of
        {ok, Results, undefined} -> {ok, Results ++ Acc};
        {ok, Results, Next} ->
            describe_launch_template_versions_all(LaunchTemplateId, LaunchTemplateName, Config, Next, Results ++ Acc);
        {error, _} = Error -> Error
    end.

extract_launch_template(Node) ->
    [
        {created_by, get_text("createdBy", Node)},
        {create_time, erlcloud_xml:get_time("createTime", Node)},
        {default_version_number, get_integer("defaultVersionNumber", Node)},
        {launch_template_id, get_text("launchTemplateId", Node)},
        {launch_template_name, get_text("launchTemplateName", Node)},
        {tag_set, [extract_tag_item(Item) || Item <- xmerl_xpath:string("tagSet/item", Node, [])]}
    ].

extract_launch_template_version(Node) ->
    [
        {created_by, get_text("createdBy", Node)},
        {create_time, erlcloud_xml:get_time("createTime", Node)},
        {default_version, get_bool("defaultVersion", Node)},
        {launch_template_data, transform_item_list(Node, "launchTemplateData", fun extract_launch_template_data/1)},
        {launch_template_id, get_text("launchTemplateId", Node)},
        {launch_template_name, get_text("launchTemplateName", Node)},
        {version_description, get_text("versionDescription", Node)},
        {version_number, get_integer("versionNumber", Node)}
    ].

extract_capacity_reservation_target(Node) ->
    [
        {capacity_reservation_id, get_text("capacityReservationId", Node)},
        {capacity_reservation_resource_group_arn, get_text("capacityReservationResourceGroupArn", Node)}
    ].

extract_capacity_reservation_spec(Node) ->
    [
        {capacity_reservation_preference, get_text("capacityReservationPreference", Node)},
        {capacity_reservation_target, transform_item_list(Node, "capacityReservationTarget", fun extract_capacity_reservation_target/1)}
    ].

extract_elastic_gpu_specification(Node) ->
    [{type, get_text("type", Node)}].

extract_elastic_inference_accelerator(Node) ->
    [
        {count, get_integer("count", Node)},
        {type, get_text("type", Node)}
    ].

extract_spot_market_options(Node) ->
    [
        {block_duration_minutes, get_integer("blockDurationMinutes", Node)},
        {instance_interruption_behaviour, get_text("instanceInterruptionBehavior", Node)},
        {max_price, get_text("maxPrice", Node)},
        {spot_instance_type, get_text("spotInstanceType", Node)},
        {valid_until, erlcloud_xml:get_time("validUntil", Node)}
    ].

extract_instance_market_options(Node) ->
    [
        {market_type, get_text("marketType", Node)},
        {spot_options, transform_item_list(Node, "spotOptions", fun extract_spot_market_options/1)}
    ].

extract_license_configuration(Node) ->
    [{license_configuration_arn, get_text("licenseConfigurationArn", Node)}].

extract_maintenance_options(Node) ->
    [{auto_recovery, get_text("autoRecovery", Node)}].

extract_metadata_options(Node) ->
    [
        {http_endpoint, get_text("httpEndpoint", Node)},
        {http_protocol_ipv6, get_text("httpProtocolIpv6", Node)},
        {http_put_response_hop_limit, get_integer("httpPutResponseHopLimit", Node)},
        {http_tokens, get_text("httpTokens", Node)},
        {instance_metadata_tags, get_text("instanceMetadataTags", Node)},
        {state, get_text("state", Node)}
    ].

extract_launch_template_placement(Node) ->
    [
        {affinity, get_text("affinity", Node)},
        {availability_zone, get_text("availabilityZone", Node)},
        {group_name, get_text("groupName", Node)},
        {host_id, get_text("hostId", Node)},
        {host_resource_group_arn, get_text("hostResourceGroupArn", Node)},
        {partition_number, get_integer("partitionNumber", Node)},
        {spread_domain, get_text("spreadDomain", Node)},
        {tenancy, get_text("tenancy", Node)}
    ].

extract_private_dns_name_options(Node) ->
    [
        {enable_resource_name_dns_aaaa_record, get_bool("enableResourceNameDnsAAAARecord", Node)},
        {enable_resource_name_dns_a_record, get_bool("enableResourceNameDnsARecord", Node)},
        {hostname_type, get_text("hostnameType", Node)}
    ].

extract_tag_specification(Node) ->
    [
        {resource_type, get_text("resourceType", Node)},
        {tag_set, transform_item_list(Node, "tagSet/item", fun extract_tag_item/1)}
    ].

extract_cpu_options(Node) ->
    [
        {core_count, get_integer("coreCount", Node)},
        {threads_per_core, get_integer("threadsPerCore", Node)}
    ].

extract_iam_instance_profile(Node) ->
    [
        {arn, get_text("arn", Node)},
        {id, get_text("id", Node)}
    ].

extract_credit_specification(Node) ->
    [
        {cpu_credits, get_text("cpuCredits", Node)}
    ].

extract_range(Node, FnConvert) ->
        [
        {max, FnConvert("max", Node)},
        {min, FnConvert("min", Node)}        
    ].

extract_int_range(Node) -> extract_range(Node, fun erlcloud_xml:get_integer/2).
extract_float_range(Node) -> extract_range(Node, fun erlcloud_xml:get_float/2).

extract_instance_requirements(Node) ->
    [
        {accelerator_count, transform_item_list(Node, "acceleratorCount", fun extract_int_range/1)},
        {accelerator_manufacturer_set, transform_item_list(Node, "acceleratorManufacturerSet/item", fun erlcloud_xml:get_text/1)},
        {accelerator_name_set, transform_item_list(Node, "acceleratorNameSet/item", fun erlcloud_xml:get_text/1)},
        {accelerator_total_memory_mib, transform_item_list(Node, "acceleratorTotalMemoryMiB", fun extract_int_range/1)},
        {accelerator_type_set, transform_item_list(Node, "acceleratorTypeSet/item", fun erlcloud_xml:get_text/1)},
        {bare_metal, get_text("bareMetal", Node)},
        {baseline_ebs_bandwidth_mbps, transform_item_list(Node, "baselineEbsBandwidthMbps", fun extract_int_range/1)},
        {burstable_performance, get_text("burstablePerformance", Node)},
        {cpu_manufacturer_set, transform_item_list(Node, "cpuManufacturerSet/item", fun erlcloud_xml:get_text/1)},
        {excluded_instance_type_set, transform_item_list(Node, "excludedInstanceTypeSet/item", fun erlcloud_xml:get_text/1)},
        {instance_generation_set, transform_item_list(Node, "instanceGenerationSet/item", fun erlcloud_xml:get_text/1)},
        {local_storage, get_text("localStorage", Node)},
        {local_storage_type_set, transform_item_list(Node, "localStorageTypeSet/item", fun erlcloud_xml:get_text/1)},
        {memory_gib_per_vcpu, transform_item_list(Node, "memoryGiBPerVCpu", fun extract_float_range/1)},
        {memory_mib, transform_item_list(Node, "memoryMiB", fun extract_int_range/1)},
        {network_interface_count, transform_item_list(Node, "networkInterfaceCount", fun extract_int_range/1)},
        {on_demand_max_price_percentage_over_lowest_price, get_integer("onDemandMaxPricePercentageOverLowestPrice", Node)},
        {require_hibernate_support, get_bool("requireHibernateSupport", Node)},
        {spot_max_price_percentage_over_lowest_price, get_integer("spotMaxPricePercentageOverLowestPrice", Node)},
        {total_local_storage_gb, transform_item_list(Node, "totalLocalStorageGB", fun extract_float_range/1)},
        {vcpu_count, transform_item_list(Node, "vCpuCount", fun extract_int_range/1)}
    ].

extract_network_interface_specification(Node) ->
    [
        {associate_carrier_ip_address, get_bool("associateCarrierIpAddress", Node)},
        {associate_public_ip_address, get_bool("associatePublicIpAddress", Node)},
        {delete_on_termination, get_bool("deleteOnTermination", Node)},
        {description, get_text("description", Node)},
        {device_index, get_integer("deviceIndex", Node)},
        {group_set, transform_item_list(Node, "groupSet", fun(N) -> {group_id, get_text("groupId", N)} end)},
        {interface_type, get_text("interfaceType", Node)},
        {ipv4_prefix_count, get_integer("ipv4PrefixCount", Node)},
        {ipv4_prefix_set, transform_item_list(Node, "ipv4PrefixSet/item", fun(N) -> {ipv4_prefix, get_text("ipv4Prefix", N)} end)},
        {ipv6_address_count, get_integer("ipv6AddressCount", Node)},
        {ipv6_addresses_set, transform_item_list(Node, "ipv6AddressesSet/item", fun(N) -> {ipv6_address, get_text("ipv6Address", N)} end)},
        {ipv6_prefix_count, get_integer("ipv6PrefixCount", Node)},
        {ipv6_prefix_set, transform_item_list(Node, "ipv6AddressesSet/item", fun(N) -> {ipv6_prefix, get_text("ipv6Prefix", N)} end)},
        {network_card_index, get_integer("networkCardIndex", Node)},
        {network_interface_id, get_text("networkInterfaceId", Node)},
        {private_ip_address, get_text("privateIpAddress", Node)},
        {private_ip_addresses_set, transform_item_list(Node, "privateIpAddressesSet/item", fun extract_private_ip_address/1)},
        {secondary_private_ip_address_count, get_integer("secondaryPrivateIpAddressCount", Node)},
        {subnet_id, get_text("subnetId", Node)}
    ].

transform_item_list(ParentNode, Tag, FncTransform) ->
    [FncTransform(Item) || Item <- xmerl_xpath:string(Tag, ParentNode)].

extract_launch_template_data(Node) ->
    [
        {block_device_mapping_set, transform_item_list(Node, "blockDeviceMappingSet/item", fun extract_block_device_mapping/1)},
        {capacity_reservation_specification, transform_item_list(Node, "capacityReservationSpecification", fun extract_capacity_reservation_spec/1)},
        {cpu_options, transform_item_list(Node, "cpuOptions", fun extract_cpu_options/1)},
        {credit_specification, transform_item_list(Node, "creditSpecification", fun extract_credit_specification/1)},
        {disable_api_stop, get_bool("disableApiStop", Node)},
        {disable_api_termination, get_bool("disableApiTermination", Node)},
        {ebs_optimized, get_bool("ebsOptimized", Node)},
        {elastic_gpu_specification_set, transform_item_list(Node, "elasticGpuSpecificationSet/item", fun extract_elastic_gpu_specification/1)},
        {elastic_inference_accelerator_set, transform_item_list(Node, "elasticInferenceAcceleratorSet/item", fun extract_elastic_inference_accelerator/1)},
        {enclave_options, [{enabled, get_bool("enclaveOptions/enabled", Node)}]},
        {hibernation_options, [{configured, get_bool("hibernationOptions/configured", Node)}]},
        {iam_instance_profile, transform_item_list(Node, "iamInstanceProfile", fun extract_iam_instance_profile/1)},
        {image_id, get_text("imageId", Node)},
        {instance_initiated_shutdown_behavior, get_text("instanceInitiatedShutdownBehavior", Node)},
        {instance_market_options, transform_item_list(Node, "instanceMarketOptions", fun extract_instance_market_options/1)},
        {instance_requirements, transform_item_list(Node, "instanceRequirements", fun extract_instance_requirements/1)},
        {instance_type, get_text("instanceType", Node)},
        {kernel_id, get_text("kernelId", Node)},
        {key_name, get_text("keyName", Node)},
        {license_set, transform_item_list(Node, "licenseSet/item", fun extract_license_configuration/1)},
        {maintenance_options, transform_item_list(Node, "maintenanceOptions", fun extract_maintenance_options/1)},
        {metadata_options, transform_item_list(Node, "metadataOptions", fun extract_metadata_options/1)},
        {monitoring, [{enabled, get_bool("monitoring/enabled", Node)}]},
        {network_interface_set, transform_item_list(Node, "networkInterfaceSet/item", fun extract_network_interface_specification/1)},
        {placement, transform_item_list(Node, "placement", fun extract_launch_template_placement/1)},
        {private_dns_name_options, transform_item_list(Node, "privateDnsNameOptions", fun extract_private_dns_name_options/1)},
        {ram_disk_id, get_text("ramDiskId", Node)},
        {security_group_id_set, [get_text(Item) || Item <- xmerl_xpath:string("securityGroupIdSet/item", Node)]},
        {security_group_set, [get_text(Item) || Item <- xmerl_xpath:string("securityGroupSet/item", Node)]},
        {tag_specification_set, transform_item_list(Node, "tagSpecificationSet/item", fun extract_tag_specification/1)},
        {user_data, get_text("userData", Node)}
    ].
