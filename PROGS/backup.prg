PROCEDURE fnBackUp

	**S 100923 -- Inisialisasi dan Instansi object oTzip
	SET CLASSLIB TO libs\tzip.vcx ADDITIVE 
	oTzip = CREATEOBJECT("tzip")
	
	LOCAL cDatabase, cBackUpFolder, cBackUpFile, cBackUpTempFolder
	
	**S 100923 -- Tutup semua Form dan Tabel yang terbuka
	=fnTutupForm()
	CLOSE DATABASES ALL
	

	**S 110119 -- Ambil pengaturan BackUp pada file conn.kon
	cDatabase = JUSTPATH(fnDekrip(fnRead("Connection","database","DATA\conn.kon")))
	cBackUpFolder = fnDekrip(fnRead("BackUp","folder","DATA\conn.kon"))
	
	
	**S 100923 -- Jika aturan Folder BackUp tidak ada
	IF EMPTY(cBackUpFolder)
		cBackUpFolder = GETDIR(SYS(5)+SYS(2003),"Folder untuk BackUp Database","Pilih BackUp Folder",64)
		**S 101007 -- Jika pemilihan folder dibatalkan, batalkan proses backup
		IF EMPTY(cBackUpFolder)
			RETURN .F.
		ELSE
			=fnWrite("BackUp","folder",fnEnkrip(cBackUpFolder),"DATA\conn.kon")
		ENDIF
	ENDIF
	
	**S 101007 -- Jika aturan Folder BackUpnya ada, tetapi Folder BackUpnya tidak ada. Buat baru
	IF !DIRECTORY(cBackUpFolder)
		MD "&cBackUpFolder."
	ENDIF
	
	**S 100923 -- Folder Temporary
	cBackUpTempFolder = cBackUpFolder + "Temp_RC" 
	
	**S 100923 -- Buat Nama File BackUp
	cBackUpFile = cBackUpFolder + "backup." + ALLTRIM(STR(YEAR(DATE()))) + "." +;
				  PADL(ALLTRIM(STR(MONTH(DATE()))),2,"0") + "." + PADL(ALLTRIM(STR(DAY(DATE()))),2,"0") + ".rc" 
				  
	**S 100923 -- Periksa apakah Nama File BackUp sudah ada
	IF FILE(cBackUpFile,1)
		IF !MESSAGEBOX("Backup Database untuk hari ini telah dilakukan. Hendak diulangi?",1+64,"Konfirmasi BackUp") = 1
			RETURN .F.
		ENDIF
		DELETE FILE "&cBackUpFile."
	ENDIF
	
	**S 100923 -- BackUp Mulai
	WAIT WINDOW "BACKUP Database Mulai..." NOWAIT
	
	**S 100924 -- Hapus file *.bak dan *.tbk pada folder database
	DELETE FILE cDatabase + "\*.BAK"
	DELETE FILE cDatabase + "\*.TBK"
		
	**S 101007 -- Periksa, apakah Folder Temporary sudah ada. Apabila ada, hapus!
	IF DIRECTORY(cBackUpTempFolder,1)
		DELETE FILE cBackUpTempFolder + "\*.*"
		RD "&cBackUpTempFolder."
	ENDIF
	
	**S 101007 -- Buat Folder Temporary
	MD "&cBackUpTempFolder."
	
	**S 100923 -- Copy semua file Database
	COPY FILE cDatabase + "\*.dbc" TO cBackUpTempFolder + "\*.dbc"
	COPY FILE cDatabase + "\*.dbf" TO cBackUpTempFolder + "\*.dbf"
	COPY FILE cDatabase + "\*.DCT" TO cBackUpTempFolder + "\*.DCT"
	COPY FILE cDatabase + "\*.DCX" TO cBackUpTempFolder + "\*.DCX"
	COPY FILE cDatabase + "\*.CDX" TO cBackUpTempFolder + "\*.CDX"
	COPY FILE cDatabase + "\*.FPT" TO cBackUpTempFolder + "\*.FPT"
	COPY FILE cDatabase + "\*.ini" TO cBackUpTempFolder + "\*.ini"
	
	**S 100923 -- Kompres file 
	oTzip.tzarc(cBackUpTempFolder,cBackUpFile)
	
	**S 100923 -- Hapus file database di folder Temporary
	DELETE FILE cBackUpTempFolder + "\*.*"
	
	**S 100923 -- Hapus Folder Temporary
	RD "&cBackUpTempFolder."
	
	**S 100923 -- Backup Selesai
	WAIT WINDOW "BACKUP Database Selesai..." NOWAIT

