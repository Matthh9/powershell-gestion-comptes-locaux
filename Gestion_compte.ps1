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

function mot_de_passe {
    param (
        $user
    )

    function saisie-mdp {
        #Construction de la fonction à l'aide des commandes de cette page :
        #https://morgantechspace.com/2018/05/how-to-get-password-from-user-with-mask-powershell.html

        $secure_mdp = Read-Host -Prompt "Entrer le mot de passe" -AsSecureString
        $secure_mdp2 = Read-Host -Prompt "Entrer le mot de passe à nouveau" -AsSecureString
    
        #la commande suivante permet de déchiffrer le mot de passe
        $plain_mdp = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto( [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure_mdp) )
        $plain_mdp2 = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto( [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure_mdp2) )


        if ($plain_mdp -cne $plain_mdp2){ #-c pour être case sensitive, ne pour not equal pour reboucler si les mot de passe ne correspondent pas après validation on relance la fonction pour avoir 2 mdp identiques
            $secure_mdp = saisie-mdp
        }
    
        return $secure_mdp #il faut retourner un secure string sinon ça tombe en erreur
    }

    $mdp = saisie-mdp
    Set-LocalUser -Name $user -Password $mdp
}


function afficher_choix {
    param (
        $Texte_intruductif,
        $options #tableau avec les différents choix
    )
    $erreur="Erreur le choix n'est pas disponible : "

    #clear

    Write-Host $Texte_intruductif

    for($i = 0; $i -lt $options.length; $i++){ 
        Write-Host "  "$i" - " $options[$i] 
    }
    $choix = Read-Host "Choix"

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
    Write-Host "création d'un utilisateur"

    $nom = Read-Host "Nom d'utilisateur"
    $description = Read-Host "Description du compte"
    $fullname = Read-Host "Nom complet du compte"
    $user = New-LocalUser -Name $nom -Description $description -FullName $fullname -NoPassword

    $choix = afficher_choix "Voulez-vous ajouter un mot de passe ?" @("Oui","Non")
    if($choix -eq 0){
        mot_de_passe $user
    }
}


function gestion_user {
    $get_user_resultat= Get-LocalUser
    $index_user= afficher_choix "Modification d'un utilisateur" $get_user_resultat
    $user= $get_user_resultat[$index_user]

    $modification = afficher_choix $info_user"Quelle modification voulez-vous effectuer ?" @("Password","renomer le compte","Description","Full name","desactiver/reactiver un compte","supprimer un compte")

    if($modification -eq 4){
        if($user.Enabled){ 
            Write-Host "Désactivation du compte"
            Disable-LocalUser -Name $user
        }else{
            Write-Host "Activation du compte"
            Enable-LocalUser -Name $user
        }
    }else{
        $new_value = Read-Host "Nouvelle valeur"
        Switch ($modification){
            0 {mot_de_passe $user}
            1 {Rename-LocalUser -Name $user -NewName $new_value}
            2 {Set-LocalUser -Name $user -Description $new_value}
            3 {Set-LocalUser -Name $user -FullName $new_value}
            5 {Remove-LocalUser -Name $user}
        }
    }
}



menu "Bonjour, bienvenu dans l'utilitaire de gestion des comptes locaux"