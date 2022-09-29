
function measurepoint(i, dev, fname, path, point, params; twait=10)
    println("===========================")
    println("= Medindo o ponto $i     =")
    println("===========================")
    for (p,par) in zip(point,params)
        println("$par => $p")
    end
    println("=  Esperando $twait (s)   =")
    sleep(twait)
    println("= Começando a leitura ... =")
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
    
    println("=   Leitura realizada     =")
    println("===========================") 
    println("=    Salvando os dados    =")
    h5open(fname, "r+") do h
        daqsave(h, X, path)
        HDF5.attributes(h[path])["parameters"] = params
        HDF5.attributes(h[path])["point"] = point
    end
    println("===========================")
    
    return X
end
