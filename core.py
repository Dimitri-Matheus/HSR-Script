import os
import subprocess

# Configurações iniciais
title = "Genshin Impact + ReShade"
console_color = "0f"
console_size = "110,25"

# Caminho para o executável do jogo
genshin_impact_path = r"C:\Games\Star Rail\Games\StarRail.exe"  # Altere para o caminho do seu StarRail.exe

# Função para executar comandos no PowerShell
def run_powershell_command(command):
    subprocess.run(["powershell", "-command", command], check=True)

# Verifica se o caminho do executável do jogo existe
if not os.path.isfile(genshin_impact_path):
    raise FileNotFoundError(f"O arquivo especificado não foi encontrado: {genshin_impact_path}")

# Configurar título e aparência do console
os.system(f"title {title}")
os.system(f"color {console_color}")
os.system(f"mode con:cols={console_size.split(',')[0]} lines={console_size.split(',')[1]}")

# Definir política de execução do PowerShell para não restrito
run_powershell_command("Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted")

# Verifica se o Injector.exe existe no diretório atual
injector_path = "Injector.exe"
if not os.path.isfile(injector_path):
    raise FileNotFoundError(f"O arquivo Injector.exe não foi encontrado no diretório atual.")

# Executar o Injector.exe como administrador
run_powershell_command(f'Start-Process -FilePath "{injector_path}" StarRail.exe -Verb RunAs')

# Executar o jogo como administrador
run_powershell_command(f'Start-Process -FilePath "{genshin_impact_path}" -Verb RunAs')

# Reverter a política de execução do PowerShell para restrito
run_powershell_command("Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Restricted")

print("Script concluído com sucesso.")
