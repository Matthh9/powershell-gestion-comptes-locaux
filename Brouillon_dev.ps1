function test{
    param (
        $test2
    )

    Write-Host "Erreur le choix n'est pas disponible : "
    $temp = (& $test2)
    $temp
}

function Hello ($in) {
     
    write-Host "Hello $in"
}

function dev{
    Write-Host "test de commande en paramètre"
}


function exec-script ($func, $parm, $autre) {
       
    #Invoke-Expression $file    
       
    $x = (& $func $parm)
       
    Write-Host $x

        
    }

Write-Host "début"
#test "Write-Host 'test de commande en paramètre'"
Write-Host "fin"

exec-script -func "Write-Host" -parm " Hello World"
exec-script  "Get-LocalUser" "Test"