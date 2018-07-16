#/bin/bash!

function usage () {
   cat <<EOF
Usage: $scriptname [-a]  <autoscalingGroupName>  -b <region name> -c <desired capacity> -d <max size>
   -h   Get Help
   -a   autoscalingGroupName
   -b   region name
   -c   desired capacity
   -d   max size
   -h   help
EOF
   exit 0
}

while getopts ":ha:b:c:d:" opt; do
   case $opt in
   a )  autoscaling_group_name=$OPTARG ;;
   b )  region_name=$OPTARG ;;
   c )  desired_capacity=$OPTARG  ;;
   d )  max_size=$OPTARG  ;;
   h )  usage ;;
   \?)  usage ;;
   esac
done

shift $(($OPTIND - 1))

if [ -z $autoscaling_group_name ]  ; then
  echo -e "Please enter the autoscaling group name"
  usage
  exit 1
fi

if [ -z $region_name ]  ; then
  echo -e "Please enter the AWS region name"
  usage
  exit 1
fi

current_minsize=$(aws autoscaling describe-auto-scaling-groups --region $region_name --query 'AutoScalingGroups[].[AutoScalingGroupName, MinSize, MaxSize,DesiredCapacity]' --output table | grep -w $autoscaling_group_name | awk '{print $4}')
current_maxsize=$(aws autoscaling describe-auto-scaling-groups --region $region_name --query 'AutoScalingGroups[].[AutoScalingGroupName, MinSize, MaxSize,DesiredCapacity]' --output table | grep -w $autoscaling_group_name | awk '{print $6}')
current_desired_cap=$(aws autoscaling describe-auto-scaling-groups --region $region_name --query 'AutoScalingGroups[].[AutoScalingGroupName, MinSize, MaxSize,DesiredCapacity]' --output table | grep -w $autoscaling_group_name | awk '{print $8}')

echo -e "current_minsize=$current_minsize"
echo -e "current_maxsize=$current_maxsize"
echo -e "current_desired_cap=$current_desired_cap"

if [ -z $desired_capacity ] && [ -z $max_size ]  ; then
  echo -e "Please enter the desired capacity or max size or both"
  usage
elif [ -z $desired_capacity ]; then
  echo -e "max_size=" $max_size
  if [ $current_maxsize -gt $max_size ] && [ $current_desired_cap -gt $max_size ]; then   
    echo -e "aws autoscaling update-auto-scaling-group updating desired capacity to $max_size and max size to $max_size"
    aws autoscaling update-auto-scaling-group --auto-scaling-group-name $autoscaling_group_name --desired-capacity $max_size --max-size $max_size
  else
    echo -e "aws autoscaling update-auto-scaling-group updating max size to $max_size"
    aws autoscaling update-auto-scaling-group --auto-scaling-group-name $autoscaling_group_name --max-size $max_size
  fi
elif [ -z $max_size ]; then
   echo -e "desired_capacity=" $desired_capacity
   if [ $desired_capacity -le $current_maxsize ]; then
    echo -e "aws autoscaling updating desired capacity to $desired_capacity"
    aws autoscaling update-auto-scaling-group --auto-scaling-group-name $autoscaling_group_name --desired-capacity $desired_capacity
   else
    echo -e "aws autoscaling desired capacity should be lesser or equal to max size "
   fi
elif [ $desired_capacity -le $max_size ]; then 
  echo -e "aws autoscaling updating both desired capacity to $desired_capacity and max size to $max_size"
  aws autoscaling update-auto-scaling-group --auto-scaling-group-name $autoscaling_group_name --desired-capacity $desired_capacity --max-size $max_size
else
  echo -e "aws autoscaling desired capacity should be lesser or equal to max size "
fi

