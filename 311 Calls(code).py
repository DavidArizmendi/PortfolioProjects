# NYC 311 Calls Analysis ( Data Visualization Project using Python)

# THIS IS ONLY THE CODE. 
# TO SEE THE WHOLE PROJECT WITH THE VISUALIZATIONS (YOU CAN SCROLL DOWN ALL THE WAY TO THE BOTTOM TO SEE THE VISUALIZATIONS, WHICH WE PUT TOGETHER)... 
# ...PLEASE GO TO: https://colab.research.google.com/drive/1AL3Cv4bkBNDrWZuHTM6henVgYs1qA83O?usp=sharing



# Team members: David Arizmendi, Yang Song, Omar Lazaro
# Source: NYC open data. Because the original dataset is quite large (26million rows for 1 year), we narrowed it down to one month of data - April 2022
# Original source: https://data.cityofnewyork.us/Social-Services/311-Service-Requests-from-2010-to-Present/erm2-nwe9


#load packages
#packages
!pip install geopandas
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import panel as pn
from panel.interact import interact, interactive, fixed, interact_manual
from panel import widgets
pn.extension()
%matplotlib inline
%matplotlib notebook

import geopandas as gpd
import json

from bokeh.plotting import figure, show, output_notebook
from bokeh.tile_providers import CARTODBPOSITRON, get_provider
from bokeh.models import ColumnDataSource, GeoJSONDataSource, LinearColorMapper, ColorBar
from bokeh.palettes import brewer

import warnings
warnings.filterwarnings('ignore')

output_notebook()

# read the file
df = pd.read_csv('https://query.data.world/s/svkt7shxhbgx5vkm65lwj6esovtaeg')
df

#inspect the dataset
df.info()

#dataset rows and columns
df.shape

#install bokeh
!pip install pandas-bokeh
import pandas_bokeh
pandas_bokeh.output_notebook()

# install plotly
pn.extension('plotly')
import plotly.express as px

#let's see complaint cases count throughout boroughs
comcount = df.groupby([df["Complaint Type"],df["Borough"],df["Status"]])['Unique Key'].count().reset_index()
comcount = comcount.rename(columns={"Unique Key":"Count"})

comcount

#cases count review across Boroughs
sorted_comcount = comcount.sort_values('Count',ascending = False)

#make a grouped bar chart to see complaint count by Boroughs
px.bar(sorted_comcount, x="Borough", color="Status",
                        y='Count',
                        title="Grouped Bar Chart",
                       barmode='group',
                       height=600
                 )

#Checking the count for different complaint types
comtypetop10 = df['Complaint Type'].value_counts()[:10]
comtypetop10

#Creating a bar chart to show top 10 Complaint Types across all Boroughs
px.bar(comtypetop10, 
                        title="Top 10 Complaint Types",
                      labels={'index':'Complaint Types','value':'Count' },width=1000, height=500,
                 )

#Creating a list with the boroughs to get rid of the "Unspecified" borough
boroughs = ['BROOKLYN', 'BRONX','QUEENS','MANHATTAN','STATEN ISLAND'] 

#Creating a list with the top 5 complaint types
top5_complaints = ['Illegal Parking', 'Noise - Residential','HEAT/HOT WATER','Blocked Driveway','Noise - Street/Sidewalk'] 

#Creating a subdataframe that only has the top 5 complaint types
top5_subdf = df[df['Complaint Type'].isin(top5_complaints)] 

#Taking a look at the new subdf 
top5_subdf.head()

#Taking a look at the Boroughs 
top5_subdf.Borough.value_counts()

#Modifying the subdf with top 5 complaints so that it only includes the actual Boroughs
top5_subdf = top5_subdf[top5_subdf['Borough'].isin(boroughs)] 

#Vertifying that "UNSPECIFIED" Borough is gone
top5_subdf.Borough.value_counts()

#let's see complaint cases count throughout boroughs for the top 5 complaints
comcount2 = top5_subdf.groupby([top5_subdf["Complaint Type"],top5_subdf["Borough"],top5_subdf["Status"]])['Unique Key'].count().reset_index()
comcount2 = comcount2.rename(columns={"Unique Key":"Count"})

comcount2.head()

#Creating a bar chart that shows top 5 complaint types by Borough
px.bar(comcount2, x='Borough', y='Count', color='Complaint Type', 
       color_discrete_map={'Illegal Parking': 'yellow', 'Blocked Driveway': 'black','HEAT/HOT WATER': 'pink', 'Noise - Residential': 'brown',
                           'Noise - Street/Sidewalk':'magenta'}, title='Top 5 Complaint Types Across Boroughs', barmode='group')

