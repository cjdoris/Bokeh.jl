import importlib
import json
import pandas as pd

def save_json(data, name):
    with open(f'data/{name}.json', 'w') as fp:
        json.dump(data, fp, indent=2)

def save_df(data, name, datecols=[], timecols=[], datetimecols=[], numberlistcols=[]):
    data = json.loads(data.to_json(orient='table', index=False))
    cols = []
    for col in data['schema']['fields']:
        col = dict(col)
        assert col['type'] in ('string', 'integer', 'number')
        col['data'] = [x[col['name']] for x in data['data']]
        if col['name'] in datecols:
            assert col['type'] == 'string'
            col['type'] = 'date'
            assert all(x.endswith('T00:00:00.000Z') for x in col['data'])
            col['data'] = [x[:-14] for x in col['data']]
        elif col['name'] in timecols:
            assert col['type'] == 'string'
            col['type'] = 'time'
        elif col['name'] in datetimecols:
            assert col['type'] == 'string'
            col['type'] = 'datetime'
            assert all(x.endswith('Z') for x in col['data'])
            col['data'] = [x[:-1] for x in col['data']]
        elif col['name'] in numberlistcols:
            assert col['type'] == 'string'
            col['type'] = 'numberlist'
            assert all(isinstance(x, list) for x in col['data'])
        cols.append(col)
    save_json(cols, name)


### DATA FRAMES

for x in [
    dict(mod='anscombe'),
    dict(mod='antibiotics'),
    dict(mod='autompg', attr='autompg'),
    dict(mod='autompg', attr='autompg_clean'),
    dict(mod='autompg2', attr='autompg2'),
    dict(mod='browsers', attr='browsers_nov_2013'),
    dict(mod='commits', timecols=['time']),
    dict(mod='daylight', attr='daylight_warsaw_2013', datecols=['Date'], timecols=['Sunrise', 'Sunset']),
    dict(mod='penguins'),
    dict(mod='degrees'),
    dict(mod='iris', attr='flowers', name='iris'),
    dict(mod='mtb', attr='obiszow_mtb_xcm'),
    dict(mod='perceptions', attr='numberly'),
    dict(mod='perceptions', attr='probly'),
    dict(mod='periodic_table', attr='elements'),
    dict(mod='sea_surface_temperature', attr='sea_surface_temperature'),
    dict(mod='sprint', attr='sprint'),
    dict(mod='unemployment1948'),
    dict(mod='us_marriages_divorces'),
]:
    modname = x.pop('mod')
    attr = x.pop('attr', 'data')
    name = x.pop('name', modname if attr=='data' else attr)
    mod = importlib.import_module('bokeh.sampledata.' + modname)
    data = getattr(mod, attr)
    save_df(data, name, **x)


### LES MIS

from bokeh.sampledata.les_mis import data

save_df(pd.DataFrame(data['nodes'], columns=['name', 'group']), 'les_mis_nodes')
save_df(pd.DataFrame(data['links'], columns=['source','target','value']), 'les_mis_links')


### OLYMPICS

from bokeh.sampledata.olympics2014 import data

df = pd.DataFrame([
    (x['name'], x['abbr'], x['medals']['bronze'], x['medals']['silver'], x['medals']['gold'], x['medals']['total'])
    for x in data['data']
], columns=['name','abbr','bronze','silver','gold','total'])
save_df(df, 'olympics2014')


### US HOLIDAYS

from bokeh.sampledata.us_holidays import us_holidays as data

df = pd.DataFrame(data, columns=['date', 'name'])
save_df(df, 'us_holidays', datecols=['date'])


### US STATES

from bokeh.sampledata.us_states import data

df = pd.DataFrame([(k, v['name'], v['region'], v['lats'], v['lons']) for (k,v) in data.items()], columns=['code','name','region','lats','lons'])
save_df(df, 'us_states', numberlistcols=['lats','lons'])
