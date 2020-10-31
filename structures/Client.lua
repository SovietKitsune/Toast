local discordia = require('discordia')

local class, enums, Client = discordia.class, discordia.enums, discordia.Client
local Toast, get, set = class('Toast', Client)

local validOptions = {
    prefix = 'string'
}

local function parseOptions(options)
    local discordiaOptions = {}
    local toastOptions = {}

    for i, v in pairs(options) do
        if validOptions[i] then
            toastOptions[i] = v
        else
            discordiaOptions[i] = v
        end
    end

    return toastOptions, discordiaOptions
end

function Toast:__init(options)
    local options, discordiaOptions = parseOptions(options)
    Client.__init(self, discordiaOptions)
    self._prefix = type(options.prefix) == 'table' and options.prefix or {options.prefix or '!'}
    self._commands = {}
    self._uptime = discordia.Stopwatch()
    self:on('messageCreate', function(msg)
        if msg.author.bot then return end
        local prefix
        for _, pre in pairs(self.prefix) do
            if not string.match(msg.content, '^'..pre) then return end
            prefix = pre
            break
        end
        if not prefix then return end
        local command, arg = string.match(msg.cleanContent, '^'..prefix..'(%S+)%s*(.*)')
        if not command then return end
        local args = {}
        for arg in string.gmatch(arg, '%S+') do
            table.insert(args, arg)
        end
        command = self.commands[string.lower(command)]
        if not command then return end
        local success, err = pcall(command.execute, msg, args)
        if not success then
            self:error('ERROR WITH '..command.name..': '..err)
        end
    end)
end

function Toast:login(token)
    self:run('Bot '..token)
end

function Toast:addCommand(command)
    self._commands[command.name] = command
    self:debug('Command '..command.name..' has been added')
end

function get.prefix(self) return self._prefix end
function get.commands(self) return self._commands end
function get.uptime(self) return self._uptime end

return Toast