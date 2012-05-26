class PgqIssues < Consumer2

  # to insert event: PgqIssue.my_event(1, 2, 3)
  
  # async execute
  def my_event(a, b, c)
    sleep 0.2
    logger.info "async call my_event with #{[a, b, c].inspect}"
  end
  
end
