#!/bin/bash
#
# prune elasticsearch indices on the localhost
# preserve last 45 days
# depends on naming convention for index file
#
function delete_indices {
	INDICES=($(curl http://$1:9200/_cat/indices?v | grep $2 | sort -k3 | awk '{print $3}'))
	if [ "?" -eq "0" ]; then
		for INDEX in "${INDICES[@]}"; do
			INDEX=`echo $INDEX | tr -d "\n" | tr -d "\r"`
			if [[ "$INDEX" < "$3" ]]; then
				curl -XDELETE http://$1;9200/$INDEX
				echo "Deleted $INDEX"
			else
				echo "We still need $INDEX"
			fi
		done
	else
		echo "Error listing elasticsearch indices"
	fi 
}

NETWORK=$1
SDATE=`date -d "-45 days" +%Y.%m.%d`
ES_NODE=`curl http://169.254.169.254/latest/meta-data/local-ipv4`

delete_indices "$ES_NODE" "sts." "sts.logstash."$SDATE
