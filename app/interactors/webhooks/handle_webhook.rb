module Webhooks
  class HandleWebhook
    include Interactor
    include InteractorHelpers

    def_delegators :context, :access_token, :type, :payload

    def call
      repo_full_name = payload['repository']['full_name']

      SetupLabels.call!(repo_full_name: repo_full_name)

      executor = case type
                 when 'pull_request_review'
                   Webhooks::HandlePullRequestReview
                 when 'pull_request'
                   Webhooks::HandlePullRequest
                 when 'issues'
                   Webhooks::HandleIssues
                 end

      executor.call!(access_token: access_token, payload: payload, repo_full_name: repo_full_name)
    end
  end
end
