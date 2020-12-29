# Ps-functions-for-HP-Orcestration
Creating Distribution List with thore HP orchestrator does not allow tests which causes many failed attempts while the analyst needs to stay until the script runs to be sure that the task is done.   

  

Workflow: 

User who needs a new distribution list send a request to the SD. 

Template is provided for the user to list the group members’ email addresses, required display name, owner, editor etc 

The specifications says that the input needs to be in an email format in all the fileds. Which almost never happens. We either receive only names, usernames or data copy pasted from Outlook “To” field. 

The listed powershell meant to be an automated response for this issue, saving time, and probably life too when one needs to get 100 email addresses from 100 username in a multidomain environment that is a killer. 

 

Test-DLFromuserName:  complete, tested 

Get-DLFromEmails: under development  
