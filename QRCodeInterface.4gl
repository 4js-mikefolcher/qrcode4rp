PACKAGE com.fourjs.qrcode4rp
IMPORT os

IMPORT FGL greruntime
IMPORT FGL com.fourjs.qrcode4rp.QRCodeConfig

PRIVATE DEFINE currentQRCodeFile STRING

PUBLIC FUNCTION generateQRCode(qrURI STRING) RETURNS STRING
    CONSTANT cImageFilePrefix = "QRCode_"
    DEFINE imgHandler om.SaxDocumentHandler

    #Get the full path of the 4RP file
    VAR reportFile = getQR4RPFile()
    IF reportFile IS NULL THEN
      RETURN NULL
    END IF

    #Get the QR Code temporary image file
    VAR imageDir = getTmpImageDir()
    IF imageDir IS NULL THEN
      RETURN NULL
    END IF

    #Load the GRE settings
    IF fgl_report_loadCurrentSettings(reportFile) THEN
        CALL fgl_report_selectDevice('Image')
        CALL fgl_report_configurePageSize('6in', '6in')
        CALL fgl_report_configureImageDevice(
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            'png',
            imageDir,
            cImageFilePrefix,
            NULL
        )
        LET imgHandler = fgl_report_commitCurrentSettings()
        IF imgHandler IS NULL THEN
            RETURN NULL 
        END IF 
    ELSE
        RETURN NULL 
    END IF 

    #Output the URI to the report
    START REPORT rptQRCode TO XML HANDLER imgHandler
    OUTPUT TO REPORT rptQRCode(qrURI)
    FINISH REPORT rptQRCode 

    #Get the image file
    VAR globPattern = SFMT("%1%2%3*.png", imageDir.trimWhiteSpace(), os.Path.separator(), cImageFilePrefix)
    VAR imageFiles = os.Path.glob(globPattern)
    IF imageFiles.getLength() > 0 THEN
        LET currentQRCodeFile = imageFiles[imageFiles.getLength()]
    ELSE 
        ERROR "Failed to find report file"
        RETURN NULL 
    END IF

    #Should we return the file URI instead?
    --RETURN ui.Interface.filenameToURI(currentQRCodeFile)
    RETURN currentQRCodeFile

END FUNCTION #generateQRCode

PUBLIC FUNCTION cleanupQRCode() RETURNS ()

   IF currentQRCodeFile IS NOT NULL THEN
      IF os.Path.exists(currentQRCodeFile) THEN
         IF os.Path.delete(currentQRCodeFile) THEN
            LET currentQRCodeFile = ""
         END IF
      END IF
   END IF

END FUNCTION #cleanupQRCode

PRIVATE FUNCTION getTmpImageDir() RETURNS (STRING)

   VAR imageDir = os.Path.makeTempName()
   IF NOT os.Path.exists(imageDir) THEN
      IF NOT os.Path.mkdir(imageDir) THEN
         LET imageDir = ""
      END IF
   END IF

   RETURN imageDir

END FUNCTION #getTmpImageDir

PRIVATE REPORT rptQRCode(authUri STRING)

    FORMAT
    ON EVERY ROW
        PRINT authUri

END REPORT #rptQRCode