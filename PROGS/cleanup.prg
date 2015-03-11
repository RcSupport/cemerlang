SET PROCEDURE TO PROGS\backup.prg ADDITIVE

LOCAL cDatabase, cBackUpFolder, cBackUpFile

**S 101001 -- Ambil pengaturan BackUp pada file conn.kon
cDatabase = fnDekrip(fnRead('BackUp','database','DATA\conn.kon'))
cBackUpFolder = fnDekrip(fnRead('BackUp','folder','DATA\conn.kon'))

**S 101001 -- Periksa Aturan BackUp
IF !EMPTY(cDatabase) AND !EMPTY(cBackUpFolder)
	**S 101001 -- Buat Nama File BackUp
	cBackUpFile = cBackUpFolder + 'Backup.' + ALLTRIM(STR(YEAR(DATE()))) + '.' +;
				  PADL(ALLTRIM(STR(MONTH(DATE()))),2,'0') + '.' + PADL(ALLTRIM(STR(DAY(DATE()))),2,'0') + '.rc' 
	**S 101001 -- Periksa, apakah file backup hari yang bersangkutan sudah ada
	IF !FILE(cBackUpFile,1)
		IF MESSAGEBOX("BackUp Database hari ini, belum dilakukan." + CHR(13) + "Lakukan BackUp Database ?", 4+32, ATT_CAPTION) = 6
			fnBackUp()
		ENDIF
	ENDIF
ENDIF	
	
CLEAR EVENTS
CLEAR WINDOWS
CLEAR MENUS
CLEAR POPUP
CLEAR DLLS 
RELEASE ALL EXTENDED
POP MENU _msysmenu
SET SYSMENU TO DEFAULT

** 081112 - Tutup Koneksi
IF _SCREEN.pConnection > 0
	=SQLDISCONNECT(_SCREEN.pConnection)
ENDIF 

QUIT()