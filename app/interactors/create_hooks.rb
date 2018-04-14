class CreateHooks
  include Interactor
  include InteractorHelpers

  REPOS = ['woodmont/capital', 'woodmont/listings', 'phstc/putslabel', 'phstc/crosshero'].freeze
  WEBHOOK_URL = 'https://putslabel.herokuapp.com/webhook'.freeze

  def call
    REPOS.each do |repo|
      client.create_hook(
        repo,
        'web',
        {
          url: WEBHOOK_URL,
          content_type: 'json'
        },
        events: %w[issues status pull_request_review push pull_request],
        active: true
      )
    rescue Octokit::UnprocessableEntity
      # TODO ignore if hook is already in place
      # otherwise log it in an error tracker
    end
  end
end