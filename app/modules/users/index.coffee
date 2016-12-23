require './tasks/session_timeout_destroy'
require './tasks/create_default_admin'

require './models/user'
require './models/session'

require './controller'

# TODO Переписать сокеты и убрать этот архоизм
#socketIo = require 'app/socket_io'
#socketIo.registerInterceptor require './interceptors/io_session'
