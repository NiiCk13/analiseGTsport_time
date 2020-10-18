# -*- coding: utf-8 -*-
# Run this app with `python app.py` and
# visit http://127.0.0.1:8050/ in your web browser.
import dash
import dash_table
import dash_core_components as dcc
import dash_html_components as html
import plotly.express as px
import plotly.graph_objects as go
import pandas as pd
import numpy as np
from dash.dependencies import Input, Output
external_stylesheets = ['https://codepen.io/chriddyp/pen/bWLwgP.css']
app = dash.Dash(__name__, external_stylesheets=external_stylesheets)


#Get all the tables that are used
dimensionContinent = pd.read_excel('dim_continent.xlsx')
dimensionTracks = pd.read_excel('DimensionTable_GtTracks.xlsx')
factTimes = pd.read_csv('FactTable_gtTimes.csv')

#Transfomation all the files in dataframes
df_continents = pd.DataFrame(dimensionContinent)
df_tracks = pd.DataFrame(dimensionTracks)
df_times = pd.DataFrame(factTimes)

#clean all dataframes



#all the joins and transformations to main table
df = pd.DataFrame(df_times.merge(df_tracks, how='inner',  left_on='Link', right_on='Leaderboards'))
df = pd.DataFrame(df.merge(df_continents, how='inner',  left_on='Ctry', right_on='name'))#Full data Table Frame
df[['Id']] = np.arange(len(df))
df['#'] = df['#'].str.replace('=','')


#build the firs fact dataframe
df1 = df.groupby(['End', 'region', 'Ctry', 'Course', 'Tyres']).agg({'Id': ['sum']})
df1.columns = ['Qty']
df1 = df1.reset_index()

#set the filters variables
regionFilter = df1['region'].unique()




#coding to declare the style of page
colors = {
    'background': '#F7F7F0',
    'text': '#696964 ',
    'backgroundTable': '#FFFFFF'
}





app = dash.Dash(__name__)
#intance the elements on the canvas and scribe the title of the page
app.layout =html.Div(style={'backgroundColor': colors['background']},
                       children=[html.H1(style={'color': colors['text']},
                                         children="GT Sport Data"
                        ),
                        #plot the text that will describe the roport page
                        html.Div(style={'color': colors['text']},
                                 children ="Dash to show the quantity of participants in the Daily races by the country and tracks"
                        ),
                        #plot the filter field on the screen to Graph bellow
                        html.Aside(children=[html.Label('Filter you continent'),
                                    dcc.Dropdown(id='QtyPlayer-regionF',
                                                 options=[{'label': i, 'value': i} for i in regionFilter],
                                                 value='Europe',
                                                 multi = False
                                     )]
                        ),
                        #plot the main Graphic on the Screen
                        dcc.Graph(id="QtyPlayer-Ctry"

                        ),
                        #plot the table base to Graph bellow on the screen
                        html.Div(style={'backgroundColor': colors['backgroundTable']},
                                 children =[dash_table.DataTable(
                                                                id='table',
                                                                columns=[{"name": i, "id": i} for i in df.columns],
                                                                page_current=0,
                                                                page_size=25,
                                                                page_action='custom',

                                                                )]

                        ),
                                #aspace to add another text by using html components or instanciate a Graph using dcc.Graph
                                #aspace to add another text by using html components or instanciate a Graph using dcc.Graph
                                #aspace to add another text by using html components or instanciate a Graph using dcc.Graph
                        ])



#Codes to realize the updates in the graphs results



@app.callback(
    Output('QtyPlayer-Ctry', 'figure'),
    Output('table', 'data'),
    [Input('QtyPlayer-regionF', 'value'), #call the filter by continent
     Input('table', "page_current"),
     Input('table', "page_size")
    #aspace to add another call
    #aspace to add another call
    #aspace to add another call
    ])

def update_graph(QtyPlayer_regionF,page_current, page_size):
    data = px.data.gapminder()

    dfRegion = df1[df1['region'] == QtyPlayer_regionF]
    dfRegionTable = df[df['region'] == QtyPlayer_regionF]


    #coding to declare the graph proprities
    fig = px.bar(dfRegion, x="Ctry", y='Qty')#grafic to show the quantity of racers by Ctry, but be able to use Tyre types, Course of event, anda Full date
    tab= dfRegionTable.iloc[
    page_current * page_size:(page_current + 1) * page_size
    ].to_dict('records')




    # codig to instance the plot on the screen
    fig.update_layout(
        plot_bgcolor=colors['background'],
        paper_bgcolor=colors['background'],
        font_color=colors['text']


    )



    return fig,tab






if __name__ == '__main__':
    app.run_server(debug=True)
