* Procedure untuk passing parameter ke form lain
* parameter = namaform,passparam  =>  string,string
Procedure fnPassprm
	Lparameters oNmClass, vCommand
* nama class, perintah [param1, param2,...]
	Local cntClass
	For cntClass = 1 To _Screen.FormCount
		If _Screen.Forms[cntClass].BaseClass = "Form" ;
				AND Upper(_Screen.Forms[cntClass].Name) ;
				== Upper(oNmClass)
			_Screen.Forms[cntClass].&vCommand.
			Exit
		Endif
	Endfor
Endproc

* Procedure Declare DLL Baca / Tulis *.txt
Procedure fnDeclare
	Declare Integer GetPrivateProfileString In Win32API  As GetPrivStr ;
		string cSection, String cKey, String cDefault, String @cBuffer, ;
		integer nBufferSize, String cINIFile

	Declare Integer WritePrivateProfileString In Win32API As WritePrivStr ;
		string cSection, String cKey, String cValue, String cINIFile
Endproc

* Procedure untuk Baca *.txt File
Procedure fnRead
	Lparameters cLabel, cKey, cDirectory
	Local cHasil, cBuffer, lError, cError
	cHasil = ''
	cBuffer = Space(1000) + Chr(0)
	cError = On('ERROR')

** Declare Win32 AP
	=fnDeclare()

** Ambil data dari File
	If GetPrivStr(cLabel, cKey, "", ;
			@cBuffer, Len(cBuffer), Curdir() + cDirectory) > 0
** Cek Error
		On Error lError = .T.

** Simpan Hasil
		cHasil = Alltrim(Chrtran(cBuffer,Chr(0),""))
		On Error &cError

** Jika Error, Reset Variable hasil
		If lError
			cHasil = ''
		Endif
	Endif
	Return cHasil
Endproc

* Procedure untuk Tulis *.txt File
Procedure fnWrite
	Lparameters cLabel, cKey, cData, cDirectory
	Local lError, cError
	cError = On('ERROR')

** Declare Win32 API
	=fnDeclare()

** Tulis Data ke File
	If WritePrivStr(cLabel, cKey, cData, Curdir() + cDirectory) > 0
		On Error &cError
		If lError
			Return .F.
		Endif
	Endif
Endproc

* 081105 - Procedure Untuk Tipe Connection
Procedure fnConnType
	Lparameters cType, cServer, cUser, cPass, cDatabase
	Do Case
		Case cType = "1"
			cConn = "DRIVER=SQL Server;SERVER=&cServer.;UID=&cUser.;PWD=&cPass.;APP=Microsoft Visual FoxPro;DATABASE=&cDatabase.;Network=DBMSLPCN,.T."
		Case cType = "2"
			cConn = "DRIVER={Microsoft Visual FoxPro Driver};SourceType=&cServer.;SourceDB=&cDatabase.;Exclusive=No;NULL=YES;Collate=Machine;BACKGROUNDFETCH=NO;DELETED=YES"
		Case cType = "3"
			cConn = "DRIVER={MySQL ODBC 3.51 Driver};DESC=;DATABASE=&cDatabase.;SERVER=&cServer.;UID=&cUser.;PASSWORD=&cPass.;PORT=3306;OPTION=3;STMT=;"
		Case cType = "4"

		Otherwise
			cConn = ""
	Endcase
	Return cConn
Endproc

* 081105 - Procedure Untuk Buat Koneksi
Procedure fnConnection
	Lparameters cType, cServer, cUser, cPass, cDatabase
	Store Sqlstringconnect(fnConnType(cType, cServer, cUser, cPass, cDatabase)) To nConn
	If nConn > 0
		=SQLSetprop(nConn,"DispLogin",3)
*!*			=SQLSETPROP(nConn,"Transactions",2)
	Else
		_MsgErrorConnection()
		=fnTextFile("Error No.   : 102 -- fnConnection, " + Chr(13) + "Error Message : Tidak Dapat Koneksi", "ErrLog.Txt", .T.)
	Endif
	Return nConn
Endproc

* 081105 - Procedure Untuk Requery Table ke DATABASE
Procedure fnRequery
	Lparameters cCommand, oCursor, nConn

