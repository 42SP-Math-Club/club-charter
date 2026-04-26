.PHONY: all pdf clean help distclean view rebuild install-deps check-deps

MAIN        = math-club-charter
LATEX       = latexmk
LATEX_FLAGS = -pdf -interaction=nonstopmode

BUILD_DIR   = build

LATEX_PACKAGES = \
    inputenc pmboxdraw lmodern fontenc geometry xcolor \
    titlesec titletoc fancyhdr enumitem hyperref mdframed \
    array booktabs microtype parskip amsmath amssymb \
    tcolorbox fancyvrb

LATEX_PACKAGE_FILES = $(addsuffix .sty,$(LATEX_PACKAGES))

ifeq ($(OS),Windows_NT)
    OPEN_CMD = cmd /c start ""
    OS_NAME  = Windows
else
    UNAME_S := $(shell uname -s)
    ifeq ($(UNAME_S),Linux)
        OPEN_CMD = xdg-open
        OS_NAME  = Linux
    else ifeq ($(UNAME_S),Darwin)
        OPEN_CMD = open
        OS_NAME  = macOS
    else
        OPEN_CMD = echo "Cannot open PDF — unrecognised OS. File is at"
        OS_NAME  = Unknown
    endif
endif

all: pdf

check-deps:
	@echo "Checking LaTeX dependencies..."
	@command -v latexmk >/dev/null 2>&1 \
	    || { echo "ERROR: latexmk not found. Install TeX Live or MiKTeX first."; exit 1; }
	@command -v kpsewhich >/dev/null 2>&1 \
	    || { echo "ERROR: kpsewhich not found. TeX tools are incomplete."; exit 1; }
	@if command -v tlmgr >/dev/null 2>&1; then \
	    echo "  ✓ TeX Live detected"; \
	elif command -v miktex >/dev/null 2>&1 || command -v mpm >/dev/null 2>&1; then \
	    echo "  ✓ MiKTeX detected"; \
	else \
	    echo "ERROR: Neither tlmgr (TeX Live) nor MiKTeX CLI found."; \
	    exit 1; \
	fi
	@missing=""; \
	for pkg in $(LATEX_PACKAGE_FILES); do \
	    if ! kpsewhich "$$pkg" >/dev/null 2>&1; then \
	        missing="$$missing $$pkg"; \
	    fi; \
	done; \
	if [ -n "$$missing" ]; then \
	    echo "ERROR: Missing packages:$$missing"; \
	    echo "Run 'make install-deps' to install them."; \
	    exit 1; \
	fi
	@echo "  ✓ All LaTeX dependencies OK"

install-deps:
	@echo "Installing LaTeX packages..."
	@if command -v tlmgr >/dev/null 2>&1; then \
	    echo "  TeX Live — installing with tlmgr..."; \
	    tlmgr install $(LATEX_PACKAGES) \
	        || echo "  (Some packages may already be installed — that is fine)"; \
	elif command -v miktex >/dev/null 2>&1; then \
	    echo "  MiKTeX — installing with miktex CLI..."; \
	    for pkg in $(LATEX_PACKAGES); do \
	        miktex packages install "$$pkg" \
	            || echo "  Package $$pkg: already installed or skipped"; \
	    done; \
	elif command -v mpm >/dev/null 2>&1; then \
	    echo "  MiKTeX (legacy mpm) — installing..."; \
	    for pkg in $(LATEX_PACKAGES); do \
	        mpm --install "$$pkg" \
	            || echo "  Package $$pkg: already installed or skipped"; \
	    done; \
	else \
	    echo "ERROR: No supported TeX package manager found."; \
	    echo ""; \
	    echo "Install a TeX distribution and re-run 'make install-deps':"; \
	    echo "  Windows : MiKTeX  https://miktex.org/download"; \
	    echo "            TeX Live https://tug.org/texlive/windows.html"; \
	    echo "  Linux   : sudo apt-get install texlive-full"; \
	    echo "  macOS   : brew install --cask mactex  (or mactex-no-gui)"; \
	    exit 1; \
	fi
	@echo "  ✓ LaTeX packages ready!"

$(BUILD_DIR)/$(MAIN).pdf: $(MAIN).tex
	@mkdir -p $(BUILD_DIR)
	$(LATEX) $(LATEX_FLAGS) -output-directory=$(BUILD_DIR) $(MAIN).tex

pdf: check-deps $(BUILD_DIR)/$(MAIN).pdf

view: pdf
	@echo "Opening $(BUILD_DIR)/$(MAIN).pdf on $(OS_NAME)..."
	$(OPEN_CMD) $(BUILD_DIR)/$(MAIN).pdf

clean:
	@[ -d $(BUILD_DIR) ] \
	    && $(LATEX) -c -output-directory=$(BUILD_DIR) $(MAIN).tex \
	    || echo "Nothing to clean."

distclean:
	@[ -d $(BUILD_DIR) ] \
	    && $(LATEX) -C -output-directory=$(BUILD_DIR) $(MAIN).tex \
	    || echo "Nothing to remove."
	@rm -rf $(BUILD_DIR)

rebuild: distclean pdf

help:
	@echo "=== Clube de Matemática — Makefile ==="
	@echo ""
	@echo "  Sistema operacional detectado : $(OS_NAME)"
	@echo ""
	@echo "Targets:"
	@echo "  make install-deps   Instala pacotes LaTeX necessários"
	@echo "  make check-deps     Verifica se as dependências estão instaladas"
	@echo "  make  (ou make pdf) Compila para PDF (padrão; verifica deps)"
	@echo "  make view           Compila e abre o PDF"
	@echo "  make clean          Remove arquivos auxiliares do build"
	@echo "  make distclean      Remove tudo, incluindo o PDF gerado"
	@echo "  make rebuild        distclean + pdf"
	@echo "  make help           Exibe esta mensagem"
	@echo ""
	@echo "Uso típico (primeira vez):"
	@echo "  make install-deps && make view"