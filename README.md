# Moodle dashboard

Plataforma: Extensão para Google Chrome | Chromium

[![Versão][version-image]][version-url] [![Licença MIT][license-image]][license-url]

## Guia de desenvolvimento

1. Instalação de ferramentas:

  ```
  ./install
  ```

  Com este comando será instalado as ferramentas `npm`, `bower` e `grunt-cli`

2. Instalação de dependências:

  ```
  ./update
  ```

  Com este comando será instalado todas dependências de desenvolvimento e produção.

3. Compilação:

  ```
  ./compile
  ```

  Com este comando será compilado o que for necessário e gerado a aplicação em `dist/`.

## Licença

Moodle dashboard é distribuído gratuitamente sob os termos da [licença MIT][license-url].

[license-image]: http://img.shields.io/badge/license-MIT-blue.svg?style=flat
[license-url]: LICENSE

[version-image]: https://img.shields.io/badge/version-0.1-brightgreen.svg?style=flat
[version-url]: https://github.com/ldseinhardt/moodle-dashboard/releases

## TODOS

- [x] Criar um jeito de upar um .csv localmente
- [ ] Integrar o arquivo .csv que foi upado localmente na aplicação

## Bugs Atuais



## Anotações

### Organização do projeto (raiz)

/dist -> pasta onde é gerado o plugin na estrutura e linguagens que o chrome suporta (html + css + js),
está pasta é plugin final, então seu zip pode ser publicado na webstore ou entao carregado como plugin local.

/docs -> prints

/src -> código fonte do plugin (coffeescript + less + html)

/vendor -> libs de terceiros que não foram possíveis adicionar com o gerenciador de pacotes bower,
nota nenhuma lib eh carregada externamente pois um requisito erá o plugin funcionar offline se houve dados previamente carregados

.editorconf -> arquivo de configuração para seu editor/ide manter o padrão de identação (no coffeescript faz diferença),
 algumas identação's requerem um plugin

.gitignore -> arquivos ignorados pelo git

Gruntfile.js -> tarefas para gerar o plugin, um "makefile" só que em js

LICENSE -> licença

README -> readme

bower.json -> dependências externas: jQuery, d3, ...

compile -> script bash que "compila" o plugin (chama a task padrão do grunt)

install -> script bash que instala as ferramentas necessárias

package.jon -> dependências que são instaladas para "compilar o projeto"

update -> instala as dependências externas com o npm e bower

### Organização do projeto (src)

coffee -> scripts coffeescript (js)

html -> scripts html, template base

json -> arquivos de configuração, tradução (em json)

less -> arquivos less (css)

### Organização do projeto (coffee)

view -> scripts de visuaçização, gráficos
	nota: o script view.coffee carrega todos os gráficos

client.coffee -> script cliente (pense no modelo cliente servidor, o cliente seria o script carregado junto a aba do navegador)

dashboard.coffee -> script servidor (pense no modelo cliente servidor, o servidor seria o
 script carregado em background que responde aos clientes com solicitações de dados), esse
script armezena os dados de todos os moodles visitados em localstorage do plugin

i18n.coffee -> script com funções para lidar com multi idomas (en/pt-br)

inject.coffee -> script que é carregado junto a todas as páginas que o usuário navega para tentar
 identificar se as mesmas são um moodle

moddle.coffee -> script com várias funções para "crawlear" um moddle com uma sessão de professor aberta

notas:
	- plugins para o chrome possuem algumas frescuras, ex não suporta script inline no html por padrão.

	- scripts novos e sites novos requisitados devem ser registrados no manifest.json, assim como as
 permissões necessárias.

	- para publicar um plugin é necessário uma conta de desenvolvedor no google, se você não possuí e
for publicar em uma conta própria, existe uma taxa de ativação de conta de desenvolvedor 5$.

	- se você já sabe js, css mas não sabe coffeescript e less é possível gerar o projeto para js e css
 e passar a trabalhar somente com essas linguagens

	- less é um css que suporta váriaves, "funções", aninhamento, ...
	
	- coffeescript é um js com frescuras "inspiradas" em python e ruby.

### Algumas outras duvidas

  1. Em moodle.coffee temos duas funções que não entendi seu conteudo. ProcessRow e ProcessRaw

  2. line 694 - sendDataToFlaskServer:

    acho que posso excluir as funções de conexão com flask, já que não estamos mais usando este servdor.

  3. Como limpar os cursos depois que a extensão fechar?
    (para não ter 'lixo' com cursos de outro usuario)

  4. Problema em moodle.coffee
    As informações do usuario estão agrupadas em um id=user-index-participants-113065_rX
    onde "X" é um numero de 0 até a qtd de participantes -1.

  Como eu faço para acesar essa informação através do html??