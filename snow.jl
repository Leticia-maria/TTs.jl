function snow(io = stdout)
    h, w = displaysize(io)
    iob = IOBuffer()
    ioc = IOContext(IOContext(iob, io), :displaysize=>(h,w))
    print(io, repeat("\n", h), "\e[", h, "A\e[1G") # new lines and move back up
    air = ones(Int, w, h)
    flakes = [" ", "*", "❄︎", "❅", "❆"]
    scsin(t) = ((sin(t) / 2) + 0.5) * (0.1 / 3)
    likelihood(t) = scsin(t) + scsin(t * 1.00001) + scsin(t * 0.9999)
    try
        while true
            for x in 1:w, y in h:-1:1
                air[x,y] = if y == 1 # new flakes
                    rand() < likelihood(time()) ? rand(2:length(flakes)) : 1
                elseif y == h # accumulate bottom
                    ((rand() < 0.95 && air[x,y] > 1) || (air[x, y-1] > 1 && rand() < 0.2)) ? 2 : 1
                elseif all(>(1), air[x, y:end]) # melt pile sometimes
                    rand() < 0.95 ? 2 : 1
                elseif (air[x, y-1] > 1 && all(>(1), air[x, (y+1):end])) # if flake coming and piled up below
                    rand() < 0.1 ? 2 : 1
                else # fall downwards otherwise
                    air[x, y-1]
                end
            end
            print(ioc, "\e[", h, "A\e[1G") # move back to start
            print.((ioc,), flakes[air])
            print(ioc, "\e[", h, "A\e[1G") # move back to start
            Base.banner(ioc)
            printstyled(ioc, "julia> ", color = :green, bold = true)
            println(ioc, "snow()")
            print(io, String(take!(iob)))
            sleep(1/8)
        end
    catch e
        isa(e,InterruptException) || rethrow()
    end
    nothing
end
