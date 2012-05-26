PgqWeb
======

Web interface for [pgq](http://github.com/kostya/pgq) gem, based on Rails Engine. Inspect pgq and londiste queues. Rails 3! only tested.
Requires haml, jquery, will_paginate.


```ruby
gem 'pgq_web'
```

Add to routes.rb

    mount PgqWeb::Engine => "/pgq_web"


Specify more databases to inspect. Create initializer with.

```ruby
PgqWeb::Watcher.databases = [ActiveRecord::Base, Base2]
```

### Example

![Example](https://github.com/kostya/pgq_web/raw/master/img.png)



Used twitter bootstrap.