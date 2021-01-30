function generateNiPi(x, GRID_SIZE)  # -1 : ni, 1 : pi
    array = Array{Int8}(undef, GRID_SIZE)
    if x == -1
        array = collect(0:GRID_SIZE - 1)
        array[1] = GRID_SIZE
    elseif x == 1
        array = collect(2:GRID_SIZE + 1)
        array[GRID_SIZE] = 1
    end

    return array
end


function generateGrid(GRID_SIZE)
    spins = Array{Int64}(undef, GRID_SIZE, GRID_SIZE)

    for row in 1:GRID_SIZE
        for column in 1:GRID_SIZE       
            randomNumber = rand()   # od 0 do 1
                if randomNumber > 0.5
                    spins[row, column] = -1
                else
                    spins[row, column] = 1
                end
        end
    end
    return spins
end


function calculateBoltzmannFactors(temperature)
    boltzmannFactors = Dict()
    helper4 = exp(-4 / temperature)
    helper8 = exp(-8 / temperature)
    return boltzmannFactors = Dict(0.0 => 1.0, 4.0 => helper4, 8.0 => helper8)
end


function calculateM(inputSpins, GRID_SIZE)
    sum = 0
    for column in 1:GRID_SIZE
        for row in 1:GRID_SIZE
            sum += inputSpins[row, column]
        end
    end
    return sum/(GRID_SIZE * GRID_SIZE)
end


function calculateE(inputSpins, GRID_SIZE, ni, pi)

    energy = 0
    for row in 1:GRID_SIZE
        for column in 1:GRID_SIZE
            energy += 0.5 * inputSpins[column, row] * (inputSpins[pi[column], row] + inputSpins[ni[column], row] + inputSpins[column, ni[row]] + inputSpins[column, pi[row]] )
        end
    end

    return abs(energy)
end


function MCSingleSim(MCS, GRID_SIZE, READ_STEPS, temperature, spins, ni, pi)

    boltzmannFactors = calculateBoltzmannFactors(temperature)
    absSumM = 0
    sumE = 0
    sumESquared = 0
    sumMSquared = 0
    counter = 0

    for step in 1:MCS
        for row in 1:GRID_SIZE
            for column in 1:GRID_SIZE
                deltaE = 2 * spins[column, row] * (spins[pi[column], row] + spins[ni[column], row] + spins[column, ni[row]] + spins[column, pi[row]] )
                if deltaE < 0
                    spins[column, row] *= -1
                else
                    w = min(1.0, boltzmannFactors[deltaE])
                    randomNumber = rand()
                    if randomNumber <= w
                        spins[column, row] *= -1
                    end
                end
            end
        end

        if mod(MCS, READ_STEPS) == 0
            counter += 1
            if mod(counter, 10000) == 0
                print(" ", counter/2000, "/", MCS/2000, " ")
            end

            calculatedM = abs(calculateM(spins, GRID_SIZE))
            absSumM += calculatedM
            sumMSquared += calculatedM * calculatedM

            calculatedE = calculateE(spins, GRID_SIZE, ni, pi)
            sumE += calculatedE
            sumESquared += calculatedE * calculatedE

        end
    end
    
    currentMediumM = absSumM / counter
    currentMagneticSus = ((GRID_SIZE * GRID_SIZE)/temperature) * (sumMSquared/counter - ((absSumM/(counter) * (absSumM/(counter)))))
    currentThermalCap = (1.0/(GRID_SIZE * GRID_SIZE * temperature * temperature))*( (sumESquared/counter) - (sumE/counter *  sumE/counter));

    return [spins, currentMediumM, currentMagneticSus, currentThermalCap]
end


function simulate(MCS, GRID_SIZE, READ_STEPS, T_START, T_END, T_STEP)
    


    ni = generateNiPi(-1, GRID_SIZE)
    pi = generateNiPi(1, GRID_SIZE)
    
    spins = generateGrid(GRID_SIZE)
    t = T_START

    mediumM = Float64[]
    magneticSus = Float64[]
    temperatureRange = Float64[]
    thermalCap = Float64[]
        
    singleData = MCSingleSim(MCS, GRID_SIZE, READ_STEPS, t, spins, ni, pi)
    
    name = string("data_spins_[", GRID_SIZE, "]")
    spins = singleData[1]
    write(name, string(spins))
    
    while t < T_END

        singleData = MCSingleSim(MCS, GRID_SIZE, READ_STEPS, t, spins, ni, pi)
        spins = singleData[1]
        push!(mediumM, singleData[2])
        push!(magneticSus, singleData[3])
        push!(temperatureRange, t)
        push!(thermalCap, singleData[4])

        if (t>2.1 && t<2.8)
            t += T_STEP * 0.1
        else
            t += T_STEP
        end
        print(round.(t, digits=4), "  ")
    end
    
    return [mediumM, magneticSus, temperatureRange, thermalCap]
end
 

#   main()
function main()

    T_START = 0.05   # T dla ktorej symulacja sie rozpoczyna, T* = 0.05, 2.269, 8
    GRID_SIZE = 70   # rozmiar jednego wymiaru sieci dwuwymiarowej (kwadratowej), L = 6, 20, 70
    MCS = 200000    # ilosc krokow symulacji MC


    T_END = 5.0   # T dla ktorej symulacja jest konczona
    T_STEP = 0.05   # delta T poza znaczacym przedzialem


    READ_STEPS = 500   # liczba okreslajaca, co ile krokow brane sa dane konfiguracji
    TEMPERATURE = 0.05  # do obserwowania spinow     

    temperatureRange = []
    @time data = simulate(MCS, GRID_SIZE, READ_STEPS, T_START, T_END, T_STEP)
   
    name = string("data_M_[", GRID_SIZE, "]")
    write(name, string(data[1]))

    name = string("data_M_SUS_[", GRID_SIZE, "]")
    write(name, string(data[2]))

    name = string("data_T_[", GRID_SIZE, "]")
    write(name, string(data[3]))

    name = string("data_THERM_CAP_[", GRID_SIZE, "]")
    write(name, string(data[4]))

end


#   MAIN
main()



