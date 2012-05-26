# encoding: utf-8

class PgqWeb::PgqController < PgqWeb::ApplicationController
  layout 'pgq_web/pgq'
  
  KEYS_NAMES = {'lag' => "Lag", 'last_seen' => "Last Seen", 'queue_name' => "Queue Name", 'consumer_name' => "Consumer", 
                'status' => "Status", 'pending_events' => "Pending", 'host' => "Db Host", 'db' => "Database", 'errors_count' => "Errors Count",
                'actions' => "Actions"}
                
  before_filter :get_db_index, [:errors_list, :pending_list, :pending_events_count, :delete_all, :retry_all, :delete, :retry] 

  def index
    @keys = %w(consumer_name queue_name last_seen lag status pending_events)
    @keys_names = @keys.inject({}){|r, el| r[el] = el; r}
    @keys_names.merge!(KEYS_NAMES)
    @info = consumer_info
    @info_groups = @info.group_by{|row| [row['host'], row['db']]}
  end
  
  def errors
    @keys = %w(host db queue_name errors_count actions)
    @keys_names = @keys.inject({}){|r, el| r[el] = el; r}
    @keys_names.merge!(KEYS_NAMES)
    
    @info = consumer_info

    @info = @info.map do |row|
      count = row['database'].pgq_failed_event_count(row['queue_name'], row['consumer_name'])
      if count.to_i > 0
        row['errors_count'] = "#{count.to_i}"
        row
      end
    end.compact.sort{|a, b| a['failed_count'] <=> b['failed_count']}
  end
  
  def errors_list
    @queue_name = params['queue_name']
    @consumer_name = params['consumer_name']
    
    params['per_page'] ||= 30
    
    page = (params['page'] || 1).to_i
    per_page = params['per_page'].to_i
    
    offset = 0
    
    @errors_count = @db.pgq_failed_event_count(params['queue_name'], params['consumer_name'])

    @errors  = WillPaginate::Collection.create(page, per_page) do |pager|
      pager.total_entries = @errors_count
        
      offset = pager.total_entries - page * per_page
      
      if offset < 0
        offset = 0
      end

      pager.replace(@db.pgq_failed_event_list(@queue_name, @consumer_name, per_page, offset))
    end
  end
  
  def pending_list
    @last_event = params['last_event'].to_i
    @queue_name = params['queue_name']
    table, last_event = @db.pgq_last_event_id(params['queue_name'])
    
    @pending_count = @db.connection.select_one("SELECT count(*) as count FROM #{table} WHERE ev_id > #{(last_event || @last_event).to_i}")['count']
    
    params['per_page'] ||= 30
    
    page = (params['page'] || 1).to_i
    per_page = (params['per_page']).to_i
    
    @pending = WillPaginate::Collection.create(page, per_page) do |pager|
      pager.total_entries = @pending_count
           
      offset = pager.total_entries - page * per_page
                    
      if offset < 0
        offset = 0
      end
      
      data = @db.connection.select_all("SELECT * FROM #{table} WHERE ev_id > #{(last_event || @last_event).to_i} OFFSET #{offset.to_i} LIMIT #{per_page.to_i}")
      pager.replace(data)
    end                                                         
  end  

  def pending_events_count
    table, last_event = @db.pgq_last_event_id(params['queue_name'])
    
    res = if last_event
      @last_event = last_event.to_i
      @db.connection.select_value "SELECT count(*) FROM #{table} WHERE ev_id > #{last_event.to_i}"
    else
      '-'
    end

    @res = res
    
    respond_to do |f|
      f.js {}
    end
  end
  
  def delete_all    
    @db.pgq_mass_delete_failed_events(params['queue_name'], params['consumer_name'], 5_000)
    redirect_to :action => :errors
  end
  
  def retry_all
    @db.pgq_mass_retry_failed_events(params['queue_name'], params['consumer_name'], 5_000)
    redirect_to :action => :errors
  end
  
  def delete
    data = @db.pgq_failed_event_delete(params['queue_name'], params['consumer_name'], params['ev_id'].to_i)
    str = (data.to_i == 1) ? params['ev_id'].to_s : '-'
    @res = "deleted event " + str
    
    respond_to do |f|
      f.js {}
    end
  end              
  
  def retry
    data = @db.pgq_failed_event_retry(params['queue_name'], params['consumer_name'], params['ev_id'].to_i)
    @res = "retried event " + data.to_s
    
    respond_to do |f|
      f.js {}
    end
  end
  
protected
  
  def consumer_info
    Rails.logger.info "#{PgqWeb::Watcher.databases.inspect}"
    res = PgqWeb::Watcher.databases.map do |base|
      data = base.pgq_get_consumer_info
      cfg = base.connection.instance_variable_get("@config")
      db = cfg[:database] || cfg['database']
      host = cfg['host'] || cfg[:host] || 'localhost'
      data.map do |h|
        h['db'] = db
        h['host'] = host
        h['database'] = base
        h['db_index'] = PgqWeb::Watcher.databases.index(base)
        
        h['last_seen_sec'] = h['last_seen_sec'].to_f
        h['lag_sec'] = h['lag_sec'].to_f        
        
        h['status'] = status_str(h)
        
        h
      end
    end.flatten
    res
  end
  
  def data_with_keys(info, keys)
    data = []
    info.each do |row|
      data << keys.map{|key| row[key]}
    end
    data
  end
  
  def get_db_index
    @db = PgqWeb::Watcher.databases.at(params[:db_index].to_i) || PgqWeb::Watcher.databases[0]
  end
  
  def status_str(h)
    case
      # more 1 day, and equal
      when h['last_seen_sec'] > 3600 && h['lag_sec'] > 3600 && (h['last_seen_sec'] - h['lag_sec']).abs < 5 then :stopped

      # when lag 1 h
      when h['lag_sec'] > 3600 then :warn

      # lag 6h
      when h['lag_sec'] > 21600 then :error

      # last seen > 2 h, something bad
      when h['last_seen_sec'] > 7200 then :error

      else :ok
    end
  end
  
end
