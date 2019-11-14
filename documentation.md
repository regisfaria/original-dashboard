# documentation


## TODOS

- [x] Criar um jeito de upar um .csv localmente
- [ ] Integrar o arquivo .csv que foi upado localmente na aplicação

## Bugs Atuais



## Anotações

-> Algumas funções uteis:
  Object.getOwnPropertyNames(_objectName_): lista os metodos de um objeto
  JSON.stringify(_objectName_): lista os atributos e seus respectivos valores de um objeto

-> Atributos de course:

  course.id

  course.users
    course.users.[role].list
    course.users.filter((user)
    course.users.push
    course.users[p]
    course.users.sort((a, b)
    course.users[0].selected

  course.users_not_found
    course.users_not_found[user]

  course.dates
    course.dates.max
      course.dates.max.value
      course.dates.max.selected
    course.dates.min
      course.dates.min.value
      course.dates.min.selected

  course.name

  course.errors
    '''course.errors.push(time)

  course.course

  course.logs
    course.logs[realtime]
    course.logs[day]

  course.selected

-> Para pegar o nome do curso clicado no dashboard usamos 'course.html()'

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

  1. Arranjar um jeito de ao invez de a box de enviar arquivo, aparecer uma janela intermediaria
    para que o usuario receba uma msg sobre como upar um arquivo localmente.

  2. Qual a diferença entre usar sendMessage() e chamar a função moodle.nomeFunção()?
  
  3. Como limpar os cursos depois que a extensão fechar?
    (para não ter 'lixo' com cursos de outro usuario)

