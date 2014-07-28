# Description:
#   Create pull request on GitHub to deploy application.
#
# Configuration:
#   None
#
# Commands:
#   hubot deploy <target> to <environment> - Create pull request.

module.exports = (robot) ->
  robot.respond /deploy (.+) to (.+)/i, (msg) ->
    target      = msg.match[1]
    environment = msg.match[2]

    permitTargets      = ['app', 'infra']
    permitEnvironments = ['staging', 'production']

    if (target not in permitTargets) || (environment not in permitEnvironments)
      msg.send 'Invalid command'
      return

    currentDate = ->
      date = new Date
      date.getFullYear() + '.' + (date.getMonth() + 1) + '.' + date.getDate()

    pullRequestBody = """
        このプルリクエストをマージすると、 **#{environment}** 環境へのデプロイが走ります。
        以下の Checklist すべてにチェックできた場合のみ、 **Merge pull request** よりマージしてください。

        ## Checklist

        - [ ] diff に問題がないことを確認した
        - [ ] すべてのコミットのステータスが Success であることを確認した
        - [ ] 2人以上の :+1: がついた

        ## Notice

        - デプロイに問題がある場合は、 **Close pull request** よりこのプルリクエストを閉じてください。
      """

    GitHubApi = require('github')

    github = new GitHubApi
      version: '3.0.0'

    github.authenticate
      type: 'basic'
      username: ''
      password: ''

    github.pullRequests.create
      user: ''
      repo: 'sample-' + target
      head: 'master'
      base: "release/#{environment}"
      title: currentDate() + ' deploy ' + target + ' to ' + environment
      body: pullRequestBody
    , (err, res) ->
      msg.send 'Continue manual merge on GitHub: ' + res._links.html.href unless res == undefined
