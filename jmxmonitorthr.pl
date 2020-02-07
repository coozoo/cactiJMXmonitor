#!/usr/bin/perl
#usage: call script with two arguments - jmx host and ip
#	if you have username and password then add two more arguments
#example: ./jmxmonitor 127.0.0.1 1098 user password

#additional description:
#nonthreaded average time of execution around 50-60 seconds for an all values
#threaded around 10-18 seconds for all list of parameters (time really depends from your CPU it's java...)
#added -client flag to java significatly reduces time execution on linux (at least mine)
#the max time execution throwed 10-11 seconds 
#added -Xint flag to java interpreted only reduced time for 1-2 seconds
#but I don't know maybe there is some side effects :)
#threaded defenitely better but not sure if it's better for server :)
#so be aware during monitoring about timings do not set them really low 
#at least 20 seconds looks reasonable lowest value when no networks delays
#and 10 seconds if flags above works for your system but again if no networks delays
#and try how long it runs on your system

#use warnings;
use threads;
#use TimeLimit;
#use Data::Dumper;
use Time::HiRes qw(gettimeofday);
use File::Basename;
use File::Spec::Functions qw/ canonpath /;

my $fsep = canonpath "/";
my $dirname = dirname(__FILE__);
my $jarPluginName = "jmxquery.jar";

my $jmxIP = '127.0.0.1';
my $jmxPort = '1098';
my $userName = '';
my $userPassword = '';

my $num_args = $#ARGV + 1;
if ($num_args == 2) 
{
	$jmxIP=$ARGV[0];
	$jmxPort=$ARGV[1];

}
elsif ($num_args == 4)
{
	$jmxIP=$ARGV[0];
	$jmxPort=$ARGV[1];
	$userName = '';
	$userPassword = '';
}

my $jmxURL = "service:jmx:rmi:///jndi/rmi://$jmxIP:$jmxPort/jmxrmi";
#print $jmxURL."\n";
# those parameters speed up java execution
# -Xint about 1-2 seconds (why I can't explain)
# -dsa about 1 second
# -client about 1-10 second
# to start about 50 java jmx collectors processes 
# 2.3 GHz 4 cores
# java8 - execution time about 4-6 seconds
# java11 - 18-20 seconds. Don't use java 11 for that !!!!!!!!
my $baseCommand="java -jar -client -Xint -dsa $dirname$fsep$jarPluginName";
#no user then no password and vice versa
if ($userName ne '' && $userPassword ne '')
{
	$baseCommand=$baseCommand." -U $jmxURL -username  $userName -password $userPassword";
}
elsif($userName eq '' || $userPassword eq '')
{
	$baseCommand=$baseCommand." -U $jmxURL";
}


my @javaProp;

#get java version
my $javaversion='';
$javaversion=getValue($baseCommand,"JMImplementation","JMImplementation:type=MBeanServerDelegate","ImplementationVersion","");
#  print $javaversion."\n";
# print ((split(/\./, $javaversion))[1]."\n");

$majorversion=8;
# handle versions early it was 1.7.9,1.8.9 now versions looks like this 11.0.6+10
# so suppose we need to check if 1st number is not 1 then get first value
if((split(/\./, $javaversion))[0] == 1)
{
    $majorversion=(split(/\./, $javaversion))[1];
}
else
{
    $majorversion=(split(/\./, $javaversion))[0];
}

 # print $majorversion."\n";

