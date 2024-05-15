[CmdletBinding()]
param(
    #the artifact to install.
    [Parameter(Mandatory = $false)]
    [string]$Tag = "001"
)

#AGENT COMMANDS

Set-Location .\stw-mapping-library
(Get-Location).path
java --version
update-alternatives --list java
mvn clean install -pl trade-mapping-to-ipaffs -am --settings ../stw-ops/scripts/settings/settings.xml


#LOCAL COMMANDS

# Set-Location /Users/ciaranha/repos/DEFRA-STW/stw-mapping-library
# mvn clean install -pl trade-mapping-to-ipaffs -am --settings /Users/ciaranha/repos/DEFRA-STW/stw-ops/scripts/settings/settings.xml