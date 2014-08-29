-record(aws_config, {
          as_host="autoscaling.amazonaws.com"::string(),
          ec2_host="ec2.amazonaws.com"::string(),
          iam_host="iam.amazonaws.com"::string(),
          sts_host="sts.amazonaws.com"::string(),
          s3_scheme="https://"::string(),
          s3_host="s3.amazonaws.com"::string(),
          s3_port=80::non_neg_integer(),
          sdb_host="sdb.amazonaws.com"::string(),
          elb_host="elasticloadbalancing.amazonaws.com"::string(),
          ses_host="email.us-east-1.amazonaws.com"::string(),
          sqs_host="queue.amazonaws.com"::string(),
          sns_host="sns.amazonaws.com"::string(),
          mturk_host="mechanicalturk.amazonaws.com"::string(),
          mon_host="monitoring.amazonaws.com"::string(),
          mon_port=undefined::non_neg_integer()|undefined,
          mon_protocol=undefined::string()|undefined,
          ddb_scheme="https://"::string(),
          ddb_host="dynamodb.us-east-1.amazonaws.com"::string(),
          ddb_port=80::non_neg_integer(),
          ddb_retry=fun erlcloud_ddb_impl:retry/1::erlcloud_ddb_impl:retry_fun(),
          kinesis_scheme="https://"::string(),
          kinesis_host="kinesis.us-east-1.amazonaws.com"::string(),
          kinesis_port=80::non_neg_integer(),
          kinesis_retry=fun erlcloud_kinesis_impl:retry/2::erlcloud_kinesis_impl:retry_fun(),
          cloudtrail_scheme="https://"::string(),
          cloudtrail_host="cloudtrail.amazonaws.com"::string(),
          cloudtrail_port=80::non_neg_integer(),
          access_key_id::string()|undefined|false,
          secret_access_key::string()|undefined|false,
          security_token=undefined::string()|undefined,
          timeout=10000::timeout(),
          cloudtrail_raw_result=false::boolean()
         }).
-type(aws_config() :: #aws_config{}).
