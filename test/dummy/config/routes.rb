Rails.application.routes.draw do
  mount PgqWeb::Engine => "/pgq_web"
end
