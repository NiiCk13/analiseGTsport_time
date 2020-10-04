# -*- coding: utf-8 -*-
# Run this app with `python app.py` and
# visit http://127.0.0.1:8050/ in your web browser.
import dash
import dash_core_components as dcc
import dash_html_components as html
import plotly.express as px
import pandas as pd
import numpy as np
from app_Graphics import generate_table


#Get all the tables that are used
dimensionContinent = pd.read_excel('C:/Users/nicolas.lelis/Desktop/dim_continent.xlsx')
dimensionTracks = pd.read_excel('DimensionTable_GtTracks.xlsx')
factTimes = pd.read_csv('FactTable_gtTimes.csv')

#Transfomation all the files in dataframes
df_continents = pd.DataFrame(dimensionContinent)
df_tracks = pd.DataFrame(dimensionTracks)
df_times = pd.DataFrame(factTimes)

#all the joins and transformations to main table
df = pd.DataFrame(df_times.merge(df_tracks, how='inner',  left_on='Link', right_on='Leaderboards'))
df = pd.DataFrame(df.merge(df_continents, how='inner',  left_on='Ctry', right_on='Area'))#Full data Table Frame
df[['Id']] = np.arange(len(df))


#build the firs fact dataframe
df1 = df.groupby(['End', 'Continent', 'Ctry', 'Course', 'Tyres']).agg({'Id': ['sum']})
df1.columns = ['Qty']
df1 = df1.reset_index()




#coding to declare the graph proprities
fig = px.bar(df1, x="Ctry", y='Qty', color="Course", barmode="group")#grafic to show the quantity of racers by Ctry, but be able to use Tyre types, Course of event, anda Full date



#coding to declare the style of page
colors = {
    'background': '#F7F7F0',
    'text': '#696964 ',
    'backgroundTable': '#FFFFFF'
}



#codig to instance the plot on the screen
fig.update_layout(
    plot_bgcolor=colors['background'],
    paper_bgcolor=colors['background'],
    font_color=colors['text']
)


app = dash.Dash(__name__)
app.layout=html.Div(style={'backgroundColor': colors['background']},
                       children=[html.H1(style={'color': colors['text']},
                                         children="GT Sport Data"
                                         ),

                        html.Div(style={'color': colors['text']},
                                 children ="Dash to show the quantity of participants\n in the Daily races by the country and tracks"
                        ),

                        html.Aside(style={'marin_right': 500},
                                   children=[html.Label('Filter you continent'),
                                    dcc.Dropdown(id='QtyPlayer-Ctry-dropdown',
                                                 options=[{'label': 'Continent', 'value': 'Area'}],
                                                 multi= True
                                     )]
                        ),

                        dcc.Graph(id="QtyPlayer-Ctry",
                                  figure=fig
                         ),

                        html.Div(style={'backgroundColor': colors['backgroundTable']},
                                 children =[html.H4(style={'color': colors['text'], 'textAlign': 'Center'},
                                                    children="Results of Daily"),
                                                    generate_table(df)
                                 ]
                        ),
                                #aspace to add another text by using html components or instanciate a Graph using dcc.Graph
                                #aspace to add another text by using html components or instanciate a Graph using dcc.Graph
                                #aspace to add another text by using html components or instanciate a Graph using dcc.Graph
                        ])

if __name__ == '__main__':


    app.run_server(debug=True)