** 081112 - Buat Koneksi Baru, Jika nConn <> .F.
	Local nConn, lKoneksi
	If Empty(nConn)
		Store Sqlstringconnect(_Screen.pConnection_Name) To nConn
		lKoneksi = .T.
	Endif

** 081105 - Cek, Koneksi yang dibuat berhasil
	If nConn <= 0
		_MsgErrorConnection()
		=fnTextFile("Error No.   : 101 -- fnRequery , " + Chr(13) + "Error Message : Tidak Dapat Koneksi", "ErrLog.Txt", .T.)
		Return .F.
	Endif

** Command menghasilkan Cursor
	If Type("oCursor") <> "L"
		If SQLExec(nConn,cCommand,oCursor) < 0
** Tampilkan Error Message
			_MsgErrorQuery()
			=fnDisConnect(nConn)
			Return .F.
		Endif
	Else
		If SQLExec(nConn,cCommand) < 0
** Tampilkan Error Message
			_MsgErrorQuery()
			=fnDisConnect(nConn)
			Return .F.
		Endif
	Endif

** 081112 - Bukan Manual Koneksi
	If lKoneksi
		=fnDisConnect(nConn)
	Endif
	Return .T.
Endproc

* 081105 - Procedure Untuk TUTUP Aktif Koneksi
Procedure fnDisConnect
	Lparameters nConn

** Cek, ADA Koneksi
	If nConn > 0
** Tutup Koneksi
		=SQLDisconnect(nConn)
	Endif
	Return .T.
Endproc

** 081105 - Procedure Commit Transaction
Procedure fnCommit
	Lparameters nConn
	Local lCommit
	Wait Window "Commit Transaction" Nowait
** 081105 - Coba Commit sebanyak 5 kali
	For i = 1 To 5
		If Sqlcommit(nConn) = 1
			lCommit = .T.
			Exit
		Endif
		i = i + 1
	Endfor

** 081105 - Jika Gagal
	If !lCommit
		=fnTextFile("Error No.   : 001, " + Chr(13) + "Error Message : Tidak Dapat Commit Transaksi", "ErrLog.Txt", .T.)
		Sqlrollback(nConn)
	Endif
	Return .T.
Endproc

* Fungsi Buka Document Sesuai dengan Asosiasi Program filenya
Procedure fnBukaDok(oDocument)
	Local nReturn

	Declare Integer ShellExecute ;
		IN SHELL32.Dll ;
		INTEGER nWinHandle, ;
		STRING cOperation, ;
		STRING cFileName, ;
		STRING cParameters, ;
		STRING cDirectory, ;
		INTEGER nShowWindow

*Proses Kembali ke window utama VFP (Proses ini di pakai oleh ShellExecute)
	Declare Integer FindWindow ;
		IN WIN32API ;
		STRING cNull, ;
		STRING cWinName

	nReturn=ShellExecute(FindWindow( 0, _Screen.Caption), "Open", oDocument, "", Sys(2023), 1)

*Pesan Error Jika Nilai return < 32
	If nReturn < 32
		Do Case
			Case nReturn=2
				Wait Wind "Asosiasi File Dokumen atau URL salah."
			Case nReturn=31
				Wait Wind "Asosiasi '."+Justext(oDocument)+"' tidak ada."
			Case nReturn=29
				Wait Wind "Program Aplikasi tidak bisa dipanggil."
			Case nReturn=30
				Wait Wind "Program Aplikasi telah dibuka."
		Endcase
	Endif
Endproc

* Procedure untuk mendapatkan nomor transaksi terakhir berdasarkan jenis transaksi dan ketentuan penomorannya
Procedure fnGetNumber
	Lparameters cCode, cType
	Local nNumber, nConn, lExist

** 081112 - Jika Ada Koneksi Aktif
	If _Screen.pConnection > 0
		nConn = _Screen.pConnection
	Else
		Store Sqlstringconnect(_Screen.pConnection_Name) To nConn
** 081105 - Cek, Koneksi yang dibuat berhasil
		If nConn <= 0
			_MsgErrorConnection()
			=fnTextFile("Error No.   : 103 -- fnGetNumber , " + Chr(13) + "Error Message : Tidak Dapat Koneksi", "ErrLog.Txt", .T.)
			Return .F.
		Endif
	Endif

	If SQLExec(nConn,"SELECT nomor FROM hitung WHERE kode = ?cCode AND tipe = ?cType","_tMyNomor") < 1
