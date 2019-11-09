##### jruby debugging

use in order to enable debug interface:
```sh
JRUBY_OPTS="-Xcext.enabled=true --debug" bundle exec rspec
```

and place `require 'debug'` in the code. [More info](https://gist.github.com/klappradla/69029a982ade44e20e124c29b1c00541).
