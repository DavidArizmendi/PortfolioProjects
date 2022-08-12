#This is one of the first Python projects I ever worked on
#The goal of this Python program is: given certain rates, compute monthly cost of renting an office at a certain building 

Estimate = 0 
Count = 0

Quote = "y"

while(Quote == "y"):
    print("Need Office Space?") 
    print("==================")
    print("1- Private Office")
    print("2-Colocation")
    print("3-Temporary Workspace")

    Space = (input("What type of Space? 1, 2, or 3? "))
    RentCharges = 0
    PhoneCharges = 0

    if Space == "1":
        RentCharges += 1000
    elif Space == "2":
        RentCharges += 500
    elif Space == "3":
        days = int(input("How many days do you need? "))
        RentCharges += (days *60)
    
    PhoneService = input("Phone Service? (y/n) ")
    if PhoneService == "y":
        mins = int(input("How many minutes do you need? "))
        PhoneCharges += (mins * .50)
    
    print("Your monthly charge is " + str(RentCharges + PhoneCharges))
    
    Count += 1 
    Estimate += RentCharges + PhoneCharges
    
    Quote = input("Another quote? (y/n) ")
    if Quote != "y":
        break
    
print("Average quotation provided was " + str(Estimate/Count))

if Quote != "y":
    print("Press any key to continue...")
