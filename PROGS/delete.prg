PROCEDURE fnDelete

LOCAL nConn
STORE SQLSTRINGCONNECT(_SCREEN.pConnection_Name) TO nConn
**S 101113 -- Ambil Estimasi_No yang berada dalam Tanggal Dari dan Tanggal Sampai
	**S 101113 -- Untuk transaksi Tunai (Bayar = 0,1,3) dan transaksi Asuransi (Bayar = 2)
	=fnRequery("SELECT Estimasi_No, Bayar, (NVL(Jasa,0)+NVL(Total_Jasa,0))+"+;
					"(NVL(Material,0)+NVL(Total_Material,0)) AS Total_Estimasi, "+;
					"0 AS Selesai "+;
				"FROM Estimasi "+;
				"WHERE INLIST(NVL(Bayar,0),0,1,2,3) "+;
					"AND (Tanggal BETWEEN ?pdTanggalDari AND ?pdTanggalSampai) "+;
					"AND (Tanggal_Keluar BETWEEN ?pdTanggalDari AND ?pdTanggalSampai)","tEstimasi")
				
	**S 101113 -- Ambil Estimasi_No dan Total Pembayaran dari Tabel Bayar untuk Transaksi Tunai
	=fnRequery("SELECT Estimasi_No, SUM(Total) AS Total_Bayar "+;
				"FROM Bayar "+;
				"WHERE Jenis IN (1,3,4) "+;				
				"GROUP BY Estimasi_No ","tBayar")

	**S 101113 -- Ambil Estimasi_No dan Total Pembayaran dari Tabel Lunas untuk Transaksti Asuransi
	=fnRequery("SELECT Estimasi_No, SUM(Total) AS Total_Lunas FROM Lunas_Detail GROUP BY Estimasi_No","tLunas")
	
	**S 101113 -- Update Record pada kursor tEstimasi SET selesai = 1 untuk Transaksi Tunai (tBayar)
	UPDATE tEs SET tEs.Selesai = 1; 
		FROM tEstimasi tEs;
			 LEFT JOIN tBayar tByr ON tByr.Estimasi_No = tEs.Estimasi_No;
		WHERE tEs.Total_Estimasi = tByr.Total_Bayar
	
	**S 101113 -- Update Record pada kursor tEstimasi SET selesai = 1 untuk Transaksi Asuransi (tLunas)
	UPDATE tEs SET tEs.Selesai = 1;
		FROM tEstimasi tEs;
			LEFT JOIN tLunas tLns ON tLns.Estimasi_No = tEs.Estimasi_No;
		WHERE tEs.Total_Estimasi = tLns.Total_Lunas
	
	**S 101113 -- Buat Kursor yang memuat List Estimasi_No yang akan DiDelete dari tEstimasi
	SELECT * FROM tEstimasi WHERE Selesai = 1 INTO CURSOR tDelete
	
	**S 101113 -- Tutup Kursor Lainnya
	USE IN tLunas
	USE IN tBayar
	USE IN tEstimasi
	
	**S 101113 -- Mulai Penghapusan
	SELECT tDelete
ENDPROC

