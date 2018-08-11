<?php
//
// get-cpu-metrics : create csv ready to be imported into excel.  The columns are tab-delimited.
//                   the user is then able to create a pivot table from the data produced
//					 All cpu utilization metrics for all ec2 instances within the account for the past 14 days
//

date_default_timezone_set('America/New_York');
$edate = date('Y-m-d');
$sdate = date('Y-m-d', strtotime('-14 day', (strtotime($edate))));
$fn = 'asec6 cpu metrics from ' . $sdate . ' to ' . $edate . ".csv";
$put_str = "Region" . "\t" . "Instance" . "\t" . "Size" . "\t" . "Time" . "\t" . "Date" . "\t" . "Percent\r\n";
$ret = file_put_contents($fn, $put_str);

$regions = array("us-east-1","us-west-2","us-west-1","eu-west-1","eu-central-1",
                   "ap-southeast-1","ap-northeast-1","ap-southeast-2","ap-northeast-2",
                   "ap-south-1","sa-east-1");


foreach ($regions as $region) {
    echo $region;
    echo "\r\n";
    $command = "aws ec2 describe-instances --region {$region} --query Reservations[*].Instances[*].[InstanceId,InstanceType] --output text";
    $instances = shell_exec($command);
	if (strlen($instances) > 0 ) {
		$inst_a = explode(chr(10),$instances);
		$inst_a_size = count($inst_a) - 1;
		for ($y = 0; $y < $inst_a_size; $y++) {
			$ec2 = explode("\t",$inst_a[$y]);
//
// Get the CloudWatch metrics for each instance
//
			$command = "aws cloudwatch get-metric-statistics --metric-name CPUUtilization --start-time {$sdate}T00:00:00 --end-time ";
			$command = $command . "{$edate}T00:00:00 --period 3600 --namespace AWS/EC2 --statistics Average --dimensions Name=InstanceId,Value={$ec2[0]}";
			$string = shell_exec($command);
//  
//  Have had some trouble with non-printable characters, loop below just makes sure to drop them out
//			
			$s = "";
			for ($i = 0; $i <= strlen($string); $i++) {
				if (ord($string[$i]) > 0 && ord($string[$i]) <= 127) {
					$s = $s . $string[$i];
				}
			}
			$lines = explode(chr(10), $s);
			$num_lines = count($lines);
			$j = 0;
			$data = [[[]]];
			for ($i = 0; $i < $num_lines; $i++) {
				if (strpos($lines[$i], 'Timestamp') != false) {
					$data[$j][0] = substr($lines[$i],strpos($lines[$i], ':') + 3, 10);
					$data[$j][1] = substr($lines[$i],strpos($lines[$i], ':') + 14, 9);
				}
				if (strpos($lines[$i], 'Average') != false) {
					$data[$j][2] = round(substr($lines[$i],strpos($lines[$i], ':') + 2, 5), 2) / 100;
					$j++;
				}
			}
			$num_elements = count($data);
			for ($i = 0; $i < $num_elements; $i++) {
				$put_str = $region . "\t" . $ec2[0] . "\t" . $ec2[1] . "\t" . $data[$i][0] . "\t" . $data[$i][1] . "\t" . $data[$i][2] . "\r\n";
				$ret = file_put_contents($fn,$put_str,FILE_APPEND);
			}
			echo $ec2[0] . "\t" . $num_elements . "\t" . $y . "\r\n";
		}
	}
}
?>