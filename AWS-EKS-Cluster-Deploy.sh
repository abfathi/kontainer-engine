#/bin/bash!
echo $PWD

function usage () {
   cat <<EOF
Usage: $scriptname [-a]  <cluster name>  -c <display name> -d <aws_access_key_id> -e <aws_secret_access_key> -f <AWS region name> -g <instance type> -i <minimum nodes> -j <maximum nodes>
   -h   Get Help
   -a   cluster name
   -c   display name
   -d   AWS access key 
   -e   AWS secret access key
   -f   AWS region name
   -g   instance type
   -i   minimum nodes
   -j   maximum nodes
   -h   help
   
EOF
   exit 0
}


while getopts ":ha:c:d:e:f:g:i:j:" opt; do
   case $opt in
   a )  cluster_name=$OPTARG ;;
   c )  display=$OPTARG  ;;
   d )  aws_access_key=$OPTARG  ;;
   e )  aws_secret_access_key=$OPTARG  ;;
   f )  region_name=$OPTARG  ;;
   g )  instance_type=$OPTARG  ;;
   i )  min_nodes=$OPTARG  ;;
   j )  max_nodes=$OPTARG  ;;
   h )  usage ;;
   \?)  usage ;;
   esac
done

shift $(($OPTIND - 1))

if [ -z $cluster_name ]  ; then
  echo -e "Please enter the cluster name"
  usage
  exit 1
fi

if [ -z $display ]  ; then
  echo -e "Please enter the cluster display name"
  usage
  exit 1
fi
if [ -z $aws_access_key ]  ; then
  echo -e "Please enter AWS access Key id"
  usage
  exit 1
fi
if [ -z $aws_secret_access_key ]  ; then
  echo -e "Please enter AWS secret access"
  usage
  exit 1
fi
if [ -z $region_name ]  ; then
  echo -e "Please enter the region name"
  usage
  exit 1
fi
if [ -z $instance_type ]  ; then
  echo -e "Please enter the EC2 instance type"
  usage
  exit 1
fi
if [ -z $min_nodes ]  ; then
  echo -e "Please enter the minimal number of nodes"
  usage
  exit 1
fi
if [ -z $max_nodes ]  ; then
  echo -e "Please enter the maximum number of nodes"
  usage
  exit 1
fi

echo -e "cluster_name=$cluster_name"
echo -e "display=$display"
echo -e "aws_access_key=$aws_access_key"
echo -e "aws_secret_access_key=$aws_secret_access_key"
echo -e "region_name=$region_name"
echo -e "instance_type=$instance_type"
echo -e "min_nodes=$min_nodes"
echo -e "max_nodes=$max_nodes"

echo -e "START K8s provisionning"
./build/bin/kontainer-engine_darwin-amd64 create $cluster_name --driver eks --display-name $display --client-id $aws_access_key --client-secret $aws_secret_access_key --region $region_name --instance-type $instance_type --minimum-nodes $min_nodes --maximum-nodes $max_nodes
echo -e "END K8s provisionning"

echo -e "START KUBECTL CONFIGURATION"
source ./genKubeCfg.sh $cluster_name
echo -e "END KUBECTL CONFIGURATION"