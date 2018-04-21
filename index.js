module.exports = robot => {
  const READY_FOR_REVIEW = 'ready for review'
  const REJECTED = 'rejected'
  const REVIEW_REQUESTED = 'review requested'
  const IN_PROGRESS = 'in progress'

  robot.log('Yay, the app was loaded!')

  // For more information on building apps:
  // https://probot.github.io/docs/

  // To get your app running against GitHub, see:
  // https://probot.github.io/docs/development/

  robot.on('issues.labeled', async context => {
    robot.log(context)
  })

  const removeLabels = async (github, owner, repo, number, labels) => {
    labels.forEach(async name => {
      await github.issues.removeLabel({
        owner,
        repo,
        number,
        name
      })
    })
  }

  robot.on('issues.closed', async context => {
    // robot.log(context)

    await removeLabels(
      context.github,
      context.payload.repository.owner.login,
      context.payload.repository.name,
      context.payload.issue.number,
      [IN_PROGRESS, READY_FOR_REVIEW, REVIEW_REQUESTED]
    )
  })

  robot.on('pull_request.closed', async context => {
    robot.log(context)
  })

  robot.on(
    ['pull_request.opened', 'pull_request.edited', 'pull_request.reopened'],
    async context => {
      robot.log(context)
    }
  )

  robot.on('pull_request.review_requested', async context => {
    robot.log(context)
  })

  robot.on('pull_request_review', async context => {
    robot.log(context)
  })
}