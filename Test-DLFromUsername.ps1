Function Test-DLFromUsername {

        param (

        $TemplatePath       

        )

        Begin{



                              $Display = Import-Csv $TemplatePath | select Display |  % {$_.Psobject.properties.value} | where {$_}

                              $Owner = Import-Csv $TemplatePath | select Owner  |  % {$_.Psobject.properties.value} | where {$_}

                              $Editor =import-csv $TemplatePath | select Editor | % {$_.Psobject.properties.value} | where {$_}

                              $GroupMembers = Import-Csv $TemplatePath | select Groupmembers  |  % {$_.Psobject.properties.value} | where {$_}

                              $SenderScope = Import-Csv $TemplatePath | select SenderScope  | % {$_.Psobject.properties.value} | where {$_}

                              $PrimarySmtpAddress = Import-Csv $TemplatePath | select PrimarySmtpAddress |  % {$_.Psobject.properties.value} | where {$_}



                              $Display = foreach($line in $Display) {$line.ToString().split("\")}

                              $Owner = foreach($line in $Owner) {$line.ToString().split("\")}

                              $Editor = foreach($line in $Editor) {$line.ToString().split("\")}

                              $GroupMembers = foreach($line in $Groupmembers) {$line.ToString().split("\")}

                              $SenderScope  = foreach($line in $SenderScope ) {$line.ToString().split("\")}

                              $PrimarySmtpAddress = foreach($line in $PrimarySmtpAddress) {$line.ToString().split("\")}

                               }



                            Process{

                                       



                                      if($null -ne $Display){

                                        if(Get-ADGroup $Display) {Write-Output "Display status:";  Write-Output "   This DisplayName is already in use"}

                                            else {Write-Output "Displayname good to go"  }

                                                  }

                                              else { 

                                                Write-Host "The DisplayName is Mandatory"        

                                              }



                                     



                                       Write-Output "Owner: " 

                                            if($Owner.Lenght -le 3){ Get-ADUser -server $Owner[0] -Identity $Owner[1] -pro * | select mail | % {$_.Psobject.properties.value}} 

                                            else { Write-Output "Owner is: " Write-Output "   There must be only ine owner"}



                                     



                                                                              

                                      Write-Output "Editors: "  

                                            If($Editor.length -gt 2 ) { for($i -eq 0; $i -le $Editor.Length; $i++){Get-ADUser -Server $EditorsDomain[$i] -Identity $EditorsUsers[$i] -pro * | select mail | % {$_.Psobject.properties.value} }

                                             }

                                            else{Get-ADUser -Server $Editor[0] -Identity $Editor[1] -pro * | select mail | % {$_.Psobject.properties.value}  }

                                       





                                       

                                       If ($GroupMembers.Length -le 2) {$GroupMembersEmails = get-aduser -server $GroupMembersDomain[$i] -Identity $GroupMembersUsers[$i] -Properties * | select mail | % {$_.PSobject.properties.value}}   

                                          else {$GroupMembersDomain = for ($i = 0; $i -le $GroupMembers.length -1; $i += 2) {

                                                                                                                    $GroupMembers[$i]

                                                                                                                  }     

       

                                                    $GroupMembersUsers = for ($i = 1; $i -le $GroupMembers.length -1; $i += 2) {

                                                                                                                    $GroupMembers[$i]

                                                                                                              }

                                                    $GroupMembersEmails = for($i = 0; $i -le ($GroupMembersUsers.Length -1); $i++) {get-aduser -server $GroupMembersDomain[$i] -Identity $GroupMembersUsers[$i] -Properties * | select mail | % {$_.PSobject.properties.value}}



                            

          

      

      

                                      $GroupMembersEmails = foreach($mail in $GroupMembersEmails)  {"   $mail;"} 



                                      Write-Output "Groupmembers: "

                                      Write-Output $GroupMembersEmails

                                      

                                      switch ($Senderscope) {

                                         {$SenderScope.ToLower()  -eq "internal"} {Write-Output "DL scope:"; Write-Output "   This DL will be $SenderScope" }

                                         {$SenderScope.ToLower()  -eq "external"} {Write-Output "DL scope:"; Write-Output "   This DL will be $SenderScope"}

                                          Default {Write-Output "DL scope:"; Write-Output "   This field is invalid "}

                                            } 

      

     

                                            }



        

                                   }

    }

      
