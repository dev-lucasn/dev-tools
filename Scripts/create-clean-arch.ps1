$solutionName = Read-Host "Digite o nome da solução"
if ([string]::IsNullOrWhiteSpace($solutionName)) {
    Write-Host "Nome da solução não pode estar vazio."
    exit
}

$projectType = Read-Host "Tipo de projeto principal (api/worker)"
$projectType = $projectType.ToLower()

if ($projectType -ne "api" -and $projectType -ne "worker") {
    Write-Host "Tipo inválido. Use 'api' ou 'worker'."
    exit
}

$baseDir = Join-Path $PWD $solutionName
New-Item -ItemType Directory -Path $baseDir -Force | Out-Null
Set-Location -Path $baseDir

dotnet new sln -n $solutionName

dotnet new classlib -n "$solutionName.Core"
dotnet new classlib -n "$solutionName.Application"
dotnet new classlib -n "$solutionName.Infrastructure"

if ($projectType -eq "api") {
    dotnet new webapi -n "$solutionName.API" --no-https
    $mainProject = "$solutionName.API"
}
else {
    dotnet new worker -n "$solutionName.Worker"
    $mainProject = "$solutionName.Worker"
}

dotnet sln add "$solutionName.Core\$solutionName.Core.csproj"
dotnet sln add "$solutionName.Application\$solutionName.Application.csproj"
dotnet sln add "$solutionName.Infrastructure\$solutionName.Infrastructure.csproj"
dotnet sln add "$mainProject\$mainProject.csproj"

dotnet add "$solutionName.Application\$solutionName.Application.csproj" reference `
    "$solutionName.Core\$solutionName.Core.csproj"

dotnet add "$solutionName.Infrastructure\$solutionName.Infrastructure.csproj" reference `
    "$solutionName.Application\$solutionName.Application.csproj" `
    "$solutionName.Core\$solutionName.Core.csproj"

dotnet add "$mainProject\$mainProject.csproj" reference `
    "$solutionName.Infrastructure\$solutionName.Infrastructure.csproj" `
    "$solutionName.Application\$solutionName.Application.csproj" `
    "$solutionName.Core\$solutionName.Core.csproj"

Write-Host "Solução $solutionName com projeto $projectType criada com sucesso!"
