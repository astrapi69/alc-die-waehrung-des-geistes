# Makefile fuer dein Adaptive-Learner-Content-Repo.
#
# Ein Befehl genuegt zum Loslegen:
#
#     make validate        Prueft deine Inhalte (legt beim ersten Mal automatisch
#                          eine lokale Python-Umgebung an, du musst nichts installieren).
#
# Weitere Ziele:
#     make setup           Nur die lokale Umgebung anlegen/aktualisieren.
#     make generate        KI-Aufgaben generieren (braucht einen API-Schluessel, siehe README).
#     make audit           Ueberblick ueber deine Inhalte ausgeben.
#     make clean           Die lokale Umgebung entfernen.
#
# Du brauchst nur "make" und "python3". Kein pip, kein venv, kein Poetry von Hand.
# Kein "make" auf deinem System (z. B. Windows ohne WSL)? Dann committe deine
# Aenderungen und lass die GitHub-Actions-CI validieren, sie prueft dasselbe.

VENV := .venv
PY := $(VENV)/bin/python
PIP := $(VENV)/bin/pip

.PHONY: validate setup generate audit clean help

help:
	@echo "make validate   - Inhalte pruefen (richtet sich beim ersten Mal selbst ein)"
	@echo "make setup      - lokale Umgebung anlegen"
	@echo "make generate   - KI-Aufgaben generieren (API-Schluessel noetig)"
	@echo "make audit      - Inhalts-Ueberblick"
	@echo "make clean      - lokale Umgebung entfernen"

# Die lokale Umgebung. Wird nur angelegt, wenn sie fehlt.
$(VENV)/.ready:
	@echo ">> Lege lokale Python-Umgebung an (einmalig) ..."
	python3 -m venv $(VENV)
	@$(PIP) install --quiet --upgrade pip
	@$(PIP) install --quiet pyyaml jsonschema
	@touch $(VENV)/.ready
	@echo ">> Fertig. Kuenftige Laeufe nutzen diese Umgebung direkt."

setup: $(VENV)/.ready

validate: $(VENV)/.ready
	@$(PY) scripts/validate_content.py

generate: $(VENV)/.ready
	@$(PY) scripts/generate_exercises.py $(ARGS)

audit: $(VENV)/.ready
	@$(PY) scripts/audit_content.py

clean:
	rm -rf $(VENV)
