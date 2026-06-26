DOCS_DIR    := docs
CSS_FILE    := $(DOCS_DIR)/style.css
TARGET_HTML := $(DOCS_DIR)/index.html
TARGET_PDF  := $(DOCS_DIR)/index.pdf
TOOLS_DIR   := tools
BUILD_DIR   := .build

LATEX       := pdflatex
LATEX_FLAGS := -shell-escape -interaction=nonstopmode

LATEX_PACKAGES = \
    inputenc pmboxdraw lmodern fontenc geometry xcolor \
    titlesec titletoc fancyhdr enumitem hyperref mdframed \
    array booktabs microtype parskip amsmath amssymb \
    tcolorbox fancyvrb svg

LATEX_PACKAGE_FILES = $(addsuffix .sty,$(LATEX_PACKAGES))

DOCKER_IMAGE := charter-builder

ifeq ($(OS),Windows_NT)
	OPEN_CMD   = cmd /c start ""
	RM_DIR_CMD = rm -rf
	OS_NAME    = Windows
else
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S),Linux)
		OPEN_CMD   = xdg-open
		RM_DIR_CMD = rm -rf
		OS_NAME    = Linux
	else ifeq ($(UNAME_S),Darwin)
		OPEN_CMD   = open
		RM_DIR_CMD = rm -rf
		OS_NAME    = macOS
	else
		OPEN_CMD   = echo "Não é possível abrir o PDF — SO não reconhecido. Arquivo em"
		RM_DIR_CMD = rm -rf
		OS_NAME    = Unknown
	endif
endif

.PHONY: all style pdf html clean distclean \
        check-deps install-deps view help \
        docker-build docker-make docker-clean

all: style pdf html
	@echo "  ✓ Build completo: PDF e HTML em $(DOCS_DIR)/"

style:
	@mkdir -p $(DOCS_DIR)
	@printf '%s\n' \
	    ':root { --bg: #ffffff; --surface: #f1f5f9; --text: #1e293b; --muted: #64748b; --accent: #1F3A8A; --accent-light: #2563eb; --code-bg: #f8fafc; --code-border: #e2e8f0; --code-text: #1e293b; }' \
	    ':root.dark-mode { --bg: #0f1117; --surface: #1a1d27; --text: #e2e8f0; --muted: #94a3b8; --accent: #1F3A8A; --accent-light: #3b82f6; --code-bg: #13161f; --code-border: #2d3142; --code-text: #e2e8f0; }' \
	    'body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; background: var(--bg); color: var(--text); max-width: 900px; margin: 0 auto; padding: 2rem; line-height: 1.5; }' \
	    'h1, h2, h3 { color: var(--text); font-weight: 700; margin-top: 2rem; }' \
	    'a { color: var(--accent-light); text-decoration: none; }' \
	    'a:hover { text-decoration: underline; }' \
	    '.center { text-align: center; }' \
	    'header#title-block-header { border-bottom: 2px solid var(--accent); margin-bottom: 2rem; padding-bottom: 1rem; }' \
	    '.title { font-size: 2rem; color: var(--text); }' \
	    '.infobox { background: var(--surface); border-left: 4px solid var(--accent); padding: 1rem; margin: 1.5rem 0; border-radius: 4px; }' \
	    '.alertbox { background: rgba(239, 68, 68, 0.1); border: 1px solid #ef4444; border-left: 5px solid #ef4444; padding: 1rem; margin: 1.5rem 0; border-radius: 4px; }' \
	    '.citacao { background: rgba(255,255,255,0.02); border-left: 3px solid var(--muted); padding: 0.5rem 1rem; font-style: italic; margin: 1rem 0; }' \
	    'pre { background: var(--code-bg); border: 1px solid var(--code-border); border-radius: 4px; padding: 1rem; overflow-x: auto; font-size: 0.85rem; color: var(--code-text); }' \
	    'code { font-family: "Fira Code", "Cascadia Code", "JetBrains Mono", "Consolas", monospace; font-size: 0.9em; }' \
	    'pre code { background: none; padding: 0; border: none; }' \
	    '.code-caption { font-size: 0.85rem; color: var(--muted); margin-top: 0.25rem; text-align: center; }' \
	    'table { border-collapse: collapse; width: 100%; margin: 1.5rem 0; }' \
	    'th, td { padding: 0.5rem 1rem; border: 1px solid var(--code-border); }' \
	    'th { background: var(--surface); color: var(--text); font-weight: 700; }' \
	    'td { background: var(--bg); }' \
	    'img { max-width: 100%; height: auto; }' \
	    '.site-header { display: flex; align-items: center; gap: 0.75rem; font-size: 0.85rem; color: var(--muted); margin-bottom: 2rem; padding-bottom: 0.75rem; border-bottom: 1px solid var(--code-border); }' \
	    '.theme-toggle { background: var(--surface); color: var(--text); border: 1px solid var(--code-border); border-radius: 4px; cursor: pointer; font-size: 1.1rem; padding: 4px 8px; line-height: 1; }' \
	    '.theme-toggle:hover { border-color: var(--accent-light); }' \
	    '.minipage-wrapper { display: inline-block; vertical-align: top; width: 45%; margin: 0.5rem 2%; }' \
	    '@media (max-width: 640px) {' \
	    'body { padding: 1rem; }' \
	    '}' \
	    > $(CSS_FILE)
	@echo "  ✓ CSS gerado em $(CSS_FILE)"

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

