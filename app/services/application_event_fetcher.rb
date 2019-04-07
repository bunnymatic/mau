# frozen_string_literal: true

class ApplicationEventFetcher
  class InvalidApplicationEventQueryError < StandardError; end

  def self.run(application_event_query)
    raise InvalidApplicationEventQueryError, application_event_query.errors.full_messages.to_sentence unless application_event_query.valid?

    types = ApplicationEvent.available_types.map(&:constantize)

    if application_event_query.number_of_records?
      return types.each_with_object({}) do |clz, memo|
        memo[clz] = clz.by_recency.limit(application_event_query.number_of_records)
      end
    else
      return types.each_with_object({}) do |clz, memo|
        memo[clz] = clz.by_recency.where(['created_at > ?', application_event_query.since])
      end
    end
  end
end
