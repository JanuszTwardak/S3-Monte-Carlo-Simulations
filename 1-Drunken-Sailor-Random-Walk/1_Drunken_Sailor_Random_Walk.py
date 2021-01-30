import random


def main():

    #liczba krokow
    NUMBER_OF_STEPS = 100000

    #liczba marynarzy
    NUMBER_OF_SAILORS = 1000
    
    #zapisanie pozycji kazdego marynarza do listy 
    storedPositions = startSimulation(NUMBER_OF_SAILORS, NUMBER_OF_STEPS)     

    # zapis danych do pliku .txt
    saveToFile(storedPositions, NUMBER_OF_SAILORS)


def startSimulation(NUMBER_OF_SAILORS, NUMBER_OF_STEPS):

    #zainicjalizowanie listy, w ktorej beda przechowywanie pozycje
    storedPositions = []

    #petla wykonuje sie dla kazdego marynarza
    for _ in range (0, NUMBER_OF_SAILORS):
        position = 0

        #droga jednego marynarza
        for _ in range (0, NUMBER_OF_STEPS):
            randomNumber = random.random()
            if (randomNumber > 0.5):
                position += 1
            else:
                position -= 1

        storedPositions.append(position)    #dodanie pozycji marynarza do listy
    
    #na koniec metoda zwraca wszystkie pozycje
    return storedPositions


def saveToFile(storedPositions, NUMBER_OF_SAILORS):

    f = open("1000m-100000kv2.txt", 'w')
    for i in range(0, NUMBER_OF_SAILORS):
        f.write(str(storedPositions[i]))
        f.write("\n")
    f.close()


if __name__ == "__main__":
    main()