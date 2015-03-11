IF USED("jurnal")
	USE IN jurnal
ENDIF 

USE data\jurnal.dbf IN 0 exclusive 

SELECT jurnal
** SET ORDER TO jurnal_no

REPLACE ALL jurnal_banding WITH SUBSTR(jurnal_no,4,20) FOR (SUBSTR(jurnal_no,1,2)="KW") OR (SUBSTR(jurnal_no,1,2)="JR")

SELECT jurnal_banding, COUNT(jurnal_banding) FROM jurnal GROUP BY jurnal_banding HAVING COUNT(jurnal_banding) > 1 INTO CURSOR tBanding

GO TOP IN tBanding
SCAN ALL
	UPDATE Jurnal SET Jurnal.Estimasi_No = "HAPUS";
		WHERE SUBSTR(Jurnal.Jurnal_No,1,2) = "KW";
			AND Jurnal.Jurnal_Banding = tBanding.Jurnal_Banding
ENDSCAN

SELECT Jurnal
GO TOP IN Jurnal
SCAN ALL
	IF Jurnal.Estimasi_No = "HAPUS"
		DELETE
	ENDIF
ENDSCAN

PACK

CLOSE TABLES ALL 

** SELECT * FROM Jurnal ORDER BY Jurnal_Banding






*!*	IF USED("jurnal")
*!*		USE IN jurnal
*!*	ENDIF 

*!*	USE data\jurnal.dbf IN 0 exclusive 

*!*	SELECT jurnal
*!*	SET ORDER TO jurnal_no
		
*!*	*!*	REPLACE ALL jurnal_no WITH SUBSTR(jurnal_no,1,2)+'.'+SUBSTR(jurnal_no,3,20);
*!*	*!*		FOR LEFT(jurnal_no,3) ="JR1"
*!*	*!*		
*!*	LOCAL cJurnal_No
*!*	cJurnal_No = " "	
*!*	GO top
*!*	SCAN ALL 
*!*		IF jurnal.jurnal_no = cJurnal_No
*!*			DELETE
*!*		ENDIF 
*!*		cJurnal_No = jurnal.jurnal_no
*!*	ENDSCAN 
*!*	PACK
*!*	CLOSE TABLES ALL 