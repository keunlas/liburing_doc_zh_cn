.PHONY: sync catalog check

sync:
	./scripts/sync-upstream.sh

catalog:
	./scripts/catalog.sh

check:
	./scripts/check-docs.sh

