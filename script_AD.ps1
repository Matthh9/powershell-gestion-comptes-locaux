$DC="badiou"
$DNS="local"
$DCExec=$DC+'.'+$DNS
$domaineMail='@'+$DCExec

$pathLog="C:\Users\Administrateur\Desktop\log"
$logFile="log.txt"

$fichierCSV="C:\Users\Administrateur\Desktop\user.csv"




if (Test-Path -Path $pathLog){
    Write-Host "dossier de log existant"
} else {
    New-Item -Force -Path $pathLog -ItemType Directory
}


if (Test-Path $pathLog'\'$logFile){
    Write-Host "fichier de log existant"
} else {
    Out-File $pathLog'\'$logFile -Encoding "UTF8"
}



Import-Module ActiveDirectory
if (Test-Path -Path $fichierCSV){
    $csv = Import-Csv -Path $fichierCSV -Header 'Prenom','Nom','Service','Titre','Tel','OU'
}


$listrOU = ("Utilisateurs", "Clients", "Servers")

foreach ($OU in $listrOU) {
    Write-Host "check pour OU : "$OU
    try{
        New-ADOrganizationalUnit -Name $OU -Path "DC=$DC,DC=$DNS"
        Write-Host "Creation de l'OU"
    } Catch { Write-Host "OU existante" }
}


#Creation des utilisateurs
foreach ($user in $csv) {
    Write-Host "Traitement du user : "$user
    $SamAccountName=($user.Prenom[0]+$user.Nom.Substring(0,$taile)).ToLower()

    #check si le compe existe pour le creer apres
    $accountSearch = $(try {Get-ADUser -Filter 'SamAccountName -like $SamAccountName' -SearchBase "DC=$DC,DC=$DNS"} catch {$null})
    If ($accountSearch -ne $Null) { 
        Write-Host "Utilisateur deja existant dans l'AD" 
    } Else {
        Write-Host "Utilisateur non existant dans l'AD, creation en cours" 
        #si le nom de l'user est trop petit
        if($user.Nom.Length -gt 5){
            $taile=5
        } else {
            $taile=$user.Nom.Length
        }

        
        $name=$user.Prenom+' '+$user.Nom
        $description="utilisateur "+$user.Service
        $path="OU="+$user.OU+", DC="+$DC+", DC="+$DNS


        New-ADUser -Name $name -GivenName $user.Prenom -Surname $user.Nom -SamAccountName $SamAccountName -EmailAddress $SamAccountName$domaineMail -DisplayName $SamAccountName -Description $description -Company $DC -Department $user.Service -OfficePhone $user.Tel -Title $user.Titre -Path $path
        $account= Get-ADUser -Filter 'SamAccountName -like $SamAccountName' -SearchBase "DC=$DC,DC=$DNS"

        $Secure_String_Pwd = ConvertTo-SecureString "P@ssW0rD!" -AsPlainText -Force
        Set-ADAccountPassword -Identity $account -NewPassword $Secure_String_Pwd

        Write-Host $account
        $account | Enable-ADAccount
    }
}
