.PHONY: all pdf html clean help distclean view rebuild install-deps check-deps

MAIN        = index
LATEX       = latexmk
LATEX_FLAGS = -pdf -interaction=nonstopmode

BUILD_DIR   = build
HTML_DIR    = $(BUILD_DIR)/html

LATEX_PACKAGES = \
    inputenc pmboxdraw lmodern fontenc geometry xcolor \
    titlesec titletoc fancyhdr enumitem hyperref mdframed \
    array booktabs microtype parskip amsmath amssymb \
    tcolorbox fancyvrb

LATEX_PACKAGE_FILES = $(addsuffix .sty,$(LATEX_PACKAGES))

ifeq ($(OS),Windows_NT)
	OPEN_CMD   = cmd /c start ""
	RM_DIR_CMD = rm -rf
	MKDIR_CMD  = mkdir -p $(BUILD_DIR)
    OS_NAME    = Windows
else
    UNAME_S := $(shell uname -s)
    ifeq ($(UNAME_S),Linux)
        OPEN_CMD   = xdg-open
        RM_DIR_CMD = rm -rf
        MKDIR_CMD  = mkdir -p $(BUILD_DIR)
        OS_NAME    = Linux
    else ifeq ($(UNAME_S),Darwin)
        OPEN_CMD   = open
        RM_DIR_CMD = rm -rf
        MKDIR_CMD  = mkdir -p $(BUILD_DIR)
        OS_NAME    = macOS
    else
        OPEN_CMD   = echo "Não é possível abrir o PDF — SO não reconhecido. Arquivo em"
        RM_DIR_CMD = rm -rf
        MKDIR_CMD  = mkdir -p $(BUILD_DIR)
        OS_NAME    = Unknown
    endif
endif

all: pdf

check-deps:
	@echo "Verificando dependências do LaTeX..."
	@command -v $(LATEX) >/dev/null 2>&1 || { echo "ERRO: $(LATEX) não encontrado. Instale TeX Live, MiKTeX ou MacTeX primeiro."; exit 1; }
	@command -v kpsewhich >/dev/null 2>&1 || { echo "ERRO: kpsewhich não encontrado. A instalação do TeX está incompleta."; exit 1; }
	@missing=""; \
	for pkg in $(LATEX_PACKAGE_FILES); do \
	    if ! kpsewhich "$$pkg" >/dev/null 2>&1; then \
	        missing="$$missing $$pkg"; \
	    fi; \
	done; \
	if [ -n "$$missing" ]; then \
	    echo "ERRO: Pacotes ausentes:$$missing"; \
	    echo "Execute 'make install-deps' ou instale-os via gerenciador do seu sistema (apt, dnf, etc)."; \
	    exit 1; \
	fi
	@echo "  ✓ Todas as dependências do LaTeX estão OK!"

install-deps:
	@echo "Tentando instalar pacotes LaTeX ausentes..."
	@if command -v tlmgr >/dev/null 2>&1; then \
	    echo "  TeX Live detectado. Executando tlmgr..."; \
	    tlmgr install $(LATEX_PACKAGES) || { \
	        echo ""; \
	        echo "  ATENÇÃO: Se o tlmgr falhou no Linux, o gerenciador de pacotes da sua distro pode estar bloqueando-o."; \
	        echo "  Neste caso, instale os pacotes pelo sistema. Exemplo no Ubuntu/Debian:"; \
	        echo "  sudo apt install texlive-latex-extra texlive-science texlive-fonts-recommended"; \
	    }; \
	elif command -v miktex >/dev/null 2>&1; then \
	    echo "  MiKTeX detectado. Instalando via miktex CLI..."; \
	    for pkg in $(LATEX_PACKAGES); do \
	        miktex packages install "$$pkg" || echo "  Pacote $$pkg: já instalado ou ignorado"; \
	    done; \
	else \
	    echo "ERRO: Nenhum gerenciador de pacotes TeX suportado (tlmgr ou miktex) encontrado."; \
	    echo "Recomendamos instalar uma distribuição TeX completa:"; \
	    echo "  Windows : MiKTeX (https://miktex.org) ou TeX Live"; \
	    echo "  Linux   : sudo apt install texlive-full (Ubuntu/Debian)"; \
	    echo "  macOS   : brew install --cask mactex"; \
	    exit 1; \
	fi
	@echo "  ✓ Processo de instalação finalizado!"

$(BUILD_DIR)/$(MAIN).pdf: $(MAIN).tex
	@$(MKDIR_CMD)
	$(LATEX) $(LATEX_FLAGS) -output-directory=$(BUILD_DIR) $(MAIN).tex

pdf: check-deps $(BUILD_DIR)/$(MAIN).pdf

html: check-deps
	@mkdir -p docs
	@if command -v make4ht >/dev/null 2>&1; then \
		echo "Compilando HTML com make4ht..."; \
		make4ht -d docs $(MAIN).tex; \
	elif command -v htlatex >/dev/null 2>&1; then \
		echo "Compilando HTML com htlatex..."; \
		cd docs && htlatex ../$(MAIN).tex; \
	else \
		echo "ERRO: make4ht/htlatex não encontrados."; exit 1; \
	fi
	@echo "  ✓ HTML gerado em docs/"	

view: pdf
	@echo "Abrindo $(BUILD_DIR)/$(MAIN).pdf no $(OS_NAME)..."
	@$(OPEN_CMD) $(BUILD_DIR)/$(MAIN).pdf

clean:
	@echo "Limpando arquivos auxiliares..."
	@$(LATEX) -c -output-directory=$(BUILD_DIR) $(MAIN).tex >/dev/null 2>&1 || true

distclean: clean
	@echo "Removendo o diretório de build e PDF gerado..."
	@$(LATEX) -C -output-directory=$(BUILD_DIR) $(MAIN).tex >/dev/null 2>&1 || true
	@$(RM_DIR_CMD) $(BUILD_DIR) >/dev/null 2>&1 || true

rebuild: distclean pdf

help:
	@echo "=== Clube de Matemática — Makefile ==="
	@echo ""
	@echo "  Sistema operacional detectado : $(OS_NAME)"
	@echo ""
	@echo "Targets:"
	@echo "  make install-deps   Tenta instalar pacotes LaTeX necessários"
	@echo "  make check-deps     Verifica se as dependências estão instaladas"
	@echo "  make  (ou make pdf) Compila para PDF (padrão; verifica deps)"
	@echo "  make html           Compila para HTML em build/html"
	@echo "  make view           Compila e abre o PDF"
	@echo "  make clean          Remove arquivos auxiliares do build"
	@echo "  make distclean      Remove tudo, incluindo o PDF gerado"
	@echo "  make rebuild        distclean + pdf"
	@echo "  make help           Exibe esta mensagem"
	@echo ""
	@echo "Uso típico (primeira vez):"
	@echo "  make install-deps && make view"
