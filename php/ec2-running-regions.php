<?php 
/*
  Checking all regions for running instances to shutdown except the machine from which
  this script is running
 */

  $regions = array("us-east-1","us-west-2","us-west-1","eu-west-1","eu-central-1",
                   "ap-southeast-1","ap-northeast-1","ap-southeast-2","ap-northeast-2",
                   "ap-south-1","sa-east-1");

  $thisInstance = shell_exec("wget -q -O - http://instance-data/latest/meta-data/instance-id");
  echo "This machine's instance id is {$thisInstance}.";
  echo "\r\n";

  foreach ($regions as $region) {
        echo $region;
        echo "\r\n";
        $command = "aws ec2 describe-instances --region {$region} --filters \"Name=instance-state-name,Values=running\"  --query Reservations[*].Instances[*].[InstanceId] --output text";
        $running = shell_exec($command);
/*
  If $running has a length of > 0, then instance ids have been returned.  It will be a string of
  potentially multiple instanceIds separated by chr(10), there will be a trailing chr(10 so the
  array's last element will be null
 */
        if (strlen($running) > 0) {
          $ids = explode(chr(10), $running);
          $num_of_ids = count($ids) - 1;
          for ($i = 0; $i < $num_of_ids; $i++) {
            if ($ids[$i] != $thisInstance) {
              echo $ids[$i];
              echo "\r\n";
            }
          } 
          echo "\r\n";
        }
    } 
 ?>