pdf: main.tex includes.tex resourcers.tex $(wildcard resources/*.svg)
	@mkdir -p $(DOCS_DIR)
	cp -r resources/* $(DOCS_DIR)/ 2>/dev/null || true
	-$(LATEX) $(LATEX_FLAGS) -output-directory=$(DOCS_DIR) -jobname=index main.tex
	-$(LATEX) $(LATEX_FLAGS) -output-directory=$(DOCS_DIR) -jobname=index main.tex
	rm -f $(DOCS_DIR)/*.aux $(DOCS_DIR)/*.log $(DOCS_DIR)/*.toc \
	      $(DOCS_DIR)/*.out $(DOCS_DIR)/*.nav $(DOCS_DIR)/*.snm
	rm -rf svg-inkscape
	@echo "  ✓ PDF gerado em $(TARGET_PDF)"

html: main.tex includes.tex resourcers.tex $(wildcard resources/*.svg)
	@mkdir -p $(DOCS_DIR) $(DOCS_DIR)/resources
	cp -r resources/* $(DOCS_DIR)/resources/ 2>/dev/null || true
	python3 $(TOOLS_DIR)/preprocess-tex.py "$(CURDIR)" "$(DOCS_DIR)" "$(BUILD_DIR)"
	pandoc $(BUILD_DIR)/main.tex -o $(TARGET_HTML) \
		--from latex --to html5 --standalone \
		--mathjax=https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-chtml-full.js \
		--css="style.css" \
		--metadata title="Regimento - Clube de Matemática 42 SP" \
		--metadata lang=pt-BR \
		--lua-filter=$(TOOLS_DIR)/html-extra.lua \
		--highlight-style=pygments
	rm -rf $(BUILD_DIR) .tikz_build
	@echo "  ✓ HTML gerado em $(TARGET_HTML)"

view: pdf
	@echo "Abrindo $(TARGET_PDF) no $(OS_NAME)..."
	@$(OPEN_CMD) $(TARGET_PDF)

clean:
	@echo "Limpando artefatos de build..."
	rm -rf $(BUILD_DIR) .tikz_build

distclean: clean
	@echo "Removendo diretório $(DOCS_DIR)..."
	rm -rf $(DOCS_DIR)

rebuild: distclean all

docker-build:
	@echo "[Docker] Construindo a imagem..."
	docker build -t $(DOCKER_IMAGE) .

docker-make:
	@echo "[Docker] Executando build completo no container..."
	docker run --rm -v "$(CURDIR)":/data $(DOCKER_IMAGE) sh -c "make distclean && make"
	docker run --rm -v "$(CURDIR)":/data alpine chown -R $(shell id -u):$(shell id -g) /data/docs
	@echo "  ✓ Permissões corrigidas para o usuário local."

docker-clean:
	@echo "[Docker] Executando distclean no container..."
	docker run --rm -v "$(CURDIR)":/data $(DOCKER_IMAGE) make distclean

help:
	@echo "=== Clube de Matemática — Makefile ==="
	@echo ""
	@echo "  Sistema operacional detectado : $(OS_NAME)"
	@echo ""
	@echo "Targets:"
	@echo "  make all             style + pdf + html"
	@echo "  make style           Gera CSS em docs/style.css"
	@echo "  make pdf             Compila PDF (via pdflatex)"
	@echo "  make html            Compila HTML (via Pandoc)"
	@echo "  make view            Abre o PDF"
	@echo "  make clean           Remove artefatos temporários"
	@echo "  make distclean       Remove docs/ inteiro"
	@echo "  make rebuild         distclean + all"
	@echo "  make check-deps      Verifica dependências LaTeX"
	@echo "  make install-deps    Tenta instalar pacotes LaTeX"
	@echo ""
	@echo "Docker (recomendado):"
	@echo "  make docker-build    Constrói a imagem Docker"
	@echo "  make docker-make     Build completo no container"
	@echo "  make docker-clean    Distclean no container"
	@echo ""
	@echo "Uso típico:"
	@echo "  make docker-build && make docker-make"
	@echo "  make docker-make     (após a primeira build)"