# print "\n".$baseCommand."\n";
# stupid java their revolution in memory managment it was rename namespaces...
if($majorversion < 8)
{
	# print "java7-\n";

	#array sequence $nameforcacti $object $attribute $key set them '' if no need one of them
@javaProp = (	['HeapMemoryUsageused', 'java.lang:type=Memory', 'HeapMemoryUsage', 'used'],
			['HeapMemoryUsagemax', 'java.lang:type=Memory', 'HeapMemoryUsage', 'max'],
			['HeapMemoryUsagecommitted', 'java.lang:type=Memory', 'HeapMemoryUsage', 'committed'],
			['NonHeapMemoryUsageused', 'java.lang:type=Memory', 'NonHeapMemoryUsage', 'used'],
			['NonHeapMemoryUsagecommitted', 'java.lang:type=Memory', 'NonHeapMemoryUsage', 'committed'],
			['Metaspaceused', 'java.lang:type=MemoryPool,name=Metaspace', 'Usage', 'used'],
			['Metaspacecommitted', 'java.lang:type=MemoryPool,name=Metaspace', 'Usage', 'committed'],
			['PSEdenSpaceused', 'java.lang:type=MemoryPool,name=PS Eden Space', 'Usage', 'used'],
			['PSEdenSpacecommitted', 'java.lang:type=MemoryPool,name=PS Eden Space', 'Usage', 'committed'],
			['PSEdenSpacemax', 'java.lang:type=MemoryPool,name=PS Eden Space', 'Usage', 'max'],
			['PSSurvivorSpaceused', 'java.lang:type=MemoryPool,name=PS Survivor Space', 'Usage', 'used'],
			['PSSurvivorSpacecommitted', 'java.lang:type=MemoryPool,name=PS Survivor Space', 'Usage', 'committed'],
			['PSSurvivorSpacemax', 'java.lang:type=MemoryPool,name=PS Survivor Space', 'Usage', 'max'],
			['PSOldGenused', 'java.lang:type=MemoryPool,name=PS Old Gen', 'Usage', 'used'],
			['PSOldGencommitted', 'java.lang:type=MemoryPool,name=PS Old Gen', 'Usage', 'committed'],
			['PSOldGenmax', 'java.lang:type=MemoryPool,name=PS Old Gen', 'Usage', 'max'],
			['CodeCacheused', 'java.lang:type=MemoryPool,name=Code Cache', 'Usage', 'used'],
			['CodeCachecommitted', 'java.lang:type=MemoryPool,name=Code Cache', 'Usage', 'committed'],
			['CodeCachemax', 'java.lang:type=MemoryPool,name=Code Cache', 'Usage', 'max'],
			['CompressedClassSpaceused', 'java.lang:type=MemoryPool,name=Compressed Class Space', 'Usage', 'used'],
			['CompressedClassSpacecommitted', 'java.lang:type=MemoryPool,name=Compressed Class Space', 'Usage', 'committed'],
			['CompressedClassSpacemax', 'java.lang:type=MemoryPool,name=Compressed Class Space', 'Usage', 'max'],
			['PSMarkSweepCollectionCount', 'java.lang:type=GarbageCollector,name=PS MarkSweep', 'CollectionCount', ''],
			['PSMarkSweepCollectionTime', 'java.lang:type=GarbageCollector,name=PS MarkSweep', 'CollectionTime', ''],
			['PSMarkSweepLastGcInfoduration', 'java.lang:type=GarbageCollector,name=PS MarkSweep', 'LastGcInfo', 'duration'],
			['PSScavengeSweepCollectionCount', 'java.lang:type=GarbageCollector,name=PS Scavenge', 'CollectionCount', ''],
			['PSScavengeSweepCollectionTime', 'java.lang:type=GarbageCollector,name=PS Scavenge', 'CollectionTime', ''],
			['PSScavengeSweepLastGcInfoduration', 'java.lang:type=GarbageCollector,name=PS Scavenge', 'LastGcInfo', 'duration'],
			['ProcessCpuLoad', 'java.lang:type=OperatingSystem', 'ProcessCpuLoad', ''],
			['SystemCpuLoad', 'java.lang:type=OperatingSystem', 'SystemCpuLoad', ''],
			['OpenFileDescriptorCount', 'java.lang:type=OperatingSystem', 'OpenFileDescriptorCount', ''],
			['MaxFileDescriptorCount', 'java.lang:type=OperatingSystem', 'MaxFileDescriptorCount', ''],
			['CommittedVirtualMemorySize', 'java.lang:type=OperatingSystem', 'CommittedVirtualMemorySize', ''],
			['TotalSwapSpaceSize', 'java.lang:type=OperatingSystem', 'TotalSwapSpaceSize', ''],
			['FreeSwapSpaceSize', 'java.lang:type=OperatingSystem', 'FreeSwapSpaceSize', ''],
			['FreePhysicalMemorySize', 'java.lang:type=OperatingSystem', 'FreePhysicalMemorySize', ''],
			['TotalPhysicalMemorySize', 'java.lang:type=OperatingSystem', 'TotalPhysicalMemorySize', ''],
			['ThreadCount', 'java.lang:type=Threading', 'ThreadCount', ''],
			['DaemonThreadCount', 'java.lang:type=Threading', 'DaemonThreadCount', ''],
			['TotalStartedThreadCount', 'java.lang:type=Threading', 'TotalStartedThreadCount', ''],
			['TotalLoadedClassCount', 'java.lang:type=ClassLoading', 'TotalLoadedClassCount', ''],
			['LoadedClassCount', 'java.lang:type=ClassLoading', 'LoadedClassCount', ''],
			['UnloadedClassCount', 'java.lang:type=ClassLoading', 'UnloadedClassCount', ''],
			['', '', '', '']
			 );
}
elsif($majorversion == 8)
{
	# print "java8\n";

	#array sequence $nameforcacti $object $attribute $key set them '' if no need one of them
@javaProp = (	['HeapMemoryUsageused', 'java.lang:type=Memory', 'HeapMemoryUsage', 'used'],
			['HeapMemoryUsagemax', 'java.lang:type=Memory', 'HeapMemoryUsage', 'max'],
			['HeapMemoryUsagecommitted', 'java.lang:type=Memory', 'HeapMemoryUsage', 'committed'],
			['NonHeapMemoryUsageused', 'java.lang:type=Memory', 'NonHeapMemoryUsage', 'used'],
			['NonHeapMemoryUsagecommitted', 'java.lang:type=Memory', 'NonHeapMemoryUsage', 'committed'],
			['Metaspaceused', 'java.lang:type=MemoryPool,name=Metaspace', 'Usage', 'used'],
			['Metaspacecommitted', 'java.lang:type=MemoryPool,name=Metaspace', 'Usage', 'committed'],
			['G1EdenSpaceused', 'java.lang:type=MemoryPool,name=G1 Eden Space', 'Usage', 'used'],
			['G1EdenSpacecommitted', 'java.lang:type=MemoryPool,name=G1 Eden Space', 'Usage', 'committed'],
			['G1SurvivorSpaceused', 'java.lang:type=MemoryPool,name=G1 Survivor Space', 'Usage', 'used'],
			['G1SurvivorSpacecommitted', 'java.lang:type=MemoryPool,name=G1 Survivor Space', 'Usage', 'committed'],
			['G1OldGenused', 'java.lang:type=MemoryPool,name=G1 Old Gen', 'Usage', 'used'],
			['G1OldGencommitted', 'java.lang:type=MemoryPool,name=G1 Old Gen', 'Usage', 'committed'],
			['G1OldGenmax', 'java.lang:type=MemoryPool,name=G1 Old Gen', 'Usage', 'max'],
			['CodeCacheused', 'java.lang:type=MemoryPool,name=Code Cache', 'Usage', 'used'],
			['CodeCachecommitted', 'java.lang:type=MemoryPool,name=Code Cache', 'Usage', 'committed'],
			['CodeCachemax', 'java.lang:type=MemoryPool,name=Code Cache', 'Usage', 'max'],
			['CompressedClassSpaceused', 'java.lang:type=MemoryPool,name=Compressed Class Space', 'Usage', 'used'],
			['CompressedClassSpacecommitted', 'java.lang:type=MemoryPool,name=Compressed Class Space', 'Usage', 'committed'],
			['CompressedClassSpacemax', 'java.lang:type=MemoryPool,name=Compressed Class Space', 'Usage', 'max'],
			['G1OldGenerationCollectionCount', 'java.lang:type=GarbageCollector,name=G1 Old Generation', 'CollectionCount', ''],
			['G1OldGenerationCollectionTime', 'java.lang:type=GarbageCollector,name=G1 Old Generation', 'CollectionTime', ''],
			['G1OldGenerationLastGcInfoduration', 'java.lang:type=GarbageCollector,name=G1 Old Generation', 'LastGcInfo', 'duration'],
			['G1YoungGenerationCollectionCount', 'java.lang:type=GarbageCollector,name=G1 Young Generation', 'CollectionCount', ''],
			['G1YoungGenerationSweepCollectionTime', 'java.lang:type=GarbageCollector,name=G1 Young Generation', 'CollectionTime', ''],
			['G1YoungGenerationSweepLastGcInfoduration', 'java.lang:type=GarbageCollector,name=G1 Young Generation', 'LastGcInfo', 'duration'],
			['ProcessCpuLoad', 'java.lang:type=OperatingSystem', 'ProcessCpuLoad', ''],
			['SystemCpuLoad', 'java.lang:type=OperatingSystem', 'SystemCpuLoad', ''],
			['OpenFileDescriptorCount', 'java.lang:type=OperatingSystem', 'OpenFileDescriptorCount', ''],
			['MaxFileDescriptorCount', 'java.lang:type=OperatingSystem', 'MaxFileDescriptorCount', ''],
			['CommittedVirtualMemorySize', 'java.lang:type=OperatingSystem', 'CommittedVirtualMemorySize', ''],
			['TotalSwapSpaceSize', 'java.lang:type=OperatingSystem', 'TotalSwapSpaceSize', ''],
			['FreeSwapSpaceSize', 'java.lang:type=OperatingSystem', 'FreeSwapSpaceSize', ''],
			['FreePhysicalMemorySize', 'java.lang:type=OperatingSystem', 'FreePhysicalMemorySize', ''],
			['TotalPhysicalMemorySize', 'java.lang:type=OperatingSystem', 'TotalPhysicalMemorySize', ''],
			['ThreadCount', 'java.lang:type=Threading', 'ThreadCount', ''],
			['DaemonThreadCount', 'java.lang:type=Threading', 'DaemonThreadCount', ''],
			['TotalStartedThreadCount', 'java.lang:type=Threading', 'TotalStartedThreadCount', ''],
			['TotalLoadedClassCount', 'java.lang:type=ClassLoading', 'TotalLoadedClassCount', ''],
			['LoadedClassCount', 'java.lang:type=ClassLoading', 'LoadedClassCount', ''],
			['UnloadedClassCount', 'java.lang:type=ClassLoading', 'UnloadedClassCount', ''],
			['', '', '', '']
			 );
}
else
{
    # print "9+\n";
    @javaProp = (	['HeapMemoryUsageused', 'java.lang:type=Memory', 'HeapMemoryUsage', 'used'],
			['HeapMemoryUsagemax', 'java.lang:type=Memory', 'HeapMemoryUsage', 'max'],
			['HeapMemoryUsagecommitted', 'java.lang:type=Memory', 'HeapMemoryUsage', 'committed'],
			['NonHeapMemoryUsageused', 'java.lang:type=Memory', 'NonHeapMemoryUsage', 'used'],
			['NonHeapMemoryUsagecommitted', 'java.lang:type=Memory', 'NonHeapMemoryUsage', 'committed'],
			['Metaspaceused', 'java.lang:type=MemoryPool,name=Metaspace', 'Usage', 'used'],
			['Metaspacecommitted', 'java.lang:type=MemoryPool,name=Metaspace', 'Usage', 'committed'],
			['G1EdenSpaceused', 'java.lang:type=MemoryPool,name=G1 Eden Space', 'Usage', 'used'],
			['G1EdenSpacecommitted', 'java.lang:type=MemoryPool,name=G1 Eden Space', 'Usage', 'committed'],
			['G1SurvivorSpaceused', 'java.lang:type=MemoryPool,name=G1 Survivor Space', 'Usage', 'used'],
			['G1SurvivorSpacecommitted', 'java.lang:type=MemoryPool,name=G1 Survivor Space', 'Usage', 'committed'],
			['G1OldGenused', 'java.lang:type=MemoryPool,name=G1 Old Gen', 'Usage', 'used'],
			['G1OldGencommitted', 'java.lang:type=MemoryPool,name=G1 Old Gen', 'Usage', 'committed'],
			['G1OldGenmax', 'java.lang:type=MemoryPool,name=G1 Old Gen', 'Usage', 'max'],
		# codecache memory in java 9-11 replaced by CodeHeap 'non-nmethods', CodeHeap 'non-profiled nmethods', CodeHeap 'profiled nmethods'
		# "great idea" to use single quotes inside names...
		# I'm not adding Codeheap max because accordingly oracle in a future it can be dynamic
			['CodeHeapNMused', 'java.lang:type=MemoryPool,name=CodeHeap \'non-nmethods\'', 'Usage', 'used'],
			['CodeHeapNPMused', 'java.lang:type=MemoryPool,name=CodeHeap \'non-profiled nmethods\'', 'Usage', 'used'],
			['CodeHeapPMused', 'java.lang:type=MemoryPool,name=CodeHeap \'profiled nmethods\'', 'Usage', 'used'],
			['CompressedClassSpaceused', 'java.lang:type=MemoryPool,name=Compressed Class Space', 'Usage', 'used'],
			['CompressedClassSpacecommitted', 'java.lang:type=MemoryPool,name=Compressed Class Space', 'Usage', 'committed'],
			['CompressedClassSpacemax', 'java.lang:type=MemoryPool,name=Compressed Class Space', 'Usage', 'max'],
			['G1OldGenerationCollectionCount', 'java.lang:type=GarbageCollector,name=G1 Old Generation', 'CollectionCount', ''],
			['G1OldGenerationCollectionTime', 'java.lang:type=GarbageCollector,name=G1 Old Generation', 'CollectionTime', ''],
			['G1OldGenerationLastGcInfoduration', 'java.lang:type=GarbageCollector,name=G1 Old Generation', 'LastGcInfo', 'duration'],
			['G1YoungGenerationCollectionCount', 'java.lang:type=GarbageCollector,name=G1 Young Generation', 'CollectionCount', ''],
			['G1YoungGenerationSweepCollectionTime', 'java.lang:type=GarbageCollector,name=G1 Young Generation', 'CollectionTime', ''],
			['G1YoungGenerationSweepLastGcInfoduration', 'java.lang:type=GarbageCollector,name=G1 Young Generation', 'LastGcInfo', 'duration'],
			['ProcessCpuLoad', 'java.lang:type=OperatingSystem', 'ProcessCpuLoad', ''],
			['SystemCpuLoad', 'java.lang:type=OperatingSystem', 'SystemCpuLoad', ''],
			['OpenFileDescriptorCount', 'java.lang:type=OperatingSystem', 'OpenFileDescriptorCount', ''],
			['MaxFileDescriptorCount', 'java.lang:type=OperatingSystem', 'MaxFileDescriptorCount', ''],
			['CommittedVirtualMemorySize', 'java.lang:type=OperatingSystem', 'CommittedVirtualMemorySize', ''],
			['TotalSwapSpaceSize', 'java.lang:type=OperatingSystem', 'TotalSwapSpaceSize', ''],
			['FreeSwapSpaceSize', 'java.lang:type=OperatingSystem', 'FreeSwapSpaceSize', ''],
			['FreePhysicalMemorySize', 'java.lang:type=OperatingSystem', 'FreePhysicalMemorySize', ''],
			['TotalPhysicalMemorySize', 'java.lang:type=OperatingSystem', 'TotalPhysicalMemorySize', ''],
			['ThreadCount', 'java.lang:type=Threading', 'ThreadCount', ''],
			['DaemonThreadCount', 'java.lang:type=Threading', 'DaemonThreadCount', ''],
			['TotalStartedThreadCount', 'java.lang:type=Threading', 'TotalStartedThreadCount', ''],
			['TotalLoadedClassCount', 'java.lang:type=ClassLoading', 'TotalLoadedClassCount', ''],
			['LoadedClassCount', 'java.lang:type=ClassLoading', 'LoadedClassCount', ''],
			['UnloadedClassCount', 'java.lang:type=ClassLoading', 'UnloadedClassCount', ''],
			['', '', '', '']
			 );
}


