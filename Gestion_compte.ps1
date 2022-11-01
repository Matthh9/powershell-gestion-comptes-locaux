<#
Auteur :
Date :

#>


#Code trouv� ici : https://serverfault.com/questions/11879/gaining-administrator-privileges-in-powershell
#le Code permet de red�marrer un shell en admin pour effectuer les commandes sur les comptes parce que les commandes qui touchent aux comptes ont besoin d'�tre admin pour �tre lanc�es
if (!
    #current role
    (New-Object Security.Principal.WindowsPrincipal(
        [Security.Principal.WindowsIdentity]::GetCurrent()
    #is admin?
    )).IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator
    )
) {
    #elevate script and exit current non-elevated runtime
    Start-Process `
        -FilePath 'powershell' `
        -ArgumentList (
            #flatten to single array
            '-File', $MyInvocation.MyCommand.Source, $args `
            | %{ $_ }
        ) `
        -Verb RunAs
    exit
}



function afficher_choix {
    param (
        $Texte_intruductif,
        $options #tableau avec les diff�rents choix
    )
    $erreur="Erreur le choix n'est pas disponible : "

    #clear

    Write-Host $Texte_intruductif

    for($i = 0; $i -lt $options.length; $i++){ 
        Write-Host "  "$i" - " $options[$i] 
    }
    $choix = Read-Host "Choix"
    #Write-Host $choix " : " $options[$choix]

    if($options -contains $options[$choix]){
        return $choix
    } else { afficher_choix $erreur$Texte_intruductif $options }
}

function menu {
    $choix = afficher_choix "Choix d'une action" @('Cr�er un utilisateur', 'Modifier un utilisateur')

    Switch ($choix){
        0 {creation_user}
        1 {gestion_user}
    }
}


function creation_user {
    Write-Host "cr�ation d'un utilisateur"
}


function gestion_user {
    $get_user_resultat= Get-LocalUser
    $index_user= afficher_choix "Modification d'un utilisateur" $get_user_resultat
    $user= $get_user_resultat[$index_user]

    $modification = afficher_choix $info_user"Quelle modification voulez-vous effectuer ?" @("Password","renomer le compte","Description","Full name","desactiver/reactiver un compte","supprimer un compte")

    if($modification -eq 0){
        Write-Host "modification du MDP"

    }elseif($modification -eq 4){
        if($user.Enabled){ 
            Write-Host "D�sactivation du compte"
            Disable-LocalUser -Name $user
        }else{
            Write-Host "Activation du compte"
            Enable-LocalUser -Name $user
        }
    }elseif($modification -eq 5){
        Remove-LocalUser -Name $user
    }else{
        $new_value = Read-Host "Nouvelle valeur"
        Switch ($modification){
            1 {Rename-LocalUser -Name $user -NewName $new_value}
            2 {Set-LocalUser -Name $user -Description $new_value}
            3 {Set-LocalUser -Name $user -FullName $new_value}
        }
    }
}



menu "Bonjour, bienvenu dans l'utilitaire de gestion des comptes locaux"

#$Password = Read-Host -AsSecureString