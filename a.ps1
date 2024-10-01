param (
    [switch]$f = $false
)
$search=$args[0]

$pulled=apull.ps1 $search -all

Foreach ($p in $pulled)
{
    if ($f){
        adis -f $p
    }
    else
    {
        adis $p
    }
}