# Modifying the Created Date column to make our following visualizations more appealing 
df['Created Date'] = pd.DatetimeIndex(df['Created Date']).date

# Showing the change 
df.head()

#let's see complaint cases count throughout boroughs and create another subdf grouped by some useful categories 
comcount3 = df.groupby([df["Complaint Type"],df["Borough"],df["Status"], df["Created Date"]])['Unique Key'].count().reset_index()
comcount3 = comcount3.rename(columns={"Unique Key":"Count"})


comcountD= comcount3.groupby([comcount3["Complaint Type"],comcount3["Borough"],comcount3["Created Date"]])['Count'].sum().reset_index()
comcountD

#Creating another subdf grouping by Boroughs, the Incident Date and their count of occurrences
comcount4 = comcount3.groupby([comcount3["Borough"],comcount3["Created Date"]])['Count'].sum().reset_index()


comcount4

# Removing the "Unspecified" Borough so that it does not ruin the next visualization 
comcount5 = comcount4[comcount4['Borough'].isin(boroughs)] 

# Creating a line chart to show the trend of daily number of complaints by Borough 
px.line(comcount5,x='Created Date', y='Count', color='Borough', title='Trend of Daily Number of Complaints by Borough')

#check the datatypes
comcount.dtypes

#check the complaint types
typelabel = comcount["Complaint Type"].unique().tolist()

#check the status 
statuslabel = comcount["Status"].unique().tolist()
statuslabel

#area list
arealabel = comcount["Borough"].unique().tolist()
arealabel

arealabel2= top5_subdf["Borough"].unique().tolist()
arealabel2

#create dropdown list of types
uType = pn.widgets.Select(name = "Select Complaint Type From Below List", 
                          options = typelabel,
                          value ="Traffic")
uType

#create dropdown list of types
uStatus = pn.widgets.Select(name = "Select Complaint Status From Below List", 
                          options = statuslabel,
                          value ="In Progress")
uStatus

#area dropdown list
uArea = pn.widgets.Select(name = "Select Borough From Below List", 
                          options = arealabel2,
                          value ='BROOKLYN')
uArea

#convert the variable type
comcount['Borough'] = comcount['Borough'].astype('string')
comcount['Count'] = comcount['Count'].astype('int64')
comcount['Status'] = comcount['Status'].astype('string')
comcount['Complaint Type'] = comcount['Complaint Type'].astype('string')
comcount.dtypes

#make a bar plot to see complaint cases by Borough
px.bar(comcount, x= 'Borough', y="Count", hover_data=['Count', 'Status'],color="Status",barmode='stack', title ="311 complaint by Boroughs")

#pin the dropdown list to barplot
@pn.depends(uType)
def firstplot(type_val):
    val= comcount[comcount['Complaint Type']==type_val]
    fig = px.bar(val, x="Borough", y="Count", color = "Status",
                 color_discrete_map={'Closed':'green', 'In Progress':'yellow', 'Open':'red', 'Assigned':'blue',
                                     'Pending':'brown', 'Started':'black', 'Unspecified':'pink'}, title = "Complaints in each Borough",width=1000, height=500) 
    return fig

comcount = df.groupby([df["Complaint Type"],df["Borough"],df["Status"]])['Unique Key'].count().reset_index()
comcount = comcount.rename(columns={"Unique Key":"Count"})

comcount

top5_subdf = top5_subdf.groupby([top5_subdf["Complaint Type"],top5_subdf["Borough"],top5_subdf["Status"]])['Unique Key'].count().reset_index()
top5_subdf = top5_subdf.rename(columns={"Unique Key":"Count"})

top5_subdf.head()

#pin the dropdown list to barplot
@pn.depends(uArea)
def comp5(area_val):
    val= top5_subdf[top5_subdf['Borough']==area_val]
    fig = px.bar(val, x="Complaint Type", y="Count", color="Complaint Type",
                 color_discrete_map={'Illegal Parking': 'yellow', 'Blocked Driveway': 'black','HEAT/HOT WATER': 'pink', 'Noise - Residential': 'brown',
                           'Noise - Street/Sidewalk':'magenta'}, title = "Top 5 Complaint Types by Borough",width=1000, height=500) 
    return fig

#plotting
pn.Column(uArea,comp5)

df["Status"].value_counts()

#plotting
pn.Column(uType,firstplot)

#check comcount list
comcount.head()

comcount["Complaint Type"].value_counts()

#check the complaint types
typelabel = comcount["Complaint Type"].unique().tolist()

