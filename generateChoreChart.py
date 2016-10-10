import pandas as pd
import numpy as np

start_date = "2016-10-10"
dates = pd.date_range(start=start_date, periods=300, freq='D')

def getFrequencyArray(frequency,start_offset,start_inversion=True):
    zr = pd.Series("", index=dates)
    chore_dates = pd.Series(pd.date_range(start=pd.Timestamp(start_date) + pd.DateOffset(start_offset),
                                          end = dates[-1] ,
                                          freq = str(frequency) + 'D'))
    chore_split = (chore_dates.iloc[::2],
                   chore_dates.iloc[1::2],)

    zr.loc[chore_split[0]] = "Russell"
    zr.loc[chore_split[1]] = "Marisa"
    return zr

chores = {"cleanBathroom" : getFrequencyArray( 7, 0),
          "cleanKitchen"  : getFrequencyArray( 7, 0),
}

choreChart = pd.DataFrame(chores, index=dates)

print(choreChart)
choreChart.to_csv("output.csv")
