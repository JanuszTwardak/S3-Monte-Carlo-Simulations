import random


def main():

    #USTAWIENIA SYMULACJI:
    STEPS = 1000
    DIVISIONS = 100
    D_PHI = 0.1

    #startowa funkcja
    phi = [0.2] * (DIVISIONS + 1)   # funkcja stała, wszystkie wartości startowo ustawione na 0.2
    divisionLength = 6 / DIVISIONS  # długość jednego podziału
 
    U = 0.0
    for i in range(DIVISIONS + 1):
        U += phi[i] * phi[i] * V(-3 + i * divisionLength)


    T = 0.0
    for i in range(1,100):
        T += 0.5 * (phi[i] * (2 * phi[i] - phi[i - 1] - phi[i + 1]))/(divisionLength**2)
    
    T += 0.5 / divisionLength * divisionLength * (phi[0] * (2 * phi[0] - phi[1]) + phi[DIVISIONS] * (2 * phi[DIVISIONS] - phi[DIVISIONS-1]))

    numerator = U + T

    denominator = 0
    for value in phi:
        denominator += value**2

    f = open("energytest.txt", 'w')
    g = open("phitest.txt", 'w')

    energy = numerator / denominator

    f.write(str(energy))
    f.write("\n")

    for _ in range(STEPS):
        for _ in range(DIVISIONS):
            randomX = random.randint(0, DIVISIONS)
            randomValue = random.random()

            phiTrial = phi[randomX] + (randomValue - 0.5) * D_PHI
            deltaPhi = phiTrial - phi[randomX]
            deltaPhiSquared = phiTrial**2 - phi[randomX]**2

            if(randomX != 0 and randomX != DIVISIONS):
                dT = (deltaPhiSquared - deltaPhi * (phi[randomX + 1] + phi[randomX - 1])) / (divisionLength**2)
            elif(randomX == 0):
                dT = (deltaPhiSquared - deltaPhi * (phi[randomX + 1]) + phi[randomX]) / (divisionLength**2)
            elif(randomX == DIVISIONS):
                dT = (deltaPhiSquared - deltaPhi * (phi[randomX - 1]) + phi[randomX]) / (divisionLength**2)

            dU = deltaPhiSquared * V(-3 + randomX * divisionLength)

            newEnergy = (numerator + dU + dT) / (denominator + deltaPhiSquared)

            if (energy > newEnergy):  
                energy = newEnergy
                numerator += dU + dT
                denominator += deltaPhiSquared
                phi[randomX] = phiTrial
                print(energy)
            
        f.write(str(energy))
        f.write("\n")
    g.write(str(phi))

    f.close()
    g.close()


#obliczanie V = 0.5 * x^2 + 0.1 * x^3
def V(x):
    V = 0.5 * x**2 + 0.1 * x**3
    return V


if __name__ == "__main__":

    main()
