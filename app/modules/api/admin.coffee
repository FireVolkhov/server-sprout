{Router} = require 'express'

userController = require 'app/modules/users/admin_controller'
chatController = require 'app/modules/chats/admin_controller'
messageController = require 'app/modules/messages/admin_controller'
searchController = require 'app/modules/search/admin_controller'
workerController = require 'app/modules/worker/admin_controller'
settingController = require 'app/modules/settings/admin_controller'
documentation = require 'app/documentation'

router = new Router()

router.get '/documentation', documentation.getDoc 'adminRouts'

router.use '/user/create', userController.getRout 'create'
router.use '/user/get', userController.getRout 'get'
router.use '/user/save', userController.getRout 'save'

router.use '/chat/get', chatController.getRout 'get'
router.use '/chat/restore', chatController.getRout 'restore'
router.use '/chat/finish', chatController.getRout 'finish'
router.use '/chat/delete', chatController.getRout 'delete'
router.use '/chat/:chat_id/export', chatController.getRout 'export', 'GET'
router.use '/chat/exports', chatController.getRout 'exportAllChats', 'GET'
router.use '/chat/sendToMail', chatController.getRout 'sendToMail'
router.use '/chat/nuke/drop', chatController.getRout 'nukeDrop'
router.use '/chat/edit', chatController.getRout 'edit'

router.use '/setting/timer/set', settingController.getRout 'setDefaultTimer'
router.use '/setting/timer/get', settingController.getRout 'getDefaultTimer'

router.use '/message/get', messageController.getRout 'get'

router.use '/search', searchController.getRout 'search'

router.use '/worker/checkMessageArchiveTime', workerController.getRout 'checkMessageArchiveTime'
router.use '/worker/checkObserversAcceptedChat', workerController.getRout 'checkObserversAcceptedChat'
router.use '/worker/deleteOldSessions', workerController.getRout 'deleteOldSessions'

module.exports = router
