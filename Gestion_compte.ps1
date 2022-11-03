<#
Auteur :
Date :

#>


#Code trouvé ici : https://serverfault.com/questions/11879/gaining-administrator-privileges-in-powershell
#le Code permet de redémarrer un shell en admin pour effectuer les commandes sur les comptes parce que les commandes qui touchent aux comptes ont besoin d'être admin pour être lancées
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





function texte_non_vide{
    param (
        $texte
    )

    while ($texte -eq ""){
        $texte = Read-Host "Désolé le choix ne peux pas être nul"
    }
    return $texte
}


function mot_de_passe {
    param (
        $user
    )

    function saisie-mdp {
        param (
            $messageErreur
        )

        #Construction de la fonction à l'aide des commandes de cette page :
        #https://morgantechspace.com/2018/05/how-to-get-password-from-user-with-mask-powershell.html

        $secure_mdp = Read-Host -Prompt $messageErreur"Entrer le mot de passe" -AsSecureString
        $secure_mdp2 = Read-Host -Prompt "Entrer le mot de passe à nouveau" -AsSecureString
    
        #la commande suivante permet de déchiffrer le mot de passe
        $plain_mdp = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto( [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure_mdp) )
        $plain_mdp2 = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto( [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure_mdp2) )

        if ($plain_mdp -cne $plain_mdp2){ #-c pour être case sensitive, ne pour not equal pour reboucler si les mot de passe ne correspondent pas après validation on relance la fonction pour avoir 2 mdp identiques
            $secure_mdp = saisie-mdp "Erreur les mot de passe ne correspondent pas : "
        }
    
        return $secure_mdp #il faut retourner un secure string sinon ça tombe en erreur quand on essaye de passer la commande : Set-LocalUser -Name $user -Password $mdp
    }

    $mdp = saisie-mdp
    Set-LocalUser -Name $user -Password $mdp
}


function afficher_choix {
    param (
        $texte_intruductif,
        $options, #tableau avec les différents choix
        $messageErreur,
        $non_vide = $false
    )

    clear

    if($messageErreur.Length){
        Write-Host $messageErreur
    }
    Write-Host $texte_intruductif

    for($i = 0; $i -lt $options.length; $i++){ 
        Write-Host "  "$i" - " $options[$i] 
    }
    $choix = Read-Host "Choix"

    if($non_vide){
        $choix = texte_non_vide $choix
    }

    if($options -contains $options[$choix]){
        return $choix
    } else { afficher_choix $texte_intruductif $options "Erreur : la sélection ne fait pas partie du choix possible"}
}


function creation_user {
    clear
    Write-Host "Création d'un utilisateur"

    $nom = Read-Host "Nom d'utilisateur"
    $nom = texte_non_vide $nom
    $description = Read-Host "Description du compte"
    $fullname = Read-Host "Nom complet du compte"
    $user = New-LocalUser -Name $nom -Description $description -FullName $fullname -NoPassword

    $choix = afficher_choix "Voulez-vous ajouter un mot de passe ?" @("Oui","Non") -non_vide $true
    if($choix -eq 0){
        mot_de_passe $user
    }

    $choix = afficher_choix "Ajouter dans un Nouveau groupe ou groupe Existant ?" @("Nouveau groupe","Groupe existant") -non_vide $true
    if($choix -eq 0){
        $nom_groupe = Read-Host "Nom du nouveau groupe"
        $description_groupe = Read-Host "Description du nouveau groupe"

        Add-LocalGroupMember -Group $nom_groupe -Member $user
    }else{
        Write-Host "use :r"$user
        $get_groupe_resultat = Get-LocalGroup
        $index_goupe= afficher_choix "Choix du groupe à ajouter" $get_groupe_resultat
        $groupe= $get_groupe_resultat[$index_goupe]
        Add-LocalGroupMember -Group $groupe -Member $user
    }

}


function gestion_user {
    $get_user_resultat= Get-LocalUser
    $index_user= afficher_choix "Modification d'un utilisateur" $get_user_resultat -non_vide $true
    $user= $get_user_resultat[$index_user]

    $modification = afficher_choix $info_user"Quelle modification voulez-vous effectuer ?" @("Password","renomer le compte","Description","Full name","desactiver/reactiver un compte","supprimer un compte") -non_vide $true

    # traitement à part des cas particuliers
    if($modification -eq 0){
        mot_de_passe $user
    }elseif($modification -eq 5){
        Remove-LocalUser -Name $user
    }elseif($modification -eq 4){
        if($user.Enabled){ 
            Write-Host "Désactivation du compte"
            Disable-LocalUser -Name $user
        }else{
            Write-Host "Activation du compte"
            Enable-LocalUser -Name $user
        }
    #traitement des autres cas qui peuvent être traités de la même manière
    }else{
        $new_value = Read-Host "Nouvelle valeur"
        Switch ($modification){
            1 {Rename-LocalUser -Name $user -NewName $new_value}
            2 {Set-LocalUser -Name $user -Description $new_value}
            3 {Set-LocalUser -Name $user -FullName $new_value}
        }
    }
}


function menu {
    $choix = afficher_choix "Choix d'une action" @('Créer un utilisateur', 'Modifier un utilisateur') -non_vide $true

    Switch ($choix){
        0 {creation_user}
        1 {gestion_user}
    }
}


clear
menu "Bonjour, bienvenu dans l'utilitaire de gestion des comptes locaux"