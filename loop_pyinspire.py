# script using
# https://bitbucket.org/ihuston/pyinspire
# to loop and get hopefully the whole inspire database 

import string
import subprocess


def createSearchString(letters, year):
    yearString = str(year)
    search = " ".join(['\'', "d == " + yearString, "a " + "".join(letters) + "*" '\''])
    return search

years = range(1960,2017)
alphabet = list(string.ascii_lowercase)

print(years)
print(alphabet)

inspirebib = open('inspire.bib', 'w')

with open('inspire.bib', 'w') as outfile:
    for year in years:
        for firstletter in alphabet:
            for secondletter in alphabet:
                print( str(year) , firstletter+secondletter)

                bibout = subprocess.check_output(["python","pyinspire.py", "-b", "-s", createSearchString([firstletter,secondletter],year) ] ).strip()
                bibout_string = bibout.decode("utf-8") 
            
                #            print(bibout_string)
                outfile.write(bibout_string)
                #bibout_string.replace(',\\n', ',')
