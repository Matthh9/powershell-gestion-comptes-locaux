<#
Auteur :
Date :

#>

#Requires -RunAsAdministrator

function menu {
    param (
        $Texte_intruductif
    )
    clear

    Write-Host $Texte_intruductif -ForegroundColor Green

    #Write-Host ("Voulez-vous :","1 - créer un compte") -Separator "`n  " -ForegroundColor Green
    $choix = Read-Host "Voulez-vous :`n  1 - Créer un compte`n  2 - Gestion des comptes`nChoix"

    Switch ($choix){
    1 {creation_user}
    2 {"Cat is Mentioned"}
    default {menu "Désolé, le choix effectué ne correspond à aucun scénario"}
    }

}


function creation_user {
    clear
    Write-Host "création d'un utilisateur" -ForegroundColor Green
}



menu "Bonjour, bienvenu dans l'utilitaire de gestion des comptes locaux"

#$Password = Read-Host -AsSecureString