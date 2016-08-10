import random

#pick a fake random seed from my mind
random.seed(888)

#first, figure out which women's kayaker to use
#Based on this list :
# https://www.google.com/webhp?sourceid=chrome-instant&ion=1&espv=2&ie=UTF-8#q=men%27s%20canoe%20team&mie=oly%2C%5B%22%2Fg%2F11c3ymwfzz%22%2C6%2C%22w%22%2C2%2C%22%2Fx%2F336rbv96sw9cw%22%2Cnull%2Cnull%2Cnull%2Cnull%2Cnull%2Cnull%2Cnull%2Cnull%2Cnull%2Cnull%2Cnull%2Cnull%2Cnull%2Cnull%2C20%5D
#ordered as is on the page

print('Use the person who is the ith person on the page : ')
print('https://www.google.com/webhp?sourceid=chrome-instant&ion=1&espv=2&ie=UTF-8#q=men%27s%20canoe%20team&mie=oly%2C%5B%22%2Fg%2F11c3ymwfzz%22%2C6%2C%22w%22%2C2%2C%22%2Fx%2F336rbv96sw9cw%22%2Cnull%2Cnull%2Cnull%2Cnull%2Cnull%2Cnull%2Cnull%2Cnull%2Cnull%2Cnull%2Cnull%2Cnull%2Cnull%2Cnull%2C20%5D')

womenKayaker = random.randint(0,14)
print(womenKayaker)

#Next, we create a list and shuffle it.
#Follow 

listOfPeople = ['Russell', 'Ryne', 'MattA', 'MattS', 'Laura', 'Felix', 'Frank', 'Rex', 'Zach', 'Meghan', 'Brad','Susan']
assert(len(listOfPeople) == 12)

print ('List of people : ' , listOfPeople )
print ('Match to this ordered list of teams : ')

teams = [str(womenKayeker) , 'poland','us','suisse','russia','brazil','slovenia','germany','cz republic','great britain','france','slovakia']

print('Randomizing ')
listOfPeople.shuffle()

dictOfFinalResults = dict(zip( listOfPeople , teams ))
print("Final team mappings :")

for k,v in dictOfFinalResults :
    print(k,v)