#pin the dropdown list to barplot
@pn.depends(uType)
def firstplot(type_val):
    val= comcount[comcount['Complaint Type']==type_val]
    fig = px.bar(val, x="Borough", y="Count", color = "Status",
                 color_discrete_map={'Closed':'green', 'In Progress':'yellow', 'Open':'red', 'Assigned':'blue',
                                     'Pending':'brown', 'Started':'black', 'Unspecified':'pink'}, title = "Complaints in each Borough",width=1000, height=500) 
    return fig

#pin the dropdown list to barplot
@pn.depends(uType)
def Davidplot2(date_val):
    val1= comcount5[comcount5['Created Date']==date_val]
    fig = px.line(val1, x="Created Date", y="Count", color = "Borough", title = "Trend of Daily Number of Complaints by Borough",width=1000, height=500) 
    
    return fig

#Let's get a new dataframe grouping by created date
comcount10 = df.groupby([df["Created Date"],df["Borough"],df["Complaint Type"]])['Unique Key'].count().reset_index()
comcount10 = comcount10.rename(columns={"Unique Key":"Count"})
comcount10

#create a function to see different complaint type in each Borough over time
@pn.depends(uType)
def firstplot10(type_val):
    val= comcount10[comcount10['Complaint Type']==type_val]
    fig = px.line(val, x="Created Date", y="Count", color = "Borough", color_discrete_map={'MANHATTAN': 'green', 'BROOKLYN': 'red','BRONX': 'blue', 'QUEENS': 'purple',
                           'STATEN ISLAND':'orange', 'Unspecified':'black'}, 
                 title = "Complaints in each Borough",width=1000, height=500) 
    return fig

#plotting
pn.Column(uType,firstplot10)

# Making a plot to see Trend of daily number of complaints by Borough
px.line(comcount5,x='Created Date', y='Count', color='Borough', title='Trend of Daily Number of Complaints by Borough', width=1100, height=600)

#make an interactive plot to filter borough
@pn.depends(uArea)
def secondplot(area_val):
    sta= comcount[comcount['Borough']==area_val]
    fig = px.bar(sta, x="Status", y="Count",barmode='stack', title = 'Total Complaints by Status and Borough',width=1000, height=500)
    return fig

pn.Column(uArea,secondplot)

#New DF for chart
TotalDatav2 = df.groupby([df["Created Date"],df["Complaint Type"],df["Borough"],df["Status"]])['Unique Key'].count().reset_index()
TotalDatav2 = TotalDatav2.rename(columns={"Unique Key":"Count"})

#create dropdown list of types
pType = pn.widgets.Select(name = "Select Complaint Type From Below List", 
                          options = typelabel)
pType

# new function to show the created date by count of complaints and be able to filter by complaint type
@pn.depends(pType)
def fifthplot(type_valv2):
    val2= TotalDatav2[TotalDatav2['Complaint Type']==type_valv2]
    fig2 = px.bar(val2, x="Created Date", y="Count", color = "Status",
                  color_discrete_map={'Closed':'green', 'In Progress':'yellow', 'Open':'red', 'Assigned':'blue',
                                     'Pending':'brown', 'Started':'black', 'Unspecified':'pink'}, title = "Daily Complaints",width=1000, height=500)
    return fig2

#plotting
pn.Column(pType,fifthplot)

###Geo map plot


import geopandas as gpd
import json

#read the nyc zipcode geojson boundary file using geopandas
zipShape = gpd.read_file('https://data.beta.nyc/dataset/3bf5fb73-edb5-4b05-bb29-7c95f4a727fc/resource/894e9162-871c-4552-a09c-c6915d8783fb/download/zip_code_040114.geojson')
#getting the year value first in a separate column
#then grouping by date and zipcode to see how many center opened in each zipcode
df['Created Date'] = pd.DatetimeIndex(df['Created Date']).date
zipdateCnt = df.groupby(['Incident Zip',"Created Date",])['Unique Key'].count().reset_index()
zipdateCnt["Incident Zip"] = zipdateCnt["Incident Zip"].astype('float')
zipdateCnt["Incident Zip"] = zipdateCnt["Incident Zip"].astype('int')
zipdateCnt["Incident Zip"] = zipdateCnt["Incident Zip"].astype('string')
zipdateCnt


#check data types
zipdateCnt.dtypes

#check data types
zipShape.dtypes

#rename columns
zipdateCnt.rename(columns={'Unique Key':'Count', 'Incident Zip':'Zipcode'}, inplace =True)
zipdateCnt


#change type to str
zipShape["ZIPCODE"] = zipShape["ZIPCODE"].astype('string')



#combining the zip boundary shape data with
zipdateCntShape =pd.merge(zipShape,zipdateCnt,how='inner',left_on='ZIPCODE',right_on='Zipcode')
zipdateCntShape

#check columns
zipdateCntShape.columns

#create a new count/population ratio variable
zipdateCntShape['count_population_ratio']= zipdateCntShape["Count"]/zipdateCntShape["POPULATION"]
zipdateCntShape['count_population_ratio']

#add the year slider with ranges set to min and max values of opening year
import datetime as dt
dateSlider=pn.widgets.DateSlider(name='Date Slider',
                               start=dt.date(2022, 4, 1),
                               end=dt.date(2022, 4, 30),
                               value=dt.date(2022, 4, 10))

dateSlider

@pn.depends(dateSlider)
def complaintChoroMap(paramSlider):
    #get the cumulative number of complaint per zipcode by that date
    zipdateCum = zipdateCnt[zipdateCnt['Created Date']<=paramSlider]
    zipdateCumGrp = zipdateCum.groupby(['Zipcode'])['Count'].sum().reset_index()
    zipdateCumGrp['Zipcode'] = zipdateCumGrp['Zipcode'].astype('str')
    #Merge the count by zipcode/year dataset and zip shape files and zip code field
    zipdateCntShapeCum = pd.merge(zipShape, zipdateCumGrp, how='inner', left_on ='ZIPCODE', right_on ='Zipcode')
    #convert the merged shape count file to geojson format needed for bokeh
    json_data = json.dumps(json.loads(zipdateCntShapeCum.to_json()))
    geozipCntShape = GeoJSONDataSource(geojson = json_data)
    
    #which interactive tools you want
    tools = "wheel_zoom,pan,reset,hover"
    
    #what to show when hovering over
    hoverText = [('Zipcode',"@ZIPCODE"),('Number of complaint',"@Count"),('Population',"@POPULATION")]
    plotTitle = "Total # of NYC Complaint" +str(paramSlider)
    
    #Create the figure
    p = figure(title = plotTitle, plot_height=600, plot_width=600,
              x_range=(-74.26,-73.68), y_range=(40.48, 40.93),
              toolbar_location ='right', tools=tools, tooltips=hoverText)
    #create the colormap based legend with linearcolorMapper and colorBar
    palette = brewer['OrRd'][8]
    palette = palette[::-1]
    #instantiate linearColor Mapper that linearly maps numbers in a range
    DC_mapper = LinearColorMapper(palette = palette,
                                 low =zipdateCntShapeCum['Count'].min(),
                                 high =zipdateCntShapeCum['Count'].max())
    color_bar = ColorBar(color_mapper =DC_mapper, label_standoff =5, width=300, height=20,
                        location=(0,0),
                         orientation ='horizontal')
    #use the patch renderer ootion to add zipcode boundary shapes to the figure
    p.patches('xs','ys', source=geozipCntShape, fill_alpha=1, line_width=0.1, line_color='black',
             fill_color={'field':'Count', 'transform':DC_mapper})
    
    p.add_layout(color_bar, 'above')
    p.xgrid.grid_line_color =None
    p.ygrid.grid_line_color =None 
    return(p)

#pn.Row(dateSlider,complaintChoroMap).servable()
pn.Row(dateSlider, complaintChoroMap)

#Reading a new dataframe with "Resolution Time" column – a calculated field ((Closed Date - Created Date) * 1440) [We multiplied by 1440 to convert to minutes]
df1 = pd.read_excel('https://query.data.world/s/m6fuy4jwxbmai2unmqg2sg3724gsoa')
df1

# Modifying the Date column to make following visualizations more appealing 
df1['Created Date'] = df1['Created Date'].astype('string')
df1['Created Date'] = pd.DatetimeIndex(df1['Created Date']).date

#Showing the change
df1.head(10)

# we grouped by created date to see cases across all Boroughs and computed resolution time in days
comcount8 = df1.groupby([df1["Created Date"],df1['Borough']])['Resolution Time'].mean().reset_index()
comcount8['Resolution_days'] = comcount8['Resolution Time']/1440
comcount8

#Removing "Unspecified" Borough 
comcount9=comcount8[comcount8['Borough'].isin(boroughs)]

# plot a line chart to see trends
px.line(comcount9,x='Created Date', y='Resolution_days', color='Borough',title='Average Resolution Time Complaints by Borough')

