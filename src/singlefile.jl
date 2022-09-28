
function measurezero(h, dev, path="zeros"; twait=10)
    println("===========================")
    println("=    Medindo o zero       =")
    println("===========================")
    println("Quando estiver tudo desligado, pressione ENTER")
    readline()
    println("Podemos medir o zero? Pressione ENTER para confirmar.")
    readline()
    nzeros = try
        z = h["path"]
        length(keys(z)) + 1
    catch e
        create_group(h, path)
        1
    end

    println("===========================")
    println("=   Adquirindo dados     =")
    X = daqacquire(dev) 
    println("=    Zero medido!         =")
    println("=    Salvando os dados    =")
    daqsave(h[path], X, "$nzeros")
    println("===========================")
    
end


function execute_experiment_file(fname, setup::ExperimentSetup,
                                 viewfun=nothing;
                                 init=1, cont=false, measure_zero=true)
    # I will not overwrite anything, except if we explicitly say so
    # using keyword cont=true
    if !cont &&  (isdir(fname) || isfile(fname))
        error("Pasta/arquivo $fname já existe. Apague ou guarde você mesmo, vagabundo!")
    end

    println("Começando o experimento usando o arquivo $fname")
    if cont && isfile(fname)
        mode = "r+"
        # Vamos verificar se o ponto init está lá.
        # Caso esteja - erro
        h5open(fname, "r") do h
            if string(init) ∈ keys(h["data"])
                error("Ponto $init já foi medido. Não sei o que fazer.")
            end
        end
    else
        mode = "w"
    end
    h5open(fname, mode) do h
        if "config" ∉ keys(h)
            println("Salvando a configuração...")
            daqsave(h, setup, "config")
        end
    end

    dev = inputdevice(setup)
    
    if measure_zero 
        h5open(fname, "r+") do h
            measurezero(h, dev, "zeros")
        end
    end
    
    # Vamos realizar as medidas
    println("===========================")
    println("=  Começando as medições  =")
    println("===========================")
    println("Quando estiver tudo ligado, pressione ENTER")
    readline()
    println("Podemos começar as medições? Pressione ENTER para confirmar.")
    readline()

    h5open(fname, "r+") do h
        if "data" ∉ keys(h)
            create_group(h, "data")
        end
    end
    
    # Ponto inicial
    setpoint!(setup, init)

    i = init
    params = parameters(setup)
    
    while movenext!(setup)
        sleep(twait)
        point = daqpoint(setup, i)

        println("===========================")
        println("=   Medindo o ponto $i    =")
        println("===========================") 
        println("= Começando a leitura ... =")

        X = daqacquire(inputdevice(setup))
        println("=   Leitura realizada     =")
        println("===========================") 
        println("=    Salvando os dados    =")
        h5open(fname, "r+") do h
            g = h["data"]
            s = string(i)
            daqsave(g, X, s)
            attributes(g[s])["parameters"] = params
            attributes(g[s])["point"] = point
        end
        i += 1
        println("===========================")
        if !isnothing(viewfun)
            viewfun(i, X, fname)
        end
        println("\n\n")
    end

    
    # If we got this far, let measure the zero again.

    if measure_zero 
        h5open(fname, "r+") do h
            measurezero(h, dev, "zeros")
        end
    end

    
end
