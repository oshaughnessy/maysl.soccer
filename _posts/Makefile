DATESTAMP=$(shell date +%Y-%m-%d)

%:
	[ ! -f $(DATESTAMP)-$@.md ] && { printf -- "---\ntitle: \ntag: \n---\n\n" >> $(DATESTAMP)-$@.md; } || true
	vim $(DATESTAMP)-$@.md
