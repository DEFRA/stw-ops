[CmdletBinding()]
param(
    #the artifact to install.
    [Parameter(Mandatory = $false)]
    [string]$Tag = "001"
)

Set-Location .\stw-mapping-library

mvn clean install -pl trade-mapping-to-ipaffs -am #--settings /home/vsts/work/1/s/stw-ops/scripts/settings/settings.xml