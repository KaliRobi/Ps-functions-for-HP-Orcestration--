<#the following script is the first version of the SomeCompany's  Test-DLFromEmails function for the Distribution List creation process automated by the HP orchestartion tool.
Further features are under progress. Coming soon: this function corrects invalid data input, but we also need to validate the correct ones before we enter them into the tool to avoid errors.
With one boolean argument the script will be able to process those too. #>

function Test-DLFromEmails {



    #[CmdletBinding(DefaultParameterSetName = 'DefParSet')]



    param(

        [CmdletBinding(DefaultParameterSetName = 'DefParSet')]

        [# this is the absolute path of the distrubtion template on any given loaction

        Parameter(

        Position = 0,

        Mandatory=$True,

        ParameterSetName= "DefParSet")]

        [string[]]

        $TemplatePath, 

        # in this environment there are 20+ subdomain. the performace is better if we set the domains manually. 
        [

        Parameter(

        Position = 1,

        Mandatory= $True,

        ParameterSetName= "DefParSet")]

        [Array[]]

        $Domains 

        )

    Begin{

            $CustomDomains = @()    

            foreach ($dom in $Domains) {

                $CustomDomains += $dom

            }

            
            #extracting values from the DL

            $NewTemplate = Import-Csv -Path $TemplatePath 

            # in this section all value lines up into an array. Regardless of the expected cell number most of the  keys are going thru simiar process    

            $Display = @()

            foreach($item in $NewTemplate.getenumerator())  {

                $Display += "$($item.Display) $($item.Value)"

            }   
            #checking the lengh to make sure there is only one owner set
 
            if($Display[0].Length -lt 3) {Write-Host "There must be a Displayname."}

            elseif ($Display[1].Length -gt 1) {Write-Host "There must be only one displayname."                    

            } else {Write-Host "The displayName : "$($Display[0])" "}

                

            $Owner = @()

            foreach($item in $NewTemplate.GetEnumerator()) {

                $Owner += "$($item.Owner) $($item.value)"

            }

            #applying the same check, if more or less than one item is longer than '' then it is considered as incorrect input           

            if ($Owner[0].Length -lt 7 ){Write-Host "There must be an Owner."}

            elseif ($Owner[1].Length -gt 1) {Write-Host "There must be only one Owner"}

            else {Write-Host "There is an Owner: " $($Owner)}

            $Owner = foreach($i in $Owner) {$i.trim(" ")}


            $Editor = @()

            foreach($item in $NewTemplate.GetEnumerator()) {

                $Editor += "$($item.Editor) $($item.value)"

            }

            $Editor = foreach($i in $Editor) {$i.trim(" ")}



            $Groupmembers = @()

            foreach($item in $NewTemplate.GetEnumerator()) {

                $Groupmembers += "$($item.Groupmembers) $($item.value)"

            }

            $Groupmembers = foreach($i in $Groupmembers) {$i.trim(" ")}



            $SenderScope = @()

            foreach ($item in $NewTemplate.GetEnumerator()) { 

                 $SenderScope += "$($item.SenderScope) $($item.value)"

            }

            $SenderScope= foreach($i in $SenderScope) {$i.trim(" ")}



            $PrimarySmtpAddress = @()

            foreach ($item in $NewTemplate.GetEnumerator()) {

                $PrimarySmtpAddress += "$($item.PrimarySmtpAddress) $($item.value)"

            }    

            $PrimarySmtpAddress = foreach($i in $PrimarySmtpAddress) {$i.trim(" ")}

        }

                 # at this point all the necesary data is extracted 

    Process{

                    #first invalid addresses  are separarated from the ones which good to go

                    $ValidGroupmembers =  @()

                    foreach($member in $Groupmembers) { foreach($Domain in $CustomDomains)

                            { 

                                $ValidMember = Get-ADUser   -Server  $Domain     -f{mail -like  $member}  -pro * | select mail | % {$_.Psobject.properties.value};

                                $ValidGroupmembers += $ValidMember}}

                                     

                                    

                     # if it was not able to find the email address  it wont be in the VAlidgroupmembers array.
                     # Comparing the two arrays and assigning it to a new one. This is the data which requires further processing     

                    $InvalidGroupMembers = compare $ValidGroupmembers $Groupmembers -PassThru


                    # Since the hp tool needs the mails separated by ; here the mails are prepared for that, the user just meeds to pass this list to the hp tool
                    $ValidGroupmembers  =  foreach($member in $ValidGroupmembers) {" $member;"}

                    Write-Output "The Valid mail addresses:"

                    $ValidGroupmembers

                                



                      # One way to find those addresses which were not in  the AD is by finding their owner by name. Spliting the name in the address because usualy this part is correct

                    $offers = @()

                    $names = @()

                    foreach ($InValidMember in $InvalidGroupMembers) {

                            $GivenName = $InValidMember.Replace('@', '.').Split('.')[0]; 

                            $SurName = $InValidMember.Replace('@', '.').Split('.')[1];

                    #when the first and last name is extracted, the script first looks for the users with the same last name on that domain then filters out the ones who have the wanted first name. When a candidate user is found it gets his/her emailadress if it is possible.

                            foreach($Domain in $CustomDomains)  

                                        {$offer = Get-ADUser -server $Domain -Filter{SurName -like $SurName} -pro * | where {$_.GivenName -like $GivenName}  | select mail | % {$_.Psobject.properties.value}; $offers += $offer ; $names += "$($GivenName) $($Surname)" }}

                    #still there will be users who cannot be found like this because for example the last name inclueds number. So the unique names are listed here too.       

                            Write-Output "Emails were not valid for the following names: "

                            $NotValidNames = $names | sort -Unique

                            $NotValidNames 

                    # the found candiate email adresses are listed here

                            Write-Output "Based on first and last name these are the suggestions for these (the missing needs manual search): " 

                            $offers

                            
                    # senderscope, only internal or external uses. only two values are valid 
                            if ($SenderScope[0].ToLower() -eq 'internal') {Write-Output "The SenderScope is Internal"} 

                            elseif ($SenderScope[0].ToLower() -eq 'external') { Write-Output "the SenderScope is external" }

                            else{ Write-Output "Invalid Value" }

    } 


}

