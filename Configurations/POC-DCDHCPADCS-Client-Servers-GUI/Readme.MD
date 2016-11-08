# Lab definition

## NOTE!
This is currently under testing for release - until then see configuration:
POC-MultiRole  (either GUI or Core)

This lab builds the foloowing:

* 1 DC with users, groups and OU's
* 1 DHCP Server on the DC
* 1 ADCS authority, with defined autoenroll GPO's and two certificate templates:
        * WebServer template
        * DSC Credential encryption Template
* 1 Domain joined Web server
* 1 Domain joined Windows 10 Client