tile_provider = get_provider(CARTODBPOSITRON)
#range bounds supplied in web mercator coordinates for NYC region
#passing x_axis_type="mercator" and y_axis_type = 'mercator' to figure generates axes with latitudute and
#longittude labels instead of raw web mercator coordinates
p = figure(x_range = (-8259906.21686089, -8204246.471464255),
          y_range =(4938869.1755786293, 5812341.663847511),
          x_axis_type ="mercator", y_axis_type = "mercator")
p.add_tile(tile_provider)

show(p)

#to convert lat long values to web mercator coodinates
def wgs84_to_web_mercator(df, lat, lon):
    k = 6378137
    df["wbm_x"] = df[lon]*(k*np.pi/180.0)
    df["wbm_y"] = np.log(np.tan((90+df[lat])* np.pi/360.0))*k
    return df

#copy dataset
df1 = df

#transforming any 9 digit
df1['Incident Zip'] = df1['Incident Zip'].astype('str')
df1['Incident Zip'] = df1['Incident Zip'].str.slice(0, 5, 1)

#add the textinput widget to allow users to search for centers using zipcode
uZip = pn.widgets.TextInput(name="Enter the zipcode", value="10010", width = 200)

#create the custom map zooming to that zipcode area
@pn.depends(uZip)
def complaintzipMap(paramZip):
    tile_provider = get_provider(CARTODBPOSITRON)
    #filter the dataframe to match only user provided
    zip_dc = df1[df1["Incident Zip"]==paramZip]
    #transform the lat lon values to webmercator coordinates
    wbm_DC = wgs84_to_web_mercator(zip_dc,"Latitude","Longitude")
    #convert to columnDataSource format that bokeh needs
    wbm_zipDC =ColumnDataSource(data= wbm_DC)
    #in the hover text, include Complaint Type name and Complaint closed date
    hoverText =[('Complaint Type',"@{Complaint Type}"),('Closed Date',"@{Closed Date}")]
    # create figure with min and max values of web mercator coordinates for x and y
    p = figure(x_range =(min(wbm_DC['wbm_x']),max(wbm_DC['wbm_x'])), y_range=(min(wbm_DC['wbm_y']),max(wbm_DC['wbm_y'])),
               x_axis_type = "mercator", y_axis_type="mercator",
               tooltips = hoverText)#add the hovertext to the figure
    p.circle(x="wbm_x", y="wbm_y", size =5, fill_color ="blue", fill_alpha=0.8, source =wbm_zipDC)
    p.add_tile(tile_provider)
    return p

#launching the panel app
pn.Row(uZip,complaintzipMap)

#Put everything together to make a dashboard

# Create tab 1 
tab1= pn.Column(uType,firstplot)

# Create tab 2
tab2= pn.Column(pType,fifthplot)

# Create tab 3
tab3= px.bar(comcount2, x='Borough', y='Count', color='Complaint Type', 
       color_discrete_map={'Illegal Parking': 'yellow', 'Blocked Driveway': 'black','HEAT/HOT WATER': 'pink', 'Noise - Residential': 'brown',
                           'Noise - Street/Sidewalk':'magenta'}, title='Top 5 Complaint Types by Borough', barmode='group', width=1100, height=600)

# Create tab 4
tab4= pn.Column(uArea,comp5)

# Create tab 5
tab5= px.line(comcount5,x='Created Date', y='Count', color='Borough', title='Trend of Daily Number of Complaints by Borough', width=1100, height=600)

# Create tab 6
tab6= px.line(comcount9,x='Created Date', y='Resolution_days', color='Borough',
              color_discrete_map={'MANHATTAN': 'green', 'BROOKLYN': 'red','BRONX': 'blue', 'QUEENS': 'purple',
                           'STATEN ISLAND':'orange', 'Unspecified':'black'},title='Average Resolution Time for Complaints by Borough', width=1100, height=600)

# Create tab 7
tab7= pn.Row(dateSlider, complaintChoroMap)

#Create tab 8
tab8 = pn.Row(uZip,complaintzipMap)

#Create tab 9
tab9 =pn.Column(uType,firstplot10)

# Put tabs together
tabs= pn.Tabs(("Complaints in each Borough", tab1), ("Daily Complaints", tab2), ("Top 5 Complaint Types across Boroughs", tab3), ("Top 5 Complaint Types by Borough", tab4), ("Trend of Daily Number of Complaints by Borough", tab5),("Daily Number of Complaints by Borough with type filter", tab9), ("Average Resolution Time for Complaints by Borough ", tab6), ("Geographical Distribution of Complaints", tab7),("Complaints Locations at Zipcode level", tab8),tabs_location='left')

# Show tabs
tabs

# Display tabs properly 
tabs.servable()