** Tampilkan Error Message
		_MsgErrorQuery()

** 081112 - Tutup Koneksi, jika Sudah ADA koneksi, batalkan seua Koneksi
		=fnDisConnect(nConn)
		If _Screen.pConnection > 0
			_Screen.pConnection = 0
		Endif
	Endif

** Cek Cursor Hasil
	If Reccount("_tMyNomor") = 0		&& Jika tidak ada Hasil
** Insert Record Baru
		If SQLExec(nConn,"INSERT INTO hitung (kode, tipe, nomor) VALUES (?cCode, ?cType, 1 )") < 1
			_MsgErrorQuery()
		Endif
		nNumber = 1
	Else 								&& Jika ada Hasil
** Update Record
		nNumber = _tMyNomor.nomor + 1
		If SQLExec(nConn,"UPDATE hitung SET nomor = ?VAL(LTRIM(STR(_tMyNomor.nomor+1))) WHERE kode = ?cCode AND tipe = ?cType") < 1
			_MsgErrorQuery()
		Endif
	Endif

** 081112 - Tutup Koneksi, jika Koneksi dibuat sekarang
	If _Screen.pConnection = 0
		=fnDisConnect(nConn)
	Endif

** Use Cursor Aktif
	Use In _tMyNomor
	Return nNumber
Endproc

* Procedure untuk mendapatkan nomor transaksi / kode dengan panjang yang sama
Procedure fnNumber
	Lparameters cType, cName, nPrefix, dDate
	Local cNoPrefix, cNumber, nNumber

** Set Jenis Reset Nomor
	Do Case
		Case cType = 'Tahun'
			cNoPrefix = fnDateToYear(dDate)
		Case cType = 'Bulan'
			cNoPrefix = fnDateToPeriode(dDate)
		Otherwise
			cNoPrefix = ''
	Endcase

** Ambil DATA Nomor terakhir
	nNumber = fnGetNumber(cName,cNoPrefix)

** Set Return Value
	If Empty(cType)
		cNumber = Iif(!Empty(cNoPrefix),cNoPrefix+'.','')+Padl(Ltrim(Str(nNumber)),nPrefix,'0')
	Else
		cNumber = Iif(!Empty(cNoPrefix),cNoPrefix+'.','')+Padl(Ltrim(Str(nNumber)),nPrefix,'0')
	Endif
	Return cNumber
Endproc

* Procedure tulis ke Text file...
Procedure fnTextFile
	Lparameters cString, cFileName, lID
	If Type("lID") <> "L" Then
		lID = .T.
	Endif

	Set Console Off
	Set Printer To (cFileName) Additive
	Set Printer On
	If lID Then
		?Ttoc(Datetime()) + " - User ID : " + Alltrim(Iif(Type("gcUser") <> "C", "---",gcUser)) + " - " + cString
	Else
		? cString
	Endif
	Set Printer Off
	Set Printer To
Endfunc

* Procedure Report Windows
Procedure fnReportWindow
	Lparameters cFormName, cCaptionFom, cReport, nType

	Local oReportForm As Form
	oReportForm = Createobject("Form")
	With oReportForm
		.Caption = cCaptionFom
		.Name = cFormName
		.Width = _Screen.Width - 15
		.Height = _Screen.Height - 50
		.AutoCenter= .T.
		.MaxButton=.F.
		.AlwaysOnTop=.T.
		.HalfHeightCaption=.T.
	Endwith
	Do Case
		Case nType = 1
&& -> TO PRINTER Langsung
			Report Form &cReport. To Printer Prompt
		Case nType = 2
&& -> TO PRINTER PREVIEW
			Report Form &cReport. To Printer Prompt Preview Window  &cFormName.
		Case nType = 3
&& -> PREVIEW NOWAIT
			Report Form &cReport. Preview Window &cFormName. Nowait
		Case nType = 4
&& -> PREVIEW WAIT
			Report Form &cReport. Preview Window &cFormName.
	Endcase

** Set Preview Toolbar di DOCK position
	If Wexist("Print Preview")
		Move Window "Print Preview" To 10,10
		Mouse DblClick At 11,11
	Endif
	Release oReportForm
