function Test-DLDromEmails {

    param(
        [# this is the absolute path of the distrubtion template on any given loaction
        Parameter(Mandatory=$True,
        ParameterSetName= "path")]
        [string[]]
        $TemplatePath

        <#[# Parameter for the domain array latter can be set to have a param which just have all the domians
        Parameter(Mandatory= $False,
        ParameterSetName= "CustomDomains")]
        [string[]]
        $CustomDomains
      #>

        )
    Begin{
            $CustomDomains = 'dummydomain', 'dummydomain'
            #extracting values from the DL
            $NewTemplate = Import-Csv -Path $TemplatePath 
            #Write-Host $NewTemplate | fl
    #display extract    
            $Display = @()
            foreach($item in $NewTemplate.getenumerator())  {
                $Display += "$($item.Display) $($item.Value)"
            }   
     #display leng check. As the array lenght allways equals with the longest comun's lenght in the csv
     # it is checking if there us a seconf item which is longer than 1 '' character.
     # if it is longer then sends the info that there are more than on displays       
                if($Display[0].Length -lt 3) {Write-Host "There must be a Displayname."}
                elseif ($Display[1].Length -gt 1) {Write-Host "There must be only one displayname."                    
                } else {Write-Host "there is a displayname"}
                
    # extracting owner data
            $Owner = @()
            foreach($item in $NewTemplate.GetEnumerator()) {
                $Owner += "$($item.Owner) $($item.value)"
            }
     #applying the same check, if more or less than one item is longer than '' then it is considered as incorrect input           
                if ($Owner[0].Length -lt 7 ){Write-Host "There must be an Owner."}
                elseif ($Owner[1].Length -gt 1) {Write-Host "There must be only one Owner"}
                else {Write-Host "there is an Owner"}

      # all the rest attributum of the dl is extracted
      # may beneficial to add quantity based behaviour flow. if something is empty that part wont run          
              
            $Editor = @()
            foreach($item in $NewTemplate.GetEnumerator()) {
                $Editor += "$($item.Editor) $($item.value)"
            }

            $Groupmembers = @()
            foreach($item in $NewTemplate.GetEnumerator()) {
                $Groupmembers += "$($item.Groupmembers) $($item.value)"
            }

            $SenderScope = @()
            foreach ($item in $NewTemplate.GetEnumerator()) { 
                 $SenderScope += "$($item.SenderScope) $($item.value)"
            }


            $PrimarySmtpAddress = @()
            foreach ($item in $NewTemplate.GetEnumerator()) {
                $PrimarySmtpAddress += "$($item.PrimarySmtpAddress) $($item.value)"
                
            }    
    }

    Process{
          #how to make it possible to check if find the email address but if does not
            #retrun the firts and last name, cehcek it in ad and the offer it as solution


            # checks for the emailaddress in ad.
                    #when it finds it, it returns it
                    #when does not splits the emailaddress to dirst and last name and tries to find it
                                #when it does not find it on the default server it takes the provided custom servers.
            for($i = 0; $i -le $CustomDomains.Length; $i++) {
                $CustomDomains = 'dummydomain', 'dummydomain'
                $CurrentDomain = $CustomDomains[$i]
                $CurrentMember = $Groupmembers[$i]
                $GivenName = $CurrentMember.Replace('@', '.').Split('.')[0]
                $SurName = $CurrentMember.Replace('@', '.').Split('.')[1]        
                #if (
                    write-host $CustomDomains[$i]
                    Get-ADUser -Server   $CustomDomains[$i] -f{mail -like $CurrentMember} 
                    #) {
                    #write-host $CurrentMember
                 #   }
      #              else {for($i = 0; $i -le  $CustomDomains.Length; $i++){Get-ADUser -server $CurrentDomain -Filter{SurName -like $SurName} -pro * | where {$_.$GivenName -like $GivenName}  | select mail}
                    #      }
                        
                                                            }
            
            
            }

    

   

    }