ENDPROC 





PROCEDURE fnRestore
	**S 100924 -- Inisialisasi dan Instansi object oTzip
	SET CLASSLIB TO libs\tzip.vcx ADDITIVE 
	oTzip = CREATEOBJECT("tzip")
	
	LOCAL cDatabase, cRestoreFolder, cRestoreFile, cRestoreTempFolder
	
	**S 100924 -- Tutup semua Form dan Tabel yang terbuka
	=fnTutupForm()
	CLOSE DATABASES ALL
	

	**S 110119 -- Ambil pengaturan BackUp pada file conn.kon
	cDatabase = JUSTPATH(fnDekrip(fnRead("Connection","database","DATA\conn.kon")))
	cRestoreFolder = fnDekrip(fnRead("BackUp","folder","DATA\conn.kon"))
	cRestoreTempFolder = cDatabase + "\Temp_RC"
	
	
	**S 100924 -- Jika aturan Folder Restore tidak ada
	IF EMPTY(cRestoreFolder)
		MESSAGEBOX("Error konfigurasi Restore Database. Hubungi Administrator.",0+16,ATT_CAPTION) 
		RETURN .F.
	ENDIF
	
	**S 100924 -- Pilih File untuk Restore
	cRestoreFile = GETFILE("rc","File Restore","Pilih",0,"Cari File Restore Database")
	IF EMPTY(cRestoreFile)
		RETURN .F.
	ENDIF
	
	**S 100924 -- Konfirmasi untuk melanjutkan Restore
	IF MESSAGEBOX("Restore Database akan segera dilakukan. " + CHR(13) + "Kehilangan Data yang ada saat ini mungkin terjadi." +;
					CHR(13) + "Lanjutkan ?",1+64,"Konfirmasi Restore Database") = 2
		RETURN .F.
	ENDIF
	
	**S 100924 -- Restore Mulai
	WAIT WINDOW "RESTORE Database Mulai..." NOWAIT
	
	**S 101007 -- Periksa, Apakah Temporary Folder sudah ada. Apabila ada, hapus!
	IF DIRECTORY(cRestoreTempFolder,1)
		DELETE FILE cRestoreTempFolder + "\*.*"
		RD "&cRestoreTempFolder."
	ENDIF
		
	**S 101007 -- Buat Folder temporary
	MD "&cRestoreTempFolder."
	
	**S 100924 -- Pindahkan file conn.kon dan file command.ini ke folder temporary
	COPY FILE cDatabase + "\conn.kon" TO cRestoreTempFolder + "\conn.kon"
	
	**S 100924 -- Hapus semua file pada folder database
	DELETE FILE cDatabase + "\*.*"
	
	**S 100924 -- Uncompress file Restore
	oTzip.tzunarc(cRestoreFile,cDatabase)
	
	**S 100924 -- Pindahkan kembali file conn.kon dari folder temporary
	COPY FILE cRestoreTempFolder + "\conn.kon" TO cDatabase + "\conn.kon"
	
	**S 100924 -- Hapus file conn.kon pada temporary folder
	DELETE FILE cRestoreTempFolder + "\conn.kon"
	
	**S 100924 -- Hapus temporary folder
	RD "&cRestoreTempFolder."
	
	**S 100924 -- Restore Selesai
	WAIT WINDOW "RESTORE Database Selesai..." NOWAIT
	
ENDPROC