Endproc

* Procedure Random Character
Procedure fnRandom
	Lparameters cChar, nLength
	Local cReturn

	=Rand(-1)
	cReturn= ""
	For i = 1 To nLength
		cReturn= cReturn + Chr(Rand()*200+15)
	Next
	Return cReturn + cChar
Endfunc

* Procedure ENKRIP
Procedure fnEnkrip
	Lparameters cEncrip
	Local cTemp, i
	If Len(cEncrip) > 0
		cTemp = ""
		For i = 1 To Len(cEncrip)
			cTemp = cTemp + Chr(Asc(Substr(cEncrip,i,1)) + 14 + i)
		Endfor
	Else
		cTemp = cEncrip
	Endif
	Return cTemp
Endproc

**Procedure DEKRIP
Procedure fnDekrip
	Lparameters cDecrip
	Local cTemp, i
	If Len(Alltrim(cDecrip)) > 0
		cTemp = ""
		For i = 1 To Len(Alltrim(cDecrip))
			cTemp = cTemp + Chr(Asc(Substr(cDecrip,i,1)) - 14 - i)
		Endfor
	Else
		cTemp = cDecrip
	Endif
	Return cTemp
Endproc

* -- Fungsi untuk menghitung selisih jam...
* -- Syntax : fnSelisihJam(Jam_Awal, Jam_Akhir, nMode)
* --          Jam_Awal  : Jam mulai perhitungan
* --          Jam_Akhir : Jam Perhitungan sampai jam berapa
* --          nMode     : 1 - Hasil dalam Jam, 2 - Hasil dalam menit
Function fnSelisihJam
	Lparameters tTime1, tTime2, nMode
	Local nTmp
	If Parameters() < 3 Then
		nMode = 1
	Endif

	If tTime2 < tTime1 Then
		Messagebox("Jam awal tidak boleh setelah jam akhir...", 64, "Peringatan")
		Return -1
	Endif

	nTmp = tTime2 - tTime1
	If nMode = 1 Then
		Return (nTmp/(60*60))
	Else
		Return (nTmp/60)
	Endif
Endfunc

* Procedure untuk ngecek, jam yang dimasukkan bener apa nggak....
Procedure fnIsTime
	Lparameters cTime
	Local tTmp
* -- Cek parameternya cocok nggak...
	If Type("cTime") <> "C" Then
		Messagebox("Parameternya harus string....", 64, ATT_CAPTION)
		Return .F.
	Endif

	tTmp = Ctot(Dtoc(Date()) + " " + Alltrim(cTime))
	If Empty(tTmp) Then
		Return .F.
	Else
		Return .T.
	Endif
Endproc

Function fnSQLSeek
	Lparameters cExp, cTableName, cIndex, cCursor
	Local cSQLCmd

* -- Cek Parametersnya....
	If Type("cCursor") <> "C" Then
		cCursor = "xTmp"
	Endif

	cExp = Strtran(cExp, "'", "''")

* -- Lakukan pencarian....
	cSQLCmd = "SELECT * FROM " + cTableName + " WHERE " + cIndex + ;
		IIF(At("%", cExp) <> 0, " LIKE '" + cExp, " = '" + cExp) + "'"
	If fnRequery(cSQLCmd, cCursor) = .F. Then
		Messagebox("Error melakukan pencarian data ke SQL Servernya... ", 64, "SQL Seek")
		Return -1
	Endif

* -- Cek, ada datanya apa nggak..
	If Reccount(cCursor) > 0 Then
		Return 1
	Else
		Return 0
	Endif
Endfunc

* Procedure Angka2Text
Procedure fnTerbilang
	Lparameters nValue
	Local nLength, cValue, cDigit

	nValue = Transform(nValue,"999999999999999999.99")
	nLength = Len(Alltrim(nValue))

	cValue = ''
** Jika, length Value TIDAK SAMA dengan 0
	Do While nLength >= 1
** Set Value per Character
		cDigit = Substr(Alltrim(nValue),nLength,1)

** Jika Value Angka
		If Asc(cDigit) >= 48 And Asc(cDigit) <= 57
			cValue = cValue + cDigit
		Else
			Exit
		Endif
		nLength = nLength - 1
	Enddo

