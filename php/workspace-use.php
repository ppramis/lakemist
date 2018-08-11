<?php 
/*
  Checking on workspace usage given start-time and end-time
 */

 $command = "aws workspaces describe-workspaces --query Workspaces[*].[WorkspaceId,UserName] --output text";
 $workspaces = shell_exec($command);
 
 if (strlen($workspaces) > 0) {
  $ids = explode(chr(10), $workspaces);
  $num_of_ids = count($ids) - 1;
  $start = "2018-08-01T00:00:00";
  $end   =	"2018-08-12T23:59:59";
  for ($i = 0; $i < $num_of_ids; $i++) {
	  $workspace = substr($ids[$i],0, 12);
//	  echo $ids[$i];
//	  echo "\r\n";
	  $logins = "aws cloudwatch get-metric-statistics --metric-name ConnectionSuccess ";
	  $logins = $logins . "--start-time  $start ";
	  $logins = $logins . "--end-time $end ";
	  $logins = $logins . "--period 3600 --namespace AWS/WorkSpaces ";
	  $logins = $logins . "--statistics SampleCount --dimensions Name=WorkspaceId,Value=$workspace ";
	  $logins = $logins . "--output text";
//	  echo $logins;
//	  echo "\r\n";
	  
	  $output = shell_exec($logins);
	  echo $ids[$i] , "  " , $output;
	  echo "\r\n";
	  } 
  echo "\r\n";
 }
 

/* 
 foreach ($workspaces as $workspace) {
        echo $workspace;
        echo "\r\n";
		
        $command = "aws ec2 describe-instances --region {$region} --filters \"Name=instance-state-name,Values=running\"  --query Reservations[*].Instances[*].[InstanceId] --output text";
        $running = shell_exec($command);
*/

/*
  If $running has a length of > 0, then instance ids have been returned.  It will be a string of
  potentially multiple instanceIds separated by chr(10), there will be a trailing chr(10 so the
  array's last element will be null
 */

 ?>
