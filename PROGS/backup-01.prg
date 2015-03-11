PROCEDURE fnRestore
*!*	LPARAMETERS nAbsensi, nAlat, nAsuransi, nBayar, nEstimasi, nEstimasiDetail, nJasa, nJurnal, nKendaraan, nKerja, nKerjaDetail, nMaterial, nMerk, nPegawai, nPemilik, nPinjaman, nRekening, nSatuan, nTipe 

LOCAL nConn
STORE SQLSTRINGCONNECT(_SCREEN.pConnection_name) TO nConn

STORE 0 TO nAbsensi, nAlat, nAsuransi, nBayar, nEstimasi, nEstimasiDetail, nJasa, nJurnal, nKendaraan, nKerja, nKerjaDetail, nMaterial, nMerk, nPegawai, nPemilik, nPinjaman, nRekening, nSatuan, nTipe 


IF FILE("Restore\absensi.dbf") THEN
	nAbsensi = 1
ENDIF
IF FILE("Restore\alat.dbf") THEN
	nAlat = 1
ENDIF
IF FILE("Restore\asuransi.dbf") THEN
	nAsuransi = 1
ENDIF
IF FILE("Restore\bayar.dbf") THEN
	nBayar = 1
ENDIF
IF FILE("Restore\estimasi.dbf") THEN
	nEstimasi = 1
ENDIF
IF FILE("Restore\estimasi_detail.dbf") THEN
	nEstimasiDetail = 1
ENDIF
IF FILE("Restore\jasa.dbf") THEN
	nJasa = 1
ENDIF
IF FILE("Restore\jurnal.dbf") THEN
	nJurnal = 1
ENDIF
IF FILE("Restore\kendaraan.dbf") THEN
	nKendaraan = 1
ENDIF
IF FILE("Restore\kerja.dbf") THEN
	nKerja = 1
ENDIF
IF FILE("Restore\kerja_detail.dbf") THEN
	nKerjaDetail = 1
ENDIF
IF FILE("Restore\material.dbf") THEN
	nMaterial = 1
ENDIF
IF FILE("Restore\merk.dbf") THEN
	nMerk = 1
ENDIF
IF FILE("Restore\pegawai.dbf") THEN
	nPegawai = 1
ENDIF
IF FILE("Restore\pemilik.dbf") THEN
	nPemilik = 1
ENDIF
IF FILE("Restore\pinjaman.dbf") THEN
	nPinjaman = 1
ENDIF
IF FILE("Restore\satuan.dbf") THEN
	nSatuan = 1
ENDIF
IF FILE("Restore\rekening.dbf") THEN
	nRekening = 1
ENDIF
IF FILE("Restore\tipe.dbf") THEN
	nTipe = 1
ENDIF











IF nAbsensi = 1 THEN
	
	USE "Restore\absensi.dbf" ALIAS tAbsensi
	
	SELECT tAbsensi
	GO TOP IN tAbsensi
	
	SCAN ALL
		=fnRequery("SELECT absensi_no FROM Absensi WHERE absensi_no = ?tAbsensi.absen_no","tCek")
		
		IF RECCOUNT("tCek") <> 0 THEN
			=fnRequery("UPDATE Absensi SET pegawai_id = ?tAbsensi.peg_id, "+;
										  "periode = ?tAbsensi.periode, "+;
										  "hadir = ?tAbsensi.hadir, "+;
										  "lembur = ?tAbsensi.lembur, "+;
										  "lembur_libur = ?tAbsensi.lem_lib, "+;
										  "pinjaman = ?tAbsensi.pinjaman, "+;
										  "potongan_lain = ?tAbsensi.pot_lain, "+;
										  "insentif = ?tAbsensi.insentif, "+;
										  "lain = ?tAbsensi.lain, "+;
										  "bonus = ?tAbsensi.bonus, "+;
										  "persen = ?tAbsensi.persen, "+;
										  "sisa = ?tAbsensi.sisa, "+;
										  "validasi = ?tAbsensi.validasi, "+;
										  "user_ch = 'SysAdmin', "+;
										  "date_ch = DATETIME() "+;
							"WHERE absensi_no = ?tCek.absensi_no","")
		ELSE
			=fnRequery("INSERT INTO Absensi (absensi_no, pegawai_id, periode, hadir, lembur, lembur_libur, pinjaman, "+;
							"potongan_lain, insentif, lain, bonus, persen, sisa, validasi, user_add, date_add) "+;
						"VALUES (?tAbsensi.absen_no, ?tAbsensi.peg_id, ?tAbsensi.periode, ?tAbsensi.hadir, ?tAbsensi.lembur, "+;
							"?tAbsensi.lem_lib, ?tAbsensi.pinjaman, ?tAbsensi.pot_lain, ?tAbsensi.insentif, ?tAbsensi.lain, "+;
							"?tAbsensi.bonus, ?tAbsensi.persen, ?tAbsensi.sisa, ?tAbsensi.validasi, 'SysAdmin', DATETIME())","")
		ENDIF		
	ENDSCAN
	
	IF USED("tCek")
		USE IN tCek
	ENDIF
	USE IN tAbsensi
ENDIF








