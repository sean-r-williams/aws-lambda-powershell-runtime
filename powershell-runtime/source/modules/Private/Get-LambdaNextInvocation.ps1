# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

function private:Get-LambdaNextInvocation {
    <#
        .SYNOPSIS
            Get /NEXT invocation from AWS Lambda Runtime API.

        .DESCRIPTION
            Get /NEXT invocation from AWS Lambda Runtime API.

        .Notes
            If there is an error calling the Runtime API endpoint, this is ignored and retried as part of the event loop.
    #>
    param (
        [Parameter(Position=0)]
        [System.Net.Http.HttpClient]$private:HttpClient
    )

    Write-RuntimeLog 'Start: Get-LambdaNextInvocation'

    Write-RuntimeLog 'Create GET request to Runtime API'

    $private:request = [System.Net.Http.HttpRequestMessage]::new()
    $private:request.Headers.Add('User-Agent', "aws-lambda-powershell/$env:POWERSHELL_VERSION")
    $private:request.Method = 'GET'
    $private:request.RequestUri = "http://$env:AWS_LAMBDA_RUNTIME_API/2018-06-01/runtime/invocation/next"

    try {
        # Get the next invocation
        Write-RuntimeLog 'Get the next invocation'
        $private:response = $private:HttpClient.SendAsync($private:request).GetAwaiter().GetResult()
    }
    catch {
        # If there is an error calling the Runtime API endpoint, ignore which tries again
        Write-RuntimeLog "Exception caught: $($_.Exception.Message)"
        continue
    }

    Write-RuntimeLog 'Read the response content'
    $private:incomingEvent = $private:response.Content.ReadAsStringAsync().GetAwaiter().GetResult()

    Write-RuntimeLog 'Generate the correct response headers'
    $private:incomingHeaders = @{}
    foreach ($private:header in $private:response.Headers) {
        $private:incomingHeaders[$private:header.Key] = $private:header.Value
    }

    Write-RuntimeLog 'Create a response object'
    $private:NextInvocationResponseObject = [pscustomobject]@{
        headers       = $private:incomingHeaders
        incomingEvent = $private:incomingEvent
    }

    if ($private:response) { $private:response.Dispose() }
    if ($private:responseStream) { $private:responseStream.Dispose() }
    Write-RuntimeLog 'Return response object'
    return [pscustomobject]$private:NextInvocationResponseObject
}
