from tkinter import *
import customtkinter as ctk
import PIL.Image, PIL.ImageTk

class MyImageFrame(ctk.CTkFrame):
    def __init__(self, master):
        super().__init__(master, width=300, height=315)
        
        # Load the image and place it in the frame
        self.Oniric_1 = ctk.CTkImage(PIL.Image.open("assets/logo/Oniric_1.png"), size=(256, 256))
        self.Oniric_1 = ctk.CTkLabel(master=self, text="", image=self.Oniric_1)
        self.Oniric_1.place(relx=0.5, rely=0.45, anchor=CENTER)


class HSRS(ctk.CTk):
    def __init__(self):
        super().__init__()
        self.title("")
        self.geometry("700x315")
        self.resizable(width=False, height=False)
        self.configure(fg_color="#432818")
        self.bind('<Return>', self.validate_enter)

        self.enter_bound = False

        ctk.set_default_color_theme("theme/standard.json")
        ctk.set_appearance_mode("dark")

        self.frame = MyImageFrame(self)
        self.frame.place(relx=0, rely=0, anchor=NW)

        self.title = ctk.CTkLabel(self, text="HSR+Script", font=ctk.CTkFont(size=58, weight="bold"))
        self.title.place(relx=0.72, rely=0.4, anchor=CENTER)

        self.text_1 = ctk.CTkLabel(self, text="Press enter to continue...", font=ctk.CTkFont(size=20, underline=False))
        self.text_1.place(relx=0.72, rely=0.75, anchor=CENTER)

        self.text_2 = ctk.CTkLabel(self, text="Hello,", font=ctk.CTkFont(size=20))
        self.text_2.place(relx=0.45, rely=0.05, anchor=NW)

    def validate_enter(self, event):
        if not self.enter_bound:
            self.enter_bound = True
            self.pages("path_game")
        
    def pages(self, stats):
        if stats == "path_game":
            print("Tecla funcionando!")
            self.title.configure(font=ctk.CTkFont(size=50, weight="bold"))
            self.title.place(relx=0.72, rely=0.15, anchor=CENTER)
            self.text_1.configure(text="Paste the game folder here!", font=ctk.CTkFont(size=18))
            self.text_1.place(relx=0.72, rely=0.32, anchor=CENTER)
            self.text_2.place_forget()

            self.path_entry = ctk.CTkEntry(self, placeholder_text="C:/Games...", font=ctk.CTkFont(family="Verdana", size=14))
            self.path_entry.configure(width=270, height=64, corner_radius=8)
            self.path_entry.place(relx=0.72, rely=0.58, anchor=CENTER)

            self.install_button = ctk.CTkButton(self, text="Install", font=ctk.CTkFont(family="Verdana", size=14, weight="bold"), command=lambda: self.pages("finish"))
            self.install_button.configure(width=135, height=54, corner_radius=8)
            self.install_button.place(relx=0.72, rely=0.85, anchor=CENTER)

        elif stats == "finish":
            print("Botão funcionando!")
            radio_var = IntVar(value=0)
            self.text_1.configure(text="Your game has been patched!")
            self.path_entry.place_forget()

            self.radiobutton_1 = ctk.CTkRadioButton(self, text="Run", variable= radio_var, value=1)
            self.radiobutton_1.configure(font=ctk.CTkFont(family="Verdana", size=14), radiobutton_width=18, radiobutton_height=18)
            self.radiobutton_1.place(relx=0.73, rely=0.5, anchor=CENTER)
            self.radiobutton_2 = ctk.CTkRadioButton(self, text="Not run", variable= radio_var, value=2)
            self.radiobutton_2.configure(font=ctk.CTkFont(family="Verdana", size=14), radiobutton_width=18, radiobutton_height=18)
            self.radiobutton_2.place(relx=0.73, rely=0.6, anchor=CENTER)

            self.install_button.configure(text="Finish", command=lambda: self.destroy())



    def iconbitmap(self, bitmap):
        self._iconbitmap_method_called = False
        super().wm_iconbitmap('assets/icon/1.ico')

if __name__ == "__main__":
    app = HSRS()
    app.mainloop()