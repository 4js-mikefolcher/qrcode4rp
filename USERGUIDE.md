# qrcode4rp — User Guide

Generate QR codes natively inside Genero using a Genero Report (`.4rp`)
with a `BARCODEBOX` of type `qr-code`. No external API, no internet,
no Java dependencies beyond the Genero Report Engine (GRE) that ships
with your Genero installation.

- **Package**: `com.fourjs.qrcode4rp`
- **Modules**: `QRCodeConfig` (locating the 4RP), `QRCodeInterface` (public API)
- **Renderer**: GRE Image device (PNG output)
- **Output**: absolute path to a PNG on disk (caller consumes, then calls cleanup)
- **Genero support**: 4.x, 5.x, 6.x

## Contents

- [Installation](#installation)
- [Quick start](#quick-start)
- [Public API](#public-api)
- [Configuration](#configuration)
- [How it works](#how-it-works)
- [Demo program](#demo-program)
- [Troubleshooting](#troubleshooting)

## Installation

```bash
fglpkg install qrcode4rp
```

Runtime prerequisites:

- A licensed Genero Report Engine (`greruntime.42m` must be reachable via
  `FGLLDPATH`). The package itself has no JAR or native dependencies
  beyond what GRE already requires.

## Quick start

```4gl
IMPORT FGL com.fourjs.qrcode4rp.QRCodeInterface

MAIN
    DEFINE imageFile STRING

    LET imageFile = generateQRCode("https://www.4js.com")

    IF imageFile IS NOT NULL THEN
        DISPLAY "Saved: ", imageFile
        -- ...display the image in your form, attach to an email, etc.
        CALL cleanupQRCode()
    ELSE
        DISPLAY "Failed to generate QR code"
    END IF
END MAIN
```

## Public API

### `generateQRCode(qrURI STRING) RETURNS STRING`

Renders a PNG QR code encoding `qrURI` and returns the absolute path
to the generated file. Returns `NULL` on failure (missing 4RP, GRE
settings failed to load, report engine failed, image not produced).

The image is written to a freshly-created temp directory under the
system temp location (via `os.Path.makeTempName()`), with filename
pattern `QRCode_NNNN.png`. The module keeps a record of the last
generated file so `cleanupQRCode()` can remove it on demand.

Currently fixed output parameters:

| Parameter  | Value       |
|------------|-------------|
| Format     | `png`       |
| Page size  | 6 inch × 6 inch |
| File prefix| `QRCode_`   |

### `cleanupQRCode() RETURNS ()`

Deletes the PNG produced by the most recent `generateQRCode()` call,
if it still exists on disk. Safe to call multiple times or before
any generate — it is a no-op if there is nothing to delete. Does not
remove the temp directory itself.

Call this once you have finished using the image (displayed it,
attached it, base64-encoded it, etc.) to avoid leaving files in the
system temp area.

### `getQR4RPFile() RETURNS STRING`

Returns the absolute path of the QR code template (`QRReport.4rp`),
resolved using the precedence described in [Configuration](#configuration).
Returns `NULL` (empty string) if no template can be located.

Normal callers do not need this — `generateQRCode()` calls it
internally. Exposed for diagnostics and for applications that embed
the QR report inside a larger report pipeline.

## Configuration

`getQR4RPFile()` resolves the template path in the following order,
returning the first non-null result:

1. A cached value from a previous call in the same process.
2. The environment variable **`QR_REPORT_4RP`**, if set.
3. The fglprofile entry **`qr.report.4rp`**, if defined.
4. **Default lookup:** searches the current working directory and
   every entry in `FGLLDPATH` for a file at
   `com/fourjs/qrcode4rp/QRReport.4rp`. Returns the first hit.

### Examples

Override via environment variable:

```bash
export QR_REPORT_4RP=/opt/reports/branded_qrcode.4rp
fglrun myapp.42m
```

Override via fglprofile (in your resource file):

```
qr.report.4rp = "/opt/reports/branded_qrcode.4rp"
```

Use the default bundled template — no configuration needed as long as
the package directory `com/fourjs/qrcode4rp/` is reachable from
`FGLLDPATH` or the current working directory.

## How it works

1. `generateQRCode()` resolves the 4RP path via `getQR4RPFile()`.
2. A new temp directory is created with `os.Path.makeTempName()` +
   `os.Path.mkdir()` to hold the output.
3. GRE is configured for the **Image** device (`fgl_report_selectDevice`),
   6×6 inch page (`fgl_report_configurePageSize`), PNG output
   (`fgl_report_configureImageDevice` with `imageDir` and prefix
   `QRCode_`).
4. `fgl_report_commitCurrentSettings()` returns a SAX handler.
5. The private report `rptQRCode(authUri STRING)` is started against
   that handler, one row is output (`authUri = qrURI`), and the report
   is finished.
6. The `.4rp` stylesheet contains a single `BARCODEBOX` with
   `codeType="qr-code"` and `codeValue="{{authUri}}"`, so GRE
   rasterises the QR as a PNG.
7. The module globs `imageDir/QRCode_*.png` and returns the last
   matching file.

The `.4rp` template uses this stylesheet snippet (see
[QRReport.4rp](QRReport.4rp)):

```xml
<BARCODEBOX name="BarCodeBox"
            width="max" anchorX="0" anchorY="0"
            alignment="center" floatingBehavior="enclosed"
            codeType="qr-code"
            codeValue="{{authUri}}"/>
```

Bring your own `.4rp` if you want to change the QR size, add a
caption, change the page dimensions, or embed the QR code inside a
larger report layout — just point `QR_REPORT_4RP` or `qr.report.4rp`
at your custom file.

## Demo program

The package ships with `test_qrcode4rp`:

```bash
fglpkg bdl qrcode4rp test_qrcode4rp https://www.4js.com
```

or, when already built locally:

```bash
fglrun com/fourjs/qrcode4rp/test_qrcode4rp.42m 'https://github.com/4js-mikefolcher/qrcode4rp'
```

It encodes the command-line argument (or `https://www.4js.com` when
none is given), prints the generated PNG path, and leaves the file
in place so it can be opened with an image viewer.

Example output:

```
Encoding: https://github.com/4js-mikefolcher/qrcode4rp

OK: QR code written to /var/folders/.../T/fgl00065102/QRCode_0001.png
  size: 20848 bytes

Open it with:
  open /var/folders/.../T/fgl00065102/QRCode_0001.png
```

## Troubleshooting

**`The 42m module 'greruntime' could not be loaded`**
The Genero Report Engine is not on `FGLLDPATH`. Add the GRE `lib`
directory (where `greruntime.42m` lives) to `FGLLDPATH`, e.g.
`FGLLDPATH=.:$GREDIR/lib`.

**`generateQRCode` returns `NULL` and no output is produced**
Most commonly caused by the template lookup failing. Verify by calling
`getQR4RPFile()` directly — if it returns an empty string, neither
`QR_REPORT_4RP`, `qr.report.4rp`, nor the default `com/fourjs/qrcode4rp/`
lookup matched. Check that the package directory is on `FGLLDPATH`
(or the current working directory) and that `QRReport.4rp` was copied
into it during the build.

**`ERROR "Failed to find report file"`**
GRE ran to completion but no `QRCode_*.png` appeared in the temp
directory. Usually indicates the GRE is licensed for design-time
only, or the `.4rp` template is malformed. Try rendering the same
`.4rp` from Genero Report Writer / Studio to verify the template
is valid.

**The temp PNG disappears immediately after `generateQRCode()`**
You (or a library you're calling) invoked `cleanupQRCode()` too
early. Only call cleanup once the image has been consumed — embedded
in a form, saved elsewhere, attached to an email, etc.

## License

MIT
