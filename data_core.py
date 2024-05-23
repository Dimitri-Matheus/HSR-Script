import os
import subprocess
from tkinter import *
import customtkinter as ctk

impact_path = r"D:\Path\to\Game.exe"
injector_path = "script/Injector.exe"


def window_error(message):
    window = ctk.CTkToplevel(fg_color="#432818")
    window.title("")
    window.resizable(width=False, height=False)
    window.geometry("300x350")
    ctk.set_default_color_theme("theme/standard.json")

    title = ctk.CTkLabel(window, text="HSR+Script", font=ctk.CTkFont(size=48, weight="bold"))
    title.place(relx=0.5, rely=0.15, anchor=CENTER)

    error = ctk.CTkLabel(window, text=message, font=ctk.CTkFont(size=20))
    error.place(relx=0.5, rely=0.45, anchor=CENTER)

    close_button = ctk.CTkButton(window, text="Close", font=ctk.CTkFont(family="Verdana", size=14, weight="bold"), command=window.destroy)
    close_button.configure(width=135, height=54, corner_radius=8)
    close_button.place(relx=0.5, rely=0.8, anchor=CENTER)

    window.mainloop()


def run_powershell_command(command):
    subprocess.run(["powershell", "-command", command], check=True)


if not os.path.isfile(impact_path):
    raise FileNotFoundError(f"O arquivo do game não foi encontrado: {impact_path}")


if not os.path.isfile(injector_path):
    raise FileNotFoundError(f"O arquivo Injector.exe não foi encontrado no diretório atual.")

run_powershell_command("Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted")
run_powershell_command(f'Start-Process -FilePath "{injector_path}" StarRail.exe -Verb RunAs')
run_powershell_command(f'Start-Process -FilePath "{impact_path}" -Verb RunAs')
run_powershell_command("Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Restricted")

# Tests
window_error('ERROR!')
#print("Script concluído com sucesso!")