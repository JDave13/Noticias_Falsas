# Script PowerShell para convertir el informe Markdown a Word
param(
    [string]$InputFile = "informe_practica1.md",
    [string]$OutputDir = "out", 
    [string]$OutputFile = "Informe_Practica1_NoticiasFalsas.docx"
)

Write-Host "Exportacion a Word - Informe Noticias Falsas" -ForegroundColor Cyan
Write-Host "======================================================" -ForegroundColor Cyan

# Crear directorio de salida si no existe
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Name $OutputDir | Out-Null
    Write-Host "Directorio '$OutputDir' creado" -ForegroundColor Green
}

# Verificar si el archivo de entrada existe
if (-not (Test-Path $InputFile)) {
    Write-Host "ERROR: Archivo '$InputFile' no encontrado" -ForegroundColor Red
    Write-Host "Asegurate de ejecutar este script desde la raiz del proyecto" -ForegroundColor Yellow
    exit 1
}

Write-Host "Archivo de entrada: $InputFile" -ForegroundColor White

# Verificar si pandoc esta instalado
$pandocInstalled = Get-Command pandoc -ErrorAction SilentlyContinue

if (-not $pandocInstalled) {
    Write-Host "Pandoc no encontrado. Intentando instalar..." -ForegroundColor Yellow
    
    # Verificar si winget esta disponible
    $wingetInstalled = Get-Command winget -ErrorAction SilentlyContinue
    
    if ($wingetInstalled) {
        Write-Host "Instalando pandoc con winget..." -ForegroundColor Blue
        winget install --id JohnMacFarlane.Pandoc -e --source winget --accept-package-agreements --accept-source-agreements
        
        # Verificar instalacion despues de 5 segundos
        Start-Sleep -Seconds 5
        $pandocInstalled = Get-Command pandoc -ErrorAction SilentlyContinue
        
        if ($pandocInstalled) {
            Write-Host "Pandoc instalado exitosamente" -ForegroundColor Green
        } else {
            Write-Host "Pandoc instalado pero no esta en PATH. Reinicia la terminal." -ForegroundColor Yellow
            exit 1
        }
    } else {
        Write-Host "winget no disponible. Instala pandoc manualmente desde:" -ForegroundColor Red
        Write-Host "https://pandoc.org/installing.html" -ForegroundColor Yellow
        exit 1
    }
} else {
    Write-Host "Pandoc encontrado" -ForegroundColor Green
}

# Mostrar version de pandoc
$PandocVersion = & pandoc --version | Select-Object -First 1
Write-Host "Version: $PandocVersion" -ForegroundColor White

# Verificar si existen las figuras
$FiguresDir = "figures"
if (Test-Path $FiguresDir) {
    $FigureCount = (Get-ChildItem "$FiguresDir\*.png" -ErrorAction SilentlyContinue | Measure-Object).Count
    Write-Host "Figuras encontradas: $FigureCount archivos PNG en $FiguresDir/" -ForegroundColor White
} else {
    Write-Host "Directorio '$FiguresDir' no encontrado" -ForegroundColor Yellow
    Write-Host "Ejecuta 'python generate_figures.py' primero para crear las graficas" -ForegroundColor Yellow
}

# Definir ruta completa del archivo de salida
$OutputPath = Join-Path $OutputDir $OutputFile

# Ejecutar conversion
Write-Host ""
Write-Host "Iniciando conversion a Word..." -ForegroundColor Blue
Write-Host "$InputFile -> $OutputPath" -ForegroundColor White

$CurrentDate = Get-Date -Format 'dd/MM/yyyy'

& pandoc $InputFile -o $OutputPath --toc --number-sections --resource-path=".;figures;results" --metadata=title:"Deteccion de Noticias Falsas - Informe de Practica" --metadata=author:"Practica PLN - Universidad Nacional de Colombia" --metadata=date:$CurrentDate --highlight-style=tango --wrap=auto

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "CONVERSION EXITOSA" -ForegroundColor Green
    Write-Host "Archivo generado: $OutputPath" -ForegroundColor White
    
    # Mostrar informacion del archivo generado
    if (Test-Path $OutputPath) {
        $FileInfo = Get-Item $OutputPath
        $FileSizeMB = [math]::Round($FileInfo.Length / 1MB, 2)
        Write-Host "Tamaño: $FileSizeMB MB" -ForegroundColor White
        Write-Host "Fecha: $($FileInfo.LastWriteTime)" -ForegroundColor White
        
        # Intentar abrir el archivo
        $OpenFile = Read-Host "`nAbrir el archivo Word ahora? (s/N)"
        if ($OpenFile -match '^[sS].*') {
            Start-Process $OutputPath
            Write-Host "Abriendo archivo..." -ForegroundColor Green
        }
    }
    
    Write-Host ""
    Write-Host "PROCESO COMPLETADO" -ForegroundColor Green
    Write-Host "El archivo esta listo para compartir o imprimir" -ForegroundColor Yellow
    
} else {
    Write-Host ""
    Write-Host "ERROR EN LA CONVERSION" -ForegroundColor Red
    Write-Host "Codigo de salida: $LASTEXITCODE" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "SUGERENCIAS:" -ForegroundColor Cyan
    Write-Host "1. Verifica que el archivo '$InputFile' este bien formateado" -ForegroundColor White
    Write-Host "2. Asegurate de que las rutas de imagenes sean correctas" -ForegroundColor White
    Write-Host "3. Ejecuta 'pandoc --version' para verificar la instalacion" -ForegroundColor White
    exit 1
}

Write-Host ""
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "FIN DEL SCRIPT" -ForegroundColor Cyan