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
pd.set_option('display.max_rows', 50000)
pd.set_option('display.max_columns', 500)
pd.set_option('display.width', 500000)



external_stylesheets = ['https://codepen.io/chriddyp/pen/bWLwgP.css']
app = dash.Dash(__name__, external_stylesheets=external_stylesheets)


#Get all the tables that are used
dimensionContinent = pd.read_excel('dim_continent.xlsx')
dimensionTracks = pd.read_excel('DimensionTable_GtTracks.xlsx')
trackImages = pd.read_excel('trackImages.xlsx')
countryFlags = pd.read_excel('dim_countries.xlsx')
factTimes = pd.read_csv('FactTable_gtTimes.csv')

#Transfomation all the files in dataframes
df_continents = pd.DataFrame(dimensionContinent)
df_trackImages = pd.DataFrame(trackImages)
df_countryFlags = pd.DataFrame(countryFlags)
df_tracks = pd.DataFrame(dimensionTracks)
df_times = pd.DataFrame(factTimes)

#clean all dataframes



#all the joins and transformations to main table
df = pd.DataFrame(df_times.merge(df_tracks, how='inner',  left_on='Link', right_on='Leaderboards'))
df = pd.DataFrame(df.merge(df_continents, how='inner',  left_on='Ctry', right_on='name'))#Full data Table Frame
df = pd.DataFrame(df.merge(df_trackImages,how='left', left_on='Course', right_on='Course'))

df[['Id']] = np.arange(len(df))
df['#'] = df['#'].str.replace('=','')


#build the firs fact dataframe
df1 = df.groupby(['region', 'Ctry']).agg({'Id': ['count']})
df1.columns = ['Qty']
df1 = df1.reset_index()
dfRegionTable = df[['Time',	'Player', 'Ctry', 'Gap', 'Link', 'Course', 'Tyres', 'name']]


#2 dataframe
df_BestplayersOverall = df[['Gap']]=='00.000'
df_BestplayersOverall = df.groupby(['Player','LinkFlag']).agg({'Id':['count']})
df_BestplayersOverall.columns = ['Qty']
df_BestplayersOverall = df_BestplayersOverall.reset_index()
df_BestplayersOverall = df_BestplayersOverall.sort_values('Qty',ascending=False)



#3 dataframe
df_BestplayersByTrack = df[['Gap']]=='00.000'
df_BestplayersByTrack = df.groupby(['Player','Course','LinkFlag','LinkImg']).agg({'Id':['count']})
df_BestplayersByTrack.columns = ['Qty']
df_BestplayersByTrack = df_BestplayersByTrack.reset_index()
df_BestplayersByTrack = df_BestplayersByTrack.sort_values('Qty',ascending=False)


#4

df_qtyContinent = df.groupby(['region']).agg({'Id':['count']})
df_qtyContinent.columns = ['Qty']
df_qtyContinent = df_qtyContinent.reset_index()
df_qtyContinent = df_qtyContinent[0:4]
d = go.Figure(data=[go.Pie(labels=df_qtyContinent['region'], values=df_qtyContinent['Qty'],hole=.6,marker_colors=['rgb(56, 75, 126)', 'rgb(18, 36, 37)', 'rgb(34, 53, 101)',
                'rgb(36, 55, 57)', 'rgb(6, 4, 4)'], pull=[0 ,0 ,0 ,0.05])])





#set the filters variables
regionFilter = df1['region'].unique()




#coding to declare the style of page
colors = {
    'headerBackground': '#0a0e22',
    'background': '#d9d9d9',
    'backgroundGraphs': '#FFFFFF',
    'text': '#696964 ',
    'backgroundTable': '#FFFFFF'
}


