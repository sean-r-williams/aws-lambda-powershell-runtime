<#
.SYNOPSIS
    Emits a log entry from the Lambda Runtime.
.DESCRIPTION
    Emits a log entry (either JSON- or text-formatted, based on user configuration) to the log stream.
.NOTES
    The function automatically inherits the parent
.LINK
    Specify a URI to a help page, this will show when Get-Help -Online is used.
.EXAMPLE
    Test-MyTestFunction -Verbose
    Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
#>


function Private:Write-RuntimeLog {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory,
            Position=0
        )]
        [string]
        $Message,

        [Parameter(
            DontShow
        )]
        [string]
        $Source = $(
            (Get-Variable MyInvocation -Scope 1 -ValueOnly).MyCommand.Name ??
            (Get-Variable MyInvocation -Scope 1 -ValueOnly).ScriptName ??
            "<unknown>"
        )
    )

    Begin {
        $Script:JSONLogBase = $Script:JSONLogBase ?? @{
            level = "DEBUG"
            logger = "RUNTIME"
        }
    }

    End {
        If ($env:POWERSHELL_RUNTIME_VERBOSE) {
            If ($env:AWS_LAMBDA_LOG_FORMAT -eq "JSON") {
                $LogObject = $Script:JSONLogBase.Clone() + @{
                    message = $Message
                    source = $Source
                }
                Write-Host ($LogObject | ConvertTo-Json -Compress -Depth 100)
            } Else {
                Write-Host "[RUNTIME-$Source]$Message"
            }
        }
    }

}