IF nAlat = 1 THEN
	
	USE "Restore\alat.dbf" ALIAS tAlat
	
	SELECT tAlat
	GO TOP IN tAlat
	
	SCAN ALL
		=fnRequery("SELECT alat_id FROM alat WHERE alat_id = ?tAlat.alat_id","tCek")
		
		IF RECCOUNT("tCek") <> 0 THEN
			=fnRequery("UPDATE alat SET kode = ?tAlat.kode, "+;
									   "nama = ?tAlat.nama, "+;
									   "ket = ?tAlat.ket, "+;
									   "user_ch = 'SysAdmin', "+;
									   "date_ch = DATETIME() "+
							"WHERE alat_id = ?tCek.alat_id","")
		ELSE
			=fnRequery("INSERT INTO alat (alat_id, kode, nama, ket, user_add, date_add) "+;
						"VALUES (?tAlat.alat_id, ?tAlat.kode, ?tAlat.nama, ?tAlat.ket, 'SysAdmin', DATETIME())")
		ENDIF
	ENDSCAN
	
	IF USED("tCek")
		USE IN tCek
	ENDIF
	USE IN tAlat
ENDIF






IF nAsuransi = 1

	USE "Restore\asuransi.dbf" ALIAS tAsuransi

	SELECT tAsuransi
	GO TOP IN tAsuransi
	SCAN ALL
		=fnRequery("SELECT asuransi_id FROM asuransi WHERE kode = ?tAsuransi.kode","tCek",nConn)
		IF RECCOUNT("tCek") <> 0 THEN
			=fnRequery("UPDATE Asuransi SET asuransi_id=?tAsuransi.as_id, kode=?tAsuransi.kode, nama=?tAsuransi.nama, "+;
						"alamat=?tAsuransi.alamat, kota=?tAsuransi.kota, telepon01=?tAsuransi.Tlp01, telepon02=?tAsuransi.Tlp02, "+;
						"fax=?tAsuransi.fax, kontak=?tAsuransi.kontak, kontak_hp01=?tAsuransi.hp01, kontak_hp02=?tAsuransi.hp02, "+;
						"keterangan=?tAsuransi.ket, aktif=?tAsuransi.aktif, user_ch='SysAdmin', date_ch=?DATETIME() "+;
						"WHERE asuransi_id = ?tCek.asuransi_id","")
		ELSE
			=fnRequery("INSERT INTO Asuransi (asuransi_id, kode, nama, alamat, kota, telepon01, telepon02, fax, kontak, "+;
						"kontak_hp01, kontak_hp02, keterangan, aktif, user_add, date_add) "+;
						"VALUES (?tAsuransi.as_id, ?tAsuransi.kode, ?tAsuransi.nama, ?tAsuransi.alamat, "+;
						"?tAsuransi.kota, ?tAsuransi.Tlp01, ?tAsuransi.Tlp02, ?tAsuransi.fax, ?tAsuransi.kontak, "+;
						"?tAsuransi.hp01, ?tAsuransi.hp02, ?tAsuransi.ket, ?tAsuransi.aktif, "+;
						"'SysAdmin', DATETIME())","")
		ENDIF
	ENDSCAN
	
	IF USED("tCek")
		USE IN tCek
	ENDIF
	USE IN tAsuransi
	
ENDIF








IF nBayar = 1 THEN
	
	USE "Restore\bayar.dbf" ALIAS tBayar
	
	SELECT tBayar
	GO TOP IN tBayar
	
	SCAN ALL
		=fnRequery("SELECT bayar_no FROM bayar WHERE bayar_no = ?tBayar.bayar_no","tCek")
		
		IF RECCOUNT("tBayar") <> 0 THEN
			=fnRequery("UPDATE Bayar SET tanggal = ?tBayar.tanggal, "+;
										"estimasi_no = ?tBayar.es_no, "+;
										"no_polisi = ?tBayar.no_pol, "+;
										"tipe_id = ?tBayar.tipe_id, "+;
										"bayar_nama = ?tBayar.byr_nama, "+;
										"bayar_alamat = ?tBayar.byr_almt, "+;
										"bayar_kota = ?tBayar.byr_kota, "+;
										"bayar_tipe = ?tBayar.byr_tipe, "+;
										"total = ?tBayar.total, "+;
										"untuk = ?tBayar.untuk, "+;
										"jenis = ?tBayar.jenis, "+;
										"keterangan = ?tBayar.ket, "+;
										"posting = ?tBayar.posting, "+;
										"validasi = ?tBayar.validasi, "+;
										"user_ch = 'SysAdmin', "+;
										"date_ch = DATETIME() "+;
								"WHERE bayar_no = ?tCek.bayar_no","")						
		ELSE
			=fnRequery("INSERT INTO Bayar (bayar_no, tanggal, estimasi_no, no_polisi, tipe_id, bayar_nama, bayar_alamat, "+;
							"bayar_kota, bayar_tipe, total, untuk, jenis, keterangan, posting, validasi, user_add, date_add) "+;
						"VALUES (?tBayar.bayar_no, ?tBayar.tanggal, ?tBayar.es_no, ?tBayar.no_pol, ?tBayar.tipe_id, ?tBayar.byr_nama, "+;
							"?tBayar.byr_almt, ?tBayar.byr_kota, ?tBayar.byr_tipe, ?tBayar.total, ?tBayar.untuk, ?tBayar.jenis, "+;
							"?tBayar.ket, ?tBayar.posting, ?tBayar.validasi, 'SysAdmin', DATETIME())")
		ENDIF
	ENDSCAN 

	IF USED("tCek")
		USE IN tCek
	ENDIF
	USE IN tBayar
