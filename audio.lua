--[[

  Audio

--]]

local audio = {}


function audio_getSource (id)
    if (not audio[id]) then
        audio[id] = love.audio.newSource (string.format('/sounds/%s', id), 'static')
    end
    
    return audio[id]
end

--[[

  Public sounds

--]]

sounds = 
{
  volume = 0.1,
  hover = audio_getSource ('mouse_hover_button.mp3'), 
  click = audio_getSource('mouse_button_click.mp3'), 
  intro = audio_getSource('game_intro.wav'), 
  game_bg = audio_getSource('game_bg_music.mp3')
}