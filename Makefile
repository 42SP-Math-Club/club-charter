.PHONY: all pdf clean help distclean view rebuild install-deps check-deps

MAIN = math-club-charter
LATEX = latexmk
LATEX_FLAGS = -pdf -interaction=nonstopmode

BUILD_DIR = build

LATEX_PACKAGES = inputenc pmboxdraw lmodern fontenc geometry xcolor titlesec titletoc fancyhdr enumitem hyperref mdframed array booktabs microtype parskip amsmath amssymb tcolorbox fancyvrb

ifeq ($(OS),Windows_NT)
    OPEN_CMD = cmd /c start
    OS_NAME = Windows
else
    UNAME_S := $(shell uname -s)
    ifeq ($(UNAME_S),Linux)
        OPEN_CMD = xdg-open
        OS_NAME = Linux
    endif
    ifeq ($(UNAME_S),Darwin)
        OPEN_CMD = open
        OS_NAME = macOS
    endif
endif

all: pdf

check-deps:
	@echo "Checking LaTeX dependencies..."
	@command -v latexmk >/dev/null 2>&1 || (echo "ERROR: latexmk not found. Please install TeX Live or MiKTeX first." && exit 1)
	@if command -v tlmgr >/dev/null 2>&1; then \
		echo "TeX Live detected. Verifying packages..."; \
		for pkg in $(LATEX_PACKAGES); do \
			tlmgr list --only-installed $$pkg 2>/dev/null | grep -q $$pkg || (echo "ERROR: Package '$$pkg' not installed. Run 'make install-deps'." && exit 1); \
		done; \
	elif command -v mpm >/dev/null 2>&1; then \
		echo "MiKTeX detected. Verifying packages..."; \
		for pkg in $(LATEX_PACKAGES); do \
			mpm --list --package=$$pkg 2>/dev/null | grep -q $$pkg || (echo "WARNING: Could not verify package '$$pkg' with mpm. Proceeding anyway."); \
		done; \
	else \
		echo "ERROR: Neither tlmgr (TeX Live) nor mpm (MiKTeX) found. Please install a TeX distribution."; \
		exit 1; \
	fi
	@echo "✓ All LaTeX dependencies OK"

install-deps:
	@echo "Installing LaTeX packages..."
	@if command -v tlmgr >/dev/null 2>&1; then \
		echo "TeX Live found. Installing packages with tlmgr..."; \
		tlmgr install --yes $(LATEX_PACKAGES) || echo "Some packages may already be installed"; \
	elif command -v mpm >/dev/null 2>&1; then \
		echo "MiKTeX found. Installing packages with mpm..."; \
		mpm --admin update --admin || echo "MiKTeX admin update skipped"; \
		for pkg in $(LATEX_PACKAGES); do \
			mpm --admin install $$pkg || echo "Package $$pkg: already installed or skipped"; \
		done; \
	else \
		echo "ERROR: Neither tlmgr (TeX Live) nor mpm (MiKTeX) found."; \
		echo ""; \
		echo "Please install a TeX distribution:"; \
		echo "  Windows: MiKTeX (https://miktex.org/download) or TeX Live (https://tug.org/texlive/windows.html)"; \
		echo "  Linux:   TeX Live (apt-get install texlive-full)"; \
		echo "  macOS:   MacTeX/TeX Live (brew install mactex-basic)"; \
		echo ""; \
		echo "After installing, run 'make install-deps' again."; \
		exit 1; \
	fi
	@echo "LaTeX packages ready!"

pdf: check-deps $(MAIN).tex
	@mkdir -p $(BUILD_DIR)
	$(LATEX) $(LATEX_FLAGS) $(MAIN).tex -outdir=$(BUILD_DIR)

clean:
	$(LATEX) -c -outdir=$(BUILD_DIR) $(MAIN).tex

distclean:
	$(LATEX) -C -outdir=$(BUILD_DIR) $(MAIN).tex

view: pdf
	@echo "Abrindo $(MAIN).pdf no $(OS_NAME)..."
	@$(OPEN_CMD) $(BUILD_DIR)/$(MAIN).pdf

rebuild: clean pdf

help:
	@echo "=== Clube de Matemática - Makefile ==="
	@echo ""
	@echo "Sistema Operacional detectado: $(OS_NAME)"
	@echo ""
	@echo "Targets disponíveis:"
	@echo "  make install-deps - Instala dependências LaTeX"
	@echo "  make check-deps   - Verifica se as dependências estão instaladas"
	@echo "  make          - Compila para PDF (padrão, verifica deps)"
	@echo "  make pdf      - Compila LaTeX para PDF"
	@echo "  make view     - Compila e abre o PDF"
	@echo "  make clean    - Remove arquivos temporários"
	@echo "  make distclean - Remove tudo (temporários + PDF)"
	@echo "  make rebuild  - Recompila do zero"
	@echo "  make help     - Mostra esta mensagem"
	@echo ""
	@echo "Exemplos de uso:"
	@echo "  make install-deps # Instala pacotes LaTeX (primeira vez)"
	@echo "  make          # Compila para PDF"
	@echo "  make view     # Compila e abre PDF"
	@echo "  make clean    # Remove temporários"
