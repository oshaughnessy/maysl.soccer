DATESTAMP=$(shell date +%Y-%m-%d)

%:
	[ ! -f $(DATESTAMP)-$@ ] && printf -- "---\ntitle: \ntag: \n---\n\n" >> $(DATESTAMP)-$@.md
	vim $(DATESTAMP)-$@.md
