
function measurezero(dev, fname, path="zeros"; twait=10)
    println("===========================")
    println("=    Medindo o zero       =")
    println("===========================")
    println("Quando estiver tudo desligado, pressione ENTER")
    readline()
    println("Podemos medir o zero? Pressione ENTER para confirmar.")
    readline()
    nzeros = h5open(fname, "r+") do h
        try
            z = h[path]
            length(keys(z)) + 1
        catch e
            create_group(h, path)
            1
        end
    end
    
    sleep(twait)
    println("===========================")
    println("=   Adquirindo dados     =")

    X = try
        daqacquire(dev)
    catch e
        if isa(e, InterruptException)
            daqstop(dev)
            throw(e)
        else
            throw(e)
        end
    end
    
    println("=    Zero medido!         =")
    println("=    Salvando os dados    =")
    h5open(fname, "r+") do h
        daqsave(h[path], X, "$nzeros")
    end
    println("===========================")
    println("\n\n")
    return X
        
end
