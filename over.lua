-----------------------------------------------------------------------------------------
--
-- over.lua
--
-----------------------------------------------------------------------------------------

local composer = require"composer"
local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
function scene:show( event )
  if (event.phase == 'did') then
    composer.gotoScene('stage1')
  end
end

function scene:hide( event )
  if (event.phase == 'did') then
    composer.removeScene('over')
  end
end

function scene:destroy(event)
  scene:removeEventListener( 'create', scene )
  scene:removeEventListener( 'show', scene )
  scene:removeEventListener( 'hide', scene )
  scene:removeEventListener( 'destroy', scene )
end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene
