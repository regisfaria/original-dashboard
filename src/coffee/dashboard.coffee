###
# dashboard: moodle collection
###

class Dashboard
  constructor: () ->
    @load(=>
      @onMessage()
      console.log('Dashboard:', @)
    )

  sync: ({url, lang}) ->
    if !@contains(url) && @settings.search_moodle
      @list.push(new Moodle(
        url: url
        lang: lang
      ).syncTitle(=> @save()))
    moodle = @getMoodle(url)
    sync = moodle && @settings.sync_metadata
    time = @settings.sync_metadata_interval
    if sync && (Date.now() - moodle.getLastAccess()) > (1000 * 60 * time)
      moodle.sync((status, scope) =>
        if status == Moodle.response().success
          @getMoodles()
          @save()
        else if !moodle.hasUsers() && @settings.message_error_sync_moodle
          @notification(url, 'error', status)
          console.log('[' + url + ']', scope + ':', status)
      )
    if @settings.message_update
      @checkUpdate((data) =>
        if data.client
          @notification(url, 'update', data.client)
      )
    @

  syncData: (message) ->
    if @settings.sync_logs
      time = 1000 * 60 * 60 * @settings.sync_logs_interval
      progress =
        success: 0
        error: 0
        total: 0
      moodle = @getMoodle(message.moodle)
      moodle.setCourse(message.course)
      moodle.syncDates((status, scope, total) =>
        message.cmd = 'responseSync'
        message.error = status != Moodle.response().success
        message.showError = @settings.message_error_sync_dashboard
        message.status = status
        message.silent = moodle.hasData() && (
          Date.now() - moodle.getLastSync() <= time
        )
        if scope == Moodle.response().sync_dates
          unless message.error
            progress.total = total
        else
          if message.error
            progress.error++
          else
            progress.success++
          if progress.success + progress.error == progress.total
            if !message.error && !progress.error
              moodle.upLastSync()
            moodle.setDefaultLang()
            @save()
            if @settings.message_alert_users_not_found
              message.users = moodle.getUsersNotFound()
        message.progress = progress
        @sendMessage(message)
        unless status == Moodle.response().success
          console.log('[' + message.moodle + ']', scope + ': ', status)
      )
    @

  select: (url) ->
    for moodle in @list
      moodle.select(url)
    @

  getMoodles: (message = {}) ->
    if message.moodle
      @select(message.moodle)
    message.cmd = 'responseMoodles'
    message.list = []
    for moodle in @list
      if moodle.hasCourses()
        message.list.push(
          title: moodle.getTitle()
          url: moodle.getURL()
          selected: moodle.isSelected()
          access: moodle.getLastAccess()
        )
    message.list.sort((a, b) -> b.access - a.access)
    @sendMessage(message)
    @

  getCourses: (message) ->
    moodle = @getMoodle(message.moodle)
    message.cmd = 'responseCourses'
    message.courses = moodle.getCourseList()
    @sendMessage(message)
    @

  getUsers: (message) ->
    moodle = @getMoodle(message.moodle)
    moodle.setCourse(message.course)
    message.cmd = 'responseUsers'
    message.roles = moodle.getUsers()
    @sendMessage(message)
    @

  setUser: (message) ->
    moodle = @getMoodle(message.moodle).setCourse(message.course)
    switch message.action
      when 'select-all'
        moodle.setUsersAll(message.role)
      when 'select-invert'
        moodle.setUsersInvert(message.role)
      else
        moodle.setUser(message.role, message.user, message.selected)
    @

  getDates: (message) ->
    moodle = @getMoodle(message.moodle)
    moodle.setCourse(message.course)
    message.cmd = 'responseDates'
    # Por algum motivo não consegue entrar no if abaixo
    if moodle.hasDates()
      message.dates = moodle.getDates()
      console.log '--> Tem datas e são: ' + message.dates
    @sendMessage(message)
    @

  setDates: (message) ->
    moodle = @getMoodle(message.moodle)
    moodle.setCourse(message.course)
    if moodle.hasDates()
      moodle.setDates(message.dates)
    @

  syncMessageMissingData: (message) ->
    moodle = @getMoodle(message.moodle)
    # para setar um curso, é testado seus indices, então primeiro pego o indice do curso na lista de cursos
    message.course_index = moodle.getCourseIndex(message.course)
    moodle.setCourse(message.course_index)
    message.course = moodle.getCourse()
    console.log '--> syncMessageMissingData: o curso que foi clicado:' + message.course.name
    console.log '--> syncMessageMissingData: propriedades do curso:' + JSON.stringify(message.course)
    @
  
  '''
   O problema que temos aqui é que a função setCourse testa em um loop pelo index passado
  comparando com o index da lista de cursos que foi crawleada.
   
   Desta maneira, o atributo selected vai ser 1 apenas para o curso clicado e 0 para os demais.
   
   Tenho que arranjar uma maneira de descobrir qual é o index do curso que eu selecionei no dashboard
  para então conseguir jogar ele na função de setar qual curso estou selecionando.
  '''
  getLogs: (message) ->
    moodle = @getMoodle(message.moodle)
    moodle.setCourse(message.course_index)
    message.cmd = 'responseLogs'
    #message.logs = moodle.getLocalLogs(message.course)
    @sendMessage(message)
    @
  '''
  old getLogs:
    getLogs: (message) ->
    moodle = @getMoodle(message.moodle)
    moodle.setCourse(message.course)
    message.cmd = 'responseLogs'
    message.logs = moodle.getLogs()
    @sendMessage(message)
    @
  '''

  # função que inicia o download dos logs
  downloadLogs: (message) ->
    moodle = @getMoodle(message.moodle)
    moodle.setCourse(message.course)
    course = moodle.getCourse().name.replace(/\s/g, '_')
    # talvez seja preciso alterar a função abaixo
    logs = moodle.getLogs()
    csv = ''
    columns = Object.keys(logs[0])
    for column, i in columns
      if i
        csv += ', '
      csv += '"' + column + '"'
    csv += '\r\n'
    for row, i in logs
      for column, value of row
        if column != columns[0]
          csv += ', '
        csv += '"' + value + '"'
      csv += '\r\n'
    date = new Date().toISOString().split(/T/)[0]
    chrome.downloads.download(
      url: 'data:text/plain;charset=UTF-8,' + encodeURIComponent(csv)
      saveAs: message.saveAs
      filename: course + '_(' + date + ').csv'
    )
    @

  getData: (message) ->
    moodle = @getMoodle(message.moodle)
    moodle.setCourse(message.course)
    message.cmd = 'responseData'
    message.error = !moodle.hasData()
    console.log 'entrou an getData: ' + moodle.hasData()
    unless message.error
      console.log 'passou noo unless da get data'
      data = moodle.getCourseData()
      if data
        message.data = data
      #Oq isso faz??
      message.filters =
        list: moodle.getActivities(message.role)
        filtrated: @settings.filters
      console.log 'A função getData está rodando CHECK'
    @sendMessage(message)
    @

  getHelp: (message) ->
    message.cmd = 'responseHelp'
    message.help = @help.langs
    @sendMessage(message)
    @

  getQuestions: (message) ->
    message.cmd = 'responseQuestions'
    message.questions = @questions.langs
    @sendMessage(message)
    @

  getVersion: (message) ->
    message_version = @clone(message)
    message_version.cmd = 'responseVersion'
    message_version.version = @settings.version
    @sendMessage(message_version)
    .checkUpdate((data) =>
      if data.client
        message_update = @clone(message)
        message_update.cmd = 'responseUpdate'
        message_update.url = data.client.url
        message_update.version = data.client.version
        message_update.description = data.client.description
        message_update.show = (
          @settings.message_update && @settings.newVersion != data.client.version
        )
        @settings.newVersion = data.client.version
        @sendMessage(message_update)
      if data.help
        @getHelp(@clone(message))
      if data.questions
        @getQuestions(@clone(message))
    )
    @

  checkUpdate: (response) ->
    $.getJSON(@settings.server, {
      request: JSON.stringify(
        command: 'update'
        client: @settings.version
        help: @help.version
        questions: @questions.version
      )
    }, (data) =>
      if data
        if data.help
          @help = data.help
        if data.questions
          @questions = data.questions
        response?(data)
    )
    @

  support: (message) ->
    moodle = @getMoodle(message.moodle)
    message.cmd = 'responseSupport'
    $.post(@settings.server, {
      request: JSON.stringify(
        command: 'message'
        name: message.name
        email: message.email
        subject: message.subject
        message: message.message
        moodle:
          title: moodle.getTitle()
          url: moodle.getURL()
      )
    }, =>
      message.status = true
      @sendMessage(message)
    ).fail(=>
      message.status = false
      @sendMessage(message)
    )
    @

  analytics: (message) ->
    moodle = @getMoodle(message.moodle)
    if moodle && @settings.analytics
      $.post(@settings.server, {
        request: JSON.stringify(
          command: 'analytics'
          open: new Date(message.open).toISOString()[..18].replace(/T/, ' ')
          close: new Date(message.close).toISOString()[..18].replace(/T/, ' ')
          zone: new Date().getTimezoneOffset()
          moodle:
            title: moodle.getTitle()
            url: moodle.getURL()
          client: @settings.version
        )
      })
    @

  getConfig: (message) ->
    message.cmd = 'responseConfig'
    message.settings = @settings
    @sendMessage(message)
    @

  setConfig: (message) ->
    if message.settings.filters
      index = @settings.filters.indexOf(message.settings.filters.key)
      if message.settings.filters.value && index >= 0
        @settings.filters.splice(index, 1)
      else if index < 0
        @settings.filters.push(message.settings.filters.key)
    settings = [
      'search_moodle',
      'sync_metadata',
      'sync_metadata_interval',
      'sync_logs',
      'sync_logs_interval',
      'message_error_sync_moodle',
      'message_error_sync_dashboard',
      'message_alert_users_not_found',
      'analytics',
      'message_update'
    ]
    for setting in settings
      if message.settings.hasOwnProperty(setting)
        @settings[setting] = set[setting]
    if message.settings.language
      chrome.storage.local.set(language: message.settings.language)
    @

  defaultConfig: (message) ->
    $.getJSON(chrome.extension.getURL('settings.json'), (@settings) => @)
    @

  deleteMoodle: (message) ->
    index = -1
    for moodle, i in @list
      if moodle.equals(message.moodle)
        index = i
    if index >= 0
      @list.splice(index, 1)
    @

  sendMessageToMoodle: (message) ->
    moodle = @getMoodle(message.moodle)
    if moodle
      moodle.getSessKey((sessKey) ->
        if sessKey
          for user in message.users
            moodle.sendMessageToUser(
              user,
              message.message,
              sessKey
              (response) -> console.log('send message to', user, '[', message.message , ']')
            )
      )
    @

  getSelected: ->
    for moodle in @list
      if moodle.isSelected()
        return moodle

  getMoodle: (url) ->
    for moodle in @list
      if moodle.equals(url)
        return moodle

  contains: (url) ->
    for moodle in @list
      if moodle.equals(url)
        return true
    return false

  toString: ->
    JSON.stringify(@)

  parse: (str) ->
    for key, value of JSON.parse(str)
      @[key] = value
    @list = ((list) ->
      new Moodle(e) for e in list
    )(@list)
    @

  clone: (obj) ->
    JSON.parse(JSON.stringify(obj))

  load: (onload) ->
    @list = []
    $.when(
      $.getJSON(chrome.extension.getURL('help.json')),
      $.getJSON(chrome.extension.getURL('questions.json')),
      $.getJSON(chrome.extension.getURL('settings.json'))
    ).done((helpArgs, questionsArgs, settingsArgs) =>
      @help = helpArgs[0]
      @questions = questionsArgs[0]
      @settings = settingsArgs[0]
      chrome.storage.local.get(data: @toString(), (items) =>
        @parse(items.data)
        @settings.version = settingsArgs[0].version
        @settings.server = settingsArgs[0].server
        onload?()
      )
    )
    @

  save: ->
    chrome.storage.local.set(data: @toString())
    @

  notification: (url, type, data) ->
    chrome.tabs.query(
      url: url + '/*'
      (tabs) ->
        if tabs && tabs.length && tabs[0].id
          chrome.tabs.sendMessage(tabs[0].id,
            cmd: 'notification'
            type: type
            data: data
          )
    )
    @

  sendMessage: (message) ->
    message.client = true
    chrome.runtime.sendMessage(message)
    @

  onMessage: ->
    chrome.runtime.onMessage.addListener((request) =>
      unless request.client
        commands = [
          'sync',
          'getMoodles',
          'getCourses',
          'getUsers',
          'setUser',
          'getDates',
          'setDates',
          'getLogs',
          'downloadLogs',
          'getData',
          'syncData',
          'support',
          'analytics',
          'getHelp',
          'getQuestions',
          'getVersion',
          'getConfig',
          'setConfig',
          'deleteMoodle',
          'syncMessageMissingData',
          'defaultConfig',
          'sendMessageToMoodle'
        ]
        if commands.indexOf(request.cmd) >= 0
          @[request.cmd](request)
          @save()
        else
          console.log('message:', request)
    )
    @

new Dashboard()
