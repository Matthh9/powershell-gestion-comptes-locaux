<#
Auteur :
Date :

#>

#Requires -RunAsAdministrator

function afficher_choix {
    param (
        $Texte_intruductif,
        $options
    )
    $erreur="Erreur le choix n'est pas disponible : "

    clear

    Write-Host $Texte_intruductif -ForegroundColor Green

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
    $choix = afficher_choix "Choix d'une action" @('Créer un utilisateur', 'Modifier un utilisateur')

    Switch ($choix){
        0 {creation_user}
        1 {gestion_user}
    }
}


function creation_user {
    clear
    Write-Host "création d'un utilisateur" -ForegroundColor Green
}


function gestion_user {
    $get_user_resultat = Get-LocalUser
    $choix = afficher_choix "modification d'un utilisateur" $get_user_resultat

    #on fait ça parce que la fonction selectionner_user retourn la valeur en double

    Write-Host "user returné" $choix
            

}



menu "Bonjour, bienvenu dans l'utilitaire de gestion des comptes locaux"

#$Password = Read-Host -AsSecureString