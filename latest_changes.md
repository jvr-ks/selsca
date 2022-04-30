#### Latest changes:
[-> README](README.md)
  
Version (>=)| Change
------------ | -------------
0.031 | File "mime.type" created auto. if not existent
0.030 | UAC request integrated
  
#### Known issues / bugs 
Issue / Bug | Type | fixed in version
------------ | ------------- | -------------
- | bug | -

#### Latest changes, older entries:
* Names must be surrounded by **round backets** now!
* PATH and SCALA_HOME etc. are set as System-Environment-Variables now,  
please manually remove any corresponding User-Environment-Variables!  
* **Blanks are NOT allowed in the selection-name!**   
* RestApi, example call with browser: http://localhost:65501/selsca?version=(Scala-2.13.6)  
or  
curl http://localhost:65501/selsca?version=(Scala-2.13.6)   
(With curl brackets must be escaped!)  
Use "restapioff" start-parameter to disable the RestApi server.  
The port-number is defined in the Configuration-file: "selscaRestPort=65501" (65501 is default)  

** Besides that, the purpose of "selsca" is NOT to temporary switch the Scala-version in a batch-file,     
because this can be done with and set path=scalapathXYZ;%path% etc. !**  
   
* Menu-entry "Internet resources"
* Scala 3 (Dotty) Windows .exe is not available at the moment,   
but you can use SBT, take a look at [dotty_latest](https://github.com/jvr-ks/dotty_latest)

* "scalaVersion.exe"  
* Scala version can be selected via a selsca.exe "start-argument", example:  
selsca.exe "(Scala 2.12.13)"  
Please verify the correct operation of the app before using this feature.  
(The path-confirmation query is skipped!)  
  
* LinkList removed  
  
[-> README](README.md)  