ENDIF









IF nEstimasi = 1 THEN
	
	USE "Restore\estimasi.dbf" ALIAS tEstimasi	
	
	SELECT tEstimasi
	GO TOP IN tEstimasi
	SCAN ALL
		=fnRequery("SELECT estimasi_no FROM estimasi WHERE estimasi_no = ?tEstimasi.Es_No","tCek")
		IF RECCOUNT("tCek") <> 0 THEN
			=fnRequery("UPDATE estimasi SET no_faktur = ?tEstimasi.no_fak, "+;
											"tambah = ?tEstimasi.tambah, "+;
											"warna_no = ?tEstimasi.wrn_no, "+;
											"tanggal = ?tEstimasi.tanggal, "+;
											"tanggal_masuk = ?tEstimasi.tgl_msk, "+;
											"tanggal_keluar = ?tEstimasi.tgl_kel, "+;
											"pemilik_id = ?tEstimasi.pem_id, "+;
											"asuransi_id = ?tEstimasi.as_id, "+;
											"no_polisi = ?tEstimasi.no_pol, "+;
											"bayar = ?tEstimasi.bayar, "+;
											"bayar_nama = ?tEstimasi.byr_nama, "+;
											"bayar_alamat = ?tEstimasi.byr_almt, "+;
											"bayar_telepon = ?tEstimasi.byr_telp, "+;
											"resiko = ?tEstimasi.resiko, "+;
											"jasa = ?tEstimasi.jasa, "+;
											"material = ?tEstimasi.material, "+;
											"total_jasa = ?tEstimasi.tot_jasa, "+;
											"total_material = ?tEstimasi.tot_mat, "+;
											"total = ?tEstimasi.total, "+;
											"status = ?tEstimasi.status, "+;
											"validasi = ?tEstimasi.validasi, "+;
											"selesai = ?tEstimasi.selesai, "+;
											"jenis = ?tEstimasi.jenis, "+;
											"keterangan = ?tEstimasi.ket, "+;
											"tanggal_bayar = ?tEstimasi.tanggal_ba, "+;
											"user_ch = 'SysAdmin', "+;
											"date_ch = DATETIME() "+;
										"WHERE estimasi_no = ?tCek.estimasi_no","")									
		ELSE
			=fnRequery("INSERT INTO estimasi (estimasi_no, no_faktur, tambah, warna_no, tanggal, tanggal_masuk, tanggal_keluar, "+;
							"pemilik_id, asuransi_id, no_polisi, bayar, bayar_nama, bayar_alamat, bayar_telepon, resiko, jasa, "+;
							"material, total_jasa, total_material, total, status, validasi, selesai, jenis, keterangan, tanggal_bayar, "+;
							"user_add, date_add) "+;
						"VALUES (?tEstimasi.es_no, ?tEstimasi.no_fak, ?tEstimasi.tambah, ?tEstimasi.wrn_no, ?tEstimasi.tanggal, "+;
							"?tEstimasi.tgl_msk, ?tEstimasi.tgl_kel, ?tEstimasi.pem_id, ?tEstimasi.as_id, ?tEstimasi.no_pol, "+;
							"?tEstimasi.bayar, ?tEstimasi.byr_nama, ?tEstimasi.byr_almt, ?tEstimasi.byr_telp, ?tEstimasi.resiko, "+;
							"?tEstimasi.jasa, ?tEstimasi.material, ?tEstimasi.tot_jasa, ?tEstimasi.tot_mat, ?tEstimasi.total, "+;
							"?tEstimasi.status, ?tEstimasi.validasi, ?tEstimasi.selesai, ?tEstimasi.jenis, ?tEstimasi.ket, "+;
							"?tEstimasi.tanggal_ba, 'SysAdmin', DATETIME())","")
		ENDIF
	
	ENDSCAN
	
	IF USED("tCek")
		USE IN tCek
	ENDIF
	USE IN tEstimasi	

ENDIF







IF nEstimasiDetail = 1 THEN
	
	USE "Restore\estimasi_detail.dbf" ALIAS tEstimasiDetail
	
	SELECT tEstimasiDetail
	GO TOP IN tEstimasiDetail
	
	SCAN ALL
		=fnRequery("SELECT estimasi_detail FROM estimasi_detail WHERE estimasi_detail = ?tEstimasiDetail.es_det","tCek")
		
		IF RECCOUNT("tCek") <> 0 THEN
			=fnRequery("UPDATE estimasi_detail SET estimasi_no = ?tEstimasiDetail.es_no, "+;
												  "jasa_id = ?tEstimasiDetail.jasa_id, "+;
												  "material_id = ?tEstimasiDetail.mat_id, "+;
												  "satuan_id = ?tEstimasiDetail.sat_id, "+;
												  "panel = ?tEstimasiDetail.panel, "+;
												  "kuantitas = ?tEstimasiDetail.qty, "+;
												  "harga = ?tEstimasiDetail.harga, "+;
												  "diskon = ?tEstimasiDetail.diskon, "+;
												  "tipe = ?tEstimasiDetail.tipe, "+;
												  "keterangan = ?tEstimasiDetail.ket, "+;
												  "user_ch = 'SysAdmin', "+;
												  "date_ch = DATETIME() "+;
								"WHERE estimasi_detail = ?tCek.es_det","")
		ELSE
			=fnRequery("INSERT INTO estimasi_detail (estimasi_detail, estimasi_no, jasa_id, material_id, satuan_id, panel, kuantitas, "+;
							"harga, diskon, tipe, keterangan, user_add, date_add) "+;
						"VALUES (?tEstimasiDetail.es_det, ?tEstimasiDetail.es_no, ?tEstimasiDetail.jasa_id, ?tEstimasiDetail.mat_id, "+;
							"?tEstimasiDetail.sat_id, ?tEstimasiDetail.panel, ?tEstimasiDetail.qty, ?tEstimasiDetail.harga, ?tEstimasiDetail.diskon, "+;
							"?tEstimasiDetail.tipe, ?tEstimasiDetail.ket, 'SysAdmin', DATETIME())")			
		ENDIF
	ENDSCAN 

	IF USED("tCek")
		USE IN tCek
	ENDIF
	USE IN tEstimasiDetail
