# EndPointRecon
This is a simple script that will perform passive non aggressive enumeration of web application endpoints using gau, waybackurls, paramspider, and gospider. All endpoints are then run through gf pattern sets to create a list of targeted endpoints of interest for potential SQLi, LFI, IDOR, SSRF, etc...

## Arguments
![alt text](https://github.com/antroguy/EndpointRecon/blob/main/img/Commands.png)

This script accepts two initial arguments:
- ***setup*** - This will setup and install the necessary tools to run the script properly.
- ***enum***  - This will perform web application endpoint enumeration.

## Enum
![alt text](https://github.com/antroguy/EndpointRecon/blob/main/img/Enum.png)

Enum accepts two positional parameters:
- ***Domains*** - This will be a list of InScope Domains to perform the enumeration on. This can also be a list of Web applications.
- ***output_directory***  - The name of the output directory to create where all output will be saved.

## Example
```
./endpointRecon.sh enum Domains.txt TARGET_###
```
```
./endpointRecon.sh enum WebHosts.txt TARGET_###
```
