#This is one of the first Python projects I ever worked on 
#The goal of this Python program is: Given certain rates, compute total gas cost and total cost of the trip 

distance = int(input("Enter distance (miles): "))
MPG = int(input("Enter miles per gallon: "))

gasUsed = distance / MPG
gasPrice = float(input("Enter gas price: "))
carCost = gasUsed * gasPrice
print("Gas Cost of Trip is: ", carCost)

days = int(input("Enter number of days traveling: "))
stars = input("Enter number of stars of hotel (1-5): ")

nightsSpend = days - 1

price5star = 250
price4star = 180
price3star = 120
price2star = 100
price1star = 50

if stars == "1": 
    hotelPrice = price1star * nightsSpend
elif stars == "2": 
    hotelPrice = price2star * nightsSpend
elif stars == "3": 
    hotelPrice = price3star * nightsSpend
elif stars == "4": 
    hotelPrice = price4star * nightsSpend
elif stars == "5": 
    hotelPrice = price5star * nightsSpend
    
if nightsSpend > 2 and stars ==5: 
    hotelPrice = (hotelPrice *90)/100

mealCost = (hotelPrice * 20)/100
    

totalCost = mealCost + hotelPrice +carCost 

print("Total cost of the trip is: " + str(totalCost))
