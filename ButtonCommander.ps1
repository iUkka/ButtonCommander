<#
.SYNOPSIS
This script is backend for mattermost slash/button commands.
.DESCRIPTION
Use this script with the MicrosoftTeams PowerShell version 3.
.PARAMETER ListenerPort
Port for listener, 12345 by default
.PARAMETER ListenerHost
Parameter requires a hostname or IP in the format localhost or 192.168.0.1. By default all ips.
.PARAMETER Config
Path to config file in INI format, by default ./settings.ini
.PARAMETER Verbose
This switch give limited information for debugging troubles.
#>param(
    $ListenerPort = 12345,
    $ListenerHost = '+', #all ips
    $Config = "$PSScriptRoot\settings.ini",
    [switch] $verbose
)

    if ($verbose) {
        $VerbosePreference = 'Continue'
    } else {
        $VerbosePreference = 'SilentlyContinue'
    }

function Reload-OwnConfig {
    $ini = @{}
    if (Test-path -path $script:configpath) {
        switch -regex -file $script:configpath
        {
            "^\[(.+)\]$" { 
                $section = $matches[1]
                $ini[$section] = @{}
            }
            "^([^[#].*)=(.*)" {
                $name,$value = $matches[1..2]
                $ini[$section][$name] = $value
            }
        }
    }
    return $ini
}

    $script:configpath = $config
    $script:OwnConfig = Reload-OwnConfig

    # Create a listener on port 12345
    $ListenerPort = 'http://{0}:{1}/' -f $ListenerHost,$ListenerPort
    $listener = New-Object -TypeName System.Net.HttpListener
    $listener.Prefixes.Add($ListenerPort) 
    $listener.Start()
    Write-Verbose 'Listening ...'

    # Run until you send a GET request to /end
    while ($listener.IsListening) { #listener
        $message = $null

        $context = $listener.GetContext() 
 
        # Capture the details about the request
        $request = $context.Request

        # Setup a place to deliver a response
        $response = $context.Response

        switch -regex ($request.Url) { 
            '/stop$' { 
                # Break from loop if request sent to /end
                $message = "Listener stopped, bye-bye!"
                $break = $true 
            }
            '/reload$' { 
                #reload configuration
                $script:OwnConfig = Reload-OwnConfig
                $message = "Listener config reloaded!
$($script:OwnConfig|Out-String)"
                $break = $false
            }
            Default { # Let mortal combat begin!
                $break = $false
        
                # Split request URL to get command and options
                $requestvars = ([String]$request.Url).split('/')
        
                $method = ([String]$request.HttpMethod)
                $path = $requestvars[3].Split('\')[0]
                $IncomingVariables = $script:OwnConfig[$path].IncomingVariables
                $argumentList = @()
                if ($request.HasEntityBody) {
                    $Reader = New-Object System.IO.StreamReader($request.InputStream)
                    try {
                        $originalvalues = $Reader.ReadToEnd()
                        Write-Verbose "$($originalvalues|Out-string)"
                        $values = $originalvalues-split '&' | ConvertFrom-StringData -ErrorAction Stop
                        Write-Verbose "Values - type is $($values.GetType())"
                        
                    } catch {
                    # Button stuff
                        write-verbose "$($originalvalues|out-string)"
                        #$values = Json-ToHashTable( $originalvalues )
                        $ht = @{}
                        (ConvertFrom-Json $originalvalues).psobject.properties | Foreach { $ht[$_.Name] = $_.Value }
                        $values = $($ht.GetEnumerator()  | % { "$($_.Name)=$($_.Value)" }) | ConvertFrom-StringData
                        Remove-Variable ht -ErrorAction SilentlyContinue
                        Write-Verbose "Values - type is $($values.GetType())"
                    }
                    Write-Verbose "Values is: `n`r $($values|ft|Out-String)"
                    write-verbose "Looking from $($IncomingVariables -split "," )"
                    $IncomingVariables -split "," | foreach{
                        if ($values."$_"){
                            write-verbose "Value is $($values."$_"|Out-string)"
                            #$argumentList += "-$($_) "+"'"+$([System.Web.HttpUtility]::UrlDecode($values."$_"))+"' "
                            $argumentList += '-{0} "{1}"' -f $($_), $([System.Web.HttpUtility]::UrlDecode($values."$_"))
                            write-verbose "$argumentList"
                        } else { write-verbose "No value named $($_)" }#end if
                    } #end foreach
                } #end if
                if (($Script:OwnConfig[$path]).Script) 
                {
                    Write-Verbose "Executing section [$path] with script $(($Script:OwnConfig[$path]).Script)"
                    try {
                        Set-Location $PSScriptRoot
                        $message = Invoke-Expression "$(($Script:OwnConfig[$path]).Script) $argumentList"
                        
                    } catch {
                        $_
                        Write-Host -Foreground Red -Background Black "Invoke-Expression $(($Script:OwnConfig[$path]).Script) $argumentList"
                        $message
                        $message = "Something wrong with script.`n$(($Script:OwnConfig[$path]).Script)`n$($argumentList | Out-string)"
                    }
                    Pop-Location
                } #end if passed

            } #End default
        } # end switch



    if (-not $message) { #No script block or no variables
        $message = "Nothing happends. No [Script] found for $path. Check your setting file!" 
    }

    #check message is json
    try {
        $answer = ConvertFrom-Json $message -ErrorAction Stop
        Write-Verbose "JSON is valid"
    } #JSON is valid
    catch {
        Write-Verbose "JSON is invalid"
        $message = ($message|Out-String)
        $answer = @"
{
    "response_type": "in_channel",
    "text": ""
}
"@ | ConvertFrom-Json
        $answer.text = $message
    }
        $answer = $answer | ConvertTo-Json -Depth 100
      
    # Convert the data to UTF8 bytes
    [byte[]]$buffer = [System.Text.Encoding]::UTF8.GetBytes($answer)

    # Set length of response
    $response.ContentLength64 = $buffer.length
    $response.ContentType = 'application/json'
    $response.StatusCode = 200
    # Write response out and close
    $response.OutputStream.Write($buffer,0,$buffer.Length)
    $response.Close()
       
    #game over, man
    if ($break) {break}

}
 
#Terminate the listener
$listener.Stop()