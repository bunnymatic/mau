class ApplicationEventFetcher
  class InvalidApplicationEventQueryError < StandardError; end

  def self.run(application_event_query)
    raise InvalidApplicationEventQueryError, application_event_query.errors.full_messages.to_sentence unless application_event_query.valid?

    types = ApplicationEvent.available_types.map(&:constantize)

    if application_event_query.number_of_records?
      types.index_with do |clz|
        clz.by_recency.limit(application_event_query.number_of_records)
      end
    else
      types.index_with do |clz|
        clz.by_recency.where(['created_at > ?', application_event_query.since])
      end
    end
  end
end