ENDIF






IF nJasa = 1 THEN
	
	USE "Restore\jasa.dbf" ALIAS tJasa
	
	SELECT tJasa
	GO TOP IN tJasa
	
	SCAN ALL
		=fnRequery("SELECT jasa_id FROM jasa WHERE jasa_id = ?tJasa.jasa_id","tCek")
		
		IF RECCOUNT("tCek") <> 0 THEN
			=fnRequery("UPDATE jasa SET kode = ?tJasa.kode, "+;
										"nama = ?tJasa.nama, "+;
										"panel = ?tJasa.panel, "+;
										"harga = ?tJasa.harga, "+;
										"keterangan = ?tJasa.ket, "+;
										"aktif = ?tJasa.aktif, "+;
										"user_ch = 'SysAdmin', "+;
										"date_ch = DATETIME() "+;
							"WHERE jasa_id = ?tCek.jasa_id","")						
		ELSE
			=fnRequery("INSERT INTO jasa (jasa_id, kode, nama, panel, harga, keterangan, aktif, user_add, date_add) "+;
						"VALUES (?tJasa.jasa_id, ?tJasa.kode, ?tJasa.nama, ?tJasa.panel, ?tJasa.harga, ?tJasa.ket, "+;
							"?tJasa.aktif, 'SysAdmin', DATETIME())")
		
		ENDIF	
	ENDSCAN	
	
	IF USED("tCek")
		USE IN tCek
	ENDIF
	USE IN tJasa
	
ENDIF







IF nJurnal = 1 THEN
	
	USE "Restore\jurnal.dbf" ALIAS tJurnal
	
	SELECT tJurnal
	GO TOP IN tJurnal
	
	SCAN ALL
		=fnRequery("SELECT jurnal_no FROM jurnal WHERE jurnal_no = ?tJurnal.jur_no","tCek")
		
		IF RECCOUNT("tCek") <> 0 THEN
			=fnRequery("UPDATE jurnal SET bayar_tipe = ?tJurnal.byr_tipe, "+;
										 "estimasi_no = ?tJurnal.es_no, "+;
										 "tanggal = ?tJurnal.tanggal, "+;
										 "tipe_id = ?tJurnal.tipe_id, "+;
										 "rekening_id = ?tJurnal.rek_id, "+;
										 "lawan_id = ?tJurnal.lawan_id, "+;
										 "debet = ?tJurnal.debet, "+;
										 "kredit = ?tJurnal.kredit, "+;
										 "jenis = ?tJurnal.jenis, "+;
										 "sumber = ?tJurnal.sumber, "+;
										 "keterangan = ?tJurnal.ket, "+;
										 "validasi = ?tJurnal.validasi, "+;
										 "user_ch = 'SysAdmin', "+;
										 "date_ch = DATETIME() "+;
								"WHERE jurnal_no = ?tCek.jurnal_no","")									 
		ELSE
			=fnRequery("INSERT INTO jurnal (jurnal_no, bayar_tipe, estimasi_no, tanggal, tipe_id, rekening_id, lawan_id, debet, kredit, jenis, sumber, "+;
							"keterangan, validasi, user_add, date_add) "+;
						"VALUES (?tJurnal.jur_no, ?tJurnal.byr_tipe, ?tJurnal.es_no, ?tJurnal.tanggal, ?tJurnal.tipe_id, ?tJurnal.rek_id, ?tJurnal.lawan_id, "+;
							"?tJurnal.debet, ?tJurnal.kredit, ?tJurnal.jenis, ?tJurnal.sumber, ?tJurnal.ket, ?tJurnal.validasi, 'SysAdmin', DATETIME())")
		ENDIF
	ENDSCAN
	
	IF USED("tCek")
		USE IN tCek
	ENDIF
	USE IN tJurnal
ENDIF