**
	nValue = Substr(Alltrim(nValue),1,nLength-1)
	Set Decimals To 0
	nValue = Substr(Padl(Val(nValue),18,'#'),1,18)
	Set Decimals To 2

	Declare cSatuan(1,5)
	cSatuan(1) =' rupiah'
	cSatuan(2) =' ribu '
	cSatuan(3) =' juta '
	cSatuan(4) =' milyar '
	cSatuan(5) =' trilyun '

	Declare cBilang(1,5)
	cBilang(1)=Right(nValue,3)
	cBilang(2)=Substr(Right(nValue,6),1,3)
	cBilang(3)=Substr(Right(nValue,9),1,3)
	cBilang(4)=Substr(Right(nValue,12),1,3)
	cBilang(5)=Substr(Right(nValue,15),1,3)

	For i = 1 To 5 Step 1
		If Substr(cBilang(i),3,1) ='#'
			i = i - 1
			Exit
		Else
			If Substr(cBilang(i),2,1) ='#' Or Substr(cBilang(i),1,1) ='#'
				cBilang(i) = Strtran(cBilang(i),'#','0')
				Exit
			Endif
		Endif
	Endfor

	For j = 1 To i
		If !Isnull(cBilang(j))
			cBilang(j) = fnHuruf(cBilang(j)) + cSatuan(j)
		Endif
	Endfor

	If Isnull(cBilang(1))
		cBilang(1)= cSatuan(1)
	Endif

	For j = 1 To ( i - 1 )
		If !Isnull(cBilang( j + 1 ))
			cBilang( j + 1 ) = cBilang( j + 1 ) + cBilang(j)
		Else
			cBilang( j + 1 ) = cBilang(j)
		Endif
	Endfor
	If fnDecimal(cValue)='00'
		cAngkaText = cBilang(i)
	Else
		cAngkaText = cBilang(i) + ' point '+ fnDecimal(cValue)
	Endif
	Return cAngkaText
Endproc

Function fnDecimal
	Lparameters cDecimal
	Local cDecimal1, cDecimal2

	cDecimal1 = Substr(cDecimal,2,1)
	cDecimal2 = Substr(cDecimal,1,1)
	Do Case
		Case cDecimal1 = '0'
			If cDecimal2 = '0'
				cDecimal1 = '00'
			Else
				cDecimal1 = 'nol '+ fnAngka(cDecimal2)
			Endif
		Case cDecimal1 = '1'
			If cDecimal2 = '0'
				cDecimal1 = 'sepuluh'
			Else
				cDecimal1 = fnAngka(cDecimal2) + 'belas'
			Endif
		Otherwise
			If cDecimal2 = '0'
				cDecimal1 = fnAngka(cDecimal1) + ' puluh'
			Else
				cDecimal1 = fnAngka(cDecimal1) + ' puluh ' + fnAngka(cDecimal2)
			Endif
	Endcase
	Return cDecimal1
Endfunc

Function fnHuruf
	Lparameters cValue
	Local cNilai1, cNilai2, cNilai3

	cNilai1 = Substr(cValue,1,1)
	cNilai2 = Substr(cValue,2,1)
	cNilai3 = Substr(cValue,3,1)
	Do Case
		Case cNilai2 = '0'
			If cNilai3 = '0'
				cNilai2 = Null
			Else
				cNilai2 = fnAngka(cNilai3)
			Endif
		Case cNilai2 = '1'
			Do Case
				Case cNilai3 = '0'
					cNilai2 = 'sepuluh '
				Case cNilai3 = '1'
					cNilai2 = 'sebelas '
				Other
					cNilai2 = fnAngka(cNilai3) + 'belas'
			Endcase
		Other
			If cNilai3 = '0'
				cNilai2 = fnAngka(cNilai2) + ' puluh'
			Else
				cNilai2 = fnAngka(cNilai2) + ' puluh ' + fnAngka(cNilai3)
			Endif
	Endcase

	Do Case
		Case cNilai1 = '0'
			cNilai1 = cNilai2
		Case cNilai1 = '1'
			If !Isnull(cNilai2)
				cNilai1 = 'seratus ' + cNilai2
			Else
				cNilai1 = 'seratus'
			Endif
		Other
			If !Isnull(cNilai2)
				cNilai1 = fnAngka(cNilai1) + ' ratus ' + cNilai2
			Else
				cNilai1 = fnAngka(cNilai1) + ' ratus'
			Endif
	Endcase
	Return cNilai1
