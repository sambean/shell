#!/bin/sh
source ~/.bash
appName=www
git="/IS/git/remote_www/"
docBase="/IS/app/www.indulgesmart.com"
warname=indulgesmart-www-webapp.war
tomcatName=apache-tomcat-8.0.3-test
tomcatPath=/IS/server/$tomcatName
if [ "-$1" = "-" ];then
   echo "please specified branch"
   exit	
fi  
echo $git
cd $git
git pull
#switch branch
git checkout $1
#need to ssh without password
git pull
echo "start to package,use test  profile"
mvn clean package -X -Ptest -Dmaven.test.skip=true -U  
if [ ! -f  "$git/target/$warname" ];then
echo "package failed========================================="
exit
fi
echo "start to backup"
path="`date '+%Y%m%d%H%M%S'`"
path="/IS/data/appbackup/"$appName/$path
echo "backup dir"$path
mkdir -p $path
cd $docBase
cp -R * $path
echo "backup end"
echo "delete docBase"$docBase
rm -rf $docBase/*
echo "move to docBase "$docBase
cd $git/target
mv $warname $docBase
cd $docBase
echo "start to unzip"
unzip $warname   >>/dev/null
echo "start to rm war" $warname
rm -rf $warname
#shutdown tomcat
pid=`ps aux | grep $tomcatName | grep -v 'grep' |  awk 'NR==1{print $2}'`
echo "kill:" + $pid
kill -9 $pid
echo "start tomcat" $tomcatPath
cd $tomcatPath/bin
./startup.sh
pid=`ps aux | grep $tomcatName | grep -v 'grep' | awk 'NR==1{print $2}'`
echo "start success,pid is " $pid
#cd $tomcatPath/logs
#itiail -n 500 -f catalina.out
