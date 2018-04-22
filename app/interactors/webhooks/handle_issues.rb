module Webhooks
  class HandleIssues
    include Interactor
    include InteractorHelper

    def_delegators :context, :payload

    def call
      case payload['action']
      when 'labeled'
        HandleIssuesActionLabeled.call!(context)
      when 'closed'
        HandleIssuesActionClosed.call!(context)
      end
    end
  end
end