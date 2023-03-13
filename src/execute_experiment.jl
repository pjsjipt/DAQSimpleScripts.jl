
function execute_experiment(daqexp::AbstractSimpleScript, viewfun=nothing;
                            init=1, cont=false, twait=10.0)

    expinit(daqexp)
    
    fname, path = expconfigfile(daqexp)
    
    # fname não deveria ser o nome de uma pasta que já existe...
    if isdir(fname)
        error("O arquivo $fname é uma pasta que já existe. Forneça o nome de um arquivo!")
    end
    
    # I will avoid overwriting anything.
    if !cont &&  (isdir(fname) || isfile(fname))
        error("Pasta/arquivo $fname já existe. Apague ou guarde você mesmo, vagabundo!")
    end
    
    println("Começando o experimento usando o arquivo $fname")
    if cont && isfile(fname)
        mode = "r+"
    else
        mode = "w"
    end

    h5open(fname, mode) do h
        if path ∉ keys(h)
            println("Salvando a configuração do experimento...")
            daqsave(h, daqexp.setup, "$path/config")
            println("Salvando os parâmetros de ensaio...")
            daqsave(h, daqexp.config, "$path/parameters")
        else
            # Não vamos fazer nada. Vamos admitir que
            # está tudo certo e vamos em frente
        end
    end


    # Vamos verificar se o ponto init está lá.
    # Caso esteja - erro
    if checkdatafile(daqexp, init)
        error("Ponto $init já foi medido. Não sei o que fazer.")
    end

    params = parameters(daqexp.setup)
   
    dev = inputdevice(daqexp.setup)
    
    if ismeasurezero(daqexp)
        fname, path = expzerosfile(daqexp)
        X = measurezero(dev, fname, path, twait=twait)
        if !isnothing(viewfun)
            viewfun(0, X, zeros(length(params)), params)
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


    # Ponto inicial
    startplan!(daqexp.setup)
    setpoint!(daqexp.setup, i)
    i = init

    while movenext!(daqexp.setup)
        point = daqpoint(daqexp.setup, i)
        fname, path = expinitdata(daqexp, i)

        X = measurepoint(i, dev, fname, path, point, params; twait=twait)
        
        if !isnothing(viewfun)
            viewfun(i, X, point, params)
        end
        i += 1
    end
    
    if ismeasurezero(daqexp)
        fname, path = expzerosfile(daqexp)
        X = measurezero(dev, fname, path, twait=twait)
        if !isnothing(viewfun)
            viewfun(0, X, zeros(length(params)), params)
        end
        
    end

    return
end

