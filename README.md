# qrcode4rp

A Genero BDL package for generating QR codes natively via a Genero
Report (`.4rp`) `BARCODEBOX` — no external API, no internet, no Java
dependencies beyond the Genero Report Engine (GRE).

- Package: `com.fourjs.qrcode4rp`
- Genero versions supported: 4.x, 5.x, 6.x
- PNG output, 6×6 inch page, file path returned to caller
- Bring-your-own `.4rp` template supported via env var / fglprofile
- Companion to [`qrcode`](https://github.com/4js-mikefolcher/qrcode) (goqr.me API client)

## Install

```bash
fglpkg install qrcode4rp
```

## Quick example

```4gl
IMPORT FGL com.fourjs.qrcode4rp.QRCodeInterface

MAIN
    DEFINE imageFile STRING

    LET imageFile = generateQRCode("https://www.4js.com")

    IF imageFile IS NOT NULL THEN
        DISPLAY "Saved: ", imageFile
        -- ...display, embed, or attach the image here...
        CALL cleanupQRCode()
    ELSE
        DISPLAY "Failed to generate QR code"
    END IF
END MAIN
```

See [USERGUIDE.md](USERGUIDE.md) for the full API reference, configuration
details, and troubleshooting.

## Why this package

If you already have the Genero Report Engine licensed and running, you
don't need an external QR code service. `qrcode4rp` piggy-backs on
GRE's built-in `BARCODEBOX` support to rasterise a QR code to a PNG
using the same report infrastructure you already use for invoices,
statements, and other output.

Compared with an API-based approach:

- **No network dependency** — works offline, no rate limits, no ToS.
- **No per-call cost** — free once GRE is licensed.
- **Customisable layout** — swap the bundled `.4rp` for one with your
  own branding, caption text, or embedding inside a larger report.

Downsides:

- Requires GRE to be present and reachable via `FGLLDPATH`.
- Currently PNG only, 6×6 inch page. Other sizes/formats require
  editing `QRReport.4rp` (or supplying a replacement).

## Configuration

`generateQRCode()` looks up the template file in this order:

1. Environment variable `QR_REPORT_4RP`
2. fglprofile entry `qr.report.4rp`
3. Default: `com/fourjs/qrcode4rp/QRReport.4rp` on `FGLLDPATH` or `pwd`

See [USERGUIDE.md](USERGUIDE.md#configuration) for details.

## Demo program

```bash
fglpkg bdl qrcode4rp test_qrcode4rp https://www.4js.com
```

or after `make`:

```bash
fglrun com/fourjs/qrcode4rp/test_qrcode4rp.42m 'https://github.com/4js-mikefolcher/qrcode4rp'
```

## License

MIT
