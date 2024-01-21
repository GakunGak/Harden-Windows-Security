Function Get-CommonWDACConfig {
    [CmdletBinding()]
    Param(
        [parameter(Mandatory = $false)][System.Management.Automation.SwitchParameter]$CertCN,
        [parameter(Mandatory = $false)][System.Management.Automation.SwitchParameter]$CertPath,
        [parameter(Mandatory = $false)][System.Management.Automation.SwitchParameter]$SignToolPath,
        [parameter(Mandatory = $false)][System.Management.Automation.SwitchParameter]$SignedPolicyPath,
        [parameter(Mandatory = $false)][System.Management.Automation.SwitchParameter]$UnsignedPolicyPath,
        [parameter(Mandatory = $false, DontShow = $true)][System.Management.Automation.SwitchParameter]$StrictKernelPolicyGUID,
        [parameter(Mandatory = $false, DontShow = $true)][System.Management.Automation.SwitchParameter]$StrictKernelNoFlightRootsPolicyGUID,
        [parameter(Mandatory = $false)][System.Management.Automation.SwitchParameter]$Open,
        [parameter(Mandatory = $false, DontShow = $true)][System.Management.Automation.SwitchParameter]$LastUpdateCheck
    )
    begin {
        # Importing the $PSDefaultParameterValues to the current session, prior to everything else
        . "$ModuleRootPath\CoreExt\PSDefaultParameterValues.ps1"

        # Assigning the path to the UserConfigurations.json file
        [System.IO.FileInfo]$Path = "$UserAccountDirectoryPath\.WDACConfig\UserConfigurations.json"

        # Create User configuration folder if it doesn't already exist
        if (-NOT (Test-Path -Path (Split-Path -Path $Path -Parent))) {
            New-Item -ItemType Directory -Path (Split-Path -Path $Path -Parent) -Force | Out-Null
            Write-Verbose -Message 'The .WDACConfig folder in the current user folder has been created because it did not exist.'
        }

        # Create User configuration file if it doesn't already exist
        if (-NOT (Test-Path -Path $Path)) {
            New-Item -ItemType File -Path (Split-Path -Path $Path -Parent) -Name (Split-Path -Path $Path -Leaf) -Force | Out-Null
            Write-Verbose -Message 'The UserConfigurations.json file has been created because it did not exist.'
        }

        if ($Open) {
            . $Path
            [System.Boolean]$ReturnAndDone = $true
            Return
        }

        # Display this message if User Configuration file is empty or only has spaces/new lines
        if ([System.String]::IsNullOrWhiteSpace((Get-Content -Path $Path))) {
            Write-Verbose -Message 'Your current WDAC User Configurations is empty.'
            # set a boolean value that returns from the Process and End blocks as well
            [System.Boolean]$ReturnAndDone = $true
            # return/exit from the begin block
            Return
        }

        Write-Verbose -Message 'Reading the current user configurations'
        [System.Object[]]$CurrentUserConfigurations = Get-Content -Path $Path -Force

        # If the file exists but is corrupted and has bad values, rewrite it
        try {
            [System.Collections.Hashtable]$CurrentUserConfigurations = $CurrentUserConfigurations | ConvertFrom-Json -AsHashtable
        }
        catch {
            Write-Warning -Message 'The UserConfigurations.json was corrupted, clearing it.'
            Set-Content -Path $Path -Value ''
            [System.Boolean]$ReturnAndDone = $true
            # return/exit from the begin block
            Return
        }
    }

    process {
        # return/exit from the process block
        if ($true -eq $ReturnAndDone) { return }

        # Remove any empty values from the hashtable
        @($CurrentUserConfigurations.keys) | ForEach-Object -Process {
            if (!$CurrentUserConfigurations[$_]) { $CurrentUserConfigurations.Remove($_) }
        }
    }

    end {
        # return/exit from the end block
        if ($true -eq $ReturnAndDone) { return }

        # Use a switch statement to check which parameter is present and output the corresponding value from the json file
        switch ($true) {
            $SignedPolicyPath.IsPresent { return ($CurrentUserConfigurations.SignedPolicyPath ?? $null) }
            $UnsignedPolicyPath.IsPresent { return ($CurrentUserConfigurations.UnsignedPolicyPath ?? $null) }
            $SignToolPath.IsPresent { return ($CurrentUserConfigurations.SignToolCustomPath ?? $null) }
            $CertCN.IsPresent { return ($CurrentUserConfigurations.CertificateCommonName ?? $null) }
            $StrictKernelPolicyGUID.IsPresent { return ($CurrentUserConfigurations.StrictKernelPolicyGUID ?? $null) }
            $StrictKernelNoFlightRootsPolicyGUID.IsPresent { return ($CurrentUserConfigurations.StrictKernelNoFlightRootsPolicyGUID ?? $null) }
            $CertPath.IsPresent { return ($CurrentUserConfigurations.CertificatePath ?? $null) }
            $LastUpdateCheck.IsPresent { return ($CurrentUserConfigurations.LastUpdateCheck ?? $null) }
            Default {
                # If no parameter is present
                Return $CurrentUserConfigurations
            }
        }
    }
    <#
.SYNOPSIS
    Query and Read common values for parameters used by WDACConfig module
.LINK
    https://github.com/HotCakeX/Harden-Windows-Security/wiki/Get-CommonWDACConfig
.DESCRIPTION
    Reads and gets the values from the User Config Json file, used by the module internally and also to display the values on the console for the user
.COMPONENT
    Windows Defender Application Control, ConfigCI PowerShell module, WDACConfig module
.FUNCTIONALITY
    Reads and gets the values from the User Config Json file, used by the module internally and also to display the values on the console for the user
.PARAMETER SignedPolicyPath
    Shows the path to a Signed WDAC xml policy
.PARAMETER UnsignedPolicyPath
    Shows the path to an Unsigned WDAC xml policy
.PARAMETER CertCN
    Shows the certificate common name
.PARAMETER SignToolPath
    Shows the path to the SignTool.exe
.PARAMETER CertPath
    Shows the path to a .cer certificate file
.PARAMETER Open
    Opens the User Configuration file with the default app assigned to open Json files
.PARAMETER StrictKernelPolicyGUID
    Shows the GUID of the Strict Kernel mode policy
.PARAMETER StrictKernelNoFlightRootsPolicyGUID
    Shows the GUID of the Strict Kernel no Flights root mode policy
.PARAMETER LastUpdateCheck
    Shows the date of the last update check
.PARAMETER Verbose
    Shows verbose messages
.INPUTS
    System.Management.Automation.SwitchParameter
.OUTPUTS
    System.Object[]
    System.DateTime
    System.String
    System.Guid
#>
}

