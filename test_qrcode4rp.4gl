PACKAGE com.fourjs.qrcode4rp

IMPORT os
IMPORT FGL com.fourjs.qrcode4rp.QRCodeInterface

-- Demo program for com.fourjs.qrcode4rp.
--
-- Usage:
--   fglrun test_qrcode4rp.42m            -- uses a default URL
--   fglrun test_qrcode4rp.42m <data>     -- encodes the given text (URL or plain text)
--
-- Generates a QR code PNG via the 4RP BARCODEBOX report and prints the
-- path so the user can open it. The temporary file is removed on exit.

MAIN
    DEFINE payload STRING
    DEFINE imageFile STRING

    IF num_args() >= 1 THEN
        LET payload = arg_val(1)
    ELSE
        LET payload = "https://www.4js.com"
    END IF

    DISPLAY "Encoding: ", payload
    DISPLAY ""

    LET imageFile = generateQRCode(payload)

    IF imageFile IS NULL OR imageFile.getLength() = 0 THEN
        DISPLAY "FAILED: generateQRCode returned no file"
        EXIT PROGRAM 1
    END IF

    IF NOT os.Path.exists(imageFile) THEN
        DISPLAY SFMT("FAILED: image file not found at %1", imageFile)
        EXIT PROGRAM 1
    END IF

    DISPLAY SFMT("OK: QR code written to %1", imageFile)
    DISPLAY SFMT("  size: %1 bytes", os.Path.size(imageFile))
    DISPLAY ""
    DISPLAY "Open it with:"
    DISPLAY SFMT("  open %1", imageFile)

END MAIN
