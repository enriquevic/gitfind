# GitFind

Busca projetos e código no GitHub pelo terminal ou por uma janela GTK — sem abrir o navegador.

A busca do GitHub trata várias palavras como **E lógico** sobre nome e descrição. Por isso `análise de dados SAP` só casa com repositórios que tenham literalmente essas palavras no nome, e o resultado costuma ser um punhado de projetos minúsculos e mal batizados. O GitFind resolve isso disparando **cinco consultas em paralelo** e fundindo os rankings.

![modos](https://img.shields.io/badge/modos-repos%20%7C%20c%C3%B3digo%20%7C%20t%C3%B3picos-blue)

## Instalação

```bash
git clone https://github.com/enriquevic/gitfind.git
cd gitfind && ./install.sh
gh auth login          # se ainda não estiver autenticado
```

Dependências: **`gh`** (obrigatório), **`fzf`** (opcional, modo interativo no terminal), **`python3-gi`** (para a GUI — já vem no Debian/Ubuntu com GNOME).

```bash
sudo apt install gh fzf python3-gi
```

## Uso

```bash
gitfind "analise de dados SAP"     # busca por tema
gitfind -x "terminal dashboard"    # frase exata, na mesma ordem
gitfind -c "def handle_webhook"    # dentro do código-fonte
gitfind -T sap                     # descobre tópicos do GitHub
gitfind-gui                        # interface gráfica
```

No modo interativo (`fzf`): `enter` clona, `ctrl-o` abre no navegador, `ctrl-y` copia a URL, `ctrl-d` imprime a URL, `tab` marca vários.

## Como o ranking funciona

Cada busca de repositórios dispara cinco consultas independentes:

| Tag | Estratégia |
|-----|------------|
| `N` | o termo no **nome ou descrição** |
| `E` | idem, com os termos **traduzidos** para inglês |
| `R` | o termo dentro do **README** |
| `T` | **tópico** identificado + palavras restantes |
| `S` | só o tópico, ordenado por estrelas |

Os resultados são fundidos por **Reciprocal Rank Fusion**: cada lista contribui `peso / (k + posição)`. Um repositório encontrado por vários caminhos independentes sobe; um que aparece em uma só desce. A coluna **Origem** mostra as letras de quem achou aquele item — mais letras, mais confiável.

Os pesos foram calibrados empiricamente — tópico é o sinal mais forte (é uma etiqueta que um humano colocou de propósito), README é o mais ruidoso:

```
T 1,3   ·   N 1,0   ·   E 0,9   ·   S 0,8   ·   R 0,6
```

Um bônus pequeno por estrelas desempata sem mandar na fila. Tudo isso é ajustável por variável de ambiente (`GITFIND_W_TOPIC`, `GITFIND_STAR_WEIGHT`, `GITFIND_RRF_K`...).

Exemplo real, buscando `abapgit`:

```
NRST    1928  abapGit/abapGit          ← quatro estratégias concordaram
ST       433  SAP/code-pal-for-abap
ST       380  abap2UI5/abap2UI5
```

## Frase exata

Quando a busca por tema traz coisas só aproximadamente relacionadas, use `-x`. Ele põe a frase entre aspas, o que força correspondência literal **inclusive na ordem das palavras**, e desliga tradução e expansão por tópico.

A diferença é grande: `dashboard terminal` solto casa com 4.770 repositórios; `"dashboard terminal"` com 72.

## Paginação

`-p` navega além dos primeiros resultados, e `-n` define o tamanho da página.

```bash
gitfind "rest api" -n 20 -p 3      # itens 41 a 60
```

O conjunto fundido é fixo em 100 candidatos por estratégia, então o ranking não muda quando você avança e volta.

## Opções

```
  -c, --code              busca dentro do código-fonte
  -T, --topics            descobre tópicos sobre um tema
  -x, --exact             frase exata, na mesma ordem
  -p, --page <n>          página de resultados
  -n, --limit <n>         resultados por página (padrão 30)
  -t, --topic <t1,t2>     fixa o tópico
  -m, --match <campo>     name, description ou readme
  -S, --sort <campo>      stars, updated ou forks
  -l, --language <lang>   linguagem
  -s, --stars <expr>      ">100", "50..500"
  -u, --user <user>       usuário ou organização
  -1, --simple            uma consulta só, sem fusão
  -v, --verbose           mostra as estratégias e seus resultados
  -P, --porcelain         saída TSV, para scripts
      --no-cache          ignora o cache de 10 minutos
```

## Interface gráfica

`gitfind-gui` não reimplementa nada — chama `gitfind --porcelain` e desenha o resultado. Um motor só, CLI e GUI sempre em sincronia.

Três modos, filtros de linguagem/tópico/estrelas/usuário, colunas ordenáveis por clique e um painel de preview: o README no modo repositórios, e no modo código o arquivo real recortado em volta do termo buscado, com a linha marcada. Busca e preview rodam em thread separada, então a janela não trava.

## Limitações

A busca de código do GitHub exige autenticação e tem cota própria e apertada (~30 requisições por minuto). O cache de 10 minutos ajuda, mas rajadas de `-c` vão esbarrar no limite — o erro é repassado com uma mensagem explicando.

Consultas que misturam um domínio com uma tarefa genérica ainda rendem menos que uma palavra-chave dentro de um tópico. Para "análise de dados em SAP", `gitfind analytics -t sap` traz resultados melhores que a frase inteira. A fusão melhorou muito o caso geral, mas não substitui escolher bem o termo.
