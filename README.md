# cactiJMXmonitor

## Info

Configured device looks like this:

<img src="https://user-images.githubusercontent.com/25594311/74098571-9771a480-4b22-11ea-8b42-f5ba16bd3f06.png" width="80%"></img> 

## Script

This script can be executed from shell

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

### JAVA and Environment Perfomance

 To start about 50 java jmx collectors processes (that's how script configured).
 
 System with CPU: 2.3 GHz 4 cores.
  - java-1.8.0 - execution time about 4-6 seconds;
  - java-11 - 18-20 seconds.
  
  Monitoring of 4 java instances (4 parallel executions of script) will take about 10-15 seconds in case if everything fine.
  
  Sometimes Java can be slow when leaking memory or some problems and jmx answer can be slow as well. As result in case of one minute polling this script can finish by timeout and you will get empty results.
  
  But in most cases it will work fine.
  
  **Don't use java 11 to run this script you will struggle from perfomance!!!!!!!!**
  
  **Not sure but suppose with newer java you will get the same result**

Install java (example for fedora):
```bash
# dnf install java-1.8.0-openjdk-headless
```

If you have multiple java installations switch default one by executing command line and enter number:
```bash
# alternatives --config java
```

If you need default to be another version of java, then modify script with full path to java binary.

## Install to cacti

### Copy Script to cacti

Copy jmxmonitorthr.pl, jmxquery.jar to /var/lib/cacti/scripts

```bash
$ git clone https://github.com/coozoo/cactiJMXmonitor
$ cd cactiJMXmonitor
$ chmod 777 jmxmonitorthr.pl
$ cp jmxmonitorthr.pl /var/lib/cacti/scripts/
$ cp jmxquery.jar /var/lib/cacti/scripts/
```

### Import Host Template

There is two templates for now:

* java 8 template - suitable only for java8;
* java 9 template - suitable for java 9 and higher (at least up to java11 nothing changed).

It's small differences between java 8 and 9/11, codecache memory is splitted onto three codeheap spaces.

So if you are planning to move from java8 to higher version it's better to use java9 template

Steps to install:
1. In cacti go to "Console"->"Import/Export"->"Import Templates"
2. Press "Select a file" button and find downloaded cacti_host_template_jmx_-_device_java9.xml
3. Unmark "Preview Import Only" (sure you can try it to view changes)
4. Select "Data Source Profile" - "1 Minute Collection" will work fine (I'm using custom 1 minute to save data longer)

