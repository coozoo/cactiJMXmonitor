# cactiJMXmonitor

## Info

This script canbe executed from shell

Replace IP port with yours values

```bash
$ ./jmxmonitorthr.pl 127.0.0.1:1098

```

Result of executing command:

```bash
HeapMemoryUsageused:3105249280 HeapMemoryUsagemax:10737418240 HeapMemoryUsagecommitted:10737418240 NonHeapMemoryUsageused:244632312 NonHeapMemoryUsagecommitted:255975424 Metaspaceused:157534160 Metaspacecommitted:164462592 G1EdenSpaceused:2176843776 G1EdenSpacecommitted:6710886400 G1SurvivorSpaceused:54525952 G1SurvivorSpacecommitted:54525952 G1OldGenused:924211200 G1OldGencommitted:3972005888 G1OldGenmax:10737418240 CompressedClassSpaceused:19339016 CompressedClassSpacecommitted:22044672 CompressedClassSpacemax:1073741824 G1OldGenerationCollectionCount:0 G1OldGenerationCollectionTime:0 G1OldGenerationLastGcInfoduration:null G1YoungGenerationCollectionCount:129 G1YoungGenerationSweepCollectionTime:7282 G1YoungGenerationSweepLastGcInfoduration:100 ProcessCpuLoad:2 SystemCpuLoad:3 OpenFileDescriptorCount:178 MaxFileDescriptorCount:1048576 CommittedVirtualMemorySize:15482507264 TotalSwapSpaceSize:0 FreeSwapSpaceSize:0 FreePhysicalMemorySize:1820565504 TotalPhysicalMemorySize:15599792128 ThreadCount:142 DaemonThreadCount:100 TotalStartedThreadCount:888 TotalLoadedClassCount:28649 LoadedClassCount:28648 UnloadedClassCount:1

```

Note: you need to open JMX like this but remember don't use it in real env and don't open to the world without ssl
```
-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=1098 -Dcom.sun.management.jmxremote.rmi.port=1098 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Djava.rmi.server.hostname={hostip}
```


## Setup

Copy jmxmonitorthr.pl, jmxquery.jar to
/var/lib/cacti/scripts

```bash
$ git clone https://github.com/coozoo/cactiJMXmonitor
cd cactiJMXmonitor
cp jmxmonitorthr.pl /var/lib/cacti/scripts/
cp jmxquery.jar /var/lib/cacti/scripts/
```

Cacti templates will be provided later.
