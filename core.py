import os
import subprocess

injector_path = "script/Injector.exe"

# Function to Main.py
def verification(impact_path, text):
    missing_file = "Injector.exe" if not os.path.isfile(injector_path) else f"The specified file was not found!"
    if not os.path.isfile(injector_path) or not os.path.isfile(impact_path):
        text.configure(text=f"{missing_file}")
        raise FileNotFoundError("The files were not found!")
    
    elif os.path.isfile(injector_path) and os.path.isfile(impact_path):
        print("All necessary files were found!")
    else:
        print("Failed to read the files!")

def run_command(impact_path, mode):
    bat_file_path = os.path.join("script", "HSR+Reshade.bat")
    bat_content = f"""@echo off
    powershell -Command "Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted"
    powershell -Command "Start-Process -FilePath Injector.exe -ArgumentList 'StarRail.exe' -Verb RunAs"
    powershell -Command "Start-Process -FilePath '{impact_path}' -Verb RunAs"
    powershell -Command "Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Restricted"
    exit
    """
    
    if not os.path.exists(bat_file_path):
        with open(bat_file_path, "w") as bat_file:
            bat_file.write(bat_content)
            print(f"Batch file created at: {bat_file_path}")
    else:
            print(f"{os.path.basename(bat_file_path)} already exists")

    if mode == True:
        try:
            subprocess.run(["powershell", "-Command", "Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted"], check=True)
            subprocess.run(["powershell", "-Command", f'Start-Process -FilePath "{injector_path}" -ArgumentList "StarRail.exe" -Verb RunAs'], check=True)
            subprocess.run(["powershell", "-Command", f'Start-Process -FilePath "{impact_path}" -Verb RunAs'], check=True)
            subprocess.run(["powershell", "-Command", "Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Restricted"], check=True)

        except subprocess.CalledProcessError as e:
            print(f"An error occurred while executing the command: {e}")

# Test
#verification(r"C:\Games\Star Rail\Games")
#run_command(r"C:\Games\Star Rail\Games\StarRail.exe", False)