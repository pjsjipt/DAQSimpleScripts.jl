import Dates
using Statistics
# Visualizing MeasData stuff

using GLMakie

function viewmeasdata(f, x::MeasData, p, params; title=nothing,
                     show_means=true, ymeanlimits=nothing, meanlines=nothing)
    
    # We will divide the the figure in 3 regions:
    # One is the header - It will show the device name, time
    # and experimental point.
    # Then we will show the time series and finally the mean values
    header = f[1,1] = GridLayout(tellwidth=false)
    
    plab = ["$par = $pt" for (pt,par) in zip(p,params)]
    hstr = [string(daqtime(x)); plab]
    hlab = [Label(header[2,i], hstr[i], tellwidth=false)
            for i in eachindex(hstr)]
    if isnothing(title)
        htitle = Label(header[1,:], devname(x), tellwidth=false)
    else
        htitle = Label(header[1,:], title, tellwidth=false)
    end
        


    fdata = f[2,1] = GridLayout()
    show_ts=true

    
    chans = daqchannels(x)
    nch = numchannels(x)

    if show_ts
        ts = fdata[1,1] = GridLayout()
        chidx = Observable(1)
        chhdr = Observable(chans[1])

        tsfig = ts[1,1]
        ax = Axis(tsfig, title=chhdr)

        t = samplingtimes(x.sampling)
        xi = x[chidx[]]
        y = Observable(xi)
        ym = Observable(mean(xi))
        ymax = Observable(maximum(xi))
        ymin = Observable(minimum(xi))
        symin = lift(x->string(round(x,sigdigits=4)), ymin)
        symax = lift(x->string(round(x,sigdigits=4)), ymax)
        sym = lift(x->string(round(x,sigdigits=4)), ym)
        ystd = std(xi)
        tmax = t[argmax(xi)]
        tmin = t[argmin(xi)]
        pmin = Observable(Point(tmin,ymin[]))
        pmax = Observable(Point(tmax,ymax[]))
        
        
        ysp = Observable(ym[] .+ ystd)
        ysn = Observable(ym[] .- ystd)

        
        lines!(ax, t, y, color=:gray50)
        hlines!(ax, ym, color=:black, linewidth=3,label="x̄")
        hlines!(ax, ysp, linestyle=:dash, color=:red, label="x̄+σ")
        hlines!(ax, ysn, linestyle=:dash, color=:blue, label="x̄-σ")
        hlines!(ax, ymax, linestyle=:dot, color=:red, label="x̂")
        hlines!(ax, ymin, linestyle=:dot, color=:blue,label="x̌")
        
        scatter!(ax, pmin, color=:blue)
        scatter!(ax, pmax, color=:red)
        text!(pmin, text=symin, color=:blue, align=(:center,:bottom))
        text!(pmax, text=symax, color=:red, align=(:center,:top))
        text!(t[1], ym, text=sym, align=(:left,:bottom))
        axislegend(ax, bgcolor=:transparent)
                
        # Lets add a slider and a label
        chslider = SliderGrid(ts[2,1], (label=chhdr, range=1:nch,
                                        startvalue=chidx[]), tellwidth=false)

        on(chslider.sliders[1].value) do i
            chidx[] = i
            chhdr[] = chans[i]
            xi = x[i]
            y[] = xi
            ym[] = mean(xi)
            ymax[] = maximum(xi)
            ymin[] = minimum(xi)
            xstd = std(xi)
            ysp[] = ym[] .+ xstd
            ysn[] = ym[] .- xstd
            tmax = t[argmax(xi)]
            tmin = t[argmin(xi)]
            pmin[] = Point(tmin,ymin[])
            pmax[] = Point(tmax,ymax[])
            reset_limits!(ax)
        end
        
    end

    if show_means
        axm = Axis(fdata[1,2], title="Mean")
        if !isnothing(ymeanlimits)
            ylims!(axm, ymeanlimits)
        end
        if !isnothing(meanlines)
            hlines!(axm, meanlines)
        end
        
        xm = mean(x[], dims=2)[:]
        scatter!(axm, 1:nch, xm)
        
        if show_ts
            xmi = Observable(xm[chidx[]])
            vlines!(axm, chidx, linestyle=:dot)
            scatter!(axm, chidx, xmi, color=:red)
            on(chslider.sliders[1].value) do i
                xmi[] = ym[]
            end
        end
        
    end

    
    f
    
end


function create_measdata(nchans=64, rate=100.0, nsamples=100; devname="Example")
    
    x = randn(nchans, nsamples)
    sampling = DaqSamplingRate(rate, nsamples, Dates.now())
    chans = "E" .* string.(1:nchans)
    channels = DaqChannels(devname, "Test", chans)

    return MeasData(devname, "Test", sampling, x, channels)
    
end



