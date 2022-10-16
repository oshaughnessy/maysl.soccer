DATESTAMP=$(shell date +%Y-%m-%d)

%:
	[ ! -f $(DATESTAMP)-$@.md ] && { printf -- "---\ntitle: \ntags: \n---\n\n" >> $(DATESTAMP)-$@.md; } || true
	vim $(DATESTAMP)-$@.md