Endfunc
Function fnAngka
	Lparameters cValue
	Do Case
		Case cValue = '1'
			Return 'satu'
		Case cValue = '2'
			Return 'dua'
		Case cValue = '3'
			Return 'tiga'
		Case cValue = '4'
			Return 'empat'
		Case cValue = '5'
			Return 'lima'
		Case cValue = '6'
			Return 'enam'
		Case cValue = '7'
			Return 'tujuh'
		Case cValue = '8'
			Return 'delapan'
		Case cValue = '9'
			Return 'sembilan'
		Other
	Endcase
Endproc



* -- Fungsi untuk mendapatkan nama hari dari suatu tanggal.....
Function fnNamaHari
	Lparameters dTgl
	Local nDOW
	Do Case
		Case (Type("dTgl") = "D") .Or. (Type("dTgl") = "T")
			nDOW = Dow(dTgl, 1)

		Case Type("dTgl") = "N"
			nDOW = dTgl

		Otherwise
			Return ""

	Endcase

	Do Case
		Case nDOW = 1
			Return "Minggu"

		Case nDOW = 2
			Return "Senin"

		Case nDOW = 3
			Return "Selasa"

		Case nDOW = 4
			Return "Rabu"

		Case nDOW = 5
			Return "Kamis"

		Case nDOW = 6
			Return "Jum'at"

		Case nDOW = 7
			Return "Sabtu"

		Otherwise
			Return ""
	Endcase
Endfunc

* Procedure Tanggal ke Tahun Bulan
Procedure fnDateToPeriode(dDate)
	Return Right(Str(Year(dDate)),2)+Padl(Alltrim(Str(Month(dDate))),2,'0')
Endproc

* Procedure Tanggal ke Tahun
Procedure fnDateToYear(dDate)
	Return Right(Alltrim(Str(Year(Date()))),2)
Endproc

* Procedure Selisih berapa bulan antara   01/12/98   dg   04/08/2000 ? hasilnya=20 bulan
Procedure fnMtoM(dDate_Start,dDate_Finish)
	Return Abs( ((Year(dDate_Start)-1)*12+Month(dDate_Start))-;
		((Year(dDate_Finish)-1)*12+Month(dDate_Finish)) )
Endproc

* Procedure untuk mendapatkan tanggal awal bulan
Procedure fnBoM(dDate)		&& Begin of Month
	Return Ctod('01/'+Str(Month(dDate))+'/'+Str(Year(dDate)))
Endproc

* Procedure untuk mendapatkan tanggal akhir bulan
Procedure fnEoM(dDate)   	&& End of Month
	Local dMonth
	dMonth = Gomonth(dDate,1)
	Return Ctod('01/'+Str(Month(dMonth))+'/'+Str(Year(dMonth))) - 1
Endproc

* Procedure untuk hari dan bulan
Procedure fnDayMonth(dDate)
	Return Padl(Alltrim(Str(Month(dDate))),2,'0')+'\'+;
		PADL(Alltrim(Str(Day(dDate))),2,'0')
Endproc

Procedure fnPeriodeGaji(cPeriode)
	Local cJenis
	cJenis = Substr(cPeriode,5,1)

	Do Case
		Case cJenis = 'M'
			cJenis = 'Minggu ke '
		Case cJenis = 'B'
			cJenis = 'Bulan '
		Otherwise
	Endcase

	Return cJenis + Substr(cPeriode,6,2) + ' ' + 'Tahun ' + Substr(cPeriode,1,4)
Endproc

*!*	* Procedure Nama Tanggal dalam Indonesia
*!*	PROCEDURE  fnDate_Ind(dMonth)
*!*		cMonth = 'Jan Feb Mar Apr Mei Jun Jul Agt Sep Okt Nov Des'
*!*		cMonth = ALLTRIM(SUBSTR(cMonth,MONTH(dMonth)*4-3,3))
*!*		RETURN cMonth
*!*	ENDPROC

