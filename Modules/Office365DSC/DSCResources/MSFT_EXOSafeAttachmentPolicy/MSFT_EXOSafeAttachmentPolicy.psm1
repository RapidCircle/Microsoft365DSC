function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [Parameter()]
        [ValidateSet('Block', 'Replace', 'Allow', 'DynamicDelivery')]
        [System.String]
        $Action = 'Block',

        [Parameter()]
        [Boolean]
        $ActionOnError = $false,

        [Parameter()]
        [System.String]
        $AdminDisplayName,

        [Parameter()]
        [Boolean]
        $Enable = $false,

        [Parameter()]
        [Boolean]
        $Redirect = $false,

        [Parameter()]
        [System.String]
        $RedirectAddress,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $GlobalAdminAccount
    )
    Write-Verbose "Get-TargetResource will attempt to retrieve SafeAttachmentPolicy $($Identity)"
    Write-Verbose 'Calling Connect-ExchangeOnline function:'
    Connect-ExchangeOnline -GlobalAdminAccount $GlobalAdminAccount -CommandsToImport '*SafeAttachmentPolicy'
    Write-Verbose 'Global ExchangeOnlineSession status:'
    Write-Verbose "$( Get-PSSession -ErrorAction SilentlyContinue | Where-Object Name -eq 'ExchangeOnline' | Out-String)"
    $CmdletIsAvailable = Confirm-ImportedCmdletIsAvailable -CmdletName 'Get-SafeAttachmentPolicy'
    try
    {
        $SafeAttachmentPolicies = Get-SafeAttachmentPolicy
    }
    catch
    {
        Close-SessionsAndReturnError -ExceptionMessage $_.Exception
    }

    $SafeAttachmentPolicy = $SafeAttachmentPolicies | Where-Object Identity -eq $Identity
    if (-NOT $SafeAttachmentPolicy)
    {
        Write-Verbose "SafeAttachmentPolicy $($Identity) does not exist."
        $result = $PSBoundParameters
        $result.Ensure = 'Absent'
        return $result
    }
    else
    {
        $result = @{
            Ensure = 'Present'
        }

        foreach ($KeyName in ($PSBoundParameters.Keys | Where-Object {$_ -ne 'Ensure'}) )
        {
            if ($null -ne $SafeAttachmentPolicy.$KeyName)
            {
                $result += @{
                    $KeyName = $SafeAttachmentPolicy.$KeyName
                }
            }
            else
            {
                $result += @{
                    $KeyName = $PSBoundParameters[$KeyName]
                }
            }
        }

        Write-Verbose "Found SafeAttachmentPolicy $($Identity)"
        Write-Verbose "Get-TargetResource Result: `n $($result | Out-String)"
        return $result
    }
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [Parameter()]
        [ValidateSet('Block', 'Replace', 'Allow', 'DynamicDelivery')]
        [System.String]
        $Action = 'Block',

        [Parameter()]
        [Boolean]
        $ActionOnError = $false,

        [Parameter()]
        [System.String]
        $AdminDisplayName,

        [Parameter()]
        [Boolean]
        $Enable = $false,

        [Parameter()]
        [Boolean]
        $Redirect = $false,

        [Parameter()]
        [System.String]
        $RedirectAddress,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $GlobalAdminAccount
    )
    Write-Verbose 'Entering Set-TargetResource'
    Write-Verbose 'Calling Connect-ExchangeOnline function:'
    Connect-ExchangeOnline -GlobalAdminAccount $GlobalAdminAccount -CommandsToImport '*SafeAttachmentPolicy'
    Write-Verbose 'Global ExchangeOnlineSession status:'
    Write-Verbose "$( Get-PSSession -ErrorAction SilentlyContinue | Where-Object Name -eq 'ExchangeOnline' | Out-String)"
    $CmdletIsAvailable = Confirm-ImportedCmdletIsAvailable -CmdletName 'Set-SafeAttachmentPolicy'
    $SafeAttachmentPolicyParams = $PSBoundParameters
    $SafeAttachmentPolicyParams.Remove('Ensure') | out-null
    $SafeAttachmentPolicyParams.Remove('GlobalAdminAccount') | out-null
    try
    {
        $SafeAttachmentPolicies = Get-SafeAttachmentPolicy
    }
    catch
    {
        Close-SessionsAndReturnError -ExceptionMessage $_.Exception
    }

    $SafeAttachmentPolicy = $SafeAttachmentPolicies | Where-Object Identity -eq $Identity
    if ('Present' -eq $Ensure )
    {
        if (-NOT $SafeAttachmentPolicy)
        {
            try
            {
                Write-Verbose "Creating SafeAttachmentPolicy $($Identity)."
                $SafeAttachmentPolicyParams += @{
                    Name = $SafeAttachmentPolicyParams.Identity
                }

                $SafeAttachmentPolicyParams.Remove('Identity') | out-null
                New-SafeAttachmentPolicy @SafeAttachmentPolicyParams
            }
            catch
            {
                Close-SessionsAndReturnError -ExceptionMessage $_.Exception
            }
        }
        else
        {
            try
            {
                Write-Verbose "Setting SafeAttachmentPolicy $Identity with values: $($SafeAttachmentPolicyParams | Out-String)"
                Set-SafeAttachmentPolicy @SafeAttachmentPolicyParams
            }
            catch
            {
                Close-SessionsAndReturnError -ExceptionMessage $_.Exception
            }
        }
    }
    elseif (('Absent' -eq $Ensure) -and ($SafeAttachmentPolicy))
    {
        Write-Verbose "Removing SafeAttachmentPolicy $($Identity) "
        try
        {
            Remove-SafeAttachmentPolicy -Identity $Identity -Confirm:$false -Force
        }
        catch
        {
            Close-SessionsAndReturnError -ExceptionMessage $_.Exception
        }
    }

    Write-Verbose 'Closing Remote PowerShell Sessions'
    $ClosedPSSessions = (Get-PSSession | Remove-PSSession)
    Write-Verbose 'Global ExchangeOnlineSession status: '
    Write-Verbose "$( Get-PSSession -ErrorAction SilentlyContinue | Where-Object Name -eq 'ExchangeOnline' | Out-String)"
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [Parameter()]
        [ValidateSet('Block', 'Replace', 'Allow', 'DynamicDelivery')]
        [System.String]
        $Action = 'Block',

        [Parameter()]
        [Boolean]
        $ActionOnError = $false,

        [Parameter()]
        [System.String]
        $AdminDisplayName,

        [Parameter()]
        [Boolean]
        $Enable = $false,

        [Parameter()]
        [Boolean]
        $Redirect = $false,

        [Parameter()]
        [System.String]
        $RedirectAddress,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $GlobalAdminAccount
    )
    Write-Verbose -Message "Testing SafeAttachmentPolicy for $($Identity)"
    $CurrentValues = Get-TargetResource @PSBoundParameters
    $ValuesToCheck = $PSBoundParameters
    $ValuesToCheck.Remove('GlobalAdminAccount') | out-null
    $TestResult = Test-Office365DSCParameterState -CurrentValues $CurrentValues `
        -DesiredValues $PSBoundParameters `
        -ValuesToCheck $ValuesToCheck.Keys
    if ($TestResult)
    {
        Write-Verbose 'Test-TargetResource returned True'
        Write-Verbose 'Closing Remote PowerShell Sessions'
        $ClosedPSSessions = (Get-PSSession | Remove-PSSession)
        Write-Verbose 'Global ExchangeOnlineSession status: '
        Write-Verbose "$( Get-PSSession -ErrorAction SilentlyContinue | Where-Object Name -eq 'ExchangeOnline' | Out-String)"
    }
    else
    {
        Write-Verbose 'Test-TargetResource returned False'
    }

    return $TestResult
}

function Export-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $GlobalAdminAccount
    )
    $result = Get-TargetResource @PSBoundParameters
    Write-Verbose 'Closing Remote PowerShell Sessions'
    $ClosedPSSessions = (Get-PSSession | Remove-PSSession)
    $result.GlobalAdminAccount = Resolve-Credentials -UserName $GlobalAdminAccount.UserName
    $content = "        EXOSafeAttachmentPolicy " + (New-GUID).ToString() + "`r`n"
    $content += "        {`r`n"
    $currentDSCBlock = Get-DSCBlock -Params $result -ModulePath $PSScriptRoot
    $content += Convert-DSCStringParamToVariable -DSCBlock $currentDSCBlock -ParameterName 'GlobalAdminAccount'
    $content += "        }`r`n"
    return $content
}

Export-ModuleMember -Function *-TargetResource