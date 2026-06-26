# Clube de Matemática 42 São Paulo

Regimento oficial do Clube de Matemática da 42 School unidade São Paulo.

## 📋 Sobre

Este repositório contém o regimento (estatuto) do Clube de Matemática, um grupo de estudos dedicado ao desenvolvimento colaborativo e compartilhamento de conhecimento em matemática entre membros da comunidade 42.

O documento apresenta:

- **Princípios e valores** do clube
- **Diretrizes operacionais** e estrutura organizacional
- **Direitos e responsabilidades** dos membros
- **Processos** para atividades e tomada de decisão

## 📄 Documentação

A documentação completa está disponível em:
- **Arquivo LaTeX:** `main.tex` (modular, com `sections/` e `appendices/`)
- **PDF compilado:** `docs/index.pdf`
- **HTML:** `docs/index.html` (com dark mode e MathJax)
- **Formato:** LaTeX → PDF (pdflatex) / HTML5 (Pandoc)

## 🛠️ Como Usar

### Build completo (recomendado)

```bash
make docker-build   # Constrói a imagem (só na primeira vez)
make docker-make    # Gera PDF + HTML em docs/
```

### Compilar apenas PDF

```bash
make pdf            # Gera docs/index.pdf
```

### Compilar apenas HTML

```bash
make html           # Gera docs/index.html
```

### Abrir o PDF

```bash
make view           # Abre docs/index.pdf no visualizador padrão
```

### Limpeza

```bash
make docker-clean   # Remove docs/ inteiro
make clean          # Remove artefatos temporários (.build, .tikz_build)
```

### Requisitos

- **Docker** (qualquer versão recente)

> Todo o toolchain (TeXLive, Pandoc, Python, dvisvgm) roda dentro do container.
> **Nenhuma dependência LaTeX no host é necessária.**

## 📝 Estrutura do Projeto

```
club-charter/
├── main.tex                          # Documento principal (agrega includes, sections, appendices)
├── includes.tex                      # Preâmbulo LaTeX (pacotes, cores, fancyhdr, tcolorbox)
├── resourcers.tex                    # Logos e recursos gráficos (\logoClube com \includesvg)
├── sections/                         # Seções do estatuto (01 a 06)
├── appendices/                       # Apêndices (A a C)
├── resources/                        # SVGs das logos (42SPcm, 42SPcm_back)
├── tools/                            # Scripts de build (preprocess-tex.py, html-extra.lua)
├── Dockerfile                        # Imagem com TeXLive + Pandoc 3.1.11
├── Makefile                          # Targets: docker-build, docker-make, pdf, html, style, clean
├── docs/                             # Output: PDF + HTML + CSS + resources copiados
├── README.md
├── LICENSE
└── .gitignore
```

## 🤝 Contribuindo

Para sugestões ou correções no regimento:

1. Faça um fork do repositório
2. Crie uma branch para sua alteração (`git checkout -b melhoria/descricao`)
3. Commit suas mudanças (`git commit -m 'Adiciona melhorias'`)
4. Push para a branch (`git push origin melhoria/descricao`)
5. Abra um Pull Request

## 📜 Licença

Veja o arquivo [LICENSE](LICENSE) para detalhes.