app = dash.Dash(__name__)
#intance the elements on the canvas and scribe the title of the page
app.layout = html.Div(style={'backgroundColor': colors['background'],
                             'margin':'0',
                             'padding':'0',
                             'font-family': 'Helvetica Neue, HelveticaNeue-Medium, HelveticaNeue-Light,Roboto, sans-serif',
                             'font-size':'14px',
                             'line-height': '1',
                             '-webkit-font-smoothing': 'antialiased'},

                      children=[html.Div([
                                          html.Img(src='https://www.gran-turismo.com/common/front/img/global/logo-gt.svg',
                                                   style={'position' :'absolute',
                                                          'margin-top': '1%',
                                                          'margin-left': '2%'
                                                          }),

                                          html.H1('GT-Sport Daily Races analysis | ',
                                                  style={'margin-left':'10%',
                                                         'margin-top':'1.5%',
                                                         'font-style': 'italic',
                                                         'display': 'inline-block',
                                                         'color': '#FFFFFF'})

                                         ],
                                        style={'backgroundColor': colors['headerBackground'],
                                               "height": "15%",
                                               'border-bottom': '10px solid #4d5668'}
                                    ),

                        #plot the text that will describe the roport page
                        html.Div(style={'color': colors['text']},
                                 children ="Dash to show the quantity of participants in the Daily races by the country and tracks"
                        ),
                        #plot the indicator cards bellow of the header
                            html.Div([
                                    html.Div([html.Div('1st Daily Player',id='1stT'),
                                              html.H6(df_BestplayersOverall['Player'][0],
                                                      style={'font-size': '1.2rem',
                                                             'line-height': '1.6',
                                                             'letter-spacing': '0',
                                                             'margin-bottom': '0.75rem',
                                                             'margin-top': '0.75rem'}),
                                              html.Img(src= df_BestplayersOverall['LinkFlag'][0],
                                                       style={'max-width':'35%',
                                                              'max-height':'35%',
                                                              'float':'right'})],

                                    id='1stP',style={'border-radius': '5px',
                                                     'background-color': '#f9f9f9',
                                                     'margin': '10px',
                                                     'padding': '15px',
                                                     'position': 'relative',
                                                     'flex': '1',
                                                     'box-shadow': '2px 2px 2px lightgrey'}),



                                    html.Div([html.Div('2nd Daily Player',id='2ndT'),
                                              html.H6(df_BestplayersOverall['Player'][1],
                                                      style={'font-size': '1.2rem',
                                                             'line-height': '1.6',
                                                             'letter-spacing': '0',
                                                             'margin-bottom': '0.75rem',
                                                             'margin-top': '0.75rem'}),
                                              html.Img(src= df_BestplayersOverall['LinkFlag'][1],
                                                       style={'max-width':'35%',
                                                              'max-height':'35%',
                                                              'float':'right'})],

                                    id='2ndP',style={'border-radius': '5px',
                                                     'background-color': '#f9f9f9',
                                                     'margin': '10px',
                                                     'padding': '15px',
                                                     'position': 'relative',
                                                     'flex': '1',
                                                     'box-shadow': '2px 2px 2px lightgrey'}),



                                    html.Div([html.Div('3rd Daily Player',id='3rdT'),
                                              html.H6(df_BestplayersOverall['Player'][2],
                                                      style={'font-size': '1.2rem',
                                                             'line-height': '1.6',
                                                             'letter-spacing': '0',
                                                             'margin-bottom': '0.75rem',
                                                             'margin-top': '0.75rem'}),
                                              html.Img(src= df_BestplayersOverall['LinkFlag'][2],
                                                       style={'max-width':'35%',
                                                              'max-height':'35%',
                                                              'float':'right'})],

                                    id='3rdP',style={'border-radius': '5px',
                                                     'background-color': '#f9f9f9',
                                                     'margin': '10px',
                                                     'padding': '15px',
                                                     'position': 'relative',
                                                     'flex': '1',
                                                     'box-shadow': '2px 2px 2px lightgrey'}),



                                    html.Div([html.Div('4th Daily Player',id='4thT'),
                                              html.H6(df_BestplayersOverall['Player'][3],
                                                      style={'font-size': '1.2rem',
                                                             'line-height': '1.6',
                                                             'letter-spacing': '0',
                                                             'margin-bottom': '0.75rem',
                                                             'margin-top': '0.75rem'}),
                                              html.Img(src= df_BestplayersOverall['LinkFlag'][3],
                                                       style={'max-width':'35%',
                                                              'max-height':'35%',
                                                              'float':'right'})],

                                    id='4thP',style={'border-radius': '5px',
                                                     'background-color': '#f9f9f9',
                                                     'margin': '10px',
                                                     'padding': '15px',
                                                     'position': 'relative',
                                                     'flex': '1',
                                                     'box-shadow': '2px 2px 2px lightgrey'}),



                                    html.Div([html.Div('5th Daily Player',id='5thT'),
                                              html.H6(df_BestplayersOverall['Player'][4],
                                                      style={'font-size': '1.2rem',
                                                             'line-height': '1.6',
                                                             'letter-spacing': '0',
                                                             'margin-bottom': '0.75rem',
                                                             'margin-top': '0.75rem'}),
                                              html.Img(src= df_BestplayersOverall['LinkFlag'][4],
                                                       style={'max-width':'35%',
                                                              'max-height':'35%',
                                                              'float':'right'})],

                                    id='5thP',style={'border-radius': '5px',
                                                     'background-color': '#f9f9f9',
                                                     'margin': '10px',
                                                     'padding': '15px',
                                                     'position': 'relative',
                                                     'flex': '1',
                                                     'box-shadow': '2px 2px 2px lightgrey'}),

                                         ],
                                 style={'display': 'flex'},
                                 id='info-container'
                                    ),








                        #plot the filter field on the screen to Graph bellow
                        html.Aside(style={"width": "47%",
                                          'margin-left':'1.5%'},
                                    children=[html.Label('Filter you continent'),
                                    dcc.Dropdown(id='QtyPlayer-regionF',
                                                 options=[{'label': i, 'value': i} for i in regionFilter],
                                                 value='Europe',
                                                 multi = False

                                    )
                            ]

                        ),
                        #plot the main Graphic on the Screen ( qtd of player by country)
                        html.Div(style={'width': '50%',
                                        'backgroundColor': colors['backgroundTable'],
                                        'margin-top':'1.5%',
                                        'margin-left':'1.5%',
                                        'height': '50%',
                                        'position':'absolute'},
                                 children=[dcc.Graph(id="QtyPlayer-Ctry",
                                                     style={'min-width': '85%',
                                                            'height':'95%',
                                                            'max-height':'95%',
                                                            'background-color':'#FFFFFF'})]

                        ),
                        html.Div(style={'width': '50%',
                                        'backgroundColor': colors['backgroundTable'],
                                        'margin-top': '30%',
                                        'margin-left':'1.5%'



                                        },
                                 children=[dcc.Graph(id="qtdy-continent",figure=d)]

                        ),
                        #plot the table base to Graph bellow on the screen
                        html.Div(style={'backgroundColor': colors['backgroundTable'], 'margin-top':'2%'},
                                 children =[dash_table.DataTable(
                                                                id='table',
                                                                columns=[{"name": i, "id": i} for i in dfRegionTable.columns],
                                                                page_current=0,
                                                                page_size=10,
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


    dfRegion = df1[df1['region'] == QtyPlayer_regionF]
    dfRegion = dfRegion.sort_values('Qty', ascending=False)
    dfRegionTable = df[df['region'] == QtyPlayer_regionF]



    #coding to declare the graph proprities
    fig = px.bar(dfRegion, x="Ctry", y='Qty')#grafic to show the quantity of racers by Ctry, but be able to use Tyre types, Course of event, anda Full date
    tab= dfRegionTable.iloc[
    page_current * page_size:(page_current + 1) * page_size
    ].to_dict('records')




    # codig to instance the plot on the screen
    fig.update_layout(
        #plot_bgcolor=colors['background'],
        #paper_bgcolor=colors['background'],
        font_color=colors['text']


    )



    return fig,tab






if __name__ == '__main__':
    app.run_server(debug=True)
