PgqWeb::Engine.routes.draw do
  match '/' => 'pgq#index'
  match '/:action(/:id)' => "pgq#"
end