-module(erlcloud_eks_container_credentials).

-include("erlcloud.hrl").
-include("erlcloud_aws.hrl").

-export([get_container_credentials/1]).

%%%---------------------------------------------------------------------------
-spec get_container_credentials( Config :: aws_config() ) -> {ok, binary()} | {error, container_credentials_unavailable | erlcloud_aws:httpc_result_error()}.
%%%---------------------------------------------------------------------------
%% @doc Retrieve the container credentials. Will fail if not an EKS pod using EKS Pod Identity.
%%
%% This convenience function will retrieve the credentials from the AWS Task Metadata Endpoint.
%%
%%
get_container_credentials(Config) ->
  FullUri = os:getenv("AWS_CONTAINER_CREDENTIALS_FULL_URI"),
  TokenFilePath = os:getenv("AWS_CONTAINER_AUTHORIZATION_TOKEN_FILE"),
  case {FullUri, TokenFilePath} of
    {false, _} -> {error, container_credentials_unavailable};
    {_, false} -> {error, authorization_token_file_unavailable};
    {_, _} ->
      ServiceToken = string:trim(os:cmd("cat " ++ TokenFilePath)),
      CredentialsPath = FullUri,
      erlcloud_aws:http_body(erlcloud_httpc:request(CredentialsPath, get, [{"Authorization", ServiceToken}], <<>>, erlcloud_aws:get_timeout(Config), Config))
  end.