IF nKendaraan = 1 THEN
	
	USE "Restore\kendaraan.dbf" ALIAS tKendaraan
	
	SELECT tKendaraan
	GO TOP IN tKendaraan
	
	SCAN ALL
		=fnRequery("SELECT no_polisi FROM kendaraan WHERE no_polisi = ?tKendaraan.no_pol","tCek")
		
		IF RECCOUNT("tCek") <> 0 THEN
			=fnRequery("UPDATE kendaraan SET merk_id = ?tKendaraan.merk_id, "+;
											"pemilik_id = ?tKendaraan.pem_id, "+;
											"model = ?tKendaraan.model, "+;
											"tahun = ?tKendaraan.tahun, "+;
											"warna = ?tKendaraan.warna, "+;
											"warna_baru = ?tKendaraan.wrn_baru, "+;
											"aktif = ?tKendaraan.aktif, "+;
											"user_ch = 'SysAdmin', "+;
											"date_ch = DATETIME() "+;											
							"WHERE no_polisi = ?tCek.no_polisi","")							
		ELSE
			=fnRequery("INSERT INTO kendaraan (no_polisi, merk_id, pemilik_id, model, tahun, warna, warna_baru, aktif, "+;
							"user_add, date_add) "+;
						"VALUES (?tKendaraan.no_pol, ?tKendaraan.merk_id, ?tKendaraan.pem_id, ?tKendaraan.model, "+;
							"?tKendaraan.tahun, ?tKendaraan.warna, ?tKendaraan.wrn_baru, ?tKendaraan.aktif, "+;
							"'SysAdmin', DATETIME())")
		ENDIF
	ENDSCAN
	
	IF USED("tCek")
		USE IN tCek
	ENDIF
	USE IN tKendaraan
ENDIF









IF nKerja = 1 THEN 

	USE "Restore\kerja.dbf" ALIAS tKerja
	
	SELECT tKerja
	GO TOP IN tKerja
	
	SCAN ALL
		=fnRequery("SELECT kerja_no FROM kerja WHERE kerja_no = ?tKerja.kerja_no","tCek")
		
		IF RECCOUNT("tCek") <> 0 THEN
			=fnRequery("UPDATE kerja SET warna_no = ?tKerja.warna_no, "+;
										"tanggal = ?tKerja.tanggal, "+;
										"pemilik_id = ?tKerja.pem_id, "+;
										"asuransi_id = ?tKerja.as_id, "+;
										"no_polisi = ?tKerja.no_pol, "+;
										"estimasi_no = ?tKerja.es_no, "+;
										"jasa = ?tKerja.jasa, "+;
										"material = ?tKerja.material, "+;
										"total_jasa = ?tKerja.tot_jasa, "+;
										"total_material = ?tKerja.tot_mat, "+;
										"total = ?tKerja.total, "+;
										"status = ?tKerja.status, "+;
										"batal = ?tKerja.batal, "+;
										"setuju = ?tKerja.setuju, "+;
										"validasi = ?tKerja.validasi, "+;
										"jenis = ?tKerja.jenis, "+;
										"keterangan = ?tKerja.ket, "+;
										"user_ch = 'SysAdmin', "+;
										"date_ch = DATETIME() "+;
								"WHERE kerja_no = ?tCek.kerja_no","")
		ELSE
			=fnRequery("INSERT INTO kerja (kerja_no, warna_no, tanggal, pemilik_id, asuransi_id, no_polisi, estimasi_no, jasa, material, "+;
							"total_jasa, total_material, total, status, batal, setuju, validasi, jenis, keterangan, user_add, date_add) "+;
						"VALUES (?tKerja.kerja_no, ?tKerja.warna_no, ?tKerja.tanggal, ?tKerja.pem_id, ?tKerja.as_id, ?tKerja.no_pol, "+;
							"?tKerja.es_no, ?tKerja.jasa, ?tKerja.material, ?tKerja.tot_jasa, ?tKerja.tot_mat, ?tKerja.total, ?tKerja.status, "+;
							"?tKerja.batal, ?tKerja.setuju, ?tKerja.validasi, ?tKerja.jenis, ?tKerja.ket, 'SysAdmin', DATETIME())")
		ENDIF	
	ENDSCAN
	
	IF USED("tCek")
		USE IN tCek
	ENDIF
	USE IN tKerja
ENDIF








IF nKerjaDetail = 1 THEN
	
	USE "Restore\kerja_detail.dbf" ALIAS tKerjaDetail
	
	SELECT tKerjaDetail
	GO TOP IN tKerjaDetail
	
	SCAN ALL
		=fnRequery("SELECT kerja_detail FROM kerja_detail WHERE kerja_detail = ?tKerjaDetail.krj_det","tCek")
		
		IF RECCOUNT("tCek") <> 0 THEN
			=fnRequery("UPDATE Kerja_Detail SET estimasi_detail = ?tKerjaDetail.es_det, "+;
											   "kerja_no = ?tKerjaDetail.kerja_no, "+;
											   "jasa_id = ?tKerjaDetail.jasa_id, "+;
											   "material_id = ?tKerjaDetail.mat_id, "+;
											   "satuan_id = ?tKerjaDetail.sat_id, "+;
											   "panel = ?tKerjaDetail.panel, "+;
											   "kuantitas = ?tKerjaDetail.qty, "+;
											   "harga = ?tKerjaDetail.harga, "+;
											   "diskon = ?tKerjaDetail.diskon, "+;
											   "tipe = ?tKerjaDetail.tipe, "+;
											   "keterangan = ?tKerjaDetail.ket, "+;
											   "user_ch = 'SysAdmin', "+;
											   "date_ch = DATETIME() "+;
								"WHERE kerja_detail = ?tCek.kerja_detail","")											   
		ELSE
			=fnRequery("INSERT INTO Kerja_Detail (kerja_detail, estimasi_detail, kerja_no, jasa_id, material_id, satuan_id, panel, "+;
							"kuantitas, harga, diskon, tipe, keterangan, user_add, date_add) "+;
						"VALUES (?tKerjaDetail.krj_det, ?tKerjaDetail.es_det, ?tKerjaDetail.kerja_no, ?tKerjaDetail.jasa_id, "+;
							"?tKerjaDetail.mat_id, ?tKerjaDetail.sat_id, ?tKerjaDetail.panel, ?tKerjaDetail.qty, ?tKerjaDetail.harga, "+;
							"?tKerjaDetail.diskon, ?tKerjaDetail.tipe, ?tKerjaDetail.ket, 'SysAdmin', DATETIME())")
		ENDIF		
	ENDSCAN
	
	IF USED("tCek")
		USE IN tCek
	ENDIF
	USE IN tKerjaDetail
