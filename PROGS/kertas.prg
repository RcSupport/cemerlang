define class AddPrinterForm as custom && olepublic
    hidden cUnit, cPrinterName, nFormHeight, nFormWidth, nLeftMargin, ;
        nTopMargin, nRightMargin, nBottomMargin, ;
        nInch2mm, nCm2mm, nCoefficient, hHeap

    cUnit = "English"      && inches or Metric - cm's
    cPrinterName = ""
    nFormHeight = 0
    nFormWidth = 0
    nLeftMargin = 0
    nTopMargin = 0
    nRightMargin = 0
    nBottomMargin = 0

    nApiErrorCode = 0
    cApiErrorMessage = ""
    cErrorMessage = ""

    nInch2mm = 25.4
    nCm2mm = 10
    nCoefficient = 0

    hHeap = 0

    procedure init(tcUnit)
    if pcount() = 1 and inlist(tcUnit, "English", "Metric")
        this.cUnit = proper(tcUnit)
    endif
    this.LoadApiDlls()
    this.hHeap = HeapCreate(0, 4096, 0)
* Use Windows default printer
    this.cPrinterName = set("Printer",2)
    this.nCoefficient = iif(proper(this.cUnit) = "English", ;
        this.nInch2mm, this.nCm2mm) * 1000
    endproc

    procedure destroy
    if this.hHeap <> 0
        HeapDestroy(this.hHeap)
    endif

    endproc

    procedure SetFormMargins(tnLeft, tnTop, tnRight, tnBottom)
    with this
        .nLeftMargin    = tnLeft   * .nCoefficient
        .nTopMargin    = tnTop    * .nCoefficient
        .nRightMargin    = tnRight  * .nCoefficient
        .nBottomMargin    = tnBottom * .nCoefficient
    endwith
    endproc

    procedure AddForm(tcFormName, tnWidth, tnHeight, tcPrinterName)
    local lhPrinter, llSuccess, lcForm

    this.nFormWidth  = tnWidth  * this.nCoefficient
    this.nFormHeight = tnHeight * this.nCoefficient
    if pcount() > 3
        this.cPrinterName = tcPrinterName
    else
        this.cPrinterName = set("Printer",2)
    endif

    this.ClearErrors()
    lhPrinter = 0
    if OpenPrinter(this.cPrinterName, @lhPrinter, 0) = 0
        this.cErrorMessage = "Unable to get printer handle for '" ;
            + this.cPrinterName + "."
        this.nApiErrorCode = GetLastError()
        this.cApiErrorMessage = this.ApiErrorText(this.nApiErrorCode)
        return .f.
    endif

    lnFormName = HeapAlloc(this.hHeap, 0, len(tcFormName) + 1)
    = sys(2600, lnFormName, len(tcFormName) + 1, tcFormName + chr(0))

* Build FORM_INFO_1 structure
    with this
        lcForm = this.Num2LOng(0) + ;      && Flags
        this.Num2LOng(lnFormName) + ;
            this.Num2LOng(.nFormWidth) + ;
            this.Num2LOng(.nFormHeight) + ;
            this.Num2LOng(.nLeftMargin) + ;
            this.Num2LOng(.nTopMargin) + ;
            this.Num2LOng(.nFormWidth - .nRightMargin) + ;
            this.Num2LOng(.nFormHeight - .nBottomMargin)
    endwith

* Finally, call the API


    if AddForm(lhPrinter, 1, @lcForm) = 0
        this.cErrorMessage = "Unable to Add Form '" + tcFormName + "'."
        this.nApiErrorCode = GetLastError()
        this.cApiErrorMessage = this.ApiErrorText(this.nApiErrorCode)
        llSuccess = .f.
    else
        llSuccess = .t.
    endif
    = HeapFree(this.hHeap, 0, lnFormName)
    = ClosePrinter(lhPrinter)

    return llSuccess




    procedure SetForm(tcFormName,tnWidth,tnHeight,tcPrinterName)
    local lhPrinter, llSuccess, lcForm
    if pcount() > 3
        this.cPrinterName = tcPrinterName
    else
        this.cPrinterName = set("Printer",2)
    endif
    this.ClearErrors()
    
    lhPrinter = 0
    if OpenPrinter(this.cPrinterName, @lhPrinter, 0) = 0
        this.cErrorMessage = "Unable to get printer handle for '" ;
            + this.cPrinterName + "."
        this.nApiErrorCode = GetLastError()
        this.cApiErrorMessage = this.ApiErrorText(this.nApiErrorCode)
        return .f.
    endif

    lnFormName = HeapAlloc(this.hHeap, 0, len(tcFormName) + 1)
    = sys(2600, lnFormName, len(tcFormName) + 1, tcFormName + chr(0))
    
    this.nFormWidth  = tnWidth  * this.nCoefficient
    this.nFormHeight = tnHeight * this.nCoefficient
    
    with this
        lcForm = this.Num2LOng(0) + ;      && Flags
        this.Num2LOng(lnFormName) + ;
            this.Num2LOng(.nFormWidth) + ;
            this.Num2LOng(.nFormHeight) + ;
            this.Num2LOng(.nLeftMargin) + ;
            this.Num2LOng(.nTopMargin) + ;
            this.Num2LOng(.nFormWidth - .nRightMargin) + ;
            this.Num2LOng(.nFormHeight - .nBottomMargin)
    ENDWITH
