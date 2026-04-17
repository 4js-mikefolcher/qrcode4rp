PKGDIR=com/fourjs/qrcode4rp

LIBS=\
 $(PKGDIR)/QRCodeConfig.42m\
 $(PKGDIR)/QRCodeInterface.42m\
 $(PKGDIR)/QRReport.4rp

TESTS=\
 $(PKGDIR)/test_qrcode4rp.42m

all: $(LIBS) $(TESTS)

$(PKGDIR):
	mkdir -p $(PKGDIR)

$(PKGDIR)/QRCodeConfig.42m: QRCodeConfig.4gl | $(PKGDIR)
	fglcomp -Wall -M --output-dir . QRCodeConfig.4gl

$(PKGDIR)/QRCodeInterface.42m: QRCodeInterface.4gl $(PKGDIR)/QRCodeConfig.42m | $(PKGDIR)
	fglcomp -Wall -M --output-dir . QRCodeInterface.4gl

$(PKGDIR)/QRReport.4rp: QRReport.4rp | $(PKGDIR)
	cp QRReport.4rp $(PKGDIR)/QRReport.4rp

$(PKGDIR)/test_qrcode4rp.42m: test_qrcode4rp.4gl $(PKGDIR)/QRCodeInterface.42m | $(PKGDIR)
	fglcomp -Wall -M --output-dir . test_qrcode4rp.4gl

clean::
	rm -rf com *.42m *.42f

ARGS ?=

test: $(PKGDIR)/test_qrcode4rp.42m $(PKGDIR)/QRReport.4rp
	fglrun $(PKGDIR)/test_qrcode4rp.42m $(ARGS)
