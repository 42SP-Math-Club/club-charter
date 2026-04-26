.PHONY: all pdf clean help distclean view rebuild

MAIN = math-club-charter
LATEX = latexmk
LATEX_FLAGS = -pdf -interaction=nonstopmode -outdir=build

BUILD_DIR = build

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

pdf: $(MAIN).tex
	@mkdir -p $(BUILD_DIR)
	$(LATEX) $(LATEX_FLAGS) $(MAIN).tex

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
	@echo "  make          - Compila para PDF (padrão)"
	@echo "  make pdf      - Compila LaTeX para PDF"
	@echo "  make view     - Compila e abre o PDF"
	@echo "  make clean    - Remove arquivos temporários"
	@echo "  make distclean - Remove tudo (temporários + PDF)"
	@echo "  make rebuild  - Recompila do zero"
	@echo "  make help     - Mostra esta mensagem"
	@echo ""
	@echo "Exemplos de uso:"
	@echo "  make          # Compila para PDF"
	@echo "  make view     # Compila e abre PDF"
	@echo "  make clean    # Remove temporários"
