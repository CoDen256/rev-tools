$first=$args[0]
if ($first -eq $null)
{
    Write-Host "No args"
    exit 1
}

Write-Host "Creating a git repo in $first"
cd $first
cp $HOME/tools/.gitignore.example .gitignore
Write-Host "Copied .gitignore"
Write-Host "Running: git init ."
git init .
Write-Host "Running: git config core.autocrlf false"
git config core.autocrlf false
git config feature.manyFiles true
Write-Host "Running: git add ."
git add .
Write-Host "Running: commit -m 'init'"
git commit -m "init"
Write-Host "Openning studio and code"
code .
studio .
cd ..