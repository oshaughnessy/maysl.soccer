QR_URL := https://maysl.soccer/

help:
	@echo try "qr"

maysl-qr.%:
	qrencode -s 10 -l H -t $* -o $@ $(QR_URL)
