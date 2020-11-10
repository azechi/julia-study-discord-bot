using HTTP
using JSON
using OpenTrick

logfile = open("log.txt", "w+")

TOKEN = ENV["DISCORD_BOT_TOKEN"]

seq = nothing

version = 8

function getGateway()

  r = HTTP.request("GET", 
                   "https://discord.com/api/v$version/gateway/bot", 
                   ["Authorization" => "Bot $TOKEN"])
  JSON.parse(String(r.body); dicttype=Dict{Symbol, Any})
end

function heartbeat()
  d = Dict("op"=>1, "d"=>seq)
end

function identify()
  d = Dict("op" => 2,
           "s" => seq,
           "d" => Dict("token"=> TOKEN,
                       "intents"=> (1 << 11),
                       "properties"=> Dict("\$os"=> String(Sys.KERNEL),
                                           "\$browser" => "repl",
                                           "\$device" => "repl")))
end

url = "wss://gateway.discord.gg/?v=$version&encoding=json"


io = opentrick(HTTP.WebSockets.open, url)

readTask = Threads.@spawn begin

  while isopen(io)
    s = String(readavailable(io))
    d = JSON.parse(s; dicttype=Dict{Symbol, Any})

    println(logfile, "<-<-<-", chomp(json(d, 2)), "<-<-<")
    flush(logfile)
  end

end

heartTask = Threads.@spawn begin

  while isopen(io)
    sleep(40)
    d = heartbeat()

    println(logfile, "->->->", chomp(json(d, 2)), "->->->")
    flush(logfile)

    write(io, json(d))
  end

end