ENDIF








IF nMaterial = 1

	USE "Restore\material.dbf" ALIAS tMaterial

	SELECT tMaterial
	GO TOP IN tMaterial

	SCAN ALL
		=fnRequery("SELECT material_id FROM material WHERE material_id = ?tMaterial.mat_id","tCek")
	
		IF RECCOUNT("tCek") <> 0 THEN
			=fnRequery("UPDATE material SET satuan_id = ?tMaterial.sat_id, "+;
										"kode = ?tMaterial.kode, "+;
										"nama = ?tMaterial.nama, "+;
										"part_no = ?tMaterial.part_no, "+;
										"kuantitas = ?tMaterial.qty, "+;
										"harga_jual = ?tMaterial.hrg_jual, "+;
										"harga_beli = ?tMaterial.hrg_beli, "+;
										"keterangan = ?tMaterial.ket, "+;
										"urutan = ?tMaterial.urutan, "+;
										"induk_id = ?tMaterial.ind_id, "+;
										"aktif = ?tMaterial.aktif, "+;
										"user_ch = 'SysAdmin', "+;
										"date_ch = DATETIME() "+;
							"WHERE material_id = ?tCek.material_id","")									
		ELSE
			=fnRequery("INSERT INTO material (material_id, satuan_id, kode, nama, part_no, kuantitas, harga_jual, harga_beli, "+;
						"keterangan, urutan, induk_id, aktif, user_add, date_add) "+;
					"VALUES (?tMaterial.mat_id, ?tMaterial.sat_id, ?tMaterial.kode, ?tMaterial.nama, ?tMaterial.part_no, "+;
						"?tMaterial.qty, ?tMaterial.hrg_jual, ?tMaterial.hrg_beli, ?tMaterial.ket, ?tMaterial.urutan, "+;
						"?tMaterial.ind_id, ?tMaterial.aktif, 'SysAdmin', DATETIME())")
		ENDIF	
	ENDSCAN
	
	IF USED("tCek")
		USE IN tCek
	ENDIF
	USE IN tMaterial
ENDIF






IF nMerk = 1
	
	USE "Restore\merk.dbf" ALIAS tMerk
	
	SELECT tMerk
	GO TOP IN tMerk
	
	SCAN ALL
		=fnRequery("SELECT merk_id FROM merk WHERE merk_id = ?tMerk.merk_id","tCek")
		
		IF RECCOUNT("tCek") <> 0 THEN
			=fnRequery("UPDATE merk SET kode = ?tMerk.kode, "+;
										"nama = ?tMerk.nama, "+;
										"jenis = ?tMerk.jenis, "+;
										"aktif = ?tMerk.aktif, "+;
										"user_ch = 'SysAdmin', "+;
										"date_ch = DATETIME() "+;
								"WHERE merk_id = ?tCek.merk_id","")
		ELSE
			=fnRequery("INSERT INTO merk (merk_id, kode, nama, jenis, aktif, user_add, date_add) "+;
						"VALUES (?tMerk.merk_id, ?tMerk.kode, ?tMerk.nama, ?tMerk.jenis, ?tMerk.aktif, 'SysAdmin', DATETIME())")
		ENDIF	
	ENDSCAN
	
	IF USED("tCek")
		USE IN tCek
	ENDIF
	USE IN tMerk
ENDIF






