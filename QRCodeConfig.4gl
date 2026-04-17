PACKAGE com.fourjs.qrcode4rp
IMPORT os

PRIVATE CONSTANT cDefaultQR4RP = "QRReport.4rp"
PRIVATE CONSTANT cProfileQR4RP = "qr.report.4rp"
PRIVATE CONSTANT cEnvironmentQR4RP = "QR_REPORT_4RP"
PRIVATE DEFINE qr4rpFile STRING = ""

PUBLIC FUNCTION getQR4RPFile() RETURNS (STRING)

	WHENEVER ANY ERROR RAISE

	#Leverage the getHelper and return the account SID
	LET qr4rpFile = getHelper(qr4rpFile, cEnvironmentQR4RP, cProfileQR4RP)
   IF qr4rpFile IS NULL THEN
      LET qr4rpFile = findDefaultQR4RP()
   END IF
	RETURN qr4rpFile

END FUNCTION #getQR4RPFile

PRIVATE FUNCTION findDefaultQR4RP() RETURNS (STRING)

   VAR qr4rpFilePath STRING = ""

   #Search through the FGLLDPATH to find the package package
   VAR libraryPaths STRING = FGL_GETENV("FGLLDPATH")
   VAR pathList = libraryPaths.split(os.Path.pathSeparator())

   #Add the current directory as the first path to search
   CALL pathList.insertElement(1)
   LET pathList[1] = os.Path.pwd()

   #Search to the 4rp file
   VAR idx INTEGER = 0
   FOR idx = 1 TO pathList.getLength()
      VAR filePath = SFMT(
         "%1%2com%2fourjs%2qrcode4rp%2%3",
         pathList[idx],
         os.Path.separator(),
         cDefaultQR4RP
      )
      IF os.Path.exists(filePath) THEN
         LET qr4rpFilePath = filePath
         EXIT FOR
      END IF
   END FOR

   RETURN qr4rpFilePath

END FUNCTION #findDefaultQR4RP

PRIVATE FUNCTION getHelper(initialValue STRING, envName STRING, prfKey STRING) RETURNS STRING

	VAR getValue = initialValue

	IF getValue IS NOT NULL THEN
		RETURN getValue
	END IF

	#Environment variable will always take precedence over fglprofile
	LET getValue = FGL_GETENV(envName)
	IF getValue IS NOT NULL THEN
		RETURN getValue
	END IF

	#If the getValue is still empty, use the fglprofile entry
	LET getValue = base.Application.getResourceEntry(prfKey)
	RETURN getValue

END FUNCTION #getHelper