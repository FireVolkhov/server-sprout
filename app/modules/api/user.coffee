{Router} = require 'express'

userController = require 'app/modules/users/controller'

router = new Router()
router.use '/user/login', userController.getRout 'login'
router.use '/user/logout', userController.getRout 'logout'

module.exports = router