IF nPegawai = 1 THEN
	
	USE "Restore\pegawai.dbf" ALIAS tPegawai
	
	SELECT tPegawai
	GO TOP IN tPegawai
	
	SCAN ALL
		=fnRequery("SELECT Pegawai_Id FROM pegawai WHERE pegawai_id = ?tPegawai.peg_id","tCek")
		
		IF RECCOUNT("tCek") <> 0 THEN
			=fnRequery("UPDATE Pegawai SET nik = ?tPegawai.nik, "+;
										  "nama = ?tPegawai.nama, "+;
										  "alamat = ?tPegawai.alamat, "+;
										  "kota = ?tPegawai.kota, "+;
										  "kelamin = ?tPegawai.kelamin, "+;
										  "tanggal_masuk = ?tPegawai.tgl_msuk, "+;
										  "lembur = ?tPegawai.lembur, "+;
										  "aktif = ?tPegawai.aktif, "+;
										  "tempat_lahir = ?tPegawai.tmp_lhr, "+;
										  "tanggal_lahir = ?tPegawai.tgl_lhr, "+;
										  "telepon01 = ?tPegawai.tlp01, "+;
										  "telepon02 = ?tPegawai.tlp02, "+;
										  "hp01 = ?tPegawai.hp01, "+;
										  "hp02 = ?tPegawai.hp02, "+;
										  "divisi = ?tPegawai.divisi, "+;
										  "pokok = ?tPegawai.pokok, "+;
										  "lembur_libur = ?tPegawai.lem_lib, "+;
										  "insentif = ?tPegawai.insentif, "+;
										  "lain = ?tPegawai.lain, "+;
										  "bonus = ?tPegawai.bonus, "+;
										  "persen = ?tPegawai.persen, "+;
										  "pinjaman = ?tPegawai.pinjaman, "+;
										  "periode = ?tPegawai.periode, "+;
										  "user_ch = 'SysAdmin', "+;
										  "date_ch = DATETIME() "+;
								"WHERE pegawai_id = ?tCek.pegawai_id","")										  
		ELSE
			=fnRequery("INSERT INTO Pegawai (pegawai_id, nik, nama, alamat, kota, kelamin, tanggal_masuk, lembur, aktif, "+;
							"tempat_lahir, tanggal_lahir, telepon01, telepon02, hp01, hp02, divisi, pokok, lembur_libur, insentif, "+;
							"lain, bonus, persen, pinjaman, periode, user_add, date_add) "+;
						"VALUES (?tPegawai.peg_id, ?tPegawai.nik, ?tPegawai.nama, ?tPegawai.alamat, ?tPegawai.kota, ?tPegawai.kelamin, "+;
							"?tPegawai.tgl_msuk, ?tPegawai.lembur, ?tPegawai.aktif, ?tPegawai.tmp_lhr, ?tPegawai.tgl_lhr, "+;
							"?tPegawai.tlp01, ?tPegawai.tlp02, ?tPegawai.hp01, ?tPegawai.hp02, ?tPegawai.divisi, ?tPegawai.pokok, "+;
							"?tPegawai.lem_lib, ?tPegawai.insentif, ?tPegawai.lain, ?tPegawai.bonus, ?tPegawai.persen, "+;
							"?tPegawai.pinjaman, ?tPegawai.periode, 'SysAdmin', DATETIME())")
		ENDIF

	ENDSCAN
	
	IF USED("tCek")
		USE IN tCek
	ENDIF
	USE IN tPegawai
ENDIF







IF nPemilik = 1 THEN
	
	USE "Restore\pemilik.dbf" ALIAS tPemilik
	
	SELECT tPemilik
	GO TOP IN tPemilik
	
	SCAN ALL
		=fnRequery("SELECT pemilik_id FROM pemilik WHERE pemilik_id = ?tPemilik.pem_id","tCek")
		
		IF RECCOUNT("tCek") <> 0 THEN
			=fnRequery("UPDATE Pemilik SET kode = ?tPemilik.kode, "+;
										  "nama = ?tPemilik.nama, "+;
										  "alamat = ?tPemilik.alamat, "+;
										  "kota = ?tPemilik.kota, "+;
										  "telepon01 = ?tPemilik.tlp01, "+;
										  "telepon02 = ?tPemilik.tlp02, "+;
										  "hp01 = ?tPemilik.hp01, "+;
										  "hp02 = ?tPemilik.hp02, "+;
										  "fax = ?tPemilik.fax, "+;
										  "npwp = ?tPemilik.npwp, "+;
										  "aktif = ?tPemilik.aktif, "+;
										  "keterangan = ?tPemilik.ket, "+;
										  "user_ch = 'SysAdmin', "+;
										  "date_ch = DATETIME() "+;
							"WHERE pemilik_id = ?tCek.pemilik_id","")
		ELSE
			=fnRequery("INSERT INTO Pemilik (pemilik_id, kode, nama, alamat, kota, telepon01, telepon02, hp01, hp02, "+;
							"fax, npwp, aktif, keterangan, user_add, date_add) "+;
						"VALUES (?tPemilik.pem_id, ?tPemilik.kode, ?tPemilik.nama, ?tPemilik.alamat, ?tPemilik.kota, "+;
							"?tPemilik.tlp01, ?tPemilik.tlp02, ?tPemilik.hp01, ?tPemilik.hp02, ?tPemilik.fax, ?tPemilik.npwp, "+;
							"?tPemilik.aktif, ?tPemilik.ket, 'SysAdmin', DATETIME())")		
		ENDIF	
	ENDSCAN
	
	IF USED("tCek")
		USE IN tCek
	ENDIF
	USE IN tPemilik
ENDIF









IF nPinjaman = 1 THEN
	
	USE "Restore\pinjaman.dbf" ALIAS tPinjaman
	
	SELECT tPinjaman
	GO TOP IN tPinjaman
	
	SCAN ALL
		=fnRequery("SELECT pinjaman_no FROM pinjaman WHERE pinjaman_no = ?tPinjaman.pinj_no","tCek")
		
		IF RECCOUNT("tCek") <> 0 THEN
			=fnRequery("UPDATE Pinjaman SET tanggal = ?tPinjaman.tanggal, "+;
										   "total = ?tPinjaman.total, "+;
										   "validasi = ?tPinjaman.validasi, "+;
										   "pegawai_id = ?tPinjaman.peg_id, "+;
										   "user_ch = 'SysAdmin', "+;
										   "date_ch = DATETIME() "+;
								"WHERE pinjaman_no = ?tCek.pinjaman_no")
		ELSE
			=fnRequery("INSERT INTO Pinjaman (pinjaman_no, tanggal, total, validasi, pegawai_id, user_add, date_add) "+;
						"VALUES (?tPinjaman.pinj_no, ?tPinjaman.tanggal, ?tPinjaman.total, ?tPinjaman.validasi, ?tPinjaman.peg_id, "+;
							"'SysAdmin', DATETIME())")
		ENDIF		
	ENDSCAN

	IF USED("tCek")
		USE IN tCek
	ENDIF
	USE IN tPinjaman