# SIG # Begin signature block
# MIILkgYJKoZIhvcNAQcCoIILgzCCC38CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCB8scDw743FvNRg
# SVRHp4ncdlz+d6ZSFYQPG4yW4UyabaCCB9AwggfMMIIFtKADAgECAhMeAAAABI80
# LDQz/68TAAAAAAAEMA0GCSqGSIb3DQEBDQUAME8xEzARBgoJkiaJk/IsZAEZFgNj
# b20xIjAgBgoJkiaJk/IsZAEZFhJIT1RDQUtFWC1DQS1Eb21haW4xFDASBgNVBAMT
# C0hPVENBS0VYLUNBMCAXDTIzMTIyNzExMjkyOVoYDzIyMDgxMTEyMTEyOTI5WjB5
# MQswCQYDVQQGEwJVSzEeMBwGA1UEAxMVSG90Q2FrZVggQ29kZSBTaWduaW5nMSMw
# IQYJKoZIhvcNAQkBFhRob3RjYWtleEBvdXRsb29rLmNvbTElMCMGCSqGSIb3DQEJ
# ARYWU3B5bmV0Z2lybEBvdXRsb29rLmNvbTCCAiIwDQYJKoZIhvcNAQEBBQADggIP
# ADCCAgoCggIBAKb1BJzTrpu1ERiwr7ivp0UuJ1GmNmmZ65eckLpGSF+2r22+7Tgm
# pEifj9NhPw0X60F9HhdSM+2XeuikmaNMvq8XRDUFoenv9P1ZU1wli5WTKHJ5ayDW
# k2NP22G9IPRnIpizkHkQnCwctx0AFJx1qvvd+EFlG6ihM0fKGG+DwMaFqsKCGh+M
# rb1bKKtY7UEnEVAsVi7KYGkkH+ukhyFUAdUbh/3ZjO0xWPYpkf/1ldvGes6pjK6P
# US2PHbe6ukiupqYYG3I5Ad0e20uQfZbz9vMSTiwslLhmsST0XAesEvi+SJYz2xAQ
# x2O4n/PxMRxZ3m5Q0WQxLTGFGjB2Bl+B+QPBzbpwb9JC77zgA8J2ncP2biEguSRJ
# e56Ezx6YpSoRv4d1jS3tpRL+ZFm8yv6We+hodE++0tLsfpUq42Guy3MrGQ2kTIRo
# 7TGLOLpayR8tYmnF0XEHaBiVl7u/Szr7kmOe/CfRG8IZl6UX+/66OqZeyJ12Q3m2
# fe7ZWnpWT5sVp2sJmiuGb3atFXBWKcwNumNuy4JecjQE+7NF8rfIv94NxbBV/WSM
# pKf6Yv9OgzkjY1nRdIS1FBHa88RR55+7Ikh4FIGPBTAibiCEJMc79+b8cdsQGOo4
# ymgbKjGeoRNjtegZ7XE/3TUywBBFMf8NfcjF8REs/HIl7u2RHwRaUTJdAgMBAAGj
# ggJzMIICbzA8BgkrBgEEAYI3FQcELzAtBiUrBgEEAYI3FQiG7sUghM++I4HxhQSF
# hqV1htyhDXuG5sF2wOlDAgFkAgEIMBMGA1UdJQQMMAoGCCsGAQUFBwMDMA4GA1Ud
# DwEB/wQEAwIHgDAMBgNVHRMBAf8EAjAAMBsGCSsGAQQBgjcVCgQOMAwwCgYIKwYB
# BQUHAwMwHQYDVR0OBBYEFOlnnQDHNUpYoPqECFP6JAqGDFM6MB8GA1UdIwQYMBaA
# FICT0Mhz5MfqMIi7Xax90DRKYJLSMIHUBgNVHR8EgcwwgckwgcaggcOggcCGgb1s
# ZGFwOi8vL0NOPUhPVENBS0VYLUNBLENOPUhvdENha2VYLENOPUNEUCxDTj1QdWJs
# aWMlMjBLZXklMjBTZXJ2aWNlcyxDTj1TZXJ2aWNlcyxDTj1Db25maWd1cmF0aW9u
# LERDPU5vbkV4aXN0ZW50RG9tYWluLERDPWNvbT9jZXJ0aWZpY2F0ZVJldm9jYXRp
# b25MaXN0P2Jhc2U/b2JqZWN0Q2xhc3M9Y1JMRGlzdHJpYnV0aW9uUG9pbnQwgccG
# CCsGAQUFBwEBBIG6MIG3MIG0BggrBgEFBQcwAoaBp2xkYXA6Ly8vQ049SE9UQ0FL
# RVgtQ0EsQ049QUlBLENOPVB1YmxpYyUyMEtleSUyMFNlcnZpY2VzLENOPVNlcnZp
# Y2VzLENOPUNvbmZpZ3VyYXRpb24sREM9Tm9uRXhpc3RlbnREb21haW4sREM9Y29t
# P2NBQ2VydGlmaWNhdGU/YmFzZT9vYmplY3RDbGFzcz1jZXJ0aWZpY2F0aW9uQXV0
# aG9yaXR5MA0GCSqGSIb3DQEBDQUAA4ICAQA7JI76Ixy113wNjiJmJmPKfnn7brVI
# IyA3ZudXCheqWTYPyYnwzhCSzKJLejGNAsMlXwoYgXQBBmMiSI4Zv4UhTNc4Umqx
# pZSpqV+3FRFQHOG/X6NMHuFa2z7T2pdj+QJuH5TgPayKAJc+Kbg4C7edL6YoePRu
# HoEhoRffiabEP/yDtZWMa6WFqBsfgiLMlo7DfuhRJ0eRqvJ6+czOVU2bxvESMQVo
# bvFTNDlEcUzBM7QxbnsDyGpoJZTx6M3cUkEazuliPAw3IW1vJn8SR1jFBukKcjWn
# aau+/BE9w77GFz1RbIfH3hJ/CUA0wCavxWcbAHz1YoPTAz6EKjIc5PcHpDO+n8Fh
# t3ULwVjWPMoZzU589IXi+2Ol0IUWAdoQJr/Llhub3SNKZ3LlMUPNt+tXAs/vcUl0
# 7+Dp5FpUARE2gMYA/XxfU9T6Q3pX3/NRP/ojO9m0JrKv/KMc9sCGmV9sDygCOosU
# 5yGS4Ze/DJw6QR7xT9lMiWsfgL96Qcw4lfu1+5iLr0dnDFsGowGTKPGI0EvzK7H+
# DuFRg+Fyhn40dOUl8fVDqYHuZJRoWJxCsyobVkrX4rA6xUTswl7xYPYWz88WZDoY
# gI8AwuRkzJyUEA07IYtsbFCYrcUzIHME4uf8jsJhCmb0va1G2WrWuyasv3K/G8Nn
# f60MsDbDH1mLtzGCAxgwggMUAgEBMGYwTzETMBEGCgmSJomT8ixkARkWA2NvbTEi
# MCAGCgmSJomT8ixkARkWEkhPVENBS0VYLUNBLURvbWFpbjEUMBIGA1UEAxMLSE9U
# Q0FLRVgtQ0ECEx4AAAAEjzQsNDP/rxMAAAAAAAQwDQYJYIZIAWUDBAIBBQCggYQw
# GAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGC
# NwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQx
# IgQgcci4IleKz9D3ELexV2ZgwFb5q0tPXwCuFH1vh+hl5tQwDQYJKoZIhvcNAQEB
# BQAEggIAmMbSUG2ytAHbCHe9uIBR5mky5S1ZdG75MwMxfoO3Evs0II6Jpr+1nn3h
# p7MWUtvhsVjcipESslErq+KEpBiiPD6JlrCMXspekD7j8Rf4RbGaEdQNu+B8KaN+
# WPu1rwUJKMIKAkOffk6viq9J4putvXPJz6xv1q+Xn+B9mnq6bLbgQ9oinUexsC4j
# 6bhb3ClU6I1YYD1mRzmAvr8X5NGjFYRwCaAzsG5af3ug8+YVIFUI4Doey+pkYGFK
# HKMTpwh3sKgyB2b+cNKre8IVacP3IaD1DTfx9i1XuvW+uCtIdULAy2Ms3rV0Lj6y
# fIWfNRhLON7+ivwyFZcnQyFY8REJP53CU+o3DkZvS/tntkZSzkm6oLzNiO6xO3M9
# +64Z10aepoDsD7bKz++KQcmD6RCvf+YizZRRL3TQoaVwi8iZorCwBbkylgh21zMb
# X13T1n0L4gfhr4VV2gC5FzVcG93PXKBK5B05rs7s+u9ancHBW8ZFTR9u2SSLBGO5
# viSOz/wPQzV5YfWeZFyp/YctJeRPECejwDEArJJpYn3+8wQCnl0mn9Sde5f7mkdA
# JIe056KGigUSad0zU2d+enHvqwgBXU4XPJUe8Bzp54Wg9D0teaJFPkBZvna1FU+U
# M7kF2YNtSdlO4kDIRHe3/Jg+1j6nwJ1vDRJ0lJh4EwSAzi5288A=
# SIG # End signature block
