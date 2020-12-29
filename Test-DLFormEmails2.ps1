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
         #trim the input 

        #$Groupmembers = foreach($i in $Groupmembers) {$i.trim(" ")}

                      #VAlidates the email addresses against the AD 

                                

                    # $ValidGroupmembers =  foreach($member in $Groupmembers) {foreach($Domain in $CustomDomains)

                    #      { Get-ADUser   -Server  $Domain     -f{mail -like  $member}  -pro * | select mail | % {$_.Psobject.properties.value} }}

                    $ValidGroupmembers =  @()

                    foreach($member in $Groupmembers) { foreach($Domain in $CustomDomains)

                            { 

                                $ValidMember = Get-ADUser   -Server  $Domain     -f{mail -like  $member}  -pro * | select mail | % {$_.Psobject.properties.value};

                                $ValidGroupmembers += $ValidMember}}

                                     

                                    

                     # if it was not able to find the email address  it wont be in the VAlidgroupmembers array. Comparing the two arrays and assigning it to a new one          

                    $InvalidGroupMembers = compare $ValidGroupmembers $Groupmembers -PassThru



                    $ValidGroupmembers  =  foreach($member in $ValidGroupmembers) {" $member;"}

                    Write-Output "The Valid mail addresses:"

                        $ValidGroupmembers

                                



                      # One way to find these users is by finding them by name. First we get the name by spliting

                    $offers = @()

                    foreach ($InValidMember in $InvalidGroupMembers) {

                            $GivenName = $InValidMember.Replace('@', '.').Split('.')[0]; 

                            $SurName = $InValidMember.Replace('@', '.').Split('.')[1];

                            

                            foreach($Domain in $CustomDomains)  

                                        {$offer = Get-ADUser -server $Domain -Filter{SurName -like $SurName} -pro * | where {$_.GivenName -like $GivenName}  | select mail | % {$_.Psobject.properties.value; $offers += $offer}}}

                    Write-Host: "Incorrect emails have been found. Based on first and last name these are the suggestions:" 

                    $offers



            

                     #   foreach($Domain in $CustomDomains)

                     #           {$Membersuggestion = Get-ADUser -server $Domain -Filter{SurName -like $SurName} -pro *| where {$_.GivenName -like $GivenName } | select mail | % {$_.psobject.properties.value}

                     #             Write-Host "  $Membersuggestion" }
                        
                                                            }
            
            
            }

    

   

    }