* Finally, call the API
    llSuccess =SetForm(lhPrinter, tcFormName,1,@lcForm)
	if llSuccess = 0
        this.cErrorMessage = "Unable to Add Form '" + tcFormName + "'."
        this.nApiErrorCode = GetLastError()
        this.cApiErrorMessage = this.ApiErrorText(this.nApiErrorCode)
    endif
    = HeapFree(this.hHeap, 0, lnFormName)
    = ClosePrinter(lhPrinter)
    return llSuccess





    procedure ClearErrors
    this.cErrorMessage = ""
    this.nApiErrorCode = 0
    this.cApiErrorMessage = ""
    endproc

    procedure DeleteForm(tcFormName, tcPrinterName)
    local lhPrinter, llSuccess

    if pcount() > 1
        this.cPrinterName = tcPrinterName
    ELSE
    	this.cPrinterName = set("Printer",2)   
    endif

    this.ClearErrors()
    lhPrinter = 0
    if OpenPrinter(this.cPrinterName, @lhPrinter, 0) = 0
        this.cErrorMessage = "Unable to get printer handle for '" + this.cPrinterName + "."
        this.nApiErrorCode = GetLastError()
        this.cApiErrorMessage = this.ApiErrorText(this.nApiErrorCode)
        return .f.
    endif

* Finally, call the API
    if DeleteForm(lhPrinter, tcFormName) = 0
        this.cErrorMessage = "Unable to delete Form '" + tcFormName + "'."
        this.nApiErrorCode = GetLastError()
        this.cApiErrorMessage = this.ApiErrorText(this.nApiErrorCode)
        llSuccess = .f.
    else
        llSuccess = .t.
    endif
    = ClosePrinter(lhPrinter)
    return llSuccess

    function Num2LOng(tnNum)
    declare RtlMoveMemory in WIN32API as RtlCopyLong ;
        string @dest, long @source, long length
    local lcString
    lcString = space(4)
    =RtlCopyLong(@lcString, bitor(tnNum,0), 4)
    return lcString
    endfunc

    function Long2Num(tcLong)
    declare RtlMoveMemory in WIN32API as RtlCopyNum ;
        long @dest, string @source, long length
    local lnNum
    lnNum = 0
    = RtlCopyNum(@lnNum, tcLong, 4)
    return lnNum
    endfunc

    hidden procedure ApiErrorText
        lparameters tnErrorCode
        local lcErrBuffer
        lcErrBuffer = repl(chr(0),1024)
        = FormatMessage(0x1000 ,.null., tnErrorCode, 0, @lcErrBuffer, 1024,0)
        return strtran(left(lcErrBuffer, at(chr(0),lcErrBuffer)- 1 ), ;
            "file", "form", -1, -1, 3)

        endproc

    hidden procedure LoadApiDlls
        declare integer OpenPrinter in winspool.drv;
            string  pPrinterName,;
            integer @phPrinter,;
            integer pDefault
        declare integer ClosePrinter in winspool.drv;
            integer hPrinter
        declare integer AddForm in winspool.drv;
            integer hPrinter,;
            integer level,;
            string  @pForm
        declare integer DeleteForm in winspool.drv;
            integer hPrinter,;
            string  pFormName
        declare integer HeapCreate in Win32API;
            integer dwOptions, integer dwInitialSize,;
            integer dwMaxSize
        declare integer HeapAlloc in Win32API;
            integer hHeap, integer dwFlags, integer dwBytes
        declare lstrcpy in Win32API;
            string @lpstring1, integer lpstring2
        declare integer HeapFree in Win32API;
            integer hHeap, integer dwFlags, integer lpMem
        declare HeapDestroy in Win32API;
            integer hHeap
        declare integer GetLastError in kernel32
        declare integer FormatMessage in kernel32.dll ;
            integer dwFlags, string @lpSource, ;
            integer dwMessageId, integer dwLanguageId, ;
            string @lpBuffer, integer nSize, integer Arguments

        declare integer SetForm in winspool.drv ;
            integer phPrinter,;
            string pFormName,;
            integer plevel,;
            string pForm

        endproc

enddefine