my (@threads);
my $resultString='';
#for nonthreaded comment threads inside for and last foreach (and uncomment calling procedure)
for (my $i = 0; $i <= $#{ \@javaProp }; $i++)
{
	#$resultString=$resultString." ".getValue($baseCommand,$javaProp[$i][0],$javaProp[$i][1],$javaProp[$i][2],$javaProp[$i][3]);
	my $t=threads->new(\&getValue,$baseCommand,$javaProp[$i][0],$javaProp[$i][1],$javaProp[$i][2],$javaProp[$i][3]);
	push(@threads,$t);
}
my $start_time = gettimeofday ;
#print "started\n";
my $cnt=0;
my $flag=0;
foreach(@threads)
{
	#print "thread".$cnt."\n";
	my $end_time = gettimeofday ;
	
	if($flag==0)
	{
	    my $result=$_->join;
	    my $elapsed_time = int(($end_time-$start_time)*1000);
	    #print $elapsed_time,"\n";
	    if($elapsed_time>10000)
	    {
		$flag=1;
	    }
	    else
	    {
	    if($result)
	    {
		    if($cnt==0)
			    {$resultString=$result;}
		    else
			    {$resultString=$resultString." ".$result;}
		    $cnt++;
	    }
	    }
	}
	else
	{
	    #print "detached\n";
	    $_->detach;
	    $cnt++;
	}
}
$resultString= $resultString."\n";
print $resultString;

sub getValue
{
	my ($baseCommand,$nameforcacti,$object,$attribute,$key)=@_;
	#print $javaProp[$i][0].$javaProp[$i][1].$javaProp[$i][2]."\n"
	if($object ne '')
	{
	$object=" -O \"".$object."\" ";
	if($attribute ne '')
	{
		$attribute=" -A \"".$attribute."\" ";
	}
	if($key ne '')
	{
		$key=" -K \"".$key."\" ";
	}
	
	my $commandExec="$baseCommand $object $attribute $key";
	# print $commandExec."\n";
	my $result = `$commandExec`;
	# be carefull some results from jmx can produce odd symbols for example - semicolon
	# you need to add handling of them here
	if (index($result, "JMX OK") != -1) 
		{
			if(index($attribute, "ImplementationVersion") == -1)
			{
				my $delim = q{|};
				my $last  = substr $result, rindex( $result, $delim ) + length $delim;
				$last =~ s/\s//g;
				$delim = q{=};
				$last  = substr $last, rindex( $last, $delim ) + length $delim;
				# don't wanna analyze output to much so just comparing and deciding what to do by names
				# convert memory to KB 
				# I think it's better to convert inside cacti but if no then I will try here
				#if(index($object, "Memory") != -1)
				#
				#	$last = round($last/1024);
				#}
				# convert CPU load to percents
				if(index($attribute, "Cpu") != -1)
				{
					$last = int ( ($last*100) + 0.5 );
				}
				return $nameforcacti.":".$last;
			}
			else
			{
				my $delim = q{=};
				my $last  = substr $result, rindex( $result, $delim ) + length $delim;
				$last =~ s/\s//g;
				return $last;
			}
		}
		# only for debug no output if JMX not OK
		#else
		#{
		#	return $nameforcacti.":bad answer ".$result;
		#}
	}
}
