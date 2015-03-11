** Tututp Semua Form yang Aktif
LOCAL nForms,i
nForms=_SCREEN.FORMCOUNT

FOR i = nForms TO 1 STEP -1
	IF TYPE("_SCREEN.FORMS(i)") = "O"
		_SCREEN.FORMS(i).RELEASE()
	ENDIF 
ENDFOR

** Procedure untuk melakukan reindex database.....
LOCAL oTables[1], i, lError, cOnError
LOCAL cType, cDatabase

** Set Variable, Database Type dan Database FileName
cType = fnDekrip(fnRead('Connection','type','DATA\conn.kon'))	
cDatabase = fnDekrip(fnRead('Connection','database','DATA\conn.kon'))
cDatabase = "'"+cDatabase+"'"
	
CLOSE TABLES ALL
CLOSE DATABASES ALL 
OPEN DATABASE &cDatabase EXCLUSIVE 

** Siapkan dulu error 
cOnError = ON("ERROR")
ON ERROR lError = .T.

FOR i = 1 to ADBOBJECTS(oTables, "Table")
	lError = .F.
	IF !EMPTY(oTables[i])
		IF !USED(oTables[i])
			** Use Table
			USE (oTables[i]) IN 0 EXCLUSIVE 
			
			** Cek, ada Error
			IF lError THEN 
				** Jika Error tampilkan Message
				WAIT WINDOW "Table " + oTables[i] + " TIDAK dapat di-REINDEX"
				LOOP
			ENDIF 
			
			** Set Environment
			SELECT (oTables[i])
			WAIT WINDOW NOWAIT "Reindex dan Clean Up Table " + UPPER(ALLTRIM(oTables[i])) + ".DBF"
			PACK 
			REINDEX
		ENDIF
	ENDIF
ENDFOR
CLOSE TABLES ALL 
CLOSE DATABASES ALL 
WAIT WINDOW NOWAIT "Reindex Selesai....."

** 101108 - Buka kembali form level
IF !WEXIST("_level")
	DO FORM forms\utils\_level.scx
ENDIF 