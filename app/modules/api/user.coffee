{Router} = require 'express'
socketIo = require './io'

userController = require 'app/modules/users/controller'

router = new Router()
router.use '/user/login', userController.getRout 'login'
router.use '/user/logout', userController.getRout 'logout'
router.use '/user/push/set', userController.getRout 'setPush'

socketIo.on 'connection', userController.getSocket 'connection'
socketIo.on 'user/subscribe', userController.getSocket 'subscribe'
socketIo.on 'disconnect', userController.getSocket 'disconnect'

module.exports = router