* Procedure Nama Bulan dalam Indonesia
Procedure  fnMonth_Ind(dMonth)
	Cmonth = 'Jan Feb Mar Apr Mei Jun Jul Agt Sep Okt Nov Des'
	Cmonth = Alltrim(Substr(Cmonth,Month(dMonth)*4-3,3))
*!*		cMonth = 'Januari  Pebruari Maret    April    Mei      Juni     Juli     Agustus  September Oktober  November Desember'
*!*		cMonth = ALLTRIM(SUBSTR(cMonth,MONTH(dMonth)*9-8,9))
	Return Cmonth
Endproc

* Procedure Nama Hari dalam Indonesia
Procedure  fnDay_Ind(dDay)
	cDay = 'Minggu Senin  Selasa Rabu   Kamis  Jumat  Sabtu  '
	cDay = Alltrim(Substr(cDay,Dow(dDay)*7-6,7))
	Return cDay
Endproc

* Procedure Tanggal dalam Indonesia
Procedure  fnDate_Ind(dDate)
	cDate = fnMonth_Ind(dDate)
	cDate = Alltrim(Str(Day(dDate)))+' - '+cDate+' - '+Alltrim(Str(Year(dDate)))
	Return cDate
Endproc


* Fungsi Untuk Error Query
FUNCTION fnError		
	LPARAMETERS nError, cError, cLine, cProg, nLineNo
	LOCAL cErr
	
	LOCAL cFileTxt
	cFileTxt = fnDirError()
				
	cErr = LEFT("Error No.  : " + LTRIM(STR(nError)) + ", " + CHR(13) +;
			"Error Mssg : " + cError + ", " + CHR(13) +;
			"Line Code  : " + cLine + " on line number : " + LTRIM(STR(nLineNo)) + ", " + CHR(13) +;
			"Program    : " + cProg,250)
    WAIT WINDOW cErr TIMEOUT 5	
    _SCREEN.pError = .T.
    RETURN .T.
*!*		=fnTextFile(cErr, cFileTxt, .T.)
ENDFUNC 

* Fungsi Untuk Direktori Error Query
FUNCTION fnDirError	
	LOCAL cDirTxt, cDir, cFileTxt	
	cDirTxt = SYS(5) + SYS(2003) + "\ERR\"
	cDir = JUSTPATH(cDirTxt)
	IF !DIRECTORY(cDir)
		cDir = "'"+cDir+"'"
		MD &cDir
	ENDIF 
	
	cFileTxt = IIF(!EMPTY(cDirTxt),""+ALLTRIM(cDirTxt),"")+;
			"ErrLog"+;				
				Alltrim(Str(YEAR(DATE())))+;
				Padl(Alltrim(Str(MONTH(DATE()))),2,'0')+".Txt"
	RETURN cFileTxt
ENDFUNC 

* Fungsi untuk Error Connection
FUNCTION _MsgErrorConnection
    MESSAGEBOX('Koneksi ke database terputus, HUBUNGI Administrator !!!',48,''+ATT_CAPTION+'',gnSec)
ENDFUNC 


* Fungsi Untuk Error Query
FUNCTION _MsgErrorQuery		
	LPARAMETERS nError, cError, cLine, cProg, nLineNo
	LOCAL cFileTxt
	cFileTxt = fnDirError()
	
	AERROR(arrErr)
	=MESSAGEBOX("Tidak bisa Akses ke DATABASE, HUBUNGI Administrator !!!"+CHR(13)+;
			"Error : " + ArrErr(2),48,''+ATT_CAPTION+'',gnSec)
	=fnTextFile("Error No.   : " + STR(ArrErr(1)) + ", " + CHR(13) + "Error Message : " + ArrErr(2), cFileTxt, .T.)
ENDFUNC 

* Fungsi Untuk Error Set Connection
FUNCTION _MsgErrorSet
    MESSAGEBOX('Koneksi TIDAK bisa diSET, Transaksi diBATALkan'+CHR(13)+;
    'Hubungi Administrator !!!',48,''+ATT_CAPTION+'',gnSec)
ENDFUNC 

* Fungsi Untuk Error Save
FUNCTION _MsgErrorSave
	MESSAGEBOX('Data TIDAK dapat DISIMPAN...!!!',48,''+ATT_CAPTION+'',gnSec)	
	LOCAL cFileTxt
	cFileTxt = fnDirError()
	
	AERROR(ArrErr)	
	
	=fnTextFile("Error No.   : " + STR(ArrErr(1)) + ", " + CHR(13) + "Error Message : " + ArrErr(2), cFileTxt , .T.)
