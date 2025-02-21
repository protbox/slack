function love.conf(t)
	t.window.title = "Slack"
	t.window.width = 320*4
	t.window.height = 200*4
	t.modules.physics = false
end

slack = {
    viewport = { x = 320, y = 200 },
    res = {}, -- resources stored here if load_assets called
    components = {},
    tile_size = 16,
    controls = {
        ["up"]      = {'key:up', 'button:dpup'},
        ["down"]    = {'key:down', 'button:dpdown'},
        ["left"]    = {'key:left', 'button:dpleft'},
        ["right"]   = {'key:right', 'button:dpright'},
        ["x"]       = {'key:x', 'button:a'},
        ["z"]       = {'key:z', 'button:x'},
        ["start"]   = {'key:return', 'button:start'},
        ["select"]  = {'key:lshift', 'button:back'}
    },
    tile_size = 16
}