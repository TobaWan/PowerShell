function Invoke-CleanTemp {
    <#
        .Synopsis
            Will clean local temp folders

        .Description
            Will clean local temp folders

        .Parameter Force
            Closes running programs from the application array in the function

        .Example
            PS C:\> Invoke-CleanTemp
            Will start the function and try to delete files and folder in the current users temp and
            in the C:\Windows\Temp folder.

        .Example
            PS C:\> Invoke-CleanTemp -Force
            Will start the function and closing the applications that are in the applications array
            and then tries to delete files and folder in the current users temp and
            in the C:\Windows\Temp folder.

        .Notes
            NAME:      	Invoke-CleanTemp
            AUTHOR:    	Fredrik Wall, fredrik@poweradmin.se
            BLOG:		https://www.fredrikwall.se
            TWITTER:	walle75
            CREATED:    04/07/2010
            LASTEDIT:  	26/11/2020
            CHANGES:   	04/07/2010  -   Added support for closing Chrome and Tweetdeck
                        30/09/2010  -   Added support for closing Skype, Spotify, iTunes and Safari
                        26/11/2020  -   Changed parameter name to Force for closing applications
                                        Added and removed applications to close
                                        Added support for WhatIf to show what the function will do if the parameter is used

    #>
    #Requires -RunAsAdministrator
    [Cmdletbinding(SupportsShouldProcess)]
    param (
        [Parameter()]
        [Switch]
        $Force
    )
    
    if ($Force) {
        $ApplicationsToStop = "iexplore", "outlook", "word", "excel", "chrome", "skype", "lync", "spotify", "itunes", "safari", "firefox", "teams"
        $ApplicationsToStop | Foreach-Object {
            $Application = (Get-Process $_ -ErrorAction SilentlyContinue).Name
            if ($Application) {
                $Application = ($Application | Get-Unique).ToLower()
                
                if ($PSCmdlet.ShouldProcess($Application, 'Closing Application')) {
                    Stop-Process -Name $Application -Force 
                }
                else {
                }
            }
        }
    }
    
    # Users temp folder
    $UsersTempFolderFilesAndFolders = Get-ChildItem $Env:temp -Recurse
    $UsersTempFolderFilesAndFoldersCount = $UsersTempFolderFilesAndFolders.Count
    $UsersTempFolderFilesAndFoldersSize = ($UsersTempFolderFilesAndFolders | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum / 1MB

    if ($PSCmdlet.ShouldProcess("$Env:Temp ($UsersTempFolderFilesAndFoldersCount files and folders) ($UsersTempFolderFilesAndFoldersSize MB)", 'Remove')) {
        $UsersTempFolderFilesAndFolders | Remove-Item -Recurse -ErrorAction SilentlyContinue -Confirm:$false -Force
    }
    else {
    }
    
    # Windows temp folder
    $WindowsTempFolderFilesAndFolders = Get-ChildItem "C:\Windows\Temp" -Recurse -ErrorAction SilentlyContinue
    $WindowsTempFolderFilesAndFoldersCount = $WindowsTempFolderFilesAndFolders.Count
    $WindowsTempFolderFilesAndFoldersSize = ($WindowsTempFolderFilesAndFolders | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum / 1MB
    
    if ($PSCmdlet.ShouldProcess("C:\Windows\Temp ($WindowsTempFolderFilesAndFoldersCount files and folders) ($WindowsTempFolderFilesAndFoldersSize MB)", 'Remove')) {
        $WindowsTempFolderFilesAndFolders | Remove-Item -Recurse -ErrorAction SilentlyContinue -Confirm:$false -Force
    }
    else {
    }
}
    
Clear-Host

# To run the function to remove files and folders you need to take away -WhatIf
Invoke-CleanTemp -Force -WhatIf

#Get-Help Invoke-CleanTemp -Full