ENDFUNC 

* Fungsi Untuk Error Edit
Function _MsgErrorEdit
	Lparameters ATT_NILAI
	If Type("ATT_NILAI") <> "C"
		ATT_NILAI = Alltrim(Str(ATT_NILAI))
	Endif
	Messagebox('Data '+Alltrim(Upper(ATT_NILAI))+' TIDAK dapat DIUBAH',16,''+ATT_CAPTION+'',gnSec)
Endfunc

* Fungsi Untuk Error Delete
Function _MsgErrorDelete
	Lparameters ATT_NILAI
	If Type("ATT_NILAI") <> "C"
		ATT_NILAI = Alltrim(Str(ATT_NILAI))
	Endif
	Messagebox('Data '+Alltrim(Upper(ATT_NILAI))+' TIDAK dapat DIHAPUS',16,''+ATT_CAPTION+'',gnSec)
Endfunc

* Fungsi Untuk Error Delete, karena DATA ada di Table Lain
Function _MsgDeleteTable
	Lparameters ATT_NILAI, ATT_TABLE
	If Type("ATT_NILAI") <> "C"
		ATT_NILAI = Alltrim(Str(ATT_NILAI))
	Endif
	Messagebox('Data '+Alltrim(Upper(ATT_NILAI))+' TIDAK dapat DIHAPUS, DATA terdapat pada Tabel '+Alltrim(Upper(ATT_TABLE)),16,''+ATT_CAPTION+'',gnSec)
Endfunc

* Fungsi Untuk Delete
Function _MsgDelete
	Parameters ATT_TARGET, ATT_NILAI
	If Type("ATT_NILAI") <> "C"
		ATT_NILAI = Alltrim(Str(ATT_NILAI))
	Endif
	If Messagebox('HAPUS data '+Upper(Alltrim(ATT_TARGET))+' dengan nilai '+Upper(Alltrim(ATT_NILAI))+' ini?',36,''+ATT_CAPTION+'')=6
		ATT_EXECH='ya'
	Else
		ATT_EXECH='tdk'
	Endif
	Return ATT_EXECH
Endfunc

* Fungsi Untuk Empty
Function _MsgEmpty
	Parameters ATT_TEXT
	Messagebox('Data '+Upper(ATT_TEXT)+' masih KOSONG...!!!',48,''+ATT_CAPTION+'',gnSec)
Endfunc

* Fungsi Untuk Data sudah ADA
Function _MsgFull
	Parameters ATT_TEXT
	Messagebox('Data '+Upper(ATT_TEXT)+' sudah ADA...!!!',48,''+ATT_CAPTION+'',gnSec)
Endfunc

* Fungsi Untuk Data TIDAK ADA
Function _MsgNull
	Parameters ATT_TEXT
	Messagebox('Data '+Alltrim(ATT_TEXT)+' TIDAK ADA...!!!',48,''+ATT_CAPTION+'',gnSec)
Endfunc

* Fungsi Untuk Cek Qty
Function _MsgLack
	Parameters ATT_TEXT, ATT_QTY
	Messagebox('Qty '+Upper(Alltrim(ATT_TEXT))+' TIDAK mencukupi permintaan'+Chr(13)+;
		'Qty yang TERSEDIA adalah '+Alltrim(Str(ATT_QTY)),48,''+ATT_CAPTION+'',gnSec)
Endfunc

* Fungsi Tanggal
Function _MsgDate
	Parameters ATT_DATE
	If Messagebox('Anda INPUT tanggal '+Dtoc(ATT_DATE)+' ?',36,''+ATT_CAPTION+'') = 6
		ATT_EXECH='ya'
	Else
		ATT_EXECH='tdk'
	Endif
	Return ATT_EXECH
Endfunc


** 090731 - Procedure Tutup Semua Form yang aktif
Procedure fnTutupForm
	Local nForms, i
	nForms = _Screen.FormCount

	For i = nForms To 1 Step -1
		If Type("_SCREEN.FORMS(i)") = "O"
			_Screen.Forms(i).Release()
		Endif
	Endfor
Endproc
