# Clube de Matemática @ 42 São Paulo

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
- **Arquivo LaTeX:** `math-club-charter.tex`
- **PDF compilado:** `build/math-club-charter.pdf`
- **Formato:** LaTeX / PDF

## 🛠️ Como Usar

### Compilar o Documento PDF

Você pode compilar o documento de duas formas:

**Opção 1: Usando Make (recomendado)**

```bash
# Compilar
make pdf

# Compilar e abrir o PDF
make view

# Limpar arquivos temporários
make clean

# Ver todos os targets disponíveis
make help
```

**Opção 2: Linha de comando**

```bash
latexmk -pdf math-club-charter.tex
```

### Requisitos

- Uma distribuição LaTeX (TeX Live, MiKTeX, MacTeX, etc.)
- `latexmk` (geralmente vem com distribuições LaTeX)
- `make` (ou `mingw-make` no Windows)
- Pacotes LaTeX: `geometry`, `xcolor`, `titlesec`, `hyperref`, `mdframed`, `tcolorbox`, `amsmath`, `amssymb`

## 📝 Estrutura do Projeto

```
club-charter/
├── README.md                         # Este arquivo
├── .gitignore                        # Arquivos ignorados pelo Git  
├── Makefile                          # Automatização de compilação
├── LICENSE                           # Licença do projeto
├── math-club-charter.tex             # Documento principal em LaTeX
└── build/
    └── math-club-charter.pdf         # PDF compilado
```

**Nota:** A pasta `build/` contém apenas o PDF final. Arquivos temporários de compilação são ignorados pelo Git.

## 🤝 Contribuindo

Para sugestões ou correções no regimento:

1. Faça um fork do repositório
2. Crie uma branch para sua alteração (`git checkout -b melhoria/descricao`)
3. Commit suas mudanças (`git commit -m 'Adiciona melhorias'`)
4. Push para a branch (`git push origin melhoria/descricao`)
5. Abra um Pull Request

## 📜 Licença

Veja o arquivo [LICENSE](LICENSE) para detalhes.
