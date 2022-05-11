# This script extracts various bits of information from the Python library to re-use in the
# Julia package:
# - Models (names, bases, props, docstrings)
# - Named colors
# - Palettes
# - Hatch patterns
# - Dash patterns


# modified from https://github.com/bokeh/bokeh/blob/2.4.2/scripts/spec.py

import bokeh
assert bokeh.__version__ == '2.4.2'

import json
import inspect

from bokeh.core.property.bases import UndefinedType
from bokeh.core.property.descriptors import AliasPropertyDescriptor
from bokeh.model import Model

import bokeh.palettes
import bokeh.colors.named
import bokeh.models
import bokeh.models.widgets
import bokeh.core.enums
import bokeh.core.property.visual

def save(data, name):
    with open(f'spec/{name}.json', 'wt') as fp:
        json.dump(data, fp, indent=2)


### MODELS

def _proto(obj, defaults=False):
    t = type(obj)
    x = obj.to_json(defaults)
    del x['id']  # id is not informative, by excluding it we can find more inherited props
    x['__type__'] = t.__module__ + '.' + t.__name__
    return json.dumps(x, sort_keys=True, indent=None)

data = []
for name, m in sorted([("Model", Model)] + list(Model.model_class_reverse_map.items())):
    item = {
        'name'  : name,
        'fullname': m.__module__ + '.' + m.__name__,
        'bases' : [] if m is Model else [base.__module__ + '.' + base.__name__ for base in m.__bases__],
        'desc'  : inspect.cleandoc(m.__doc__ or ""),
    }
    props = []
    for prop_name in m.properties():
        descriptor = m.lookup(prop_name)
        if isinstance(descriptor, AliasPropertyDescriptor):
            continue

        prop = descriptor.property

        detail = {
            'name'    : prop_name,
            'type'    : str(prop),
            'desc'    : inspect.cleandoc(prop.__doc__ or ""),
        }

        default = descriptor.instance_default(m())

        if isinstance(default, UndefinedType):
            default = "<Undefined>"

        if isinstance(default, Model):
            default = _proto(default)

        if isinstance(default, (list, tuple)) and any(isinstance(x, Model) for x in default):
            default = [_proto(x) for x in default]

        if isinstance(default, dict) and any(isinstance(x, Model) for x in default.values()):
            default = { k: _proto(v) for k, v in default.items() }

        detail['default'] = default

        props.append(detail)

    item['props'] = props

    data.append(item)

save(data, 'model_types')


### PALETTES

palette_set = {p for ps in bokeh.palettes.all_palettes.values() for p in ps.values()}
assert all(isinstance(p, tuple) for p in palette_set)
palettes = {k:v for (k,v) in bokeh.palettes.__dict__.items() if isinstance(v, tuple) and v in palette_set}
save({'all':palettes, 'grouped':bokeh.palettes.all_palettes}, 'palettes')


### NAMED COLORS

colors = {c.name:c.to_hex() for c in bokeh.colors.named.colors}
save(colors, 'colors')


### HATCH PATTERNS

hatch_patterns = dict(bokeh.core.enums._hatch_patterns)
save(hatch_patterns, 'hatch_patterns')


### DASH PATTERNS

dash_patterns = bokeh.core.property.visual.DashPattern._dash_patterns
save(dash_patterns, 'dash_patterns')