ENDIF









IF nRekening = 1 THEN
	
	USE "Restore\rekening.dbf" ALIAS tRekening
	
	SELECT tRekening
	GO TOP IN tRekening
	
	SCAN ALL
		=fnRequery("SELECT rekening_id FROM rekening where rekening_id = ?tRekening.rek_id","tCek")
		
		IF RECCOUNT("tCek") <> 0 THEN
			=fnRequery("UPDATE rekening SET kode = ?tRekening.kode, "+;
										   "utama = ?tRekening.utama, "+;
										   "pembantu = ?tRekening.pembantu, "+;
										   "nama = ?tRekening.nama, "+;
										   "tunai = ?tRekening.tunai, "+;
										   "bank = ?tRekening.bank, "+;
										   "cek = ?tRekening.cek, "+;
										   "maksimal = ?tRekening.maksimal, "+;
										   "minimal = ?tRekening.minimal, "+;
										   "urutan = ?tRekening.urutan, "+;
										   "induk_id = ?tRekening.ind_id, "+;
										   "keterangan = ?tRekening.ket, "+;
										   "user_ch = 'SysAdmin', "+;
										   "date_ch = DATETIME() "+;
							"WHERE rekening_id = ?tCek.rekening_id","")
		ELSE
			=fnRequery("INSERT INTO rekening (rekening_id, kode, utama, pembantu, nama, tunai, bank, cek, maksimal, "+;
							"minimal, urutan, induk_id, keterangan, user_add, date_add) "+;
						"VALUES (?tRekening.rek_id, ?tRekening.kode, ?tRekening.utama, ?tRekening.pembantu, ?tRekening.nama, "+;
							"?tRekening.tunai, ?tRekening.bank, ?tRekening.cek, ?tRekening.maksimal, ?tRekening.minimal, "+;
							"?tRekening.urutan, ?tRekening.ind_id, ?tRekening.ket, 'SysAdmin', DATETIME())")
		ENDIF	
	ENDSCAN 
	
	IF USED("tCek")
		USE IN tCek
	ENDIF
	USE IN tRekening
ENDIF








IF nSatuan = 1 THEN 
	
	USE "Restore\satuan.dbf" ALIAS tSatuan
	
	SELECT tSatuan
	GO TOP IN tSatuan
	
	SCAN ALL
		=fnRequery("SELECT satuan_id FROM satuan WHERE satuan_id = ?tSatuan.sat_id","tCek")
		
		IF RECCOUNT("tCek") <> 0 THEN 
			=fnRequery("UPDATE Satuan SET induk_id = ?tSatuan.ind_id, "+;
										 "kode = ?tSatuan.kode, "+;
										 "nama = ?tSatuan.nama, "+;
										 "konversi = ?tSatuan.konversi, "+;
										 "utama = ?tSatuan.utama, "+;
										 "keterangan = ?tSatuan.ket, "+;
										 "aktif = ?tSatuan.aktif, "+;
										 "user_ch = 'SysAdmin', "+;
										 "date_ch = DATETIME() "+;
							"WHERE satuan_id = ?tCek.satuan_id","")
		ELSE
			=fnRequery("INSERT INTO Satuan (satuan_id, induk_id, kode, nama, konversi, utama, keterangan, aktif, user_add, date_add) "+;
						"VALUES (?tSatuan.sat_id, ?tSatuan.ind_id, ?tSatuan.kode, ?tSatuan.nama, ?tSatuan.konversi, ?tSatuan.utama, "+;
							"?tSatuan.ket, ?tSatuan.aktif, 'SysAdmin', DATETIME())")
		ENDIF
	ENDSCAN
	
	IF USED("tCek")
		USE IN tCek
	ENDIF
	USE IN tSatuan
ENDIF








IF nTipe = 1 THEN
	
	USE "Restore\tipe.dbf" ALIAS tTipe
	
	SELECT tTipe
	GO TOP IN tTipe 
	
	SCAN ALL
		=fnRequery("SELECT tipe_id FROM tipe WHERE tipe_id = ?tTipe.tipe_id","tCek")
		
		IF RECCOUNT("tCek") <> 0 THEN
			=fnRequery("UPDATE Tipe SET rekening_id = ?tTipe.rek_id, "+;
									   "kode = ?tTipe.kode, "+;
									   "nama = ?tTipe.nama, "+;
									   "keterangan = ?tTipe.ket, "+;
									   "user_ch = 'SysAdmin', "+;
									   "date_ch = DATETIME() "+;
							"WHERE tipe_id = ?tCek.tipe_id","")
		ELSE
			=fnRequery("INSERT INTO Tipe (tipe_id, rekening_id, kode, nama, keterangan, user_add, date_add) "+;
						"VALUES (?tTipe.tipe_id, ?tTipe.rek_id, ?tTipe.kode, ?tTipe.nama, ?tTipe.ket, 'SysAdmin', DATETIME())")
		ENDIF	
	ENDSCAN
	
	IF USED("tCek")
		USE IN tCek
	ENDIF
	USE IN tTipe
ENDIF








ENDPROC