** Tutup semua menu
_SCREEN.Caption = "RC Electronic, Hand Made Software, @Copyright 2010"
PUSH MENU _MSYSMENU
_SCREEN.ControlBox = .T.
_SCREEN.Closable = .T.
_SCREEN.MaxButton = .F.
_SCREEN.MinButton = .T.
_SCREEN.WindowState = 2
_SCREEN.Icon='GRAPHICS\ICON.ico'

ON SHUTDOWN QUIT()

** Jalankan Init Program
DO progs\init.prg
_SCREEN.Caption = SPACE(5) + gcCompany + SPACE(5) + fnVersi()

*** Form Login
LOCAL objfrmCetak
SET CLASSLIB TO libs\profile

objFrmCetak = CREATEOBJECT("profile.login")
objFrmCetak.Show(1)
*** End of Form


*!*	LOCAL cDatabase 
*!*	cDatabase = "'" + fnDekrip(fnRead('Connection','database','DATA\conn.kon')) +"'"

*!*	OPEN DATABASE &cDatabase SHARED 
*!*	=sp_Lunas('')

*!*	CLOSE DATABASES 

DO FORM forms\utils\_level.scx
ON KEY LABEL F2 ACTIVATE WINDOW calculator
*Menu Utama
** 120127 - Menu Berdasarkan data di conn
LOCAL cModul
cModul = fnRead('menu','modul','DATA\conn.kon')

** 1 = Att Op, 2 = Att, 3 = Admin, 4 = Pay Master, 5 = Pay Staff
DO CASE
CASE cModul = '10000'
	DO menus\menu_gd.mpr
OTHERWISE
	DO menus\menu.mpr
ENDCASE

READ EVENTS